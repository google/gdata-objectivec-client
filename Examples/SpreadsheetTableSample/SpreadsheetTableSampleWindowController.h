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
//  SpreadsheetTableSampleWindowController.h
//

#import <Cocoa/Cocoa.h>

#import "GData/GData.h"

@interface SpreadsheetTableSampleWindowController : NSWindowController {
  IBOutlet NSTextField *mUsernameField;
  IBOutlet NSSecureTextField *mPasswordField;

  IBOutlet NSButton *mAddTableButton;
  IBOutlet NSButton *mDeleteTableButton;
  IBOutlet NSButton *mRandomizeTableButton;

  IBOutlet NSTableView *mSpreadsheetTable;
  IBOutlet NSProgressIndicator *mSpreadsheetProgressIndicator;
  IBOutlet NSTextView *mSpreadsheetResultTextField;

  IBOutlet NSTableView *mWorksheetTable;
  IBOutlet NSProgressIndicator *mWorksheetProgressIndicator;
  IBOutlet NSTextView *mWorksheetResultTextField;

  IBOutlet NSTableView *mTableTable;
  IBOutlet NSProgressIndicator *mTableProgressIndicator;
  IBOutlet NSTextView *mTableResultTextField;

  IBOutlet NSTableView *mRecordTable;
  IBOutlet NSProgressIndicator *mRecordProgressIndicator;
  IBOutlet NSTextView *mRecordResultTextField;

  IBOutlet NSProgressIndicator *mGlobalFetchProgressIndicator;

  GDataFeedSpreadsheet *mSpreadsheetFeed;
  GDataServiceTicket *mSpreadsheetFeedTicket;
  NSError *mSpreadsheetFetchError;

  GDataFeedWorksheet *mWorksheetFeed;
  GDataServiceTicket *mWorksheetFeedTicket;
  NSError *mWorksheetFetchError;

  GDataFeedSpreadsheetTable *mTableFeed;
  GDataServiceTicket *mTableFeedTicket;
  NSError *mTableFetchError;

  GDataFeedSpreadsheetRecord *mRecordFeed;
  GDataServiceTicket *mRecordFeedTicket;
  NSError *mRecordFetchError;

  NSMutableArray *mRecordUpdateTickets;
}

+ (SpreadsheetTableSampleWindowController *)sharedWindowController;

- (IBAction)getSpreadsheetClicked:(id)sender;
- (IBAction)addTableClicked:(id)sender;
- (IBAction)deleteTableClicked:(id)sender;
- (IBAction)randomizeTableClicked:(id)sender;
- (IBAction)loggingCheckboxClicked:(id)sender;
@end
