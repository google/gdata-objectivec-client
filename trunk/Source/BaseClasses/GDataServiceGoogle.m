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
//  GDataServiceGoogle.m
//

#define GDATASERVICEGOOGLE_DEFINE_GLOBALS 1
#import "GDataServiceGoogle.h"

extern NSString* const kFetcherRetryInvocationKey;

static NSString* const kCaptchaFullURLKey = @"CaptchaFullUrl";

enum {
  // indices of parameters for the post-authentication invocation
  kInvocationObjectURLIndex = 2,
  kInvocationObjectClassIndex,
  kInvocationObjectToPostIndex,
  kInvocationObjectETagIndex,
  kInvocationHTTPMethodIndex,
  kInvocationDelegateIndex,
  kInvocationFinishedSelectorIndex,
  kInvocationFailedSelectorIndex,
  kInvocationRetryInvocationValueIndex,
  kInvocationTicketIndex
};


@interface GDataServiceGoogle (PrivateMethods)
- (void)authFetcher:(GDataHTTPFetcher *)fetcher failedWithStatus:(int)status data:(NSData *)data;
- (void)authFetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error;
@end

@implementation GDataServiceGoogle

- (id)init {
  self = [super init]; 
  if (self) {
  }
  return self;
}

- (void)dealloc {
  [captchaToken_ release];
  [captchaAnswer_ release];
  [authToken_ release];  
  [authSubToken_ release];  
  [accountType_ release];
  [signInDomain_ release];
  [serviceID_ release];
  [super dealloc]; 
}

#pragma mark -

- (NSMutableURLRequest *)authenticationRequestForURL:(NSURL *)url {
  
  // subclasses may add headers to this
  NSMutableURLRequest *request;
  request = [[[NSMutableURLRequest alloc] initWithURL:url
                                          cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                      timeoutInterval:60] autorelease];
  return request;
}

// This routine signs into the service defined by the subclass's serviceID
// method, and if successful calls the invocation's finishedSelector.

- (GDataServiceTicket *)authenticateThenInvoke:(NSInvocation *)invocation {
  
  GDataServiceTicket *ticket;
  [invocation getArgument:&ticket atIndex:kInvocationTicketIndex];

  if ([username_ length] > 0 && [[self password] length] > 0) {
    
    // do we care about http: protocol logins?
    NSString *domain = [self signInDomain];
    if ([domain length] == 0) {
      domain = @"www.google.com";
    }
    
    // unit tests will authenticate to a server running locally; 
    // see GDataServiceTest.m
    NSString *scheme = [domain hasPrefix:@"localhost:"] ? @"http" : @"https";
    
    NSString *urlTemplate = @"%@://%@/accounts/ClientLogin";
    NSString *authURLString = [NSString stringWithFormat:urlTemplate, 
                                                         scheme, domain];
    
    NSURL *authURL = [NSURL URLWithString:authURLString];
    NSMutableURLRequest *request = [self authenticationRequestForURL:authURL];
    
    NSString *password = [self password];

    NSString *userAgent = [self userAgent];
    if ([userAgent length] == 0) {
      userAgent = [self defaultApplicationIdentifier];
    }
    
    NSString *postTemplate = @"Email=%@&Passwd=%@&source=%@&service=%@&accountType=%@";
    NSString *postString = [NSString stringWithFormat:postTemplate, 
      [GDataUtilities stringByURLEncodingForURI:[self username]],
      [GDataUtilities stringByURLEncodingForURI:password],
      [GDataUtilities stringByURLEncodingForURI:userAgent],
      [self serviceID],
      [self accountType]];
    
    if ([captchaToken_ length] > 0 && [captchaAnswer_ length] > 0) {
      NSString *captchaTemplate = @"&logintoken=%@&logincaptcha=%@";
      postString = [postString stringByAppendingFormat:captchaTemplate,
        [GDataUtilities stringByURLEncodingForURI:captchaToken_],
        [GDataUtilities stringByURLEncodingForURI:captchaAnswer_]];
    }
    
    GDataHTTPFetcher* fetcher = [GDataHTTPFetcher httpFetcherWithRequest:request];

    [fetcher setRunLoopModes:[self runLoopModes]];
    
    [fetcher setPostData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [self addAuthenticationToFetcher:fetcher];
    
    [fetcher setFetchHistory:fetchHistory_];
    
    [fetcher setUserData:invocation]; 
    
    [fetcher setIsRetryEnabled:[ticket isRetryEnabled]];
    [fetcher setMaxRetryInterval:[ticket maxRetryInterval]];
    
    if ([ticket retrySelector]) {
      [fetcher setRetrySelector:@selector(authFetcher:willRetry:forError:)];
    }
    
    [ticket setAuthFetcher:fetcher];
    [ticket setCurrentFetcher:fetcher];
    
    [fetcher beginFetchWithDelegate:self
                  didFinishSelector:@selector(authFetcher:finishedWithData:)
          didFailWithStatusSelector:@selector(authFetcher:failedWithStatus:data:)
           didFailWithErrorSelector:@selector(authFetcher:failedWithError:)];
    
    return ticket;
    
  } else {
    // we could not initiate a fetch; tell the client
    id delegate;
    SEL failedSelector;
    [invocation getArgument:&delegate       atIndex:kInvocationDelegateIndex];
    [invocation getArgument:&failedSelector atIndex:kInvocationFailedSelectorIndex];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"empty username/password"
                                                         forKey:kGDataServerErrorStringKey];
    NSError *error = [NSError errorWithDomain:kGDataServiceErrorDomain
                                         code:-1
                                     userInfo:userInfo];
    
    [delegate performSelector:failedSelector
                   withObject:ticket
                   withObject:error];

    return nil;
  }
}

- (void)authFetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data {
  
  // authentication fetch completed
  NSString* responseString = [[[NSString alloc] initWithData:data
                                                    encoding:NSUTF8StringEncoding] autorelease];
  NSDictionary *responseDict = [GDataServiceGoogle dictionaryWithResponseString:responseString];
  NSString *authToken = [responseDict objectForKey:@"Auth"];
  
  [self setAuthToken:authToken];
  
  NSInvocation *invocation = [fetcher userData];

  // set the currentFetcher to nil before we move on to doing an object fetch
  GDataServiceTicket *ticket;
  
  [invocation getArgument:&ticket atIndex:kInvocationTicketIndex];
  [ticket setCurrentFetcher:nil];  
  
  if ([authToken length] > 0) {
    // now invoke the actual fetch
    [invocation invoke];
  } else {
    // there was no auth token    
    [self authFetcher:fetcher failedWithStatus:kGDataBadAuthentication data:data];
  }
  
  // the userData contains the ticket which points to the fetcher; break the
  // retain cycle
  [fetcher setUserData:nil];
}

- (void)authFetcher:(GDataHTTPFetcher *)fetcher failedWithStatus:(int)status data:(NSData *)data {
  
  NSMutableDictionary *userInfo = nil;
  if ([data length]) {
    // put user-readable error info into the error object
    NSString *failureInfoStr = [[[NSString alloc] initWithData:data
                                                      encoding:NSUTF8StringEncoding] autorelease];
    if (failureInfoStr) {
      // parse each line of x=y into an entry in a dictionary
      NSDictionary *responseDict = [GDataServiceGoogle dictionaryWithResponseString:failureInfoStr];
      userInfo = [NSMutableDictionary dictionaryWithDictionary:responseDict];
      
      // look for the partial-path URL to a captch image (which the user
      // can retrieve from the userInfo later with the -captchaURL method)
      NSString *str = [userInfo objectForKey:@"CaptchaUrl"];
      if ([str length] > 0) {
        
        // since we know the sign-in domain now, make a string with the full URL
        NSString *captchaURLString;
        
        if ([str hasPrefix:@"http:"] || [str hasPrefix:@"https:"]) {
          // the server gave us a full URL
          captchaURLString = str;
        } else {
          // the server gave us a relative URL
          captchaURLString = [NSString stringWithFormat:@"https://%@/accounts/%@",
            [self signInDomain], str];
        }
        
        [userInfo setObject:captchaURLString forKey:kCaptchaFullURLKey];
      }
      
      // The auth server returns errors as "Error" but generally the library
      // provides errors in the userInfo as "error".  We'll copy over the
      // auth server's error to "error" as a convenience to clients, and hope
      // few are confused about why the error appears twice in the dictionary.
      NSString *authErrStr = [userInfo authenticationError];
      if (authErrStr != nil 
          && [userInfo objectForKey:kGDataServerErrorStringKey] == nil) {
        [userInfo setObject:authErrStr forKey:kGDataServerErrorStringKey];
      }
    }
  }
  
  NSError *error = [NSError errorWithDomain:kGDataServiceErrorDomain
                                       code:status
                                   userInfo:userInfo];
  [self authFetcher:fetcher failedWithError:error];
}

- (void)authFetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error {
  
  NSInvocation *invocation = [[[fetcher userData] retain] autorelease];
  
  id delegate;
  SEL failedSelector;
  GDataServiceTicket *ticket;
  
  [invocation getArgument:&delegate       atIndex:kInvocationDelegateIndex];
  [invocation getArgument:&failedSelector atIndex:kInvocationFailedSelectorIndex];
  [invocation getArgument:&ticket         atIndex:kInvocationTicketIndex];
  
  [fetcher setUserData:nil];  
  
  [delegate performSelector:failedSelector
                 withObject:ticket
                 withObject:error];  
  
  [ticket setFetchError:error];
  [ticket setHasCalledCallback:YES];
  [ticket setCurrentFetcher:nil];
}

// The auth fetcher may call into this retry method; this one invokes the
// selector provided by the user.
- (BOOL)authFetcher:(GDataHTTPFetcher *)fetcher willRetry:(BOOL)willRetry forError:(NSError *)error {
  
  NSInvocation *invocation = [fetcher userData];
  
  id delegate;
  GDataServiceTicket *ticket;
  
  [invocation getArgument:&delegate       atIndex:kInvocationDelegateIndex];
  [invocation getArgument:&ticket         atIndex:kInvocationTicketIndex];
  
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

// This is the main routine for invoking transactions with with Google services.  
// If there is no auth token available, this routine authenticates before invoking
// the action.
- (GDataServiceTicket *)fetchAuthenticatedObjectWithURL:(NSURL *)objectURL
                                            objectClass:(Class)objectClass
                                           objectToPost:(GDataObject *)objectToPost
                                                   ETag:(NSString *)etag
                                             httpMethod:(NSString *)httpMethod
                                               delegate:(id)delegate
                                      didFinishSelector:(SEL)finishedSelector
                                        didFailSelector:(SEL)failedSelector {
  
  // make an invocation for this call
  GDataServiceTicket *result = nil;
  
  SEL theSEL = @selector(fetchObjectWithURL:objectClass:objectToPost:ETag:httpMethod:delegate:didFinishSelector:didFailSelector:retryInvocationValue:ticket:);
  
  GDataServiceTicket *ticket = [GDataServiceTicket ticketForService:self];
  
  NSMethodSignature *signature = [self methodSignatureForSelector:theSEL];
  NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
  [invocation setSelector:theSEL];
  [invocation setTarget:self];
  [invocation setArgument:&objectURL        atIndex:kInvocationObjectURLIndex];
  [invocation setArgument:&objectClass      atIndex:kInvocationObjectClassIndex];
  [invocation setArgument:&objectToPost     atIndex:kInvocationObjectToPostIndex];
  [invocation setArgument:&etag             atIndex:kInvocationObjectETagIndex];
  [invocation setArgument:&httpMethod       atIndex:kInvocationHTTPMethodIndex];
  [invocation setArgument:&delegate         atIndex:kInvocationDelegateIndex];
  [invocation setArgument:&finishedSelector atIndex:kInvocationFinishedSelectorIndex];
  [invocation setArgument:&failedSelector   atIndex:kInvocationFailedSelectorIndex];
  [invocation setArgument:&ticket           atIndex:kInvocationTicketIndex];
  
  NSValue *noRetryInvocation = nil;
  [invocation setArgument:&noRetryInvocation atIndex:kInvocationRetryInvocationValueIndex];
  
  [invocation retainArguments];
  
  if ([username_ length] == 0) {
    // There's no username, so we can proceed to fetch.  We won't be retrying 
    // this invocation if it fails.
    [invocation invoke];
    [invocation getReturnValue:&result];
    
  } else if ([authToken_ length] > 0 || [authSubToken_ length] > 0) {
    // There is already an auth token.
    //
    // If the auth token has expired, we'll be retrying this same invocation
    // after getting a fresh token
    
    // Having the invocation retain itself as a parameter would cause a
    // retain loop, so we'll have it retain an NSValue of itself
    NSValue *invocationValue = [NSValue valueWithNonretainedObject:invocation];
    
    [invocation setArgument:&invocationValue 
                    atIndex:kInvocationRetryInvocationValueIndex]; 
    [invocation invoke];
    [invocation getReturnValue:&result];

  } else {
    // we need to authenticate first.  We won't be retrying this invocation if 
    // it fails.
    
    result = [self authenticateThenInvoke:invocation];
  }
  return result;
}

// override the base class's failure handler to look for a session expired error
- (void)objectFetcher:(GDataHTTPFetcher *)fetcher failedWithStatus:(int)status data:(NSData *)data {
  
  const int kTokenExpired = 401;
  
  if (status == kTokenExpired) {
    
    NSInvocation *retryInvocation = [fetcher propertyForKey:kFetcherRetryInvocationKey];
    if (retryInvocation) {
      
      // avoid an infinite loop: remove the retry invocation before re-invoking
      NSValue *noRetryInvocation = nil;
      [retryInvocation setArgument:&noRetryInvocation 
                           atIndex:kInvocationRetryInvocationValueIndex];
      
      [self authenticateThenInvoke:retryInvocation];
      return;
    }
  }

  [super objectFetcher:fetcher failedWithStatus:status data:data];
}

#pragma mark -

- (GDataServiceTicket *)fetchAuthenticatedFeedWithURL:(NSURL *)feedURL
                                            feedClass:(Class)feedClass
                                             delegate:(id)delegate
                                    didFinishSelector:(SEL)finishedSelector
                                      didFailSelector:(SEL)failedSelector {
  
  return [self fetchAuthenticatedObjectWithURL:feedURL
                                   objectClass:feedClass
                                  objectToPost:nil
                                          ETag:nil
                                    httpMethod:nil
                                      delegate:delegate
                             didFinishSelector:finishedSelector
                               didFailSelector:failedSelector];
  
}

- (GDataServiceTicket *)fetchAuthenticatedEntryWithURL:(NSURL *)entryURL
                                            entryClass:(Class)entryClass
                                              delegate:(id)delegate
                                     didFinishSelector:(SEL)finishedSelector
                                       didFailSelector:(SEL)failedSelector {
  
  return [self fetchAuthenticatedObjectWithURL:entryURL
                                   objectClass:entryClass
                                  objectToPost:nil
                                          ETag:nil
                                    httpMethod:nil
                                      delegate:delegate
                             didFinishSelector:finishedSelector
                               didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchAuthenticatedEntryByInsertingEntry:(GDataEntryBase *)entryToInsert
                                                     forFeedURL:(NSURL *)feedURL
                                                       delegate:(id)delegate
                                              didFinishSelector:(SEL)finishedSelector
                                                didFailSelector:(SEL)failedSelector {

  NSString *etag = [entryToInsert ETag];

  return [self fetchAuthenticatedObjectWithURL:feedURL
                                   objectClass:[entryToInsert class]
                                  objectToPost:entryToInsert
                                          ETag:etag
                                    httpMethod:@"POST"
                                      delegate:delegate
                             didFinishSelector:finishedSelector
                               didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchAuthenticatedEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                                   forEntryURL:(NSURL *)entryURL
                                                      delegate:(id)delegate
                                             didFinishSelector:(SEL)finishedSelector
                                               didFailSelector:(SEL)failedSelector {

  // Entries should be updated only if they contain copies of any unparsed XML
  // (unknown children and attributes.)
  //
  // To update an entry that ignores unparsed XML, first fetch a complete copy
  // with fetchAuthenticatedEntryWithURL: (or a service-specific entry
  // fetch method) using the URL from the entry's selfLink.
  //
  // See setShouldServiceFeedsIgnoreUnknowns in GDataServiceBase.h for more
  // information.

  GDATA_ASSERT(![entryToUpdate shouldIgnoreUnknowns],
               @"unsafe update of %@", [entryToUpdate class]);

  return [self fetchAuthenticatedObjectWithURL:entryURL
                                   objectClass:[entryToUpdate class]
                                  objectToPost:entryToUpdate
                                          ETag:[entryToUpdate ETag]
                                    httpMethod:@"PUT"
                                      delegate:delegate
                             didFinishSelector:finishedSelector
                               didFailSelector:failedSelector];
}  

- (GDataServiceTicket *)deleteAuthenticatedEntry:(GDataEntryBase *)entryToDelete
                                        delegate:(id)delegate
                               didFinishSelector:(SEL)finishedSelector
                                 didFailSelector:(SEL)failedSelector {
  
  NSString *etag = [entryToDelete ETag];
  NSURL *editURL = [[entryToDelete editLink] URL];
  
  GDATA_ASSERT(editURL != nil, @"deleting uneditable entry: %@", entryToDelete);
  
  return [self deleteAuthenticatedResourceURL:editURL
                                         ETag:etag
                                     delegate:delegate
                            didFinishSelector:finishedSelector
                              didFailSelector:failedSelector];
}  

- (GDataServiceTicket *)deleteAuthenticatedResourceURL:(NSURL *)resourceEditURL
                                              delegate:(id)delegate
                                     didFinishSelector:(SEL)finishedSelector
                                       didFailSelector:(SEL)failedSelector {
  // pass through with a nil ETag
  //
  // This is provided for compatibility with interfaces to v1 services (which
  // lack etag support.)  Interfaces for newer services should only call into
  // deleteAuthenticatedResourceURL:ETag: 

  GDATA_ASSERT(resourceEditURL != nil, @"deleting unspecified resource");

  return [self deleteAuthenticatedResourceURL:resourceEditURL
                                         ETag:nil
                                     delegate:delegate
                            didFinishSelector:finishedSelector
                              didFailSelector:failedSelector];
}

- (GDataServiceTicket *)deleteAuthenticatedResourceURL:(NSURL *)resourceEditURL
                                                  ETag:(NSString *)etag
                                              delegate:(id)delegate
                                     didFinishSelector:(SEL)finishedSelector
                                       didFailSelector:(SEL)failedSelector {

  GDATA_ASSERT(resourceEditURL != nil, @"deleting unspecified resource");
  
  return [self fetchAuthenticatedObjectWithURL:resourceEditURL
                                   objectClass:nil
                                  objectToPost:nil
                                          ETag:etag
                                    httpMethod:@"DELETE"
                                      delegate:delegate
                             didFinishSelector:finishedSelector
                               didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchAuthenticatedFeedWithQuery:(GDataQuery *)query
                                              feedClass:(Class)feedClass
                                               delegate:(id)delegate
                                      didFinishSelector:(SEL)finishedSelector
                                        didFailSelector:(SEL)failedSelector {
  
  return [self fetchAuthenticatedFeedWithURL:[query URL]
                                   feedClass:feedClass
                                    delegate:delegate
                           didFinishSelector:finishedSelector
                             didFailSelector:failedSelector];
}  

#pragma mark -

// Batch feed support

- (GDataServiceTicket *)fetchAuthenticatedFeedWithBatchFeed:(GDataFeedBase *)batchFeed
                                            forBatchFeedURL:(NSURL *)feedURL
                                                   delegate:(id)delegate
                                          didFinishSelector:(SEL)finishedSelector
                                            didFailSelector:(SEL)failedSelector {
  // add basic namespaces to feed, if needed
  if ([[batchFeed namespaces] objectForKey:kGDataNamespaceGDataPrefix] == nil) {
    [batchFeed addNamespaces:[GDataEntryBase baseGDataNamespaces]];
  }
  
  // add batch namespace, if needed
  if ([[batchFeed namespaces] objectForKey:kGDataNamespaceBatchPrefix] == nil) {
    
    [batchFeed addNamespaces:[GDataEntryBase batchNamespaces]];
  }
  
  return [self fetchAuthenticatedObjectWithURL:feedURL
                                   objectClass:[batchFeed class]
                                  objectToPost:batchFeed
                                          ETag:nil
                                    httpMethod:nil
                                      delegate:delegate
                             didFinishSelector:finishedSelector
                               didFailSelector:failedSelector];
}

#pragma mark -

//
// Accessors
//

// When the username or password changes, we invalidate any held auth token
- (void)setUserCredentialsWithUsername:(NSString *)username
                              password:(NSString *)password {
  // if the username or password is changing, invalidate the 
  // auth token
  if (!AreEqualOrBothNil([self username], username)
      || !AreEqualOrBothNil([self password], password)) {
    
    [self setAuthToken:nil];
    [self setAuthSubToken:nil];
  }

  [super setUserCredentialsWithUsername:username password:password];
}

- (void)setCaptchaToken:(NSString *)captchaToken
          captchaAnswer:(NSString *)captchaAnswer {
  
  [captchaToken_ release];
  captchaToken_ = [captchaToken copy];
  
  [captchaAnswer_ release];
  captchaAnswer_ = [captchaAnswer copy];
}

- (NSString *)authToken {
  return authToken_; 
}

- (void)setAuthToken:(NSString *)str {
  [authToken_ autorelease];
  authToken_ = [str copy];
}

- (NSString *)authSubToken {
  return authSubToken_; 
}

- (void)setAuthSubToken:(NSString *)str {
  [authSubToken_ autorelease];
  authSubToken_ = [str copy];
}

- (NSMutableURLRequest *)requestForURL:(NSURL *)url 
                                  ETag:(NSString *)etag
                            httpMethod:(NSString *)httpMethod {
  
  NSMutableURLRequest *request = [super requestForURL:url 
                                                 ETag:etag
                                           httpMethod:httpMethod];

  // if appropriate set the method override header
  if ([httpMethod length] > 0) {
    if (shouldUseMethodOverrideHeader_) {
      // superclass set the http method; we'll change it to POST and 
      // set the header
      [request setValue:httpMethod forHTTPHeaderField:@"X-HTTP-Method-Override"];
      [request setHTTPMethod:@"POST"];
    }  
  }
    
  // add the auth token to the header
  if ([authToken_ length] > 0) {
    NSString *value = [NSString stringWithFormat:@"GoogleLogin auth=%@", 
      authToken_];
    [request setValue:value forHTTPHeaderField: @"Authorization"];
  } else if ([authSubToken_ length] > 0) {
    NSString *value = [NSString stringWithFormat:@"AuthSub token=%@", 
      authSubToken_];
    [request setValue:value forHTTPHeaderField: @"Authorization"];
  }
  return request;
}

- (NSString *)serviceID {
  // subclasses should return the service ID, like @"cl" for calendar
  //
  // if this class is used directly, call setServiceID: before fetching
  
  if (serviceID_) {
    return serviceID_;
  }
  
  GDATA_ASSERT(0, @"GDataServiceGoogle should have a serviceID");
  return nil;
}

- (void)setServiceID:(NSString *)str {
  [serviceID_ autorelease];
  serviceID_ = [str copy];
}

- (NSString *)accountType {
  if (accountType_) {
    return accountType_; 
  }
  return @"HOSTED_OR_GOOGLE";
}

- (void)setAccountType:(NSString *)str {
  [accountType_ autorelease];
  accountType_ = [str copy];
}

- (NSString *)signInDomain {
  if (signInDomain_) {
    return signInDomain_; 
  }
  return @"www.google.com";
}

- (void)setSignInDomain:(NSString *)signInDomain {
  [signInDomain_ release];
  signInDomain_ = [signInDomain copy];
}

// when it's not possible to do http methods other than GET and POST,
// the X-HTTP-Method-Override header can be used in conjunction with POST
// for other commands.  Default for this is NO.
- (BOOL)shouldUseMethodOverrideHeader {
  return shouldUseMethodOverrideHeader_;  
}

- (void)setShouldUseMethodOverrideHeader:(BOOL)flag {
  shouldUseMethodOverrideHeader_ = flag;
}

#pragma mark -

// convert responses of the form "a=foo \n b=bar"   to a dictionary
+ (NSDictionary *)dictionaryWithResponseString:(NSString *)responseString {
  
  NSArray *allLines = [responseString componentsSeparatedByString:@"\n"];
  NSMutableDictionary *responseDict = [NSMutableDictionary dictionary];

  NSString *line;
  GDATA_FOREACH(line, allLines) {
    NSScanner *scanner = [NSScanner scannerWithString:line];
    NSString *key;
    NSString *value;
    
    if ([scanner scanUpToString:@"=" intoString:&key]
        && [scanner scanString:@"=" intoString:nil]
        && [scanner scanUpToString:@"\n" intoString:&value]) {
      
      [responseDict setObject:value forKey:key];
    }
  }
  return responseDict;
}

@end


@implementation GDataServiceTicket

- (void)dealloc {
  [authFetcher_ release];
  [super dealloc];
}

- (NSString *)description {
  NSString *template = @"%@ 0x%lX: {service:%@ objectFetcher:%@ authFetcher:%@ userData:%@}";
  return [NSString stringWithFormat:template,
    [self class], self, service_, objectFetcher_, authFetcher_, userData_];
}

- (void)cancelTicket {
  [authFetcher_ stopFetching];
  [self setAuthFetcher:nil];
  
  [super cancelTicket];
}

- (GDataHTTPFetcher *)authFetcher {
  return [[authFetcher_ retain] autorelease]; 
}

- (void)setAuthFetcher:(GDataHTTPFetcher *)fetcher {
  [authFetcher_ autorelease];
  authFetcher_ = [fetcher retain];
}
@end

@implementation NSDictionary (GDataServiceGoogleAdditions) 
// category to get authentication info from the callback error's userInfo
- (NSString *)authenticationError {
  return [self objectForKey:@"Error"];
}

- (NSString *)captchaToken {
  return [self objectForKey:@"CaptchaToken"];
}

- (NSURL *)captchaURL {
  NSString *str = [self objectForKey:kCaptchaFullURLKey];
  if ([str length] > 0) {
    return [NSURL URLWithString:str]; 
  }
  return nil;
}
@end

