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
//  BloggerSampleWindowController.m
//

#import "BloggerSampleWindowController.h"

@interface BloggerSampleWindowController (PrivateMethods)
- (void)updateUI;

- (void)fetchAllBlogs;
- (void)fetchPostsForSelectedBlog;
- (void)addEntry;
- (void)updateSelectedPost;
- (void)deleteSelectedPost;

- (GDataServiceGoogleBlogger *)bloggerService;
- (GDataEntryBlog *)selectedBlog;
- (GDataEntryBlogPost *)selectedPost;
- (GDataEntryBlogComment *)selectedComment;

- (GDataFeedBase *)blogFeed;
- (void)setBlogFeed:(GDataFeedBase *)feed;
- (NSError *)blogFetchError;
- (void)setBlogFetchError:(NSError *)error;
- (GDataServiceTicket *)blogFeedTicket;
- (void)setBlogFeedTicket:(GDataServiceTicket *)ticket;

- (GDataFeedBase *)postFeed;
- (void)setPostFeed:(GDataFeedBase *)feed;
- (NSError *)postFetchError;
- (void)setPostFetchError:(NSError *)error;
- (GDataServiceTicket *)postFeedTicket;
- (void)setPostFeedTicket:(GDataServiceTicket *)ticket;

- (GDataServiceTicket *)editPostTicket;
- (void)setEditPostTicket:(GDataServiceTicket *)ticket;

- (GDataFeedBase *)commentFeed;
- (void)setCommentFeed:(GDataFeedBase *)feed;
- (NSError *)commentFetchError;
- (void)setCommentFetchError:(NSError *)error;
- (GDataServiceTicket *)commentFeedTicket;
- (void)setCommentFeedTicket:(GDataServiceTicket *)ticket;

@end

@implementation BloggerSampleWindowController

+ (BloggerSampleWindowController *)sharedBloggerSampleWindowController {

  static BloggerSampleWindowController* gController = nil;

  if (!gController) {
    gController = [[BloggerSampleWindowController alloc] init];
  }
  return gController;
}


- (id)init {
  return [self initWithWindowNibName:@"BloggerSampleWindow"];
}

- (void)awakeFromNib {
  // Set the result text fields to have a distinctive color and mono-spaced font
  [mBlogsResultTextField setTextColor:[NSColor darkGrayColor]];
  [mPostsResultTextField setTextColor:[NSColor darkGrayColor]];
  [mCommentsResultTextField setTextColor:[NSColor darkGrayColor]];

  NSFont *resultTextFont = [NSFont fontWithName:@"Monaco" size:9];
  [mBlogsResultTextField setFont:resultTextFont];
  [mPostsResultTextField setFont:resultTextFont];
  [mCommentsResultTextField setFont:resultTextFont];

  [self updateUI];
}

- (void)dealloc {
  [mBlogFeed release];
  [mBlogFeedTicket release];
  [mBlogFetchError release];

  [mPostFeed release];
  [mPostFeedTicket release];
  [mPostFetchError release];

  [mEditPostTicket release];

  [mCommentFeed release];
  [mCommentFeedTicket release];
  [mCommentFetchError release];

  [super dealloc];
}

#pragma mark -

- (void)updateUI {

  // blogs list display
  [mBlogsTable reloadData];

  if (mBlogFeedTicket != nil) {
    [mBlogsProgressIndicator startAnimation:self];
  } else {
    [mBlogsProgressIndicator stopAnimation:self];
  }

  // blogs fetch result or selected item
  NSString *blogsResultStr = @"";
  if (mBlogFetchError) {
    blogsResultStr = [mBlogFetchError description];
  } else {
    GDataEntryBlog *blog = [self selectedBlog];
    if (blog) {
      blogsResultStr = [blog description];
    }
  }
  [mBlogsResultTextField setString:blogsResultStr];

  // post list display
  [mPostsTable reloadData];

  if (mPostFeedTicket != nil) {
    [mPostsProgressIndicator startAnimation:self];
  } else {
    [mPostsProgressIndicator stopAnimation:self];
  }

  // post fetch result or selected item
  NSString *postResultStr = @"";
  if (mPostFetchError) {
    postResultStr = [mPostFetchError description];
  } else {
    if ([self selectedPost] != nil) {
      postResultStr = [[self selectedPost] description];
    }
  }
  [mPostsResultTextField setString:postResultStr];

  // enable/disable edit buttons
  BOOL isBlogSelected = ([self selectedBlog] != nil);
  [mAddPostButton setEnabled:isBlogSelected];

  BOOL isPostSelected = ([self selectedPost] != nil);
  [mDeletePostButton setEnabled:isPostSelected];
  [mPostDraftCheckBox setEnabled:isPostSelected];

  BOOL canUpdatePost = NO;

  if (isPostSelected) {
    // the post can be updated if either the text or the draft checkbox state
    // has changed
    NSString *postStr = [[[self selectedPost] content] stringValue];
    NSString *editedStr = [mPostEditField stringValue];

    BOOL isPostDraft = [[[self selectedPost] atomPubControl] isDraft];
    BOOL isEditedDraft = ([mPostDraftCheckBox state] == NSOnState);

    canUpdatePost = ![postStr isEqual:editedStr]
      || (isPostDraft != isEditedDraft);
  }
  [mUpdatePostButton setEnabled:canUpdatePost];

  if (mEditPostTicket != nil) {
    [mEditProgressIndicator startAnimation:self];
  } else {
    [mEditProgressIndicator stopAnimation:self];
  }

  // comment list display
  [mCommentsTable reloadData];

  if (mCommentFeedTicket != nil) {
    [mCommentsProgressIndicator startAnimation:self];
  } else {
    [mCommentsProgressIndicator stopAnimation:self];
  }

  // comment fetch result or selected item
  NSString *commentResultStr = @"";
  if (mCommentFetchError) {
    commentResultStr = [mCommentFetchError description];
  } else {
    if ([self selectedComment] != nil) {
      commentResultStr = [[self selectedComment] description];
    }
  }
  [mCommentsResultTextField setString:commentResultStr];
}

- (void)reloadEntryEditField {
  GDataEntryBlogPost *entry = [self selectedPost];
  if (entry) {
    [mPostEditField setStringValue:[[entry content] stringValue]];

    BOOL isDraft = [[entry atomPubControl] isDraft];
    [mPostDraftCheckBox setState:(isDraft ? NSOnState : NSOffState)];
  }
}

#pragma mark IBActions
- (IBAction)getBlogsClicked:(id)sender {

  NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];

  NSString *username = [mUsernameField stringValue];
  username = [username stringByTrimmingCharactersInSet:whitespace];

  if ([username rangeOfString:@"@"].location == NSNotFound) {
    // if no domain was supplied, add @gmail.com
    username = [username stringByAppendingString:@"@gmail.com"];
  }

  [mUsernameField setStringValue:username];

  [self fetchAllBlogs];
}

- (IBAction)addPostClicked:(id)sender {
  [self addEntry];
}

- (IBAction)updatePostClicked:(id)sender {
  [self updateSelectedPost];
}

- (IBAction)deletePostClicked:(id)sender {
  [self deleteSelectedPost];
}

- (IBAction)draftCheckboxClicked:(id)sender {
  [self updateUI];
}

- (IBAction)loggingCheckboxClicked:(id)sender {
  [GDataHTTPFetcher setIsLoggingEnabled:[sender state]];
}

#pragma mark -

// get a google service object with the current username/password
//
// A "service" object handles networking tasks.  Service objects
// contain user authentication information as well as networking
// state information (such as cookies and the "last modified" date for
// fetched data.)

- (GDataServiceGoogleBlogger *)bloggerService {

  static GDataServiceGoogleBlogger* service = nil;

  if (!service) {
    service = [[GDataServiceGoogleBlogger alloc] init];

    [service setShouldCacheDatedData:YES];
    [service setServiceShouldFollowNextLinks:YES];
  }

  // update the name/password each time the service is requested
  NSString *username = [mUsernameField stringValue];
  NSString *password = [mPasswordField stringValue];

  [service setUserCredentialsWithUsername:username
                                 password:password];

  return service;
}

// get the blog selected in the top list, or nil if none
- (GDataEntryBlog *)selectedBlog {

  NSArray *blogs = [mBlogFeed entries];
  int rowIndex = [mBlogsTable selectedRow];
  if ([blogs count] > 0 && rowIndex > -1) {

    GDataEntryBlog *blog = [blogs objectAtIndex:rowIndex];
    return blog;
  }
  return nil;
}

// get the entry selected in the bottom list, or nil if none
- (GDataEntryBlogPost *)selectedPost {

  NSArray *entries = [mPostFeed entries];
  int rowIndex = [mPostsTable selectedRow];
  if ([entries count] > 0 && rowIndex > -1) {

    GDataEntryBlogPost *entry = [entries objectAtIndex:rowIndex];
    return entry;
  }
  return nil;
}

// get the entry selected in the bottom list, or nil if none
- (GDataEntryBlogComment *)selectedComment {

  NSArray *entries = [mCommentFeed entries];
  int rowIndex = [mCommentsTable selectedRow];
  if ([entries count] > 0 && rowIndex > -1) {

    GDataEntryBlogComment *entry = [entries objectAtIndex:rowIndex];
    return entry;
  }
  return nil;
}

#pragma mark Fetch all blogs

// begin retrieving the list of the user's blogs
- (void)fetchAllBlogs {

  [self setBlogFeed:nil];
  [self setBlogFetchError:nil];

  [self setPostFeed:nil];
  [self setPostFetchError:nil];

  [self setCommentFeed:nil];
  [self setCommentFetchError:nil];

  NSURL* feedURL = [GDataServiceGoogleBlogger blogFeedURLForUserID:kGDataServiceDefaultUser];

  GDataServiceGoogleBlogger *service = [self bloggerService];
  GDataServiceTicket *ticket;

  ticket = [service fetchFeedWithURL:feedURL
                           feedClass:[GDataFeedBlog class]
                            delegate:self
                   didFinishSelector:@selector(blogListTicket:finishedWithFeed:error:)];
  [self setBlogFeedTicket:ticket];

  [self updateUI];
}

// blog feed fetch callback
- (void)blogListTicket:(GDataServiceTicket *)ticket
      finishedWithFeed:(GDataFeedBase *)feed
                 error:(NSError *)error {

  [self setBlogFeed:feed];
  [self setBlogFetchError:error];
  [self setBlogFeedTicket:nil];

  [self updateUI];
}

#pragma mark Fetch a blog's posts

// for the blog selected in the top list, begin retrieving the list of
// entries
- (void)fetchPostsForSelectedBlog {

  GDataEntryBlog *blog = [self selectedBlog];
  if (blog != nil) {

    [self setPostFeed:nil];
    [self setPostFetchError:nil];

    [self setCommentFeed:nil];
    [self setCommentFetchError:nil];

    NSURL *feedURL = [[blog feedLink] URL];

    GDataServiceGoogleBlogger *service = [self bloggerService];
    GDataServiceTicket *ticket;
    ticket = [service fetchFeedWithURL:feedURL
                             feedClass:[GDataFeedBlogPost class]
                              delegate:self
                     didFinishSelector:@selector(blogPostTicket:finishedWithFeed:error:)];
    [self setPostFeedTicket:ticket];
    [self updateUI];
  }
}

// post feed fetch callback
- (void)blogPostTicket:(GDataServiceTicket *)ticket
         finishedWithFeed:(GDataFeedBase *)feed
                 error:(NSError *)error {

  [self setPostFeed:feed];
  [self setPostFetchError:error];
  [self setPostFeedTicket:nil];

  [self updateUI];
}

#pragma mark Fetch a blog post's comments

// for the post selected in the middle list, begin retrieving the feed of
// comments
- (void)fetchCommentsForSelectedPost {

  GDataEntryBlogPost *post = [self selectedPost];
  if (post != nil) {

    [self setCommentFeed:nil];
    [self setCommentFetchError:nil];

    NSURL *feedURL = [[post repliesAtomLink] URL];
    if (feedURL != nil) {
      GDataServiceGoogleBlogger *service = [self bloggerService];
      GDataServiceTicket *ticket;
      ticket = [service fetchFeedWithURL:feedURL
                               feedClass:[GDataFeedBlogComment class]
                                delegate:self
                       didFinishSelector:@selector(blogCommentTicket:finishedWithFeed:error:)];
      [self setCommentFeedTicket:ticket];
    }
  }
  [self updateUI];
}

// fetched comment feed callback
- (void)blogCommentTicket:(GDataServiceTicket *)ticket
         finishedWithFeed:(GDataFeedBase *)feed
                    error:(NSError *)error {

  [self setCommentFeed:feed];
  [self setCommentFetchError:error];
  [self setCommentFeedTicket:nil];

  [self updateUI];
}

#pragma mark Add an entry

- (void)addEntry {
  GDataEntryBlogPost *newEntry = [GDataEntryBlogPost postEntry];

  NSString *title = [NSString stringWithFormat:@"Post Created %@",
                     [NSDate date]];
  NSString *content = [mPostEditField stringValue];
  BOOL isDraft = [mPostDraftCheckBox state];

  [newEntry setTitleWithString:title];
  [newEntry setContentWithString:content];
  [newEntry addAuthor:[GDataPerson personWithName:@"Blogger Sample App"
                                            email:nil]];
  GDataAtomPubControl *atomPub;
  atomPub = [GDataAtomPubControl atomPubControlWithIsDraft:isDraft];
  [newEntry setAtomPubControl:atomPub];

  NSURL *postURL = [[[self selectedBlog] postLink] URL];
  if (postURL != nil) {
    GDataServiceGoogleBlogger *service = [self bloggerService];
    [service setServiceUserData:newEntry];

    GDataServiceTicket *ticket;
    ticket = [service fetchEntryByInsertingEntry:newEntry
                                      forFeedURL:postURL
                                        delegate:self
                               didFinishSelector:@selector(addEntryTicket:finishedWithEntry:error:)];
    [self setEditPostTicket:ticket];
    [self updateUI];
  }
}

// add entry callback
- (void)addEntryTicket:(GDataServiceTicket *)ticket
     finishedWithEntry:(GDataEntryBlogPost *)addedEntry
                 error:(NSError *)error {

  if (error == nil) {
    NSBeginAlertSheet(@"Add", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Added entry: %@", [[addedEntry title] stringValue]);

    NSMutableArray *entries = [NSMutableArray arrayWithArray:[mPostFeed entries]];
    [entries insertObject:addedEntry atIndex:0];
    [mPostFeed setEntries:entries];
  } else {
    // failed to add entry
    GDataEntryBlogPost *addedEntry = [ticket postedObject];
    NSBeginAlertSheet(@"Add", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Failed to add entry: %@\nError: %@",
                      [[addedEntry title] stringValue], error);
  }

  [self setEditPostTicket:nil];
  [self updateUI];
}


#pragma mark Update an entry


- (void)updateSelectedPost {
  GDataEntryBlogPost *editedEntry = [[[self selectedPost] copy] autorelease];
  if (editedEntry) {

    // save the edited text into the entry
    [[editedEntry content] setStringValue:[mPostEditField stringValue]];

    BOOL isDraft = ([mPostDraftCheckBox state] == NSOnState);

    GDataAtomPubControl *atomPub = [editedEntry atomPubControl];
    if (atomPub == nil) {
      atomPub = [GDataAtomPubControl atomPubControl];
      [editedEntry setAtomPubControl:atomPub];
    }
    [atomPub setIsDraft:isDraft];

    // send the edited entry to the server
    GDataServiceGoogleBlogger *service = [self bloggerService];

    // remember the old entry; we'll replace the edited one with it later
    [service setServiceUserData:[self selectedPost]];

    GDataServiceTicket *ticket;
    ticket = [service fetchEntryByUpdatingEntry:editedEntry
                                       delegate:self
                              didFinishSelector:@selector(updateTicket:finishedWithEntry:error:)];
    [self setEditPostTicket:ticket];
    [self updateUI];
  }
}

// update entry callback
- (void)updateTicket:(GDataServiceTicket *)ticket
   finishedWithEntry:(GDataEntryBlogPost *)editedEntry
               error:(NSError *)error {
  if (error == nil) {
    NSBeginAlertSheet(@"Update", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Updated entry: %@",
                      [[editedEntry title] stringValue]);

    GDataEntryBlogPost *oldEntry = [ticket userData];
    NSMutableArray *entries = [NSMutableArray arrayWithArray:[mPostFeed entries]];
    unsigned int indexOfOldEntry = [entries indexOfObject:oldEntry];
    if (indexOfOldEntry != NSNotFound) {
      [entries replaceObjectAtIndex:indexOfOldEntry withObject:editedEntry];
      [mPostFeed setEntries:entries];
    }
  } else {
    // update failed
    GDataEntryBlogPost *editedEntry = [ticket userData];
    NSBeginAlertSheet(@"Update", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Failed to update entry: %@\nError: %@",
                      [[editedEntry title] stringValue], error);
  }

  [self setEditPostTicket:nil];
  [self updateUI];
}

#pragma mark Delete an entry

- (void)deleteSelectedPost {
  GDataEntryBlogPost *entry = [self selectedPost];
  if (entry) {
    GDataServiceGoogleBlogger *service = [self bloggerService];
    [service setServiceUserData:entry]; // remember which entry we're deleting

    GDataServiceTicket *ticket;
    ticket = [service deleteEntry:entry
                         delegate:self
                didFinishSelector:@selector(deleteTicket:finishedWithNil:error:)];

    [ticket setUserData:entry];
    [self setEditPostTicket:ticket];
    [self updateUI];
  }
}

- (void)deleteTicket:(GDataServiceTicket *)ticket
     finishedWithNil:(id)object
               error:(NSError *)error {
  GDataEntryBlogPost *entry = [ticket userData];

  if (error == nil) {

    NSBeginAlertSheet(@"Delete", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Deleted entry: %@",
                      [[entry title] stringValue]);

    // remove the deleted entry from the list
    NSMutableArray *entries = [NSMutableArray arrayWithArray:[mPostFeed entries]];

    if ([entries containsObject:entry]) {
      [entries removeObject:entry];
      [mPostFeed setEntries:entries];
    }

    [self reloadEntryEditField];

  } else {
    // delete failed
    NSBeginAlertSheet(@"Delete", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Failed to delete entry: %@\nError: %@",
                      [[entry title] stringValue], error);
  }

  [self setEditPostTicket:nil];
  [self updateUI];
}

#pragma mark Text field delegate methods

- (void)controlTextDidChange:(NSNotification *)note {
  if ([note object] == mPostEditField) {

    [self updateUI]; // enabled/disable the Update button
  }
}

#pragma mark TableView delegate methods
//
// table view delegate methods
//

- (void)tableViewSelectionDidChange:(NSNotification *)notification {

  id object = [notification object];
  if (object == mBlogsTable) {
    // the user clicked on a blog, so fetch its entries
    [self fetchPostsForSelectedBlog];
  } else if (object == mPostsTable) {
    // the user clicked on an blog post; display it below the posts table
    [self reloadEntryEditField];

    // fetch the comment list for the selected post
    [self fetchCommentsForSelectedPost];
  } else {
    // the user clicked on a comment; redisplay the results field
    [self updateUI];
  }
}

// table view data source methods
- (GDataFeedBase *)feedForTableView:(NSTableView *)tableView {
  GDataFeedBase *feed;
  if (tableView == mBlogsTable) {
    feed = mBlogFeed;
  } else if (tableView == mPostsTable) {
    feed = mPostFeed;
  } else {
    feed = mCommentFeed;
  }
  return feed;
}

- (int)numberOfRowsInTableView:(NSTableView *)tableView {
  return [[[self feedForTableView:tableView] entries] count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
  GDataFeedBase *feed = [self feedForTableView:tableView];
  GDataEntryBase *entry = [feed entryAtIndex:row];
  return [[entry title] stringValue];
}

#pragma mark Setters and Getters

- (GDataFeedBase *)blogFeed {
  return mBlogFeed;
}

- (void)setBlogFeed:(GDataFeedBase *)feed {
  [mBlogFeed autorelease];
  mBlogFeed = [feed retain];
}

- (NSError *)blogFetchError {
  return mBlogFetchError;
}

- (void)setBlogFetchError:(NSError *)error {
  [mBlogFetchError release];
  mBlogFetchError = [error retain];
}

- (GDataServiceTicket *)blogFeedTicket {
  return mBlogFeedTicket;
}

- (void)setBlogFeedTicket:(GDataServiceTicket *)ticket {
  [mBlogFeedTicket autorelease];
  mBlogFeedTicket = [ticket retain];
}

- (GDataFeedBase *)postFeed {
  return mPostFeed;
}

- (void)setPostFeed:(GDataFeedBase *)feed {
  [mPostFeed autorelease];
  mPostFeed = [feed retain];
}

- (NSError *)postFetchError {
  return mPostFetchError;
}

- (void)setPostFetchError:(NSError *)error {
  [mPostFetchError release];
  mPostFetchError = [error retain];
}

- (GDataServiceTicket *)postFeedTicket {
  return mPostFeedTicket;
}

- (void)setPostFeedTicket:(GDataServiceTicket *)ticket {
  [mPostFeedTicket autorelease];
  mPostFeedTicket = [ticket retain];
}

- (GDataFeedBase *)commentFeed {
  return mCommentFeed;
}

- (void)setCommentFeed:(GDataFeedBase *)feed {
  [mCommentFeed autorelease];
  mCommentFeed = [feed retain];
}

- (NSError *)commentFetchError {
  return mCommentFetchError;
}

- (void)setCommentFetchError:(NSError *)error {
  [mCommentFetchError release];
  mCommentFetchError = [error retain];
}

- (GDataServiceTicket *)commentFeedTicket {
  return mCommentFeedTicket;
}

- (void)setCommentFeedTicket:(GDataServiceTicket *)ticket {
  [mCommentFeedTicket autorelease];
  mCommentFeedTicket = [ticket retain];
}

- (GDataServiceTicket *)editPostTicket {
  return mEditPostTicket;
}

- (void)setEditPostTicket:(GDataServiceTicket *)ticket {
  [mEditPostTicket autorelease];
  mEditPostTicket = [ticket retain];
}

@end
