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
//  YouTubeSampleWindowController.h
//

#import <Cocoa/Cocoa.h>

#import "GData/GData.h"
#import "GData/GDataFeedPhotoAlbum.h"
#import "GData/GDataFeedPhoto.h"

@interface YouTubeSampleWindowController : NSWindowController {
  IBOutlet NSTextField *mUsernameField;
  IBOutlet NSSecureTextField *mPasswordField;
  IBOutlet NSPopUpButton *mUserFeedPopup;
  IBOutlet NSTextField *mEntryCountField;
  
  IBOutlet NSTableView *mEntriesTable;
  IBOutlet NSProgressIndicator *mEntriesProgressIndicator;
  IBOutlet NSTextView *mEntriesResultTextField;
  IBOutlet NSButton *mEntriesCancelButton;
  IBOutlet NSImageView *mEntryImageView;

  IBOutlet NSButton *mChooseFileButton;
  IBOutlet NSTextField *mFilePathField;
 
  IBOutlet NSTextField *mDeveloperKeyField;
  IBOutlet NSTextField *mTitleField;
  IBOutlet NSTextField *mDescriptionField;
  IBOutlet NSTextField *mKeywordsField;
  IBOutlet NSPopUpButton *mCategoryPopup;
  IBOutlet NSButton *mPrivateCheckbox;
  
  IBOutlet NSButton *mUploadButton;
  IBOutlet NSButton *mPauseUploadButton;
  IBOutlet NSButton *mStopUploadButton;
  IBOutlet NSProgressIndicator *mUploadProgressIndicator;

  GDataFeedYouTubeVideo *mEntriesFeed; // user feed of album entries
  GDataServiceTicket *mEntriesFetchTicket;
  NSError *mEntriesFetchError;
  NSString *mEntryImageURLString;

  GDataServiceTicket *mUploadTicket;
}

+ (YouTubeSampleWindowController *)sharedYouTubeSampleWindowController;

- (IBAction)getEntriesClicked:(id)sender;
- (IBAction)cancelEntriesFetchClicked:(id)sender;

- (IBAction)chooseFileClicked:(id)sender;
- (IBAction)uploadClicked:(id)sender;
- (IBAction)pauseUploadClicked:(id)sender;
- (IBAction)stopUploadClicked:(id)sender;

- (IBAction)loggingCheckboxClicked:(id)sender;
@end
