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
//  BloggerSampleWindowController.h
//

#import <Cocoa/Cocoa.h>

#import "GData/GData.h"

@interface BloggerSampleWindowController : NSWindowController {
  IBOutlet NSTextField *mUsernameField;
  IBOutlet NSSecureTextField *mPasswordField;
  
  IBOutlet NSTableView *mBlogsTable;
  IBOutlet NSProgressIndicator *mBlogsProgressIndicator;
  IBOutlet NSTextField *mBlogsResultTextField;

  IBOutlet NSTableView *mEntriesTable;
  IBOutlet NSProgressIndicator *mEntriesProgressIndicator;
  IBOutlet NSTextField *mEntriesResultTextField;
  
  IBOutlet NSTextField *mEntryEditField;
  
  IBOutlet NSButton *mAddPostButton;
  IBOutlet NSButton *mUpdatePostButton;
  IBOutlet NSButton *mDeletePostButton;
  
  GDataFeedBase *mBlogsFeed;
  BOOL mIsBloggerFetchPending;
  NSError *mBloggerFetchError;
    
  GDataFeedBase *mEntriesFeed;
  BOOL mIsEntriesFetchPending;
  NSError *mEntriesFetchError;
  
}

+ (BloggerSampleWindowController *)sharedBloggerSampleWindowController;

- (IBAction)getBlogsClicked:(id)sender;

- (IBAction)addPostClicked:(id)sender;
- (IBAction)updatePostClicked:(id)sender;
- (IBAction)deletePostClicked:(id)sender;
@end
