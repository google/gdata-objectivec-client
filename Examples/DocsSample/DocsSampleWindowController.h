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
  IBOutlet NSButton *mViewSelectedDocButton;

  IBOutlet NSButton *mUploadFileButton;
  IBOutlet NSButton *mStopUploadButton;
  IBOutlet NSProgressIndicator *mUploadProgressIndicator;

  IBOutlet NSTextField *mUploadingTextField;

  GDataFeedDocList *mDocListFeed;
  GDataServiceTicket *mDocListFetchTicket;
  NSError *mDocListFetchError;
  
  GDataServiceTicket *mUploadTicket;
}

+ (DocsSampleWindowController *)sharedDocsSampleWindowController;

- (IBAction)getDocListClicked:(id)sender;
- (IBAction)cancelDocListFetchClicked:(id)sender;

- (IBAction)viewSelectedDocClicked:(id)sender;

- (IBAction)uploadFileClicked:(id)sender;
- (IBAction)stopUploadClicked:(id)sender;

- (IBAction)loggingCheckboxClicked:(id)sender;
@end
