/* Copyright (c) 2008 Google Inc.
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
//  ContactsSampleWindowController.h
//

#import <Cocoa/Cocoa.h>

#import "GData/GData.h"

#import "GData/GDataFeedContact.h"

@interface ContactsSampleWindowController : NSWindowController {
  IBOutlet NSTextField *mUsernameField;
  IBOutlet NSSecureTextField *mPasswordField;
  
  IBOutlet NSButton *mShowDeletedCheckbox;
  IBOutlet NSButton *mGetContactsButton;
  
  IBOutlet NSTableView *mContactTable;
  IBOutlet NSProgressIndicator *mContactProgressIndicator;
  IBOutlet NSTextView *mContactResultTextField;
  IBOutlet NSButton *mContactCancelButton;
  IBOutlet NSButton *mSortContactsCheckbox;
  
  IBOutlet NSButton *mAddContactButton;
  IBOutlet NSTextField *mAddTitleField;
  IBOutlet NSTextField *mAddEmailField;
  IBOutlet NSButton *mDeleteContactButton;
  
  IBOutlet NSSegmentedControl *mEntrySegmentedControl;

  IBOutlet NSTableView *mEntryTable;
  IBOutlet NSTextView *mEntryResultTextField;
  
  IBOutlet NSButton *mAddEntryButton;
  IBOutlet NSButton *mDeleteEntryButton;
  IBOutlet NSButton *mEditEntryButton;
  IBOutlet NSButton *mMakePrimaryEntryButton;
  
  IBOutlet NSTextField *mServiceURLField; 
  
  GDataFeedContact *mContactFeed;
  GDataServiceTicket *mContactFetchTicket;
  NSError *mContactFetchError;
}

+ (ContactsSampleWindowController *)sharedContactsSampleWindowController;

- (IBAction)getContactClicked:(id)sender;

- (IBAction)cancelContactFetchClicked:(id)sender;

- (IBAction)addContactClicked:(id)sender;
- (IBAction)deleteContactClicked:(id)sender;

- (IBAction)addEntryClicked:(id)sender;
- (IBAction)editEntryClicked:(id)sender;
- (IBAction)deleteEntryClicked:(id)sender;
- (IBAction)makeEntryPrimaryClicked:(id)sender;

- (IBAction)entrySegmentClicked:(id)sender;
- (IBAction)sortContactsClicked:(id)sender;

- (IBAction)loggingCheckboxClicked:(id)sender;
@end
