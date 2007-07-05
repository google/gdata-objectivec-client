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

#define GDATASERVICEBASE_DEFINE_GLOBALS 1
#import "GDataServiceBase.h"
#import "GDataFeedCalendar.h"
#import "GDataFeedCalendarEvent.h"
#import "GDataProgressMonitorInputStream.h"

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
- (NSString *)defaultApplicationIdentifier;

- (NSMutableDictionary *)callbackDictionaryForObjectClass:(Class)objectClass
                                                 delegate:(id)delegate
                                         finishedSelector:(SEL)finishedSelector
                                           failedSelector:(SEL)failedSelector
                                          retryInvocation:(NSInvocation *)retryInvocation
                                                   ticket:(GDataServiceTicketBase *)ticket
                                               streamData:(NSData *)data;

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
  
  [username_ release];
  [password_ release];
  
  [super dealloc];
}

- (NSMutableURLRequest *)requestForURL:(NSURL *)url httpMethod:(NSString *)httpMethod {
  
  // subclasses may add headers to this
  NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url
                                                               cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                           timeoutInterval:60] autorelease];
  NSString *userAgent = [self userAgent];
  if ([userAgent length] == 0) {
    userAgent = [self defaultApplicationIdentifier];
  }
  
  [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
  [request setValue:@"text/xml" forHTTPHeaderField:@"Accept"];
  [request setValue:@"application/atom+xml;charset=utf-8" forHTTPHeaderField:@"content-type"]; // header is authoritative for character set issues.
  [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
  
  if ([httpMethod length] > 0) {
    [request setHTTPMethod:httpMethod];
  }
  
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
                               retryInvocation:(NSInvocation *)retryInvocation
                                        ticket:(GDataServiceTicketBase *)ticket {
  
  AssertSelectorNilOrImplementedWithArguments(delegate, finishedSelector, @encode(GDataServiceTicketBase *), @encode(GDataObject *), 0);
  AssertSelectorNilOrImplementedWithArguments(delegate, failedSelector, @encode(GDataServiceTicketBase *), @encode(NSError *), 0);

  NSMutableURLRequest *request = [self requestForURL:feedURL httpMethod:httpMethod];
  
  // we need to create a ticket unless one was created earlier (like during
  // authentication)
  if (!ticket) {
    ticket = [GDataServiceTicketBase ticketForService:self];
    [ticket setUserData:serviceUserData_];
    [ticket setUploadProgressSelector:serviceUploadProgressSelector_];
  }
  
  AssertSelectorNilOrImplementedWithArguments(delegate, [ticket uploadProgressSelector],
                                              @encode(GDataProgressMonitorInputStream *), @encode(unsigned long long), 
                                              @encode(unsigned long long), 0);
    
  NSInputStream *uploadStream = nil;
  NSData *uploadData = nil;
  NSData *dataToRetain = nil;
  
  if (objectToPost) {
    
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
  
  if (uploadStream) {
    [fetcher setPostStream:uploadStream]; 
  } else if (uploadData) {
    [fetcher setPostData:uploadData]; 
  }
  
  // add cookie and last-modified-since history
  [fetcher setFetchHistory:fetchHistory_];
  
  // when the server gives us a "Not Modified" error, have the fetcher
  // just pass us the cached data from the previous call, if any
  [fetcher setShouldCacheDatedData:shouldCacheDatedData_];
  
  // remember the object fetcher in the ticket
  [ticket setObjectFetcher:fetcher];
    
  // add parameters used by the callbacks
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
  
  return didFetch ? ticket : nil;
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
      object = [[[objectClass alloc] initWithXMLElement:root
                                                 parent:nil] autorelease];
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
  if ([username_ length] && [[self password] length]) {
    [fetcher setCredential:[NSURLCredential credentialWithUser:username_
                                                      password:[self password]
                                                   persistence:NSURLCredentialPersistenceForSession]];
  }
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
                  retryInvocation:nil
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
                  retryInvocation:nil
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
                  retryInvocation:nil
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
                  retryInvocation:nil
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
                  retryInvocation:nil
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
                  retryInvocation:nil
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

- (void)setServiceUploadProgressSelector:(SEL)progressSelector {
  serviceUploadProgressSelector_ = progressSelector; 
}

- (SEL)serviceUploadProgressSelector {
  return serviceUploadProgressSelector_;
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

// return a generic name and version for the current application; this avoids
// anonymous server transactions.  Applications should call setUserAgent
// to avoid the need for this method to be used.
- (NSString *)defaultApplicationIdentifier {
  NSString *procName = [[NSProcessInfo processInfo] processName];
  NSString *version = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
  if (!version || [version isEqual:@"CFBundleShortVersionString"]) {
    version = @"version?";    
  }
  NSString *result = [NSString stringWithFormat:@"%@/%@", procName, version];
  return result;
}
@end

@implementation GDataServiceTicketBase

+ (GDataServiceTicketBase *)ticketForService:(GDataServiceBase *)service {
  return [[[self alloc] initWithService:service] autorelease];  
}

- (id)initWithService:(GDataServiceBase *)service {
  self = [super init];
  if (self) {
    service_ = [service retain];
  }
  return self;
}

- (void)dealloc {
  [service_ release];
  [userData_ release];
  [objectFetcher_ release];
  [fetchedObject_ release];
  [fetchError_ release];
  
  [super dealloc];
}

- (NSString *)description {
  NSString *template = @"%@ 0x%lX: {service:%@ objectFetcher:%@ userData:%@}";
  return [NSString stringWithFormat:template,
    [self class], self, service_, objectFetcher_, userData_];
}

- (void)cancelTicket {
  [objectFetcher_ stopFetching];
  
  [self setObjectFetcher:nil];
  [self setUserData:nil];
  
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

- (void)setUploadProgressSelector:(SEL)progressSelector {
  uploadProgressSelector_ = progressSelector; 
}

- (SEL)uploadProgressSelector {
  return uploadProgressSelector_;
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

- (BOOL)hasCalledCallback {
  return hasCalledCallback_;  
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

- (void)setHasCalledCallback:(BOOL)flag {
  hasCalledCallback_ = flag; 
}

@end

