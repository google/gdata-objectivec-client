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

//
// GDataOAuthViewControllerTouch.m
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_OAUTH

#if TARGET_OS_IPHONE

// If you want to shave a few bytes, and you include GDataOAuthViewTouch.xib
// in your project, then you can define this as 0 in your prefix file.
#ifndef GDATA_CONSTRUCT_OAUTH_VIEWS_IN_SOURCE_CODE
#define GDATA_CONSTRUCT_OAUTH_VIEWS_IN_SOURCE_CODE 1
#endif

#define GDATAOAUTHVIEWCONTROLLERTOUCH_DEFINE_GLOBALS 1
#import "GDataOAuthViewControllerTouch.h"

#import "GDataOAuthSignIn.h"
#import "GDataOAuthAuthentication.h"

static NSString * const kGDataOAuthAccountName = @"OAuth";
static GDataOAuthKeychain* sDefaultKeychain = nil;

// If the Interface Builder .xib is compiled in to the app, it overrides this code.
#if GDATA_CONSTRUCT_OAUTH_VIEWS_IN_SOURCE_CODE
// Wrappers for calls deprecated in 3.0
@interface UIButton(GDataOAuthViewControllerTouch)
- (void)oauthCompatibilitySetFont:(UIFont *)font;
- (void)oauthCompatibilitySetTitleShadowOffset:(CGSize)offset;
@end


@implementation UIButton(GDataOAuthViewControllerTouch)
- (void)oauthCompatibilitySetFont:(UIFont *)font {
  id label = self;
  if ([self respondsToSelector:@selector(titleLabel)]) {
   label = [self performSelector:@selector(titleLabel)];
  }
  // OK to send to button in 2.0, but prefer sending to label.
  [label setFont:font];
}

- (void)oauthCompatibilitySetTitleShadowOffset:(CGSize)offset {
  id label = self;
  if ([self respondsToSelector:@selector(titleLabel)]) {
    label = [self performSelector:@selector(titleLabel)];
  }
  // OK to send to button in 2.0, but prefer sending to label.
  [label setShadowOffset:offset];
}
@end

#endif // GDATA_CONSTRUCT_OAUTH_VIEWS_IN_SOURCE_CODE


@interface GDataOAuthViewControllerTouch()

@property (nonatomic, copy) NSURLRequest *request;

- (void)signIn:(GDataOAuthSignIn *)signIn displayRequest:(NSURLRequest *)request;
- (void)signIn:(GDataOAuthSignIn *)signIn
finishedWithAuth:(GDataOAuthAuthentication *)auth
         error:(NSError *)error;  
- (BOOL)isNavigationBarTranslucent;
- (void)moveWebViewFromUnderNavigationBar;
- (void)popView;
- (void)clearBrowserCookies;
@end

@implementation GDataOAuthViewControllerTouch

@synthesize request = request_;
@synthesize backButton = backButton_;
@synthesize forwardButton = forwardButton_;
@synthesize navButtonsView = navButtonsView_;
@synthesize rightBarButtonItem = rightBarButtonItem_;
@synthesize keychainApplicationServiceName = keychainApplicationServiceName_;
@synthesize initialHTMLString = initialHTMLString_;
@synthesize browserCookiesURL = browserCookiesURL_;
@synthesize signIn = signIn_;
@synthesize userData = userData_;
@synthesize webView = webView_;

- (id)initWithScope:(NSString *)scope
           language:(NSString *)language
     appServiceName:(NSString *)keychainAppServiceName
           delegate:(id)delegate
   finishedSelector:(SEL)finishedSelector {
  // convenient entry point for Google authentication
  return [self initWithScope:scope
                    language:language
             requestTokenURL:nil
           authorizeTokenURL:nil
              accessTokenURL:nil
              authentication:nil
              appServiceName:keychainAppServiceName
                    delegate:(id)delegate
            finishedSelector:(SEL)finishedSelector];
}

- (id)initWithScope:(NSString *)scope
           language:(NSString *)language
    requestTokenURL:(NSURL *)requestURL
  authorizeTokenURL:(NSURL *)authorizeURL
     accessTokenURL:(NSURL *)accessURL
     authentication:(GDataOAuthAuthentication *)auth
     appServiceName:(NSString *)keychainAppServiceName
           delegate:(id)delegate
   finishedSelector:(SEL)finishedSelector {

  NSString *nibName = [[self class] authNibName];

  self = [super initWithNibName:nibName bundle:nil];
  if (self != nil) {
    delegate_ = [delegate retain];
    finishedSelector_ = finishedSelector;

    if (auth) {
      [auth setScope:scope];

      // use the supplied auth and OAuth endpoint URLs
      signIn_ = [[GDataOAuthSignIn alloc] initWithAuthentication:auth
                                                 requestTokenURL:requestURL
                                               authorizeTokenURL:authorizeURL
                                                  accessTokenURL:accessURL
                                                        delegate:self
                                              webRequestSelector:@selector(signIn:displayRequest:)
                                                finishedSelector:@selector(signIn:finishedWithAuth:error:)];
    } else {
      // use default Google auth and endpoint values
      signIn_ = [[GDataOAuthSignIn alloc] initWithGoogleAuthenticationForScope:scope
                                                                      language:language
                                                                      delegate:self
                                                            webRequestSelector:@selector(signIn:displayRequest:)
                                                              finishedSelector:@selector(signIn:finishedWithAuth:error:)];
    }

    // the display name defaults to the bundle's name
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *displayName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if ([displayName length] == 0) {
      displayName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
      if ([displayName length] == 0) {
        displayName = [[bundle executablePath] lastPathComponent];
      }
    }
    [self setDisplayName:displayName];

    // if the user is signing in to a Google service, we'll delete the
    // Google authentication browser cookies upon completion
    //
    // for other service domains, or to disable clearing of the cookies,
    // set the browserCookiesURL property explicitly
    NSString *authorizationHost = [[signIn_ authorizeTokenURL] host];
    if ([authorizationHost isEqual:@"www.google.com"]) {
      NSURL *cookiesURL = [NSURL URLWithString:@"https://www.google.com/accounts"];
      [self setBrowserCookiesURL:cookiesURL];
    }

    [self setKeychainApplicationServiceName:keychainAppServiceName];
  }
  return self;
}

- (void)dealloc {
  [backButton_ release];
  [forwardButton_ release];
  [navButtonsView_ release];
  [rightBarButtonItem_ release];
  [signIn_ setDelegate:nil];
  [signIn_ release];
  [request_ release];
  [delegate_ release];
  [keychainApplicationServiceName_ release];
  [initialHTMLString_ release];
  [userData_ release];
  [webView_ release];
  [super dealloc];
}

+ (NSString *)authNibName {
  // subclasses may override this to specify a custom nib name
  return @"GDataOAuthViewTouch";
}

+ (GDataOAuthAuthentication *)authForGoogleFromKeychainForName:(NSString *)appServiceName {
  GDataOAuthAuthentication *newAuth = [GDataOAuthAuthentication authForInstalledApp];
  [self authorizeFromKeychainForName:appServiceName
                      authentication:newAuth];
  return newAuth;
}

+ (BOOL)authorizeFromKeychainForName:(NSString *)appServiceName
                      authentication:(GDataOAuthAuthentication *)newAuth {
  [newAuth setToken:nil];
  [newAuth setHasAccessToken:NO];

  BOOL didGetTokens = NO;
  GDataOAuthKeychain *keychain = [GDataOAuthKeychain defaultKeychain];
  NSString *password = [keychain passwordForService:appServiceName
                                            account:kGDataOAuthAccountName
                                              error:nil];
  if (password != nil) {
    [newAuth setKeysForResponseString:password];
    [newAuth setHasAccessToken:YES];
    didGetTokens = YES;
  }
  return didGetTokens;
}

+ (BOOL)removeParamsFromKeychainForName:(NSString *)appServiceName {
  GDataOAuthKeychain *keychain = [GDataOAuthKeychain defaultKeychain];
  return [keychain removePasswordForService:appServiceName
                                    account:kGDataOAuthAccountName
                                      error:nil];
}

+ (BOOL)saveParamsToKeychainForName:(NSString *)appServiceName
                     authentication:(GDataOAuthAuthentication *)auth {
  [self removeParamsFromKeychainForName:appServiceName];
  // don't save unless we have a token that can really authorize requests
  if (![auth hasAccessToken]) return NO;

  // make a response string containing the values we want to save
  NSString *password = [auth persistenceResponseString];
  GDataOAuthKeychain *keychain = [GDataOAuthKeychain defaultKeychain];
  return [keychain setPassword:password
                    forService:appServiceName
                       account:kGDataOAuthAccountName
                         error:nil];
}



- (void)constructView {
// If the Interface Builder .xib is compiled in to the app, it overrides this code.
#if GDATA_CONSTRUCT_OAUTH_VIEWS_IN_SOURCE_CODE
  static const int kButtonFontHeight = 26;
  static const int kButtonHeight = 30;
  static const int kButtonXMargin = 6;
  static const int kButtonWidth = 30;
  CGRect webFrame = [[UIScreen mainScreen] applicationFrame];
  UIView *view = [[[UIView  alloc] initWithFrame:webFrame] autorelease];
  [view setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleHeight |
        UIViewAutoresizingFlexibleBottomMargin];
  webFrame.origin = CGPointZero;
  UIWebView *webView = [[[UIWebView alloc] initWithFrame:webFrame] autorelease];
  [webView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleHeight |
        UIViewAutoresizingFlexibleBottomMargin];
  [self setView:view];
  [view addSubview:webView];
  [self setWebView:webView];
  [webView setDelegate:self];

  UIColor *normalColor = [UIColor colorWithWhite:1.0 alpha:1.0];
  UIColor *dimColor = [UIColor colorWithRed:152./255. green:175./255. blue:243./255. alpha:0.6];

  UIFont *buttonFont = [UIFont boldSystemFontOfSize:kButtonFontHeight];
  CGRect backButtonFrame = CGRectMake(0, 0, kButtonWidth, kButtonHeight);
  UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [backButton setFrame:backButtonFrame];
  [backButton oauthCompatibilitySetFont:buttonFont];
  [backButton setTitleColor:normalColor forState:UIControlStateNormal];
  [backButton setTitleColor:dimColor forState:UIControlStateDisabled];
  [backButton oauthCompatibilitySetTitleShadowOffset:CGSizeMake(0, -2)];
  NSString *backTriangle = [NSString stringWithFormat:@"%C", 0x25C0];
  [backButton setTitle:backTriangle forState:UIControlStateNormal];
  [backButton addTarget:webView
                 action:@selector(goBack)
       forControlEvents:UIControlEventTouchUpInside];
  [backButton setEnabled:NO];
  [self setBackButton:backButton];

  CGRect forwardButtonFrame =
    CGRectMake(kButtonWidth+kButtonXMargin, 0, kButtonWidth, kButtonHeight);
  UIButton *forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [forwardButton setFrame:forwardButtonFrame];
  [forwardButton oauthCompatibilitySetFont:buttonFont];
  [forwardButton setTitleColor:normalColor forState:UIControlStateNormal];
  [forwardButton setTitleColor:dimColor forState:UIControlStateDisabled];
  [forwardButton oauthCompatibilitySetTitleShadowOffset:CGSizeMake(0, -2)];
  NSString *forwardTriangle = [NSString stringWithFormat:@"%C", 0x25B6];
  [forwardButton setTitle:forwardTriangle forState:UIControlStateNormal];
  [forwardButton addTarget:webView
                    action:@selector(goForward)
          forControlEvents:UIControlEventTouchUpInside];
  [forwardButton setEnabled:NO];
  [self setForwardButton:forwardButton];

  CGRect navFrame =
    CGRectMake(0, 0, kButtonXMargin + 2*kButtonWidth, kButtonHeight);
  UIView *navButtonsView = [[[UIView alloc] initWithFrame:navFrame] autorelease];
  [navButtonsView setBackgroundColor:[UIColor clearColor]];
  [navButtonsView addSubview:backButton];
  [navButtonsView addSubview:forwardButton];
  [self setNavButtonsView:navButtonsView];

  UIBarButtonItem *rightBarButtonItem =
    [[[UIBarButtonItem alloc] initWithCustomView:navButtonsView] autorelease];
  [self setRightBarButtonItem:rightBarButtonItem];
  [[self navigationItem] setRightBarButtonItem:rightBarButtonItem];
#endif
}

- (void)loadView {
  NSString *nibPath = nil;
  NSBundle *nibBundle = [self nibBundle];
  if (nibBundle == nil) {
    nibBundle = [NSBundle mainBundle];
  }
  NSString *nibName = [self nibName];
  if (nibName != nil) {
    nibPath = [nibBundle pathForResource:nibName ofType:@"nib"];
  }
  if (nibPath != nil && [[NSFileManager defaultManager] fileExistsAtPath:nibPath]) {
    [super loadView];
  } else {
    [self constructView];
  }
}


- (void)viewDidLoad {
  // the app may prefer some html other than blank white to be displayed
  // before the sign-in web page loads
  NSString *html = [self initialHTMLString];
  if ([html length] > 0) {
    [[self webView] loadHTMLString:html baseURL:nil];
  }

  [rightBarButtonItem_ setCustomView:navButtonsView_];
  [[self navigationItem] setRightBarButtonItem:rightBarButtonItem_];
}

- (void)popView {
  if ([[self navigationController] topViewController] == self) {
    if (![[self view] isHidden]) {
      // set the flag to our viewWillDisappear method so it knows
      // this is a disappearance initiated by the sign-in object,
      // not the user cancelling via the navigation controller
      isPoppingSelf_ = YES;

      [[self navigationController] popViewControllerAnimated:YES];
      [[self view] setHidden:YES];

      isPoppingSelf_ = NO;
    }
  }
}

- (void)cancelSigningIn {
  // The application has explicitly asked us to cancel signing in
  // (so no further callback is required)
  hasCalledFinished_ = YES;

  [delegate_ autorelease];
  delegate_ = nil;

  // The sign-in object's cancel method will close the window
  [signIn_ cancelSigningIn];
  hasDoneFinalRedirect_ = YES;
}

#pragma mark Token Revocation

+ (void)revokeTokenForGoogleAuthentication:(GDataOAuthAuthentication *)auth {
  [GDataOAuthSignIn revokeTokenForGoogleAuthentication:auth];
}

#pragma mark Browser Cookies

- (void)clearBrowserCookies {
  // if browserCookiesURL is non-nil, then get cookies for that URL
  // and delete them from the common application cookie storage
  NSURL *cookiesURL = [self browserCookiesURL];
  if (cookiesURL) {
    NSHTTPCookieStorage *cookieStorage;

    cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies =  [cookieStorage cookiesForURL:cookiesURL];

    for (NSHTTPCookie *cookie in cookies) {
      [cookieStorage deleteCookie:cookie];
    }
  }
}

#pragma mark Accessors

- (void)setDisplayName:(NSString *)displayName {
  GDataOAuthAuthentication *auth = [self authentication];
  [auth setDisplayName:displayName];
}

- (NSString *)displayName {
  return [[self authentication] displayName];
}

- (GDataOAuthAuthentication *)authentication {
  GDataOAuthAuthentication *auth = [signIn_ authentication];
  return auth;
}

- (void)setNetworkLossTimeoutInterval:(NSTimeInterval)val {
  [signIn_ setNetworkLossTimeoutInterval:val];
}

- (NSTimeInterval)networkLossTimeoutInterval {
  return [signIn_ networkLossTimeoutInterval];
}

- (BOOL)shouldUseKeychain {
  BOOL hasName = ([keychainApplicationServiceName_ length] > 0);
  return hasName;
}

#pragma mark SignIn callbacks

- (void)signIn:(GDataOAuthSignIn *)signIn displayRequest:(NSURLRequest *)request {
  // this is the signIn object's webRequest method, telling the controller
  // to either display the request in the webview, or close the window
  //
  // All web requests and all window closing goes through this routine

#if DEBUG
  if ([self navigationController]) {
    if ([[self navigationController] topViewController] != self && request != nil) {
      NSLog(@"Unexpected: Request to show, when already on top. request %@", [request URL]);
    } else if([[self navigationController] topViewController] != self && request == nil) {
      NSLog(@"Unexpected: Request to pop, when not on top. request nil");
    }
  }
#endif

  if (request != nil) {
    // Display the request.
    [self setRequest:request];
    [[self webView] loadRequest:[self request]];
  } else {
    // request was nil.
    [self popView];
  }
}

- (void)signIn:(GDataOAuthSignIn *)signIn
  finishedWithAuth:(GDataOAuthAuthentication *)auth
             error:(NSError *)error {
  if (!hasCalledFinished_) {
    hasCalledFinished_ = YES;

    if (error == nil) {
      BOOL shouldUseKeychain = [self shouldUseKeychain];
      if (shouldUseKeychain) {
        NSString *appServiceName = [self keychainApplicationServiceName];
        if ([auth canAuthorize]) {
          // save the auth params in the keychain
          [[self class] saveParamsToKeychainForName:appServiceName authentication:auth];
        } else {
          // remove the auth params from the keychain
          [[self class] removeParamsFromKeychainForName:appServiceName];
        }
      }
    }

    if (delegate_ && finishedSelector_) {
      SEL sel = finishedSelector_;
      NSMethodSignature *sig = [delegate_ methodSignatureForSelector:sel];
      NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
      [invocation setSelector:sel];
      [invocation setTarget:delegate_];
      [invocation setArgument:&self atIndex:2];
      [invocation setArgument:&auth atIndex:3];
      [invocation setArgument:&error atIndex:4];
      [invocation invoke];
    }

    [delegate_ autorelease];
    delegate_ = nil;
  }
}

- (void)moveWebViewFromUnderNavigationBar {
  CGRect dontCare;
  CGRect webFrame = [[self view] bounds];
  UINavigationBar *navigationBar = [[self navigationController] navigationBar];
  CGRectDivide(webFrame, &dontCare, &webFrame,
    [navigationBar frame].size.height, CGRectMinYEdge);
  [[self webView] setFrame:webFrame];
}

// isTranslucent is defined in iPhoneOS 3.0 on.
- (BOOL)isNavigationBarTranslucent {
  UINavigationBar *navigationBar = [[self navigationController] navigationBar];
  BOOL isTranslucent =
    ([navigationBar respondsToSelector:@selector(isTranslucent)] &&
     [navigationBar isTranslucent]);
  return isTranslucent;
}

#pragma mark -
#pragma mark Protocol implementations

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  if (!isViewShown_) {
    isViewShown_ = YES;
    if ([self isNavigationBarTranslucent]) {
      [self moveWebViewFromUnderNavigationBar];
    }
    if (![signIn_ startSigningIn]) {
      // Can't start signing in. We must pop our view.
      // UIWebview needs time to stabilize. Animations need time to complete.
      // We remove ourself from the view stack after that.
      [self performSelector:@selector(popView) withObject:nil afterDelay:0.5];
    }
  }
  [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  if (!isPoppingSelf_) {
    // we are not popping ourselves, so presumably we are being popped by the
    // navigation controller; tell the sign-in object to close up shop
    //
    // this will indirectly call our signIn:finishedWithAuth:error: method
    // for us
    [signIn_ windowWasClosed];
  }

  // prevent the next sign-in from showing in the WebView that the user is
  // already signed in
  [self clearBrowserCookies];

  [super viewWillDisappear:animated];
}

- (BOOL)webView:(UIWebView *)webView
  shouldStartLoadWithRequest:(NSURLRequest *)request
              navigationType:(UIWebViewNavigationType)navigationType {

  if (!hasDoneFinalRedirect_) {
    hasDoneFinalRedirect_ = [signIn_ requestRedirectedToRequest:request];
    if (hasDoneFinalRedirect_) {
      // signIn has told the view to close
      return NO;
    }
  }
  return YES;
}

- (void)updateUI {
  [backButton_ setEnabled:[[self webView] canGoBack]];
  [forwardButton_ setEnabled:[[self webView] canGoForward]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
  [self updateUI];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  [self updateUI];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  BOOL value = YES;
  if (!isInsideShouldAutorotateToInterfaceOrientation_) {
    isInsideShouldAutorotateToInterfaceOrientation_ = YES;
    UIViewController *navigationController = [self navigationController];
    if (navigationController != nil) {
      value = [navigationController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    } else {
      value = [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    }
    isInsideShouldAutorotateToInterfaceOrientation_ = NO;
  }
  return value;
}


@end


#pragma mark Common Code

@implementation GDataOAuthKeychain

+ (GDataOAuthKeychain *)defaultKeychain {
  if (sDefaultKeychain == nil) {
    sDefaultKeychain = [[self alloc] init];
  }
  return sDefaultKeychain;
}


// For unit tests: allow setting a mock object
+ (void)setDefaultKeychain:(GDataOAuthKeychain *)keychain {
  if (sDefaultKeychain != keychain) {
    [sDefaultKeychain release];
    sDefaultKeychain = [keychain retain];
  }
}

- (NSString *)keyForService:(NSString *)service account:(NSString *)account {
  return [NSString stringWithFormat:@"com.google.GDataOAuth.%@%@", service, account];
}

// The Keychain API isn't available on the iPhone simulator in SDKs before 3.0,
// so, on early simulators we use a fake API, that just writes, unencrypted, to
// NSUserDefaults.
#if TARGET_IPHONE_SIMULATOR && __IPHONE_OS_VERSION_MAX_ALLOWED < 30000
#pragma mark Simulator

// Simulator - just simulated, not secure.
- (NSString *)passwordForService:(NSString *)service account:(NSString *)account error:(NSError **)error {
  NSString *result = nil;
  if (0 < [service length] && 0 < [account length]) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [self keyForService:service account:account];
    result = [defaults stringForKey:key];
    if (result == nil && error != NULL) {
      *error = [NSError errorWithDomain:kGDataOAuthKeychainErrorDomain
                                   code:kGDataOAuthKeychainErrorNoPassword
                               userInfo:nil];
    }
  } else if (error != NULL) {
    *error = [NSError errorWithDomain:kGDataOAuthKeychainErrorDomain
                                 code:kGDataOAuthKeychainErrorBadArguments
                             userInfo:nil];
  }
  return result;

}


// Simulator - just simulated, not secure.
- (BOOL)removePasswordForService:(NSString *)service account:(NSString *)account error:(NSError **)error {
  BOOL didSucceed = NO;
  if (0 < [service length] && 0 < [account length]) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [self keyForService:service account:account];
    [defaults removeObjectForKey:key];
    [defaults synchronize];
  } else if (error != NULL) {
    *error = [NSError errorWithDomain:kGDataOAuthKeychainErrorDomain
                                 code:kGDataOAuthKeychainErrorBadArguments
                             userInfo:nil];
  }
  return didSucceed;
}

// Simulator - just simulated, not secure.
- (BOOL)setPassword:(NSString *)password
         forService:(NSString *)service
            account:(NSString *)account
              error:(NSError **)error {
  BOOL didSucceed = NO;
  if (0 < [password length] && 0 < [service length] && 0 < [account length]) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [self keyForService:service account:account];
    [defaults setObject:password forKey:key];
    [defaults synchronize];
    didSucceed = YES;
  } else if (error != NULL) {
    *error = [NSError errorWithDomain:kGDataOAuthKeychainErrorDomain
                                 code:kGDataOAuthKeychainErrorBadArguments
                             userInfo:nil];
  }
  return didSucceed;
}

#else // ! TARGET_IPHONE_SIMULATOR
#pragma mark Device

+ (NSMutableDictionary *)keychainQueryForService:(NSString *)service account:(NSString *)account {
  NSMutableDictionary *query = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         (id)kSecClassGenericPassword, (id)kSecClass,
                         @"OAuth", (id)kSecAttrGeneric,
                         account, (id)kSecAttrAccount,
                         service, (id)kSecAttrService,
                         nil];
  return query;
}

- (NSMutableDictionary *)keychainQueryForService:(NSString *)service account:(NSString *)account {
  return [[self class] keychainQueryForService:service account:account];
}



// iPhone
- (NSString *)passwordForService:(NSString *)service account:(NSString *)account error:(NSError **)error {
  OSStatus status = kGDataOAuthKeychainErrorBadArguments;
  NSString *result = nil;
  if (0 < [service length] && 0 < [account length]) {
    CFDataRef passwordData = NULL;
    NSMutableDictionary *keychainQuery = [self keychainQueryForService:service account:account];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];

    status = SecItemCopyMatching((CFDictionaryRef)keychainQuery,
                                 (CFTypeRef *)&passwordData);
    if (status == noErr && 0 < [(NSData *)passwordData length]) {
      result = [[[NSString alloc] initWithData:(NSData *)passwordData
                                      encoding:NSUTF8StringEncoding] autorelease];
    }
    if (passwordData != NULL) {
      CFRelease(passwordData);
    }
  }
  if (status != noErr && error != NULL) {
    *error = [NSError errorWithDomain:kGDataOAuthKeychainErrorDomain
                                 code:status
                             userInfo:nil];
  }
  return result;
}


// iPhone
- (BOOL)removePasswordForService:(NSString *)service account:(NSString *)account error:(NSError **)error {
  OSStatus status = kGDataOAuthKeychainErrorBadArguments;
  if (0 < [service length] && 0 < [account length]) {
    NSMutableDictionary *keychainQuery = [self keychainQueryForService:service account:account];
    status = SecItemDelete((CFDictionaryRef)keychainQuery);
  }
  if (status != noErr && error != NULL) {
    *error = [NSError errorWithDomain:kGDataOAuthKeychainErrorDomain
                                 code:status
                             userInfo:nil];
  }
  return status == noErr;
}

// iPhone
- (BOOL)setPassword:(NSString *)password
         forService:(NSString *)service
            account:(NSString *)account
              error:(NSError **)error {
  OSStatus status = kGDataOAuthKeychainErrorBadArguments;
  if (0 < [service length] && 0 < [account length]) {
    [self removePasswordForService:service account:account error:nil];
    if (0 < [password length]) {
      NSMutableDictionary *keychainQuery = [self keychainQueryForService:service account:account];
      NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
      [keychainQuery setObject:passwordData forKey:(id)kSecValueData];
      status = SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
    }
  }
  if (status != noErr && error != NULL) {
    *error = [NSError errorWithDomain:kGDataOAuthKeychainErrorDomain
                                 code:status
                             userInfo:nil];
  }
  return status == noErr;
}

#endif // ! TARGET_IPHONE_SIMULATOR

@end

#endif // TARGET_OS_IPHONE

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_OAUTH
