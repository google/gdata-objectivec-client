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

#import "GData/GTMOAuth2WindowController.h"

static NSString* const kActivityFeed = @"activity";
static NSString* const kChannelsFeed = @"channels";
static NSString* const kMostPopularFeed = @"most popular";

@interface YouTubeSampleWindowController (PrivateMethods)
- (void)updateUI;

- (void)fetchEntryImageURLString:(NSString *)urlString;

- (GDataEntryBase *)selectedEntry;
- (void)fetchAllEntries;
- (void)uploadVideoFile;
- (void)restartUpload;

- (GDataFeedYouTubeVideo *)entriesFeed;
- (void)setEntriesFeed:(GDataFeedYouTubeVideo *)feed;

- (NSError *)entriesFetchError;
- (void)setEntriesFetchError:(NSError *)error;

- (GDataServiceTicket *)entriesFetchTicket;
- (void)setEntriesFetchTicket:(GDataServiceTicket *)ticket;

- (NSString *)entryImageURLString;
- (void)setEntryImageURLString:(NSString *)str;

- (GDataServiceTicket *)uploadTicket;
- (void)setUploadTicket:(GDataServiceTicket *)ticket;

- (NSURL *)uploadLocationURL;
- (void)setUploadLocationURL:(NSURL *)url;

- (GDataServiceGoogleYouTube *)youTubeService;

- (void)ticket:(GDataServiceTicket *)ticket
  hasDeliveredByteCount:(unsigned long long)numberOfBytesRead
  ofTotalByteCount:(unsigned long long)dataLength;

- (void)fetchStandardCategories;
@end

@implementation YouTubeSampleWindowController

static YouTubeSampleWindowController* gYouTubeSampleWindowController = nil;

static NSString *const kKeychainItemName = @"YouTubeSample: YouTube";

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
  // Load the OAuth token from the keychain, if it was previously saved
  NSString *clientID = [mClientIDField stringValue];
  NSString *clientSecret = [mClientSecretField stringValue];

  GTMOAuth2Authentication *auth;
  auth = [GTMOAuth2WindowController authForGoogleFromKeychainForName:kKeychainItemName
                                                            clientID:clientID
                                                        clientSecret:clientSecret];
  [[self youTubeService] setAuthorizer:auth];

  // Set the result text fields to have a distinctive color and mono-spaced font
  // to aid in understanding of each album and photo query operation.
  [mEntriesResultTextField setTextColor:[NSColor darkGrayColor]];

  NSFont *resultTextFont = [NSFont fontWithName:@"Monaco" size:9];
  [mEntriesResultTextField setFont:resultTextFont];

  // load the user feed types into the pop-up menu, and default to showing
  // the feed of the user's uploads, as it's generally most interesting
  NSArray *userFeedTypes = [NSArray arrayWithObjects:
    kChannelsFeed,
    kMostPopularFeed,
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
  [mUploadLocationURL release];

  [super dealloc];
}

#pragma mark -

- (NSString *)signedInUsername {
  // Get the email address of the signed-in user
  GTMOAuth2Authentication *auth = [[self youTubeService] authorizer];
  BOOL isSignedIn = auth.canAuthorize;
  if (isSignedIn) {
    return auth.userEmail;
  } else {
    return nil;
  }
}

- (BOOL)isSignedIn {
  NSString *name = [self signedInUsername];
  return (name != nil);
}

- (void)runSigninThenInvokeSelector:(SEL)signInDoneSel {
  // Applications should have client ID and client secret strings
  // hardcoded into the source, but the sample application asks the
  // developer for the strings
  NSString *clientID = [mClientIDField stringValue];
  NSString *clientSecret = [mClientSecretField stringValue];

  if ([clientID length] == 0 || [clientSecret length] == 0) {
    // Remind the developer that client ID and client secret are needed
    [mClientIDButton performSelector:@selector(performClick:)
                          withObject:self
                          afterDelay:0.5];
    return;
  }

  // Show the OAuth 2 sign-in controller
  NSString *scope = [GDataServiceGoogleYouTube authorizationScope];

  NSBundle *frameworkBundle = [NSBundle bundleForClass:[GTMOAuth2WindowController class]];
  GTMOAuth2WindowController *windowController;
  windowController = [GTMOAuth2WindowController controllerWithScope:scope
                                                           clientID:clientID
                                                       clientSecret:clientSecret
                                                   keychainItemName:kKeychainItemName
                                                     resourceBundle:frameworkBundle];
  
  [windowController setUserData:NSStringFromSelector(signInDoneSel)];
  [windowController signInSheetModalForWindow:[self window]
                                     delegate:self
                             finishedSelector:@selector(windowController:finishedWithAuth:error:)];
}

- (void)windowController:(GTMOAuth2WindowController *)windowController
        finishedWithAuth:(GTMOAuth2Authentication *)auth
                   error:(NSError *)error {
  // Callback from OAuth 2 sign-in
  if (error == nil) {
    [[self youTubeService] setAuthorizer:auth];

    NSString *selStr = [windowController userData];
    if (selStr) {
      [self performSelector:NSSelectorFromString(selStr)];
    }
  } else {
    [self setEntriesFetchError:error];
    [self updateUI];
  }
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
  GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithURLString:urlString];
  [fetcher setComment:@"thumbnail"];
  [fetcher beginFetchWithDelegate:self
                didFinishSelector:@selector(imageFetcher:finishedWithData:error:)];
}

- (void)imageFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error {
  if (error == nil) {
    // got the data; display it in the image view
    NSImage *image = [[[NSImage alloc] initWithData:data] autorelease];

    [mEntryImageView setImage:image];
  } else {
    NSLog(@"imageFetcher:%@ failedWithError:%@", fetcher,  error);
  }
}

#pragma mark -

- (void)updateUI {
  BOOL isSignedIn = [self isSignedIn];
  NSString *username = [self signedInUsername];
  [mSignedInButton setTitle:(isSignedIn ? @"Sign Out" : @"Sign In")];
  [mSignedInField setStringValue:(isSignedIn ? username : @"No")];

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
  BOOL hasDevKey = [[mDeveloperKeyField stringValue] length] > 0;
  BOOL hasTitle = [[mTitleField stringValue] length] > 0;
  BOOL hasPath = [[mFilePathField stringValue] length] > 0;

  BOOL canUpload = isSignedIn && hasDevKey
    && hasTitle && hasPath;

  BOOL isUploading = (mUploadTicket != nil);
  BOOL canRestartUpload = !isUploading && (mUploadLocationURL != nil);
  BOOL isUploadPaused = [mUploadTicket isUploadPaused];

  [mUploadButton setEnabled:(canUpload && !isUploading)];
  [mPauseUploadButton setEnabled:isUploading];
  [mStopUploadButton setEnabled:isUploading];
  [mRestartUploadButton setEnabled:canRestartUpload];

  NSString *pauseTitle = (isUploadPaused ? @"Resume" : @"Pause");
  [mPauseUploadButton setTitle:pauseTitle];

  // Show or hide the text indicating that the client ID or client secret are
  // needed
  BOOL hasClientIDStrings = [[mClientIDField stringValue] length] > 0
    && [[mClientSecretField stringValue] length] > 0;
  [mClientIDRequiredTextField setHidden:hasClientIDStrings];
}

- (void)displayAlert:(NSString *)title format:(NSString *)format, ... {
  NSString *result = format;
  if (format) {
    va_list argList;
    va_start(argList, format);
    result = [[[NSString alloc] initWithFormat:format
                                     arguments:argList] autorelease];
    va_end(argList);
  }
  NSBeginAlertSheet(title, nil, nil, nil, [self window], nil, nil,
                    nil, nil, @"%@", result);
}

#pragma mark IBActions

- (IBAction)signInClicked:(id)sender {
  if (![self isSignedIn]) {
    // Sign in
    [self runSigninThenInvokeSelector:@selector(updateUI)];
  } else {
    // Sign out
    GDataServiceGoogleYouTube *service = [self youTubeService];

    [GTMOAuth2WindowController removeAuthFromKeychainForName:kKeychainItemName];
    [service setAuthorizer:nil];
    [self updateUI];
  }
}

- (IBAction)getEntriesClicked:(id)sender {
  if (![self isSignedIn]) {
    // Sign in
    [self runSigninThenInvokeSelector:@selector(fetchAllEntries)];
  } else {
    [self fetchAllEntries];
  }
}

- (IBAction)cancelEntriesFetchClicked:(id)sender {
  [mEntriesFetchTicket cancelTicket];
  [self setEntriesFetchTicket:nil];
  [self updateUI];
}

- (IBAction)APIConsoleClicked:(id)sender {
  NSURL *url = [NSURL URLWithString:@"https://code.google.com/apis/console"];
  [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)loggingCheckboxClicked:(id)sender {
  [GTMHTTPFetcher setLoggingEnabled:[sender state]];
}

- (IBAction)chooseFileClicked:(id)sender {
  // ask the user to choose a video file
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setPrompt:@"Choose"];

  NSArray *movieTypes = [NSArray arrayWithObjects:@"mov", @"mp4", nil];

  [openPanel setAllowedFileTypes:movieTypes];
  [openPanel beginSheetModalForWindow:[self window]
                    completionHandler:^(NSInteger result) {
                      // callback
                      if (result == NSOKButton) {
                        // the user chose a file
                        NSString *path = [[openPanel URL] path];

                        [mFilePathField setStringValue:path];

                        [self updateUI]; // update UI in case we need to enable the upload button
                      }
                    }];
}

- (IBAction)uploadClicked:(id)sender {

  [self uploadVideoFile];
}

- (IBAction)pauseUploadClicked:(id)sender {
  if ([mUploadTicket isUploadPaused]) {
    // Resume from pause
    [mUploadTicket resumeUpload];
  } else {
    // Pause
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

- (IBAction)restartUploadClicked:(id)sender {
  [self restartUpload];
}

#pragma mark -

// get a YouTube service object
//
// A "service" object handles networking tasks.  Service objects
// contain user authentication information as well as networking
// state information (such as cookies and the "last modified" date for
// fetched data.)

- (GDataServiceGoogleYouTube *)youTubeService {

  static GDataServiceGoogleYouTube* service = nil;

  if (!service) {
    service = [[GDataServiceGoogleYouTube alloc] init];

    [service setShouldCacheResponseData:YES];
    [service setServiceShouldFollowNextLinks:YES];
    [service setIsServiceRetryEnabled:YES];
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

  GDataServiceGoogleYouTube *service = [self youTubeService];
  GDataServiceTicket *ticket;

  // feedID is uploads, favorites, etc
  //
  // note that activity feeds require a developer key
  NSString *feedID = [[mUserFeedPopup selectedItem] title];

  NSURL *feedURL;
  if ([feedID isEqual:kActivityFeed]) {
    // the activity feed uses a unique URL
    feedURL = [GDataServiceGoogleYouTube youTubeActivityFeedURLForUserID:kGDataServiceDefaultUser];
  } else if ([feedID isEqual:kChannelsFeed]) {
    feedURL = [GDataServiceGoogleYouTube youTubeURLForChannelsFeeds];
  } else if ([feedID isEqual:kMostPopularFeed]) {
    feedURL = [GDataServiceGoogleYouTube youTubeURLForFeedID:kGDataYouTubeFeedIDMostPopular];
  } else {
    feedURL = [GDataServiceGoogleYouTube youTubeURLForUserID:kGDataServiceDefaultUser
                                                  userFeedID:feedID];
  }

  ticket = [service fetchFeedWithURL:feedURL
                            delegate:self
                   didFinishSelector:@selector(entryListFetchTicket:finishedWithFeed:error:)];

  if ([feedID isEqual:kChannelsFeed] || [feedID isEqual:kMostPopularFeed]) {
    // when using feeds which search all public videos, we don't want
    // to follow the feed's next links, since there could be a huge
    // number of pages of results
    [ticket setShouldFollowNextLinks:NO];
  }

  [self setEntriesFetchTicket:ticket];

  [self updateUI];
}

// feed fetch callback
- (void)entryListFetchTicket:(GDataServiceTicket *)ticket
            finishedWithFeed:(GDataFeedYouTubeVideo *)feed
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

  NSURL *url = [GDataServiceGoogleYouTube youTubeUploadURLForUserID:kGDataServiceDefaultUser];

  // load the file data
  NSString *path = [mFilePathField stringValue];
  NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
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

  // create the upload entry with the mediaGroup and the file
  GDataEntryYouTubeUpload *entry;
  entry = [GDataEntryYouTubeUpload uploadEntryWithMediaGroup:mediaGroup
                                                  fileHandle:fileHandle
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

  // To allow restarting after stopping, we need to track the upload location
  // URL. The location URL will be a different address than the upload URL that
  // is used to start a new upload.
  //
  // For compatibility with systems that do not support Objective-C blocks
  // (iOS 3 and Mac OS X 10.5), the location URL may also be obtained in the
  // progress callback as ((GTMHTTPUploadFetcher *)[ticket objectFetcher]).locationURL
  // 
  GTMHTTPUploadFetcher *uploadFetcher = (GTMHTTPUploadFetcher *)[ticket objectFetcher];
  [uploadFetcher setLocationChangeBlock:^(NSURL *url) {
    [self setUploadLocationURL:url];
    [self updateUI];
  }];

  [self updateUI];
}

- (void)restartUpload {
  // Restart a stopped upload, using the location URL from the previous
  // upload attempt
  if (mUploadLocationURL == nil) return;

  GDataServiceGoogleYouTube *service = [self youTubeService];

  NSString *path = [mFilePathField stringValue];
  NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
  NSString *mimeType = [GDataUtilities MIMETypeForFileAtPath:path
                                             defaultMIMEType:@"video/mp4"];

  GDataEntryYouTubeUpload *entry;
  entry = [GDataEntryYouTubeUpload uploadEntryWithMediaGroup:nil
                                                  fileHandle:fileHandle
                                                    MIMEType:mimeType
                                                        slug:nil];
  [entry setUploadLocationURL:mUploadLocationURL];

  SEL progressSel = @selector(ticket:hasDeliveredByteCount:ofTotalByteCount:);
  [service setServiceUploadProgressSelector:progressSel];

  GDataServiceTicket *ticket;
  ticket = [service fetchEntryByInsertingEntry:entry
                                    forFeedURL:nil
                                      delegate:self
                             didFinishSelector:@selector(uploadTicket:finishedWithEntry:error:)];
  [self setUploadTicket:ticket];

  // To allow restarting after stopping, we need to track the upload location
  // URL.
  GTMHTTPUploadFetcher *uploadFetcher = (GTMHTTPUploadFetcher *)[ticket objectFetcher];
  [uploadFetcher setLocationChangeBlock:^(NSURL *url) {
    [self setUploadLocationURL:url];
    [self updateUI];
  }];

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
    [self displayAlert:@"Uploaded"
                format:@"Uploaded video: %@",
     [[videoEntry title] stringValue]];

    // refetch the current entries, in case the list of uploads
    // has changed
    [self fetchAllEntries];
  } else {
    [self displayAlert:@"Upload failed"
                format:@"Upload failed: %@", error];
  }
  [mUploadProgressIndicator setDoubleValue:0.0];

  [self setUploadTicket:nil];
  [self updateUI];
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

#pragma mark Client ID Sheet

// Client ID and Client Secret Sheet
//
// Sample apps need this sheet to ask for the client ID and client secret
// strings
//
// Your application will just hardcode the client ID and client secret strings
// into the source rather than ask the user for them.
//
// The string values are obtained from the API Console,
// https://code.google.com/apis/console

- (IBAction)clientIDClicked:(id)sender {
  // Show the sheet for developers to enter their client ID and client secret
  [NSApp beginSheet:mClientIDSheet
     modalForWindow:[self window]
      modalDelegate:self
     didEndSelector:@selector(clientIDSheetDidEnd:returnCode:contextInfo:)
        contextInfo:NULL];
}

- (IBAction)clientIDDoneClicked:(id)sender {
  [NSApp endSheet:mClientIDSheet returnCode:NSOKButton];
}

- (void)clientIDSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
  [sheet orderOut:self];
  [self updateUI];
}

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
  GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithURL:categoriesURL];
  [fetcher setComment:@"YouTube categories"];
  [fetcher beginFetchWithDelegate:self
                didFinishSelector:@selector(categoryFetcher:finishedWithData:error:)];
}


- (void)categoryFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error {
  if (error) {
    NSLog(@"categoryFetcher:%@ failedWithError:%@", fetcher, error);
    return;
  }

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

#pragma mark Setters and Getters

- (GDataFeedYouTubeVideo *)entriesFeed {
  return mEntriesFeed;
}

- (void)setEntriesFeed:(GDataFeedYouTubeVideo *)feed {
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

- (NSURL *)uploadLocationURL {
  return mUploadLocationURL;
}

- (void)setUploadLocationURL:(NSURL *)url {
  [mUploadLocationURL release];
  mUploadLocationURL = [url retain];
}

@end
