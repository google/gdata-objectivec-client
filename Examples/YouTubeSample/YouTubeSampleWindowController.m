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
//  YouTubeSampleWindowController.m
//

#import "YouTubeSampleWindowController.h"
#import "GData/GDataServiceGoogleYouTube.h"
#import "GData/GDataEntryPhotoAlbum.h"
#import "GData/GDataEntryPhoto.h"
#import "GData/GDataFeedPhoto.h"
#import "GData/GDataEntryYouTubeUpload.h"

static NSString* const kActivityFeed = @"activity";

@interface YouTubeSampleWindowController (PrivateMethods)
- (void)updateUI;

- (void)fetchEntryImageURLString:(NSString *)urlString;

- (GDataEntryBase *)selectedEntry;
- (void)fetchAllEntries;
- (void)uploadVideoFile;

- (GDataFeedBase *)entriesFeed;
- (void)setEntriesFeed:(GDataFeedBase *)feed;

- (NSError *)entriesFetchError;
- (void)setEntriesFetchError:(NSError *)error;

- (GDataServiceTicket *)entriesFetchTicket;
- (void)setEntriesFetchTicket:(GDataServiceTicket *)ticket;

- (NSString *)entryImageURLString;
- (void)setEntryImageURLString:(NSString *)str;

- (GDataServiceTicket *)uploadTicket;
- (void)setUploadTicket:(GDataServiceTicket *)ticket;

- (GDataServiceGoogleYouTube *)youTubeService;

- (void)fetchStandardCategories;
@end

@implementation YouTubeSampleWindowController

static YouTubeSampleWindowController* gYouTubeSampleWindowController = nil;

+ (YouTubeSampleWindowController *)sharedYouTubeSampleWindowController {
  
  if (!gYouTubeSampleWindowController) {
    gYouTubeSampleWindowController = [[YouTubeSampleWindowController alloc] init];
  }  
  return gYouTubeSampleWindowController;
}

- (id)init {
  return [self initWithWindowNibName:@"YouTubeSampleWindow"];
}

- (void)awakeFromNib {
  // Set the result text fields to have a distinctive color and mono-spaced font
  // to aid in understanding of each album and photo query operation.
  [mEntriesResultTextField setTextColor:[NSColor darkGrayColor]];

  NSFont *resultTextFont = [NSFont fontWithName:@"Monaco" size:9];
  [mEntriesResultTextField setFont:resultTextFont];
  
  // load the user feed types into the pop-up menu, and default to showing
  // the feed of the user's uploads, as it's generally most interesting
  NSArray *userFeedTypes = [NSArray arrayWithObjects:
    kGDataYouTubeUserFeedIDContacts,
    kGDataYouTubeUserFeedIDFavorites,
    kGDataYouTubeUserFeedIDInbox,
    kGDataYouTubeUserFeedIDPlaylists,
    kGDataYouTubeUserFeedIDSubscriptions,
    kActivityFeed,
    kGDataYouTubeUserFeedIDFriendsActivity,
    kGDataYouTubeUserFeedIDUploads,
    nil];

  [mUserFeedPopup removeAllItems];
  [mUserFeedPopup addItemsWithTitles:userFeedTypes];
  [mUserFeedPopup selectItemWithTitle:kGDataYouTubeUserFeedIDUploads];
  
  // reset the upload file path
  [mFilePathField setStringValue:@""];
  
  [self updateUI];
  
  // start retrieving the list of assignable upload categories
  [self fetchStandardCategories];
}

- (void)dealloc {
  [mEntriesFeed release];
  [mEntriesFetchError release];
  [mEntriesFetchTicket release];
  [mEntryImageURLString release];

  [mUploadTicket release];
  
  [super dealloc];
}

#pragma mark -

// album and photo thumbnail display

// fetch or clear the thumbnail for this specified entry
- (void)updateImageForEntry:(GDataEntryBase *)entry {
  
  if (!entry || ![entry respondsToSelector:@selector(mediaGroup)]) {
    
    // clear the image; no entry is selected, or it's not an entry type with a 
    // thumbnail
    [mEntryImageView setImage:nil];
    [self setEntryImageURLString:nil];
    
  } else {    
    // if the new thumbnail URL string is different from the previous one,
    // save the new URL, clear the existing image and fetch the new image
    GDataEntryYouTubeVideo *video = (GDataEntryYouTubeVideo *)entry;

    GDataMediaThumbnail *thumbnail = [[video mediaGroup] highQualityThumbnail];
    if (thumbnail != nil) {
      NSString *imageURLString = [thumbnail URLString];
      if (!imageURLString || ![mEntryImageURLString isEqual:imageURLString]) {
        
        [self setEntryImageURLString:imageURLString];
        [mEntryImageView setImage:nil];

        if (imageURLString) {
          [self fetchEntryImageURLString:imageURLString];
        }
      } 
    }
  }
}

- (void)fetchEntryImageURLString:(NSString *)urlString {
  
  NSURL *imageURL = [NSURL URLWithString:urlString];
  NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
  GDataHTTPFetcher *fetcher = [GDataHTTPFetcher httpFetcherWithRequest:request];
  
  [fetcher beginFetchWithDelegate:self
                didFinishSelector:@selector(imageFetcher:finishedWithData:)
                  didFailSelector:@selector(imageFetcher:failedWithError:)];
}

- (void)imageFetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data {
  // got the data; display it in the image view
  NSImage *image = [[[NSImage alloc] initWithData:data] autorelease];
  
  [mEntryImageView setImage:image];
}

- (void)imageFetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error {
  NSLog(@"imageFetcher:%@ failedWithError:%@", fetcher,  error);       
}

#pragma mark -

- (void)updateUI {
  
  // entry list display
  [mEntriesTable reloadData]; 
  
  if (mEntriesFetchTicket != nil) {
    [mEntriesProgressIndicator startAnimation:self];  
  } else {
    [mEntriesProgressIndicator stopAnimation:self];  
  }
  
  // entry fetch result or selected item
  NSString *entriesResultStr = @"";
  if (mEntriesFetchError) {
    entriesResultStr = [mEntriesFetchError description];
    [self updateImageForEntry:nil];
  } else {
    GDataEntryBase *entry = [self selectedEntry];
    if (entry) {
      entriesResultStr = [entry description];
    }
    // fetch or clear the entry thumbnail
    [self updateImageForEntry:entry];
  }
  [mEntriesResultTextField setString:entriesResultStr];
  
  // show how many entries are in the table
  NSString *countStr = @"Entries: -";
  if (mEntriesFetchTicket == nil) {
    // not currently fetching; show the count
    unsigned int numEntries = [[mEntriesFeed entries] count];
    countStr = [NSString stringWithFormat:@"Entries: %u", numEntries];
  } 
  [mEntryCountField setStringValue:countStr];
  
  // enable the upload button only if all preconditions are met
  BOOL hasUsername = [[mUsernameField stringValue] length] > 0;
  BOOL hasPassword = [[mPasswordField stringValue] length] > 0;
  BOOL hasDevKey = [[mDeveloperKeyField stringValue] length] > 0;
  BOOL hasTitle = [[mTitleField stringValue] length] > 0;
  BOOL hasPath = [[mFilePathField stringValue] length] > 0;
  
  BOOL canUpload = hasUsername && hasPassword && hasDevKey
    && hasTitle && hasPath;
  
  BOOL isUploading = (mUploadTicket != nil);

  [mUploadButton setEnabled:(canUpload && !isUploading)];
  [mPauseUploadButton setEnabled:isUploading];
  [mStopUploadButton setEnabled:isUploading];

  BOOL isUploadPaused = [mUploadTicket isUploadPaused];
  NSString *pauseTitle = (isUploadPaused ? @"Resume" : @"Pause");
  [mPauseUploadButton setTitle:pauseTitle];
}

#pragma mark IBActions

- (IBAction)getEntriesClicked:(id)sender {
  
  NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];

  NSString *username = [mUsernameField stringValue];
  username = [username stringByTrimmingCharactersInSet:whitespace];

  [mUsernameField setStringValue:username];

  [self fetchAllEntries];
}

- (IBAction)cancelEntriesFetchClicked:(id)sender {
  [mEntriesFetchTicket cancelTicket];
  [self setEntriesFetchTicket:nil];
  [self updateUI];
}

- (IBAction)loggingCheckboxClicked:(id)sender {
  [GDataHTTPFetcher setIsLoggingEnabled:[sender state]]; 
}

- (IBAction)chooseFileClicked:(id)sender {
  // ask the user to choose a video file
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setPrompt:@"Choose"];
  
  NSArray *movieTypes = [NSArray arrayWithObjects:@"mov", @"mp4", nil];
  
  [openPanel beginSheetForDirectory:nil
                               file:nil
                              types:movieTypes
                     modalForWindow:[self window]
                      modalDelegate:self
                     didEndSelector:@selector(openSheetDidEnd:returnCode:contextInfo:)
                        contextInfo:nil];
}

- (void)openSheetDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo {
  
  if (returnCode == NSOKButton) {
    // the user chose a file
    NSString *path = [panel filename];
    
    [mFilePathField setStringValue:path];
    
    [self updateUI]; // update UI in case we need to enable the upload button
  }
}

- (IBAction)uploadClicked:(id)sender {
  
  [self uploadVideoFile];
}

- (IBAction)pauseUploadClicked:(id)sender {
  if ([mUploadTicket isUploadPaused]) {
    [mUploadTicket resumeUpload];
  } else {
    [mUploadTicket pauseUpload];
  }
  [self updateUI];
}

- (IBAction)stopUploadClicked:(id)sender {
  [mUploadTicket cancelTicket];
  [self setUploadTicket:nil];

  [mUploadProgressIndicator setDoubleValue:0.0];
  [self updateUI];
}

#pragma mark -

// get a YouTube service object with the current username/password
//
// A "service" object handles networking tasks.  Service objects
// contain user authentication information as well as networking
// state information (such as cookies and the "last modified" date for
// fetched data.)

- (GDataServiceGoogleYouTube *)youTubeService {
  
  static GDataServiceGoogleYouTube* service = nil;
  
  if (!service) {
    service = [[GDataServiceGoogleYouTube alloc] init];
    
    [service setShouldCacheDatedData:YES];
    [service setServiceShouldFollowNextLinks:YES];
    [service setIsServiceRetryEnabled:YES];
  }

  // update the username/password each time the service is requested
  NSString *username = [mUsernameField stringValue];
  NSString *password = [mPasswordField stringValue];
  
  if ([username length] > 0 && [password length] > 0) {
    [service setUserCredentialsWithUsername:username
                                   password:password];
  } else {
    // fetch unauthenticated
    [service setUserCredentialsWithUsername:nil
                                   password:nil];
  }

  NSString *devKey = [mDeveloperKeyField stringValue];
  [service setYouTubeDeveloperKey:devKey];

  return service;
}

// get the entry selected in the list, or nil if none
- (GDataEntryBase *)selectedEntry {
  
  NSArray *entries = [mEntriesFeed entries];
  int rowIndex = [mEntriesTable selectedRow];
  if ([entries count] > 0 && rowIndex > -1) {
    
    GDataEntryBase *entry = [entries objectAtIndex:rowIndex];
    return entry;
  }
  return nil;
}

#pragma mark Fetch all entries

// begin retrieving the list of the user's entries
- (void)fetchAllEntries {
  
  [self setEntriesFeed:nil];
  [self setEntriesFetchError:nil];
  [self setEntriesFetchTicket:nil];
  
  NSString *username = [mUsernameField stringValue];
  
  GDataServiceGoogleYouTube *service = [self youTubeService];
  GDataServiceTicket *ticket;
  
  // feedID is uploads, favorites, etc
  //
  // note that activity feeds require a developer key
  NSString *feedID = [[mUserFeedPopup selectedItem] title];
  
  NSURL *feedURL;
  if ([feedID isEqual:kActivityFeed]) {
    // the activity feed uses a unique URL
    feedURL = [GDataServiceGoogleYouTube youTubeActivityFeedURLForUserID:username];
  } else {
    feedURL = [GDataServiceGoogleYouTube youTubeURLForUserID:username
                                                  userFeedID:feedID];
  }
  
  ticket = [service fetchFeedWithURL:feedURL
                            delegate:self
                   didFinishSelector:@selector(entryListFetchTicket:finishedWithFeed:error:)];

  [self setEntriesFetchTicket:ticket];
  
  [self updateUI];
}

// feed fetch callback
- (void)entryListFetchTicket:(GDataServiceTicket *)ticket
            finishedWithFeed:(GDataFeedBase *)feed
                       error:(NSError *)error {

  [self setEntriesFeed:feed];
  [self setEntriesFetchError:error];
  [self setEntriesFetchTicket:nil];

  [self updateUI];
}

#pragma mark -

- (void)uploadVideoFile {
  
  NSString *devKey = [mDeveloperKeyField stringValue];
  
  GDataServiceGoogleYouTube *service = [self youTubeService];
  [service setYouTubeDeveloperKey:devKey];
  
  NSString *username = [mUsernameField stringValue];
  
  NSURL *url = [GDataServiceGoogleYouTube youTubeUploadURLForUserID:username];
  
  // load the file data
  NSString *path = [mFilePathField stringValue];
  NSData *data = [NSData dataWithContentsOfFile:path];
  NSString *filename = [path lastPathComponent];
  
  // gather all the metadata needed for the mediaGroup
  NSString *titleStr = [mTitleField stringValue];
  GDataMediaTitle *title = [GDataMediaTitle textConstructWithString:titleStr];
  
  NSString *categoryStr = [[mCategoryPopup selectedItem] representedObject];
  GDataMediaCategory *category = [GDataMediaCategory mediaCategoryWithString:categoryStr];
  [category setScheme:kGDataSchemeYouTubeCategory];
  
  NSString *descStr = [mDescriptionField stringValue];
  GDataMediaDescription *desc = [GDataMediaDescription textConstructWithString:descStr];
  
  NSString *keywordsStr = [mKeywordsField stringValue];
  GDataMediaKeywords *keywords = [GDataMediaKeywords keywordsWithString:keywordsStr];
  
  BOOL isPrivate = ([mPrivateCheckbox state] == NSOnState);
  
  GDataYouTubeMediaGroup *mediaGroup = [GDataYouTubeMediaGroup mediaGroup];
  [mediaGroup setMediaTitle:title];
  [mediaGroup setMediaDescription:desc];
  [mediaGroup addMediaCategory:category];
  [mediaGroup setMediaKeywords:keywords];
  [mediaGroup setIsPrivate:isPrivate];
 
  NSString *mimeType = [GDataUtilities MIMETypeForFileAtPath:path
                                             defaultMIMEType:@"video/mp4"];
  
  // create the upload entry with the mediaGroup and the file data
  GDataEntryYouTubeUpload *entry;
  entry = [GDataEntryYouTubeUpload uploadEntryWithMediaGroup:mediaGroup
                                                        data:data
                                                    MIMEType:mimeType
                                                        slug:filename];
  
  SEL progressSel = @selector(ticket:hasDeliveredByteCount:ofTotalByteCount:);
  [service setServiceUploadProgressSelector:progressSel];
  
  GDataServiceTicket *ticket;
  ticket = [service fetchEntryByInsertingEntry:entry
                                           forFeedURL:url
                                             delegate:self
                             didFinishSelector:@selector(uploadTicket:finishedWithEntry:error:)];

  [self setUploadTicket:ticket];
  [self updateUI];
}

// progress callback
- (void)ticket:(GDataServiceTicket *)ticket
   hasDeliveredByteCount:(unsigned long long)numberOfBytesRead 
   ofTotalByteCount:(unsigned long long)dataLength {
  
  [mUploadProgressIndicator setMinValue:0.0];
  [mUploadProgressIndicator setMaxValue:(double)dataLength];
  [mUploadProgressIndicator setDoubleValue:(double)numberOfBytesRead];
}

// upload callback
- (void)uploadTicket:(GDataServiceTicket *)ticket
   finishedWithEntry:(GDataEntryYouTubeVideo *)videoEntry
               error:(NSError *)error {
  if (error == nil) {
    // tell the user that the add worked
    NSBeginAlertSheet(@"Uploaded", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Uploaded video: %@",
                      [[videoEntry title] stringValue]);

    // refetch the current entries, in case the list of uploads
    // has changed
    [self fetchAllEntries];
    [self updateUI];
  } else {
    NSBeginAlertSheet(@"Upload failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Upload failed: %@", error);
  }
  [mUploadProgressIndicator setDoubleValue:0.0];

  [self setUploadTicket:nil];
}

// Setting likes/dislikes
//
// To set the authenticated user's rating for a video entry, insert an entry
// into the ratings feed for the video. The value may be
// kGDataYouTubeRatingValueLike or kGDataYouTubeRatingValueDislike
//
// Example:
//
//  - (void)setLikesValue:(NSString *)value
//          forVideoEntry:(GDataEntryYouTubeVideo *)videoEntry {
//
//    GDataEntryYouTubeRating *ratingEntry = [GDataEntryYouTubeRating ratingEntryWithValue:value];
//
//    GDataServiceGoogleYouTube *service = [self youTubeService];
//    [service fetchEntryByInsertingEntry:ratingEntry
//                             forFeedURL:[[videoEntry ratingsLink] URL]
//                               delegate:self
//                      didFinishSelector:@selector(likesTicket:finishedWithEntry:error:)];
//  }

////////////////////////////////////////////////////////
#pragma mark Text field delegate methods

- (void)controlTextDidChange:(NSNotification *)note {
    
  [self updateUI]; // enable/disable the upload button
}


#pragma mark TableView delegate methods
//
// table view delegate methods
//

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  
  [self updateUI]; 
}

// table view data source methods
- (int)numberOfRowsInTableView:(NSTableView *)tableView {
  return [[mEntriesFeed entries] count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
  // get the entry entry's title
  GDataEntryBase *entry = [[mEntriesFeed entries] objectAtIndex:row];
  return [[entry title] stringValue];
}

#pragma mark Fetch the Categories

- (void)fetchStandardCategories {
  
  // This method initiates a fetch and parse of the assignable categories.
  // If successful, the callback loads the category pop-up with the
  // categories.
  
  NSURL *categoriesURL = [NSURL URLWithString:kGDataSchemeYouTubeCategory];
  NSURLRequest *request = [NSURLRequest requestWithURL:categoriesURL];
  GDataHTTPFetcher *fetcher = [GDataHTTPFetcher httpFetcherWithRequest:request];
    
  [fetcher beginFetchWithDelegate:self
                didFinishSelector:@selector(categoryFetcher:finishedWithData:)
                  didFailSelector:@selector(categoryFetcher:failedWithError:)];
}


- (void)categoryFetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data {

  // The categories document looks like
  //  <app:categories>
  //    <atom:category term='Film' label='Film &amp; Animation'>
  //      <yt:browsable />
  //      <yt:assignable />
  //    </atom:category>
  //  </app:categories>
  //
  // We only want the categories which are assignable. We'll use XPath to
  // select those, then get the string value of the resulting term attribute
  // nodes.
  
  NSString *const path = @"app:categories/atom:category[yt:assignable]";
  
  NSError *error = nil;
  NSXMLDocument *xmlDoc = [[[NSXMLDocument alloc] initWithData:data
                                                       options:0
                                                         error:&error] autorelease];
  if (xmlDoc == nil) {
    NSLog(@"category fetch could not parse XML: %@", error);       
  } else {
    NSArray *nodes = [xmlDoc nodesForXPath:path
                                     error:&error];
    unsigned int numberOfNodes = [nodes count];
    if (numberOfNodes == 0) {
      NSLog(@"category fetch could not find nodes: %@", error);       
    } else {
      
      // add the category labels as menu items, and the category terms as
      // the menu item representedObjects.
      [mCategoryPopup removeAllItems];
      NSMenu *menu = [mCategoryPopup menu];

      for (int idx = 0; idx < numberOfNodes; idx++) {
        NSXMLElement *category = [nodes objectAtIndex:idx];
                   
        NSString *term = [[category attributeForName:@"term"] stringValue];
        NSString *label = [[category attributeForName:@"label"] stringValue];
        
        if (label == nil) label = term;
        
        NSMenuItem *item = [menu addItemWithTitle:label
                                           action:nil
                                    keyEquivalent:@""];
        [item setRepresentedObject:term];
      }
    }
  }
}

- (void)categoryFetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error {
  NSLog(@"categoryFetcher:%@ failedWithError:%@", fetcher, error);       
}

#pragma mark Setters and Getters

- (GDataFeedBase *)entriesFeed {
  return mEntriesFeed; 
}

- (void)setEntriesFeed:(GDataFeedBase *)feed {
  [mEntriesFeed autorelease];
  mEntriesFeed = [feed retain];
}

- (NSError *)entryFetchError {
  return mEntriesFetchError; 
}

- (void)setEntriesFetchError:(NSError *)error {
  [mEntriesFetchError release];
  mEntriesFetchError = [error retain];
}

- (GDataServiceTicket *)entriesFetchTicket {
  return mEntriesFetchTicket; 
}

- (void)setEntriesFetchTicket:(GDataServiceTicket *)ticket {
  [mEntriesFetchTicket release];
  mEntriesFetchTicket = [ticket retain];
}

- (NSString *)entryImageURLString {
  return mEntryImageURLString;
}

- (void)setEntryImageURLString:(NSString *)str {
  [mEntryImageURLString autorelease];
  mEntryImageURLString = [str copy];
}

- (GDataServiceTicket *)uploadTicket {
  return mUploadTicket;
}

- (void)setUploadTicket:(GDataServiceTicket *)ticket {
  [mUploadTicket release];
  mUploadTicket = [ticket retain];
}

@end
