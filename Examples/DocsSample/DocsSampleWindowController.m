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

enum {
  // upload pop-up menu items
  kUploadAsGoogleDoc = 0,
  kUploadOriginal = 1,
  kUploadOCR = 2,
  kUploadDE = 3,
  kUploadJA = 4,
  kUploadEN = 5
};

@interface DocsSampleWindowController (PrivateMethods)
- (void)updateUI;
- (void)updateChangeFolderPopup;

- (void)fetchDocList;
- (void)fetchRevisionsForSelectedDoc;

- (void)uploadFileAtPath:(NSString *)path;
- (void)showDownloadPanelForEntry:(GDataEntryBase *)entry suggestedTitle:(NSString *)title;
- (void)saveDocumentEntry:(GDataEntryBase *)docEntry toPath:(NSString *)path;
- (void)saveDocEntry:(GDataEntryBase *)entry toPath:(NSString *)savePath exportFormat:(NSString *)exportFormat authService:(GDataServiceGoogle *)service;
- (void)saveSpreadsheet:(GDataEntrySpreadsheetDoc *)docEntry toPath:(NSString *)savePath;

- (GDataServiceGoogleDocs *)docsService;
- (GDataEntryDocBase *)selectedDoc;
- (GDataEntryDocRevision *)selectedRevision;

- (GDataFeedDocList *)docListFeed;
- (void)setDocListFeed:(GDataFeedDocList *)feed;
- (NSError *)docListFetchError;
- (void)setDocListFetchError:(NSError *)error;
- (GDataServiceTicket *)docListFetchTicket;
- (void)setDocListFetchTicket:(GDataServiceTicket *)ticket;

- (GDataFeedDocRevision *)revisionFeed;
- (void)setRevisionFeed:(GDataFeedDocRevision *)feed;
- (NSError *)revisionFetchError;
- (void)setRevisionFetchError:(NSError *)error;
- (GDataServiceTicket *)revisionFetchTicket;
- (void)setRevisionFetchTicket:(GDataServiceTicket *)ticket;

- (GDataEntryDocListMetadata *)metadataEntry;
- (void)setMetadataEntry:(GDataEntryDocListMetadata *)entry;

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
  [mDocListFetchTicket release];
  [mDocListFetchError release];

  [mRevisionFeed release];
  [mRevisionFetchTicket release];
  [mRevisionFetchError release];

  [mMetadataEntry release];

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

  // show the doclist feed fetch result error or the selected entry
  NSString *docResultStr = @"";
  if (mDocListFetchError) {
    docResultStr = [mDocListFetchError description];
  } else {
    if (selectedDoc) {
      docResultStr = [selectedDoc description];
    }
  }
  [mDocListResultTextField setString:docResultStr];


  // revision list display
  [mRevisionsTable reloadData];

  GDataEntryDocRevision *selectedRevision = [self selectedRevision];

  // spin indicator when retrieving feed
  BOOL isFetchingRevisions = (mRevisionFetchTicket != nil);
  if (isFetchingRevisions) {
    [mRevisionsProgressIndicator startAnimation:self];
  } else {
    [mRevisionsProgressIndicator stopAnimation:self];
  }
  [mRevisionsCancelButton setEnabled:isFetchingRevisions];

  // show the revision feed fetch result error or the selected entry
  NSString *revisionsResultStr = @"";
  if (mRevisionFetchError) {
    revisionsResultStr = [mRevisionFetchError description];
  } else {
    if (selectedRevision) {
      revisionsResultStr = [selectedRevision description];
    }
  }
  [mRevisionsResultTextField setString:revisionsResultStr];

  BOOL isSelectedDocAStandardGDocsType =
    [selectedDoc isKindOfClass:[GDataEntryStandardDoc class]]
    || [selectedDoc isKindOfClass:[GDataEntrySpreadsheetDoc class]]
    || [selectedDoc isKindOfClass:[GDataEntryPresentationDoc class]];

  // enable the button for viewing the selected doc in a browser
  BOOL doesDocHaveHTMLLink = ([selectedDoc HTMLLink] != nil);
  [mViewSelectedDocButton setEnabled:doesDocHaveHTMLLink];

  BOOL doesRevisionHaveExportURL = ([[[selectedRevision content] sourceURI] length] > 0);
  [mDownloadSelectedRevisionButton setEnabled:doesRevisionHaveExportURL];

  BOOL doesDocHaveExportURL = ([[[selectedDoc content] sourceURI] length] > 0);
  [mDownloadSelectedDocButton setEnabled:doesDocHaveExportURL];

  BOOL doesDocHaveEditLink = ([selectedDoc editLink] != nil);
  [mDeleteSelectedDocButton setEnabled:doesDocHaveEditLink];

  [mDuplicateSelectedDocButton setEnabled:isSelectedDocAStandardGDocsType];

  // enable the publishing checkboxes when a publishable revision is selected
  BOOL isRevisionSelected = (selectedRevision != nil);
  BOOL isRevisionPublishable = isRevisionSelected
    && isSelectedDocAStandardGDocsType;

  [mPublishCheckbox setEnabled:isRevisionPublishable];
  [mAutoRepublishCheckbox setEnabled:isRevisionPublishable];
  [mPublishOutsideDomainCheckbox setEnabled:isRevisionPublishable];

  // enable the "Update Publishing" button when the selected revision is
  // publishable and the checkbox settings differ from the current publishing
  // setting for the selected revision
  BOOL isPublished = [[selectedRevision publish] boolValue];
  BOOL isPublishedChecked = ([mPublishCheckbox state] == NSOnState);

  BOOL isAutoRepublished = [[selectedRevision publishAuto] boolValue];
  BOOL isAutoRepublishedChecked = ([mAutoRepublishCheckbox state] == NSOnState);

  BOOL isExternalPublished = [[selectedRevision publishOutsideDomain] boolValue];
  BOOL isExternalPublishedChecked = ([mPublishOutsideDomainCheckbox state] == NSOnState);

  BOOL canUpdatePublishing = isRevisionPublishable
    && ((isPublished != isPublishedChecked)
        || (isAutoRepublished != isAutoRepublishedChecked)
        || (isExternalPublished != isExternalPublishedChecked));

  [mUpdatePublishingButton setEnabled:canUpdatePublishing];

  // enable uploading buttons
  BOOL isUploading = (mUploadTicket != nil);
  BOOL canPostToFeed = ([mDocListFeed postLink] != nil);

  [mUploadFileButton setEnabled:(canPostToFeed && !isUploading)];
  [mStopUploadButton setEnabled:isUploading];
  [mPauseUploadButton setEnabled:isUploading];
  [mCreateFolderButton setEnabled:canPostToFeed];

  BOOL isUploadPaused = [mUploadTicket isUploadPaused];
  NSString *pauseTitle = (isUploadPaused ? @"Resume" : @"Pause");
  [mPauseUploadButton setTitle:pauseTitle];

  // enable the "Upload Original Document" menu item only if the user metadata
  // indicates support for generic file uploads
  GDataDocFeature *feature = [mMetadataEntry featureForName:kGDataDocsFeatureNameUploadAny];
  BOOL canUploadGenericDocs = (feature != nil);

  NSMenuItem *genericMenuItem = [[mUploadPopup menu] itemWithTag:kUploadOriginal];
  [genericMenuItem setEnabled:canUploadGenericDocs];

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

- (IBAction)cancelRevisionsFetchClicked:(id)sender {
  [mRevisionFetchTicket cancelTicket];
  [self setRevisionFetchTicket:nil];
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

#pragma mark -

- (IBAction)downloadSelectedDocClicked:(id)sender {

  GDataEntryDocBase *docEntry = [self selectedDoc];

  NSString *saveTitle = [[[self selectedDoc] title] stringValue];

  [self showDownloadPanelForEntry:docEntry
                   suggestedTitle:saveTitle];
}

- (IBAction)downloadSelectedRevisionClicked:(id)sender {

  GDataEntryDocRevision *revisionEntry = [self selectedRevision];

  GDataEntryDocBase *docEntry = [self selectedDoc];

  NSString *docName = [[docEntry title] stringValue];
  NSString *revisionName = [[revisionEntry title] stringValue];
  NSString *saveTitle = [NSString stringWithFormat:@"%@ (%@)",
                         docName, revisionName];

  // we need to record if the document being saved is really a spreadsheet, and
  // the revision entry doesn't tell us, so we look at the selected doc entry
  BOOL isSpreadsheet = [docEntry isKindOfClass:[GDataEntrySpreadsheetDoc class]];
  [revisionEntry setProperty:[NSNumber numberWithBool:isSpreadsheet]
                      forKey:@"is spreadsheet"];

  [self showDownloadPanelForEntry:revisionEntry
                   suggestedTitle:saveTitle];
}

- (void)showDownloadPanelForEntry:(GDataEntryBase *)entry
                   suggestedTitle:(NSString *)title {

  NSString *sourceURI = [[entry content] sourceURI];
  if (sourceURI) {

    NSString *filename = [NSString stringWithFormat:@"%@.txt", title];

    SEL endSel = @selector(saveSheetDidEnd:returnCode:contextInfo:);

    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel beginSheetForDirectory:nil
                                 file:filename
                       modalForWindow:[self window]
                        modalDelegate:self
                       didEndSelector:endSel
                          contextInfo:[entry retain]];
  } else {
    NSBeep();
  }
}

- (void)saveSheetDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo {

  GDataEntryBase *entry = [(GDataEntryBase *)contextInfo autorelease];

  if (returnCode == NSOKButton) {
    // user clicked OK
    NSString *savePath = [panel filename];
    [self saveDocumentEntry:entry
                     toPath:savePath];
  }
}

// formerly saveSelectedDocumentToPath:
- (void)saveDocumentEntry:(GDataEntryBase *)docEntry
                   toPath:(NSString *)savePath {
  // downloading docs, per
  // http://code.google.com/apis/documents/docs/3.0/developers_guide_protocol.html#DownloadingDocs

  BOOL isSpreadsheet = [docEntry isKindOfClass:[GDataEntrySpreadsheetDoc class]];
  if (!isSpreadsheet) {
    // in a revision entry, we've add a property above indicating if this is a
    // spreadsheet revision
    isSpreadsheet = [[docEntry propertyForKey:@"is spreadsheet"] boolValue];
  }

  if (isSpreadsheet) {
    // to save a spreadsheet, we need to authenticate a spreadsheet service
    // object, and then download the spreadsheet file
    [self saveSpreadsheet:(GDataEntrySpreadsheetDoc *)docEntry
                   toPath:savePath];
  } else {
    // since the user has already fetched the doc list, the service object
    // has the proper authentication token.  We'll use the service object
    // to generate an NSURLRequest with the auth token in the header, and
    // then fetch that asynchronously.
    GDataServiceGoogleDocs *docsService = [self docsService];
    [self saveDocEntry:docEntry
                toPath:savePath
          exportFormat:@"txt"
           authService:docsService];
  }
}

- (void)saveDocEntry:(GDataEntryBase *)entry
              toPath:(NSString *)savePath
        exportFormat:(NSString *)exportFormat
         authService:(GDataServiceGoogle *)service {

  // the content src attribute is used for downloading
  NSURL *exportURL = [[entry content] sourceURL];
  if (exportURL != nil) {

    // we'll use GDataQuery as a convenient way to append the exportFormat
    // parameter of the docs export API to the content src URL
    GDataQuery *query = [GDataQuery queryWithFeedURL:exportURL];
    [query addCustomParameterWithName:@"exportFormat"
                                value:exportFormat];
    NSURL *downloadURL = [query URL];

    // create a file for saving the document
    NSError *error = nil;
    if ([[NSData data] writeToFile:savePath
                           options:NSAtomicWrite
                             error:&error]) {
      NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:savePath];

      // read the document's contents asynchronously from the network
      NSURLRequest *request = [service requestForURL:downloadURL
                                                ETag:nil
                                          httpMethod:nil];

      GDataHTTPFetcher *fetcher = [GDataHTTPFetcher httpFetcherWithRequest:request];
      [fetcher setDownloadFileHandle:fileHandle];
      [fetcher beginFetchWithDelegate:self
                    didFinishSelector:@selector(fetcher:finishedWithData:)
                      didFailSelector:@selector(fetcher:failedWithError:)];
    } else {
      NSLog(@"Error creating file at %@: %@", savePath, error);
    }
  }
}

- (void)fetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data {
  // successfully saved the document
}

- (void)fetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error {
  NSLog(@"Fetcher error: %@", error);
  NSBeep();
}

- (void)saveSpreadsheet:(GDataEntrySpreadsheetDoc *)docEntry
                 toPath:(NSString *)savePath {
  // to download a spreadsheet document, we need a spreadsheet service object,
  // and we first need to fetch a feed or entry with the service object so that
  // it has a valid auth token
  GDataServiceGoogleSpreadsheet *spreadsheetService;
  spreadsheetService = [[[GDataServiceGoogleSpreadsheet alloc] init] autorelease];

  GDataServiceGoogleDocs *docsService = [self docsService];
  [spreadsheetService setUserAgent:[docsService userAgent]];
  [spreadsheetService setUserCredentialsWithUsername:[docsService username]
                                            password:[docsService password]];
  GDataServiceTicket *ticket;
  ticket = [spreadsheetService authenticateWithDelegate:self
                                didAuthenticateSelector:@selector(spreadsheetTicket:authenticatedWithError:)];

  // we'll hang on to the spreadsheet service object with a ticket property
  // since we need it to create an authorized NSURLRequest
  [ticket setProperty:docEntry forKey:@"docEntry"];
  [ticket setProperty:savePath forKey:@"savePath"];
}

- (void)spreadsheetTicket:(GDataServiceTicket *)ticket
   authenticatedWithError:(NSError *)error {
  if (error == nil) {
    GDataEntrySpreadsheetDoc *docEntry = [ticket propertyForKey:@"docEntry"];
    NSString *savePath = [ticket propertyForKey:@"savePath"];

    [self saveDocEntry:docEntry
                toPath:savePath
          exportFormat:@"tsv"
           authService:[ticket service]];
  } else {
    // failed to authenticate; give up
    NSLog(@"Spreadsheet authentication error: %@", error);
    return;
  }
}

#pragma mark -

- (IBAction)uploadFileClicked:(id)sender {

  // ask the user to choose a file
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setPrompt:@"Upload"];

  SEL endSel = @selector(openSheetDidEnd:returnCode:contextInfo:);
  [openPanel beginSheetForDirectory:nil
                               file:nil
                              types:nil // upload any file type
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

- (IBAction)publishCheckboxClicked:(id)sender {
  // enable or disable the Update Publishing button
  [self updateUI];
}

- (IBAction)updatePublishingClicked:(id)sender {
  GDataServiceGoogleDocs *service = [self docsService];

  GDataEntryDocRevision *revisionEntry = [self selectedRevision];

  // update the revision elements to match the checkboxes
  //
  // we'll modify a copy of the selected entry so we don't leave an inaccurate
  // entry in the feed if our fetch fails
  GDataEntryDocRevision *revisionCopy = [[revisionEntry copy] autorelease];

  BOOL shouldPublish = ([mPublishCheckbox state] == NSOnState);
  [revisionCopy setPublish:[NSNumber numberWithBool:shouldPublish]];

  BOOL shouldAutoRepublish = ([mAutoRepublishCheckbox state] == NSOnState);
  [revisionCopy setPublishAuto:[NSNumber numberWithBool:shouldAutoRepublish]];

  BOOL shouldPublishExternally = ([mPublishOutsideDomainCheckbox state] == NSOnState);
  [revisionCopy setPublishOutsideDomain:[NSNumber numberWithBool:shouldPublishExternally]];

  [service fetchEntryByUpdatingEntry:revisionCopy
                            delegate:self
                   didFinishSelector:@selector(publishRevisionTicket:finishedWithEntry:error:)];
}

- (void)publishRevisionTicket:(GDataServiceTicket *)ticket
            finishedWithEntry:(GDataEntryDocRevision *)entry
                        error:(NSError *)error {
  if (error == nil) {
    NSBeginAlertSheet(@"Updated", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Updated publish status for \"%@\"",
                      [[entry title] stringValue]);

    // re-fetch the document list
    [self fetchRevisionsForSelectedDoc];
  } else {
    NSBeginAlertSheet(@"Updated failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Failed to update publish status: %@", error);
  }
}

#pragma mark -

- (IBAction)createFolderClicked:(id)sender {

  GDataServiceGoogleDocs *service = [self docsService];

  GDataEntryFolderDoc *docEntry = [GDataEntryFolderDoc documentEntry];

  NSString *title = [NSString stringWithFormat:@"New Folder %@", [NSDate date]];
  [docEntry setTitleWithString:title];

  NSURL *postURL = [[mDocListFeed postLink] URL];

  [service fetchEntryByInsertingEntry:docEntry
                           forFeedURL:postURL
                             delegate:self
                    didFinishSelector:@selector(createFolderTicket:finishedWithEntry:error:)];
}

// folder create callback
- (void)createFolderTicket:(GDataServiceTicket *)ticket
         finishedWithEntry:(GDataEntryFolderDoc *)entry
                     error:(NSError *)error {
  if (error == nil) {
    NSBeginAlertSheet(@"Created folder", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Created folder \"%@\"",
                      [[entry title] stringValue]);

    // re-fetch the document list
    [self fetchDocList];
    [self updateUI];
  } else {
    NSBeginAlertSheet(@"Create failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Folder create failed: %@", error);
  }
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
      [service deleteEntry:entry
                  delegate:self
         didFinishSelector:@selector(deleteDocEntryTicket:deletedEntry:error:)];
    }
  }
}

// entry delete callback
- (void)deleteDocEntryTicket:(GDataServiceTicket *)ticket
                deletedEntry:(GDataEntryDocBase *)object
                       error:(NSError *)error {
  if (error == nil) {
    // note: object is nil in the delete callback
    NSBeginAlertSheet(@"Deleted Doc", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Document deleted");

    // re-fetch the document list
    [self fetchDocList];
    [self updateUI];
  } else {
    NSBeginAlertSheet(@"Delete failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Document delete failed: %@", error);
  }
}

#pragma mark -

- (IBAction)duplicateSelectedDocClicked:(id)sender {

  GDataEntryDocBase *selectedDoc = [self selectedDoc];
  if (selectedDoc) {
    // make a new entry of the same class as the selected document entry,
    // with just the title set and an identifier equal to the selected
    // doc's resource ID
    GDataEntryDocBase *newEntry = [[selectedDoc class] documentEntry];

    [newEntry setIdentifier:[selectedDoc resourceID]];

    NSString *oldTitle = [[selectedDoc title] stringValue];
    NSString *newTitle = [oldTitle stringByAppendingString:@" copy"];
    [newEntry setTitleWithString:newTitle];

    GDataServiceGoogleDocs *service = [self docsService];
    NSURL *postURL = [[mDocListFeed postLink] URL];

    [service fetchEntryByInsertingEntry:newEntry
                             forFeedURL:postURL
                               delegate:self
                      didFinishSelector:@selector(duplicateDocEntryTicket:finishedWithEntry:error:)];
  }
}

// document copying callback
- (void)duplicateDocEntryTicket:(GDataServiceTicket *)ticket
              finishedWithEntry:(GDataEntryDocBase *)newEntry
                       error:(NSError *)error {
  if (error == nil) {
    NSBeginAlertSheet(@"Copied Doc", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Document duplicate \"%@\" created",
                      [[newEntry title] stringValue]);

    // re-fetch the document list
    [self fetchDocList];
    [self updateUI];
  } else {
    NSBeginAlertSheet(@"Copy failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Document duplicate failed: %@", error);
  }
}

#pragma mark -

- (IBAction)changeFolderSelected:(id)sender {

  // the selected menu item represents a folder; fetch the folder's feed
  //
  // with the folder's feed, we can insert or remove the selected document
  // entry in the folder's feed

  GDataEntryFolderDoc *folderEntry = [sender representedObject];
  NSURL *folderFeedURL = [[folderEntry content] sourceURL];
  if (folderFeedURL != nil) {

    GDataServiceGoogleDocs *service = [self docsService];

    GDataServiceTicket *ticket;
    ticket = [service fetchFeedWithURL:folderFeedURL
                              delegate:self
                     didFinishSelector:@selector(fetchFolderTicket:finishedWithFeed:error:)];

    // save the selected doc in the ticket's userData
    GDataEntryDocBase *doc = [self selectedDoc];
    [ticket setUserData:doc];
  }
}

// folder feed fetch callback
- (void)fetchFolderTicket:(GDataServiceTicket *)ticket
         finishedWithFeed:(GDataFeedDocList *)feed
                    error:(NSError *)error {

  if (error == nil) {
    GDataEntryDocBase *docEntry = [ticket userData];

    GDataServiceGoogleDocs *service = [self docsService];
    GDataServiceTicket *ticket2;

    // if the entry is not in the folder's feed, insert it; otherwise, delete
    // it from the folder's feed
    GDataEntryDocBase *foundEntry = [feed entryForIdentifier:[docEntry identifier]];
    if (foundEntry == nil) {
      // the doc isn't currently in this folder's feed
      //
      // post the doc to the folder's feed
      NSURL *postURL = [[feed postLink] URL];

      ticket2 = [service fetchEntryByInsertingEntry:docEntry
                                         forFeedURL:postURL
                                           delegate:self
                                  didFinishSelector:@selector(addToFolderTicket:finishedWithEntry:error:)];
      [ticket2 setUserData:feed];
    } else {
      // the doc is alrady in the folder's feed, so remove it
      ticket2 = [service deleteEntry:foundEntry
                            delegate:self
                   didFinishSelector:@selector(removeFromFolderTicket:finishedWithEntry:error:)];
      [ticket2 setUserData:feed];
    }
  } else {
    // failed to fetch feed of folders
    NSBeginAlertSheet(@"Fetch failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Fetch of folder feed failed: %@", error);

  }
}

// add to folder callback
- (void)addToFolderTicket:(GDataServiceTicket *)ticket
        finishedWithEntry:(GDataEntryDocBase *)entry
                    error:(NSError *)error {
  if (error == nil) {
    GDataFeedDocList *feed = [ticket userData];

    NSBeginAlertSheet(@"Added", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Added document \"%@\" to feed \"%@\"",
                      [[entry title] stringValue], [[feed title] stringValue]);

    // re-fetch the document list
    [self fetchDocList];
    [self updateUI];
  } else {
    NSBeginAlertSheet(@"Insert failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Insert to folder feed failed: %@", error);
  }
}

// remove from folder callback
- (void)removeFromFolderTicket:(GDataServiceTicket *)ticket
             finishedWithEntry:(GDataEntryDocBase *)entry
                         error:(NSError *)error {
  if (error == nil) {
    GDataFeedDocList *feed = [ticket userData];

    NSBeginAlertSheet(@"Removed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Removed document from feed \"%@\"",
                      [[feed title] stringValue]);

    // re-fetch the document list
    [self fetchDocList];
    [self updateUI];
  } else {
    NSBeginAlertSheet(@"Fetch failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Remove from folder feed failed: %@", error);
  }
}

#pragma mark -

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

    [service setShouldCacheDatedData:YES];
    [service setServiceShouldFollowNextLinks:YES];
    [service setIsServiceRetryEnabled:YES];
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

  int rowIndex = [mDocListTable selectedRow];
  if (rowIndex > -1) {
    GDataEntryDocBase *doc = [mDocListFeed entryAtIndex:rowIndex];
    return doc;
  }
  return nil;
}

// get the doc revision in the list, or nil if none
- (GDataEntryDocRevision *)selectedRevision {

  int rowIndex = [mRevisionsTable selectedRow];
  if (rowIndex > -1) {
    GDataEntryDocRevision *entry = [mRevisionFeed entryAtIndex:rowIndex];
    return entry;
  }
  return nil;
}

#pragma mark Fetch doc list user metadata

- (void)fetchMetadataEntry {
  [self setMetadataEntry:nil];

  NSURL *entryURL = [GDataServiceGoogleDocs metadataEntryURLForUserID:kGDataServiceDefaultUser];
  GDataServiceGoogleDocs *service = [self docsService];
  [service fetchEntryWithURL:entryURL
                    delegate:self
           didFinishSelector:@selector(metadataTicket:finishedWithEntry:error:)];
}

- (void)metadataTicket:(GDataServiceTicket *)ticket
     finishedWithEntry:(GDataEntryDocListMetadata *)entry
                 error:(NSError *)error {
  [self setMetadataEntry:entry];

  // enable or disable features
  [self updateUI];

  if (error != nil) {
    NSLog(@"Error fetching user metadata: %@", error);
  }
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

  NSURL *feedURL = [GDataServiceGoogleDocs docsFeedURL];

  GDataQueryDocs *query = [GDataQueryDocs documentQueryWithFeedURL:feedURL];
  [query setMaxResults:1000];
  [query setShouldShowFolders:YES];

  ticket = [service fetchFeedWithQuery:query
                              delegate:self
                     didFinishSelector:@selector(docListFetchTicket:finishedWithFeed:error:)];

  [self setDocListFetchTicket:ticket];

  // update our metadata entry for this user
  [self fetchMetadataEntry];

  [self updateUI];
}

// docList list fetch callback
- (void)docListFetchTicket:(GDataServiceTicket *)ticket
          finishedWithFeed:(GDataFeedDocList *)feed
                     error:(NSError *)error {

  [self setDocListFeed:feed];
  [self setDocListFetchError:error];
  [self setDocListFetchTicket:nil];

  [self updateUI];
}

#pragma mark Fetch revisions or content feed

- (void)fetchRevisionsForSelectedDoc {

  [self setRevisionFeed:nil];
  [self setRevisionFetchError:nil];
  [self setRevisionFetchTicket:nil];

  GDataEntryDocBase *selectedDoc = [self selectedDoc];
  GDataFeedLink *revisionFeedLink = [selectedDoc revisionFeedLink];
  NSURL *revisionFeedURL = [revisionFeedLink URL];
  if (revisionFeedURL) {

    GDataServiceGoogleDocs *service = [self docsService];
    GDataServiceTicket *ticket;
    ticket = [service fetchFeedWithURL:revisionFeedURL
                              delegate:self
                     didFinishSelector:@selector(revisionFetchTicket:finishedWithFeed:error:)];

    [self setRevisionFetchTicket:ticket];

  }

  [self updateUI];
}

// revisions list fetch callback
- (void)revisionFetchTicket:(GDataServiceTicket *)ticket
           finishedWithFeed:(GDataFeedDocRevision *)feed
                      error:(NSError *)error {

  [self setRevisionFeed:feed];
  [self setRevisionFetchError:error];
  [self setRevisionFetchTicket:nil];

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
    { @"docx", @"application/vnd.openxmlformats-officedocument.wordprocessingml.document", @"GDataEntryStandardDoc" },
    { @"ods", @"application/vnd.oasis.opendocument.spreadsheet", @"GDataEntrySpreadsheetDoc" },
    { @"odt", @"application/vnd.oasis.opendocument.text", @"GDataEntryStandardDoc" },
    { @"pps", @"application/vnd.ms-powerpoint", @"GDataEntryPresentationDoc" },
    { @"ppt", @"application/vnd.ms-powerpoint", @"GDataEntryPresentationDoc" },
    { @"rtf", @"application/rtf", @"GDataEntryStandardDoc" },
    { @"sxw", @"application/vnd.sun.xml.writer", @"GDataEntryStandardDoc" },
    { @"txt", @"text/plain", @"GDataEntryStandardDoc" },
    { @"xls", @"application/vnd.ms-excel", @"GDataEntrySpreadsheetDoc" },
    { @"xlsx", @"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", @"GDataEntrySpreadsheetDoc" },
    { @"jpg", @"image/jpeg", @"GDataEntryStandardDoc" },
    { @"jpeg", @"image/jpeg", @"GDataEntryStandardDoc" },
    { @"png", @"image/png", @"GDataEntryStandardDoc" },
    { @"bmp", @"image/bmp", @"GDataEntryStandardDoc" },
    { @"gif", @"image/gif", @"GDataEntryStandardDoc" },
    { @"html", @"text/html", @"GDataEntryStandardDoc" },
    { @"htm", @"text/html", @"GDataEntryStandardDoc" },
    { @"tsv", @"text/tab-separated-values", @"GDataEntryStandardDoc" },
    { @"tab", @"text/tab-separated-values", @"GDataEntryStandardDoc" },
    { @"pdf", @"application/pdf", @"GDataEntryPDFDoc" },
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
    // for other file types, see if we can get the type from the Mac OS
    // and use a generic file document entry class
    mimeType = [GDataUtilities MIMETypeForFileAtPath:path
                                     defaultMIMEType:nil];
    entryClass = [GDataEntryFileDoc class];
  }

  if (!mimeType) {
    errorMsg = [NSString stringWithFormat:@"need MIME type for file %@", path];
  }

  if (mimeType && entryClass) {

    GDataEntryDocBase *newEntry = [entryClass documentEntry];

    NSString *title = [[NSFileManager defaultManager] displayNameAtPath:path];
    [newEntry setTitleWithString:title];

    NSFileHandle *uploadFileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    if (!uploadFileHandle) {
      errorMsg = [NSString stringWithFormat:@"cannot read file %@", path];
    }

    if (uploadFileHandle) {
      [newEntry setUploadFileHandle:uploadFileHandle];

      [newEntry setUploadMIMEType:mimeType];
      [newEntry setUploadSlug:[path lastPathComponent]];

      NSURL *uploadURL = [GDataServiceGoogleDocs docsUploadURL];

      // add the OCR or translation parameters, if the user set the pop-up
      // button appropriately
      int popupTag = [[mUploadPopup selectedItem] tag];
      if (popupTag != 0) {
        NSString *targetLanguage = nil;
        BOOL shouldConvertToGoogleDoc = YES;
        BOOL shouldOCR = NO;

        switch (popupTag) {
            // upload original file
          case kUploadOriginal: shouldConvertToGoogleDoc = NO; break;

            // OCR
          case kUploadOCR:      shouldOCR = YES; break;

            // translation
          case kUploadDE:       targetLanguage = @"de"; break; // german
          case kUploadJA:       targetLanguage = @"ja"; break; // japanese
          case kUploadEN:       targetLanguage = @"en"; break; // english

          default: break;
        }

        GDataQueryDocs *query = [GDataQueryDocs queryWithFeedURL:uploadURL];

        [query setShouldConvertUpload:shouldConvertToGoogleDoc];
        [query setShouldOCRUpload:shouldOCR];

        // we'll leave out the sourceLanguage parameter to get
        // auto-detection of the file's language
        //
        // language codes: http://www.loc.gov/standards/iso639-2/php/code_list.php
        [query setTargetLanguage:targetLanguage];

        uploadURL = [query URL];
      }

      // make service tickets call back into our upload progress selector
      GDataServiceGoogleDocs *service = [self docsService];

      // insert the entry into the docList feed
      GDataServiceTicket *ticket;
      ticket = [service fetchEntryByInsertingEntry:newEntry
                                        forFeedURL:uploadURL
                                          delegate:self
                                 didFinishSelector:@selector(uploadFileTicket:finishedWithEntry:error:)];
      SEL progressSel = @selector(ticket:hasDeliveredByteCount:ofTotalByteCount:);
      [ticket setUploadProgressSelector:progressSel];

      // we turned automatic retry on when we allocated the service, but we
      // could also turn it on just for this ticket

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
- (void)ticket:(GDataServiceTicket *)ticket
   hasDeliveredByteCount:(unsigned long long)numberOfBytesRead
   ofTotalByteCount:(unsigned long long)dataLength {

  [mUploadProgressIndicator setMinValue:0.0];
  [mUploadProgressIndicator setMaxValue:(double)dataLength];
  [mUploadProgressIndicator setDoubleValue:(double)numberOfBytesRead];
}

// upload finished callback
- (void)uploadFileTicket:(GDataServiceTicket *)ticket
     finishedWithEntry:(GDataEntryDocBase *)entry
                   error:(NSError *)error {

  [self setUploadTicket:nil];
  [mUploadProgressIndicator setDoubleValue:0.0];

  if (error == nil) {
    // refetch the current doc list
    [self fetchDocList];

    // tell the user that the add worked
    NSBeginAlertSheet(@"Uploaded file", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"File uploaded: %@",
                      [[entry title] stringValue]);
  } else {
    NSBeginAlertSheet(@"Upload failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"File upload failed: %@", error);
  }
  [self updateUI];
}

#pragma mark TableView delegate methods

//
// table view delegate methods
//

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  if ([notification object] == mDocListTable) {
    // the user selected a document entry, so fetch its revisions
    [self fetchRevisionsForSelectedDoc];
  } else {
    // the user selected a revision entry
    //
    // update the publishing checkboxes to match the newly-selected revision

    GDataEntryDocRevision *selectedRevision = [self selectedRevision];

    BOOL isPublished = [[selectedRevision publish] boolValue];
    [mPublishCheckbox setState:(isPublished ? NSOnState : NSOffState)];

    BOOL isAutoRepublished = [[selectedRevision publishAuto] boolValue];
    [mAutoRepublishCheckbox setState:(isAutoRepublished ? NSOnState : NSOffState)];

    BOOL isExternalPublished = [[selectedRevision publishOutsideDomain] boolValue];
    [mPublishOutsideDomainCheckbox setState:(isExternalPublished ? NSOnState : NSOffState)];

    [self updateUI];
  }
}

// table view data source methods
- (int)numberOfRowsInTableView:(NSTableView *)tableView {
  if (tableView == mDocListTable) {
    return [[mDocListFeed entries] count];
  }

  if (tableView == mRevisionsTable) {
    return [[mRevisionFeed entries] count];
  }

  return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {

  if (tableView == mDocListTable) {
    // get the docList entry's title, and the kind of document
    GDataEntryDocBase *doc = [mDocListFeed entryAtIndex:row];

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

  if (tableView == mRevisionsTable) {
    // get the revision entry
    GDataEntryDocRevision *revisionEntry;
    revisionEntry = [mRevisionFeed entryAtIndex:row];

    NSString *displayStr = [NSString stringWithFormat:@"%@ (edited %@)",
                            [[revisionEntry title] stringValue],
                            [[revisionEntry editedDate] date]];
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


- (GDataFeedDocRevision *)revisionFeed {
  return mRevisionFeed;
}

- (void)setRevisionFeed:(GDataFeedDocRevision *)feed {
  [mRevisionFeed autorelease];
  mRevisionFeed = [feed retain];
}

- (NSError *)revisionFetchError {
  return mRevisionFetchError;
}

- (void)setRevisionFetchError:(NSError *)error {
  [mRevisionFetchError release];
  mRevisionFetchError = [error retain];
}

- (GDataServiceTicket *)revisionFetchTicket {
  return mRevisionFetchTicket;
}

- (void)setRevisionFetchTicket:(GDataServiceTicket *)ticket {
  [mRevisionFetchTicket release];
  mRevisionFetchTicket = [ticket retain];
}


- (GDataEntryDocListMetadata *)metadataEntry {
  return mMetadataEntry;
}

- (void)setMetadataEntry:(GDataEntryDocListMetadata *)entry {
  [mMetadataEntry release];
  mMetadataEntry = [entry retain];
}


- (GDataServiceTicket *)uploadTicket {
  return mUploadTicket;
}

- (void)setUploadTicket:(GDataServiceTicket *)ticket {
  [mUploadTicket release];
  mUploadTicket = [ticket retain];
}

@end
