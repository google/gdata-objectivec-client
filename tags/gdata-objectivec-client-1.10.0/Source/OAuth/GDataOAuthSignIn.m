/* Copyright (c) 2010 Google Inc.
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

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_OAUTH

#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_5

#define GDATAOAUTHSIGNIN_DEFINE_GLOBALS 1
#import "GDataOAuthSignIn.h"

@interface GDataOAuthSignIn ()
- (void)invokeFinalCallbackWithError:(NSError *)error;

- (GDataHTTPFetcher *)pendingFetcher;
- (void)setPendingFetcher:(GDataHTTPFetcher *)obj fetchType:(NSString *)fetchType;

- (void)closeTheWindow;
@end

@implementation GDataOAuthSignIn

@synthesize delegate = delegate_;
@synthesize authentication = auth_;
@synthesize userData = userData_;

@synthesize requestTokenURL = requestURL_;
@synthesize authorizeTokenURL = authorizeURL_;
@synthesize accessTokenURL = accessURL_;

- (id)initWithGoogleAuthenticationForScope:(NSString *)scope
                                  language:(NSString *)language
                                  delegate:(id)delegate
                        webRequestSelector:(SEL)webRequestSelector
                          finishedSelector:(SEL)finishedSelector {
  // standard Google OAuth endpoints
  //
  // http://code.google.com/apis/accounts/docs/OAuth_ref.html

  NSURL *requestURL = [NSURL URLWithString:@"https://www.google.com/accounts/OAuthGetRequestToken"];
  NSURL *authorizeURL = [NSURL URLWithString:@"https://www.google.com/accounts/OAuthAuthorizeToken"];
  NSURL *accessURL = [NSURL URLWithString:@"https://www.google.com/accounts/OAuthGetAccessToken"];

  GDataOAuthAuthentication *auth = [GDataOAuthAuthentication authForInstalledApp];

  [auth setScope:scope];
  [auth setLanguage:language];
  [auth setServiceProvider:kGDataOAuthServiceProviderGoogle];

  // open question: should we call [auth setHostedDomain: ] here too?

  // we'll use the mobile user interface for embedded sign-in as it's smaller
  // and somewhat more suitable for embedded usage
  [auth setMobile:@"mobile"];

  // we'll use a non-existent callback address, and close the window
  // immediately when it's requested
  [auth setCallback:@"http://www.google.com/OAuthCallback"];

  return [self initWithAuthentication:auth
                      requestTokenURL:requestURL
                    authorizeTokenURL:authorizeURL
                       accessTokenURL:accessURL
                             delegate:delegate
                   webRequestSelector:webRequestSelector
                     finishedSelector:finishedSelector];
}

- (id)initWithAuthentication:(GDataOAuthAuthentication *)auth
             requestTokenURL:(NSURL *)requestURL
           authorizeTokenURL:(NSURL *)authorizeURL
              accessTokenURL:(NSURL *)accessURL
                    delegate:(id)delegate
          webRequestSelector:(SEL)webRequestSelector
            finishedSelector:(SEL)finishedSelector {
  // check the selectors on debug builds
  AssertSelectorNilOrImplementedWithArguments(delegate, webRequestSelector,
    @encode(GDataOAuthSignIn *), @encode(NSURLRequest *), 0);
  AssertSelectorNilOrImplementedWithArguments(delegate, finishedSelector,
    @encode(GDataOAuthSignIn *), @encode(GDataOAuthAuthentication *),
    @encode(NSError *), 0);

  // designated initializer
  self = [super init];
  if (self != nil) {
    auth_ = [auth retain];
    requestURL_ = [requestURL retain];
    authorizeURL_ = [authorizeURL retain];
    accessURL_ = [accessURL retain];

    delegate_ = delegate;
    webRequestSelector_ = webRequestSelector;
    finishedSelector_ = finishedSelector;
  }
  return self;
}

- (void)dealloc {
  [auth_ release];

  [requestURL_ release];
  [authorizeURL_ release];
  [accessURL_ release];

  [userData_ release];

  [super dealloc];
}

#pragma mark Sign-in Sequence Methods

// stop any pending fetches, and close the window (but don't call the
// delegate's finishedSelector)
- (void)cancelSigningIn {
  [pendingFetcher_ stopFetching];
  [self setPendingFetcher:nil fetchType:nil];

  [self closeTheWindow];
}

//
// This is the entry point to begin the sequence
//  - fetch a request token
//  - display the authentication web page
//  - exchange the request token for an access token
//  - tell the delegate we're finished
//
- (BOOL)startSigningIn {
  // the authentication object won't have an access token until the access
  // fetcher successfully finishes; any auth token held before then is a request
  // token
  [auth_ setHasAccessToken:NO];

  // start fetching a request token
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL_];
  [auth_ addRequestTokenHeaderToRequest:request];

  GDataHTTPFetcher *fetcher = [GDataHTTPFetcher httpFetcherWithRequest:request];

  BOOL didStart = [fetcher beginFetchWithDelegate:self
                                didFinishSelector:@selector(requestFetcher:finishedWithData:)
                                  didFailSelector:@selector(requestFetcher:failedWithError:)];
  if (didStart) {
    [self setPendingFetcher:fetcher fetchType:kGDataOAuthFetchTypeRequest];
  }
  return didStart;
}

- (void)requestFetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data {
  [self setPendingFetcher:nil fetchType:nil];

  [auth_ setKeysForResponseData:data];

  // if the auth object has a request token, we can proceed
  NSString *token = [auth_ token];
  if ([token length] > 0) {
    // invoke the user's web request selector to display the request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:authorizeURL_];
    [auth_ addAuthorizeTokenParamsToRequest:request];

    [delegate_ performSelector:webRequestSelector_
                    withObject:self
                    withObject:request];
  }
}

- (void)requestFetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error {
  [self setPendingFetcher:nil fetchType:nil];

  [self invokeFinalCallbackWithError:error];
}

// entry point for the window controller to tell us that the window
// prematurely closed
- (void)windowWasClosed {
  [pendingFetcher_ stopFetching];
  [self setPendingFetcher:nil fetchType:nil];

  NSError *error = [NSError errorWithDomain:kGDataOAuthErrorDomain
                                       code:kGDataOAuthErrorWindowClosed
                                   userInfo:nil];

  [self invokeFinalCallbackWithError:error];
}

// internal method to tell the window controller to close the window
- (void)closeTheWindow {
  [delegate_ performSelector:webRequestSelector_
                  withObject:self
                  withObject:nil];
}

// entry point for the window controller to tell us what web page has been
// requested
//
// when the request is for the callback URL, this method returns YES, and begins
// the fetch to exchange the request token for an access token
- (BOOL)requestRedirectedToRequest:(NSURLRequest *)redirectedRequest {
  // compare the callback URL, which tells us when the web sign-in is done,
  // to the actual redirect URL
  NSString *callback = [auth_ callback];
  NSURL *callbackURL = [NSURL URLWithString:callback];

  NSURL *requestURL = [redirectedRequest URL];

  BOOL isCallback = [[callbackURL host] isEqual:[requestURL host]]
    && [[callbackURL path] isEqual:[requestURL path]];

  if (!isCallback) {
    // tell the caller that this request is nothing interesting
    return NO;
  }

  // the callback page was requested, so tell the window to close
  [self closeTheWindow];

  // once the authorization finishes, try to get a validated access token
  NSString *responseStr = [[redirectedRequest URL] query];
  [auth_ setKeysForResponseString:responseStr];

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:accessURL_];
  [auth_ addAccessTokenHeaderToRequest:request];

  GDataHTTPFetcher *fetcher = [GDataHTTPFetcher httpFetcherWithRequest:request];

  [fetcher beginFetchWithDelegate:self
                didFinishSelector:@selector(accessFetcher:finishedWithData:)
                  didFailSelector:@selector(accessFetcher:failedWithError:)];

  [self setPendingFetcher:fetcher fetchType:kGDataOAuthFetchTypeAccess];

  // tell the delegate that we did handle this request
  return YES;
}

- (void)accessFetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data {
  [self setPendingFetcher:nil fetchType:nil];

  // if this fetch succeeds, we have an access token
  [auth_ setKeysForResponseData:data];
  [auth_ setHasAccessToken:YES];

  [self invokeFinalCallbackWithError:nil];
}

- (void)accessFetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error {
  [self setPendingFetcher:nil fetchType:nil];

  [self invokeFinalCallbackWithError:error];
}

// convenience method for making the final call to our delegate
- (void)invokeFinalCallbackWithError:(NSError *)error {
  if (delegate_ && finishedSelector_) {
    NSMethodSignature *sig = [delegate_ methodSignatureForSelector:finishedSelector_];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setSelector:finishedSelector_];
    [invocation setTarget:delegate_];
    [invocation setArgument:&self atIndex:2];
    [invocation setArgument:&auth_ atIndex:3];
    [invocation setArgument:&error atIndex:4];
    [invocation invoke];
  }

  // we'll no longer send messages to the delegate
  [self setDelegate:nil];
}

- (void)notifyFetchIsRunning:(BOOL)isStarting
                        type:(NSString *)fetchType {
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

  NSString *name = (isStarting ? kGDataOAuthFetchStarted : kGDataOAuthFetchStopped);
  NSDictionary *dict = [NSDictionary dictionaryWithObject:fetchType
                                                   forKey:kGDataOAuthFetchTypeKey];
  [nc postNotificationName:name
                    object:self
                  userInfo:dict];
}

#pragma mark Token Revocation

+ (void)revokeTokenForGoogleAuthentication:(GDataOAuthAuthentication *)auth {
  // we can revoke Google tokens with the old AuthSub API,
  // http://code.google.com/apis/accounts/docs/AuthSub.html
  if ([auth canAuthorize]
      && [[auth serviceProvider] isEqual:kGDataOAuthServiceProviderGoogle]) {

    NSURL *url = [NSURL URLWithString:@"https://www.google.com/accounts/accounts/AuthSubRevokeToken"];

    // create a signed revocation request for this authentication object
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [auth addResourceTokenHeaderToRequest:request];

    // remove the no-longer-usable token from the authentication object
    [auth setHasAccessToken:NO];
    [auth setToken:nil];

    // we'll issue the request asynchronously, and there's nothing to be done if
    // revocation succeeds or fails
    [NSURLConnection connectionWithRequest:request
                                  delegate:nil];
  }
}

#pragma mark Accessors

- (GDataHTTPFetcher *)pendingFetcher {
  return pendingFetcher_;
}



- (void)setPendingFetcher:(GDataHTTPFetcher *)fetcher
                fetchType:(NSString *)fetchType {
  // send notification of the end of the pending fetcher
  //
  // we always expect either fetcher or pendingFetcher_ to be nil when
  // this is called
  BOOL isStopping = (fetcher != pendingFetcher_);
  if (isStopping) {
    NSString *oldType = [pendingFetcher_ propertyForKey:kGDataOAuthFetchTypeKey];
    if (oldType) {
      [self notifyFetchIsRunning:NO
                            type:oldType];
    }
  }

  BOOL isStarting = (fetcher != nil);
  if (isStarting) {
    [self notifyFetchIsRunning:YES
                          type:fetchType];
    [fetcher setProperty:fetchType
                  forKey:kGDataOAuthFetchTypeKey];
  }

  [pendingFetcher_ autorelease];
  pendingFetcher_ = [fetcher retain];
}

@end

#endif // #if MAC_OS_X_VERSION_MIN_REQUIRED

#endif // #if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_OAUTH
