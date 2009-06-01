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
#import "GDataHTTPFetcherLogging.h"

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

static NSMutableArray* gGDataFetcherStaticCookies = nil;
static Class gGDataFetcherConnectionClass = nil;
static NSArray *gGDataFetcherDefaultRunLoopModes = nil;

const NSTimeInterval kDefaultMaxRetryInterval = 60. * 10.; // 10 minutes

@interface GDataHTTPFetcher (PrivateMethods)
- (void)setCookies:(NSArray *)newCookies
           inArray:(NSMutableArray *)cookieStorageArray;
- (NSArray *)cookiesForURL:(NSURL *)theURL inArray:(NSMutableArray *)cookieStorageArray;
- (void)handleCookiesForResponse:(NSURLResponse *)response;

- (BOOL)shouldRetryNowForStatus:(NSInteger)status error:(NSError *)error;
- (void)destroyRetryTimer;
- (void)beginRetryTimer;
- (void)primeRetryTimerWithNewTimeInterval:(NSTimeInterval)secs;
- (void)retryFetch;
@end

@implementation GDataHTTPFetcher

+ (GDataHTTPFetcher *)httpFetcherWithRequest:(NSURLRequest *)request {
  return [[[GDataHTTPFetcher alloc] initWithRequest:request] autorelease];
}

+ (void)initialize {
  if (!gGDataFetcherStaticCookies) {
    gGDataFetcherStaticCookies = [[NSMutableArray alloc] init];
  }
}

- (id)init {
  return [self initWithRequest:nil];
}

- (id)initWithRequest:(NSURLRequest *)request {
  if ((self = [super init]) != nil) {

    request_ = [request mutableCopy];

    [self setCookieStorageMethod:kGDataHTTPFetcherCookieStorageMethodStatic];
  }
  return self;
}

- (void)dealloc {
  [self stopFetching]; // releases connection_, destroys timers

  [request_ release];
  [downloadedData_ release];
  [credential_ release];
  [proxyCredential_ release];
  [postData_ release];
  [postStream_ release];
  [loggedStreamData_ release];
  [response_ release];
  [userData_ release];
  [properties_ release];
  [runLoopModes_ release];
  [fetchHistory_ release];

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
//   - (void)fetcher:(GDataHTTPFetcher *)fetcher failedWithStatus:(int)status data:(NSData *)data
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
    AssertSelectorNilOrImplementedWithArguments(delegate, statusFailedSEL, @encode(GDataHTTPFetcher *), @encode(int), @encode(NSData *), 0);
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

  [self setDelegate:delegate];
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

      // if logging is enabled, it needs a buffer to accumulate data from any
      // NSInputStream used for uploading.  Logging will wrap the input
      // stream with a stream that lets us keep a copy the data being read.
      if ([GDataHTTPFetcher isLoggingEnabled] && postStream_ != nil) {
        loggedStreamData_ = [[NSMutableData alloc] init];
        [self logCapturePostStream];
      }

      [request_ setHTTPBodyStream:postStream_];
    }
  }

  if (fetchHistory_) {

    // If this URL is in the history, set the Last-Modified header field

    // if we have a history, we're tracking across fetches, so we don't
    // want to pull results from a cache
    [request_ setCachePolicy:NSURLRequestReloadIgnoringCacheData];

    if (isEffectiveHTTPGet) {
      NSDictionary* lastModifiedDict = [fetchHistory_ objectForKey:kGDataHTTPFetcherHistoryLastModifiedKey];
      NSString* urlString = [[request_ URL] absoluteString];
      NSString* lastModifiedStr = [lastModifiedDict objectForKey:urlString];

      // servers don't want if-modified-since on anything but GETs
      if (lastModifiedStr != nil) {
        [request_ addValue:lastModifiedStr forHTTPHeaderField:kGDataIfModifiedSinceHeader];
      }
    }
  }

  // get cookies for this URL from our storage array, if
  // we have a storage array
  if (cookieStorageMethod_ != kGDataHTTPFetcherCookieStorageMethodSystemDefault) {

    NSArray *cookies = [self cookiesForURL:[request_ URL]];
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

  if (!connection_) {
    NSAssert(connection_ != nil, @"beginFetchWithDelegate could not create a connection");
    goto CannotBeginFetch;
  }

  // we'll retain the delegate only during the outstanding connection (similar
  // to what Cocoa does with performSelectorOnMainThread:) since we'd crash
  // if the delegate was released in the interim.  We don't retain the selector
  // at other times, to avoid vicious retain loops.  This retain is balanced in
  // the -stopFetch method.
  [delegate_ retain];

  downloadedData_ = [[NSMutableData alloc] init];
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
- (void)stopFetching {
  [self destroyRetryTimer];

  if (connection_) {
    // in case cancelling the connection calls this recursively, we want
    // to ensure that we'll only release the connection and delegate once,
    // so first set connection_ to nil

    NSURLConnection* oldConnection = connection_;
    connection_ = nil;

    // this may be called in a callback from the connection, so use autorelease
    [oldConnection cancel];
    [oldConnection autorelease];

    // balance the retain done when the connection was opened
    [delegate_ release];
  }
}

- (void)retryFetch {

  id holdDelegate = [[delegate_ retain] autorelease];

  [self stopFetching];

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
    [self logFetchWithError:nil];

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

  [self setResponse:response];

  // save cookies from the response
  [self handleCookiesForResponse:response];
}


// handleCookiesForResponse: handles storage of cookies for responses passed to
// connection:willSendRequest:redirectResponse: and connection:didReceiveResponse:
- (void)handleCookiesForResponse:(NSURLResponse *)response {

  if (cookieStorageMethod_ == kGDataHTTPFetcherCookieStorageMethodSystemDefault) {

    // do nothing special for NSURLConnection's default storage mechanism

  } else if ([response respondsToSelector:@selector(allHeaderFields)]) {

    // grab the cookies from the header as NSHTTPCookies and store them either
    // into our static array or into the fetchHistory

    NSDictionary *responseHeaderFields = [(NSHTTPURLResponse *)response allHeaderFields];
    if (responseHeaderFields) {

      NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:responseHeaderFields
                                                                forURL:[response URL]];
      if ([cookies count] > 0) {

        NSMutableArray *cookieArray = nil;

        // static cookies are stored in gGDataFetcherStaticCookies; fetchHistory
        // cookies are stored in fetchHistory_'s kGDataHTTPFetcherHistoryCookiesKey

        if (cookieStorageMethod_ == kGDataHTTPFetcherCookieStorageMethodStatic) {

          cookieArray = gGDataFetcherStaticCookies;

        } else if (cookieStorageMethod_ == kGDataHTTPFetcherCookieStorageMethodFetchHistory
                   && fetchHistory_ != nil) {

          cookieArray = [fetchHistory_ objectForKey:kGDataHTTPFetcherHistoryCookiesKey];
          if (cookieArray == nil) {
            cookieArray = [NSMutableArray array];
            [fetchHistory_ setObject:cookieArray forKey:kGDataHTTPFetcherHistoryCookiesKey];
          }
        }

        if (cookieArray) {
          @synchronized(cookieArray) {
            [self setCookies:cookies inArray:cookieArray];
          }
        }
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
  //
  // put the challenge in the userInfo dictionary first so that cancelling
  // doesn't release it yet

  NSDictionary *userInfo = [NSDictionary dictionaryWithObject:challenge
                                                       forKey:kGDataHTTPFetcherErrorChallengeKey];
  [[challenge sender] cancelAuthenticationChallenge:challenge];


  NSError *error = [NSError errorWithDomain:kGDataHTTPFetcherErrorDomain
                                       code:kGDataHTTPFetcherErrorAuthenticationChallengeFailed
                                   userInfo:userInfo];

  [self connection:connection didFailWithError:error];
}



- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

  [downloadedData_ appendData:data];

  if (receivedDataSEL_) {
   [delegate_ performSelector:receivedDataSEL_
                   withObject:self
                   withObject:downloadedData_];
  }
}

- (void)updateFetchHistory {

  if (fetchHistory_) {

    NSString* urlString = [[request_ URL] absoluteString];
    if ([response_ respondsToSelector:@selector(allHeaderFields)]) {
      NSDictionary *headers = [(NSHTTPURLResponse *)response_ allHeaderFields];
      NSString* lastModifiedStr = [headers objectForKey:kGDataLastModifiedHeader];

      // get the dictionary mapping URLs to last-modified dates
      NSMutableDictionary* lastModifiedDict = [fetchHistory_ objectForKey:kGDataHTTPFetcherHistoryLastModifiedKey];
      if (!lastModifiedDict) {
        lastModifiedDict = [NSMutableDictionary dictionary];
        [fetchHistory_ setObject:lastModifiedDict forKey:kGDataHTTPFetcherHistoryLastModifiedKey];
      }

      NSMutableDictionary* datedDataCache = nil;
      if (shouldCacheDatedData_) {
        // get the dictionary mapping URLs to cached, dated data
        datedDataCache = [fetchHistory_ objectForKey:kGDataHTTPFetcherHistoryDatedDataKey];
        if (!datedDataCache) {
          datedDataCache = [NSMutableDictionary dictionary];
          [fetchHistory_ setObject:datedDataCache forKey:kGDataHTTPFetcherHistoryDatedDataKey];
        }
      }

      NSInteger statusCode = [self statusCode];
      if (statusCode != kGDataHTTPFetcherStatusNotModified) {

        // save this last modified date string for successful results (<300)
        // If there's no last modified string, clear the dictionary
        // entry for this URL. Also cache or delete the data, if appropriate
        // (when datedDataCache is non-nil.)
        if (lastModifiedStr && statusCode < 300) {
          [lastModifiedDict setValue:lastModifiedStr forKey:urlString];
          [datedDataCache setValue:downloadedData_ forKey:urlString];
        } else {
          [lastModifiedDict removeObjectForKey:urlString];
          [datedDataCache removeObjectForKey:urlString];
        }
      }
    }
  }
}

// for error 304's ("Not Modified") where we've cached the data, return status
// 200 ("OK") to the caller (but leave the fetcher status as 304)
// and copy the cached data to downloadedData_.
// For other errors or if there's no cached data, just return the actual status.
- (NSInteger)statusAfterHandlingNotModifiedError {

  NSInteger status = [self statusCode];
  if (status == kGDataHTTPFetcherStatusNotModified && shouldCacheDatedData_) {

    // get the dictionary of URLs and data
    NSString* urlString = [[request_ URL] absoluteString];

    NSDictionary* datedDataCache = [fetchHistory_ objectForKey:kGDataHTTPFetcherHistoryDatedDataKey];
    NSData* cachedData = [datedDataCache objectForKey:urlString];

    if (cachedData) {
      // copy our stored data, and forge the status to pass on to the delegate
      [downloadedData_ setData:cachedData];
      status = 200;
    }
  }
  return status;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

  [self updateFetchHistory];

  [[self retain] autorelease]; // in case the callback releases us

  [self logFetchWithError:nil];

  NSInteger status = [self statusAfterHandlingNotModifiedError];

  // if there's an error status and the client gave us a status error
  // selector, then call that selector
  if (status >= 300 && statusFailedSEL_) {

    if ([self shouldRetryNowForStatus:status error:nil]) {

      [self beginRetryTimer];

    } else if (statusFailedSEL_ == kUnifiedFailureCallback) {

      // not retrying, and no separate status callback, so call the
      // sole failure selector
      NSDictionary *userInfo =
        [NSDictionary dictionaryWithObject:downloadedData_
                                    forKey:kGDataHTTPFetcherStatusDataKey];

      NSError *error = [NSError errorWithDomain:kGDataHTTPFetcherStatusDomain
                                           code:status
                                       userInfo:userInfo];

      [delegate_ performSelector:networkFailedSEL_
                      withObject:self
                      withObject:error];

      [self stopFetching];

    } else {
      // not retrying, call status failure callback
      NSMethodSignature *signature = [delegate_ methodSignatureForSelector:statusFailedSEL_];
      NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:statusFailedSEL_];
      [invocation setTarget:delegate_];
      [invocation setArgument:&self atIndex:2];
      [invocation setArgument:&status atIndex:3];
      [invocation setArgument:&downloadedData_ atIndex:4];
      [invocation invoke];

      [self stopFetching];
    }
  } else if (finishedSEL_) {

    // successful http status (under 300)
    [delegate_ performSelector:finishedSEL_
                    withObject:self
                    withObject:downloadedData_];
    [self stopFetching];
  }

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

  [self logFetchWithError:error];

  if ([self shouldRetryNowForStatus:0 error:error]) {

    [self beginRetryTimer];

  } else {

    if (networkFailedSEL_) {
      [[self retain] autorelease]; // in case the callback releases us

      [delegate_ performSelector:networkFailedSEL_
                      withObject:self
                      withObject:error];
    }

    [self stopFetching];
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
        NSMethodSignature *signature = [delegate_ methodSignatureForSelector:retrySEL_];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:retrySEL_];
        [invocation setTarget:delegate_];
        [invocation setArgument:&self atIndex:2];
        [invocation setArgument:&willRetry atIndex:3];
        [invocation setArgument:&error atIndex:4];
        [invocation invoke];

        [invocation getReturnValue:&willRetry];
      }

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

- (void)primeRetryTimerWithNewTimeInterval:(NSTimeInterval)secs {

  [self destroyRetryTimer];

  lastRetryInterval_ = secs;

  retryTimer_ = [NSTimer scheduledTimerWithTimeInterval:secs
                                  target:self
                                selector:@selector(retryTimerFired:)
                                userInfo:nil
                                 repeats:NO];
  [retryTimer_ retain];
}

- (void)retryTimerFired:(NSTimer *)timer {

  [self destroyRetryTimer];

  retryCount_++;

  [self retryFetch];
}

- (void)destroyRetryTimer {

  [retryTimer_ invalidate];
  [retryTimer_ autorelease];
  retryTimer_ = nil;
}

- (unsigned int)retryCount {
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
    // to avoid seeding the random number generator if it's not needed.
    // However, it means min and max intervals for this fetcher are reset
    // as a side effect of calling setIsRetryEnabled.
    //
    // seed the random value, and make an initial retry interval
    // random between 1.0 and 2.0 seconds
    srandomdev();
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
    minRetryInterval_ = 1.0 + ((double)(random() & 0x0FFFF) / (double) 0x0FFFF);
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

- (int)cookieStorageMethod {
  return cookieStorageMethod_;
}

- (void)setCookieStorageMethod:(int)method {

  cookieStorageMethod_ = method;

  if (method == kGDataHTTPFetcherCookieStorageMethodSystemDefault) {
    [request_ setHTTPShouldHandleCookies:YES];
  } else {
    [request_ setHTTPShouldHandleCookies:NO];
  }
}

- (id)delegate {
  return delegate_;
}

- (void)setDelegate:(id)theDelegate {

  // we retain delegate_ only during the life of the connection
  if (connection_) {
    [delegate_ autorelease];
    delegate_ = [theDelegate retain];
  } else {
    delegate_ = theDelegate;
  }
}

- (SEL)receivedDataSelector {
  return receivedDataSEL_;
}

- (void)setReceivedDataSelector:(SEL)theSelector {
  receivedDataSEL_ = theSelector;
}

- (NSURLResponse *)response {
  return response_;
}

- (void)setResponse:(NSURLResponse *)response {
  [response_ autorelease];
  response_ = [response retain];
}

- (NSMutableDictionary *)fetchHistory {
  return fetchHistory_;
}

- (void)setFetchHistory:(NSMutableDictionary *)fetchHistory {
  [fetchHistory_ autorelease];
  fetchHistory_ = [fetchHistory retain];

  if (fetchHistory_ != nil) {
    [self setCookieStorageMethod:kGDataHTTPFetcherCookieStorageMethodFetchHistory];
  } else {
    [self setCookieStorageMethod:kGDataHTTPFetcherCookieStorageMethodStatic];
  }
}

- (void)setShouldCacheDatedData:(BOOL)flag {
  shouldCacheDatedData_ = flag;
  if (!flag) {
    [self clearDatedDataHistory];
  }
}

- (BOOL)shouldCacheDatedData {
  return shouldCacheDatedData_;
}

// delete last-modified dates and cached data from the fetch history
- (void)clearDatedDataHistory {
  [fetchHistory_ removeObjectForKey:kGDataHTTPFetcherHistoryLastModifiedKey];
  [fetchHistory_ removeObjectForKey:kGDataHTTPFetcherHistoryDatedDataKey];
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
    properties_ = [[NSMutableDictionary alloc] init];
  }

  [properties_ setValue:obj forKey:key];
}

- (id)propertyForKey:(NSString *)key {
  return [properties_ objectForKey:key];
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

#pragma mark Cookies

// return a cookie from the array with the same name, domain, and path as the
// given cookie, or else return nil if none found
//
// Both the cookie being tested and all cookies in cookieStorageArray should
// be valid (non-nil name, domains, paths)
- (NSHTTPCookie *)cookieMatchingCookie:(NSHTTPCookie *)cookie
                               inArray:(NSArray *)cookieStorageArray {

  NSUInteger numberOfCookies = [cookieStorageArray count];
  NSString *name = [cookie name];
  NSString *domain = [cookie domain];
  NSString *path = [cookie path];

  NSAssert3(name && domain && path, @"Invalid cookie (name:%@ domain:%@ path:%@)",
                   name, domain, path);

  for (NSUInteger idx = 0; idx < numberOfCookies; idx++) {

    NSHTTPCookie *storedCookie = [cookieStorageArray objectAtIndex:idx];

    if ([[storedCookie name] isEqual:name]
        && [[storedCookie domain] isEqual:domain]
        && [[storedCookie path] isEqual:path]) {

      return storedCookie;
    }
  }
  return nil;
}

// remove any expired cookies from the array, excluding cookies with nil
// expirations
- (void)removeExpiredCookiesInArray:(NSMutableArray *)cookieStorageArray {

  // count backwards since we're deleting items from the array
  for (NSInteger idx = [cookieStorageArray count] - 1; idx >= 0; idx--) {

    NSHTTPCookie *storedCookie = [cookieStorageArray objectAtIndex:idx];

    NSDate *expiresDate = [storedCookie expiresDate];
    if (expiresDate && [expiresDate timeIntervalSinceNow] < 0) {
      [cookieStorageArray removeObjectAtIndex:idx];
    }
  }
}


// retrieve all cookies appropriate for the given URL, considering
// domain, path, cookie name, expiration, security setting.
// Side effect: removed expired cookies from the storage array
- (NSArray *)cookiesForURL:(NSURL *)theURL inArray:(NSMutableArray *)cookieStorageArray {

  [self removeExpiredCookiesInArray:cookieStorageArray];

  NSMutableArray *foundCookies = [NSMutableArray array];

  // we'll prepend "." to the desired domain, since we want the
  // actual domain "nytimes.com" to still match the cookie domain ".nytimes.com"
  // when we check it below with hasSuffix
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

  NSUInteger numberOfCookies = [cookieStorageArray count];
  for (NSUInteger idx = 0; idx < numberOfCookies; idx++) {

    NSHTTPCookie *storedCookie = [cookieStorageArray objectAtIndex:idx];

    NSString *cookieDomain = [[storedCookie domain] lowercaseString];
    NSString *cookiePath = [storedCookie path];
    BOOL cookieIsSecure = [storedCookie isSecure];

    BOOL domainIsOK;

    if (isLocalhostRetrieval) {
      // prior to 10.5.6, the domain stored into NSHTTPCookies for localhost
      // is "localhost.local"
      domainIsOK = [cookieDomain isEqual:@"localhost"]
        || [cookieDomain isEqual:@"localhost.local"];
    } else {
      domainIsOK = [domain hasSuffix:cookieDomain];
    }

    BOOL pathIsOK = [cookiePath isEqual:@"/"] || [path hasPrefix:cookiePath];
    BOOL secureIsOK = (!cookieIsSecure) || [scheme isEqual:@"https"];

    if (domainIsOK && pathIsOK && secureIsOK) {
      [foundCookies addObject:storedCookie];
    }
  }
  return foundCookies;
}

// return cookies for the given URL using the current cookie storage method
- (NSArray *)cookiesForURL:(NSURL *)theURL {

  NSArray *cookies = nil;
  NSMutableArray *cookieStorageArray = nil;

  if (cookieStorageMethod_ == kGDataHTTPFetcherCookieStorageMethodStatic) {
    cookieStorageArray = gGDataFetcherStaticCookies;
  } else if (cookieStorageMethod_ == kGDataHTTPFetcherCookieStorageMethodFetchHistory) {
    cookieStorageArray = [fetchHistory_ objectForKey:kGDataHTTPFetcherHistoryCookiesKey];
  } else {
    // kGDataHTTPFetcherCookieStorageMethodSystemDefault
    cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:theURL];
  }

  if (cookieStorageArray) {

    @synchronized(cookieStorageArray) {

      // cookiesForURL returns a new array of immutable NSCookie objects
      // from cookieStorageArray
      cookies = [self cookiesForURL:theURL
                            inArray:cookieStorageArray];
    }
  }
  return cookies;
}


// add all cookies in the array |newCookies| to the storage array,
// replacing cookies in the storage array as appropriate
// Side effect: removes expired cookies from the storage array
- (void)setCookies:(NSArray *)newCookies
           inArray:(NSMutableArray *)cookieStorageArray {

  [self removeExpiredCookiesInArray:cookieStorageArray];

  NSEnumerator *newCookieEnum = [newCookies objectEnumerator];
  NSHTTPCookie *newCookie;

  while ((newCookie = [newCookieEnum nextObject]) != nil) {

    if ([[newCookie name] length] > 0
        && [[newCookie domain] length] > 0
        && [[newCookie path] length] > 0) {

      // remove the cookie if it's currently in the array
      NSHTTPCookie *oldCookie = [self cookieMatchingCookie:newCookie
                                                   inArray:cookieStorageArray];
      if (oldCookie) {
        [cookieStorageArray removeObject:oldCookie];
      }

      // make sure the cookie hasn't already expired
      NSDate *expiresDate = [newCookie expiresDate];
      if ((!expiresDate) || [expiresDate timeIntervalSinceNow] > 0) {
        [cookieStorageArray addObject:newCookie];
      }

    } else {
      NSAssert1(NO, @"Cookie incomplete: %@", newCookie);
    }
  }
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




