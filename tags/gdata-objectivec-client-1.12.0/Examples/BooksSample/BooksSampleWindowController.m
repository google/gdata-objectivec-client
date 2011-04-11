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
//  BooksSampleWindowController.m
//

#import "BooksSampleWindowController.h"

// segmented control indexes
const int kLibrarySegment = 0;    // feed of books in user's library
const int kAnnotationSegment = 1; // feed of books annotated by the user
const int kCollectionSegment = 2; // feed of collections from user's library

const int kPreviewSegment = 0;
const int kInfoSegment = 1;

// tags for viewability pop-up
const int kAnyViewability = 0;     // any amount or none is viewable
const int kPartialViewability = 1; // some is viewable
const int kFullViewability = 2;    // entire book must be viewable

// feed properties indicating the source of the feed
NSString *kSourceProperty = @"source";
NSString *kSearchFeedSource = @"search";
NSString *kVolumesFeedSource = @"volumes";
NSString *kAnnotationsFeedSource = @"annotations";

@interface BooksSampleWindowController (PrivateMethods)
- (void)updateUI;

- (void)fetchVolumes;
- (void)fetchCollections;
- (void)searchNow;

- (void)addLabelToSelectedVolume;
- (void)setReviewForSelectedVolume;
- (void)setRatingForSelectedVolume;

- (GDataServiceGoogleBooks *)booksService;
- (GDataEntryVolume *)selectedVolume;

- (GDataFeedVolume *)volumesFeed;
- (void)setVolumesFeed:(GDataFeedVolume *)feed;

- (GDataServiceTicket *)volumesFetchTicket;
- (void)setVolumesFetchTicket:(GDataServiceTicket *)ticket;

- (NSError *)volumesFetchError;
- (void)setVolumesFetchError:(NSError *)error;

- (GDataFeedCollection *)collectionsFeed;
- (void)setCollectionsFeed:(GDataFeedCollection *)feed;

- (GDataServiceTicket *)collectionsFetchTicket;
- (void)setCollectionsFetchTicket:(GDataServiceTicket *)ticket;

- (NSError *)collectionsFetchError;
- (void)setCollectionsFetchError:(NSError *)error;

- (GDataServiceTicket *)annotationsFetchTicket;
- (void)setAnnotationsFetchTicket:(GDataServiceTicket *)ticket;

- (NSString *)volumeImageURLString;
- (void)setVolumeImageURLString:(NSString *)str;

- (void)updateImageForVolume:(GDataEntryVolume *)volume;
- (void)updateWebViewForVolume:(GDataEntryVolume *)volume;

- (void)fetchURLString:(NSString *)urlString forImageView:(NSImageView *)view;

- (NSString *)volumeWebURLString;
- (void)setVolumeWebURLString:(NSString *)str;
@end

@implementation BooksSampleWindowController

static BooksSampleWindowController* gBooksSampleWindowController = nil;

+ (BooksSampleWindowController *)sharedBooksSampleWindowController {

  if (!gBooksSampleWindowController) {
    gBooksSampleWindowController = [[BooksSampleWindowController alloc] init];
  }
  return gBooksSampleWindowController;
}


- (id)init {
  return [self initWithWindowNibName:@"BooksSampleWindow"];
}

- (void)windowDidLoad {
}

- (void)awakeFromNib {
  // Set the result text field to have a distinctive color and mono-spaced font
  // to aid in understanding of each entry.
  [mVolumesResultTextField setTextColor:[NSColor darkGrayColor]];

  NSFont *resultTextFont = [NSFont fontWithName:@"Monaco" size:9];
  [mVolumesResultTextField setFont:resultTextFont];

  [self updateUI];
}

- (void)dealloc {
  [mVolumesFetchTicket cancelTicket];
  [mVolumesFeed release];
  [mVolumesFetchTicket release];
  [mVolumesFetchError release];

  [mAnnotationsFetchTicket cancelTicket];
  [mAnnotationsFetchTicket release];

  [mVolumeImageURLString release];
  [mVolumeWebURLString release];

  [super dealloc];
}

#pragma mark -

- (void)updateUI {

  // volume entries list display
  [mVolumesTable reloadData];

  // turn the spinners on during fetches
  if (mVolumesFetchTicket != nil) {
    [mVolumesProgressIndicator startAnimation:self];
  } else {
    [mVolumesProgressIndicator stopAnimation:self];
  }

  if (mCollectionsFetchTicket != nil) {
    [mCollectionProgressIndicator startAnimation:self];
  } else {
    [mCollectionProgressIndicator stopAnimation:self];
  }

  if (mAnnotationsFetchTicket != nil) {
    [mAnnotationsProgressIndicator startAnimation:self];
  } else {
    [mAnnotationsProgressIndicator stopAnimation:self];
  }

  GDataEntryVolume *selectedVolume = [self selectedVolume];

  // display the volumes fetch result or the selected volume entry
  NSString *volumesResultStr = @"";
  if (mVolumesFetchError) {
    volumesResultStr = [mVolumesFetchError description];
  } else {
    if (selectedVolume) {
      volumesResultStr = [selectedVolume description];
    }
  }
  [mVolumesResultTextField setString:volumesResultStr];

  // update the book thumbnail and the web preview
  [self updateImageForVolume:selectedVolume];
  [self updateWebViewForVolume:selectedVolume];

  GDataFeedVolume *volumesFeed = [self volumesFeed];
  BOOL isAnnotationsFeed =
    [[volumesFeed propertyForKey:kSourceProperty] isEqual:kAnnotationsFeedSource];

  // enable/disable fetch buttons
  BOOL hasUsername = ([[mUsernameField stringValue] length] > 0);
  BOOL hasPassword = ([[mPasswordField stringValue] length] > 0);
  BOOL canFetchUserFeed = (hasUsername && hasPassword);

  [mGetVolumesButton setEnabled:canFetchUserFeed];
  [mUserFeedTypeSegments setEnabled:canFetchUserFeed];

  BOOL hasSearchTerm = ([[mSearchField stringValue] length] > 0);
  [mSearchButton setEnabled:hasSearchTerm];

  // enable/disable collection pop-up
  BOOL hasCollections = ([[mCollectionsFeed entries] count] > 0);
  [mCollectionPopup setEnabled:hasCollections];

  // enable/disable cancel buttons
  [mVolumesCancelButton setEnabled:(mVolumesFetchTicket != nil)];
  [mAnnotationsCancelButton setEnabled:(mAnnotationsFetchTicket != nil)];

  // enable/disable other buttons

  // "add label" button
  BOOL isVolumeSelected = ([self selectedVolume] != nil);
  BOOL isLabelProvided = ([[mLabelField stringValue] length] > 0);

  BOOL canAddLabel = isAnnotationsFeed && isVolumeSelected && isLabelProvided;

  [mAddLabelButton setEnabled:canAddLabel];

  // set rating pop-up button
  //
  // if there's no user-set value, we'll use tag 0, "none"
  GDataRating *rating = [selectedVolume rating];
  [mRatingPopup selectItemWithTag:[[rating value] intValue]];

  NSString *avgStr = [NSString stringWithFormat:@"Avg: %@", [rating average]];
  [mAverageRatingField setStringValue:avgStr];

  BOOL canSetRating = isAnnotationsFeed && isVolumeSelected;
  [mRatingPopup setEnabled:canSetRating];

  // "save review" button
  NSString *updatedReviewStr = [mReviewField stringValue];

  NSString *oldReviewStr = [[selectedVolume review] stringValue];
  if (oldReviewStr == nil) oldReviewStr = @"";

  BOOL hasReviewChanged = ![oldReviewStr isEqual:updatedReviewStr];
  BOOL canSaveReview = isAnnotationsFeed && hasReviewChanged;
  [mSaveReviewButton setEnabled:canSaveReview];
}


#pragma mark IBActions

- (IBAction)getVolumesClicked:(id)sender {

  NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];

  NSString *username = [mUsernameField stringValue];
  username = [username stringByTrimmingCharactersInSet:whitespace];

  if ([username rangeOfString:@"@"].location == NSNotFound) {
    // if no domain was supplied, add @gmail.com
    username = [username stringByAppendingString:@"@gmail.com"];
  }

  [mUsernameField setStringValue:username];

  if ([mUserFeedTypeSegments selectedSegment] == kCollectionSegment
      && mCollectionsFeed == nil) {
    [self fetchCollections];
  } else {
    [self fetchVolumes];
  }
}

- (IBAction)collectionPopupClicked:(id)sender {
  [mUserFeedTypeSegments setSelectedSegment:kCollectionSegment];
  [self getVolumesClicked:sender];
}

- (IBAction)searchClicked:(id)sender {
  [self searchNow];
}

- (IBAction)userFeedTypeSegmentClicked:(id)sender {
  [self getVolumesClicked:nil];
}


- (IBAction)webViewSegmentClicked:(id)sender {
  [self updateUI];
}

- (IBAction)cancelVolumeFetchClicked:(id)sender {
  [mVolumesFetchTicket cancelTicket];
  [self setVolumesFetchTicket:nil];
  [self updateUI];
}

- (IBAction)cancelAnnotationsFetchClicked:(id)sender {
  [mAnnotationsFetchTicket cancelTicket];
  [self setAnnotationsFetchTicket:nil];
  [self updateUI];
}

- (IBAction)addLabelClicked:(id)sender {
  [self addLabelToSelectedVolume];
}

- (IBAction)ratingPopupClicked:(id)sender {
  [self setRatingForSelectedVolume];
}

- (IBAction)saveReviewClicked:(id)sender {
  [self setReviewForSelectedVolume];
}

- (IBAction)loggingCheckboxClicked:(id)sender {
  [GDataHTTPFetcher setIsLoggingEnabled:[sender state]];
}

#pragma mark -

// get a volume service object with the current username/password
//
// A "service" object handles networking tasks.  Service objects
// contain user authentication information as well as networking
// state information (such as cookies and the "last modified" date for
// fetched data.)

- (GDataServiceGoogleBooks *)booksService {

  static GDataServiceGoogleBooks* service = nil;

  if (!service) {
    // The service object handles networking cookies and the results cache,
    // so we want just one instance in the application

    service = [[GDataServiceGoogleBooks alloc] init];

    [service setShouldCacheDatedData:YES];
    [service setServiceShouldFollowNextLinks:YES];
  }

  // update the username/password each time the service is requested
  NSString *username = [mUsernameField stringValue];
  NSString *password = [mPasswordField stringValue];

  if ([username length] > 0 && [password length] > 0) {
    [service setUserCredentialsWithUsername:username
                                   password:password];
  } else {
    [service setUserCredentialsWithUsername:nil
                                   password:nil];
  }

  return service;
}

// get the volume selected in the top list, or nil if none
- (GDataEntryVolume *)selectedVolume {

  NSArray *volumes = [mVolumesFeed entries];
  int rowIndex = [mVolumesTable selectedRow];
  if ([volumes count] > 0 && rowIndex > -1) {

    GDataEntryVolume *volume = [volumes objectAtIndex:rowIndex];
    return volume;
  }
  return nil;
}

#pragma mark Fetch volumes

// begin retrieving the list of the user's annotated volumes
// or library volumes
- (void)fetchVolumes {

  [self setVolumesFeed:nil];
  [self setVolumesFetchError:nil];
  [self setVolumesFetchTicket:nil];

  GDataServiceGoogleBooks *service = [self booksService];
  GDataServiceTicket *ticket;

  NSURL *feedURL;
  NSString *feedType;

  NSInteger segmentIndex = [mUserFeedTypeSegments selectedSegment];
  if (segmentIndex == kLibrarySegment) {
    // feed of user's library
    feedURL = [GDataServiceGoogleBooks booksURLForCollectionID:kGDataGoogleBooksLibraryCollection];
    feedType = kVolumesFeedSource;
  } else if (segmentIndex == kAnnotationSegment) {
    // feed of books annotated by the user
    feedURL = [GDataServiceGoogleBooks booksURLForVolumeID:nil];
    feedType = kAnnotationsFeedSource;
  } else {
    // collection from user's library
    NSMenuItem *menuItem = [mCollectionPopup selectedItem];
    feedURL = [menuItem representedObject];
    feedType = kVolumesFeedSource;
  }

  ticket = [service fetchFeedWithURL:feedURL
                            delegate:self
                   didFinishSelector:@selector(volumeListFetchTicket:finishedWithFeed:error:)];
  [self setVolumesFetchTicket:ticket];

  // preserve the source of the feed
  // (editable annotations vs read-only volumes)
  [ticket setProperty:feedType forKey:kSourceProperty];

  [self updateUI];
}

// fetched volume list callback
- (void)volumeListFetchTicket:(GDataServiceTicket *)ticket
             finishedWithFeed:(GDataFeedVolume *)feed
                        error:(NSError *)error {

  [self setVolumesFeed:feed];
  [self setVolumesFetchError:error];
  [self setVolumesFetchTicket:nil];

  // transfer the feed source to a property in the feed object
  if (error == nil) {
    NSString *sourceProp = [ticket propertyForKey:kSourceProperty];
    [feed setProperty:sourceProp forKey:kSourceProperty];
  }

  [self updateUI];
}

#pragma mark Fetch collections

// begin retrieving the list of the user's collections
- (void)fetchCollections {

  [self setCollectionsFeed:nil];
  [self setCollectionsFetchError:nil];
  [self setCollectionsFetchTicket:nil];

  GDataServiceGoogleBooks *service = [self booksService];
  GDataServiceTicket *ticket;

  NSURL *collectionsFeedURL = [GDataServiceGoogleBooks collectionsURL];
  ticket = [service fetchFeedWithURL:collectionsFeedURL
                            delegate:self
                   didFinishSelector:@selector(collectionListFetchTicket:finishedWithFeed:error:)];
  [self setCollectionsFetchTicket:ticket];

  [self updateUI];
}

// fetched volume list callback
- (void)collectionListFetchTicket:(GDataServiceTicket *)ticket
                 finishedWithFeed:(GDataFeedCollection *)feed
                            error:(NSError *)error {

  [self setCollectionsFeed:feed];
  [self setCollectionsFetchError:error];
  [self setCollectionsFetchTicket:nil];

  if (error == nil) {
    // load the pop-up menu of collections
    [mCollectionPopup removeAllItems];

    GDataEntryCollection *entry;
    GDATA_FOREACH(entry, [feed entries]) {
      NSString *collectionName = [[entry title] stringValue];
      NSMenuItem *newMenuItem = [[mCollectionPopup menu] addItemWithTitle:collectionName
                                                                   action:NULL
                                                            keyEquivalent:@""];
      // have the menu item remember its feed's URL
      NSURL *collectionFeedURL = [[entry feedLink] URL];
      [newMenuItem setRepresentedObject:collectionFeedURL];
    }
  } else {
    // failed to fetch collections
    NSBeginAlertSheet(@"Error", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Error fetching collection list: %@",
                      error);

    [mUserFeedTypeSegments setSelectedSegment:kLibrarySegment];
  }

  [self fetchVolumes];
}

#pragma mark Search the query string

// begin searching for the user-specified term
- (void)searchNow {

  [self setVolumesFeed:nil];
  [self setVolumesFetchError:nil];
  [self setVolumesFetchTicket:nil];

  // set the viewability parameter from the user's pop-up menu setting
  int viewabilityIndex = [mViewabilityPopUp selectedTag];
  NSString* viewability;

  if (viewabilityIndex == kAnyViewability) {
    viewability = kGDataGoogleBooksMinViewabilityNone;
  } else if (viewabilityIndex == kPartialViewability) {
    viewability = kGDataGoogleBooksMinViewabilityPartial;
  } else {
    viewability = kGDataGoogleBooksMinViewabilityFull;
  }

  NSString *searchTerm = [mSearchField stringValue];

  NSURL *feedURL = [NSURL URLWithString:kGDataGoogleBooksVolumeFeed];

  GDataQueryBooks *query = [GDataQueryBooks booksQueryWithFeedURL:feedURL];
  [query setFullTextQueryString:searchTerm];
  [query setMinimumViewability:viewability];

  // we'll reuse the volume list fetch's callbacks for the search query callback
  GDataServiceGoogleBooks *service = [self booksService];
  GDataServiceTicket *ticket;

  ticket = [service fetchFeedWithQuery:query
                              delegate:self
                     didFinishSelector:@selector(volumeListFetchTicket:finishedWithFeed:error:)];

  [self setVolumesFetchTicket:ticket];

  // searches can have way too many results; don't try to accumulate them all
  [ticket setShouldFollowNextLinks:NO];

  [ticket setProperty:kSearchFeedSource forKey:kSourceProperty];

  [self updateUI];
}

#pragma mark Fetch a volume's thumbnail

// fetch or clear the thumbnail for this specified volume entry
- (void)updateImageForVolume:(GDataEntryVolume *)volume {

  // if there's a thumbnail and it's different from the one being shown,
  // fetch it now
  if (!volume) {
    // clear the image
    [mVolumeImageView setImage:nil];
    [self setVolumeImageURLString:nil];

  } else {
    // if the new thumbnail URL string is different from the previous one,
    // save the new one, clear the image and fetch the new image

    NSString *imageURLString = [[volume thumbnailLink] href];
    if (!imageURLString || ![mVolumeImageURLString isEqual:imageURLString]) {

      [self setVolumeImageURLString:imageURLString];
      [mVolumeImageView setImage:nil];

      if (imageURLString) {
        [self fetchURLString:imageURLString forImageView:mVolumeImageView];
      }
    }
  }
}

- (void)fetchURLString:(NSString *)urlString forImageView:(NSImageView *)view {

  NSURL *imageURL = [NSURL URLWithString:urlString];
  NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
  GDataHTTPFetcher *fetcher = [GDataHTTPFetcher httpFetcherWithRequest:request];

  // use the fetcher's userData to remember which view we'll display
  // this in once the fetch completes
  [fetcher setUserData:view];

  [fetcher beginFetchWithDelegate:self
                didFinishSelector:@selector(imageFetcher:finishedWithData:)
                  didFailSelector:@selector(imageFetcher:failedWithError:)];
}

- (void)imageFetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data {
  // got the data; display it in the image view
  NSImage *image = [[[NSImage alloc] initWithData:data] autorelease];

  NSImageView *view = (NSImageView *)[fetcher userData];

  [view setImage:image];
}

- (void)imageFetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error {
  NSLog(@"imageFetcher:%@ failedWithError:%@", fetcher,  error);
}

#pragma mark Update Web View

// fetch or clear the thumbnail for this specified album
- (void)updateWebViewForVolume:(GDataEntryVolume *)volume {

  // if there's a web URL and it's different from the one being shown,
  // fetch it now

  BOOL shouldClearWebView = NO;
  if (volume == nil) {

    // no volume is selected
    shouldClearWebView = YES;

  } else {

    // if the new web URL string is different from the previous one,
    // save the new one, clear the web page and fetch the new page

    // the user may view either the the book preview or the book
    // info page
    NSInteger segmentIndex = [mWebViewSegments selectedSegment];
    NSString *urlString;
    if (segmentIndex == 0) {
      urlString = [[volume previewLink] href];
    } else {
      urlString = [[volume infoLink] href];
    }

    if ([urlString length] == 0) {

      shouldClearWebView = YES;

    } else if (![mVolumeWebURLString isEqual:urlString]) {

      // URL has changed
      [self setVolumeWebURLString:urlString];

      NSURL *url = [NSURL URLWithString:urlString];
      NSURLRequest *request = [NSURLRequest requestWithURL:url];

      [[mWebView mainFrame] loadRequest:request];
    }
  }

  if (shouldClearWebView) {
    // clear the image
    [[mWebView mainFrame] loadHTMLString:@"" baseURL:nil];
    [self setVolumeWebURLString:nil];
  }
}

#pragma mark Add Label

- (void)addLabelToSelectedVolume {

  GDataEntryVolume *volume = [self selectedVolume];
  if (volume) {

    NSString *label = [mLabelField stringValue];

    GDataCategory *cat = [GDataCategory categoryWithScheme:kGDataBooksLabelsScheme
                                                      term:label];

    // to avoid changing the original, which is being displayed,
    // we'll add the category to a copy of the volume entry
    GDataEntryVolume *volCopy = [[volume copy] autorelease];
    [volCopy addCategory:cat];

    GDataServiceGoogleBooks *service = [self booksService];
    GDataServiceTicket *ticket;
    ticket = [service fetchEntryByUpdatingEntry:volCopy
                                       delegate:self
                              didFinishSelector:@selector(addLabelTicket:finishedWithEntry:error:)];
    [self setAnnotationsFetchTicket:ticket];

    // save the label so we can display it in the success callback
    [ticket setUserData:label];

    [self updateUI];
  }
}

- (void)addLabelTicket:(GDataServiceTicket *)ticket
     finishedWithEntry:(GDataEntryVolume *)entry
                 error:(NSError *)error {

  [self setAnnotationsFetchTicket:nil];

  if (error == nil) {
    NSString *label = [ticket userData];

    NSBeginAlertSheet(@"Added label", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Added label \"%@\" to volume %@",
                      label,
                      [[entry title] stringValue]);

    [self fetchVolumes];
  } else {
    // add label failed
    NSBeginAlertSheet(@"Add label failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Label add failed: %@", error);

    [self updateUI];
  }
}

#pragma mark Set Review

- (void)setReviewForSelectedVolume {

  GDataEntryVolume *volume = [self selectedVolume];
  if (volume) {
    NSString *reviewStr = [mReviewField stringValue];

    // to avoid changing the original, which is being displayed,
    // we'll set the review element in a copy of the volume entry
    GDataEntryVolume *volCopy = [[volume copy] autorelease];

    GDataVolumeReview *review;

    if ([reviewStr length] > 0) {
      // set the review
      review = [GDataVolumeReview textConstructWithString:reviewStr];
    } else {
      // delete the review
      review = nil;
    }
    [volCopy setReview:review];

    GDataServiceGoogleBooks *service = [self booksService];
    GDataServiceTicket *ticket;
    ticket = [service fetchEntryByUpdatingEntry:volCopy
                                       delegate:self
                              didFinishSelector:@selector(setReviewTicket:finishedWithEntry:error:)];
    [self setAnnotationsFetchTicket:ticket];

    [self updateUI];
  }
}

- (void)setReviewTicket:(GDataServiceTicket *)ticket
      finishedWithEntry:(GDataEntryVolume *)entry
                  error:(NSError *)error {

  [self setAnnotationsFetchTicket:nil];

  if (error == nil) {
    NSBeginAlertSheet(@"Review set", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Updated review for volume %@",
                      [[entry title] stringValue]);

    [self fetchVolumes];
  } else {
    // fetch failed
    NSBeginAlertSheet(@"Set review failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Review set failed: %@", error);

    [self updateUI];
  }
}

#pragma mark Set Rating

- (void)setRatingForSelectedVolume {

  GDataEntryVolume *volume = [self selectedVolume];
  if (volume) {
    // to avoid changing the original, which is being displayed,
    // we'll set the rating on a copy of the volume entry
    GDataEntryVolume *volCopy = [[volume copy] autorelease];

    int newRating = [mRatingPopup selectedTag];

    if (newRating == 0) {
      // if the user wants no rating set, remove the rating element from the
      // volume entry
      [volCopy setRating:nil];
    } else {
      // set the rating element to have a value matching the pop-up item's tag
      [volCopy setRating:[GDataRating ratingWithValue:newRating max:5 min:1]];
    }

    GDataServiceGoogleBooks *service = [self booksService];
    GDataServiceTicket *ticket;
    ticket = [service fetchEntryByUpdatingEntry:volCopy
                                       delegate:self
                              didFinishSelector:@selector(setRatingTicket:finishedWithEntry:error:)];
    [self setAnnotationsFetchTicket:ticket];

    [self updateUI];
  }
}

- (void)setRatingTicket:(GDataServiceTicket *)ticket
      finishedWithEntry:(GDataEntryVolume *)entry
                  error:(NSError *)error {

  [self setAnnotationsFetchTicket:nil];

  if (error == nil) {
    NSBeginAlertSheet(@"Set rating", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Set rating \"%@\" to volume %@",
                      [[entry rating] value],
                      [[entry title] stringValue]);

    [self fetchVolumes];
  } else {
    // fetch failed
    NSBeginAlertSheet(@"Set rating failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Set rating failed: %@", error);

    [self updateUI];
  }
}

////////////////////////////////////////////////////////
#pragma mark Text field delegate methods

- (void)controlTextDidChange:(NSNotification *)note {

  [self updateUI]; // enabled/disable buttons
}


#pragma mark TableView Delegate and Data Source Methods
//
// table view delegate methods
//
// there is only one table, mVolumesTable
//

- (void)tableViewSelectionDidChange:(NSNotification *)notification {

  // when the user clicks on a volume, we load the review field,
  // which they can then edit.  We don't want to reload the edit
  // field every time updateUI is called, since that could too easily
  // wipe out the user's edits
  GDataEntryVolume *selectedVolume = [self selectedVolume];

  NSString *reviewStr = [[selectedVolume review] stringValue];
  if (reviewStr == nil) reviewStr = @"";

  [mReviewField setStringValue:reviewStr];

  [self updateUI];
}

// table view data source methods

- (int)numberOfRowsInTableView:(NSTableView *)tableView {
  return [[mVolumesFeed entries] count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {

  // get the volume entry's title in a comma-separated list
  GDataEntryVolume *volume = [[mVolumesFeed entries] objectAtIndex:row];
  NSString *title = [[volume title] stringValue];

  // append any labels
  NSArray *labelCats = [volume categoriesWithScheme:kGDataBooksLabelsScheme];
  if ([labelCats count] > 0) {

    NSArray *labels = [labelCats valueForKeyPath:@"term"];
    NSString *labelStr = [labels componentsJoinedByString:@", "];

    title = [NSString stringWithFormat:@"%@ (%@)", title, labelStr];
  }
  return title;
}

#pragma mark Setters and Getters

- (GDataFeedVolume *)volumesFeed {
  return mVolumesFeed;
}

- (void)setVolumesFeed:(GDataFeedVolume *)feed {
  [mVolumesFeed autorelease];
  mVolumesFeed = [feed retain];
}

- (NSError *)volumesFetchError {
  return mVolumesFetchError;
}

- (void)setVolumesFetchError:(NSError *)error {
  [mVolumesFetchError release];
  mVolumesFetchError = [error retain];
}

- (GDataServiceTicket *)volumesFetchTicket {
  return mVolumesFetchTicket;
}

- (void)setVolumesFetchTicket:(GDataServiceTicket *)ticket {
  [mVolumesFetchTicket release];
  mVolumesFetchTicket = [ticket retain];
}

- (GDataFeedCollection *)collectionsFeed {
  return mCollectionsFeed;
}

- (void)setCollectionsFeed:(GDataFeedCollection *)feed {
  [mCollectionsFeed autorelease];
  mCollectionsFeed = [feed retain];
}

- (NSError *)collectionsFetchError {
  return mCollectionsFetchError;
}

- (void)setCollectionsFetchError:(NSError *)error {
  [mCollectionsFetchError release];
  mCollectionsFetchError = [error retain];
}

- (GDataServiceTicket *)collectionsFetchTicket {
  return mCollectionsFetchTicket;
}

- (void)setCollectionsFetchTicket:(GDataServiceTicket *)ticket {
  [mCollectionsFetchTicket release];
  mCollectionsFetchTicket = [ticket retain];
}

- (GDataServiceTicket *)annotationsFetchTicket {
  return mAnnotationsFetchTicket;
}

- (void)setAnnotationsFetchTicket:(GDataServiceTicket *)ticket {
  [mAnnotationsFetchTicket release];
  mAnnotationsFetchTicket = [ticket retain];
}

- (NSString *)volumeImageURLString {
  return mVolumeImageURLString;
}

- (void)setVolumeImageURLString:(NSString *)str {
  [mVolumeImageURLString autorelease];
  mVolumeImageURLString = [str copy];
}

- (NSString *)volumeWebURLString {
  return mVolumeWebURLString;
}

- (void)setVolumeWebURLString:(NSString *)str {
  [mVolumeWebURLString autorelease];
  mVolumeWebURLString = [str copy];
}

@end
// thank you for reading this sample code
