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
//  BloggerSampleWindowController.h
//

#import <Cocoa/Cocoa.h>

#import "GData/GDataBlogger.h"

@interface BloggerSampleWindowController : NSWindowController {
  IBOutlet NSTextField *mUsernameField;
  IBOutlet NSSecureTextField *mPasswordField;

  IBOutlet NSTableView *mBlogsTable;
  IBOutlet NSProgressIndicator *mBlogsProgressIndicator;
  IBOutlet NSTextView *mBlogsResultTextField;

  IBOutlet NSTableView *mPostsTable;
  IBOutlet NSProgressIndicator *mPostsProgressIndicator;
  IBOutlet NSTextView *mPostsResultTextField;

  IBOutlet NSTextField *mPostEditField;
  IBOutlet NSProgressIndicator *mEditProgressIndicator;
  IBOutlet NSButton *mPostDraftCheckBox;
  IBOutlet NSButton *mAddPostButton;
  IBOutlet NSButton *mUpdatePostButton;
  IBOutlet NSButton *mDeletePostButton;

  IBOutlet NSTableView *mCommentsTable;
  IBOutlet NSProgressIndicator *mCommentsProgressIndicator;
  IBOutlet NSTextView *mCommentsResultTextField;

  GDataFeedBase *mBlogFeed;
  GDataServiceTicket *mBlogFeedTicket;
  NSError *mBlogFetchError;

  GDataFeedBase *mPostFeed;
  GDataServiceTicket *mPostFeedTicket;
  NSError *mPostFetchError;

  GDataServiceTicket *mEditPostTicket; // for add, update, delete

  GDataFeedBase *mCommentFeed;
  GDataServiceTicket *mCommentFeedTicket;
  NSError *mCommentFetchError;
}

+ (BloggerSampleWindowController *)sharedBloggerSampleWindowController;

- (IBAction)getBlogsClicked:(id)sender;

- (IBAction)addPostClicked:(id)sender;
- (IBAction)updatePostClicked:(id)sender;
- (IBAction)deletePostClicked:(id)sender;

- (IBAction)draftCheckboxClicked:(id)sender;

- (IBAction)loggingCheckboxClicked:(id)sender;

@end
