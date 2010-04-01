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
//  TranslateSampleWindowController.h
//

#import <Cocoa/Cocoa.h>

#import "GData/GDataTranslation.h"

@interface TranslateSampleWindowController : NSWindowController {
  IBOutlet NSTextField *mUsernameField;
  IBOutlet NSSecureTextField *mPasswordField;

  IBOutlet NSButton *mHiddenCheckbox;
  IBOutlet NSButton *mDeletedCheckbox;

  IBOutlet NSButton *mCancelFeedFetchesButton;

  // the feed displayed in the table depends on the segmented control setting
  // (translation documents, glossaries, or translation memories)
  IBOutlet NSSegmentedControl *mEntriesSegmentedControl;
  IBOutlet NSTableView *mEntriesTable;
  IBOutlet NSProgressIndicator *mEntriesProgressIndicator;
  IBOutlet NSTextView *mEntriesResultTextField;

  IBOutlet NSProgressIndicator *mUpdateProgressIndicator;

  IBOutlet NSButton *mDownloadButton;
  IBOutlet NSPopUpButton *mGlossariesPopup;
  IBOutlet NSPopUpButton *mMemoriesPopup;

  IBOutlet NSTextField *mDocumentPathField;
  IBOutlet NSButton *mBrowseButton;

  IBOutlet NSTextField *mTitleTextField;
  IBOutlet NSButton *mUploadButton;
  IBOutlet NSButton *mRenameButton;
  IBOutlet NSButton *mDeleteButton;

  IBOutlet NSTextField *mSourceLangField;
  IBOutlet NSTextField *mTargetLangField;

  GDataFeedTranslationDocument *mDocumentFeed;
  GDataServiceTicket *mDocumentFeedTicket;
  NSError *mDocumentFeedFetchError;

  GDataFeedTranslationGlossary *mGlossaryFeed;
  GDataServiceTicket *mGlossaryFeedTicket;
  NSError *mGlossaryFeedFetchError;

  GDataFeedTranslationMemory *mMemoryFeed;
  GDataServiceTicket *mMemoryFeedTicket;
  NSError *mMemoryFeedFetchError;

  int mPendingEditTicketCounter;
}

+ (TranslateSampleWindowController *)sharedWindowController;

- (IBAction)getFeedClicked:(id)sender;
- (IBAction)cancelFetchesClicked:(id)sender;

- (IBAction)entriesSegmentClicked:(id)sender;

- (IBAction)glossaryPopupSelected:(id)sender;
- (IBAction)memoryPopupSelected:(id)sender;

- (IBAction)uploadEntryClicked:(id)sender;
- (IBAction)downloadEntryClicked:(id)sender;
- (IBAction)renameEntryClicked:(id)sender;
- (IBAction)deleteEntryClicked:(id)sender;
- (IBAction)browseForFileClicked:(id)sender;

- (IBAction)loggingCheckboxClicked:(id)sender;

@end
