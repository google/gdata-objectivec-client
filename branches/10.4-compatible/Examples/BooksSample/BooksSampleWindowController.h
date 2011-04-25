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
//  BooksSampleWindowController.h
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import "GData/GDataBooks.h"

@interface BooksSampleWindowController : NSWindowController {

  IBOutlet NSButton *mGetVolumesButton;
  IBOutlet NSTextField *mUsernameField;
  IBOutlet NSSecureTextField *mPasswordField;

  IBOutlet NSButton *mSearchButton;
  IBOutlet NSPopUpButton *mViewabilityPopUp;
  IBOutlet NSTextField *mSearchField;

  IBOutlet NSTableView *mVolumesTable;
  IBOutlet NSProgressIndicator *mVolumesProgressIndicator;
  IBOutlet NSTextView *mVolumesResultTextField;
  IBOutlet NSButton *mVolumesCancelButton;
  IBOutlet NSImageView *mVolumeImageView;

  IBOutlet NSSegmentedControl *mUserFeedTypeSegments;
  IBOutlet NSPopUpButton *mCollectionPopup;
  IBOutlet NSProgressIndicator *mCollectionProgressIndicator;

  IBOutlet NSSegmentedControl *mWebViewSegments;
  IBOutlet WebView *mWebView;

  IBOutlet NSProgressIndicator *mAnnotationsProgressIndicator;
  IBOutlet NSButton *mAnnotationsCancelButton;

  IBOutlet NSTextField *mLabelField;
  IBOutlet NSButton *mAddLabelButton;
  IBOutlet NSPopUpButton *mRatingPopup;
  IBOutlet NSTextField *mAverageRatingField;
  IBOutlet NSTextField *mReviewField;
  IBOutlet NSButton *mSaveReviewButton;

  // the volumes feed is returned from a fetch of the user's library
  // or annotations, or from a search
  GDataFeedVolume *mVolumesFeed;
  GDataServiceTicket *mVolumesFetchTicket;
  NSError *mVolumesFetchError;

  // feed of user's collections
  GDataFeedCollection *mCollectionsFeed;
  GDataServiceTicket *mCollectionsFetchTicket;
  NSError *mCollectionsFetchError;

  // the annotations fetch is for setting rating, review, or label
  // on a volume entry
  GDataServiceTicket *mAnnotationsFetchTicket;

  // we retain the currently-displayed book thumbnail or web page
  // so we can determine if they've changed as the user's selections
  // change
  NSString *mVolumeImageURLString;
  NSString *mVolumeWebURLString;
}

+ (BooksSampleWindowController *)sharedBooksSampleWindowController;

- (IBAction)getVolumesClicked:(id)sender;
- (IBAction)collectionPopupClicked:(id)sender;
- (IBAction)searchClicked:(id)sender;

- (IBAction)cancelVolumeFetchClicked:(id)sender;
- (IBAction)userFeedTypeSegmentClicked:(id)sender;
- (IBAction)webViewSegmentClicked:(id)sender;
- (IBAction)addLabelClicked:(id)sender;
- (IBAction)ratingPopupClicked:(id)sender;
- (IBAction)saveReviewClicked:(id)sender;
- (IBAction)cancelAnnotationsFetchClicked:(id)sender;

- (IBAction)loggingCheckboxClicked:(id)sender;
@end
