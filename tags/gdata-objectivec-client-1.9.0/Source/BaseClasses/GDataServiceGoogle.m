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

#import "GDataAuthenticationFetcher.h"

extern NSString* const kFetcherRetryInvocationKey;

static NSString* const kCaptchaFullURLKey = @"CaptchaFullUrl";
static NSString* const kFetcherTicketKey = @"_ticket"; // same as in GDataServiceBase

static NSString* const kAuthDelegateKey = @"_delegate";
static NSString* const kAuthSelectorKey = @"_sel";

enum {
  // indices of parameters for the post-authentication invocation
  kInvocationObjectURLIndex = 2,
  kInvocationObjectClassIndex,
  kInvocationObjectToPostIndex,
  kInvocationObjectETagIndex,
  kInvocationHTTPMethodIndex,
  kInvocationDelegateIndex,
  kInvocationFinishedSelectorIndex,
  kInvocationRetryInvocationValueIndex,
  kInvocationTicketIndex
};


@interface GDataServiceGoogle (PrivateMethods)
- (GDataHTTPFetcher *)authenticationFetcher;
- (NSError *)cannotCreateAuthFetcherError;

- (void)authFetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error;
- (NSError *)errorForAuthFetcherStatus:(NSInteger)status data:(NSData *)data;

- (void)standaloneAuthFetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error;

- (void)addNamespacesIfNoneToObject:(GDataObject *)obj;
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

- (NSDictionary *)customAuthenticationRequestHeaders {
  // subclasses may override
  return nil;
}

- (GDataHTTPFetcher *)authenticationFetcher {
  // internal routine
  //
  // create and return an authentication fetcher, either for use alone or as
  // part of a GData object fetch sequence
  NSDictionary *customHeaders = [self customAuthenticationRequestHeaders];
  NSString *domain = [self signInDomain];
  NSString *serviceID = [self serviceID];
  NSString *accountType = [self accountType];
  NSString *password = [self password];

  NSString *userAgent = [self userAgent];
  if ([userAgent length] == 0) {
    userAgent = [[self class] defaultApplicationIdentifier];
  }

  NSDictionary *captchaDict = nil;
  if ([captchaToken_ length] > 0 && [captchaAnswer_ length] > 0) {
    captchaDict = [NSDictionary dictionaryWithObjectsAndKeys:
                   captchaToken_, @"logintoken",
                   captchaAnswer_, @"logincaptcha", nil];
  }

  GDataHTTPFetcher *fetcher;
  fetcher = [GDataAuthenticationFetcher authTokenFetcherWithUsername:username_
                                                            password:password
                                                             service:serviceID
                                                              source:userAgent
                                                        signInDomain:domain
                                                         accountType:accountType
                                                additionalParameters:captchaDict
                                                       customHeaders:customHeaders];

  [fetcher setRunLoopModes:[self runLoopModes]];
  [fetcher setFetchHistory:fetchHistory_];

  [fetcher setIsRetryEnabled:[self isServiceRetryEnabled]];
  [fetcher setMaxRetryInterval:[self serviceMaxRetryInterval]];
  // note: this does not use the custom serviceRetrySelector, as that
  //       assumes there is a ticket associated with the fetcher

  return fetcher;
}

- (NSError *)cannotCreateAuthFetcherError {
  NSDictionary *userInfo;
  userInfo = [NSDictionary dictionaryWithObject:@"empty username/password"
                                         forKey:kGDataServerErrorStringKey];

  NSError *error = [NSError errorWithDomain:kGDataServiceErrorDomain
                                       code:-1
                                   userInfo:userInfo];
  return error;
}

// This routine signs into the service defined by the subclass's serviceID
// method, and if successful calls the invocation's finishedSelector.
- (GDataServiceTicket *)authenticateThenInvoke:(NSInvocation *)invocation {

  GDataServiceTicket *ticket;
  [invocation getArgument:&ticket atIndex:kInvocationTicketIndex];

  GDataHTTPFetcher *fetcher = [self authenticationFetcher];
  if (fetcher) {

    [fetcher setUserData:invocation];

    // store the ticket in the same property the base class uses when
    // fetching so that notification-time code can find the ticket easily
    [fetcher setProperty:ticket
                  forKey:kFetcherTicketKey];

    if ([ticket retrySelector]) {
      [fetcher setRetrySelector:@selector(authFetcher:willRetry:forError:)];
    }

    [ticket setAuthFetcher:fetcher];
    [ticket setCurrentFetcher:fetcher];

    [fetcher beginFetchWithDelegate:self
                  didFinishSelector:@selector(authFetcher:finishedWithData:)
                    didFailSelector:@selector(authFetcher:failedWithError:)];

    return ticket;

  } else {
    // we could not initiate a fetch; tell the client

    id delegate;
    SEL finishedSelector;
    [invocation getArgument:&delegate         atIndex:kInvocationDelegateIndex];
    [invocation getArgument:&finishedSelector atIndex:kInvocationFinishedSelectorIndex];

    if (finishedSelector) {
      NSError *error = [self cannotCreateAuthFetcherError];

      [GDataServiceBase invokeCallback:finishedSelector
                                target:delegate
                                ticket:ticket
                                object:nil
                                 error:error];
    }

    return nil;
  }
}

- (void)authFetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data {

  // authentication fetch completed
  NSString* responseString = [[[NSString alloc] initWithData:data
                                                    encoding:NSUTF8StringEncoding] autorelease];
  NSDictionary *responseDict = [GDataUtilities dictionaryWithResponseString:responseString];
  NSString *authToken = [responseDict objectForKey:kGDataServiceAuthTokenKey];

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
    NSDictionary *userInfo;
    userInfo = [NSDictionary dictionaryWithObject:data
                                           forKey:kGDataHTTPFetcherStatusDataKey];
    NSError *error = [NSError errorWithDomain:kGDataHTTPFetcherStatusDomain
                                         code:kGDataBadAuthentication
                                     userInfo:userInfo];

    [self authFetcher:fetcher failedWithError:error];
  }

  // the userData and properties contain the ticket which points to the
  // fetcher; free those now to break the retain cycle
  [fetcher setUserData:nil];
  [fetcher setProperties:nil];
}

- (void)authFetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error {

  if ([[error domain] isEqual:kGDataHTTPFetcherStatusDomain]) {
    NSInteger status = [error code];
    NSData *data = [[error userInfo] objectForKey:kGDataHTTPFetcherStatusDataKey];
    error = [self errorForAuthFetcherStatus:status data:data];
  }

  NSInvocation *invocation = [[[fetcher userData] retain] autorelease];

  id delegate;
  SEL finishedSelector;
  GDataServiceTicket *ticket;

  [invocation getArgument:&delegate         atIndex:kInvocationDelegateIndex];
  [invocation getArgument:&finishedSelector atIndex:kInvocationFinishedSelectorIndex];
  [invocation getArgument:&ticket           atIndex:kInvocationTicketIndex];

  [fetcher setUserData:nil];
  [fetcher setProperties:nil];

  if (finishedSelector) {
    [GDataServiceBase invokeCallback:finishedSelector
                              target:delegate
                              ticket:ticket
                              object:nil
                               error:error];
  }

  [ticket setFetchError:error];
  [ticket setHasCalledCallback:YES];
  [ticket setCurrentFetcher:nil];
}

- (NSError *)errorForAuthFetcherStatus:(NSInteger)status data:(NSData *)data {
  // convert the data into a useful NSError
  NSMutableDictionary *userInfo = nil;
  if ([data length] > 0) {
    // put user-readable error info into the error object
    NSString *failureInfoStr = [[[NSString alloc] initWithData:data
                                                      encoding:NSUTF8StringEncoding] autorelease];
    if (failureInfoStr) {
      // parse each line of x=y into an entry in a dictionary
      NSDictionary *responseDict = [GDataUtilities dictionaryWithResponseString:failureInfoStr];
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
  return error;
}

// The auth fetcher may call into this retry method; this one invokes the
// selector provided by the user.
- (BOOL)authFetcher:(GDataHTTPFetcher *)fetcher willRetry:(BOOL)willRetry forError:(NSError *)error {

  NSInvocation *invocation = [fetcher userData];

  id delegate;
  GDataServiceTicket *ticket;

  [invocation getArgument:&delegate atIndex:kInvocationDelegateIndex];
  [invocation getArgument:&ticket   atIndex:kInvocationTicketIndex];

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
                                      didFinishSelector:(SEL)finishedSelector {

  // make an invocation for this call
  GDataServiceTicket *result = nil;

  SEL theSEL = @selector(fetchObjectWithURL:objectClass:objectToPost:ETag:httpMethod:delegate:didFinishSelector:retryInvocationValue:ticket:);

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
- (void)objectFetcher:(GDataHTTPFetcher *)fetcher failedWithStatus:(NSInteger)status data:(NSData *)data {

  const NSInteger kTokenExpired = 401;

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

// Standalone auth: authenticate without fetching a feed or entry
//
// authSelector has a signature matching:
//   - (void)ticket:(GDataServiceTicket *)ticket authenticatedWithError:(NSError *)error;

- (GDataServiceTicket *)authenticateWithDelegate:(id)delegate
                         didAuthenticateSelector:(SEL)authSelector {
  AssertSelectorNilOrImplementedWithArguments(delegate, authSelector, @encode(GDataServiceGoogle *), @encode(NSError *), 0);

  GDataHTTPFetcher *fetcher = [self authenticationFetcher];
  if (fetcher) {

    NSString *selStr = NSStringFromSelector(authSelector);
    [fetcher setProperty:delegate forKey:kAuthDelegateKey];
    [fetcher setProperty:selStr forKey:kAuthSelectorKey];

    GDataServiceTicket *ticket = [GDataServiceTicket ticketForService:self];
    [ticket setAuthFetcher:fetcher];
    [fetcher setProperty:ticket forKey:kFetcherTicketKey];

    BOOL flag = [fetcher beginFetchWithDelegate:self
                              didFinishSelector:@selector(standaloneAuthFetcher:finishedWithData:)
                                didFailSelector:@selector(standaloneAuthFetcher:failedWithError:)];
    if (flag) {
      return ticket;
    } else {
      // failed to start the fetch; the fetch failed callback was called
      return nil;
    }
  }

  // we could not initiate a fetch; tell the client
  if (authSelector) {
    NSError *error = [self cannotCreateAuthFetcherError];

    [delegate performSelector:authSelector
                   withObject:nil
                   withObject:error];
  }
  return nil;
}

- (void)standaloneAuthFetcher:(GDataHTTPFetcher *)fetcher
             finishedWithData:(NSData *)data {

  NSString* responseString;
  responseString = [[[NSString alloc] initWithData:data
                                          encoding:NSUTF8StringEncoding] autorelease];
  NSDictionary *responseDict;
  responseDict = [GDataUtilities dictionaryWithResponseString:responseString];

  NSString *authToken = [responseDict objectForKey:kGDataServiceAuthTokenKey];

  // save the new auth token, even if it's empty
  [self setAuthToken:authToken];

  GDataServiceTicket *ticket = [fetcher propertyForKey:kFetcherTicketKey];

  NSString *selStr = [fetcher propertyForKey:kAuthSelectorKey];
  id delegate = [fetcher propertyForKey:kAuthDelegateKey];
  SEL authSelector = NSSelectorFromString(selStr);

  if ([authToken length] > 0) {
    // succeeded
    if (authSelector) {
      [delegate performSelector:authSelector
                     withObject:ticket
                     withObject:nil];
    }

    [ticket setAuthFetcher:nil];

    // avoid a retain cycle
    [fetcher setProperties:nil];
  } else {
    // failed: there was no auth token
    NSError *error = [self errorForAuthFetcherStatus:kGDataBadAuthentication
                                                data:data];
    [self standaloneAuthFetcher:fetcher failedWithError:error];
  }
}

- (void)standaloneAuthFetcher:(GDataHTTPFetcher *)fetcher
              failedWithError:(NSError *)error {

  // failed to authenticate
  if ([[error domain] isEqual:kGDataHTTPFetcherStatusDomain]) {
    NSInteger status = [error code];
    NSData *data = [[error userInfo] objectForKey:kGDataHTTPFetcherStatusDataKey];
    error = [self errorForAuthFetcherStatus:status data:data];
  }

  NSString *selStr = [fetcher propertyForKey:kAuthSelectorKey];
  id delegate = [fetcher propertyForKey:kAuthDelegateKey];
  SEL authSelector = NSSelectorFromString(selStr);

  GDataServiceTicket *ticket = [fetcher propertyForKey:kFetcherTicketKey];
  [delegate performSelector:authSelector
                 withObject:ticket
                 withObject:error];

  [ticket setAuthFetcher:nil];

  // avoid a retain cycle
  [fetcher setProperties:nil];
}


#pragma mark -

- (GDataServiceTicket *)fetchFeedWithURL:(NSURL *)feedURL
                                delegate:(id)delegate
                       didFinishSelector:(SEL)finishedSelector {

  return [self fetchFeedWithURL:feedURL
                      feedClass:kGDataUseRegisteredClass
                       delegate:delegate
              didFinishSelector:finishedSelector];
}

- (GDataServiceTicket *)fetchFeedWithURL:(NSURL *)feedURL
                               feedClass:(Class)feedClass
                                delegate:(id)delegate
                       didFinishSelector:(SEL)finishedSelector {

  return [self fetchAuthenticatedObjectWithURL:feedURL
                                   objectClass:feedClass
                                  objectToPost:nil
                                          ETag:nil
                                    httpMethod:nil
                                      delegate:delegate
                             didFinishSelector:finishedSelector];
}

- (GDataServiceTicket *)fetchEntryWithURL:(NSURL *)entryURL
                                 delegate:(id)delegate
                        didFinishSelector:(SEL)finishedSelector {

  return [self fetchEntryWithURL:entryURL
                      entryClass:kGDataUseRegisteredClass
                        delegate:delegate
               didFinishSelector:finishedSelector];
}

- (GDataServiceTicket *)fetchEntryWithURL:(NSURL *)entryURL
                               entryClass:(Class)entryClass
                                 delegate:(id)delegate
                        didFinishSelector:(SEL)finishedSelector {

  return [self fetchAuthenticatedObjectWithURL:entryURL
                                   objectClass:entryClass
                                  objectToPost:nil
                                          ETag:nil
                                    httpMethod:nil
                                      delegate:delegate
                             didFinishSelector:finishedSelector];
}

- (GDataServiceTicket *)fetchEntryByInsertingEntry:(GDataEntryBase *)entryToInsert
                                        forFeedURL:(NSURL *)feedURL
                                          delegate:(id)delegate
                                 didFinishSelector:(SEL)finishedSelector {

  NSString *etag = [entryToInsert ETag];

  // objects being uploaded will always need some namespaces at the root level
  [self addNamespacesIfNoneToObject:entryToInsert];

  return [self fetchAuthenticatedObjectWithURL:feedURL
                                   objectClass:[entryToInsert class]
                                  objectToPost:entryToInsert
                                          ETag:etag
                                    httpMethod:@"POST"
                                      delegate:delegate
                             didFinishSelector:finishedSelector];
}


- (GDataServiceTicket *)fetchEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                         delegate:(id)delegate
                                didFinishSelector:(SEL)finishedSelector {

  NSURL *editURL = [[entryToUpdate editLink] URL];

  return [self fetchEntryByUpdatingEntry:entryToUpdate
                             forEntryURL:editURL
                                delegate:delegate
                       didFinishSelector:finishedSelector];
}

- (GDataServiceTicket *)fetchEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                      forEntryURL:(NSURL *)entryURL
                                         delegate:(id)delegate
                                didFinishSelector:(SEL)finishedSelector {

  // Entries should be updated only if they contain copies of any unparsed XML
  // (unknown children and attributes.)
  //
  // To update an entry that ignores unparsed XML, first fetch a complete copy
  // with fetchEntryWithURL: (or a service-specific entry fetch method) using
  // the URL from the entry's selfLink.
  //
  // See setShouldServiceFeedsIgnoreUnknowns in GDataServiceBase.h for more
  // information.

  GDATA_ASSERT(![entryToUpdate shouldIgnoreUnknowns],
               @"unsafe update of %@", [entryToUpdate class]);

  // objects being uploaded will always need some namespaces at the root level
  [self addNamespacesIfNoneToObject:entryToUpdate];

  return [self fetchAuthenticatedObjectWithURL:entryURL
                                   objectClass:[entryToUpdate class]
                                  objectToPost:entryToUpdate
                                          ETag:[entryToUpdate ETag]
                                    httpMethod:@"PUT"
                                      delegate:delegate
                             didFinishSelector:finishedSelector];
}

- (GDataServiceTicket *)deleteEntry:(GDataEntryBase *)entryToDelete
                           delegate:(id)delegate
                  didFinishSelector:(SEL)finishedSelector {

  NSString *etag = [entryToDelete ETag];
  NSURL *editURL = [[entryToDelete editLink] URL];

  GDATA_ASSERT(editURL != nil, @"deleting uneditable entry: %@", entryToDelete);

  return [self deleteResourceURL:editURL
                            ETag:etag
                        delegate:delegate
               didFinishSelector:finishedSelector];
}

- (GDataServiceTicket *)deleteResourceURL:(NSURL *)resourceEditURL
                                     ETag:(NSString *)etag
                                 delegate:(id)delegate
                        didFinishSelector:(SEL)finishedSelector {

  GDATA_ASSERT(resourceEditURL != nil, @"deleting unspecified resource");

  return [self fetchAuthenticatedObjectWithURL:resourceEditURL
                                   objectClass:nil
                                  objectToPost:nil
                                          ETag:etag
                                    httpMethod:@"DELETE"
                                      delegate:delegate
                             didFinishSelector:finishedSelector];
}

- (GDataServiceTicket *)fetchFeedWithQuery:(GDataQuery *)query
                                  delegate:(id)delegate
                         didFinishSelector:(SEL)finishedSelector {

  return [self fetchFeedWithURL:[query URL]
                      feedClass:kGDataUseRegisteredClass
                       delegate:delegate
              didFinishSelector:finishedSelector];
}

- (GDataServiceTicket *)fetchFeedWithQuery:(GDataQuery *)query
                                 feedClass:(Class)feedClass
                                  delegate:(id)delegate
                         didFinishSelector:(SEL)finishedSelector {

  return [self fetchFeedWithURL:[query URL]
                      feedClass:feedClass
                       delegate:delegate
              didFinishSelector:finishedSelector];
}

// add namespaces to the object being uploaded, though only if it currently
// lacks root-level namespaces
- (void)addNamespacesIfNoneToObject:(GDataObject *)obj {

  if ([obj namespaces] == nil) {
    NSDictionary *namespaces = [[self class] standardServiceNamespaces];
    GDATA_DEBUG_ASSERT(namespaces != nil, @"nil namespaces in service");

    [obj setNamespaces:namespaces];
  }
}

+ (NSDictionary *)standardServiceNamespaces {
  // subclasses override this if they have custom namespaces
  return [GDataEntryBase baseGDataNamespaces];
}

#pragma mark -

// Batch feed support

- (GDataServiceTicket *)fetchFeedWithBatchFeed:(GDataFeedBase *)batchFeed
                               forBatchFeedURL:(NSURL *)feedURL
                                      delegate:(id)delegate
                             didFinishSelector:(SEL)finishedSelector {
  // add basic namespaces to feed, if needed
  if ([[batchFeed namespaces] objectForKey:kGDataNamespaceGDataPrefix] == nil) {
    [batchFeed addNamespaces:[GDataEntryBase baseGDataNamespaces]];
  }

  // add batch namespace, if needed
  if ([[batchFeed namespaces] objectForKey:kGDataNamespaceBatchPrefix] == nil) {

    [batchFeed addNamespaces:[GDataEntryBase batchNamespaces]];
  }

  GDataServiceTicket *ticket;

  ticket = [self fetchAuthenticatedObjectWithURL:feedURL
                                     objectClass:[batchFeed class]
                                    objectToPost:batchFeed
                                            ETag:nil
                                      httpMethod:nil
                                        delegate:delegate
                               didFinishSelector:finishedSelector];

  // batch feeds never ignore unknowns, since they are intrinsically
  // used for updating so their entries need to include complete XML
  [ticket setShouldFeedsIgnoreUnknowns:NO];

  return ticket;
}

#pragma mark -

//
// Accessors
//

// When the username or password changes, we invalidate any held auth token
- (void)setUserCredentialsWithUsername:(NSString *)username
                              password:(NSString *)password {
  // if the username or password is changing, invalidate the
  // auth token and clear the history of last-modified dates
  if (!AreEqualOrBothNil([self username], username)
      || !AreEqualOrBothNil([self password], password)) {

    [self setAuthToken:nil];
    [self setAuthSubToken:nil];

    [self clearLastModifiedDates];
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
  if (shouldUseMethodOverrideHeader_) {
    if ([httpMethod length] > 0 && ![httpMethod isEqualToString:@"POST"]) {
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

+ (NSString *)serviceID {
  // subclasses should override this class method to return the service ID,
  // like @"cl" for calendar
  return nil;
}

- (NSString *)serviceID {
  // if the base class is used directly, call setServiceID: before fetching
  if (serviceID_) return serviceID_;

  NSString *str = [[self class] serviceID];
  if (str) return str;

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

@end


@implementation GDataServiceTicket

- (void)dealloc {
  [authFetcher_ release];
  [super dealloc];
}

- (NSString *)description {
  NSString *template = @"%@ %p: {service:%@ objectFetcher:%@ authFetcher:%@ userData:%@}";
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
