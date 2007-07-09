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

extern NSString* const kCallbackRetryInvocationKey;

static NSString* const kCaptchaFullURLKey = @"CaptchaFullUrl";

enum {
  // indices of parameters for the post-authentication invocation
  kInvocationObjectURLIndex = 2,
  kInvocationObjectClassIndex,
  kInvocationObjectToPostIndex,
  kInvocationHTTPMethodIndex,
  kInvocationDelegateIndex,
  kInvocationFinishedSelectorIndex,
  kInvocationFailedSelectorIndex,
  kInvocationRetryInvocationIndex,
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
  [signInDomain_ release];
  [serviceID_ release];
  [super dealloc]; 
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
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:authURLString]];
    
    NSString *password = [self password];

    NSString *userAgent = [self userAgent];
    if ([userAgent length] == 0) {
      userAgent = [self defaultApplicationIdentifier];
    }
    
    NSString *postTemplate = @"Email=%@&Passwd=%@&source=%@&service=%@&accountType=HOSTED_OR_GOOGLE";
    NSString *postString = [NSString stringWithFormat:postTemplate, 
      [self stringByURLEncoding:[self username]],
      [self stringByURLEncoding:password],
      [self stringByURLEncoding:userAgent],
      [self serviceID]];
    
    if ([captchaToken_ length] > 0 && [captchaAnswer_ length] > 0) {
      NSString *captchaTemplate = @"&logintoken=%@&logincaptcha=%@";
      postString = [postString stringByAppendingFormat:captchaTemplate,
        [self stringByURLEncoding:captchaToken_],
        [self stringByURLEncoding:captchaAnswer_]];
    }
    
    GDataHTTPFetcher* fetcher = [GDataHTTPFetcher httpFetcherWithRequest:request];
    
    [fetcher setPostData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [self addAuthenticationToFetcher:fetcher];
    
    [fetcher setFetchHistory:fetchHistory_];
    
    [fetcher setUserData:invocation]; 
    
    [ticket setAuthFetcher:fetcher];
    
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
                                                         forKey:@"error"];
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
  
  NSString* responseString = [[[NSString alloc] initWithData:data
                                                    encoding:NSUTF8StringEncoding] autorelease];
  NSDictionary *responseDict = [GDataServiceGoogle dictionaryWithResponseString:responseString];
  NSString *authToken = [responseDict objectForKey:@"Auth"];
  
  [authToken_ release];
  authToken_ = [authToken retain];
  
  if ([authToken_ length] > 0) {
    // now invoke the actual fetch
    NSInvocation *invocation = [fetcher userData];
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
        NSString *captchaURLString = [NSString stringWithFormat:@"https://%@/accounts/%@",
          [self signInDomain], str];
        
        [userInfo setObject:captchaURLString forKey:kCaptchaFullURLKey];
      }
      
      // The auth server returns errors as "Error" but generally the library
      // provides errors in the userInfo as "error".  We'll copy over the
      // auth server's error to "error" as a convenience to clients, and hope
      // few are confused about why the error appears twice in the dictionary.
      NSString *authErrStr = [userInfo authenticationError];
      if (authErrStr != nil && [userInfo objectForKey:@"error"] == nil) {
        [userInfo setObject:authErrStr forKey:@"error"];
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

  [ticket setHasCalledCallback:YES];
}

// This is the main routine for invoking transactions with with Google services.  
// If there is no auth token available, this routine authenticates before invoking
// the action.
- (GDataServiceTicket *)fetchAuthenticatedObjectWithURL:(NSURL *)objectURL
                                            objectClass:(Class)objectClass
                                           objectToPost:(GDataObject *)objectToPost
                                             httpMethod:(NSString *)httpMethod
                                               delegate:(id)delegate
                                      didFinishSelector:(SEL)finishedSelector
                                        didFailSelector:(SEL)failedSelector {
  
  // make an invocation for this call
  GDataServiceTicket *result = nil;
  
  SEL theSEL = @selector(fetchObjectWithURL:objectClass:objectToPost:httpMethod:delegate:didFinishSelector:didFailSelector:retryInvocation:ticket:);
  
  GDataServiceTicket *ticket = [GDataServiceTicket authTicketForService:self];
  [ticket setUserData:serviceUserData_];
  [ticket setSurrogates:serviceSurrogates_];
  [ticket setUploadProgressSelector:serviceUploadProgressSelector_];
  
  NSMethodSignature *signature = [self methodSignatureForSelector:theSEL];
  NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
  [invocation setSelector:theSEL];
  [invocation setTarget:self];
  [invocation setArgument:&objectURL        atIndex:kInvocationObjectURLIndex];
  [invocation setArgument:&objectClass      atIndex:kInvocationObjectClassIndex];
  [invocation setArgument:&objectToPost     atIndex:kInvocationObjectToPostIndex];
  [invocation setArgument:&httpMethod       atIndex:kInvocationHTTPMethodIndex];
  [invocation setArgument:&delegate         atIndex:kInvocationDelegateIndex];
  [invocation setArgument:&finishedSelector atIndex:kInvocationFinishedSelectorIndex];
  [invocation setArgument:&failedSelector   atIndex:kInvocationFailedSelectorIndex];
  [invocation setArgument:&ticket           atIndex:kInvocationTicketIndex];
  
  NSInvocation *noRetryInvocation = nil;
  [invocation setArgument:&noRetryInvocation atIndex:kInvocationRetryInvocationIndex];
  
  [invocation retainArguments];
  
  if ([username_ length] == 0) {
    // There's no username, so we can proceed to fetch.  We won't be retrying 
    // this invocation if it fails.
    [invocation invoke];
    [invocation getReturnValue:&result];
    
  } else if ([authToken_ length] > 0) {
    // There is already an auth token.
    //
    // If the auth token has expired, we'll be retrying this same invocation
    // after getting a fresh token
    
    [invocation setArgument:&invocation 
                    atIndex:kInvocationRetryInvocationIndex]; 
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
    
    NSDictionary *callbackDict = [fetcher userData];
    NSInvocation *retryInvocation = [callbackDict objectForKey:kCallbackRetryInvocationKey];
    if (retryInvocation) {
      
      // avoid an infinite loop: remove the retry invocation before re-invoking
      NSInvocation *noRetryInvocation = nil;
      [retryInvocation setArgument:&noRetryInvocation atIndex:kInvocationRetryInvocationIndex];
      
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
  
  return [self fetchAuthenticatedObjectWithURL:feedURL
                                   objectClass:[entryToInsert class]
                                  objectToPost:entryToInsert
                                    httpMethod:nil
                                      delegate:delegate
                             didFinishSelector:finishedSelector
                               didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchAuthenticatedEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                                   forEntryURL:(NSURL *)entryURL
                                                      delegate:(id)delegate
                                             didFinishSelector:(SEL)finishedSelector
                                               didFailSelector:(SEL)failedSelector {
  
  return [self fetchAuthenticatedObjectWithURL:entryURL
                                   objectClass:[entryToUpdate class]
                                  objectToPost:entryToUpdate
                                    httpMethod:@"PUT"
                                      delegate:delegate
                             didFinishSelector:finishedSelector
                               didFailSelector:failedSelector];
}  

- (GDataServiceTicket *)deleteAuthenticatedResourceURL:(NSURL *)resourceEditURL
                                              delegate:(id)delegate
                                     didFinishSelector:(SEL)finishedSelector
                                       didFailSelector:(SEL)failedSelector {
  
  return [self fetchAuthenticatedObjectWithURL:resourceEditURL
                                   objectClass:nil
                                  objectToPost:nil
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

- (GDataServiceTicket *)fetchAuthenticatedFeedWithBatchFeed:(GDataFeedBase *)batchFeed
                                            forBatchFeedURL:(NSURL *)feedURL
                                                   delegate:(id)delegate
                                          didFinishSelector:(SEL)finishedSelector
                                            didFailSelector:(SEL)failedSelector {
  
  return [self fetchAuthenticatedObjectWithURL:feedURL
                                   objectClass:[batchFeed class]
                                  objectToPost:batchFeed
                                    httpMethod:nil
                                      delegate:delegate
                             didFinishSelector:finishedSelector
                               didFailSelector:failedSelector];
}

// When the username or password changes, we invalidate any held auth token
- (void)setUserCredentialsWithUsername:(NSString *)username
                              password:(NSString *)password {
  // if the username or password is changing, invalidate the 
  // auth token
  if (!AreEqualOrBothNil([self username], username)
      || !AreEqualOrBothNil([self password], password)) {
    
    [authToken_ release];
    authToken_ = nil;
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

- (NSMutableURLRequest *)requestForURL:(NSURL *)url httpMethod:(NSString *)httpMethod {
  
  NSMutableURLRequest *request = [super requestForURL:url httpMethod:httpMethod];

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
  if (authToken_) {
    NSString *value = [NSString stringWithFormat:@"GoogleLogin auth=%@", 
      authToken_];
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
  
  NSAssert(0, @"GDataServiceGoogle should have a serviceID");
  return nil;
}

- (void)setServiceID:(NSString *)str {
  [serviceID_ autorelease];
  serviceID_ = [str copy];
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
  
  NSArray *lines = [responseString componentsSeparatedByString:@"\n"];
  
  NSMutableDictionary *responseDict = [NSMutableDictionary dictionary];
  
  int idx;
  for (idx = 0; idx < [lines count]; idx++) {
    
    NSString *line = [lines objectAtIndex:idx];
    
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
+ (GDataServiceTicket *)authTicketForService:(GDataServiceGoogle *)service {
  return [[[self alloc] initWithService:service] autorelease]; 
}

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

