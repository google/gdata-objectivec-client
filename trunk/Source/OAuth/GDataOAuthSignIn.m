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

// we'll default to timing out if the network becomes unreachable for more
// than 30 seconds when the sign-in page is displayed
const NSTimeInterval kDefaultNetworkLossTimeoutInterval = 30.0;

@interface GDataOAuthSignIn ()
- (void)invokeFinalCallbackWithError:(NSError *)error;

- (void)startWebRequest;
- (void)fetchGoogleUserInfo;

- (GDataHTTPFetcher *)pendingFetcher;
- (void)setPendingFetcher:(GDataHTTPFetcher *)obj fetchType:(NSString *)fetchType;

- (void)requestFetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data;
- (void)requestFetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error;

- (void)accessFetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data;
- (void)accessFetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error;

- (void)infoFetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data;
- (void)infoFetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error;

- (void)closeTheWindow;

- (void)startReachabilityCheck;
- (void)stopReachabilityCheck;
- (void)reachabilityTarget:(SCNetworkReachabilityRef)reachabilityRef
              changedFlags:(SCNetworkConnectionFlags)flags;
- (void)reachabilityTimerFired:(NSTimer *)timer;
@end

@implementation GDataOAuthSignIn

@synthesize delegate = delegate_;
@synthesize authentication = auth_;
@synthesize userData = userData_;

@synthesize requestTokenURL = requestURL_;
@synthesize authorizeTokenURL = authorizeURL_;
@synthesize accessTokenURL = accessURL_;

@synthesize shouldFetchGoogleUserInfo = shouldFetchGoogleUserInfo_;
@synthesize networkLossTimeoutInterval = networkLossTimeoutInterval_;

- (id)initWithGoogleAuthenticationForScope:(NSString *)scope
                                  language:(NSString *)language
                                  delegate:(id)delegate
                        webRequestSelector:(SEL)webRequestSelector
                          finishedSelector:(SEL)finishedSelector {
  // standard Google OAuth endpoints
  //
  // http://code.google.com/apis/accounts/docs/OAuth_ref.html
  NSURL *requestURL = [NSURL URLWithString:@"https://www.google.com/accounts/OAuthGetRequestToken"];
  NSURL *accessURL = [NSURL URLWithString:@"https://www.google.com/accounts/OAuthGetAccessToken"];
  NSURL *authorizeURL = [NSURL URLWithString:@"https://www.google.com/accounts/OAuthAuthorizeToken"];

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

    delegate_ = [delegate retain];
    webRequestSelector_ = webRequestSelector;
    finishedSelector_ = finishedSelector;

    // for Google authentication, we want to automatically fetch user info
    if ([[authorizeURL host] isEqual:@"www.google.com"]) {
      shouldFetchGoogleUserInfo_ = YES;
    }

    // default timeout for a lost internet connection while the server
    // UI is displayed is 30 seconds
    networkLossTimeoutInterval_ = kDefaultNetworkLossTimeoutInterval;
  }
  return self;
}

- (void)dealloc {
  [self stopReachabilityCheck];

  [delegate_ release];
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

  [delegate_ autorelease];
  delegate_ = nil;
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
  [auth_ reset];

  // add the Google-specific scope for obtaining the authenticated user info
  if (shouldFetchGoogleUserInfo_) {
    NSString *uiScope = @"https://www.googleapis.com/auth/userinfo#email";
    NSString *scope = [auth_ scope];
    if ([scope rangeOfString:uiScope].location == NSNotFound) {
      scope = [scope stringByAppendingFormat:@" %@", uiScope];
      [auth_ setScope:scope];
    }
  }

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
  [self startWebRequest];
}

- (void)requestFetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error {
  [self setPendingFetcher:nil fetchType:nil];

  [self invokeFinalCallbackWithError:error];
}

- (void)startWebRequest {
  // if the auth object has a request token, we can proceed
  NSString *token = [auth_ token];
  if ([token length] > 0) {
    // invoke the user's web request selector to display the request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:authorizeURL_];
    [auth_ addAuthorizeTokenParamsToRequest:request];

    [delegate_ performSelector:webRequestSelector_
                    withObject:self
                    withObject:request];

    // at this point, we're waiting on the server-driven html UI, so
    // we want notification if we lose connectivity to the web server
    [self startReachabilityCheck];
  }
}

// entry point for the window controller to tell us that the window
// prematurely closed
- (void)windowWasClosed {
  [self stopReachabilityCheck];

  [pendingFetcher_ stopFetching];
  [self setPendingFetcher:nil fetchType:nil];

  NSError *error = [NSError errorWithDomain:kGDataOAuthErrorDomain
                                       code:kGDataOAuthErrorWindowClosed
                                   userInfo:nil];

  [self invokeFinalCallbackWithError:error];
}

// internal method to tell the window controller to close the window
- (void)closeTheWindow {
  [self stopReachabilityCheck];

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
  if ([callback length] == 0) {
    // with no callback specified for the auth, the window will never
    // automatically close
#if DEBUG
    NSAssert(0, @"GTMOAuthSignIn: No authentication callback specified");
#endif
    return NO;
  }

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

  // we have an access token
  [auth_ setKeysForResponseData:data];
  [auth_ setHasAccessToken:YES];

  if (shouldFetchGoogleUserInfo_
      && [[auth_ serviceProvider] isEqual:kGDataOAuthServiceProviderGoogle]) {
    // fetch the user's information from the Google server
    [self fetchGoogleUserInfo];
  } else {
    // we're not authorizing with Google, so we're done
    [self invokeFinalCallbackWithError:nil];
  }
}

- (void)accessFetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error {
  // failed to get the access token
  [self setPendingFetcher:nil fetchType:nil];
  [self invokeFinalCallbackWithError:error];
}

- (void)fetchGoogleUserInfo {
  // fetch the additional user info
  NSString *infoURLStr = @"https://www.googleapis.com/userinfo/email";
  NSURL *infoURL = [NSURL URLWithString:infoURLStr];

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:infoURL];
  [auth_ authorizeRequest:request];

  GDataHTTPFetcher *fetcher = [GDataHTTPFetcher httpFetcherWithRequest:request];
  [fetcher beginFetchWithDelegate:self
                didFinishSelector:@selector(infoFetcher:finishedWithData:)
                  didFailSelector:@selector(infoFetcher:failedWithError:)];

  [self setPendingFetcher:fetcher fetchType:kGDataOAuthFetchTypeUserInfo];
}

- (void)infoFetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data {
  // we have the authenticated user's info
  if (data) {
    [auth_ setKeysForResponseData:data];
  }

  [self setPendingFetcher:nil fetchType:nil];
  [self invokeFinalCallbackWithError:nil];
}

- (void)infoFetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error {
  // failed to get the authenticated user's info
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
  [delegate_ autorelease];
  delegate_ = nil;
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

#pragma mark Reachability monitoring

static void ReachabilityCallBack(SCNetworkReachabilityRef target,
                                 SCNetworkConnectionFlags flags,
                                 void *info) {
  // pass the flags to the signIn object
  GDataOAuthSignIn *signIn = (GDataOAuthSignIn *)info;

  [signIn reachabilityTarget:target
                changedFlags:flags];
}

- (void)startReachabilityCheck {
  // the user may set the timeout to 0 to skip the reachability checking
  // during display of the sign-in page
  if (networkLossTimeoutInterval_ <= 0.0 || reachabilityRef_ != NULL) {
    return;
  }

  // create a reachability target from the authorization URL, add our callback,
  // and schedule it on the run loop so we'll be notified if the network drops
  const char* host = [[authorizeURL_ host] UTF8String];
  reachabilityRef_ = SCNetworkReachabilityCreateWithName(kCFAllocatorSystemDefault,
                                                         host);
  if (reachabilityRef_) {
    BOOL isScheduled = NO;
    SCNetworkReachabilityContext ctx = { 0, self, NULL, NULL, NULL };

    if (SCNetworkReachabilitySetCallback(reachabilityRef_,
                                         ReachabilityCallBack, &ctx)) {
      if (SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef_,
                                                   CFRunLoopGetCurrent(),
                                                   kCFRunLoopDefaultMode)) {
        isScheduled = YES;
      }
    }

    if (!isScheduled) {
      CFRelease(reachabilityRef_);
      reachabilityRef_ = NULL;
    }
  }
}

- (void)destroyUnreachabilityTimer {
  [networkLossTimer_ invalidate];
  [networkLossTimer_ autorelease];
  networkLossTimer_ = nil;
}

- (void)reachabilityTarget:(SCNetworkReachabilityRef)reachabilityRef
              changedFlags:(SCNetworkConnectionFlags)flags {
  BOOL isConnected = (flags & kSCNetworkFlagsReachable) != 0
    && (flags & kSCNetworkFlagsConnectionRequired) == 0;

  if (isConnected) {
    // server is again reachable
    [self destroyUnreachabilityTimer];

    if (hasNotifiedNetworkLoss_) {
      // tell the user that the network has been found
      NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
      [nc postNotificationName:kGDataOAuthNetworkFound
                        object:self
                      userInfo:nil];
      hasNotifiedNetworkLoss_ = NO;
    }
  } else {
    // the server has become unreachable; start the timer, if necessary
    if (networkLossTimer_ == nil
        && networkLossTimeoutInterval_ > 0
        && !hasNotifiedNetworkLoss_) {
      SEL sel = @selector(reachabilityTimerFired:);
      networkLossTimer_ = [[NSTimer scheduledTimerWithTimeInterval:networkLossTimeoutInterval_
                                                            target:self
                                                          selector:sel
                                                          userInfo:nil
                                                           repeats:NO] retain];
    }
  }
}

- (void)reachabilityTimerFired:(NSTimer *)timer {
  // the user may call [[notification object] cancelSigningIn] to
  // dismiss the sign-in
  if (!hasNotifiedNetworkLoss_) {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:kGDataOAuthNetworkLost
                      object:self
                    userInfo:nil];
    hasNotifiedNetworkLoss_ = YES;
  }

  [self destroyUnreachabilityTimer];
}

- (void)stopReachabilityCheck {
  [self destroyUnreachabilityTimer];

  if (reachabilityRef_) {
    SCNetworkReachabilityUnscheduleFromRunLoop(reachabilityRef_,
                                               CFRunLoopGetCurrent(),
                                               kCFRunLoopDefaultMode);
    SCNetworkReachabilitySetCallback(reachabilityRef_, NULL, NULL);

    CFRelease(reachabilityRef_);
    reachabilityRef_ = NULL;
  }
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
