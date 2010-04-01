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

// GDataOAuthWindowController
//
// This window controller for Mac handles sign-in via OAuth to Google or
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
//  GDataOAuthWindowController *controller = [[[GDataOAuthWindowController alloc] initWithScope:scope
//                                                                                     language:nil
//                                                                               appServiceName:kAppServiceName
//                                                                               resourceBundle:nil] autorelease];
//  [controller signInSheetModalForWindow:currentWindow
//                               delegate:self
//                       finishedSelector:@selector(windowController:finishedWithAuth:error:)];
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

#import "GDataOAuthWindowController.h"
#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_OAUTH

#if !TARGET_OS_IPHONE

#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_5

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import "GDataOAuthAuthentication.h"

@class GDataOAuthSignIn;

@interface GDataOAuthWindowController : NSWindowController {
 @private
  // IBOutlets
  NSButton *keychainCheckbox_;
  WebView *webView_;
  NSButton *webCloseButton_;
  NSButton *webBackButton_;

  // the object responsible for the sign-in networking sequence; it holds
  // onto the authentication object as well
  GDataOAuthSignIn *signIn_;

  // the page request to load when awakeFromNib occurs
  NSURLRequest *initialRequest_;

  // the user we're calling back
  __weak id delegate_;
  SEL finishedSelector_;

  BOOL isWindowShown_;

  // paranoid flag to ensure we only close once during the sign-in sequence
  BOOL hasDoneFinalRedirect_;

  // paranoid flag to ensure we only call the user back once
  BOOL hasCalledFinished_;

  // if non-nil, we display as a sheet on the specified window
  NSWindow *sheetModalForWindow_;

  // if non-empty, the name of the application and service used for the
  // keychain item
  NSString *keychainApplicationServiceName_;

  // user-defined data
  id userData_;
}

@property (nonatomic, assign) IBOutlet NSButton *keychainCheckbox;
@property (nonatomic, assign) IBOutlet WebView *webView;
@property (nonatomic, assign) IBOutlet NSButton *webCloseButton;
@property (nonatomic, assign) IBOutlet NSButton *webBackButton;

@property (nonatomic, copy)   NSString *keychainApplicationServiceName;
@property (nonatomic, copy)   NSString *displayName;
@property (nonatomic, retain) id userData;

- (IBAction)closeWindow:(id)sender;

// init method for authenticating to Google services
//
// scope is the requested scope of authorization
//   (like "http://www.google.com/m8/feeds")
//
// language is nil or the desired display language code (like "es")
//
// appServiceName is used for storing the token on the keychain,
//   and is required for the "remember for later" checkbox to be shown;
//   appServiceName should be like "My Application: Google Contacts"
//   (or set to nil if no persistent keychain storage is desired)
//
// resourceBundle may be nil if the window is in the main bundle's nib
- (id)initWithScope:(NSString *)scope
           language:(NSString *)language               // may be nil
     appServiceName:(NSString *)keychainAppServiceName // may be nil
     resourceBundle:(NSBundle *)bundle;                // may be nil

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
     resourceBundle:(NSBundle *)bundle;

// entry point to begin displaying the sign-in window
//
// the finished selector should have a signature matching
//  - (void)windowController:(GDataOAuthWindowController *)windowController
//          finishedWithAuth:(GDataOAuthAuthentication *)auth
//                     error:(NSError *)error {
//
// once the finished method has been invoked with no error, the auth object
// may be used to authorize requests (adding and signing the auth header) like:
//
//     [authorizer authorizeRequest:myNSMutableURLRequest];
//
// or can be stored in a GData service object like
//   GDataServiceGoogleContact *service = [self contactService];
//   [service setAuthorizer:auth];
- (void)signInSheetModalForWindow:(NSWindow *)parentWindowOrNil
                         delegate:(id)delegate
                 finishedSelector:(SEL)finishedSelector;

- (void)cancelSigningIn;

// subclasses may override authNibName to specify a custom name
+ (NSString *)authNibName;

// revocation of an authorized token from Google
+ (void)revokeTokenForGoogleAuthentication:(GDataOAuthAuthentication *)auth;

// keychain
//
// The keychain checkbox is shown if the keychain application service
// name (typically set in the initWithScope: method) is non-empty
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
// is used only by the window controller
+ (BOOL)saveParamsToKeychainForName:(NSString *)appServiceName
                     authentication:(GDataOAuthAuthentication *)auth;

//
// get the underlying authentication object
//
- (GDataOAuthAuthentication *)authentication;

//
// useful window elements
//
- (WebView *)webView;
- (NSButton *)keychainCheckbox;

@end

#endif // #if MAC_OS_X_VERSION_MIN_REQUIRED

#endif // #if !TARGET_OS_IPHONE

#endif // #if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_OAUTH
