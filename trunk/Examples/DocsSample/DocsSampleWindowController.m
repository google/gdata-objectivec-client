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
//  DocsSampleWindowController.m
//

#import "DocsSampleWindowController.h"
#import "GData/GDataServiceGoogleDocs.h"
#import "GData/GDataQueryDocs.h"
#import "GData/GDataEntryDocBase.h"
#import "GData/GDataEntrySpreadsheetDoc.h"
#import "GData/GDataEntryPresentationDoc.h"
#import "GData/GDataEntryStandardDoc.h"

@interface DocsSampleWindowController (PrivateMethods)
- (void)updateUI;
- (void)updateChangeFolderPopup;

- (void)fetchDocList;

- (void)uploadFileAtPath:(NSString *)path;

- (GDataServiceGoogleDocs *)docsService;
- (GDataEntryDocBase *)selectedDoc;

- (GDataFeedDocList *)docListFeed;
- (void)setDocListFeed:(GDataFeedDocList *)feed;
- (NSError *)docListFetchError;
- (void)setDocListFetchError:(NSError *)error;  
- (GDataServiceTicket *)docListFetchTicket;
- (void)setDocListFetchTicket:(GDataServiceTicket *)ticket;

- (GDataServiceTicket *)uploadTicket;
- (void)setUploadTicket:(GDataServiceTicket *)ticket;
@end

@implementation DocsSampleWindowController

static DocsSampleWindowController* gDocsSampleWindowController = nil;

+ (DocsSampleWindowController *)sharedDocsSampleWindowController {
  
  if (!gDocsSampleWindowController) {
    gDocsSampleWindowController = [[DocsSampleWindowController alloc] init];
  }  
  return gDocsSampleWindowController;
}


- (id)init {
  return [self initWithWindowNibName:@"DocsSampleWindow"];
}

- (void)windowDidLoad {
}

- (void)awakeFromNib {
  // Set the result text field to have a distinctive color and mono-spaced font
  // to aid in understanding of each operation.
  [mDocListResultTextField setTextColor:[NSColor darkGrayColor]];

  NSFont *resultTextFont = [NSFont fontWithName:@"Monaco" size:9];
  [mDocListResultTextField setFont:resultTextFont];
  
  [self updateUI];
}

- (void)dealloc {
  [mDocListFeed release];
  [mDocListFetchError release];
  [mDocListFetchTicket release];
  
  [mUploadTicket cancelTicket];
  [mUploadTicket release];
  
  [super dealloc];
}

#pragma mark -

- (void)updateUI {
  
  // docList list display
  [mDocListTable reloadData]; 
  
  GDataEntryDocBase *selectedDoc = [self selectedDoc];
  
  // spin indicator when retrieving feed
  BOOL isFetchingDocList = (mDocListFetchTicket != nil);
  if (isFetchingDocList) {
    [mDocListProgressIndicator startAnimation:self];  
  } else {
    [mDocListProgressIndicator stopAnimation:self];  
  }
  [mDocListCancelButton setEnabled:isFetchingDocList];
  
  // show the feed fetch result error or the selected entry
  NSString *docResultStr = @"";
  if (mDocListFetchError) {
    docResultStr = [mDocListFetchError description];
  } else {
    if (selectedDoc) {
      docResultStr = [selectedDoc description];
    }
  }
  [mDocListResultTextField setString:docResultStr];
  
  // enable the button for viewing the selected doc in a browser
  BOOL doesDocHaveHTMLLink = ([selectedDoc HTMLLink] != nil);
  [mViewSelectedDocButton setEnabled:doesDocHaveHTMLLink];
  
  BOOL doesDocHaveHTMLContent = ([[[selectedDoc content] type] isEqual:@"text/html"]);
  [mDownloadSelectedDocButton setEnabled:doesDocHaveHTMLContent];
  
  BOOL doesDocHaveEditLink = ([selectedDoc editLink] != nil);
  [mDeleteSelectedDocButton setEnabled:doesDocHaveEditLink];
  
  // enable uploading buttons 
  BOOL isUploading = (mUploadTicket != nil);
  BOOL canPostToFeed = ([mDocListFeed postLink] != nil);

  [mUploadFileButton setEnabled:(canPostToFeed && !isUploading)];
  [mStopUploadButton setEnabled:isUploading];
  [mCreateFolderButton setEnabled:canPostToFeed];

  // fill in the add-to-folder pop-up for the selected doc
  [self updateChangeFolderPopup];

  // show the title of the file currently uploading
  NSString *uploadingStr = @"";
  NSString *uploadingTitle = [[(GDataEntryBase *) 
    [mDocListFetchTicket postedObject] title] stringValue];
  
  if (uploadingTitle) {
    uploadingStr = [NSString stringWithFormat:@"Uploading: %@", uploadingTitle];
  }
  [mUploadingTextField setStringValue:uploadingStr];
}

- (void)updateChangeFolderPopup {

  // replace all menu items in the button with the folder titles and pointers
  // of the feed's folder entries, but preserve the pop-up's "Change Folder"
  // title as the first item

  NSString *title = [mFolderMembershipPopup title];

  NSMenu *addMenu = [[[NSMenu alloc] initWithTitle:title] autorelease];
  [addMenu setAutoenablesItems:NO];
  [addMenu addItemWithTitle:title action:nil keyEquivalent:@""];
  [mFolderMembershipPopup setMenu:addMenu];

  // get all folder entries
  NSArray *folderEntries = [mDocListFeed entriesWithCategoryKind:kGDataCategoryFolderDoc];

  // get hrefs of folders that already contain the selected doc
  GDataEntryDocBase *doc = [self selectedDoc];
  NSArray *parentLinks = [doc linksWithRelAttributeValue:kGDataCategoryDocParent];
  NSArray *parentHrefs = [parentLinks valueForKey:@"href"];

  // disable the pop-up if a folder entry is selected
  BOOL isMovableDocSelected = (doc != nil)
    && ![doc isKindOfClass:[GDataEntryFolderDoc class]];
  [mFolderMembershipPopup setEnabled:isMovableDocSelected];

  if (isMovableDocSelected) {
    // step through the folders in this feed, add them to the
    // pop-up, and add a checkmark to the names of folders that
    // contain the selected document
    NSEnumerator *folderEnum = [folderEntries objectEnumerator];
    GDataEntryFolderDoc *folderEntry;
    while ((folderEntry = [folderEnum nextObject]) != nil) {

      NSString *title = [[folderEntry title] stringValue];
      NSMenuItem *item = [addMenu addItemWithTitle:title
                                            action:@selector(changeFolderSelected:)
                                     keyEquivalent:@""];
      [item setTarget:self];
      [item setRepresentedObject:folderEntry];

      NSString *folderHref = [[folderEntry selfLink] href];

      BOOL shouldCheckItem = (folderHref != nil)
        && [parentHrefs containsObject:folderHref];
      [item setState:shouldCheckItem];
    }
  }
}

#pragma mark IBActions

- (IBAction)getDocListClicked:(id)sender {
  
  NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];

  NSString *username = [mUsernameField stringValue];
  username = [username stringByTrimmingCharactersInSet:whitespace];

  if ([username rangeOfString:@"@"].location == NSNotFound) {
    // if no domain was supplied, add @gmail.com
    username = [username stringByAppendingString:@"@gmail.com"];
  }
  
  [mUsernameField setStringValue:username];

  [self fetchDocList];
}

- (IBAction)cancelDocListFetchClicked:(id)sender {
  [mDocListFetchTicket cancelTicket];
  [self setDocListFetchTicket:nil];
  [self updateUI];
}

- (IBAction)viewSelectedDocClicked:(id)sender {
  
  NSURL *docURL = [[[self selectedDoc] HTMLLink] URL];
  
  if (docURL) {
    [[NSWorkspace sharedWorkspace] openURL:docURL];
  } else {
    NSBeep(); 
  }
}

- (IBAction)downloadSelectedDocClicked:(id)sender {
  
  GDataEntryDocBase *doc = [self selectedDoc];
  
  NSString *sourceURI = [[doc content] sourceURI];
  if (sourceURI) {
    
    NSString *title = [[doc title] stringValue];
    
    NSString *filename = [NSString stringWithFormat:@"%@.html", title];
    
    SEL endSel = @selector(saveSheetDidEnd:returnCode:contextInfo:);
    
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel beginSheetForDirectory:nil
                                 file:filename
                       modalForWindow:[self window]
                        modalDelegate:self
                       didEndSelector:endSel
                          contextInfo:nil];
  } else {
    NSBeep(); 
  }
}

- (void)saveSheetDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo {
  
  if (returnCode == NSOKButton) {
    // user clicked OK
    
    NSString *sourceURI = [[[self selectedDoc] content] sourceURI];
    NSURL *url = [NSURL URLWithString:sourceURI];
    if (url) {
      
      // read the document's contents synchronously from the network
      //
      // since the user has already signed in, the service object
      // has the proper authentication token.  We'll use the service object
      // to generate an NSURLRequest with the auth token in the header, and
      // then fetch that synchronously.  Without the auth token, the sourceURI
      // would only give us the document if we were already signed into the 
      // user's account with Safari, or if the document was published with
      // public access.

      GDataServiceGoogleDocs *service = [self docsService];
      NSURLRequest *request = [service requestForURL:url
                                                ETag:nil
                                          httpMethod:nil];

      NSURLResponse *response = nil;
      NSError *error = nil;
      NSData *data = [NSURLConnection sendSynchronousRequest:request
                                           returningResponse:&response 
                                                       error:&error];

      if (error != nil) {
        NSLog(@"Error retrieving file: %@", error);
        NSBeep();
        
      } else {
        // save the file to the local path specified by the user
        NSString *savePath = [panel filename];
        
        BOOL didWrite = [data writeToFile:savePath
                                  options:NSAtomicWrite 
                                    error:&error];
        if (!didWrite) {
          NSLog(@"Error saving file: %@", error);
          NSBeep();
        }
      }
    }
  }
}

- (IBAction)uploadFileClicked:(id)sender {

  // ask the user to choose a file
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setPrompt:@"Upload"];

  NSArray *extensions = [NSArray arrayWithObjects:@"csv", @"doc", @"ods", 
    @"odt", @"pps", @"ppt",  @"rtf", @"sxw", @"txt", @"xls",
    @"jpeg", @"jpg", @"bmp", @"gif", @"html", @"htm", @"tsv", 
    @"tab", nil];
  
  SEL endSel = @selector(openSheetDidEnd:returnCode:contextInfo:);
  [openPanel beginSheetForDirectory:nil
                               file:nil
                              types:extensions
                     modalForWindow:[self window]
                      modalDelegate:self
                     didEndSelector:endSel
                      contextInfo:nil];
}

- (void)openSheetDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo {
  
  if (returnCode == NSOKButton) {
    // user chose a file and clicked OK

    // start uploading (deferred to the main thread since we currently have
    // a sheet displayed)
    [self performSelectorOnMainThread:@selector(uploadFileAtPath:)
                           withObject:[panel filename]
                        waitUntilDone:NO];
  }
}

- (IBAction)stopUploadClicked:(id)sender {
  [mUploadTicket cancelTicket];
  [self setUploadTicket:nil];

  [mUploadProgressIndicator setDoubleValue:0.0];
  [self updateUI];
}

- (IBAction)loggingCheckboxClicked:(id)sender {
  [GDataHTTPFetcher setIsLoggingEnabled:[sender state]]; 
}

#pragma mark -

- (IBAction)createFolderClicked:(id)sender {

  GDataServiceGoogleDocs *service = [self docsService];

  GDataEntryFolderDoc *docEntry = [GDataEntryFolderDoc documentEntry];

  NSString *title = [NSString stringWithFormat:@"New Folder %@", [NSDate date]];
  [docEntry setTitleWithString:title];

  NSURL *postURL = [[mDocListFeed postLink] URL];

  [service fetchDocEntryByInsertingEntry:docEntry
                              forFeedURL:postURL
                                delegate:self
                       didFinishSelector:@selector(createFolderTicket:finishedWithEntry:)
                         didFailSelector:@selector(createFolderTicket:failedWithError:)];
}

// folder created successfully
- (void)createFolderTicket:(GDataServiceTicket *)ticket
         finishedWithEntry:(GDataEntryFolderDoc *)entry {

  NSBeginAlertSheet(@"Created folder", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Created folder \"%@\"",
                    [[entry title] stringValue]);

  // re-fetch the document list
  [self fetchDocList];
  [self updateUI];
}

// failure to create folder
- (void)createFolderTicket:(GDataServiceTicket *)ticket
           failedWithError:(NSError *)error {

  NSBeginAlertSheet(@"Create failed", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Folder create failed: %@", error);
}

#pragma mark -

- (IBAction)deleteSelectedDocClicked:(id)sender {

  GDataEntryDocBase *doc = [self selectedDoc];
  if (doc) {
    // make the user confirm that the selected doc should be deleted
    NSBeginAlertSheet(@"Delete Document", @"Delete", @"Cancel", nil,
                      [self window], self,
                      @selector(deleteDocSheetDidEnd:returnCode:contextInfo:),
                      nil, nil, @"Delete the document \"%@\"?",
                      [[doc title] stringValue]);
  }
}

// delete dialog callback
- (void)deleteDocSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {

  if (returnCode == NSAlertDefaultReturn) {

    // delete the document entry
    GDataEntryDocBase *entry = [self selectedDoc];

    if (entry) {
      GDataServiceGoogleDocs *service = [self docsService];
      [service deleteDocEntry:entry
                     delegate:self
            didFinishSelector:@selector(deleteDocEntryTicket:deletedEntry:)
              didFailSelector:@selector(deleteDocEntryTicket:failedWithError:)];
    }
  }
}

// Doc entry deleted successfully
- (void)deleteDocEntryTicket:(GDataServiceTicket *)ticket
                deletedEntry:(GDataEntryDocBase *)object {

  // note: object is nil in the delete callback

  NSBeginAlertSheet(@"Deleted Doc", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Document deleted");

  // re-fetch the document list
  [self fetchDocList];
  [self updateUI];
}

// failure to delete document
- (void)deleteDocEntryTicket:(GDataServiceTicket *)ticket
             failedWithError:(NSError *)error {

  NSBeginAlertSheet(@"Delete failed", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Document delete failed: %@", error);
}

#pragma mark -

- (IBAction)changeFolderSelected:(id)sender {

  // the selected menu item represents a folder; fetch the folder's feed
  //
  // with the folder's feed, we can insert or remove the selected document
  // entry in the folder's feed

  GDataEntryFolderDoc *folderEntry = [sender representedObject];
  NSString *folderFeedURI = [[folderEntry content] sourceURI];
  if (folderFeedURI != nil) {
    NSURL *feedURL = [NSURL URLWithString:folderFeedURI];

    GDataServiceGoogleDocs *service = [self docsService];

    GDataServiceTicket *ticket;
    ticket = [service fetchDocsFeedWithURL:feedURL
                                  delegate:self
                         didFinishSelector:@selector(fetchFolderTicket:finishedWithFeed:)
                           didFailSelector:@selector(fetchFolderTicket:failedWithError:)];

    // save the selected doc in the ticket's userData
    GDataEntryDocBase *doc = [self selectedDoc];
    [ticket setUserData:doc];
  }
}


- (void)fetchFolderTicket:(GDataServiceTicket *)ticket
         finishedWithFeed:(GDataFeedDocList *)feed {

  GDataEntryDocBase *docEntry = [ticket userData];

  GDataServiceGoogleDocs *service = [self docsService];
  GDataServiceTicket *ticket2;

  // if the entry is not in the folder's feed, insert it; otherwise, delete
  // it from the folder's feed
  //
  // We should be able to look up entries by ID
  //  foundEntry = [feed entryForIdentifier:[docEntry identifier]];
  // but currently the DocList server doesn't use consistent IDs for entries in
  // different feeds, so we'll look up the entry by etag instead.  (Bug 1498057)
  
  GDataEntryDocBase *foundEntry;

  foundEntry = [GDataUtilities firstObjectFromArray:[feed entries]
                                          withValue:[docEntry ETag]
                                         forKeyPath:@"ETag"];
  if (foundEntry == nil) {
    // the doc isn't in this folder's feed
    //
    // post the doc to the folder's feed
    NSURL *postURL = [[feed postLink] URL];

    ticket2 = [service fetchDocEntryByInsertingEntry:docEntry
                                          forFeedURL:postURL
                                            delegate:self
                                   didFinishSelector:@selector(addToFolderTicket:finishedWithEntry:)
                                     didFailSelector:@selector(addToFolderTicket:failedWithError:)];
    [ticket2 setUserData:feed];
  } else {
    ticket2 = [service deleteDocEntry:foundEntry
                             delegate:self
                    didFinishSelector:@selector(removeFromFolderTicket:finishedWithEntry:)
                      didFailSelector:@selector(removeFromFolderTicket:failedWithError:)];
    [ticket2 setUserData:feed];
  }
}

// failure to delete document
- (void)fetchFolderTicket:(GDataServiceTicket *)ticket
             failedWithError:(NSError *)error {

  NSBeginAlertSheet(@"Fetch failed", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Fetch of folder feed failed: %@", error);
}

- (void)addToFolderTicket:(GDataServiceTicket *)ticket
        finishedWithEntry:(GDataEntryDocBase *)entry {

  GDataFeedDocList *feed = [ticket userData];

  NSBeginAlertSheet(@"Added", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Added document \"%@\" to feed \"%@\"",
                    [[entry title] stringValue], [[feed title] stringValue]);

  // re-fetch the document list
  [self fetchDocList];
  [self updateUI];
}

// failure to delete document
- (void)addToFolderTicket:(GDataServiceTicket *)ticket
          failedWithError:(NSError *)error {

  NSBeginAlertSheet(@"Fetch failed", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Insert to folder feed failed: %@", error);
}

- (void)removeFromFolderTicket:(GDataServiceTicket *)ticket
             finishedWithEntry:(GDataEntryDocBase *)entry {

  GDataFeedDocList *feed = [ticket userData];

  NSBeginAlertSheet(@"Removed", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Removed document from feed \"%@\"",
                    [[feed title] stringValue]);

  // re-fetch the document list
  [self fetchDocList];
  [self updateUI];
}

// failure to delete document
- (void)removeFromFolderTicket:(GDataServiceTicket *)ticket
               failedWithError:(NSError *)error {

  NSBeginAlertSheet(@"Fetch failed", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Delete from folder feed failed: %@", error);
}

#pragma mark -

// get an docList service object with the current username/password
//
// A "service" object handles networking tasks.  Service objects
// contain user authentication information as well as networking
// state information (such as cookies and the "last modified" date for
// fetched data.)

- (GDataServiceGoogleDocs *)docsService {
  
  static GDataServiceGoogleDocs* service = nil;
  
  if (!service) {
    service = [[GDataServiceGoogleDocs alloc] init];
    
    [service setUserAgent:@"Google-SampleDocsApp-1.0"];
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

// get the doc selected in the list, or nil if none
- (GDataEntryDocBase *)selectedDoc {
  
  NSArray *docs = [mDocListFeed entries];
  int rowIndex = [mDocListTable selectedRow];
  
  if ([docs count] > 0 && rowIndex > -1) {
    
    GDataEntryDocBase *doc = [docs objectAtIndex:rowIndex];
    return doc;
  }
  return nil;
}

#pragma mark Fetch doc list

// begin retrieving the list of the user's docs
- (void)fetchDocList {
  
  [self setDocListFeed:nil];
  [self setDocListFetchError:nil];
  [self setDocListFetchTicket:nil];

  GDataServiceGoogleDocs *service = [self docsService];
  GDataServiceTicket *ticket;

  // Fetching a feed gives us 25 responses by default.  We need to use
  // the feed's "next" link to get any more responses.  If we want more than 25
  // at a time, instead of calling fetchDocsFeedWithURL, we can create a
  // GDataQueryDocs object, as shown here.
  
  NSURL *feedURL = [NSURL URLWithString:kGDataGoogleDocsDefaultPrivateFullFeed];

  GDataQueryDocs *query = [GDataQueryDocs documentQueryWithFeedURL:feedURL];
  [query setMaxResults:1000];
  [query setShouldShowFolders:YES];
    
  ticket = [service fetchDocsQuery:query
                          delegate:self
                 didFinishSelector:@selector(docListListFetchTicket:finishedWithFeed:)
                   didFailSelector:@selector(docListListFetchTicket:failedWithError:)];
  
  [self setDocListFetchTicket:ticket];
  
  [self updateUI];
}

//
// docList list fetch callbacks
//

// finished docList list successfully
- (void)docListListFetchTicket:(GDataServiceTicket *)ticket
              finishedWithFeed:(GDataFeedDocList *)object {
  
  [self setDocListFeed:object];
  [self setDocListFetchError:nil];    
  [self setDocListFetchTicket:nil];
  
  [self updateUI];
} 

// failed
- (void)docListListFetchTicket:(GDataServiceTicket *)ticket
               failedWithError:(NSError *)error {
  
  [self setDocListFeed:nil];
  [self setDocListFetchError:error];    
  [self setDocListFetchTicket:nil];
  
  [self updateUI];
}

#pragma mark Upload

- (void)getMIMEType:(NSString **)mimeType andEntryClass:(Class *)class forExtension:(NSString *)extension {
  
  // Mac OS X's UTI database doesn't know MIME types for .doc and .xls
  // so GDataEntryBase's MIMETypeForFileAtPath method isn't helpful here
  
  struct MapEntry {
    NSString *extension;
    NSString *mimeType;
    NSString *className;
  };
  
  static struct MapEntry sMap[] = {
    { @"csv", @"text/csv", @"GDataEntryStandardDoc" },
    { @"doc", @"application/msword", @"GDataEntryStandardDoc" },
    { @"ods", @"application/vnd.oasis.opendocument.spreadsheet", @"GDataEntrySpreadsheetDoc" },
    { @"odt", @"application/vnd.oasis.opendocument.text", @"GDataEntryStandardDoc" },
    { @"pps", @"application/vnd.ms-powerpoint", @"GDataEntryPresentationDoc" },
    { @"ppt", @"application/vnd.ms-powerpoint", @"GDataEntryPresentationDoc" },
    { @"rtf", @"application/rtf", @"GDataEntryStandardDoc" },
    { @"sxw", @"application/vnd.sun.xml.writer", @"GDataEntryStandardDoc" },
    { @"txt", @"text/plain", @"GDataEntryStandardDoc" },
    { @"xls", @"application/vnd.ms-excel", @"GDataEntrySpreadsheetDoc" },
    { @"jpg", @"image/jpeg", @"GDataEntryStandardDoc" },
    { @"jpeg", @"image/jpeg", @"GDataEntryStandardDoc" },
    { @"png", @"image/png", @"GDataEntryStandardDoc" },
    { @"bmp", @"image/bmp", @"GDataEntryStandardDoc" },
    { @"gif", @"image/gif", @"GDataEntryStandardDoc" },
    { @"html", @"text/html", @"GDataEntryStandardDoc" },
    { @"htm", @"text/html", @"GDataEntryStandardDoc" },
    { @"tsv", @"text/tab-separated-values", @"GDataEntryStandardDoc" },
    { @"tab", @"text/tab-separated-values", @"GDataEntryStandardDoc" },
    
    { nil, nil, nil }
  };
  
  NSString *lowerExtn = [extension lowercaseString];
  
  for (int idx = 0; sMap[idx].extension != nil; idx++) {
    if ([lowerExtn isEqual:sMap[idx].extension]) {
      *mimeType = sMap[idx].mimeType;
      *class = NSClassFromString(sMap[idx].className);
      return;
    }
  }
  
  *mimeType = nil;
  *class = nil;
  return;
}

- (void)uploadFileAtPath:(NSString *)path {
    
  NSString *errorMsg = nil;
    
  // make a new entry for the file
  
  NSString *mimeType = nil;
  Class entryClass = nil;
  
  NSString *extn = [path pathExtension];
  [self getMIMEType:&mimeType andEntryClass:&entryClass forExtension:extn];
  
  if (!mimeType) {
    errorMsg = [NSString stringWithFormat:@"need MIME type for file %@", path];
  }
  if (mimeType && entryClass) {
    
    GDataEntryDocBase *newEntry = [entryClass documentEntry];
    
    NSString *title = [[NSFileManager defaultManager] displayNameAtPath:path];
    [newEntry setTitleWithString:title];
        
    NSData *uploadData = [NSData dataWithContentsOfFile:path];
    if (!uploadData) {
      errorMsg = [NSString stringWithFormat:@"cannot read file %@", path];
    }
    
    if (uploadData) {
      [newEntry setUploadData:uploadData];
      [newEntry setUploadMIMEType:mimeType];
      [newEntry setUploadSlug:[path lastPathComponent]];
  
      NSURL *postURL = [[mDocListFeed postLink] URL];
      
      // make service tickets call back into our upload progress selector
      GDataServiceGoogleDocs *service = [self docsService];
      
      SEL progressSel = @selector(inputStream:hasDeliveredByteCount:ofTotalByteCount:);
      [service setServiceUploadProgressSelector:progressSel];

      // insert the entry into the docList feed
      GDataServiceTicket *ticket;
      ticket = [service fetchDocEntryByInsertingEntry:newEntry
                                           forFeedURL:postURL
                                             delegate:self
                                    didFinishSelector:@selector(uploadFileTicket:finishedWithEntry:)
                                      didFailSelector:@selector(uploadFileTicket:failedWithError:)];
      
      // we don't want future tickets to always use the upload progress selector
      [service setServiceUploadProgressSelector:nil];
      
      [self setUploadTicket:ticket];
    }
  }
  
  if (errorMsg) {
    // we're currently in the middle of the file selection sheet, so defer our
    // error sheet
    NSBeginAlertSheet(@"Upload Error", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, errorMsg);
  }

  [self updateUI];
}
  
// progress callback
- (void)inputStream:(GDataProgressMonitorInputStream *)stream 
   hasDeliveredByteCount:(unsigned long long)numberOfBytesRead 
   ofTotalByteCount:(unsigned long long)dataLength {
  
  [mUploadProgressIndicator setMinValue:0.0];
  [mUploadProgressIndicator setMaxValue:(double)dataLength];
  [mUploadProgressIndicator setDoubleValue:(double)numberOfBytesRead];
}

// upload finished successfully
- (void)uploadFileTicket:(GDataServiceTicket *)ticket
     finishedWithEntry:(GDataEntryDocBase *)entry {
  
  [self setUploadTicket:nil];
  [mUploadProgressIndicator setDoubleValue:0.0];

  // refetch the current doc list
  [self fetchDocList];
  [self updateUI];

  // tell the user that the add worked
  NSBeginAlertSheet(@"Uploaded file", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"File uploaded: %@", 
                    [[entry title] stringValue]);
  
} 

// upload failed
- (void)uploadFileTicket:(GDataServiceTicket *)ticket
       failedWithError:(NSError *)error {
  
  [self setUploadTicket:nil];
  [mUploadProgressIndicator setDoubleValue:0.0];
  
  [self updateUI];

  NSBeginAlertSheet(@"Upload failed", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"File upload failed: %@", error);
}


#pragma mark TableView delegate methods

//
// table view delegate methods
//

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  // the user clicked on an entry; 
  // just display it below the entry table
  
  [self updateUI]; 
}

// table view data source methods
- (int)numberOfRowsInTableView:(NSTableView *)tableView {
  if (tableView == mDocListTable) {
    return [[mDocListFeed entries] count];
  } 
  return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
  
  if (tableView == mDocListTable) {
    // get the docList entry's title, and the kind of document
    GDataEntryDocBase *doc = [[mDocListFeed entries] objectAtIndex:row];
    
    NSString *docKind = @"unknown";
        
    // the kind category for a doc entry includes a label like "document"
    // or "spreadsheet"
    NSArray *categories;
    categories = [GDataCategory categoriesWithScheme:kGDataCategoryScheme
                                      fromCategories:[doc categories]];
    if ([categories count] >= 1) {
      docKind = [[categories objectAtIndex:0] label];
    }
   
    // mark if the document is starred
    if ([doc isStarred]) {
      const UniChar kStarChar = 0x2605;
      docKind = [NSString stringWithFormat:@"%C, %@", kStarChar, docKind];
    }
    
    NSString *displayStr = [NSString stringWithFormat:@"%@ (%@)",
      [[doc title] stringValue], docKind];
    return displayStr;
  } 
  return nil;
}

#pragma mark Setters and Getters

- (GDataFeedDocList *)docListFeed {
  return mDocListFeed; 
}

- (void)setDocListFeed:(GDataFeedDocList *)feed {
  [mDocListFeed autorelease];
  mDocListFeed = [feed retain];
}

- (NSError *)docListFetchError {
  return mDocListFetchError; 
}

- (void)setDocListFetchError:(NSError *)error {
  [mDocListFetchError release];
  mDocListFetchError = [error retain];
}

- (GDataServiceTicket *)docListFetchTicket {
  return mDocListFetchTicket; 
}

- (void)setDocListFetchTicket:(GDataServiceTicket *)ticket {
  [mDocListFetchTicket release];
  mDocListFetchTicket = [ticket retain];
}

- (GDataServiceTicket *)uploadTicket {
  return mUploadTicket;
}

- (void)setUploadTicket:(GDataServiceTicket *)ticket {
  [mUploadTicket release];
  mUploadTicket = [ticket retain];
}

@end
