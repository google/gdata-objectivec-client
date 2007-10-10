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
//  PicasaWebSampleWindowController.m
//

// Note: Though this sample doesn't demonstrate it, GData responses are
//       typically chunked, so check all returned feeds for "next" links
//       (use -nextLink method from the GDataLinkArray category on the
//       links array of GData objects.)

#import "PicasaWebSampleWindowController.h"
#import "GData/GDataServiceGooglePicasaWeb.h"
#import "GData/GDataEntryPhotoAlbum.h"
#import "GData/GDataEntryPhoto.h"
#import "GData/GDataFeedPhoto.h"

@interface PicasaWebSampleWindowController (PrivateMethods)
- (void)updateUI;

- (void)fetchAllAlbums;
- (void)fetchSelectedAlbum;

- (void)fetchURLString:(NSString *)urlString forImageView:(NSImageView *)view;

- (void)addAPhoto;
- (void)deleteSelectedPhoto;

- (void)addTagToSelectedPhoto;
- (void)addCommentToSelectedPhoto;
- (void)postToSelectedPhotoEntry:(GDataEntryPhotoBase *)entry;

- (GDataServiceGooglePicasaWeb *)picasaWebService;
- (GDataEntryPhotoAlbum *)selectedAlbum;
- (GDataEntryPhoto *)selectedPhoto;

- (GDataFeedPhotoAlbum *)albumFeed;
- (void)setAlbumFeed:(GDataFeedPhotoAlbum *)feed;
- (NSError *)albumFetchError;
- (void)setAlbumFetchError:(NSError *)error;  
- (GDataServiceTicket *)albumFetchTicket;
- (void)setAlbumFetchTicket:(GDataServiceTicket *)ticket;
- (NSString *)albumImageURLString;
- (void)setAlbumImageURLString:(NSString *)str;

- (GDataFeedPhoto *)photoFeed;
- (void)setPhotoFeed:(GDataFeedPhoto *)feed;
- (NSError *)photoFetchError;
- (void)setPhotoFetchError:(NSError *)error;
- (GDataServiceTicket *)photoFetchTicket;
- (void)setPhotoFetchTicket:(GDataServiceTicket *)ticket;
- (NSString *)photoImageURLString;
- (void)setPhotoImageURLString:(NSString *)str;

- (void)uploadPhotoAtPath:(NSString *)photoPath;
- (NSString *)MIMETypeForPhotoAtPath:(NSString *)path;
@end

@implementation PicasaWebSampleWindowController

static PicasaWebSampleWindowController* gPicasaWebSampleWindowController = nil;


+ (PicasaWebSampleWindowController *)sharedPicasaWebSampleWindowController {
  
  if (!gPicasaWebSampleWindowController) {
    gPicasaWebSampleWindowController = [[PicasaWebSampleWindowController alloc] init];
  }  
  return gPicasaWebSampleWindowController;
}


- (id)init {
  return [self initWithWindowNibName:@"PicasaWebSampleWindow"];
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
  [mAlbumFeed release];
  [mAlbumFetchError release];
  [mAlbumFetchTicket release];
  [mAlbumImageURLString release];
  
  [mPhotosFeed release];
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
        didFailWithStatusSelector:@selector(imageFetcher:failedWithStatus:data:)
         didFailWithErrorSelector:@selector(imageFetcher:failedWithError:)];
}

- (void)imageFetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data {
  // got the data; display it in the image view
  NSImage *image = [[[NSImage alloc] initWithData:data] autorelease];
  
  NSImageView *view = (NSImageView *)[fetcher userData];
  [view setImage:image];
}

- (void)imageFetcher:(GDataHTTPFetcher *)fetcher failedWithStatus:(int)status data:(NSData *)data {
  // failed with server status
  NSString *dataStr = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
  NSLog(@"imageFetcher:%@ failedWithStatus:%d data:%@",
        fetcher, status, dataStr);       
}

- (void)imageFetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error {
  // failed with network error
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
  NSString *photoResultStr = @"";
  if (mPhotosFetchError) {
    photoResultStr = [mPhotosFetchError description];
    [self updateImageForPhoto:nil];
  } else {
    GDataEntryPhoto *photo = [self selectedPhoto];
    if (photo) {
      photoResultStr = [photo description];
    }
    // fetch or clear the photo thumbnail
    [self updateImageForPhoto:photo];
  }
  [mPhotoResultTextField setString:photoResultStr];
  
  // enable/disable cancel buttons
  [mAlbumCancelButton setEnabled:(mAlbumFetchTicket != nil)];
  [mPhotoCancelButton setEnabled:(mPhotosFetchTicket != nil)];
  
  // enable/disable other buttons
  BOOL isAlbumSelected = ([self selectedAlbum] != nil);
  BOOL isPasswordProvided = ([[mPasswordField stringValue] length] > 0);

  [mAddPhotoButton setEnabled:(isAlbumSelected && isPasswordProvided)];
  
  BOOL isSelectedEntryEditable = 
    ([[[self selectedPhoto] links] editLink] != nil);
  
  [mDeletePhotoButton setEnabled:isSelectedEntryEditable];
  
  BOOL hasPhotoFeed = 
    ([[[self selectedPhoto] links] feedLink] != nil);
  
  BOOL isTagProvided = ([[mTagField stringValue] length] > 0);
  BOOL isCommentProvided = ([[mCommentField stringValue] length] > 0);
  
  [mAddTagButton setEnabled:(hasPhotoFeed && isTagProvided)];
  [mAddCommentButton setEnabled:(hasPhotoFeed && isCommentProvided)];  
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

- (IBAction)addClicked:(id)sender {
  [self addAPhoto];
}

- (IBAction)deleteClicked:(id)sender {
  [self deleteSelectedPhoto];
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

- (GDataServiceGooglePicasaWeb *)picasaWebService {
  
  static GDataServiceGooglePicasaWeb* service = nil;
  
  if (!service) {
    service = [[GDataServiceGooglePicasaWeb alloc] init];
    
    [service setUserAgent:@"Google-SamplePicasaWebApp-1.0"];
    [service setShouldCacheDatedData:YES];
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
  
  NSArray *albums = [mAlbumFeed entries];
  int rowIndex = [mAlbumTable selectedRow];
  if ([albums count] > 0 && rowIndex > -1) {
    
    GDataEntryPhotoAlbum *album = [albums objectAtIndex:rowIndex];
    return album;
  }
  return nil;
}

// get the photo selected in the bottom list, or nil if none
- (GDataEntryPhoto *)selectedPhoto {
  
  NSArray *photos = [mPhotosFeed entries];
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
  
  GDataServiceGooglePicasaWeb *service = [self picasaWebService];
  GDataServiceTicket *ticket;
  
  NSURL *feedURL = [GDataServiceGooglePicasaWeb picasaWebFeedURLForUserID:username
                                                                  albumID:nil
                                                                albumName:nil
                                                                  photoID:nil
                                                                     kind:nil
                                                                   access:nil];
  ticket = [service fetchPicasaWebFeedWithURL:feedURL
                                     delegate:self
                            didFinishSelector:@selector(albumListFetchTicket:finishedWithFeed:)
                              didFailSelector:@selector(albumListFetchTicket:failedWithError:)];
  [self setAlbumFetchTicket:ticket];
  
  [self updateUI];
}

//
// album list fetch callbacks
//

// finished album list successfully
- (void)albumListFetchTicket:(GDataServiceTicket *)ticket
               finishedWithFeed:(GDataFeedPhotoAlbum *)object {
  
  [self setAlbumFeed:object];
  [self setAlbumFetchError:nil];    
  [self setAlbumFetchTicket:nil];

  [self updateUI];
} 

// failed
- (void)albumListFetchTicket:(GDataServiceTicket *)ticket
                failedWithError:(NSError *)error {
  
  [self setAlbumFeed:nil];
  [self setAlbumFetchError:error];    
  [self setAlbumFetchTicket:nil];

  [self updateUI];
}

#pragma mark Fetch an album's photos 

// for the album selected in the top list, begin retrieving the list of
// photos
- (void)fetchSelectedAlbum {
  
  GDataEntryPhotoAlbum *album = [self selectedAlbum];
  if (album) {
    
    // fetch the photos feed
    NSURL *feedURL = [[[album links] feedLink] URL];
    if (feedURL) {
      
      [self setPhotoFeed:nil];
      [self setPhotoFetchError:nil];
      [self setPhotoFetchTicket:nil];
      
      GDataServiceGooglePicasaWeb *service = [self picasaWebService];
      GDataServiceTicket *ticket;
      ticket = [service fetchPicasaWebFeedWithURL:feedURL
                                         delegate:self
                                didFinishSelector:@selector(photosTicket:finishedWithEntries:)
                                  didFailSelector:@selector(photosTicket:failedWithError:)];
      [self setPhotoFetchTicket:ticket];

      [self updateUI];
    }
  }
}

//
// entries list fetch callbacks
//

// fetched photo list successfully
- (void)photosTicket:(GDataServiceTicket *)ticket
         finishedWithEntries:(GDataFeedPhoto *)object {
  
  [self setPhotoFeed:object];
  [self setPhotoFetchError:nil];
  [self setPhotoFetchTicket:nil];
  
  [self updateUI];
} 

// failed
- (void)photosTicket:(GDataServiceTicket *)ticket
             failedWithError:(NSError *)error {
  
  [self setPhotoFeed:nil];
  [self setPhotoFetchError:error];
  [self setPhotoFetchTicket:nil];
  
  [self updateUI];
  
}

#pragma mark Add a photo

- (void)addAPhoto {
  // ask the user to choose an image file
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setPrompt:@"Upload"];
  [openPanel beginSheetForDirectory:nil
                               file:nil
                              types:[NSImage imageFileTypes]
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
    
    NSString *mimeType = [GDataEntryBase MIMETypeForFileAtPath:photoPath
                                               defaultMIMEType:@"image/jpeg"];
    [newEntry setPhotoMIMEType:mimeType];
    
    // get the feed URL for the album we're inserting the photo into
    GDataEntryPhotoAlbum *album = [self selectedAlbum];
    NSURL *feedURL = [[[album links] feedLink] URL];
    
    // make service tickets call back into our upload progress selector
    GDataServiceGooglePicasaWeb *service = [self picasaWebService];
    
    SEL progressSel = @selector(inputStream:hasDeliveredByteCount:ofTotalByteCount:);
    [service setServiceUploadProgressSelector:progressSel];
    
    // insert the entry into the album feed
    GDataServiceTicket *ticket;
    ticket = [service fetchPicasaWebEntryByInsertingEntry:newEntry
                                               forFeedURL:feedURL
                                                 delegate:self
                                        didFinishSelector:@selector(addPhotoTicket:finishedWithEntry:)
                                          didFailSelector:@selector(addPhotoTicket:failedWithError:)];

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
- (void)inputStream:(GDataProgressMonitorInputStream *)stream 
   hasDeliveredByteCount:(unsigned long long)numberOfBytesRead 
   ofTotalByteCount:(unsigned long long)dataLength {
  
  [mUploadProgressIndicator setMinValue:0.0];
  [mUploadProgressIndicator setMaxValue:(double)dataLength];
  [mUploadProgressIndicator setDoubleValue:(double)numberOfBytesRead];
}

// photo added successfully
- (void)addPhotoTicket:(GDataServiceTicket *)ticket
     finishedWithEntry:(GDataEntryPhoto *)photoEntry {
  
  // tell the user that the add worked
  NSBeginAlertSheet(@"Added Photo", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Photo added: %@", 
                    [[photoEntry title] stringValue]);
  
  // refetch the current album's photos
  [self fetchSelectedAlbum];
  [self updateUI];
  [mUploadProgressIndicator setDoubleValue:0.0];
} 

// failure to add photo
- (void)addPhotoTicket:(GDataServiceTicket *)ticket
       failedWithError:(NSError *)error {
  
  NSBeginAlertSheet(@"Add failed", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Photo add failed: %@", error);
  
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
                      nil, nil, @"Delete the photo \"%@\"?",
                      [[photo title] stringValue]);
  }
}

// delete dialog callback
- (void)deleteSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
  
  if (returnCode == NSAlertDefaultReturn) {
    
    // delete the photo
    GDataEntryPhoto *photo = [self selectedPhoto];
    GDataLink *link = [[photo links] editLink];
    
    if (link) {
      GDataServiceGooglePicasaWeb *service = [self picasaWebService];
      [service deletePicasaWebResourceURL:[link URL]
                                 delegate:self 
                        didFinishSelector:@selector(deleteTicket:deletedEntry:)
                          didFailSelector:@selector(deleteTicket:failedWithError:)];
    }
  }
}

// photo deleted successfully
- (void)deleteTicket:(GDataServiceTicket *)ticket
        deletedEntry:(GDataFeedPhoto *)object {
  
  NSBeginAlertSheet(@"Deleted Photo", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Photo deleted");
  
  // re-fetch the selected album's photos
  [self fetchSelectedAlbum];
  [self updateUI];
} 


// failure to delete photo
- (void)deleteTicket:(GDataServiceTicket *)ticket
     failedWithError:(NSError *)error {
  
  NSBeginAlertSheet(@"Delete failed", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Photo delete failed: %@", error);
  
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
    
    NSURL *postURL = [[[photo links] feedLink] URL];
    if (postURL) {
      
      GDataServiceGooglePicasaWeb *service = [self picasaWebService];
      [service fetchPicasaWebEntryByInsertingEntry:entry
                                        forFeedURL:postURL
                                          delegate:self
                                 didFinishSelector:@selector(postToPhotoTicket:finishedWithEntry:)
                                   didFailSelector:@selector(postToPhotoTicket:failedWithError:)];
    }
  }
}


// tag or comment posted successfully
- (void)postToPhotoTicket:(GDataServiceTicket *)ticket
        finishedWithEntry:(GDataEntryPhotoBase *)object {
  
  NSString *label;
  
  if ([object isKindOfClass:[GDataEntryPhotoComment class]]) {
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
} 


// failure to delete photo
- (void)postToPhotoTicket:(GDataServiceTicket *)ticket
          failedWithError:(NSError *)error {
  
  NSBeginAlertSheet(@"Post failed", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Photo post failed: %@", error);
  
}


////////////////////////////////////////////////////////
#pragma mark Text field delegate methods

- (void)controlTextDidChange:(NSNotification *)note {
  if ([note object] == mTagField || [note object] == mCommentField) {
    
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
    return [[mAlbumFeed entries] count];
  } else {
    // entry table
    return [[mPhotosFeed entries] count];
  }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
  if (tableView == mAlbumTable) {
    // get the album entry's title
    GDataEntryPhotoAlbum *album = [[mAlbumFeed entries] objectAtIndex:row];
    return [[album title] stringValue];
  } else {
    // get the photo entry's title
    GDataEntryPhoto *photoEntry = [[mPhotosFeed entries] objectAtIndex:row];
    return [[photoEntry title] stringValue];
  }
  return nil;
}

#pragma mark Setters and Getters

- (GDataFeedPhotoAlbum *)albumFeed {
  return mAlbumFeed; 
}

- (void)setAlbumFeed:(GDataFeedPhotoAlbum *)feed {
  [mAlbumFeed autorelease];
  mAlbumFeed = [feed retain];
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

- (GDataFeedPhoto *)photoFeed {
  return mPhotosFeed; 
}

- (void)setPhotoFeed:(GDataFeedPhoto *)feed {
  [mPhotosFeed autorelease];
  mPhotosFeed = [feed retain];
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
