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
//  GDataServiceBase.m
//

#include <sys/utsname.h>

#define GDATASERVICEBASE_DEFINE_GLOBALS 1
#import "GDataServiceBase.h"
#import "GDataProgressMonitorInputStream.h"
#import "GDataFramework.h"

static NSString* const kCallbackDelegateKey = @"delegate";
static NSString* const kCallbackObjectClassKey = @"objectClass";
static NSString* const kCallbackFinishedSelectorKey = @"finishedSelector";
static NSString* const kCallbackFailedSelectorKey = @"failedSelector";
static NSString* const kCallbackTicketKey = @"ticket";
static NSString* const kCallbackStreamDataKey = @"streamData";

NSString* const kCallbackRetryInvocationKey = @"retryInvocation";

// XorPlainMutableData is a simple way to keep passwords held in heap objects
// from being visible as plain-text
static void XorPlainMutableData(NSMutableData *mutable) {
  
  // this helps avoid storing passwords on the heap in plaintext
  const UInt8 theXORValue = 0x95; // 0x95 = 0xb10010101
  
  UInt8 *dataPtr = [mutable mutableBytes];
  unsigned int length = [mutable length];
  
  for (unsigned int idx = 0; idx < length; idx++) {
    dataPtr[idx] ^= theXORValue;
  }
}


@interface GDataServiceBase (PrivateMethods)
- (NSMutableDictionary *)callbackDictionaryForObjectClass:(Class)objectClass
                                                 delegate:(id)delegate
                                         finishedSelector:(SEL)finishedSelector
                                           failedSelector:(SEL)failedSelector
                                          retryInvocation:(NSInvocation *)retryInvocation
                                                   ticket:(GDataServiceTicketBase *)ticket
                                               streamData:(NSData *)data;

- (BOOL)fetchNextFeedWithURL:(NSURL *)nextFeedURL
                    delegate:(id)delegate
         didFinishedSelector:(SEL)finishedSelector
             didFailSelector:(SEL)failedSelector
                      ticket:(GDataServiceTicketBase *)ticket;
@end

@implementation GDataServiceBase

- (id)init {
  self = [super init];
  if (self) {
    fetchHistory_ = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)dealloc {
  [userAgent_ release];
  [fetchHistory_ release];
  [runLoopModes_ release];
  
  [username_ release];
  [password_ release];
  
  [serviceUserData_ release];
  [serviceProperties_ release];
  [serviceSurrogates_ release];
  
  [super dealloc];
}

- (NSString *)systemVersionString {
  
  NSString *systemString = @"";
  
#ifndef GDATA_FOUNDATION_ONLY
  long systemMajor = 0, systemMinor = 0, systemRelease = 0;
  (void) Gestalt(gestaltSystemVersionMajor, &systemMajor);
  (void) Gestalt(gestaltSystemVersionMinor, &systemMinor);
  (void) Gestalt(gestaltSystemVersionBugFix, &systemRelease);
  
  systemString = [NSString stringWithFormat:@"MacOSX/%d.%d.%d",
    systemMajor, systemMinor, systemRelease];
#elif defined(_SYS_UTSNAME_H)
  struct utsname unameRecord;
  uname(&unameRecord);
  
#if GDATA_IPHONE
  systemString = [NSString stringWithFormat:@"iPhone %s/%s",
                  unameRecord.sysname, unameRecord.release]; // "iPhone Darwin/9.2.0"
#else
  systemString = [NSString stringWithFormat:@"%s/%s",
                  unameRecord.sysname, unameRecord.release]; // "Darwin/8.11.1"
#endif
#endif
      
  return systemString;
}

- (NSString *)requestUserAgent {
  
  NSString *userAgent = [self userAgent];
  if ([userAgent length] == 0) {
    userAgent = [self defaultApplicationIdentifier];
  }
  
  NSString *requestUserAgent = userAgent;

  // if the user agent already specifies the library version, we'll
  // use it verbatim in the request
  NSString *libraryString = @"GData-ObjectiveC";
  NSRange libRange = [userAgent rangeOfString:libraryString
                                      options:NSCaseInsensitiveSearch];
  if (libRange.location == NSNotFound) {
    // the user agent doesn't specify the client library, so append that
    // information, and the system version
    long major, minor, release;
    NSString *libVersionString;
    GDataFrameworkVersion(&major, &minor, &release);
    
    // most library releases will have a release value of zero
    if (release != 0) {
      libVersionString = [NSString stringWithFormat:@"%d.%d.%d", 
        major, minor, release];
    } else {
      libVersionString = [NSString stringWithFormat:@"%d.%d", major, minor];
    }
    
    NSString *systemString = [self systemVersionString];
        
    // Google servers look for gzip in the user agent before sending gzip-
    // encoded responses.  See Service.java
    requestUserAgent = [NSString stringWithFormat:@"%@ %@/%@ %@ (gzip)", 
      userAgent, libraryString, libVersionString, systemString];
  }
  return requestUserAgent;
}

- (NSMutableURLRequest *)requestForURL:(NSURL *)url httpMethod:(NSString *)httpMethod {
  
  // subclasses may add headers to this
  NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url
                                                               cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                           timeoutInterval:60] autorelease];
  
  NSString *requestUserAgent = [self requestUserAgent];
  [request setValue:requestUserAgent forHTTPHeaderField:@"User-Agent"];
  if ([httpMethod length] > 0) {
    [request setHTTPMethod:httpMethod];
  }
  
  return request;
}


// objectRequestForURL returns an NSMutableURLRequest for a GData object as XML
//
// the object is the object being sent to the server, or nil;
// the http method may be nil for get, or POST, PUT, DELETE

- (NSMutableURLRequest *)objectRequestForURL:(NSURL *)url 
                                      object:(GDataObject *)object
                                  httpMethod:(NSString *)httpMethod {
  
  NSMutableURLRequest *request = [self requestForURL:url
                                          httpMethod:httpMethod];
  
  [request setValue:@"application/atom+xml, text/xml" forHTTPHeaderField:@"Accept"];
  
  [request setValue:@"application/atom+xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"]; // header is authoritative for character set issues.
  
  [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
  
  return request;
}

#pragma mark -

- (GDataServiceTicketBase *)fetchObjectWithURL:(NSURL *)feedURL
                                   objectClass:(Class)objectClass
                                  objectToPost:(GDataObject *)objectToPost
                                    httpMethod:(NSString *)httpMethod
                                      delegate:(id)delegate
                             didFinishSelector:(SEL)finishedSelector
                               didFailSelector:(SEL)failedSelector
                          retryInvocationValue:(NSValue *)retryInvocationValue
                                        ticket:(GDataServiceTicketBase *)ticket {
  
  AssertSelectorNilOrImplementedWithArguments(delegate, finishedSelector, @encode(GDataServiceTicketBase *), @encode(GDataObject *), 0);
  AssertSelectorNilOrImplementedWithArguments(delegate, failedSelector, @encode(GDataServiceTicketBase *), @encode(NSError *), 0);

  NSMutableURLRequest *request = [self objectRequestForURL:feedURL
                                                    object:objectToPost
                                                httpMethod:httpMethod];
  
  // we need to create a ticket unless one was created earlier (like during
  // authentication)
  if (!ticket) {
    ticket = [GDataServiceTicketBase ticketForService:self];
  }
  
  AssertSelectorNilOrImplementedWithArguments(delegate, [ticket uploadProgressSelector],
      @encode(GDataProgressMonitorInputStream *), @encode(unsigned long long), 
      @encode(unsigned long long), 0);
  AssertSelectorNilOrImplementedWithArguments(delegate, [ticket retrySelector],
      @encode(GDataServiceTicketBase *),@encode(BOOL), @encode(NSError *), 0);
  
  NSInputStream *uploadStream = nil;
  NSData *uploadData = nil;
  NSData *dataToRetain = nil;
  
  if (objectToPost) {

    [ticket setPostedObject:objectToPost];

    // An upload object may provide a custom input stream, such as for 
    // multi-part MIME or media uploads.  If it lacks a custom stream, 
    // we'll make a stream from the XML data of the object.

    NSInputStream *contentInputStream = nil;
    unsigned long long contentLength = 0;
    NSDictionary *contentHeaders = nil;
    
    SEL progressSelector = [ticket uploadProgressSelector];

    if ([objectToPost generateContentInputStream:&contentInputStream
                                          length:&contentLength
                                         headers:&contentHeaders]) {
      // there is a stream
      
      // add the content-specific headers, if any
      NSEnumerator *keyEnum = [contentHeaders keyEnumerator];
      NSString *key;
      while ((key = [keyEnum nextObject]) != nil) {
        NSString *value = [contentHeaders objectForKey:key];
        [request setValue:value forHTTPHeaderField:key];
      }
      
    } else {
      
      NSData* xmlData = [[objectToPost XMLDocument] XMLData];
      contentLength = [xmlData length];
      
      if (progressSelector == nil) {
        // there is no progress selector; we can post plain NSData, which
        // is simpler because it survives http redirects
        uploadData = xmlData;
        
      } else {
        // there is a progress selector, so we need to be posting a stream
        //
        // we'll make a default input stream from the XML data
        contentInputStream = [NSInputStream inputStreamWithData:xmlData];
        
        // NSInputStream fails to retain or copy its data in 10.4, so we will
        // retain it in the callback dictionary.  We won't use the data in the
        // callbacks at all, but retaining it will ensure it's still around until
        // the upload completes.
        //
        // If it weren't for this bug in NSInputStream, we could just have
        // GDataObject's -contentInputStream method create the input stream for
        // us, so this service class wouldn't ever need to call XMLElement.
        dataToRetain = xmlData; 
      }
    }

    uploadStream = contentInputStream;
    if (progressSelector != nil) {
      
      // the caller is monitoring the upload progress, so wrap the input stream
      // with an input stream that will call back to the delegate's progress
      // selector
      GDataProgressMonitorInputStream* monitoredInputStream;
      
      monitoredInputStream = [GDataProgressMonitorInputStream inputStreamWithStream:contentInputStream
                                                                             length:contentLength];
      [monitoredInputStream setDelegate:nil];
      [monitoredInputStream setMonitorDelegate:delegate];
      [monitoredInputStream setMonitorSelector:progressSelector];
      [monitoredInputStream setMonitorSource:ticket];
      
      uploadStream = monitoredInputStream;
    }
    
    NSNumber* num = [NSNumber numberWithUnsignedLongLong:contentLength];
    [request setValue:[num stringValue] forHTTPHeaderField:@"Content-Length"];
  }
  
  GDataHTTPFetcher* fetcher = [GDataHTTPFetcher httpFetcherWithRequest:request];

  [fetcher setRunLoopModes:[self runLoopModes]];
  
  if (uploadStream) {
    [fetcher setPostStream:uploadStream]; 
  } else if (uploadData) {
    [fetcher setPostData:uploadData]; 
  }
  
  // add cookie and last-modified-since history
  [fetcher setFetchHistory:fetchHistory_];
  
  // when the server gives us a "Not Modified" error, have the fetcher
  // just pass us the cached data from the previous call, if any
  [fetcher setShouldCacheDatedData:[self shouldCacheDatedData]];
  
  // copy the service's retry settings into the ticket
  [fetcher setIsRetryEnabled:[ticket isRetryEnabled]];
  [fetcher setMaxRetryInterval:[ticket maxRetryInterval]];
  
  if ([ticket retrySelector]) {
    [fetcher setRetrySelector:@selector(objectFetcher:willRetry:forError:)];
  }
  
  // remember the object fetcher in the ticket
  [ticket setObjectFetcher:fetcher];
  [ticket setCurrentFetcher:fetcher];
    
  // add parameters used by the callbacks
  //
  // we want to add the invocation itself, not the value wrapper of it,
  // to ensure the invocation is retained until the callback completes
  
  NSInvocation *retryInvocation = [retryInvocationValue nonretainedObjectValue];
  
  NSMutableDictionary *callbackDict = [self callbackDictionaryForObjectClass:objectClass
                                                                    delegate:delegate
                                                            finishedSelector:finishedSelector
                                                              failedSelector:failedSelector
                                                             retryInvocation:retryInvocation
                                                                      ticket:ticket
                                                                  streamData:dataToRetain];
  [fetcher setUserData:callbackDict];
  
  // add username/password
  [self addAuthenticationToFetcher:fetcher];
  
  // failed fetches call the failure selector, which will delete the ticket
  BOOL didFetch = [fetcher beginFetchWithDelegate:self
                                didFinishSelector:@selector(objectFetcher:finishedWithData:)
                        didFailWithStatusSelector:@selector(objectFetcher:failedWithStatus:data:)
                         didFailWithErrorSelector:@selector(objectFetcher:failedWithNetworkError:)];
  
  // If something weird happens and the networking callbacks have been called
  // already synchronously, we don't want to return the ticket since the caller 
  // will never know when to stop retaining it, so we'll make sure the
  // success/failure callbacks have not yet been called by checking the
  // ticket
  if (!didFetch || [ticket hasCalledCallback]) {
    return nil; 
  }
    
  return ticket;
}

- (void)objectFetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data {
  
  // we'll be nilling the userdata, so be sure to retain the callback dictionary
  NSDictionary *callbackDict = [[[fetcher userData] retain] autorelease];
  
  // unpack the callback parameters
  id delegate = [callbackDict objectForKey:kCallbackDelegateKey];
  Class objectClass = [callbackDict objectForKey:kCallbackObjectClassKey];
  SEL finishedSelector = NSSelectorFromString([callbackDict objectForKey:kCallbackFinishedSelectorKey]);
  SEL failedSelector = NSSelectorFromString([callbackDict objectForKey:kCallbackFailedSelectorKey]);
  
  GDataServiceTicketBase *ticket = [callbackDict objectForKey:kCallbackTicketKey];
  
  // hide our parameters from any future inspection of the fetcher's userdata
  [fetcher setUserData:nil];
  
  NSError *error = nil;
  
  GDataObject* object = nil;
  unsigned int dataLength = [data length];
  
  // create the object returned by the service, if any
  if (dataLength > 0) {
    NSXMLDocument *xmlDocument = [[[NSXMLDocument alloc] initWithData:data
                                                              options:0
                                                                error:&error] autorelease];
    if (xmlDocument) {
      
      NSXMLElement* root = [xmlDocument rootElement];
      
      if (!objectClass) {
        objectClass = [GDataObject objectClassForXMLElement:root]; 
      }
      
      // see if the top-level class for the XML is listed in the surrogates; 
      // if so, instantiate the surrogate class instead
      NSDictionary *surrogates = [ticket surrogates];
      Class baseSurrogate = [surrogates objectForKey:objectClass];
      if (baseSurrogate) {
        objectClass = baseSurrogate; 
      }

      object = [[[objectClass alloc] initWithXMLElement:root
                                                 parent:nil
                                             surrogates:surrogates] autorelease];
#if GDATA_USES_LIBXML
      // retain the document so that pointers to internal nodes remain valid
      [object setProperty:xmlDocument forKey:kGDataXMLDocumentPropertyKey];
#endif
       
    } else {
#if DEBUG
      NSString *invalidXML = [[[NSString alloc] initWithData:data
                                                    encoding:NSUTF8StringEncoding] autorelease];
      NSLog(@"GDataServiceBase fetching: %@\n invalidXML received: %@",[fetcher request], invalidXML);
#endif
    }
  }
  
  // if we created the object (or we got empty data back, as from a GData
  // delete resource request) then we succeeded  
  if (object != nil || dataLength == 0) {
    
    // if the user is fetching a feed and the ticket specifies that "next" links
    // should be followed, then do that now
    if ([ticket shouldFollowNextLinks] 
        && [object isKindOfClass:[GDataFeedBase class]]) {
      
      GDataFeedBase *latestFeed = (GDataFeedBase *)object;
      
      // append the latest feed
      [ticket accumulateFeed:latestFeed];
      
      NSURL *nextURL = [[[latestFeed links] nextLink] URL];
      if (nextURL) {
        
        BOOL isFetchingNextFeed = [self fetchNextFeedWithURL:nextURL
                                                    delegate:delegate
                                         didFinishedSelector:finishedSelector 
                                             didFailSelector:failedSelector
                                                      ticket:ticket];
        
        // skip calling the callbacks since the ticket is still in progress
        if (isFetchingNextFeed) {
          
          return;
          
        } else {
          // the fetch didn't start; fall through to the callback for the
          // feed accumulated so far
        }
      } 
      
      // no more "next" links are present, so we don't need to accumulate more
      // entries
      GDataFeedBase *accumulatedFeed = [ticket accumulatedFeed];
      if (accumulatedFeed) {
        
        // remove the misleading "next" link from the accumulated feed
        GDataLink *accumulatedFeedNextLink = [[accumulatedFeed links] nextLink];
        if (accumulatedFeedNextLink) {
          [accumulatedFeed removeLink:accumulatedFeedNextLink];
        }
        
        // return the completed feed as the object that was fetched
        object = accumulatedFeed;
      }
    }
    
    if (finishedSelector) {
      [delegate performSelector:finishedSelector
                     withObject:ticket
                     withObject:object];
    }
    [ticket setFetchedObject:object];
    
  } else {
    if (error == nil) {
      error = [NSError errorWithDomain:kGDataServiceErrorDomain
                                  code:kGDataCouldNotConstructObjectError
                              userInfo:nil]; 
    }
    if (failedSelector) {
      [delegate performSelector:failedSelector
                     withObject:ticket
                     withObject:error];
    }
    [ticket setFetchError:error];
  }  
  
  [ticket setHasCalledCallback:YES];
  [ticket setCurrentFetcher:nil];
}

- (void)objectFetcher:(GDataHTTPFetcher *)fetcher failedWithStatus:(int)status data:(NSData *)data {

#ifdef DEBUG
  NSString *dataString = [[[NSString alloc] initWithData:data
                                            encoding:NSUTF8StringEncoding] autorelease];
  if (dataString) {
   NSLog(@"serviceBase:%@ objectFetcher:%@ failedWithStatus:%d data:%@",
         self, fetcher, status, dataString);
  }
#endif

  NSDictionary *callbackDict = [[[fetcher userData] retain] autorelease];
  
  // hide our parameters from any future inspection of the fetcher's userdata
  [fetcher setUserData:nil];

  id delegate = [callbackDict objectForKey:kCallbackDelegateKey];
  
  GDataServiceTicketBase *ticket = [callbackDict objectForKey:kCallbackTicketKey];

  NSString *failedSelectorStr = [callbackDict objectForKey:kCallbackFailedSelectorKey];
  SEL failedSelector = failedSelectorStr ? NSSelectorFromString(failedSelectorStr) : nil;
  
  NSDictionary *userInfo = nil;
  
  if ([data length]) {
    // typically, along with a failure status code is a string describing the 
    // problem
    NSString *failureStr = [[[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding] autorelease];
    if (failureStr) {
      userInfo = [NSDictionary dictionaryWithObject:failureStr
                                             forKey:@"error"];
    }
  }
    
  NSError *error = [NSError errorWithDomain:kGDataServiceErrorDomain 
                                       code:status
                                   userInfo:userInfo];
  if (failedSelector) {
    [delegate performSelector:failedSelector
                   withObject:ticket
                   withObject:error];
  }
  
  [ticket setFetchError:error];
  [ticket setHasCalledCallback:YES];
  [ticket setCurrentFetcher:nil];
}

- (void)objectFetcher:(GDataHTTPFetcher *)fetcher failedWithNetworkError:(NSError *)error {
  
  NSDictionary *callbackDict = [[[fetcher userData] retain] autorelease];
  [fetcher setUserData:nil];
  
  id delegate = [callbackDict objectForKey:kCallbackDelegateKey];

  GDataServiceTicketBase *ticket = [callbackDict objectForKey:kCallbackTicketKey];

  NSString *failedSelectorStr = [callbackDict objectForKey:kCallbackFailedSelectorKey];
  SEL failedSelector = failedSelectorStr ? NSSelectorFromString(failedSelectorStr) : nil;

  if (failedSelector) {
      
    [delegate performSelector:failedSelector
                   withObject:ticket
                   withObject:error]; 
  }  
  [ticket setFetchError:error];
  [ticket setHasCalledCallback:YES];
  [ticket setCurrentFetcher:nil];
}

// The object fetcher may call into this retry method; this one invokes the
// selector provided by the user.
- (BOOL)objectFetcher:(GDataHTTPFetcher *)fetcher willRetry:(BOOL)willRetry forError:(NSError *)error {
  
  NSDictionary *callbackDict = [fetcher userData];
  
  id delegate = [callbackDict objectForKey:kCallbackDelegateKey];
  GDataServiceTicketBase *ticket = [callbackDict objectForKey:kCallbackTicketKey];
  
  SEL retrySelector = [ticket retrySelector];
  if (retrySelector) {
    
    willRetry = [self invokeRetrySelector:retrySelector
                                 delegate:delegate
                                   ticket:ticket
                                willRetry:willRetry
                                    error:error];
  }  
  return willRetry;
}

- (BOOL)invokeRetrySelector:(SEL)retrySelector
                   delegate:(id)delegate
                     ticket:(GDataServiceTicketBase *)ticket
                  willRetry:(BOOL)willRetry
                      error:(NSError *)error {
  
  if ([delegate respondsToSelector:retrySelector]) {
  
    // Unlike the retry selector invocation in GDataHTTPFetcher, this invocation
    // passes the ticket rather than the fetcher as argument 2
    NSMethodSignature *signature = [delegate methodSignatureForSelector:retrySelector];
    NSInvocation *retryInvocation = [NSInvocation invocationWithMethodSignature:signature];
    [retryInvocation setSelector:retrySelector];
    [retryInvocation setTarget:delegate];
    [retryInvocation setArgument:&ticket atIndex:2]; // ticket passed
    [retryInvocation setArgument:&willRetry atIndex:3];
    [retryInvocation setArgument:&error atIndex:4];
    [retryInvocation invoke];
    
    [retryInvocation getReturnValue:&willRetry];
  }
  return willRetry;  
}

- (NSMutableDictionary *)callbackDictionaryForObjectClass:(Class)objectClass
                                                 delegate:(id)delegate
                                         finishedSelector:(SEL)finishedSelector
                                           failedSelector:(SEL)failedSelector
                                          retryInvocation:(NSInvocation *)retryInvocation
                                                   ticket:(GDataServiceTicketBase *)ticket
                                               streamData:(NSData *)data {
  
  NSMutableDictionary *callbackDict = [NSMutableDictionary dictionary];
  
  if (objectClass) [callbackDict setValue:objectClass forKey:kCallbackObjectClassKey];
  
  if (delegate) [callbackDict setValue:delegate forKey:kCallbackDelegateKey];
  
  if (finishedSelector) [callbackDict setValue:NSStringFromSelector(finishedSelector)
                                        forKey:kCallbackFinishedSelectorKey];
  
  if (failedSelector) [callbackDict setValue:NSStringFromSelector(failedSelector)
                                      forKey:kCallbackFailedSelectorKey];
  
  if (retryInvocation) [callbackDict setValue:retryInvocation
                                       forKey:kCallbackRetryInvocationKey];
  
  if (ticket) [callbackDict setValue:ticket
                              forKey:kCallbackTicketKey];
  
  // the stream data is retained only because of an NSInputStream bug in 
  // 10.4, as described below
  if (data) [callbackDict setValue:data forKey:kCallbackStreamDataKey];
  
  return callbackDict;
}

- (void)addAuthenticationToFetcher:(GDataHTTPFetcher *)fetcher {
  NSString *username = [self username];
  NSString *password = [self password];
  
  if ([username length] && [password length]) {
    // We're avoiding +[NSURCredential credentialWithUser:password:persistence:]
    // because it fails to autorelease itself on OS X 10.4 .. 10.5.x
    // rdar://5596278 
    
    NSURLCredential *cred;
    cred = [[[NSURLCredential alloc] initWithUser:username
                                         password:password
                                      persistence:NSURLCredentialPersistenceForSession] autorelease];
    [fetcher setCredential:cred];
  }
}

// when a ticket is set to follow "next" links for feeds, this routine
// initiates the fetch for each additional feed
- (BOOL)fetchNextFeedWithURL:(NSURL *)nextFeedURL 
                    delegate:(id)delegate
         didFinishedSelector:(SEL)finishedSelector
             didFailSelector:(SEL)failedSelector
                      ticket:(GDataServiceTicketBase *)ticket {
  
  // by definition, feed requests are GETs, so objectToPost: and httpMethod:
  // should be nil
  GDataServiceTicketBase *startedTicket;
  startedTicket = [self fetchObjectWithURL:nextFeedURL
                               objectClass:[[ticket accumulatedFeed] class]
                              objectToPost:nil
                                httpMethod:nil
                                  delegate:delegate
                         didFinishSelector:finishedSelector
                           didFailSelector:failedSelector
                      retryInvocationValue:nil
                                    ticket:ticket];
  
  // in the bizarre case that the fetch didn't begin, startedTicket will be
  // nil.  So long as the started ticket is the same as the ticket we're
  // continuing, then we're happy.
  return (ticket == startedTicket);
}
  

- (BOOL)waitForTicket:(GDataServiceTicketBase *)ticket
              timeout:(NSTimeInterval)timeoutInSeconds
        fetchedObject:(GDataObject **)outObjectOrNil 
                error:(NSError **)outErrorOrNil {
  
  NSDate* giveUpDate = [NSDate dateWithTimeIntervalSinceNow:timeoutInSeconds];
  
  // loop until the fetch completes with an object or an error,
  // or until the timeout has expired
  while (![ticket hasCalledCallback]
         && [giveUpDate timeIntervalSinceNow] > 0) {
    
    // run the current run loop 1/1000 of a second to give the networking
    // code a chance to work
    NSDate *stopDate = [NSDate dateWithTimeIntervalSinceNow:0.001];
    [[NSRunLoop currentRunLoop] runUntilDate:stopDate]; 
  }
  
  GDataObject *fetchedObject = [ticket fetchedObject];
  
  if (outObjectOrNil) *outObjectOrNil = fetchedObject;
  if (outErrorOrNil)  *outErrorOrNil = [ticket fetchError];
  
  return (fetchedObject != nil);
}

#pragma mark -

// These external entry points all call into fetchObjectWithURL: defined above 

- (GDataServiceTicketBase *)fetchFeedWithURL:(NSURL *)feedURL
                                   feedClass:(Class)feedClass
                                    delegate:(id)delegate
                           didFinishSelector:(SEL)finishedSelector
                             didFailSelector:(SEL)failedSelector {
  
  return [self fetchObjectWithURL:feedURL
                      objectClass:feedClass
                     objectToPost:nil
                       httpMethod:nil
                         delegate:delegate
                didFinishSelector:finishedSelector
                  didFailSelector:failedSelector
             retryInvocationValue:nil
                           ticket:nil];
}  

- (GDataServiceTicketBase *)fetchEntryWithURL:(NSURL *)entryURL
                                   entryClass:(Class)entryClass
                                     delegate:(id)delegate
                            didFinishSelector:(SEL)finishedSelector
                              didFailSelector:(SEL)failedSelector {
  
  return [self fetchObjectWithURL:entryURL
                      objectClass:entryClass
                     objectToPost:nil
                       httpMethod:nil
                         delegate:delegate
                didFinishSelector:finishedSelector
                  didFailSelector:failedSelector
             retryInvocationValue:nil
                           ticket:nil];
}  

- (GDataServiceTicketBase *)fetchEntryByInsertingEntry:(GDataEntryBase *)entryToInsert
                                            forFeedURL:(NSURL *)feedURL
                                              delegate:(id)delegate
                                     didFinishSelector:(SEL)finishedSelector
                                       didFailSelector:(SEL)failedSelector {
  
  return [self fetchObjectWithURL:feedURL
                      objectClass:[entryToInsert class]
                     objectToPost:entryToInsert
                       httpMethod:nil
                         delegate:delegate
                didFinishSelector:finishedSelector
                  didFailSelector:failedSelector
             retryInvocationValue:nil
                           ticket:nil];
}


- (GDataServiceTicketBase *)fetchEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                          forEntryURL:(NSURL *)entryURL
                                             delegate:(id)delegate
                                    didFinishSelector:(SEL)finishedSelector
                                      didFailSelector:(SEL)failedSelector {
  
  return [self fetchObjectWithURL:entryURL
                      objectClass:[entryToUpdate class]
                     objectToPost:entryToUpdate
                       httpMethod:@"PUT"
                         delegate:delegate
                didFinishSelector:finishedSelector
                  didFailSelector:failedSelector
             retryInvocationValue:nil
                           ticket:nil];
}


- (GDataServiceTicketBase *)deleteResourceURL:(NSURL *)resourceEditURL
                                     delegate:(id)delegate
                            didFinishSelector:(SEL)finishedSelector
                              didFailSelector:(SEL)failedSelector {
  
  return [self fetchObjectWithURL:resourceEditURL
                      objectClass:nil
                     objectToPost:nil
                       httpMethod:@"DELETE"
                         delegate:delegate
                didFinishSelector:finishedSelector
                  didFailSelector:failedSelector
             retryInvocationValue:nil
                           ticket:nil];
}

- (GDataServiceTicketBase *)fetchQuery:(GDataQuery *)query
                             feedClass:(Class)feedClass
                              delegate:(id)delegate
                     didFinishSelector:(SEL)finishedSelector
                       didFailSelector:(SEL)failedSelector {
  
  return [self fetchFeedWithURL:[query URL]
                      feedClass:feedClass
                       delegate:delegate
              didFinishSelector:finishedSelector
                didFailSelector:failedSelector];
}

- (GDataServiceTicketBase *)fetchFeedWithBatchFeed:(GDataFeedBase *)batchFeed
                                        forFeedURL:(NSURL *)feedURL
                                          delegate:(id)delegate
                                 didFinishSelector:(SEL)finishedSelector
                                   didFailSelector:(SEL)failedSelector {
  
  return [self fetchObjectWithURL:feedURL
                      objectClass:[batchFeed class]
                     objectToPost:batchFeed
                       httpMethod:nil
                         delegate:delegate
                didFinishSelector:finishedSelector
                  didFailSelector:failedSelector
             retryInvocationValue:nil
                           ticket:nil];
}

#pragma mark -

- (NSString *)userAgent {
  return userAgent_; 
}

- (void)setUserAgent:(NSString *)userAgent {
  [userAgent_ release];
  userAgent_ = [userAgent copy];
}

- (NSArray *)runLoopModes {
  return runLoopModes_;
}

- (void)setRunLoopModes:(NSArray *)modes {
  [runLoopModes_ autorelease]; 
  runLoopModes_ = [modes retain];
}

// save the username and password, converting the password to non-plaintext
- (void)setUserCredentialsWithUsername:(NSString *)username
                              password:(NSString *)password {
  if (username && ![username_ isEqual:username]) {
    
    // username changed; discard history so we're not caching for the wrong
    // user
    [fetchHistory_ removeAllObjects];
  }
  
  [username_ release];
  username_ = [username copy];
  
  [password_ release];
  
  if (password) {
    password_ = [[NSMutableData alloc] initWithBytes:[password UTF8String]
                                              length:strlen([password UTF8String])];
    XorPlainMutableData(password_);
  } else {
    password_ = nil;
  }
}

- (NSString *)username {
  return username_; 
}

// return the password as plaintext
- (NSString *)password {
  if (password_) {
    XorPlainMutableData(password_);
    NSString *result = [[[NSString alloc] initWithData:password_
                                              encoding:NSUTF8StringEncoding] autorelease];
    XorPlainMutableData(password_);
    return result;
  }
  return nil;
}

// Turn on data caching to receive a copy of previously-retrieved objects.
// Otherwise, fetches may return status 304 (No Change) rather than actual data
- (void)setShouldCacheDatedData:(BOOL)flag {
  shouldCacheDatedData_ = flag;
  
  if (!flag) {
    [fetchHistory_ removeObjectForKey:kGDataHTTPFetcherHistoryDatedDataKey]; 
  }
}

- (BOOL)shouldCacheDatedData {
  return shouldCacheDatedData_; 
}

// reset the last modified dates to avoid getting a Not Modified status
// based on prior queries
- (void)clearLastModifiedDates {
  [fetchHistory_ removeObjectForKey:kGDataHTTPFetcherHistoryLastModifiedKey];
  [fetchHistory_ removeObjectForKey:kGDataHTTPFetcherHistoryDatedDataKey]; 
}

- (BOOL)serviceShouldFollowNextLinks {
  return serviceShouldFollowNextLinks_;
}

- (void)setServiceShouldFollowNextLinks:(BOOL)flag {
  serviceShouldFollowNextLinks_ = flag; 
}


// The service userData becomes the initial value for each future ticket's
// userData.
//
// Since the network transactions may begin before the client has been 
// returned the ticket by the fetch call, it's preferable to call 
// setServiceUserData before the ticket is created rather than call the
// ticket's setUserData:.  Either way, the ticket's userData:
// method will return the value.
- (void)setServiceUserData:(id)userData {
  [serviceUserData_ autorelease];
  serviceUserData_ = [userData retain];
}

- (id)serviceUserData {
  return serviceUserData_;
}

// The service properties dictionary becomes the dictionary for each future
// ticket.

- (void)setServiceProperties:(NSDictionary *)dict {
  [serviceProperties_ autorelease];
  serviceProperties_ = [dict mutableCopy];
}

- (NSDictionary *)serviceProperties {
  // be sure the returned pointer has the life of the autorelease pool,
  // in case self is released immediately
  return [[serviceProperties_ retain] autorelease];
}

- (void)setServiceProperty:(id)obj forKey:(NSString *)key {
  
  if (obj == nil) {
    // user passed in nil, so delete the property
    [serviceProperties_ removeObjectForKey:key];
  } else {
    // be sure the property dictionary exists
    if (serviceProperties_ == nil) {
      serviceProperties_ = [[NSMutableDictionary alloc] init];
    }
    [serviceProperties_ setObject:obj forKey:key];
  }
}

- (id)servicePropertyForKey:(NSString *)key {
  id obj = [serviceProperties_ objectForKey:key];
  
  // be sure the returned pointer has the life of the autorelease pool,
  // in case self is released immediately
  return [[obj retain] autorelease];
}

- (NSDictionary *)serviceSurrogates {
  return serviceSurrogates_;
}

- (void)setServiceSurrogates:(NSDictionary *)dict {
  [serviceSurrogates_ autorelease]; 
  serviceSurrogates_ = [dict retain];
}

- (void)setServiceUploadProgressSelector:(SEL)progressSelector {
  serviceUploadProgressSelector_ = progressSelector; 
}

- (SEL)serviceUploadProgressSelector {
  return serviceUploadProgressSelector_;
}


// retrying; see comments on retry support at the top of GDataHTTPFetcher
- (BOOL)isServiceRetryEnabled {
  return isServiceRetryEnabled_;
}

- (void)setIsServiceRetryEnabled:(BOOL)flag {
  isServiceRetryEnabled_ = flag; 
}

- (SEL)serviceRetrySelector {
  return serviceRetrySEL_; 
}

- (void)setServiceRetrySelector:(SEL)theSel {
  serviceRetrySEL_ = theSel;
}

- (NSTimeInterval)serviceMaxRetryInterval {
  return serviceMaxRetryInterval_;  
}

- (void)setServiceMaxRetryInterval:(NSTimeInterval)secs {
  serviceMaxRetryInterval_ = secs; 
}

#pragma mark -

// we want to percent-escape some of the characters that are otherwise
// considered legal in URLs when we pass them as parameters
//
// Unlike [GDataQuery stringByURLEncodingStringParameter] this does not
// replace spaces with + characters
//
// Reference: http://www.ietf.org/rfc/rfc3986.txt

- (NSString *)stringByURLEncoding:(NSString *)param {
  
  NSString *resultStr = param;
  
  CFStringRef originalString = (CFStringRef) param;
  CFStringRef leaveUnescaped = NULL;
  CFStringRef forceEscaped = CFSTR("!*'();:@&=+$,/?%#[]");
  
  CFStringRef escapedStr;
  escapedStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                       originalString,
                                                       leaveUnescaped, 
                                                       forceEscaped,
                                                       kCFStringEncodingUTF8);
  
  if (escapedStr) {
    resultStr = [NSString stringWithString:(NSString *)escapedStr];
    CFRelease(escapedStr);
  }
  return resultStr;
}

// return a default process name suitable for GData and http 
- (NSString *)cleanProcessName {
  
  NSMutableString *procName = [NSMutableString stringWithString:
    [[NSProcessInfo processInfo] processName]];
  
  // make a proper token from the process name 
  // per http://www.w3.org/Protocols/rfc2616/rfc2616-sec2.html
  // and http://www.mozilla.org/build/user-agent-strings.html
  
  // replace spaces with underscores
  [procName replaceOccurrencesOfString:@" "
                            withString:@"_"
                               options:0
                                 range:NSMakeRange(0, [procName length])];

  // delete http token separators and remaining whitespace
  NSString *const kSeparators = @"()<>@,;:\\\"/[]?={}";
  
  NSMutableCharacterSet *charsToDelete;
  charsToDelete = [[[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy] autorelease];
  [charsToDelete addCharactersInString:kSeparators];
  
  while (true) {
    NSRange separatorRange = [procName rangeOfCharacterFromSet:charsToDelete];
    if (separatorRange.location == NSNotFound) break;
  
    [procName deleteCharactersInRange:separatorRange];
  }; 
  
  return procName;
}

// return a generic name and version for the current application; this avoids
// anonymous server transactions.  Applications should call setUserAgent
// to avoid the need for this method to be used.
- (NSString *)defaultApplicationIdentifier {
  NSString *procName = [self cleanProcessName];
  
  NSString *version = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
  if (!version || [version isEqual:@"CFBundleShortVersionString"]) {
    version = @"version_unknown";    
  }
  NSString *result = [NSString stringWithFormat:@"%@-%@", procName, version];
  return result;
}
@end

@implementation GDataServiceTicketBase

+ (id)ticketForService:(GDataServiceBase *)service {
  return [[[self alloc] initWithService:service] autorelease];  
}

- (id)initWithService:(GDataServiceBase *)service {
  self = [super init];
  if (self) {
    service_ = [service retain];
    
    [self setUserData:[service serviceUserData]];
    [self setProperties:[service serviceProperties]];
    [self setSurrogates:[service serviceSurrogates]];
    [self setUploadProgressSelector:[service serviceUploadProgressSelector]];  
    [self setIsRetryEnabled:[service isServiceRetryEnabled]];
    [self setRetrySelector:[service serviceRetrySelector]];
    [self setMaxRetryInterval:[service serviceMaxRetryInterval]];   
    [self setShouldFollowNextLinks:[service serviceShouldFollowNextLinks]];
  }
  return self;
}

- (void)dealloc {
  [service_ release];
  
  [userData_ release];
  [ticketProperties_ release];
  [surrogates_ release];
  
  [currentFetcher_ release];
  [objectFetcher_ release];
  
  [postedObject_ release];
  [fetchedObject_ release];
  [accumulatedFeed_ release];
  [fetchError_ release];  
  
  [super dealloc];
}

- (NSString *)description {
  NSString *template = @"%@ 0x%lX: {service:%@ currentFetcher:%@ userData:%@}";
  return [NSString stringWithFormat:template,
    [self class], self, service_, currentFetcher_, userData_];
}

- (void)cancelTicket {
  [objectFetcher_ stopFetching];
  
  [self setObjectFetcher:nil];
  [self setCurrentFetcher:nil];
  [self setUserData:nil];
  [self setProperties:nil];
  
  [service_ autorelease];
  service_ = nil;
}

- (GDataServiceBase *)service {
  return service_; 
}

- (id)userData {
  return [[userData_ retain] autorelease]; 
}

- (void)setUserData:(id)obj {
  [userData_ autorelease];
  userData_ = [obj retain];
}

- (void)setProperties:(NSDictionary *)dict {
  [ticketProperties_ autorelease];
  ticketProperties_ = [dict mutableCopy];
}

- (NSDictionary *)properties {
  // be sure the returned pointer has the life of the autorelease pool,
  // in case self is released immediately
  return [[ticketProperties_ retain] autorelease];
}

- (void)setProperty:(id)obj forKey:(NSString *)key {
  
  if (obj == nil) {
    // user passed in nil, so delete the property
    [ticketProperties_ removeObjectForKey:key];
  } else {
    // be sure the property dictionary exists
    if (ticketProperties_ == nil) {
      ticketProperties_ = [[NSMutableDictionary alloc] init];
    }
    [ticketProperties_ setObject:obj forKey:key];
  }
}

- (id)propertyForKey:(NSString *)key {
  id obj = [ticketProperties_ objectForKey:key];
  
  // be sure the returned pointer has the life of the autorelease pool,
  // in case self is released immediately
  return [[obj retain] autorelease];
}

- (NSDictionary *)surrogates {
  return surrogates_;
}

- (void)setSurrogates:(NSDictionary *)dict {
  [surrogates_ autorelease]; 
  surrogates_ = [dict retain];
}

- (SEL)uploadProgressSelector {
  return uploadProgressSelector_;
}

- (void)setUploadProgressSelector:(SEL)progressSelector {
  uploadProgressSelector_ = progressSelector; 
}

- (BOOL)shouldFollowNextLinks {
  return shouldFollowNextLinks_;  
}

- (void)setShouldFollowNextLinks:(BOOL)flag {
  shouldFollowNextLinks_ = flag;
}

- (BOOL)isRetryEnabled {
  return isRetryEnabled_;  
}

- (void)setIsRetryEnabled:(BOOL)flag {
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
  maxRetryInterval_ = secs; 
}

- (GDataHTTPFetcher *)currentFetcher {
  return [[currentFetcher_ retain] autorelease]; 
}

- (void)setCurrentFetcher:(GDataHTTPFetcher *)fetcher {
  [currentFetcher_ autorelease];
  currentFetcher_ = [fetcher retain];
}

- (GDataHTTPFetcher *)objectFetcher {
  return [[objectFetcher_ retain] autorelease]; 
}

- (void)setObjectFetcher:(GDataHTTPFetcher *)fetcher {
  [objectFetcher_ autorelease];
  objectFetcher_ = [fetcher retain];
}

- (int)statusCode {
  return [objectFetcher_ statusCode];  
}

- (void)setHasCalledCallback:(BOOL)flag {
  hasCalledCallback_ = flag; 
}

- (BOOL)hasCalledCallback {
  return hasCalledCallback_;  
}

- (void)setPostedObject:(GDataObject *)obj {
  [postedObject_ autorelease];
  postedObject_ = [obj retain];
}

- (GDataObject *)postedObject {
  return postedObject_;
}

- (void)setFetchedObject:(GDataObject *)obj {
  [fetchedObject_ autorelease];
  fetchedObject_ = [obj retain];
}

- (GDataObject *)fetchedObject {
  return fetchedObject_;
}

- (void)setFetchError:(NSError *)error {
  [fetchError_ autorelease];
  fetchError_ = [error retain];
}

- (NSError *)fetchError {
  return fetchError_; 
}

- (void)setAccumulatedFeed:(GDataFeedBase *)feed {
  [accumulatedFeed_ autorelease];
  accumulatedFeed_ = [feed retain];
}

// accumulateFeed is used by the service to append an incomplete feed
// to the ticket when shouldFollowNextLinks is enabled
- (GDataFeedBase *)accumulatedFeed {
  return accumulatedFeed_;
}

- (void)accumulateFeed:(GDataFeedBase *)newFeed {
  
  GDataFeedBase *accumulatedFeed = [self accumulatedFeed];
  if (accumulatedFeed == nil) {
    
    // the new feed becomes the accumulated feed
    [self setAccumulatedFeed:newFeed];
    
  } else {
    
    // A feed's addEntry: routine requires that a new entry's parent
    // not be set to some other feed.  Calling addEntryWithEntry: would make
    // a new, parentless copy of the entry for us, but that would be a needless
    // copy. Instead, we'll explicitly clear the entry's parent and call
    // addEntry:.
    
    NSArray *newEntries = [newFeed entries];
    NSEnumerator *entryEnum = [newEntries objectEnumerator];
    GDataEntryBase *entry;
    
    while ((entry = [entryEnum nextObject]) != nil) {
      [entry setParent:nil];
      [accumulatedFeed addEntry:entry];
    }
  }
}
@end

