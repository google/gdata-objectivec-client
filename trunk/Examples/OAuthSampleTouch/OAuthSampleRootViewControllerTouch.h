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
// OAuthSampleRootViewControllerTouch.h

@class GDataOAuthAuthentication;

@interface OAuthSampleRootViewControllerTouch : UIViewController<UINavigationControllerDelegate> {
  UISwitch *mShouldSaveInKeychainSwitch;
  UISegmentedControl *mServiceSegments;
  UIBarButtonItem *mSignInOutButton;
  int mNetworkActivityCounter;
  UILabel *mEmailField;
  UILabel *mTokenField;
  GDataOAuthAuthentication *mAuth;
}
@property (nonatomic, retain) IBOutlet UISegmentedControl *serviceSegments;
@property (nonatomic, retain) IBOutlet UISwitch *shouldSaveInKeychainSwitch;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *signInOutButton;
@property (nonatomic, retain) IBOutlet UILabel *emailField;
@property (nonatomic, retain) IBOutlet UILabel *tokenField;

- (IBAction)signInOutClicked:(id)sender;
- (IBAction)toggleShouldSaveInKeychain:(id)sender;

- (void)signInToGoogle;
- (void)signInToTwitter;
- (void)signOut;
- (BOOL)isSignedIn;

- (void)updateUI;

- (void)setAuthentication:(GDataOAuthAuthentication *)auth;

@end
