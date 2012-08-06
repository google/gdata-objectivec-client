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
//  AnalyticsSampleWindowController.h
//

//
// IMPORTANT:
//
// The XML-based API for Google Analytics has been replaced with a more efficient
// and easier-to-use JSON API.  The JSON API is documented at
//
//   https://developers.google.com/analytics
//
// See the new Objective-C client library and sample code at
//   http://code.google.com/p/google-api-objectivec-client/
//
// This sample application and library support for the XML-based Analytics
// API will eventually be removed.
//

#import <Cocoa/Cocoa.h>

#import "GData/GDataAnalytics.h"

@interface AnalyticsSampleWindowController : NSWindowController {
  IBOutlet NSTextField *mUsernameField;
  IBOutlet NSSecureTextField *mPasswordField;

  IBOutlet NSTableView *mAccountsTable;
  IBOutlet NSProgressIndicator *mAccountsProgressIndicator;
  IBOutlet NSTextView *mAccountsResultTextField;

  IBOutlet NSTableView *mAnalyticsDataTable;
  IBOutlet NSProgressIndicator *mAnalyticsDataProgressIndicator;
  IBOutlet NSTextView *mAnalyticsDataResultTextField;

  IBOutlet NSDatePicker *mStartDatePicker;
  IBOutlet NSDatePicker *mEndDatePicker;

  IBOutlet NSPopUpButton *mDimensionsPopup;
  IBOutlet NSTextField *mDimensionsField;
  IBOutlet NSPopUpButton *mMetricsPopup;
  IBOutlet NSTextField *mMetricsField;

  IBOutlet NSButton *mReloadButton;

  GDataFeedAnalyticsAccount *mAccountFeed;
  BOOL mIsAccountFetchPending;
  NSError *mAccountFetchError;

  GDataFeedAnalyticsData *mAnalyticsDataFeed;
  BOOL mIsAnalyticsDataFetchPending;
  NSError *mAnalyticsDataFetchError;
}

+ (AnalyticsSampleWindowController *)sharedAnalyticsSampleWindowController;

- (IBAction)getAccountsClicked:(id)sender;

- (IBAction)refreshAccountData:(id)sender;

- (IBAction)loggingCheckboxClicked:(id)sender;

- (IBAction)menuItemClicked:(id)sender;

@end
