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
//  GooglePhotosSampleWindowController.h
//

#import <Cocoa/Cocoa.h>

#import "GData/GData.h"
#import "GData/GDataFeedPhotoAlbum.h"
#import "GData/GDataFeedPhoto.h"

@interface GooglePhotosSampleWindowController : NSWindowController {
  IBOutlet NSTextField *mUsernameField;
  IBOutlet NSSecureTextField *mPasswordField;
  
  IBOutlet NSTableView *mAlbumTable;
  IBOutlet NSProgressIndicator *mAlbumProgressIndicator;
  IBOutlet NSTextView *mAlbumResultTextField;
  IBOutlet NSButton *mAlbumCancelButton;
  IBOutlet NSImageView *mAlbumImageView;

  IBOutlet NSButton *mCreateAlbumButton;
  IBOutlet NSButton *mCreateAlbumUnlistedCheckbox;
  IBOutlet NSTextField *mCreateAlbumField;

  IBOutlet NSTableView *mPhotoTable;
  IBOutlet NSProgressIndicator *mPhotoProgressIndicator;
  IBOutlet NSTextView *mPhotoResultTextField;
  IBOutlet NSButton *mPhotoCancelButton;
  IBOutlet NSImageView *mPhotoImageView;
  
  IBOutlet NSButton *mAddTagButton;
  IBOutlet NSTextField *mTagField;
  IBOutlet NSButton *mAddCommentButton;
  IBOutlet NSTextField *mCommentField;
  
  IBOutlet NSButton *mAddToAlbumButton;
  IBOutlet NSButton *mAddToDropBoxButton;
  IBOutlet NSButton *mDeletePhotoButton;
  IBOutlet NSButton *mDownloadPhotoButton;
  IBOutlet NSPopUpButton *mChangeAlbumPopupButton;
  IBOutlet NSProgressIndicator *mUploadProgressIndicator;
  
  GDataFeedPhotoUser *mUserAlbumFeed; // user feed of album entries
  GDataServiceTicket *mAlbumFetchTicket;
  NSError *mAlbumFetchError;
  NSString *mAlbumImageURLString;
    
  GDataFeedPhotoAlbum *mAlbumPhotosFeed; // album feed of photo entries
  GDataServiceTicket *mPhotosFetchTicket;
  NSError *mPhotosFetchError;
  NSString *mPhotoImageURLString;
}

+ (GooglePhotosSampleWindowController *)sharedGooglePhotosSampleWindowController;

- (IBAction)getAlbumClicked:(id)sender;

- (IBAction)cancelAlbumFetchClicked:(id)sender;
- (IBAction)cancelPhotoFetchClicked:(id)sender;

- (IBAction)createAlbumClicked:(id)sender;

- (IBAction)addToAlbumClicked:(id)sender;
- (IBAction)addToDropBoxClicked:(id)sender;
- (IBAction)deleteClicked:(id)sender;
- (IBAction)downloadClicked:(id)sender;

- (IBAction)addTagClicked:(id)sender;
- (IBAction)addCommentClicked:(id)sender;

- (IBAction)loggingCheckboxClicked:(id)sender;
@end
