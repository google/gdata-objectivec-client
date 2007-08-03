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

// Note: Though this sample doesn't demonstrate it, GData responses are
//       typically chunked, so check all returned feeds for "next" links
//       (use -nextLink method from the GDataLinkArray category on the
//       links array of GData objects.)

#import "DocsSampleWindowController.h"
#import "GData/GDataServiceGoogleDocs.h"
#import "GData/GDataQueryDocs.h"
#import "GData/GDataEntryDocBase.h"
#import "GData/GDataEntrySpreadsheetDoc.h"
#import "GData/GDataEntryPresentationDoc.h"
#import "GData/GDataEntryStandardDoc.h"

@interface DocsSampleWindowController (PrivateMethods)
- (void)updateUI;

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
    GDataEntryDocBase *doc = [self selectedDoc];
    if (doc) {
      docResultStr = [doc description];
    }
  }
  [mDocListResultTextField setString:docResultStr];
  
  // enable the button for viewing the selected doc in a browser
  BOOL doesDocHaveHTMLLink = ([[[self selectedDoc] links] HTMLLink] != nil);
  [mViewSelectedDocButton setEnabled:doesDocHaveHTMLLink];
  
  // enable uploading buttons 
  BOOL isUploading = (mUploadTicket != nil);
  BOOL hasFeed = (mDocListFeed != nil);

  [mUploadFileButton setEnabled:(hasFeed && !isUploading)];
  [mStopUploadButton setEnabled:isUploading];

  // show the title of the file currently uploading
  NSString *uploadingStr = @"";
  NSString *uploadingTitle = [[(GDataEntryBase *) 
    [mDocListFetchTicket postedObject] title] stringValue];
  
  if (uploadingTitle) {
    uploadingStr = [NSString stringWithFormat:@"Uploading: %@", uploadingTitle];
  }
  [mUploadingTextField setStringValue:uploadingStr];
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
  
  NSURL *docURL = [[[[self selectedDoc] links] HTMLLink] URL];
  
  if (docURL) {
    [[NSWorkspace sharedWorkspace] openURL:docURL];
  } else {
    NSBeep(); 
  }
}

- (IBAction)uploadFileClicked:(id)sender {

  // ask the user to choose a file
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setPrompt:@"Upload"];

  NSArray *extensions = [NSArray arrayWithObjects:@"csv", @"doc", @"ods", 
    @"odt", @"pps", @"ppt",  @"rtf", @"sxw", @"txt", @"xls", nil];
  
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
    
    [service setUserAgent:@"SampleDocsApp"];
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
    { @"csv", @"text/comma-separated-values", @"GDataEntryStandardDoc" },
    { @"doc", @"application/msword", @"GDataEntryStandardDoc" },
    { @"ods", @"application/vnd.oasis.opendocument.spreadsheet", @"GDataEntrySpreadsheetDoc" },
    { @"odt", @"application/vnd.oasis.opendocument.text", @"GDataEntryStandardDoc" },
    { @"pps", @"application/vnd.ms-powerpoint", @"GDataEntryPresentationDoc" },
    { @"ppt", @"application/vnd.ms-powerpoint", @"GDataEntryPresentationDoc" },
    { @"rtf", @"application/rtf", @"GDataEntryStandardDoc" },
    { @"sxw", @"application/vnd.sun.xml.writer", @"GDataEntryStandardDoc" },
    { @"txt", @"text/plain", @"GDataEntryStandardDoc" },
    { @"xls", @"application/vnd.ms-excel", @"GDataEntrySpreadsheetDoc" },
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
    
    GDataEntryDocBase *newEntry = [[[entryClass alloc] init] autorelease];
    
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
  
      NSURL *postURL = [[[mDocListFeed links] postLink] URL];
      
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
    categories = [[doc categories] categoriesWithScheme:kGDataCategoryScheme];
    if ([categories count] >= 1) {
      docKind = [[categories objectAtIndex:0] label];
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
