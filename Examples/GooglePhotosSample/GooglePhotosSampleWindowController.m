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
//  GooglePhotosSampleWindowController.m
//

#import "GooglePhotosSampleWindowController.h"
#import "GData/GDataServiceGooglePhotos.h"
#import "GData/GDataEntryPhotoAlbum.h"
#import "GData/GDataEntryPhoto.h"
#import "GData/GDataFeedPhoto.h"

@interface GooglePhotosSampleWindowController (PrivateMethods)
- (void)updateUI;

- (void)fetchAllAlbums;
- (void)fetchSelectedAlbum;

- (void)fetchURLString:(NSString *)urlString forImageView:(NSImageView *)view;

- (void)createAnAlbum;
- (void)addAPhoto;
- (void)deleteSelectedPhoto;
- (void)downloadSelectedPhoto;
- (void)moveSelectedPhotoToAlbum:(GDataEntryPhotoAlbum *)albumEntry;

- (void)addTagToSelectedPhoto;
- (void)addCommentToSelectedPhoto;
- (void)postToSelectedPhotoEntry:(GDataEntryPhotoBase *)entry;

- (GDataServiceGooglePhotos *)googlePhotosService;
- (GDataEntryPhotoAlbum *)selectedAlbum;
- (GDataEntryPhoto *)selectedPhoto;

- (GDataFeedPhotoUser *)albumFeed;
- (void)setAlbumFeed:(GDataFeedPhotoUser *)feed;
- (NSError *)albumFetchError;
- (void)setAlbumFetchError:(NSError *)error;  
- (GDataServiceTicket *)albumFetchTicket;
- (void)setAlbumFetchTicket:(GDataServiceTicket *)ticket;
- (NSString *)albumImageURLString;
- (void)setAlbumImageURLString:(NSString *)str;

- (GDataFeedPhotoAlbum *)photoFeed;
- (void)setPhotoFeed:(GDataFeedPhotoAlbum *)feed;
- (NSError *)photoFetchError;
- (void)setPhotoFetchError:(NSError *)error;
- (GDataServiceTicket *)photoFetchTicket;
- (void)setPhotoFetchTicket:(GDataServiceTicket *)ticket;
- (NSString *)photoImageURLString;
- (void)setPhotoImageURLString:(NSString *)str;

- (void)uploadPhotoAtPath:(NSString *)photoPath;
@end

@implementation GooglePhotosSampleWindowController

static GooglePhotosSampleWindowController* gGooglePhotosSampleWindowController = nil;


+ (GooglePhotosSampleWindowController *)sharedGooglePhotosSampleWindowController {
  
  if (!gGooglePhotosSampleWindowController) {
    gGooglePhotosSampleWindowController = [[GooglePhotosSampleWindowController alloc] init];
  }  
  return gGooglePhotosSampleWindowController;
}


- (id)init {
  return [self initWithWindowNibName:@"GooglePhotosSampleWindow"];
}

- (void)windowDidLoad {
}

- (void)awakeFromNib {
  // Set the result text fields to have a distinctive color and mono-spaced font
  // to aid in understanding of each album and photo query operation.
  [mAlbumResultTextField setTextColor:[NSColor darkGrayColor]];
  [mPhotoResultTextField setTextColor:[NSColor darkGrayColor]];

  NSFont *resultTextFont = [NSFont fontWithName:@"Monaco" size:9];
  [mAlbumResultTextField setFont:resultTextFont];
  [mPhotoResultTextField setFont:resultTextFont];
  
  [self updateUI];
}

- (void)dealloc {
  [mUserAlbumFeed release];
  [mAlbumFetchError release];
  [mAlbumFetchTicket release];
  [mAlbumImageURLString release];
  
  [mAlbumPhotosFeed release];
  [mPhotosFetchError release];
  [mPhotosFetchTicket release];
  [mPhotoImageURLString release];
  
  [super dealloc];
}

#pragma mark -

// album and photo thumbnail display

// fetch or clear the thumbnail for this specified album
- (void)updateImageForAlbum:(GDataEntryPhotoAlbum *)album {
  
  // if there's a thumbnail and it's different from the one being shown,
  // fetch it now
  if (!album) {
    // clear the image
    [mAlbumImageView setImage:nil];
    [self setAlbumImageURLString:nil];
    
  } else {    
    // if the new thumbnail URL string is different from the previous one,
    // save the new one, clear the image and fetch the new image
    
    NSArray *thumbnails = [[album mediaGroup] mediaThumbnails];
    if ([thumbnails count] > 0) {
      
      NSString *imageURLString = [[thumbnails objectAtIndex:0] URLString];
      if (!imageURLString || ![mAlbumImageURLString isEqual:imageURLString]) {
        
        [self setAlbumImageURLString:imageURLString];
        [mAlbumImageView setImage:nil];

        if (imageURLString) {
          [self fetchURLString:imageURLString forImageView:mAlbumImageView];
        }
      } 
    }
  }
}

// get or clear the thumbnail for this specified photo
- (void)updateImageForPhoto:(GDataEntryPhoto *)photo {
  
  // if there's a thumbnail and it's different from the one being shown,
  // fetch it now
  if (!photo) {
    // clear the image
    [mPhotoImageView setImage:nil];
    [self setPhotoImageURLString:nil];
    
  } else {    
    // if the new thumbnail URL string is different from the previous one,
    // save the new one, clear the image and fetch the new image
    
    NSArray *thumbnails = [[photo mediaGroup] mediaThumbnails];
    if ([thumbnails count] > 0) {
      
      NSString *imageURLString = [[thumbnails objectAtIndex:0] URLString];
      if (!imageURLString || ![mPhotoImageURLString isEqual:imageURLString]) {
        
        [self setPhotoImageURLString:imageURLString];
        [mPhotoImageView setImage:nil];
        
        if (imageURLString) {
          [self fetchURLString:imageURLString forImageView:mPhotoImageView];
        }
      } 
    }
  }
}

- (void)fetchURLString:(NSString *)urlString forImageView:(NSImageView *)view {
  
  NSURL *imageURL = [NSURL URLWithString:urlString];
  NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
  GDataHTTPFetcher *fetcher = [GDataHTTPFetcher httpFetcherWithRequest:request];
  
  // use the fetcher's userData to remember which image view we'll display
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

#pragma mark -

- (void)updateUI {
  
  // album list display
  [mAlbumTable reloadData]; 
  
  if (mAlbumFetchTicket != nil) {
    [mAlbumProgressIndicator startAnimation:self];  
  } else {
    [mAlbumProgressIndicator stopAnimation:self];  
  }
  
  // album fetch result or selected item
  NSString *albumResultStr = @"";
  if (mAlbumFetchError) {
    albumResultStr = [mAlbumFetchError description];
    [self updateImageForAlbum:nil];
  } else {
    GDataEntryPhotoAlbum *album = [self selectedAlbum];
    if (album) {
      albumResultStr = [album description];
    }
    // fetch or clear the album thumbnail
    [self updateImageForAlbum:album];
  }
  [mAlbumResultTextField setString:albumResultStr];
  
  // photo list display
  [mPhotoTable reloadData]; 
  
  // the bottom table displays photo entries
  if (mPhotosFetchTicket != nil) {
    [mPhotoProgressIndicator startAnimation:self];  
  } else {
    [mPhotoProgressIndicator stopAnimation:self];  
  }
  
  // display photo entry fetch result or selected item
  GDataEntryPhoto *selectedPhoto = [self selectedPhoto];

  NSString *photoResultStr = @"";
  if (mPhotosFetchError) {
    photoResultStr = [mPhotosFetchError description];
    [self updateImageForPhoto:nil];
  } else {
    if (selectedPhoto) {
      photoResultStr = [selectedPhoto description];
    }
    // fetch or clear the photo thumbnail
    [self updateImageForPhoto:selectedPhoto];
  }
  [mPhotoResultTextField setString:photoResultStr];
  
  // enable/disable cancel buttons
  [mAlbumCancelButton setEnabled:(mAlbumFetchTicket != nil)];
  [mPhotoCancelButton setEnabled:(mPhotosFetchTicket != nil)];
  
  // enable/disable other buttons
  BOOL isAlbumSelected = ([self selectedAlbum] != nil);
  BOOL isPasswordProvided = ([[mPasswordField stringValue] length] > 0);
  [mAddPhotoButton setEnabled:(isAlbumSelected && isPasswordProvided)];

  BOOL isPhotoEntrySelected = (selectedPhoto != nil &&
                               [selectedPhoto videoStatus] == nil);
  [mDownloadPhotoButton setEnabled:isPhotoEntrySelected];

  BOOL isSelectedEntryEditable = ([selectedPhoto editLink] != nil);
  [mDeletePhotoButton setEnabled:isSelectedEntryEditable];
  [mChangeAlbumPopupButton setEnabled:isSelectedEntryEditable];
  
  BOOL hasPhotoFeed = ([selectedPhoto feedLink] != nil);
  
  BOOL isTagProvided = ([[mTagField stringValue] length] > 0);
  BOOL isCommentProvided = ([[mCommentField stringValue] length] > 0);
  
  [mAddTagButton setEnabled:(hasPhotoFeed && isTagProvided)];
  [mAddCommentButton setEnabled:(hasPhotoFeed && isCommentProvided)];

  BOOL doesFeedHavePostLink = ([mUserAlbumFeed postLink] != nil);
  BOOL isNewAlbumNameProvided = ([[mCreateAlbumField stringValue] length] > 0);
  BOOL canCreateAlbum = doesFeedHavePostLink && isNewAlbumNameProvided;
  [mCreateAlbumButton setEnabled:canCreateAlbum];
}

- (void)updateChangeAlbumList {
  
  // replace all menu items in the button with the titles and pointers
  // of the feed's entries, but preserve the title
  
  NSString *title = [mChangeAlbumPopupButton title];
  
  NSMenu *menu = [[[NSMenu alloc] initWithTitle:title] autorelease];
  [menu addItemWithTitle:title action:nil keyEquivalent:@""];
  
  [mChangeAlbumPopupButton setMenu:menu];
 
  GDataFeedPhotoUser *feed = [self albumFeed];
  NSArray *entries = [feed entries];
  
  for (int idx = 0; idx < [entries count]; idx++) {
    GDataEntryPhotoAlbum *albumEntry = [entries objectAtIndex:idx];
    
    NSString *title = [[albumEntry title] stringValue];
    NSMenuItem *item = [menu addItemWithTitle:title
                                       action:@selector(changeAlbumSelected:)
                                keyEquivalent:@""];
    [item setTarget:self];
    [item setRepresentedObject:albumEntry];
  }
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  // this enables menu items in the "change the selected photo's album" menu
  //
  // if the selected photo is editable and not in the album represented by
  // this menu item, then enable the menu item
  GDataEntryPhotoAlbum *menuItemAlbum = [menuItem representedObject];

  if ([menuItemAlbum isKindOfClass:[GDataEntryPhotoAlbum class]]) {
    
    GDataEntryPhoto *selectedPhoto = [self selectedPhoto];
    
    BOOL isSelectedPhotoEntryEditable = ([selectedPhoto editLink] != nil);
    
    if (isSelectedPhotoEntryEditable) {
          
      if (menuItemAlbum != nil
          && ![[selectedPhoto albumID] isEqual:[menuItemAlbum GPhotoID]]) {
        return YES;
      }
    }
    return NO;
  }
  
  // unknown item being validated
  return YES;
}

#pragma mark IBActions

- (IBAction)getAlbumClicked:(id)sender {
  
  NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];

  NSString *username = [mUsernameField stringValue];
  username = [username stringByTrimmingCharactersInSet:whitespace];

  if ([username rangeOfString:@"@"].location == NSNotFound) {
    // if no domain was supplied, add @gmail.com
    username = [username stringByAppendingString:@"@gmail.com"];
  }
  
  [mUsernameField setStringValue:username];

  [self fetchAllAlbums];
}

- (IBAction)cancelAlbumFetchClicked:(id)sender {
  [mAlbumFetchTicket cancelTicket];
  [self setAlbumFetchTicket:nil];
  [self updateUI];
}

- (IBAction)cancelPhotoFetchClicked:(id)sender {
  [mPhotosFetchTicket cancelTicket];
  [self setPhotoFetchTicket:nil];
  [self updateUI];
}

- (IBAction)createAlbumClicked:(id)sender {
  [self createAnAlbum];
}

- (IBAction)addClicked:(id)sender {
  [self addAPhoto];
}

- (IBAction)deleteClicked:(id)sender {
  [self deleteSelectedPhoto];
}

- (IBAction)downloadClicked:(id)sender {
  [self downloadSelectedPhoto];
}

- (IBAction)addCommentClicked:(id)sender {
  [self addCommentToSelectedPhoto]; 
}

- (IBAction)addTagClicked:(id)sender {
  [self addTagToSelectedPhoto]; 
}

- (IBAction)loggingCheckboxClicked:(id)sender {
  [GDataHTTPFetcher setIsLoggingEnabled:[sender state]]; 
}
#pragma mark -

// get an album service object with the current username/password
//
// A "service" object handles networking tasks.  Service objects
// contain user authentication information as well as networking
// state information (such as cookies and the "last modified" date for
// fetched data.)

- (GDataServiceGooglePhotos *)googlePhotosService {
  
  static GDataServiceGooglePhotos* service = nil;
  
  if (!service) {
    service = [[GDataServiceGooglePhotos alloc] init];
    
    [service setShouldCacheDatedData:YES];
    [service setServiceShouldFollowNextLinks:YES];
  }

  // update the username/password each time the service is requested
  NSString *username = [mUsernameField stringValue];
  NSString *password = [mPasswordField stringValue];
  if ([username length] && [password length]) {
    [service setUserCredentialsWithUsername:username
                                   password:password];
  } else {
    [service setUserCredentialsWithUsername:nil
                                   password:nil];
  }
  
  return service;
}

// get the album selected in the top list, or nil if none
- (GDataEntryPhotoAlbum *)selectedAlbum {
  
  NSArray *albums = [mUserAlbumFeed entries];
  int rowIndex = [mAlbumTable selectedRow];
  if ([albums count] > 0 && rowIndex > -1) {
    
    GDataEntryPhotoAlbum *album = [albums objectAtIndex:rowIndex];
    return album;
  }
  return nil;
}

// get the photo selected in the bottom list, or nil if none
- (GDataEntryPhoto *)selectedPhoto {
  
  NSArray *photos = [mAlbumPhotosFeed entries];
  int rowIndex = [mPhotoTable selectedRow];
  if ([photos count] > 0 && rowIndex > -1) {
    
    GDataEntryPhoto *photo = [photos objectAtIndex:rowIndex];
    return photo;
  }
  return nil;
}

#pragma mark Fetch all albums

// begin retrieving the list of the user's albums
- (void)fetchAllAlbums {
  
  [self setAlbumFeed:nil];
  [self setAlbumFetchError:nil];
  [self setAlbumFetchTicket:nil];
  
  [self setPhotoFeed:nil];
  [self setPhotoFetchError:nil];
  [self setPhotoFetchTicket:nil];

  NSString *username = [mUsernameField stringValue];
  
  GDataServiceGooglePhotos *service = [self googlePhotosService];
  GDataServiceTicket *ticket;

  NSURL *feedURL = [GDataServiceGooglePhotos photoFeedURLForUserID:username
                                                           albumID:nil
                                                         albumName:nil
                                                           photoID:nil
                                                              kind:nil
                                                            access:nil];
  ticket = [service fetchFeedWithURL:feedURL
                            delegate:self
                   didFinishSelector:@selector(albumListFetchTicket:finishedWithFeed:error:)];
  [self setAlbumFetchTicket:ticket];

  [self updateUI];
}

// album list fetch callback
- (void)albumListFetchTicket:(GDataServiceTicket *)ticket
            finishedWithFeed:(GDataFeedPhotoUser *)feed
                       error:(NSError *)error {

  [self setAlbumFeed:feed];
  [self setAlbumFetchError:error];
  [self setAlbumFetchTicket:nil];

  if (error == nil) {
    // load the Change Album pop-up button with the
    // album entries
    [self updateChangeAlbumList];
  }

  [self updateUI];
}

#pragma mark Fetch an album's photos 

// for the album selected in the top list, begin retrieving the list of
// photos
- (void)fetchSelectedAlbum {

  GDataEntryPhotoAlbum *album = [self selectedAlbum];
  if (album) {

    // fetch the photos feed
    NSURL *feedURL = [[album feedLink] URL];
    if (feedURL) {

      [self setPhotoFeed:nil];
      [self setPhotoFetchError:nil];
      [self setPhotoFetchTicket:nil];

      GDataServiceGooglePhotos *service = [self googlePhotosService];
      GDataServiceTicket *ticket;
      ticket = [service fetchFeedWithURL:feedURL
                                delegate:self
                       didFinishSelector:@selector(photosTicket:finishedWithFeed:error:)];
      [self setPhotoFetchTicket:ticket];

      [self updateUI];
    }
  }
}

// photo list fetch callback
- (void)photosTicket:(GDataServiceTicket *)ticket
    finishedWithFeed:(GDataFeedPhotoAlbum *)feed
               error:(NSError *)error {

  [self setPhotoFeed:feed];
  [self setPhotoFetchError:error];
  [self setPhotoFetchTicket:nil];

  [self updateUI];
}

#pragma mark Create an album

- (void)createAnAlbum {
  NSString *albumName = [mCreateAlbumField stringValue];
  if ([albumName length] > 0) {

    NSString *description = [NSString stringWithFormat:@"Created %@",
                             [NSDate date]];

    BOOL doCreateUnlisted = ([mCreateAlbumUnlistedCheckbox state] == NSOnState);
    NSString *access = (doCreateUnlisted ? kGDataPhotoAccessPrivate : kGDataPhotoAccessPublic);

    GDataEntryPhotoAlbum *newAlbum = [GDataEntryPhotoAlbum albumEntry];
    [newAlbum setTitleWithString:albumName];
    [newAlbum setPhotoDescriptionWithString:description];
    [newAlbum setAccess:access];

    NSURL *postLink = [[mUserAlbumFeed postLink] URL];
    GDataServiceGooglePhotos *service = [self googlePhotosService];

    [service fetchEntryByInsertingEntry:newAlbum
                             forFeedURL:postLink
                               delegate:self
                      didFinishSelector:@selector(createAlbumTicket:finishedWithEntry:error:)];
  }
}

// album creation callback
- (void)createAlbumTicket:(GDataServiceTicket *)ticket
        finishedWithEntry:(GDataEntryPhotoAlbum *)entry
                    error:(NSError *)error {
  if (error == nil) {
    NSBeginAlertSheet(@"Album created", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Created album \"%@\"",
                      [[entry title] stringValue]);

    [self fetchAllAlbums];
  } else {
    NSBeginAlertSheet(@"Failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Creating album failed: %@", error);
  }
}

#pragma mark Add a photo

- (void)addAPhoto {
  
  // see the API documentation for the current list of file types accepted
  // for uploading
  NSArray *fileTypes = [NSArray arrayWithObjects:
                        // image types
                        @"jpeg", @"jpg", @"png", @"gif", @"bmp",
                        
                        // movies types
                        @"mov", @"mpeg", @"avi", @"mpg", @"wmv", @"mp4", @"qt",
                        nil];
  
  // ask the user to choose an image file
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setPrompt:@"Upload"];
  [openPanel beginSheetForDirectory:nil
                               file:nil
                              types:fileTypes
                     modalForWindow:[self window]
                      modalDelegate:self
                     didEndSelector:@selector(openSheetDidEnd:returnCode:contextInfo:)
                        contextInfo:nil];
}

- (void)openSheetDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo {
  
  if (returnCode == NSOKButton) {
    // user chose a photo and clicked OK
    [self uploadPhotoAtPath:[panel filename]];
  }
}

- (void)uploadPhotoAtPath:(NSString *)photoPath {

  // get the path to the selected photo, and read it into an NSData
  NSString *photoName = [photoPath lastPathComponent];

  NSData *photoData = [NSData dataWithContentsOfFile:photoPath];
  if (photoData) {

    // make a new entry for the photo
    GDataEntryPhoto *newEntry = [GDataEntryPhoto photoEntry];

    // set a title, description, and timestamp
    [newEntry setTitleWithString:photoName];
    [newEntry setPhotoDescriptionWithString:photoPath];
    [newEntry setTimestamp:[GDataPhotoTimestamp timestampWithDate:[NSDate date]]];

    // attach the NSData and set the MIME type for the photo
    [newEntry setPhotoData:photoData];

    NSString *mimeType = [GDataUtilities MIMETypeForFileAtPath:photoPath
                                               defaultMIMEType:@"image/jpeg"];
    [newEntry setPhotoMIMEType:mimeType];

    // get the feed URL for the album we're inserting the photo into
    GDataEntryPhotoAlbum *album = [self selectedAlbum];
    NSURL *feedURL = [[album feedLink] URL];

    // to upload to the account's Drop Box, instead of using an album's
    // feedLink, insert directly to this URL:
    //  feedURL = [GDataServiceGooglePhotos photoFeedURLForUserID:kGDataServiceDefaultUser
    //                                                    albumID:kGDataGooglePhotosDropBoxAlbumID
    //                                                  albumName:nil
    //                                                    photoID:nil
    //                                                       kind:nil
    //                                                     access:nil];

    // make service tickets call back into our upload progress selector
    GDataServiceGooglePhotos *service = [self googlePhotosService];

    SEL progressSel = @selector(ticket:hasDeliveredByteCount:ofTotalByteCount:);
    [service setServiceUploadProgressSelector:progressSel];

    // insert the entry into the album feed
    GDataServiceTicket *ticket;
    ticket = [service fetchEntryByInsertingEntry:newEntry
                                      forFeedURL:feedURL
                                        delegate:self
                               didFinishSelector:@selector(addPhotoTicket:finishedWithEntry:error:)];

    // no need for future tickets to monitor progress
    [service setServiceUploadProgressSelector:nil];

  } else {
    // nil data from photo file
    NSBeginAlertSheet(@"Cannot get photo file data", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Could not read photo file: %@", photoName);
  }
}

// progress callback
- (void)ticket:(GDataServiceTicket *)ticket
hasDeliveredByteCount:(unsigned long long)numberOfBytesRead
   ofTotalByteCount:(unsigned long long)dataLength {

  [mUploadProgressIndicator setMinValue:0.0];
  [mUploadProgressIndicator setMaxValue:(double)dataLength];
  [mUploadProgressIndicator setDoubleValue:(double)numberOfBytesRead];
}

// photo add callback
- (void)addPhotoTicket:(GDataServiceTicket *)ticket
     finishedWithEntry:(GDataEntryPhoto *)photoEntry
                 error:(NSError *)error {

  if (error == nil) {
    // tell the user that the add worked
    NSBeginAlertSheet(@"Added Photo", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Photo added: %@",
                      [[photoEntry title] stringValue]);

    // refetch the current album's photos
    [self fetchSelectedAlbum];
    [self updateUI];
  } else {
    // upload failed
    NSBeginAlertSheet(@"Add failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Photo add failed: %@", error);
  }

  [mUploadProgressIndicator setDoubleValue:0.0];
}

#pragma mark Delete a photo

- (void)deleteSelectedPhoto {
  GDataEntryPhoto *photo = [self selectedPhoto];
  if (photo) {
    // make the user confirm that the selected photo should be deleted
    NSBeginAlertSheet(@"Delete Photo", @"Delete", @"Cancel", nil,
                      [self window], self,
                      @selector(deleteSheetDidEnd:returnCode:contextInfo:),
                      nil, nil, @"Delete the item \"%@\"?",
                      [[photo title] stringValue]);
  }
}

// delete dialog callback
- (void)deleteSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {

  if (returnCode == NSAlertDefaultReturn) {

    // delete the photo
    GDataEntryPhoto *photo = [self selectedPhoto];

    if ([photo canEdit]) {
      GDataServiceGooglePhotos *service = [self googlePhotosService];
      [service deleteEntry:photo
                  delegate:self
         didFinishSelector:@selector(deleteTicket:nilObject:error:)];
    }
  }
}

// photo delete callback
- (void)deleteTicket:(GDataServiceTicket *)ticket
           nilObject:(GDataFeedPhoto *)object
               error:(NSError *)error {
  if (error == nil) {
    NSBeginAlertSheet(@"Deleted Photo", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Photo deleted");

    // re-fetch the selected album's photos
    [self fetchSelectedAlbum];
    [self updateUI];
  } else {
    NSBeginAlertSheet(@"Delete failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Photo delete failed: %@", error);
  }
}

#pragma mark Download a photo

- (void)downloadSelectedPhoto {
  GDataEntryPhoto *photoEntry = [self selectedPhoto];
  if (photoEntry) {
    // display a save panel to let the user pick the directory and
    // name for saving the image
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel beginSheetForDirectory:nil
                                 file:[[photoEntry title] stringValue]
                       modalForWindow:[self window]
                        modalDelegate:self
                       didEndSelector:@selector(saveSheetDidEnd:returnCode:contextInfo:)
                          contextInfo:[photoEntry retain]];
  }
}

- (void)saveSheetDidEnd:(NSOpenPanel *)panel
             returnCode:(int)returnCode
            contextInfo:(void *)contextInfo {
  GDataEntryPhoto *photoEntry = [(GDataEntryPhoto *)contextInfo autorelease];

  if (returnCode == NSOKButton) {
    // the user clicked Save
    //
    // the feed may not have images in the original size, so we'll re-fetch the
    // photo entry with a query specifying that we want the original size
    // for downloading
    NSString *savePath = [panel filename];

    NSURL *entryURL = [[photoEntry selfLink] URL];

    GDataQueryGooglePhotos *query;
    query = [GDataQueryGooglePhotos photoQueryWithFeedURL:entryURL];

    // this specifies "imgmax=d" as described at
    // http://code.google.com/apis/picasaweb/docs/2.0/reference.html#Parameters
    [query setImageSize:kGDataGooglePhotosImageSizeDownloadable];

    GDataServiceGooglePhotos *service = [self googlePhotosService];
    GDataServiceTicket *ticket;
    ticket = [service fetchEntryWithURL:[query URL]
                               delegate:self
                      didFinishSelector:@selector(fetchEntryTicket:finishedWithEntry:error:)];

    [ticket setProperty:savePath forKey:@"save path"];
  }
}

- (void)fetchEntryTicket:(GDataServiceTicket *)ticket
       finishedWithEntry:(GDataEntryPhoto *)photoEntry
                   error:(NSError *)error {
  if (error == nil) {
    // now download the uploaded photo data
    NSString *savePath = [ticket propertyForKey:@"save path"];

    // we'll search for the media content element with the medium attribute of
    // "image" to find the download URL; there may be more than one
    // media:content element
    //
    // http://code.google.com/apis/picasaweb/docs/2.0/reference.html#media_content
    NSArray *mediaContents = [[photoEntry mediaGroup] mediaContents];
    GDataMediaContent *imageContent;
    imageContent = [GDataUtilities firstObjectFromArray:mediaContents
                                              withValue:@"image"
                                             forKeyPath:@"medium"];
    if (imageContent) {
      NSURL *downloadURL = [NSURL URLWithString:[imageContent URLString]];

      // the service object creates an authenticated request for us
      GDataServiceGooglePhotos *service = [self googlePhotosService];
      NSMutableURLRequest *request = [service requestForURL:downloadURL
                                                       ETag:nil
                                                 httpMethod:nil];
      // fetch the request
      GDataHTTPFetcher *fetcher = [GDataHTTPFetcher httpFetcherWithRequest:request];
      [fetcher beginFetchWithDelegate:self
                    didFinishSelector:@selector(downloadFetcher:finishedWithData:)
                      didFailSelector:@selector(downloadFetcher:failedWithError:)];

      [fetcher setProperty:savePath forKey:@"save path"];
      [fetcher setProperty:photoEntry forKey:@"photo entry"];
    } else {
      // no image content for this photo entry; this shouldn't happen for
      // photos
    }
  } else {
    NSBeginAlertSheet(@"Download failed", nil, nil, nil,
                      [self window], nil, nil, nil, nil,
                      @"Getting downloadable photo failed: %@", error);
  }
}

- (void)downloadFetcher:(GDataHTTPFetcher *)fetcher
       finishedWithData:(NSData *)data {
  // successfully retrieved this photo's data; save it to disk
  NSString *savePath = [fetcher propertyForKey:@"save path"];
  GDataEntryPhoto *photoEntry = [fetcher propertyForKey:@"photo entry"];

  NSError *error = nil;
  BOOL didSave = [data writeToFile:savePath
                           options:NSAtomicWrite
                             error:&error];
  if (didSave) {
    // we'll set the file date to match the photo entry's date
    NSDate *photoDate = [[photoEntry timestamp] dateValue];
    if (photoDate) {
      NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:
                            photoDate, NSFileCreationDate,
                            photoDate, NSFileModificationDate, nil];
      NSFileManager *fileMgr = [NSFileManager defaultManager];
      [fileMgr changeFileAttributes:attr atPath:savePath];
    }
    NSBeginAlertSheet(@"Saved", nil, nil, nil,
                      [self window], nil, nil, nil, nil,
                      @"Saved photo: %@", savePath);
  } else {
    // error saving file.  Perhaps out of space?  Write permissions error?
    NSBeginAlertSheet(@"Save failed", nil, nil, nil,
                      [self window], nil, nil, nil, nil,
                      @"Saving photo to disk failed: %@", error);
  }
}

- (void)downloadFetcher:(GDataHTTPFetcher *)fetcher
        failedWithError:(NSError *)error {
  NSBeginAlertSheet(@"Download failed", nil, nil, nil,
                    [self window], nil, nil, nil, nil,
                    @"Downloading photo failed: %@", error);
}

#pragma mark Move a photo to another album

static NSString* const kDestAlbumKey = @"DestAlbum";

- (void)changeAlbumSelected:(id)sender {
  // move the selected photo to the album represented by the sender menu item
  NSMenuItem *menuItem = sender;
  GDataEntryPhotoAlbum *albumEntry = [menuItem representedObject];
  if (albumEntry) {
    [self moveSelectedPhotoToAlbum:albumEntry];
  }
}

- (void)moveSelectedPhotoToAlbum:(GDataEntryPhotoAlbum *)albumEntry {

  GDataEntryPhoto *photo = [self selectedPhoto];
  if (photo) {

    NSString *destAlbumID = [albumEntry GPhotoID];

    // let the photo entry retain its target album ID as a property
    // (since the contextInfo isn't retained)
    [photo setProperty:destAlbumID forKey:kDestAlbumKey];

    // make the user confirm that the selected photo should be moved
    NSBeginAlertSheet(@"Move Photo", @"Move", @"Cancel", nil,
                      [self window], self,
                      @selector(moveSheetDidEnd:returnCode:contextInfo:),
                      nil, nil,
                      @"Move the item \"%@\" to the album \"%@\"?",
                      [[photo title] stringValue],
                      [[albumEntry title] stringValue]);
  }
}

// move dialog callback
- (void)moveSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {

  if (returnCode == NSAlertDefaultReturn) {

    // move the photo
    GDataEntryPhoto *photo = [self selectedPhoto];

    // set the album to move to as the photo's new album ID
    NSString *albumID = [photo propertyForKey:kDestAlbumKey];
    [photo setAlbumID:albumID];

    GDataServiceGooglePhotos *service = [self googlePhotosService];
    [service fetchEntryByUpdatingEntry:photo
                              delegate:self
                     didFinishSelector:@selector(moveTicket:finishedWithEntry:error:)];
  }
}

// photo move callback
- (void)moveTicket:(GDataServiceTicket *)ticket
 finishedWithEntry:(GDataEntryPhoto *)entry
             error:(NSError *)error {
  if (error == nil) {
    NSBeginAlertSheet(@"Moved Photo", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Photo moved");

    // re-fetch the selected album's photos
    [self fetchSelectedAlbum];
    [self updateUI];
  } else {
    NSBeginAlertSheet(@"Move failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Photo move failed: %@", error);
  }
}

#pragma mark Add a tag or comment to a photo

- (void)addTagToSelectedPhoto {

  NSString *tagText = [mTagField stringValue];
  if ([tagText length]) {

    GDataEntryPhotoTag *tagEntry = [GDataEntryPhotoTag tagEntryWithString:tagText];

    [self postToSelectedPhotoEntry:tagEntry];
  }

}

- (void)addCommentToSelectedPhoto {

  NSString *commentText = [mCommentField stringValue];
  if ([commentText length]) {

    GDataEntryPhotoComment *commentEntry;
    commentEntry = [GDataEntryPhotoComment commentEntryWithString:commentText];

    [self postToSelectedPhotoEntry:commentEntry];
  }
}

- (void)postToSelectedPhotoEntry:(GDataEntryPhotoBase *)entry {
  // called by addTag and addComment

  GDataEntryPhoto *photo = [self selectedPhoto];
  if (photo) {

    NSURL *postURL = [[photo feedLink] URL];
    if (postURL) {

      GDataServiceGooglePhotos *service = [self googlePhotosService];
      [service fetchEntryByInsertingEntry:entry
                               forFeedURL:postURL
                                 delegate:self
                        didFinishSelector:@selector(postToPhotoTicket:finishedWithEntry:error:)];
    }
  }
}


// tag or comment posted successfully
- (void)postToPhotoTicket:(GDataServiceTicket *)ticket
        finishedWithEntry:(GDataEntryPhotoBase *)entry
                    error:(NSError *)error {
  if (error == nil) {
    NSString *label;

    if ([entry isKindOfClass:[GDataEntryPhotoComment class]]) {
      label = @"comment";
    } else {
      label = @"tag";
    }

    NSBeginAlertSheet(@"Added", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Successfully added %@ to photo", label);

    // re-fetch the selected album's photos
    [self fetchSelectedAlbum];
    [self updateUI];
  } else {
    NSBeginAlertSheet(@"Add failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Add post failed: %@", error);
  }
}

////////////////////////////////////////////////////////
#pragma mark Text field delegate methods

- (void)controlTextDidChange:(NSNotification *)note {
  id sender = [note object];
  if (sender == mTagField
      || sender == mCommentField
      || sender == mCreateAlbumField) {

    [self updateUI]; // enabled/disable the Add buttons
  }
}

#pragma mark TableView delegate methods
//
// table view delegate methods
//

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  
  if ([notification object] == mAlbumTable) {
    [self fetchSelectedAlbum];
  } else {
    // the user clicked on an entry; 
    // just display it below the entry table
    
    [self updateUI]; 
  }
}

// table view data source methods
- (int)numberOfRowsInTableView:(NSTableView *)tableView {
  if (tableView == mAlbumTable) {
    return [[mUserAlbumFeed entries] count];
  } else {
    // entry table
    return [[mAlbumPhotosFeed entries] count];
  }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
  if (tableView == mAlbumTable) {
    // get the album entry's title
    GDataEntryPhotoAlbum *album = [[mUserAlbumFeed entries] objectAtIndex:row];
    return [[album title] stringValue];
  } else {
    // get the photo entry's title
    GDataEntryPhoto *photoEntry = [[mAlbumPhotosFeed entries] objectAtIndex:row];
    return [[photoEntry title] stringValue];
  }
  return nil;
}

#pragma mark Setters and Getters

- (GDataFeedPhotoUser *)albumFeed {
  return mUserAlbumFeed; 
}

- (void)setAlbumFeed:(GDataFeedPhotoUser *)feed {
  [mUserAlbumFeed autorelease];
  mUserAlbumFeed = [feed retain];
}

- (NSError *)albumFetchError {
  return mAlbumFetchError; 
}

- (void)setAlbumFetchError:(NSError *)error {
  [mAlbumFetchError release];
  mAlbumFetchError = [error retain];
}

- (GDataServiceTicket *)albumFetchTicket {
  return mAlbumFetchTicket; 
}

- (void)setAlbumFetchTicket:(GDataServiceTicket *)ticket {
  [mAlbumFetchTicket release];
  mAlbumFetchTicket = [ticket retain];
}

- (NSString *)albumImageURLString {
  return mAlbumImageURLString;
}

- (void)setAlbumImageURLString:(NSString *)str {
  [mAlbumImageURLString autorelease];
  mAlbumImageURLString = [str copy];
}

- (GDataFeedPhotoAlbum *)photoFeed {
  return mAlbumPhotosFeed; 
}

- (void)setPhotoFeed:(GDataFeedPhotoAlbum *)feed {
  [mAlbumPhotosFeed autorelease];
  mAlbumPhotosFeed = [feed retain];
}

- (NSError *)photoFetchError {
  return mPhotosFetchError; 
}

- (void)setPhotoFetchError:(NSError *)error {
  [mPhotosFetchError release];
  mPhotosFetchError = [error retain];
}

- (GDataServiceTicket *)photoFetchTicket {
  return mPhotosFetchTicket; 
}

- (void)setPhotoFetchTicket:(GDataServiceTicket *)ticket {
  [mPhotosFetchTicket release];
  mPhotosFetchTicket = [ticket retain];
}

- (NSString *)photoImageURLString {
  return mPhotoImageURLString;
}

- (void)setPhotoImageURLString:(NSString *)str {
  [mPhotoImageURLString autorelease];
  mPhotoImageURLString = [str copy];
}


@end
