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
// OAuthSampleRootViewControllerTouch.m

#import "OAuthSampleRootViewControllerTouch.h"
#import "GDataOAuthViewControllerTouch.h"

static NSString *const kAppServiceName = @"OAuth Sample: Google Contacts";
static NSString *const kShouldSaveInKeychainKey = @"shouldSaveInKeychain";

@interface OAuthSampleRootViewControllerTouch()
- (void)incrementNetworkActivity:(NSNotification *)notify;
- (void)decrementNetworkActivity:(NSNotification *)notify;
- (void)doAnAuthenticatedAPIFetch;
- (BOOL)shouldSaveInKeychain;
@end

@implementation OAuthSampleRootViewControllerTouch

@synthesize serviceSegments = mServiceSegments;
@synthesize shouldSaveInKeychainSwitch = mShouldSaveInKeychainSwitch;
@synthesize signInOutButton = mSignInOutButton;
@synthesize tokenField = mTokenField;

- (void)awakeFromNib {
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self selector:@selector(incrementNetworkActivity:) name:kGDataOAuthFetchStarted object:nil];
  [nc addObserver:self selector:@selector(decrementNetworkActivity:) name:kGDataOAuthFetchStopped object:nil];

  // Get the saved authentication, if any, from the keychain.
  GDataOAuthAuthentication *auth;
  auth = [GDataOAuthViewControllerTouch authForInstalledAppFromKeychainForApplicationServiceName:kAppServiceName];
  [self setAuthentication:auth];

  BOOL isRemembering = [self shouldSaveInKeychain];
  [mShouldSaveInKeychainSwitch setOn:isRemembering];
  [self updateUI];
}

- (void)dealloc {
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc removeObserver:self];
  [mSignInOutButton release];
  [mShouldSaveInKeychainSwitch release];
  [mServiceSegments release];
  [mTokenField release];
  [mAuth release];
  [super dealloc];
}

- (BOOL)isSignedIn {
  BOOL isSignedIn = [mAuth canAuthorize];
  return isSignedIn;
}

- (BOOL)isGoogleSegmentSelected {
  int segmentIndex = [mServiceSegments selectedSegmentIndex];
  return (segmentIndex == 0);
}

- (IBAction)signInOutClicked:(id)sender {
  if (![self isSignedIn]) {
    // sign in
    if ([self isGoogleSegmentSelected]) {
      [self signInToGoogle];
    } else {
      [self signInToTwitter];
    }
  } else {
    // sign out
    [self signOut];
  }
  [self updateUI];
}

// UISwitch does the toggling for us. We just need to read the state.
- (IBAction)toggleShouldSaveInKeychain:(id)sender {
  [[NSUserDefaults standardUserDefaults] setBool:[sender isOn]
                                          forKey:kShouldSaveInKeychainKey];
}

- (void)signOut {
  // Remove the stored authentication from the keychain.
  [GDataOAuthViewControllerTouch removeParamsFromKeychainForApplicationServiceName:kAppServiceName];

  [GDataOAuthViewControllerTouch revokeTokenForGoogleAuthentication:mAuth];

  // Discard our retained authentication object.
  [self setAuthentication:nil];

  [self updateUI];
}

- (void)signInToGoogle {
  [self signOut];

  NSString *keychainAppServiceName = nil;
  if ([self shouldSaveInKeychain]) {
    keychainAppServiceName = kAppServiceName;
  }

  // For GData applications, the scope is available as
  //   NSString *scope = [[service class] authorizationScope]
  NSString *scope = @"http://www.google.com/m8/feeds/";

  // ### Important ###
  // GDataOAuthViewControllerTouch is not designed to be reused. Make a new
  // one each time you are going to show it.

  // Display the autentication view.
  GDataOAuthViewControllerTouch *viewController = [[[GDataOAuthViewControllerTouch alloc]
            initWithScope:scope
                 language:nil
           appServiceName:keychainAppServiceName
                 delegate:self
         finishedSelector:@selector(viewController:finishedWithAuth:error:)] autorelease];

  // You can set the title of the navigationItem of the controller here, if you want.

  [[self navigationController] pushViewController:viewController animated:YES];
}

- (void)signInToTwitter {
  // Note: to use this sample, you need to fill in a valid consumer key and
  // consumer secret provided by Twitter for their API
  //
  // http://twitter.com/apps/
  NSString *myConsumerKey = @"";
  NSString *myConsumerSecret = @"";

  if ([myConsumerKey length] == 0 || [myConsumerSecret length] == 0) {
    // perhaps display something friendlier in the UI?
    NSAssert(NO, @"A valid consumer key and consumer secret are required for signing in to Twitter");
    return;
  }

  [self signOut];
  NSURL *requestURL = [NSURL URLWithString:@"http://twitter.com/oauth/request_token"];
  NSURL *authorizeURL = [NSURL URLWithString:@"http://twitter.com/oauth/authorize"];
  NSURL *accessURL = [NSURL URLWithString:@"http://twitter.com/oauth/access_token"];
  NSString *scope = @"http://api.twitter.com/";

  GDataOAuthAuthentication *auth;
  auth = [[[GDataOAuthAuthentication alloc] initWithSignatureMethod:kGDataOAuthSignatureMethodHMAC_SHA1
                                                        consumerKey:myConsumerKey
                                                         privateKey:myConsumerSecret] autorelease];
  [auth setCallback:@"http://www.google.com/OAuthCallback"];

  NSString *keychainAppServiceName = nil;
  if ([self shouldSaveInKeychain]) {
    keychainAppServiceName = kAppServiceName;
  }

  // Display the autentication view.
  GDataOAuthViewControllerTouch *viewController;
  viewController = [[[GDataOAuthViewControllerTouch alloc] initWithScope:scope
                language:nil
         requestTokenURL:requestURL
       authorizeTokenURL:authorizeURL
          accessTokenURL:accessURL
          authentication:auth
          appServiceName:keychainAppServiceName
                delegate:self
        finishedSelector:@selector(viewController:finishedWithAuth:error:)] autorelease];

  // You can set the title of the navigationItem of the controller here, if you want.

  [[self navigationController] pushViewController:viewController animated:YES];
}

- (void)viewController:(GDataOAuthViewControllerTouch *)viewController
      finishedWithAuth:(GDataOAuthAuthentication *)auth
                 error:(NSError *)error {
  if (error != nil) {
    // Authentication failed (perhaps the user denied access, or closed the
    // window before granting access)
    NSLog(@"Authentication error: %@", error);
    NSData *responseData = [[error userInfo] objectForKey:@"data"]; // kGDataHTTPFetcherStatusDataKey
    if ([responseData length] > 0) {
      // show the body of the server's authentication failure response
      NSString *str = [[[NSString alloc] initWithData:responseData
                                             encoding:NSUTF8StringEncoding] autorelease];
      NSLog(@"%@", str);
    }

    [self setAuthentication:nil];
  } else {
    // Authentication succeeded
    //
    // At this point, we either use the authentication object to explicitly
    // authorize requests, like
    //
    //   [auth authorizeRequest:myNSURLMutableRequest]
    //
    // or store the authentication object into a GData service object like
    //
    //   [[self contactService] setAuthorizer:auth];

    // save the authentication object
    [self setAuthentication:auth];

    // Just to prove we're signed in, we'll attempt an authenticated fetch for the
    // signed-in user
    [self doAnAuthenticatedAPIFetch];
  }

  [self updateUI];
}

- (void)doAnAuthenticatedAPIFetch {
  NSString *urlStr;
  if ([self isGoogleSegmentSelected]) {
    // Google Contacts feed
    urlStr = @"http://www.google.com/m8/feeds/contacts/default/thin";
  } else {
    // Twitter status feed
    urlStr = @"http://api.twitter.com/1/statuses/home_timeline.json";
  }

  NSURL *url = [NSURL URLWithString:urlStr];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [mAuth authorizeRequest:request];

  // Synchronous fetches like this are a really bad idea in Cocoa applications
  //
  // For a very easy async alternative, we could use GDataHTTPFetcher
  NSError *error = nil;
  NSURLResponse *response = nil;
  NSData *data = [NSURLConnection sendSynchronousRequest:request
                                       returningResponse:&response
                                                   error:&error];
  if (data) {
    // API fetch succeeded
    NSString *str = [[[NSString alloc] initWithData:data
                                           encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"API response: %@", str);
  } else {
    // fetch failed
    NSLog(@"API fetch error: %@", error);
  }
}

#pragma mark -

- (void)incrementNetworkActivity:(NSNotification *)notify {
  ++mNetworkActivityCounter;
  if (1 == mNetworkActivityCounter) {
    UIApplication *app = [UIApplication sharedApplication];
    [app setNetworkActivityIndicatorVisible:YES];
  }
}

- (void)decrementNetworkActivity:(NSNotification *)notify {
  --mNetworkActivityCounter;
  if (0 == mNetworkActivityCounter) {
    UIApplication *app = [UIApplication sharedApplication];
    [app setNetworkActivityIndicatorVisible:NO];
  }
}

#pragma mark -

- (void)updateUI {
  // update the text showing the signed-in state and the button title
  // A real program would use NSLocalizedString() for strings shown to the user.
  if ([self isSignedIn]) {
    // signed in
    [mTokenField setText:[mAuth token]];
    [mSignInOutButton setTitle:@"Sign Out"];
  } else {
    // signed out
    [mTokenField setText:@"Not signed in"];
    [mSignInOutButton setTitle:@"Sign In..."];
  }
  BOOL isRemembering = [self shouldSaveInKeychain];
  [mShouldSaveInKeychainSwitch setOn:isRemembering];
}

- (void)setAuthentication:(GDataOAuthAuthentication *)auth {
  [mAuth autorelease];
  mAuth = [auth retain];
}

- (BOOL)shouldSaveInKeychain {
  return [[NSUserDefaults standardUserDefaults] boolForKey:kShouldSaveInKeychainKey];
}

@end

