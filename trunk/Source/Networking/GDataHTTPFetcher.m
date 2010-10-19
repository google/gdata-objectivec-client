/* Copyright (c) 2007 Google Inc.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

//
//  GDataHTTPFetcher.m
//

#define GDATAHTTPFETCHER_DEFINE_GLOBALS 1

#import "GDataHTTPFetcher.h"

#if MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4
@interface NSURLConnection (LeopardMethodsOnTigerBuilds)
- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately;
- (void)start;
- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
@end
#endif

static NSString* const kGDataLastModifiedHeader = @"Last-Modified";
static NSString* const kGDataIfModifiedSinceHeader = @"If-Modified-Since";

SEL const kUnifiedFailureCallback = (SEL) (void *) -1;

static GDataCookieStorage* gGDataFetcherStaticCookieStorage = nil;
static Class gGDataFetcherConnectionClass = nil;
static NSArray *gGDataFetcherDefaultRunLoopModes = nil;

const NSTimeInterval kDefaultMaxRetryInterval = 60. * 10.; // 10 minutes

const NSTimeInterval kCachedURLReservationInterval = 60.; // 1 minute

//
// internal classes
//

// GDataURLCache and GDataCachedURLResponse have interfaces similar to their
// NSURLCache counterparts, in hopes that someday the NSURLCache versions
// can be used. But in 10.5.8, those are not reliable enough except when
// used with +setSharedURLCache. Our goal here is just to cache
// responses for handling if-modified-since requests that return
// "304 Not Modified" responses, not for replacing the general URL caches.

@interface GDataCachedURLResponse : NSObject {
  NSURLResponse *response_;
  NSData *data_;
  NSDate *useDate_;         // date this response was last saved or used
  NSDate *reservationDate_; // date this response's last modified date was used
}

- (id)initWithResponse:(NSURLResponse *)response data:(NSData *)data;
- (NSURLResponse *)response;
- (NSData *)data;

// date the response was saved or last accessed
- (NSDate *)useDate;
- (void)setUseDate:(NSDate *)date;

// date the response's last-modified header was last used for a fetch request
- (NSDate *)reservationDate;
- (void)setReservationDate:(NSDate *)date;
@end


@interface GDataURLCache : NSObject {
  NSMutableDictionary *responses_; // maps request URL to GDataCachedURLResponse
  NSUInteger memoryCapacity_;      // capacity of NSDatas in the responses
  NSUInteger totalDataSize_;       // sum of sizes of NSDatas of all responses
  NSTimeInterval reservationInterval_; // reservation expiration interval
}

- (id)initWithMemoryCapacity:(NSUInteger)totalBytes;

- (GDataCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request;
- (void)storeCachedResponse:(GDataCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request;
- (void)removeCachedResponseForRequest:(NSURLRequest *)request;
- (void)removeAllCachedResponses;

- (NSUInteger)memoryCapacity;
- (void)setMemoryCapacity:(NSUInteger)totalBytes;

// for unit testing
- (void)setReservationInterval:(NSTimeInterval)secs;
- (NSDictionary *)responses;
- (NSUInteger)totalDataSize;
@end

@interface GDataHTTPFetchHistory (InternalMethods)
- (NSString *)cachedLastModifiedStringForRequest:(NSURLRequest *)request;
- (NSData *)cachedDataForRequest:(NSURLRequest *)request;
- (void)removeCachedDataForRequest:(NSURLRequest *)request;
- (void)updateFetchHistoryWithRequest:(NSURLRequest *)request
                             response:(NSURLResponse *)response
                       downloadedData:(NSData *)downloadedData;
@end


//
// GDataHTTPFetcher
//

@interface GDataHTTPFetcher (PrivateMethods)
- (void)stopFetchReleasingBlocks:(BOOL)shouldReleaseBlocks;

- (void)handleCookiesForResponse:(NSURLResponse *)response;
- (void)setCookieStorage:(GDataCookieStorage *)obj;

- (void)logNowWithError:(NSError *)error;

- (BOOL)shouldRetryNowForStatus:(NSInteger)status error:(NSError *)error;
- (void)destroyRetryTimer;
- (void)beginRetryTimer;
- (void)primeRetryTimerWithNewTimeInterval:(NSTimeInterval)secs;
- (void)sendStopNotificationIfNeeded;
- (void)retryFetch;
@end


// Private protocol for logging methods to silence -Wundeclared-selector when
// building without logging code
@protocol GDataHTTPFetcherLoggingPrivate
- (void)setupStreamLogging;
- (void)logFetchWithError:(NSError *)error;
@end


@implementation GDataHTTPFetcher

+ (GDataHTTPFetcher *)httpFetcherWithRequest:(NSURLRequest *)request {
  return [[[[self class] alloc] initWithRequest:request] autorelease];
}

+ (void)initialize {
  // note that initialize is guaranteed by the runtime to be called in a
  // thread-safe manner
  if (!gGDataFetcherStaticCookieStorage) {
    gGDataFetcherStaticCookieStorage = [[GDataCookieStorage alloc] init];
  }
}

- (id)init {
  return [self initWithRequest:nil];
}

- (id)initWithRequest:(NSURLRequest *)request {
  if ((self = [super init]) != nil) {

    request_ = [request mutableCopy];

    // default to static cookie storage
    [self setCookieStorageMethod:kGDataHTTPFetcherCookieStorageMethodStatic];
  }
  return self;
}

- (id)copyWithZone:(NSZone *)zone {
  // disallow use of fetchers in a copy property
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

#if !GDATA_IPHONE
- (void)finalize {
  [self stopFetchReleasingBlocks:YES]; // releases connection_, destroys timers
  [super finalize];
}
#endif

- (void)dealloc {
  // note: if a connection or a retry timer was pending, then this instance
  // would be retained by those so it wouldn't be getting dealloc'd,
  // hence we don't need to stopFetch here

  [request_ release];
  [connection_ release];
  [downloadedData_ release];
  [downloadFileHandle_ release];
  [credential_ release];
  [proxyCredential_ release];
  [postData_ release];
  [postStream_ release];
  [loggedStreamData_ release];
  [response_ release];
#if NS_BLOCKS_AVAILABLE
  [completionBlock_ release];
  [receivedDataBlock_ release];
  [sentDataBlock_ release];
  [retryBlock_ release];
#endif
  [userData_ release];
  [properties_ release];
  [runLoopModes_ release];
  [fetchHistory_ release];
  [cookieStorage_ release];

  [retryTimer_ invalidate];
  [retryTimer_ release];

  [super dealloc];
}

#pragma mark -

// Updated fetched API
//
// Begin fetching the URL.  The delegate is retained for the duration of
// the fetch connection.
//
// The delegate must provide and implement the finished and failed selectors.
//
// finishedSEL has a signature like:
//   - (void)fetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data
// failedSEL has a signature like:
//   - (void)fetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error
//
// Server errors (status >= 300) are reported as the code of the error object.

- (BOOL)beginFetchWithDelegate:(id)delegate
             didFinishSelector:(SEL)finishedSEL
               didFailSelector:(SEL)failedSEL {

  return [self beginFetchWithDelegate:delegate
                    didFinishSelector:finishedSEL
            didFailWithStatusSelector:kUnifiedFailureCallback
             didFailWithErrorSelector:failedSEL];
}

#if NS_BLOCKS_AVAILABLE
- (BOOL)beginFetchWithCompletionHandler:(void (^)(NSData *data, NSError *error))handler {
  completionBlock_ = [handler copy];

  // the user may have called setDelegate: earlier if they want to use other
  // delegate-style callbacks during the fetch; otherwise, the delegate is nil,
  // which is fine
  return [self beginFetchWithDelegate:[self delegate]
                    didFinishSelector:nil
            didFailWithStatusSelector:kUnifiedFailureCallback
             didFailWithErrorSelector:nil];
}
#endif


// Original fetcher API
//
// Begin fetching the URL.  The delegate is retained for the duration of
// the fetch connection.
//
// The delegate must provide and implement the finished and failed selectors.
//
// finishedSEL has a signature like:
//   - (void)fetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data
// statusFailedSEL has a signature like:
//   - (void)fetcher:(GDataHTTPFetcher *)fetcher failedWithStatus:(NSInteger)status data:(NSData *)data
// failedSEL has a signature like:
//   - (void)fetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error

- (BOOL)beginFetchWithDelegate:(id)delegate
             didFinishSelector:(SEL)finishedSEL
     didFailWithStatusSelector:(SEL)statusFailedSEL
      didFailWithErrorSelector:(SEL)networkFailedSEL {

  AssertSelectorNilOrImplementedWithArguments(delegate, finishedSEL, @encode(GDataHTTPFetcher *), @encode(NSData *), 0);
  AssertSelectorNilOrImplementedWithArguments(delegate, networkFailedSEL, @encode(GDataHTTPFetcher *), @encode(NSError *), 0);
  AssertSelectorNilOrImplementedWithArguments(delegate, receivedDataSEL_, @encode(GDataHTTPFetcher *), @encode(NSData *), 0);
  AssertSelectorNilOrImplementedWithArguments(delegate, retrySEL_, @encode(GDataHTTPFetcher *), @encode(BOOL), @encode(NSError *), 0);

  if (statusFailedSEL != kUnifiedFailureCallback) {
    AssertSelectorNilOrImplementedWithArguments(delegate, statusFailedSEL, @encode(GDataHTTPFetcher *), @encode(NSInteger), @encode(NSData *), 0);
  }

  if (connection_ != nil) {
    NSAssert1(connection_ != nil, @"fetch object %@ being reused; this should never happen", self);
    goto CannotBeginFetch;
  }

  if (request_ == nil) {
    NSAssert(request_ != nil, @"beginFetchWithDelegate requires a request");
    goto CannotBeginFetch;
  }

  [downloadedData_ release];
  downloadedData_ = nil;

  finishedSEL_ = finishedSEL;
  networkFailedSEL_ = networkFailedSEL;
  statusFailedSEL_ = statusFailedSEL;

  NSString *effectiveHTTPMethod = [request_ valueForHTTPHeaderField:@"X-HTTP-Method-Override"];
  if (effectiveHTTPMethod == nil) {
    effectiveHTTPMethod = [request_ HTTPMethod];
  }
  BOOL isEffectiveHTTPGet = (effectiveHTTPMethod == nil
                             || [effectiveHTTPMethod isEqual:@"GET"]);

  if (postData_ || postStream_) {
    if (isEffectiveHTTPGet) {
      [request_ setHTTPMethod:@"POST"];
      isEffectiveHTTPGet = NO;
    }

    if (postData_) {
      [request_ setHTTPBody:postData_];
    } else {
      if ([self respondsToSelector:@selector(setupStreamLogging)]) {
        [self performSelector:@selector(setupStreamLogging)];
      }

      [request_ setHTTPBodyStream:postStream_];
    }
  }

  if (fetchHistory_) {

    // If this URL is in the history, set the Last-Modified header field

    // if we have a history, we're tracking across fetches, so we don't
    // want to pull results from any other cache
    [request_ setCachePolicy:NSURLRequestReloadIgnoringCacheData];

    if (isEffectiveHTTPGet) {
      // servers don't want if-modified-since on anything but GETs

      // we'll only add an If-Modified-Since header if there's no ETag
      // specified, since the ETag is a more important overall criteria
      NSString *etag = [request_ valueForHTTPHeaderField:@"If-None-Match"];
      if (etag == nil) {
        // no Etag: extract the last-modified date for this request from the
        // fetch history, and add it to the request
        NSString *lastModifiedStr = [fetchHistory_ cachedLastModifiedStringForRequest:request_];

        if (lastModifiedStr != nil) {
          [request_ addValue:lastModifiedStr forHTTPHeaderField:kGDataIfModifiedSinceHeader];
        }
      } else {
        // has an ETag: remove any stored response in the fetch history
        // for this request, as the If-None-Match header could lead to
        // a 304 Not Modified, and we want that error delivered to the user
        // since they explicitly specified the ETag
        [fetchHistory_ removeCachedDataForRequest:request_];
      }
    }
  }

  // get cookies for this URL from our storage array, if
  // we have a storage array
  if (cookieStorageMethod_ != kGDataHTTPFetcherCookieStorageMethodSystemDefault
      && cookieStorageMethod_ != kGDataHTTPFetcherCookieStorageMethodNone) {

    NSArray *cookies = [cookieStorage_ cookiesForURL:[request_ URL]];
    if ([cookies count]) {

      NSDictionary *headerFields = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
      NSString *cookieHeader = [headerFields objectForKey:@"Cookie"]; // key used in header dictionary
      if (cookieHeader) {
        [request_ addValue:cookieHeader forHTTPHeaderField:@"Cookie"]; // header name
      }
    }
  }

  // finally, start the connection

  Class connectionClass = [[self class] connectionClass];

  NSArray *runLoopModes = nil;

  if ([[self class] doesSupportRunLoopModes]) {

    // use the connection-specific run loop modes, if they were provided,
    // or else use the GDataHTTPFetcher default run loop modes, if any
    if (runLoopModes_) {
      runLoopModes = runLoopModes_;
    } else  {
      runLoopModes = gGDataFetcherDefaultRunLoopModes;
    }
  }

  if ([runLoopModes count] == 0) {

    // if no run loop modes were specified, then we'll start the connection
    // on the current run loop in the current mode
   connection_ = [[connectionClass connectionWithRequest:request_
                                                 delegate:self] retain];
  } else {

    // schedule on current run loop in the specified modes
    connection_ = [[connectionClass alloc] initWithRequest:request_
                                                  delegate:self
                                          startImmediately:NO];
    NSEnumerator *modeEnumerator = [runLoopModes objectEnumerator];
    NSString *mode;
    while ((mode = [modeEnumerator nextObject]) != nil) {
      [connection_ scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:mode];
    }
    [connection_ start];
  }
  hasConnectionEnded_ = NO;

  if (!connection_) {
    NSAssert(connection_ != nil, @"beginFetchWithDelegate could not create a connection");
    goto CannotBeginFetch;
  }

  // we'll retain the delegate only during the outstanding connection (similar
  // to what Cocoa does with performSelectorOnMainThread:) since we'd crash
  // if the delegate was released in the interim.
  [self setDelegate:delegate];

  if (downloadFileHandle_ != nil) {
    // downloading to a file, so downloadedData_ remains nil
  } else {
    downloadedData_ = [[NSMutableData alloc] init];
  }

  // once connection_ is non-nil we can send the start notification
  isStopNotificationNeeded_ = YES;
  NSNotificationCenter *defaultNC = [NSNotificationCenter defaultCenter];
  [defaultNC postNotificationName:kGDataHTTPFetcherStartedNotification
                           object:self];

  return YES;

CannotBeginFetch:

  if (networkFailedSEL) {

    NSError *error = [NSError errorWithDomain:kGDataHTTPFetcherErrorDomain
                                         code:kGDataHTTPFetcherErrorDownloadFailed
                                     userInfo:nil];

    [[self retain] autorelease]; // in case the callback releases us

    [delegate performSelector:networkFailedSEL
                   withObject:self
                   withObject:error];
  }

  return NO;
}

// Returns YES if this is in the process of fetching a URL, or waiting to
// retry
- (BOOL)isFetching {
  return (connection_ != nil || retryTimer_ != nil);
}

// Returns the status code set in connection:didReceiveResponse:
- (NSInteger)statusCode {

  NSInteger statusCode;

  if (response_ != nil
    && [response_ respondsToSelector:@selector(statusCode)]) {

    statusCode = [(NSHTTPURLResponse *)response_ statusCode];
  } else {
    //  Default to zero, in hopes of hinting "Unknown" (we can't be
    //  sure that things are OK enough to use 200).
    statusCode = 0;
  }
  return statusCode;
}

- (NSDictionary *)responseHeaders {
  if (response_ != nil
      && [response_ respondsToSelector:@selector(allHeaderFields)]) {

    NSDictionary *headers = [(NSHTTPURLResponse *)response_ allHeaderFields];
    return headers;
  }
  return nil;
}

// Cancel the fetch of the URL that's currently in progress.
- (void)stopFetchReleasingBlocks:(BOOL)shouldReleaseBlocks {
  // if the connection or the retry timer is all that's retaining the fetcher,
  // we want to be sure this instance survives stopping at least long enough for
  // the stack to unwind
  [[self retain] autorelease];

  [self destroyRetryTimer];

  if (connection_) {
    // in case cancelling the connection calls this recursively, we want
    // to ensure that we'll only release the connection and delegate once,
    // so first set connection_ to nil
    NSURLConnection* oldConnection = connection_;
    connection_ = nil;

    if (!hasConnectionEnded_) {
      [oldConnection cancel];
    }

    // this may be called in a callback from the connection, so use autorelease
    [oldConnection autorelease];

    // send the stopped notification
    [self sendStopNotificationIfNeeded];

    // balance the retain done when the connection was opened
    [delegate_ autorelease];
    delegate_ = nil;
  }

#if NS_BLOCKS_AVAILABLE
  // avoid a retain loop in case the blocks are referencing
  // the fetcher instance
  if (shouldReleaseBlocks) {
    [completionBlock_ autorelease];
    completionBlock_ = nil;

    [self setSentDataBlock:nil];
    [self setReceivedDataBlock:nil];
    [self setRetryBlock:nil];
  }
#endif
}

// external stop method
- (void)stopFetching {
  [self stopFetchReleasingBlocks:YES];
}

- (void)sendStopNotificationIfNeeded {
  if (isStopNotificationNeeded_) {
    isStopNotificationNeeded_ = NO;

    NSNotificationCenter *defaultNC = [NSNotificationCenter defaultCenter];
    [defaultNC postNotificationName:kGDataHTTPFetcherStoppedNotification
                             object:self];
  }
}

- (void)retryFetch {

  id holdDelegate = [[delegate_ retain] autorelease];

  [self stopFetchReleasingBlocks:NO];

  [self beginFetchWithDelegate:holdDelegate
             didFinishSelector:finishedSEL_
     didFailWithStatusSelector:statusFailedSEL_
      didFailWithErrorSelector:networkFailedSEL_];
}

#pragma mark NSURLConnection Delegate Methods

//
// NSURLConnection Delegate Methods
//

// This method just says "follow all redirects", which _should_ be the default behavior,
// According to file:///Developer/ADC%20Reference%20Library/documentation/Cocoa/Conceptual/URLLoadingSystem
// but the redirects were not being followed until I added this method.  May be
// a bug in the NSURLConnection code, or the documentation.
//
// In OS X 10.4.8 and earlier, the redirect request doesn't
// get the original's headers and body. This causes POSTs to fail.
// So we construct a new request, a copy of the original, with overrides from the
// redirect.
//
// Docs say that if redirectResponse is nil, just return the redirectRequest.

- (NSURLRequest *)connection:(NSURLConnection *)connection
             willSendRequest:(NSURLRequest *)redirectRequest
            redirectResponse:(NSURLResponse *)redirectResponse {

  if (redirectRequest && redirectResponse) {
    NSMutableURLRequest *newRequest = [[request_ mutableCopy] autorelease];
    // copy the URL
    NSURL *redirectURL = [redirectRequest URL];
    NSURL *url = [newRequest URL];

    // disallow scheme changes (say, from https to http)
    NSString *redirectScheme = [url scheme];
    NSString *newScheme = [redirectURL scheme];
    NSString *newResourceSpecifier = [redirectURL resourceSpecifier];

    if ([redirectScheme caseInsensitiveCompare:@"http"] == NSOrderedSame
        && newScheme != nil
        && [newScheme caseInsensitiveCompare:@"https"] == NSOrderedSame) {

      // allow the change from http to https
      redirectScheme = newScheme;
    }

    NSString *newUrlString = [NSString stringWithFormat:@"%@:%@",
      redirectScheme, newResourceSpecifier];

    NSURL *newURL = [NSURL URLWithString:newUrlString];
    [newRequest setURL:newURL];

    // any headers in the redirect override headers in the original.
    NSDictionary *redirectHeaders = [redirectRequest allHTTPHeaderFields];
    if (redirectHeaders) {
      NSEnumerator *enumerator = [redirectHeaders keyEnumerator];
      NSString *key;
      while (nil != (key = [enumerator nextObject])) {
        NSString *value = [redirectHeaders objectForKey:key];
        [newRequest setValue:value forHTTPHeaderField:key];
      }
    }
    redirectRequest = newRequest;

    // save cookies from the response
    [self handleCookiesForResponse:redirectResponse];

    // log the response we just received
    [self setResponse:redirectResponse];
    [self logNowWithError:nil];

    // update the request for future logging
    [self setRequest:redirectRequest];
}
  return redirectRequest;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

  // this method is called when the server has determined that it
  // has enough information to create the NSURLResponse
  // it can be called multiple times, for example in the case of a
  // redirect, so each time we reset the data.
  [downloadedData_ setLength:0];
  [downloadFileHandle_ truncateFileAtOffset:0];

  [self setResponse:response];

  // save cookies from the response
  [self handleCookiesForResponse:response];
}


// handleCookiesForResponse: handles storage of cookies for responses passed to
// connection:willSendRequest:redirectResponse: and connection:didReceiveResponse:
- (void)handleCookiesForResponse:(NSURLResponse *)response {

  if (cookieStorageMethod_ == kGDataHTTPFetcherCookieStorageMethodSystemDefault
    || cookieStorageMethod_ == kGDataHTTPFetcherCookieStorageMethodNone) {

    // do nothing special for NSURLConnection's default storage mechanism
    // or when we're ignoring cookies

  } else if ([response respondsToSelector:@selector(allHeaderFields)]) {

    // grab the cookies from the header as NSHTTPCookies and store them either
    // into our static array or into the fetchHistory

    NSDictionary *responseHeaderFields = [(NSHTTPURLResponse *)response allHeaderFields];
    if (responseHeaderFields) {

      NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:responseHeaderFields
                                                                forURL:[response URL]];
      if ([cookies count] > 0) {
        [cookieStorage_ setCookies:cookies];
      }
    }
  }
}

-(void)connection:(NSURLConnection *)connection
       didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {

  if ([challenge previousFailureCount] <= 2) {

    NSURLCredential *credential = credential_;

    if ([[challenge protectionSpace] isProxy] && proxyCredential_ != nil) {
      credential = proxyCredential_;
    }

    // Here, if credential is still nil, then we *could* try to get it from
    // NSURLCredentialStorage's defaultCredentialForProtectionSpace:.
    // We don't, because we're assuming:
    //
    // - for server credentials, we only want ones supplied by the program
    //   calling http fetcher
    // - for proxy credentials, if one were necessary and available in the
    //   keychain, it would've been found automatically by NSURLConnection
    //   and this challenge delegate method never would've been called
    //   anyway

    if (credential) {
      // try the credential
      [[challenge sender] useCredential:credential
             forAuthenticationChallenge:challenge];
      return;
    }
  }

  // If we don't have credentials, or we've already failed auth 3x,
  // report the error, putting the challenge as a value in the userInfo
  // dictionary
#if DEBUG
  NSAssert(!isCancellingChallenge_, @"isCancellingChallenge_ unexpected");
#endif
  NSDictionary *userInfo = [NSDictionary dictionaryWithObject:challenge
                                                       forKey:kGDataHTTPFetcherErrorChallengeKey];
  NSError *error = [NSError errorWithDomain:kGDataHTTPFetcherErrorDomain
                                       code:kGDataHTTPFetcherErrorAuthenticationChallengeFailed
                                   userInfo:userInfo];

  // cancelAuthenticationChallenge seems to indirectly call
  // connection:didFailWithError: now, though that isn't documented
  //
  // we'll use an ivar to make the indirect invocation of the
  // delegate method do nothing
  isCancellingChallenge_ = YES;
  [[challenge sender] cancelAuthenticationChallenge:challenge];
  isCancellingChallenge_ = NO;

  [self connection:connection didFailWithError:error];
}

- (void)invokeSentDataCallback:(SEL)sel
                        target:(id)target
               didSendBodyData:(NSInteger)bytesWritten
             totalBytesWritten:(NSInteger)totalBytesWritten
     totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {

  NSMethodSignature *sig = [target methodSignatureForSelector:sel];
  NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
  [invocation setSelector:sel];
  [invocation setTarget:target];
  [invocation setArgument:&self atIndex:2];
  [invocation setArgument:&bytesWritten atIndex:3];
  [invocation setArgument:&totalBytesWritten atIndex:4];
  [invocation setArgument:&totalBytesExpectedToWrite atIndex:5];
  [invocation invoke];
}

- (void)invokeStatusCallback:(SEL)sel
                      target:(id)target
                      status:(NSInteger)status
                        data:(NSData *)data {

  NSMethodSignature *signature = [delegate_ methodSignatureForSelector:sel];
  NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
  [invocation setSelector:statusFailedSEL_];
  [invocation setTarget:target];
  [invocation setArgument:&self atIndex:2];
  [invocation setArgument:&status atIndex:3];
  [invocation setArgument:&downloadedData_ atIndex:4];
  [invocation invoke];
}

- (BOOL)invokeRetryCallback:(SEL)sel
                     target:(id)target
                  willRetry:(BOOL)willRetry
                      error:(NSError *)error {
  NSMethodSignature *sig = [target methodSignatureForSelector:sel];
  NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
  [invocation setSelector:sel];
  [invocation setTarget:target];
  [invocation setArgument:&self atIndex:2];
  [invocation setArgument:&willRetry atIndex:3];
  [invocation setArgument:&error atIndex:4];
  [invocation invoke];

  [invocation getReturnValue:&willRetry];
  return willRetry;
}

- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {

  SEL sel = [self sentDataSelector];
  if (delegate_ && sel) {
    [self invokeSentDataCallback:sel
                          target:delegate_
                 didSendBodyData:bytesWritten
               totalBytesWritten:totalBytesWritten
       totalBytesExpectedToWrite:totalBytesExpectedToWrite];
  }

#if NS_BLOCKS_AVAILABLE
  if (sentDataBlock_) {
    sentDataBlock_(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
  }
#endif
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
#if DEBUG
  // the download file handle should be set before the fetch is started, not
  // after
  NSAssert((downloadFileHandle_ == nil) != (downloadedData_ == nil),
           @"received data accumulates as NSData or NSFileHandle, not both");
#endif

  if (downloadFileHandle_ != nil) {
    // append to file
    @try {
      [downloadFileHandle_ writeData:data];
    }
    @catch (NSException *exc) {
      // couldn't write to file, probably due to a full disk
      NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[exc reason]
                                                           forKey:NSLocalizedDescriptionKey];
      NSError *error = [NSError errorWithDomain:kGDataHTTPFetcherStatusDomain
                                           code:kGDataHTTPFetcherErrorFileHandleException
                                       userInfo:userInfo];
      [self connection:connection didFailWithError:error];
      return;
    }
  } else {
    // append to mutable data
    [downloadedData_ appendData:data];
  }

  if (receivedDataSEL_) {
    [delegate_ performSelector:receivedDataSEL_
                    withObject:self
                    withObject:downloadedData_];
  }

#if NS_BLOCKS_AVAILABLE
  if (receivedDataBlock_) {
    receivedDataBlock_(downloadedData_);
  }
#endif
}


// For error 304's ("Not Modified") where we've cached the data, return status
// 200 ("OK") to the caller (but leave the fetcher status as 304)
// and copy the cached data.
//
// For other errors or if there's no cached data, just return the actual status.
- (NSInteger)statusAfterHandlingNotModifiedError {

  NSInteger status = [self statusCode];
  if (status == kGDataHTTPFetcherStatusNotModified
      && [fetchHistory_ shouldCacheDatedData]) {

    NSData *cachedData = [fetchHistory_ cachedDataForRequest:request_];
    if (cachedData) {
      // forge the status to pass on to the delegate
      status = 200;

      // copy our stored data, and forge the status to pass on to the delegate
      if (downloadFileHandle_ != nil) {
        @try {
          // Downloading to a file handle won't save to the cache (the data is
          // likely inappropriately large for caching), but will still read from
          // the cache, on the unlikely chance that the response was Not Modified
          // and the URL response was indeed present in the cache.
          [downloadFileHandle_ truncateFileAtOffset:0];
          [downloadFileHandle_ writeData:cachedData];
        }
        @catch (NSException * e) {
          // Failed to write data, likely due to lack of disk space
          status = kGDataHTTPFetcherErrorFileHandleException;
        }
      } else {
        [downloadedData_ setData:cachedData];
      }
    }
  }
  return status;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  hasConnectionEnded_ = YES;

  // skip caching ETagged results when the data is being saved to a file
  if (downloadFileHandle_ == nil) {
    [fetchHistory_ updateFetchHistoryWithRequest:request_
                                        response:response_
                                  downloadedData:downloadedData_];
  } else {
    [fetchHistory_ removeCachedDataForRequest:request_];
  }

  [[self retain] autorelease]; // in case the callback releases us

  [self logNowWithError:nil];

  NSInteger status = [self statusAfterHandlingNotModifiedError];

  // we want to send the stop notification before calling the delegate's
  // callback selector, since the callback selector may release all of
  // the fetcher properties that the client is using to track the fetches
  //
  // We'll also stop now so that, to any observers watching the notifications,
  // it doesn't look like our wait for a retry (which may be long,
  // 30 seconds or more) is part of the network activity
  [self sendStopNotificationIfNeeded];

  BOOL shouldStopFetching = YES;

  // if there's an error status, retry or notify the client
  if (status < 0 || status >= 300) {

    if ([self shouldRetryNowForStatus:status error:nil]) {
      // retrying
      [self beginRetryTimer];
      shouldStopFetching = NO;

    } else if (statusFailedSEL_ == kUnifiedFailureCallback) {
      // not retrying, and no separate status callback, so call the
      // sole failure selector or the completion block
      NSDictionary *userInfo = nil;
      if (downloadedData_) {
        userInfo = [NSDictionary dictionaryWithObject:downloadedData_
                                               forKey:kGDataHTTPFetcherStatusDataKey];
      }

      NSError *error = [NSError errorWithDomain:kGDataHTTPFetcherStatusDomain
                                           code:status
                                       userInfo:userInfo];
      if (networkFailedSEL_) {
        [delegate_ performSelector:networkFailedSEL_
                        withObject:self
                        withObject:error];
      }

#if NS_BLOCKS_AVAILABLE
      if (completionBlock_) {
        completionBlock_(nil, error);
      }
#endif

    } else if (statusFailedSEL_) {
      // not retrying, call status failure callback
      [self invokeStatusCallback:statusFailedSEL_
                          target:delegate_
                          status:status
                            data:downloadedData_];
    }
  } else {
    // successful http status (under 300)
    if (finishedSEL_) {
      [delegate_ performSelector:finishedSEL_
                      withObject:self
                      withObject:downloadedData_];
    }

#if NS_BLOCKS_AVAILABLE
    if (completionBlock_) {
      completionBlock_(downloadedData_, nil);
    }
#endif
  }

  if (shouldStopFetching) {
    [self stopFetching];
  }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  // prevent the failure callback from being called twice, since the stopFetch
  // call below (either the explicit one at the end of this method, or the
  // implicit one when the retry occurs) will release the delegate
  if (connection_ == nil) return;

  // if this method was invoked indirectly by cancellation of an authentication
  // challenge, defer this until it is called again with the proper error object
  if (isCancellingChallenge_) return;

  // we no longer need to cancel the connection
  hasConnectionEnded_ = YES;

  [self logNowWithError:error];

  // see comment about sendStopNotificationIfNeeded
  // in connectionDidFinishLoading:
  [self sendStopNotificationIfNeeded];

  if ([self shouldRetryNowForStatus:0 error:error]) {

    [self beginRetryTimer];

  } else {

    [[self retain] autorelease]; // in case the callback releases us

    if (networkFailedSEL_) {
      [delegate_ performSelector:networkFailedSEL_
                      withObject:self
                      withObject:error];
    }

#if NS_BLOCKS_AVAILABLE
    if (completionBlock_) {
      completionBlock_(nil, error);
    }
#endif

    [self stopFetchReleasingBlocks:YES];
  }
}

- (void)logNowWithError:(NSError *)error {
  // if the logging category is available, then log the current request,
  // response, data, and error
  if ([self respondsToSelector:@selector(logFetchWithError:)]) {
    [self performSelector:@selector(logFetchWithError:) withObject:error];
  }
}

#pragma mark Retries

- (BOOL)isRetryError:(NSError *)error {

  struct retryRecord {
    NSString *const domain;
    int code;
  };

  // Previously we also retried for
  //   { NSURLErrorDomain, NSURLErrorNetworkConnectionLost }
  // but at least on 10.4, once that happened, retries would keep failing
  // with the same error.

  struct retryRecord retries[] = {
    { kGDataHTTPFetcherStatusDomain, 408 }, // request timeout
    { kGDataHTTPFetcherStatusDomain, 503 }, // service unavailable
    { kGDataHTTPFetcherStatusDomain, 504 }, // request timeout
    { NSURLErrorDomain, NSURLErrorTimedOut },
    { nil, 0 }
  };

  // NSError's isEqual always returns false for equal but distinct instances
  // of NSError, so we have to compare the domain and code values explicitly

  for (int idx = 0; retries[idx].domain != nil; idx++) {

    if ([[error domain] isEqual:retries[idx].domain]
        && [error code] == retries[idx].code) {

      return YES;
    }
  }
  return NO;
}


// shouldRetryNowForStatus:error: returns YES if the user has enabled retries
// and the status or error is one that is suitable for retrying.  "Suitable"
// means either the isRetryError:'s list contains the status or error, or the
// user's retrySelector: is present and returns YES when called.
- (BOOL)shouldRetryNowForStatus:(NSInteger)status
                          error:(NSError *)error {

  if ([self isRetryEnabled]) {

    if ([self nextRetryInterval] < [self maxRetryInterval]) {

      if (error == nil) {
        // make an error for the status
       error = [NSError errorWithDomain:kGDataHTTPFetcherStatusDomain
                                   code:status
                               userInfo:nil];
      }

      BOOL willRetry = [self isRetryError:error];

      if (retrySEL_) {
        willRetry = [self invokeRetryCallback:retrySEL_
                                       target:delegate_
                                    willRetry:willRetry
                                        error:error];
      }

#if NS_BLOCKS_AVAILABLE
      if (retryBlock_) {
        willRetry = retryBlock_(willRetry, error);
      }
#endif

      return willRetry;
    }
  }

  return NO;
}

- (void)beginRetryTimer {

  NSTimeInterval nextInterval = [self nextRetryInterval];
  NSTimeInterval maxInterval = [self maxRetryInterval];

  NSTimeInterval newInterval = MIN(nextInterval, maxInterval);

  [self primeRetryTimerWithNewTimeInterval:newInterval];
}

- (void)retryTimerFired:(NSTimer *)timer {

  [self destroyRetryTimer];

  retryCount_++;

  [self retryFetch];
}

- (void)primeRetryTimerWithNewTimeInterval:(NSTimeInterval)secs {

  [self destroyRetryTimer];

  lastRetryInterval_ = secs;

  retryTimer_ = [NSTimer scheduledTimerWithTimeInterval:secs
                                  target:self
                                selector:@selector(retryTimerFired:)
                                userInfo:nil
                                 repeats:NO];
  [retryTimer_ retain];

  NSNotificationCenter *defaultNC = [NSNotificationCenter defaultCenter];
  [defaultNC postNotificationName:kGDataHTTPFetcherRetryDelayStartedNotification
                           object:self];
}

- (void)destroyRetryTimer {
  if (retryTimer_) {
    [retryTimer_ invalidate];
    [retryTimer_ autorelease];
    retryTimer_ = nil;

    NSNotificationCenter *defaultNC = [NSNotificationCenter defaultCenter];
    [defaultNC postNotificationName:kGDataHTTPFetcherRetryDelayStoppedNotification
                             object:self];
  }
}

- (NSUInteger)retryCount {
  return retryCount_;
}

- (NSTimeInterval)nextRetryInterval {
  // the next wait interval is the factor (2.0) times the last interval,
  // but never less than the minimum interval
  NSTimeInterval secs = lastRetryInterval_ * retryFactor_;
  secs = MIN(secs, maxRetryInterval_);
  secs = MAX(secs, minRetryInterval_);

  return secs;
}

- (BOOL)isRetryEnabled {
  return isRetryEnabled_;
}

- (void)setIsRetryEnabled:(BOOL)flag {

  if (flag && !isRetryEnabled_) {
    // We defer initializing these until the user calls setIsRetryEnabled
    // to avoid using the random number generator if it's not needed.
    // However, this means min and max intervals for this fetcher are reset
    // as a side effect of calling setIsRetryEnabled.
    //
    // make an initial retry interval random between 1.0 and 2.0 seconds
    [self setMinRetryInterval:0.0];
    [self setMaxRetryInterval:kDefaultMaxRetryInterval];
    [self setRetryFactor:2.0];
    lastRetryInterval_ = 0.0;
  }
  isRetryEnabled_ = flag;
};

- (SEL)retrySelector {
  return retrySEL_;
}

- (void)setRetrySelector:(SEL)theSelector {
  retrySEL_ = theSelector;
}

#if NS_BLOCKS_AVAILABLE
- (void)setRetryBlock:(BOOL (^)(BOOL, NSError *))block {
  [retryBlock_ autorelease];
  retryBlock_ = [block copy];
}
#endif

- (NSTimeInterval)maxRetryInterval {
  return maxRetryInterval_;
}

- (void)setMaxRetryInterval:(NSTimeInterval)secs {
  if (secs > 0) {
    maxRetryInterval_ = secs;
  } else {
    maxRetryInterval_ = kDefaultMaxRetryInterval;
  }
}

- (double)minRetryInterval {
  return minRetryInterval_;
}

- (void)setMinRetryInterval:(NSTimeInterval)secs {
  if (secs > 0) {
    minRetryInterval_ = secs;
  } else {
    // set min interval to a random value between 1.0 and 2.0 seconds
    // so that if multiple clients start retrying at the same time, they'll
    // repeat at different times and avoid overloading the server
    minRetryInterval_ = 1.0 + ((double)(arc4random() & 0x0FFFF) / (double) 0x0FFFF);
  }
}

- (double)retryFactor {
  return retryFactor_;
}

- (void)setRetryFactor:(double)multiplier {
  retryFactor_ = multiplier;
}

#pragma mark Getters and Setters

- (NSMutableURLRequest *)request {
  return request_;
}

- (void)setRequest:(NSURLRequest *)theRequest {
  [request_ autorelease];
  request_ = [theRequest mutableCopy];
}

- (NSURLCredential *)credential {
  return credential_;
}

- (void)setCredential:(NSURLCredential *)theCredential {
  [credential_ autorelease];
  credential_ = [theCredential retain];
}

- (NSURLCredential *)proxyCredential {
  return proxyCredential_;
}

- (void)setProxyCredential:(NSURLCredential *)theCredential {
  [proxyCredential_ autorelease];
  proxyCredential_ = [theCredential retain];
}

- (NSData *)postData {
  return postData_;
}

- (void)setPostData:(NSData *)theData {
  [postData_ autorelease];
  postData_ = [theData retain];
}

- (NSInputStream *)postStream {
  return postStream_;
}

- (void)setPostStream:(NSInputStream *)theStream {
  [postStream_ autorelease];
  postStream_ = [theStream retain];
}

- (NSInteger)cookieStorageMethod {
  return cookieStorageMethod_;
}

- (void)setCookieStorageMethod:(NSInteger)method {

  cookieStorageMethod_ = method;

  if (method == kGDataHTTPFetcherCookieStorageMethodSystemDefault) {
    // system default
    [request_ setHTTPShouldHandleCookies:YES];

    // no need for a cookie storage object
    [self setCookieStorage:nil];

  } else {
    // not system default
    [request_ setHTTPShouldHandleCookies:NO];

    if (method == kGDataHTTPFetcherCookieStorageMethodStatic) {
      // store cookies in the static array
      [self setCookieStorage:gGDataFetcherStaticCookieStorage];
    } else if (method == kGDataHTTPFetcherCookieStorageMethodFetchHistory) {
      // store cookies in the fetch history
      [self setCookieStorage:[fetchHistory_ cookieStorage]];
    } else {
      // kGDataHTTPFetcherCookieStorageMethodNone - ignore cookies
      [self setCookieStorage:nil];
    }
  }
}

- (id)delegate {
  return delegate_;
}

- (void)setDelegate:(id)theDelegate {
  [delegate_ autorelease];
  delegate_ = [theDelegate retain];
}

+ (BOOL)doesSupportSentDataCallback {
#if GDATA_IPHONE
  // NSURLConnection's didSendBodyData: delegate support appears to be
  // available starting in iPhone OS 3.0
  return (NSFoundationVersionNumber >= 678.47);
#else
  // per WebKit's MaxFoundationVersionWithoutdidSendBodyDataDelegate
  //
  // indicates if NSURLConnection will invoke the didSendBodyData: delegate
  // method
  return (NSFoundationVersionNumber > 677.21);
#endif
}

- (SEL)sentDataSelector {
  return sentDataSEL_;
}

- (void)setSentDataSelector:(SEL)theSelector {
  sentDataSEL_ = theSelector;
}

- (SEL)receivedDataSelector {
  return receivedDataSEL_;
}

- (void)setReceivedDataSelector:(SEL)theSelector {
  receivedDataSEL_ = theSelector;
}

#if NS_BLOCKS_AVAILABLE
- (void)setSentDataBlock:(void (^)(NSInteger, NSInteger, NSInteger))block {
  [sentDataBlock_ autorelease];
  sentDataBlock_ = [block copy];
}

- (void)setReceivedDataBlock:(void (^)(NSData *))block {
  [receivedDataBlock_ autorelease];
  receivedDataBlock_ = [block copy];
}
#endif

- (NSData *)downloadedData {
  return downloadedData_;
}

- (NSFileHandle *)downloadFileHandle {
  return downloadFileHandle_;
}

- (void)setDownloadFileHandle:(NSFileHandle *)fileHandle {
  [downloadFileHandle_ autorelease];
  downloadFileHandle_ = [fileHandle retain];
}

- (NSURLResponse *)response {
  return response_;
}

- (void)setResponse:(NSURLResponse *)response {
  [response_ autorelease];
  response_ = [response retain];
}

- (GDataHTTPFetchHistory *)fetchHistory {
  return fetchHistory_;
}

- (void)setFetchHistory:(GDataHTTPFetchHistory *)fetchHistory {
  [fetchHistory_ autorelease];
  fetchHistory_ = [fetchHistory retain];

  if (fetchHistory_ != nil) {
    // set the fetch history's cookie array to be the cookie store
    [self setCookieStorageMethod:kGDataHTTPFetcherCookieStorageMethodFetchHistory];

  } else {
    // the fetch history was removed
    if (cookieStorageMethod_ == kGDataHTTPFetcherCookieStorageMethodFetchHistory) {
      // fall back to static storage
      [self setCookieStorageMethod:kGDataHTTPFetcherCookieStorageMethodStatic];
    }
  }
}

- (void)setCookieStorage:(GDataCookieStorage *)obj {
  [cookieStorage_ autorelease];
  cookieStorage_ = [obj retain];
}

- (GDataCookieStorage *)cookieStorage {
  return cookieStorage_;
}

- (void)setShouldCacheDatedData:(BOOL)flag {
  [fetchHistory_ setShouldCacheDatedData:flag];
}

- (BOOL)shouldCacheDatedData {
  return [fetchHistory_ shouldCacheDatedData];
}

// delete last-modified dates and cached data from the fetch history
- (void)clearDatedDataHistory {
  [fetchHistory_ clearDatedDataCache];
}

- (void)setDatedDataCacheMemoryCapacity:(NSUInteger)val {
  [fetchHistory_ setMemoryCapacity:val];
}

- (NSUInteger)datedDataCacheMemoryCapacity {
  return [fetchHistory_ memoryCapacity];
}

- (id)userData {
  return userData_;
}

- (void)setUserData:(id)theObj {
  [userData_ autorelease];
  userData_ = [theObj retain];
}

- (void)setProperties:(NSDictionary *)dict {
  [properties_ autorelease];
  properties_ = [dict mutableCopy];
}

- (NSDictionary *)properties {
  return properties_;
}

- (void)setProperty:(id)obj forKey:(NSString *)key {

  if (properties_ == nil && obj != nil) {
    [self setProperties:[NSDictionary dictionary]];
  }

  [properties_ setValue:obj forKey:key];
}

- (id)propertyForKey:(NSString *)key {
  return [properties_ objectForKey:key];
}

- (void)addPropertiesFromDictionary:(NSDictionary *)dict {
  if (properties_ == nil && dict != nil) {
    [self setProperties:dict];
  } else {
    [properties_ addEntriesFromDictionary:dict];
  }
}

- (NSArray *)runLoopModes {
  return runLoopModes_;
}

- (void)setRunLoopModes:(NSArray *)modes {
  [runLoopModes_ autorelease];
  runLoopModes_ = [modes retain];
}

+ (BOOL)doesSupportRunLoopModes {
  SEL sel = @selector(initWithRequest:delegate:startImmediately:);
  return [NSURLConnection instancesRespondToSelector:sel];
}

+ (NSArray *)defaultRunLoopModes {
  return gGDataFetcherDefaultRunLoopModes;
}

+ (void)setDefaultRunLoopModes:(NSArray *)modes {
  [gGDataFetcherDefaultRunLoopModes autorelease];
  gGDataFetcherDefaultRunLoopModes = [modes retain];
}

+ (Class)connectionClass {
  if (gGDataFetcherConnectionClass == nil) {
    gGDataFetcherConnectionClass = [NSURLConnection class];
  }
  return gGDataFetcherConnectionClass;
}

+ (void)setConnectionClass:(Class)theClass {
  gGDataFetcherConnectionClass = theClass;
}

#if STRIP_GDATA_FETCH_LOGGING
+ (void)setIsLoggingEnabled:(BOOL)flag {
}
#endif // STRIP_GDATA_FETCH_LOGGING

@end

@implementation GDataCookieStorage

- (id)init {
  self = [super init];
  if (self != nil) {
    cookies_ = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc {
  [cookies_ release];
  [super dealloc];
}

// add all cookies in the new cookie array to the storage,
// replacing stored cookies as appropriate
//
// Side effect: removes expired cookies from the storage array
- (void)setCookies:(NSArray *)newCookies {

  @synchronized(cookies_) {
    [self removeExpiredCookies];

    NSEnumerator *newCookieEnum = [newCookies objectEnumerator];
    NSHTTPCookie *newCookie;

    while ((newCookie = [newCookieEnum nextObject]) != nil) {

      if ([[newCookie name] length] > 0
          && [[newCookie domain] length] > 0
          && [[newCookie path] length] > 0) {

        // remove the cookie if it's currently in the array
        NSHTTPCookie *oldCookie = [self cookieMatchingCookie:newCookie];
        if (oldCookie) {
          [cookies_ removeObjectIdenticalTo:oldCookie];
        }

        // make sure the cookie hasn't already expired
        NSDate *expiresDate = [newCookie expiresDate];
        if ((!expiresDate) || [expiresDate timeIntervalSinceNow] > 0) {
          [cookies_ addObject:newCookie];
        }

      } else {
        NSAssert1(NO, @"Cookie incomplete: %@", newCookie);
      }
    }
  }
}

// retrieve all cookies appropriate for the given URL, considering
// domain, path, cookie name, expiration, security setting.
// Side effect: removed expired cookies from the storage array
- (NSArray *)cookiesForURL:(NSURL *)theURL {

  NSMutableArray *foundCookies = nil;

  @synchronized(cookies_) {
    [self removeExpiredCookies];

    // we'll prepend "." to the desired domain, since we want the
    // actual domain "nytimes.com" to still match the cookie domain
    // ".nytimes.com" when we check it below with hasSuffix
    NSString *host = [[theURL host] lowercaseString];
    NSString *path = [theURL path];
    NSString *scheme = [theURL scheme];

    NSString *domain = nil;
    BOOL isLocalhostRetrieval = NO;

    if ([host isEqual:@"localhost"]) {
      isLocalhostRetrieval = YES;
    } else {
      if (host) {
        domain = [@"." stringByAppendingString:host];
      }
    }

    NSUInteger numberOfCookies = [cookies_ count];
    for (NSUInteger idx = 0; idx < numberOfCookies; idx++) {

      NSHTTPCookie *storedCookie = [cookies_ objectAtIndex:idx];

      NSString *cookieDomain = [[storedCookie domain] lowercaseString];
      NSString *cookiePath = [storedCookie path];
      BOOL cookieIsSecure = [storedCookie isSecure];

      BOOL isDomainOK;

      if (isLocalhostRetrieval) {
        // prior to 10.5.6, the domain stored into NSHTTPCookies for localhost
        // is "localhost.local"
        isDomainOK = [cookieDomain isEqual:@"localhost"]
          || [cookieDomain isEqual:@"localhost.local"];
      } else {
        isDomainOK = [domain hasSuffix:cookieDomain];
      }

      BOOL isPathOK = [cookiePath isEqual:@"/"] || [path hasPrefix:cookiePath];
      BOOL isSecureOK = (!cookieIsSecure) || [scheme isEqual:@"https"];

      if (isDomainOK && isPathOK && isSecureOK) {
        if (foundCookies == nil) {
          foundCookies = [NSMutableArray arrayWithCapacity:1];
        }
        [foundCookies addObject:storedCookie];
      }
    }
  }
  return foundCookies;
}

// return a cookie from the array with the same name, domain, and path as the
// given cookie, or else return nil if none found
//
// Both the cookie being tested and all cookies in the storage array should
// be valid (non-nil name, domains, paths)
//
// note: this should only be called from inside a @synchronized(cookies_) block
- (NSHTTPCookie *)cookieMatchingCookie:(NSHTTPCookie *)cookie {

  NSUInteger numberOfCookies = [cookies_ count];
  NSString *name = [cookie name];
  NSString *domain = [cookie domain];
  NSString *path = [cookie path];

  NSAssert3(name && domain && path, @"Invalid cookie (name:%@ domain:%@ path:%@)",
            name, domain, path);

  for (NSUInteger idx = 0; idx < numberOfCookies; idx++) {

    NSHTTPCookie *storedCookie = [cookies_ objectAtIndex:idx];

    if ([[storedCookie name] isEqual:name]
        && [[storedCookie domain] isEqual:domain]
        && [[storedCookie path] isEqual:path]) {

      return storedCookie;
    }
  }
  return nil;
}


// internal routine to remove any expired cookies from the array, excluding
// cookies with nil expirations
//
// note: this should only be called from inside a @synchronized(cookies_) block
- (void)removeExpiredCookies {

  // count backwards since we're deleting items from the array
  for (NSInteger idx = [cookies_ count] - 1; idx >= 0; idx--) {

    NSHTTPCookie *storedCookie = [cookies_ objectAtIndex:idx];

    NSDate *expiresDate = [storedCookie expiresDate];
    if (expiresDate && [expiresDate timeIntervalSinceNow] < 0) {
      [cookies_ removeObjectAtIndex:idx];
    }
  }
}

- (void)removeAllCookies {
  @synchronized(cookies_) {
    [cookies_ removeAllObjects];
  }
}
@end

//
// GDataCachedURLResponse
//

@implementation GDataCachedURLResponse

- (id)initWithResponse:(NSURLResponse *)response data:(NSData *)data {
  self = [super init];
  if (self != nil) {
    response_ = [response retain];
    data_ = [data retain];
    useDate_ = [[NSDate alloc] init];
  }
  return self;
}

- (void)dealloc {
  [response_ release];
  [data_ release];
  [useDate_ release];
  [reservationDate_ release];
  [super dealloc];
}

- (NSString *)description {
  NSString *reservationStr = reservationDate_ ?
    [NSString stringWithFormat:@" resDate:%@", reservationDate_] : @"";

  return [NSString stringWithFormat:@"%@ %p: {bytes:%@ useDate:%@%@}",
          [self class], self,
          data_ ? [NSNumber numberWithInt:(int)[data_ length]] : nil,
          useDate_,
          reservationStr,
          [response_ URL]];
}

// setters/getters

- (NSURLResponse *)response {
  return response_;
}

- (NSData *)data {
  return data_;
}

- (NSDate *)reservationDate{
  return reservationDate_;
}

- (void)setReservationDate:(NSDate *)date {
  [reservationDate_ autorelease];
  reservationDate_ = [date retain];
}

- (NSDate *)useDate{
  return useDate_;
}

- (void)setUseDate:(NSDate *)date {
  [useDate_ autorelease];
  useDate_ = [date retain];
}

- (NSComparisonResult)compareUseDate:(GDataCachedURLResponse *)other {
  return [useDate_ compare:[other useDate]];
}

@end

//
// GDataURLCache
//

@implementation GDataURLCache

- (id)init {
  return [self initWithMemoryCapacity:kGDataDefaultDatedDataCacheMemoryCapacity];
}

- (id)initWithMemoryCapacity:(NSUInteger)totalBytes {
  self = [super init];
  if (self != nil) {
    memoryCapacity_ = totalBytes;

    responses_ = [[NSMutableDictionary alloc] initWithCapacity:5];

    reservationInterval_ = kCachedURLReservationInterval;
  }
  return self;
}

- (void)dealloc {
  [responses_ release];
  [super dealloc];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@ %p: {responses:%@}",
          [self class], self, [responses_ allValues]];
}

// setters/getters

- (void)pruneCacheResponses {
  // internal routine to remove the least-recently-used responses when the
  // cache has grown too large
  if (memoryCapacity_ >= totalDataSize_) return;

  // sort keys by date
  SEL sel = @selector(compareUseDate:);
  NSArray *sortedKeys = [responses_ keysSortedByValueUsingSelector:sel];

  // the least-recently-used keys are at the beginning of the sorted array;
  // remove those (except ones still reserved) until the total data size is
  // reduced sufficiently
  NSEnumerator *keyEnum = [sortedKeys objectEnumerator];
  NSURL *key;
  while ((key = [keyEnum nextObject]) != nil) {
    GDataCachedURLResponse *response = [responses_ objectForKey:key];

    NSDate *resDate = [response reservationDate];
    BOOL isResponseReserved = (resDate != nil)
      && ([resDate timeIntervalSinceNow] > -reservationInterval_);

    if (!isResponseReserved) {
      // we can remove this response from the cache
      NSUInteger storedSize = [[response data] length];
      totalDataSize_ -= storedSize;
      [responses_ removeObjectForKey:key];
    }

    // if we've removed enough response data, then we're done
    if (memoryCapacity_ >= totalDataSize_) break;
  }
}

- (void)storeCachedResponse:(GDataCachedURLResponse *)cachedResponse
                 forRequest:(NSURLRequest *)request {
  @synchronized(self) {
    // remove any previous entry for this request
    [self removeCachedResponseForRequest:request];

    // cache this one only if it's not bigger than our cache
    NSUInteger storedSize = [[cachedResponse data] length];
    if (storedSize < memoryCapacity_) {

      NSURL *key = [request URL];
      [responses_ setObject:cachedResponse forKey:key];
      totalDataSize_ += storedSize;

      [self pruneCacheResponses];
    }
  }
}

- (GDataCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
  GDataCachedURLResponse *response;

  @synchronized(self) {
    NSURL *key = [request URL];
    response = [[[responses_ objectForKey:key] retain] autorelease];

    // touch the date to indicate this was recently retrieved
    [response setUseDate:[NSDate date]];
  }
  return response;
}

- (void)removeCachedResponseForRequest:(NSURLRequest *)request {
  @synchronized(self) {
    NSURL *key = [request URL];
    totalDataSize_ -= [[[responses_ objectForKey:key] data] length];
    [responses_ removeObjectForKey:key];
  }
}

- (void)removeAllCachedResponses {
  @synchronized(self) {
    [responses_ removeAllObjects];
    totalDataSize_ = 0;
  }
}

- (NSUInteger)memoryCapacity {
  return memoryCapacity_;
}

- (void)setMemoryCapacity:(NSUInteger)totalBytes {
  @synchronized(self) {
    BOOL didShrink = (totalBytes < memoryCapacity_);
    memoryCapacity_ = totalBytes;

    if (didShrink) {
      [self pruneCacheResponses];
    }
  }
}

// methods for unit testing
- (void)setReservationInterval:(NSTimeInterval)secs {
  reservationInterval_ = secs;
}

- (NSDictionary *)responses {
  return responses_;
}

- (NSUInteger)totalDataSize {
  return totalDataSize_;
}

@end

//
// GDataHTTPFetchHistory
//

@implementation GDataHTTPFetchHistory

- (id)init {
 return [self initWithMemoryCapacity:kGDataDefaultDatedDataCacheMemoryCapacity
                shouldCacheDatedData:NO];
}

- (id)initWithMemoryCapacity:(NSUInteger)totalBytes
        shouldCacheDatedData:(BOOL)shouldCacheDatedData {
  self = [super init];
  if (self != nil) {
    datedDataCache_ = [[GDataURLCache alloc] initWithMemoryCapacity:totalBytes];
    shouldCacheDatedData_ = shouldCacheDatedData;
    cookieStorage_ = [[GDataCookieStorage alloc] init];
  }
  return self;
}

- (void)dealloc {
  [datedDataCache_ release];
  [cookieStorage_ release];
  [super dealloc];
}

- (void)updateFetchHistoryWithRequest:(NSURLRequest *)request
                             response:(NSURLResponse *)response
                       downloadedData:(NSData *)downloadedData {

  if (![response respondsToSelector:@selector(allHeaderFields)]) return;

  NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];

  if (statusCode != kGDataHTTPFetcherStatusNotModified) {
    // save this last modified date string for successful results (<300)
    // If there's no last modified string, clear the dictionary
    // entry for this URL. Also cache or delete the data, if appropriate
    // (when datedDataCache is non-nil.)
    NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
    NSString* lastModifiedStr = [headers objectForKey:kGDataLastModifiedHeader];

    if (lastModifiedStr != nil && statusCode < 300) {

      // we want to cache responses for the headers, even if the client
      // doesn't want the response body data caches
      NSData *dataToStore = shouldCacheDatedData_ ? downloadedData : nil;

      GDataCachedURLResponse *cachedResponse;
      cachedResponse = [[[GDataCachedURLResponse alloc] initWithResponse:response
                                                                    data:dataToStore] autorelease];
      [datedDataCache_ storeCachedResponse:cachedResponse
                                forRequest:request];
    } else {
      [datedDataCache_ removeCachedResponseForRequest:request];
    }
  }
}

- (NSString *)cachedLastModifiedStringForRequest:(NSURLRequest *)request {
  GDataCachedURLResponse *cachedResponse;
  cachedResponse = [datedDataCache_ cachedResponseForRequest:request];

  NSURLResponse *response = [cachedResponse response];
  NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
  NSString *lastModifiedStr = [headers objectForKey:kGDataLastModifiedHeader];
  if (lastModifiedStr) {
    // since the request for a last-mod date implies this request is about
    // to be fetched again, reserve the cached response to ensure that
    // that it will be around at least until the fetch completes
    //
    // when the fetch completes, either the cached response will be replaced
    // with a new response, or the cachedDataForRequest: method below will
    // clear the reservation
    [cachedResponse setReservationDate:[NSDate date]];
  }
  return lastModifiedStr;
}

- (NSData *)cachedDataForRequest:(NSURLRequest *)request {
  GDataCachedURLResponse *cachedResponse;
  cachedResponse = [datedDataCache_ cachedResponseForRequest:request];

  NSData *cachedData = [cachedResponse data];

  // since the data for this cached request is being obtained from the cache,
  // we can clear the reservation as the fetch has completed
  [cachedResponse setReservationDate:nil];

  return cachedData;
}

- (void)removeCachedDataForRequest:(NSURLRequest *)request {
  [datedDataCache_ removeCachedResponseForRequest:request];
}

- (void)clearDatedDataCache {
  [datedDataCache_ removeAllCachedResponses];
}

- (void)clearHistory {
  [self clearDatedDataCache];
  [cookieStorage_ removeAllCookies];
}

- (GDataCookieStorage *)cookieStorage {
  return cookieStorage_;
}

- (void)setCookieStorage:(GDataCookieStorage *)obj {
  [cookieStorage_ autorelease];
  cookieStorage_ = [obj retain];
}

- (BOOL)shouldCacheDatedData {
  return shouldCacheDatedData_;
}

- (void)setShouldCacheDatedData:(BOOL)flag {
  BOOL wasCaching = shouldCacheDatedData_;
  shouldCacheDatedData_ = flag;

  if (wasCaching && !flag) {
    // users expect turning off caching to free up the cache memory
    [self clearDatedDataCache];
  }
}

- (NSUInteger)memoryCapacity {
  return [datedDataCache_ memoryCapacity];
}

- (void)setMemoryCapacity:(NSUInteger)totalBytes {
  [datedDataCache_ setMemoryCapacity:totalBytes];
}

@end

#ifdef GDATA_FOUNDATION_ONLY
#define Debugger()
#endif

void AssertSelectorNilOrImplementedWithArguments(id obj, SEL sel, ...) {

  // verify that the object's selector is implemented with the proper
  // number and type of arguments
#if DEBUG
  va_list argList;
  va_start(argList, sel);

  if (obj && sel) {
    // check that the selector is implemented
    if (![obj respondsToSelector:sel]) {
      NSLog(@"\"%@\" selector \"%@\" is unimplemented or misnamed",
                             NSStringFromClass([obj class]),
                             NSStringFromSelector(sel));
      Debugger();
    } else {
      const char *expectedArgType;
      unsigned int argCount = 2; // skip self and _cmd
      NSMethodSignature *sig = [obj methodSignatureForSelector:sel];

      // check that each expected argument is present and of the correct type
      while ((expectedArgType = va_arg(argList, const char*)) != 0) {

        if ([sig numberOfArguments] > argCount) {
          const char *foundArgType = [sig getArgumentTypeAtIndex:argCount];

          if(0 != strncmp(foundArgType, expectedArgType, strlen(expectedArgType))) {
            NSLog(@"\"%@\" selector \"%@\" argument %d should be type %s",
                  NSStringFromClass([obj class]),
                  NSStringFromSelector(sel), (argCount - 2), expectedArgType);
            Debugger();
          }
        }
        argCount++;
      }

      // check that the proper number of arguments are present in the selector
      if (argCount != [sig numberOfArguments]) {
        NSLog( @"\"%@\" selector \"%@\" should have %d arguments",
                       NSStringFromClass([obj class]),
                       NSStringFromSelector(sel), (argCount - 2));
        Debugger();
      }
    }
  }

  va_end(argList);
#endif
}
