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
//  DocsSampleWindowController.h
//

#import <Cocoa/Cocoa.h>

#import "GData/GData.h"
#import "GData/GDataFeedDocList.h"

@interface DocsSampleWindowController : NSWindowController {
  IBOutlet NSTextField *mUsernameField;
  IBOutlet NSSecureTextField *mPasswordField;
  
  IBOutlet NSTableView *mDocListTable;
  IBOutlet NSProgressIndicator *mDocListProgressIndicator;
  IBOutlet NSTextView *mDocListResultTextField;
  IBOutlet NSButton *mDocListCancelButton;

  IBOutlet NSTableView *mRevisionsTable;
  IBOutlet NSProgressIndicator *mRevisionsProgressIndicator;
  IBOutlet NSTextView *mRevisionsResultTextField;
  IBOutlet NSButton *mRevisionsCancelButton;

  IBOutlet NSButton *mViewSelectedDocButton;
  IBOutlet NSButton *mDeleteSelectedDocButton;
  IBOutlet NSButton *mDownloadSelectedDocButton;
  IBOutlet NSButton *mDuplicateSelectedDocButton;
  IBOutlet NSButton *mCreateFolderButton;

  IBOutlet NSButton *mDownloadSelectedRevisionButton;

  IBOutlet NSPopUpButton *mFolderMembershipPopup;

  IBOutlet NSButton *mUploadFileButton;
  IBOutlet NSButton *mStopUploadButton;
  IBOutlet NSButton *mPauseUploadButton;
  IBOutlet NSProgressIndicator *mUploadProgressIndicator;
  IBOutlet NSPopUpButton *mUploadPopup;

  IBOutlet NSTextField *mUploadingTextField;

  IBOutlet NSButton *mPublishCheckbox;
  IBOutlet NSButton *mAutoRepublishCheckbox;
  IBOutlet NSButton *mPublishOutsideDomainCheckbox;
  IBOutlet NSButton *mUpdatePublishingButton;

  GDataFeedDocList *mDocListFeed;
  GDataServiceTicket *mDocListFetchTicket;
  NSError *mDocListFetchError;

  GDataFeedDocRevision *mRevisionFeed;
  GDataServiceTicket *mRevisionFetchTicket;
  NSError *mRevisionFetchError;

  GDataEntryDocListMetadata *mMetadataEntry;
  
  GDataServiceTicket *mUploadTicket;
}

+ (DocsSampleWindowController *)sharedDocsSampleWindowController;

- (IBAction)getDocListClicked:(id)sender;
- (IBAction)cancelDocListFetchClicked:(id)sender;
- (IBAction)cancelRevisionsFetchClicked:(id)sender;

- (IBAction)viewSelectedDocClicked:(id)sender;
- (IBAction)downloadSelectedDocClicked:(id)sender;
- (IBAction)duplicateSelectedDocClicked:(id)sender;

- (IBAction)downloadSelectedRevisionClicked:(id)sender;

- (IBAction)createFolderClicked:(id)sender;

- (IBAction)deleteSelectedDocClicked:(id)sender;

- (IBAction)uploadFileClicked:(id)sender;
- (IBAction)stopUploadClicked:(id)sender;
- (IBAction)pauseUploadClicked:(id)sender;

- (IBAction)publishCheckboxClicked:(id)sender;
- (IBAction)updatePublishingClicked:(id)sender;

- (IBAction)loggingCheckboxClicked:(id)sender;
@end
