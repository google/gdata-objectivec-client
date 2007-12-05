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
//  BloggerSampleWindowController.m
//

#import "BloggerSampleWindowController.h"

@interface BloggerSampleWindowController (PrivateMethods)
- (void)updateUI;

- (void)fetchAllBlogs;
- (void)fetchSelectedBlogEntries;
- (void)addEntry;
- (void)updateSelectedEntry;
- (void)deleteSelectedEntry;

- (GDataServiceGoogle *)bloggerService;
- (GDataEntryBase *)selectedBlog;
- (GDataEntryBase *)selectedEntry;

- (GDataFeedBase *)blogsFeed;
- (void)setBlogsFeed:(GDataFeedBase *)feed;
- (NSError *)blogsFetchError;
- (void)setBlogsFetchError:(NSError *)error;  

- (GDataFeedBase *)entriesFeed;
- (void)setEntriesFeed:(GDataFeedBase *)feed;
- (NSError *)entriesFetchError;
- (void)setEntriesFetchError:(NSError *)error;
  
@end

@implementation BloggerSampleWindowController

static BloggerSampleWindowController* gBloggerSampleWindowController = nil;


+ (BloggerSampleWindowController *)sharedBloggerSampleWindowController {
  
  if (!gBloggerSampleWindowController) {
    gBloggerSampleWindowController = [[BloggerSampleWindowController alloc] init];
  }  
  return gBloggerSampleWindowController;
}


- (id)init {
  return [self initWithWindowNibName:@"BloggerSampleWindow"];
}

- (void)windowDidLoad {
}

- (void)awakeFromNib {
  [self updateUI];
}

- (void)dealloc {
  [mBlogsFeed release];
  [mBloggerFetchError release];
  
  [mEntriesFeed release];
  [mEntriesFetchError release];
  
  [super dealloc];
}

#pragma mark -

- (void)updateUI {
  
  // blogs list display
  [mBlogsTable reloadData]; 
  
  if (mIsBloggerFetchPending) {
    [mBlogsProgressIndicator startAnimation:self];  
  } else {
    [mBlogsProgressIndicator stopAnimation:self];  
  }
  
  // blogs fetch result or selected item
  NSString *blogsResultStr = @"";
  if (mBloggerFetchError) {
    blogsResultStr = [mBloggerFetchError description];
  } else {
    GDataEntryBase *blog = [self selectedBlog];
    if (blog) {
      blogsResultStr = [blog description];
    } else {
      
    }
  }
  [mBlogsResultTextField setStringValue:blogsResultStr];
  [mBlogsResultTextField setToolTip:blogsResultStr];
  
  // entry list display
  [mEntriesTable reloadData]; 
  
  if (mIsEntriesFetchPending) {
    [mEntriesProgressIndicator startAnimation:self];  
  } else {
    [mEntriesProgressIndicator stopAnimation:self];  
  }
  
  // entry fetch result or selected item
  NSString *entryResultStr = @"";
  if (mEntriesFetchError) {
    entryResultStr = [mEntriesFetchError description];
  } else {
    if ([self selectedEntry]) {
      entryResultStr = [[self selectedEntry] description];
    }
  }
  [mEntriesResultTextField setStringValue:entryResultStr];
  [mEntriesResultTextField setToolTip:entryResultStr];
  
  // enable/disable buttons
  BOOL isBlogSelected = ([self selectedBlog] != nil);
  [mAddPostButton setEnabled:isBlogSelected];
  
  BOOL isEntrySelected = ([self selectedEntry] != nil);
  [mDeletePostButton setEnabled:isEntrySelected];
  
  BOOL canUpdateEntry = NO;
  
  if (isEntrySelected) {
    NSString *entryStr = [[[self selectedEntry] content] stringValue];
    NSString *editedStr = [mEntryEditField stringValue];
    
    canUpdateEntry = ![entryStr isEqual:editedStr];
  }
  [mUpdatePostButton setEnabled:canUpdateEntry];
  
}

- (void)reloadEntryEditField {
  GDataEntryBase *entry = [self selectedEntry];
  if (entry) {
    [mEntryEditField setStringValue:[[entry content] stringValue]];
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
  [self updateSelectedEntry];
}

- (IBAction)deletePostClicked:(id)sender {
  [self deleteSelectedEntry];
}

#pragma mark -

// get a google service object with the current username/password
//
// A "service" object handles networking tasks.  Service objects
// contain user authentication information as well as networking
// state information (such as cookies and the "last modified" date for
// fetched data.)

- (GDataServiceGoogle *)bloggerService {
  
  static GDataServiceGoogle* service = nil;
  
  if (!service) {
    service = [[GDataServiceGoogle alloc] init];
    
    [service setUserAgent:@"Google-SampleBloggerApp-1.0"];
    
    [service setShouldCacheDatedData:YES];
    [service setServiceShouldFollowNextLinks:YES];
    [service setServiceID:@"blogger"];
  }

  // update the name/password each time the service is requested
  NSString *username = [mUsernameField stringValue];
  NSString *password = [mPasswordField stringValue];
  
  [service setUserCredentialsWithUsername:username
                                 password:password];

  return service;
}

// get the blog selected in the top list, or nil if none
- (GDataEntryBase *)selectedBlog {
  
  NSArray *blogs = [mBlogsFeed entries];
  int rowIndex = [mBlogsTable selectedRow];
  if ([blogs count] > 0 && rowIndex > -1) {
    
    GDataEntryBase *blog = [blogs objectAtIndex:rowIndex];
    return blog;
  }
  return nil;
}

// get the entry selected in the bottom list, or nil if none
- (GDataEntryBase *)selectedEntry {
  
  NSArray *entries = [mEntriesFeed entries];
  int rowIndex = [mEntriesTable selectedRow];
  if ([entries count] > 0 && rowIndex > -1) {
    
    GDataEntryBase *entry = [entries objectAtIndex:rowIndex];
    return entry;
  }
  return nil;
}

#pragma mark Fetch all blogs

// begin retrieving the list of the user's blogs
- (void)fetchAllBlogs {
  
  [self setBlogsFeed:nil];
  [self setBlogsFetchError:nil];    
  
  [self setEntriesFeed:nil];
  [self setEntriesFetchError:nil];
  
  mIsBloggerFetchPending = YES;

  NSString *username = [mUsernameField stringValue];
  NSString *password = [mPasswordField stringValue];
  
  NSURL* url = [NSURL URLWithString:@"http://www.blogger.com/feeds/default/blogs"];
  
  GDataServiceGoogle *service = [self bloggerService];
  [service setUserCredentialsWithUsername:username
                                 password:password];
  
  [service fetchAuthenticatedFeedWithURL:url
                               feedClass:kGDataUseRegisteredClass
                                delegate:self
                       didFinishSelector:@selector(feedTicket:finishedWithFeed:)
                         didFailSelector:@selector(feedTicket:failedWithError:)];
  
  [self updateUI];

}

//
// blog list fetch callbacks
//

// finished blog list successfully
- (void)feedTicket:(GDataServiceTicket *)ticket
 finishedWithFeed:(GDataFeedBase *)object {
  
  [self setBlogsFeed:object];
  [self setBlogsFetchError:nil];    
  
  mIsBloggerFetchPending = NO;
  [self updateUI];
} 

// failed
- (void)feedTicket:(GDataServiceTicket *)ticket
   failedWithError:(NSError *)error {
  
  [self setBlogsFeed:nil];
  [self setBlogsFetchError:error];    
  
  mIsBloggerFetchPending = NO;
  [self updateUI];
}

#pragma mark Fetch a blog's entries 

// for the blog selected in the top list, begin retrieving the list of
// entries
- (void)fetchSelectedBlogEntries {
  
  GDataEntryBase *blog = [self selectedBlog];
  if (blog) {
    
    GDataLink *link = [[blog links] feedLink];
    NSString *href = [link href];
    
    if ([href length] > 0) {
      
      [self setEntriesFeed:nil];
      [self setEntriesFetchError:nil];
      mIsEntriesFetchPending = YES;

      GDataServiceGoogle *service = [self bloggerService];
      [service fetchAuthenticatedFeedWithURL:[NSURL URLWithString:href]
                                   feedClass:kGDataUseRegisteredClass
                                    delegate:self
                           didFinishSelector:@selector(fetchEntriesTicket:finishedWithEntries:)
                             didFailSelector:@selector(fetchEntriesTicket:failedWithError:)];
      [self updateUI];  
    }
  }
   
}

//
// entries list fetch callbacks
//

// fetched entry list successfully
- (void)fetchEntriesTicket:(GDataServiceTicket *)ticket
 finishedWithEntries:(GDataFeedBase *)object {
  
  [self setEntriesFeed:object];
  [self setEntriesFetchError:nil];
  
  mIsEntriesFetchPending = NO;
  
  [self updateUI];
} 

// failed
- (void)fetchEntriesTicket:(GDataServiceTicket *)ticket
failedWithError:(NSError *)error {
  
  [self setEntriesFeed:nil];
  [self setEntriesFetchError:error];
  
  mIsEntriesFetchPending = NO;
  
  [self updateUI];
  
}

#pragma mark Add an entry

- (void)addEntry {
  GDataEntryBase *newEntry = [GDataEntryBase entry];
  
  NSString *title = @"New Post";
  NSString *content = [mEntryEditField stringValue];
  
  [newEntry setTitleWithString:title];
  [newEntry setContent:[GDataTextConstruct textConstructWithString:content]];
  [newEntry addAuthor:[GDataPerson personWithName:@"Blogger Sample App"
                                            email:nil]];
    
  NSURL* postURL = [[[[self selectedBlog] links] postLink] URL];
  if (postURL) {
    mIsEntriesFetchPending = YES;
    
    GDataServiceGoogle *service = [self bloggerService];
    [service setServiceUserData:newEntry];
    [service fetchAuthenticatedEntryByInsertingEntry:newEntry
                                        forFeedURL:postURL
                                           delegate:self
                                  didFinishSelector:@selector(addEntryTicket:finishedWithEntry:)
                                    didFailSelector:@selector(addEntryTicket:failedWithError:)];  
    
    [self updateUI];
  }
}

// succeeded
- (void)addEntryTicket:(GDataServiceTicket *)ticket
     finishedWithEntry:(GDataEntryBase *)addedEntry {
  
  NSBeginAlertSheet(@"Add", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Added entry: %@", [[addedEntry title] stringValue]);
  
  NSMutableArray *entries = [NSMutableArray arrayWithArray:[mEntriesFeed entries]];
  [entries insertObject:addedEntry atIndex:0];
  [mEntriesFeed setEntries:entries];
  
  mIsEntriesFetchPending = NO;
  [self updateUI];
} 

// failed
- (void)addEntryTicket:(GDataServiceTicket *)ticket
       failedWithError:(NSError *)error {
  
  GDataEntryBase *addedEntry = [ticket userData];
  NSBeginAlertSheet(@"Add", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Failed to add entry: %@\nError: %@", [[addedEntry title] stringValue], error);
  
  mIsEntriesFetchPending = NO;
  [self updateUI];
  
}

#pragma mark Update an entry


- (void)updateSelectedEntry {
  GDataEntryBase *editedEntry = [[[self selectedEntry] copy] autorelease];
  if (editedEntry) {
    
    // save the edited text into the entry
    [[editedEntry content] setStringValue:[mEntryEditField stringValue]];

    // the entry, detached, needs namespaces to be valid
    [editedEntry setNamespaces:[GDataEntryBase baseGDataNamespaces]];
      
    // send the edited entry to the server
    NSURL *linkURL = [[[editedEntry links] editLink] URL];
    
    mIsEntriesFetchPending = YES;
    
    GDataServiceGoogle *service = [self bloggerService];
    [service setServiceUserData:[self selectedEntry]]; // remember the old entry; we'll replace the edited one with it later
    [service fetchAuthenticatedEntryByUpdatingEntry:editedEntry
                                        forEntryURL:linkURL
                                           delegate:self
                                  didFinishSelector:@selector(updateTicket:finishedWithEntry:)
                                    didFailSelector:@selector(updateTicket:failedWithError:)];
    

    [self updateUI];
  }
  
}

- (void)updateTicket:(GDataServiceTicket *)ticket
   finishedWithEntry:(GDataEntryBase *)editedEntry {
  
  mIsEntriesFetchPending = NO;
  
  NSBeginAlertSheet(@"Update", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Updated entry: %@", [[editedEntry title] stringValue]);
  
  GDataEntryBase *oldEntry = [ticket userData];
  NSMutableArray *entries = [NSMutableArray arrayWithArray:[mEntriesFeed entries]];
  unsigned int indexOfOldEntry = [entries indexOfObject:oldEntry];
  if (indexOfOldEntry != NSNotFound) {
    [entries replaceObjectAtIndex:indexOfOldEntry withObject:editedEntry];
    [mEntriesFeed setEntries:entries];
  }
  
  [self updateUI];
} 

// failed
- (void)updateTicket:(GDataServiceTicket *)ticket
failedWithError:(NSError *)error {
    
  GDataEntryBase *editedEntry = [ticket userData];
  NSBeginAlertSheet(@"Update", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Failed to update entry: %@\nError: %@", [[editedEntry title] stringValue], error);
  
  mIsEntriesFetchPending = NO;
  
  [self updateUI];
}

#pragma mark Delete an entry

- (void)deleteSelectedEntry {
  GDataEntryBase *entry = [[[self selectedEntry] copy] autorelease];
  if (entry) {
        
    // send the edited entry to the server
    GDataLink *link = [[entry links] editLink];
        
    mIsEntriesFetchPending = YES;
    
    GDataServiceGoogle *service = [self bloggerService];
    [service setServiceUserData:[self selectedEntry]]; // remember which entry we're deleting
    [service deleteAuthenticatedResourceURL:[link URL]
                                   delegate:self
                          didFinishSelector:@selector(deleteTicket:finishedWithNilObject:)
                            didFailSelector:@selector(deleteTicket:failedWithError:)];
    [self updateUI];
  }
}

- (void)deleteTicket:(GDataServiceTicket *)ticket
 finishedWithNilObject:(id)object {
  
  mIsEntriesFetchPending = NO;
  
  GDataEntryBase *entry = [ticket userData];

  NSBeginAlertSheet(@"Delete", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Deleted entry: %@", [[entry title] stringValue]);
    
  // remove the deleted entry from the list
  NSMutableArray *entries = [NSMutableArray arrayWithArray:[mEntriesFeed entries]];
  if ([entries containsObject:entry]) {
    [entries removeObject:entry];
    [mEntriesFeed setEntries:entries];
  }
    
  [self updateUI];
  
  [self reloadEntryEditField];
} 

// failed
- (void)deleteTicket:(GDataServiceTicket *)ticket
failedWithError:(NSError *)error {
  
  GDataEntryBase *entry = [ticket userData];
  
  NSBeginAlertSheet(@"Delete", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Failed to delete entry: %@\nError: %@", [[entry title] stringValue], error);
  
  mIsEntriesFetchPending = NO;
  
  [self updateUI];
  
}


#pragma mark Add an entry

#pragma mark Text field delegate methods

- (void)controlTextDidChange:(NSNotification *)note {
  if ([note object] == mEntryEditField) {
    
    [self updateUI]; // enabled/disable the Update button
  }
}

#pragma mark TableView delegate methods
//
// table view delegate methods
//

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  
  if ([notification object] == mBlogsTable) {
    // the user clicked on a blog, so fetch its entries
    [self fetchSelectedBlogEntries];
  } else {
    // the user clicked on an entry; just display it below the entry table
    [self reloadEntryEditField];
    
    [self updateUI]; 
  }
}

// table view data source methods
- (int)numberOfRowsInTableView:(NSTableView *)tableView {
  if (tableView == mBlogsTable) {
    return [[mBlogsFeed entries] count];
  } else {
    return [[mEntriesFeed entries] count];
  }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
  if (tableView == mBlogsTable) {
    // get the blog entry's title
    GDataEntryBase *blog = [[mBlogsFeed entries] objectAtIndex:row];
    return [[blog title] stringValue];
  } else {
    // get the entry's title
    GDataEntryBase *entry = [[mEntriesFeed entries] objectAtIndex:row];
    return [[entry title] stringValue];
  }
}

#pragma mark Setters and Getters

- (GDataFeedBase *)blogsFeed {
  return mBlogsFeed; 
}

- (void)setBlogsFeed:(GDataFeedBase *)feed {
  [mBlogsFeed autorelease];
  mBlogsFeed = [feed retain];
}

- (NSError *)blogsFetchError {
  return mBloggerFetchError; 
}

- (void)setBlogsFetchError:(NSError *)error {
  [mBloggerFetchError release];
  mBloggerFetchError = [error retain];
}

- (GDataFeedBase *)entriesFeed {
  return mEntriesFeed; 
}

- (void)setEntriesFeed:(GDataFeedBase *)feed {
  [mEntriesFeed autorelease];
  mEntriesFeed = [feed retain];
}

- (NSError *)entriesFetchError {
  return mEntriesFetchError; 
}

- (void)setEntriesFetchError:(NSError *)error {
  [mEntriesFetchError release];
  mEntriesFetchError = [error retain];
}


@end
