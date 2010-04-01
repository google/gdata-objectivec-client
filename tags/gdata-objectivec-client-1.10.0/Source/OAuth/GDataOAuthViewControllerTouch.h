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
// GDataOAuthViewControllerTouch.h
//
// This view controller for iPhone handles sign-in via OAuth to Google or
// other services.
//
// This controller is not reusable; create a new instance of this controller
// every time the user will sign in.
//
// Sample usage:
//
//  static NSString *const kAppServiceName = @”My Application: Google Contacts”;
//  NSString *scope = @"http://www.google.com/m8/feeds/";
//
//  GDataOAuthViewControllerTouch *viewController = [[[GDataOAuthViewControllerTouch alloc] initWithScope:scope
//                                                                                               language:nil
//                                                                                         appServiceName:kAppServiceName
//                                                                                               delegate:self
//                                                                                       finishedSelector:@selector(viewController:finishedWithAuth:error:)] autorelease];
//  [[self navigationController] pushViewController:viewController
//                                         animated:YES];
//
// The finished selector should have a signature matching this:
//
//  - (void)windowController:(GDataOAuthWindowController *)windowController
//          finishedWithAuth:(GDataOAuthAuthentication *)auth
//                     error:(NSError *)error {
//    if (error != nil) {
//     // sign in failed
//    } else {
//     // sign in succeeded
//     //
//     // with the GData library, pass the authentication to the service object,
//     // like
//     //   [[self contactService] setAuthorizer:auth];
//     //
//     // or use it to sign a request directly, like
//     //    [auth authorizeRequest:myNSURLMutableRequest]
//    }
//  }
//
// To sign in to services other than Google, use the longer init method,
// as shown in the sample application

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_OAUTH

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

#import "GDataOAuthAuthentication.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAOAUTHVIEWCONTROLLERTOUCH_DEFINE_GLOBALS
#define _EXTERN
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataOAuthKeychainErrorDomain       _INITIALIZE_AS(@"com.google.GDataOAuthKeychain");


@class GDataOAuthSignIn;

@interface GDataOAuthViewControllerTouch : UIViewController<UINavigationControllerDelegate, UIWebViewDelegate> {
 @private
  UIButton *backButton_;
  UIButton *forwardButton_;
  UIView *navButtonsView_;
  UIBarButtonItem *rightBarButtonItem_;
  // The object responsible for the sign-in networking sequence; it holds
  // onto the authentication object as well.
  GDataOAuthSignIn *signIn_;

  // the page request to load when awakeFromNib occurs
  NSURLRequest *request_;

  // The user we're calling back
  id delegate_; // WEAK
  SEL finishedSelector_;

  NSString *keychainApplicationServiceName_;
  id userData_;

  // We delegate the decision to our owning NavigationController (if any).
  // But, the NavigationController will call us back, and ask us.
  // BOOL keeps us from infinite looping.
  BOOL isInsideShouldAutorotateToInterfaceOrientation_;

  // YES, when view first shown in this signIn session.
  BOOL isViewShown_;

  // To prevent us from calling our delegate's selector more than once.
  BOOL hasCalledFinished_;

  // Set in a webView callback.
  BOOL hasDoneFinalRedirect_;
}
@property (nonatomic, copy) NSString *keychainApplicationServiceName;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, retain, readonly) GDataOAuthAuthentication *authentication;
@property (nonatomic, retain) IBOutlet UIButton *backButton;
@property (nonatomic, retain) IBOutlet UIButton *forwardButton;
@property (nonatomic, retain) IBOutlet UIView *navButtonsView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *rightBarButtonItem;
@property (nonatomic, retain) id userData;

// init method for authenticating to Google services
//
// scope is the requested scope of authorization
//   (like "http://www.google.com/m8/feeds")
//
// language is nil or the desired display language code (like "es")
//
// keychain appServiceName is used for storing the token on the keychain,
//   appServiceName should be like "My Application: Google Contacts"
//   (or set to nil if no persistent keychain storage is desired)
//
// If you don't like the default nibName and bundle, you can change them
// using the UIViewController properties once you've made one of these.
- (id)initWithScope:(NSString *)scope
           language:(NSString *)language
     appServiceName:(NSString *)keychainAppServiceName
           delegate:(id)delegate
   finishedSelector:(SEL)finishedSelector;

// init method for authenticating to non-Google services, taking
//   explicit endpoint URLs and an authentication object
//
// this is the designated initializer
- (id)initWithScope:(NSString *)scope
           language:(NSString *)language
    requestTokenURL:(NSURL *)requestURL
  authorizeTokenURL:(NSURL *)authorizeURL
     accessTokenURL:(NSURL *)accessURL
     authentication:(GDataOAuthAuthentication *)auth
     appServiceName:(NSString *)keychainAppServiceName
           delegate:(id)delegate
   finishedSelector:(SEL)finishedSelector;

// Override default in UIViewController. If we have a navigationController, ask
// it. else default result (i.e., Portrait mode only).
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

// subclasses may override authNibName to specify a custom name
+ (NSString *)authNibName;

// If the nib is not found, this ViewwController calls this method to construct
// the view.
- (void)constructView;

// revocation of an authorized token from Google
+ (void)revokeTokenForGoogleAuthentication:(GDataOAuthAuthentication *)auth;

//
// Keychain
//

// create an authentication object for Google services from the access
// token and secret stored in the keychain; if no token is available, return
// an unauthorized auth object
+ (GDataOAuthAuthentication *)authForGoogleFromKeychainForName:(NSString *)appServiceName;

// add tokens from the keychain, if available, to the authentication object
//
// returns YES if the authentication object was authorized from the keychain
+ (BOOL)authorizeFromKeychainForName:(NSString *)appServiceName
                      authentication:(GDataOAuthAuthentication *)auth;

// method for deleting the stored access token and secret, useful for "signing
// out"
+ (BOOL)removeParamsFromKeychainForName:(NSString *)appServiceName;

// method for saving the stored access token and secret; typically, this method
// is used only by this.
+ (BOOL)saveParamsToKeychainForName:(NSString *)appServiceName
                     authentication:(GDataOAuthAuthentication *)auth;

@end

// To function, GDataOAuthViewControllerTouch needs a certain amount of access
// to the iPhone's keychain. To keep things simple, its keychain access is
// broken out into a helper class. We declare it here in case you'd like to use
// it too, to store passwords.

enum {
  kGDataOAuthKeychainErrorBadArguments = -1001,
  kGDataOAuthKeychainErrorNoPassword = -1002
};


@interface GDataOAuthKeychain : NSObject

+ (GDataOAuthKeychain *)defaultKeychain;

// OK to pass nil for the error parameter.
- (NSString *)passwordForService:(NSString *)service
                         account:(NSString *)account
                           error:(NSError **)error;

// OK to pass nil for the error parameter.
- (BOOL)removePasswordForService:(NSString *)service
                         account:(NSString *)account
                           error:(NSError **)error;

// OK to pass nil for the error parameter.
- (BOOL)setPassword:(NSString *)password
         forService:(NSString *)service
            account:(NSString *)account
              error:(NSError **)error;

// For unit tests: allow setting a mock object
+ (void)setDefaultKeychain:(GDataOAuthKeychain *)keychain;

@end

#endif // TARGET_OS_IPHONE

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_OAUTH
