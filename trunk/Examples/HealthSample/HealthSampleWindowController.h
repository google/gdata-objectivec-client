/* Copyright (c) 2009 Google Inc.
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
//  HealthSampleWindowController.h
//

#import <Cocoa/Cocoa.h>

#import "GData/GDataHealth.h"

@interface HealthSampleWindowController : NSWindowController {
  IBOutlet NSTextField *mUsernameField;
  IBOutlet NSSecureTextField *mPasswordField;
  IBOutlet NSMatrix *mRadioMatrix;

  IBOutlet NSTableView *mProfileListTable;
  IBOutlet NSProgressIndicator *mProfileListProgressIndicator;
  IBOutlet NSTextView *mProfileListResultTextField;

  IBOutlet NSTableView *mProfileTable;
  IBOutlet NSProgressIndicator *mProfileProgressIndicator;
  IBOutlet NSTextView *mProfileResultTextField;

  IBOutlet NSSegmentedControl *mEntrySegmentedControl;
  IBOutlet NSSegmentedControl *mXMLSegmentedControl;
  IBOutlet NSTextView *mXMLField;

  GDataFeedBase *mProfileListFeed;
  BOOL mIsProfileListFetchPending;
  NSError *mProfileListFetchError;

  GDataFeedHealthProfile *mProfileFeed;
  BOOL mIsProfileFetchPending;
  NSError *mProfileFetchError;

  GDataFeedHealthRegister *mRegisterFeed;
  BOOL mIsRegisterFetchPending;
  NSError *mRegisterFetchError;

  Class mServiceClass;
}

+ (HealthSampleWindowController *)sharedHealthSampleWindowController;

- (IBAction)getProfileListClicked:(id)sender;

- (IBAction)loggingCheckboxClicked:(id)sender;

- (IBAction)radioButtonClicked:(id)sender;

- (IBAction)entrySegmentClicked:(id)sender;

- (IBAction)xmlSegmentClicked:(id)sender;

@end
