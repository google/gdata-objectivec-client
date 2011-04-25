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
//  FinanceSampleWindowController.h
//

#import <Cocoa/Cocoa.h>

#import "GData/GDataFinance.h"

@interface FinanceSampleWindowController : NSWindowController {
  IBOutlet NSTextField *mUsernameField;
  IBOutlet NSSecureTextField *mPasswordField;

  IBOutlet NSTableView *mPortfoliosTable;
  IBOutlet NSProgressIndicator *mPortfoliosProgressIndicator;
  IBOutlet NSTextView *mPortfoliosResultTextField;

  IBOutlet NSButton *mCreatePortfolioButton;
  IBOutlet NSTextField *mPortfolioNameField;
  IBOutlet NSButton *mDeletePortfolioButton;

  IBOutlet NSTableView *mPositionsTable;
  IBOutlet NSProgressIndicator *mPositionsProgressIndicator;
  IBOutlet NSTextView *mPositionsResultTextField;

  IBOutlet NSTableView *mTransactionsTable;
  IBOutlet NSProgressIndicator *mTransactionsProgressIndicator;
  IBOutlet NSTextView *mTransactionsResultTextField;

  IBOutlet NSButton *mCreateTransactionButton;
  IBOutlet NSDatePicker *mTransactionDatePicker;
  IBOutlet NSTextField *mTransactionSharesField;
  IBOutlet NSPopUpButton *mTransactionTypePopup;
  IBOutlet NSTextField *mTransactionPriceField;
  IBOutlet NSButton *mDeleteTransactionButton;

  GDataFeedFinancePortfolio *mPortfolioFeed;
  int mPortfolioFetchesPendingCount;
  NSError *mPortfolioFetchError;

  GDataFeedFinancePosition *mPositionFeed;
  int mPositionFetchesPendingCount;
  NSError *mPositionFetchError;

  GDataFeedFinanceTransaction *mTransactionFeed;
  int mTransactionFetchesPendingCount;
  NSError *mTransactionFetchError;
}

+ (FinanceSampleWindowController *)sharedFinanceSampleWindowController;

- (IBAction)getPortfoliosClicked:(id)sender;

- (IBAction)createPortfolioClicked:(id)sender;
- (IBAction)deletePortfolioClicked:(id)sender;

- (IBAction)createTransactionClicked:(id)sender;
- (IBAction)deleteTransactionClicked:(id)sender;

- (IBAction)loggingCheckboxClicked:(id)sender;

@end
