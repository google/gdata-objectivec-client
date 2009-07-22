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
//  SpreadsheetSampleWindowController.h
//

#import <Cocoa/Cocoa.h>

#import "GData/GData.h"

@interface SpreadsheetSampleWindowController : NSWindowController {
  IBOutlet NSTextField *mUsernameField;
  IBOutlet NSSecureTextField *mPasswordField;
  
  IBOutlet NSTableView *mSpreadsheetTable;
  IBOutlet NSProgressIndicator *mSpreadsheetProgressIndicator;
  IBOutlet NSTextView *mSpreadsheetResultTextField;

  IBOutlet NSTableView *mWorksheetTable;
  IBOutlet NSProgressIndicator *mWorksheetProgressIndicator;
  IBOutlet NSTextView *mWorksheetResultTextField;
  
  IBOutlet NSSegmentedControl *mFeedSelectorSegments;
  IBOutlet NSTableView *mEntryTable;
  IBOutlet NSProgressIndicator *mEntryProgressIndicator;
  IBOutlet NSTextView *mEntryResultTextField;
  
  GDataFeedSpreadsheet *mSpreadsheetFeed;
  BOOL mIsSpreadsheetFetchPending;
  NSError *mSpreadsheetFetchError;
    
  GDataFeedWorksheet *mWorksheetFeed;
  BOOL mIsWorksheetFetchPending;
  NSError *mWorksheetFetchError;
  
  GDataFeedBase *mEntryFeed;
  BOOL mIsEntryFetchPending;
  NSError *mEntryFetchError;
}

+ (SpreadsheetSampleWindowController *)sharedSpreadsheetSampleWindowController;

- (IBAction)getSpreadsheetClicked:(id)sender;
- (IBAction)feedSegmentClicked:(id)sender;
- (IBAction)loggingCheckboxClicked:(id)sender;

@end
