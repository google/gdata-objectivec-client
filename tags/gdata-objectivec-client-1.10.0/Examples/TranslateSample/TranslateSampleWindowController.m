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
//  TranslateSampleWindowController.m
//

#import "TranslateSampleWindowController.h"

enum {
  kDocumentsSegment = 0,
  kGlossariesSegment = 1,
  kMemoriesSegment = 2
};

@interface TranslateSampleWindowController (PrivateMethods)
- (void)updateUI;

- (GDataFeedBase *)feedForSelectedSegment;
- (NSError *)fetchErrorForSelectedSegment;

- (GDataServiceGoogleTranslation *)translationService;
- (GDataEntryBase *)selectedEntry;

- (void)fetchFeeds;
- (void)cancelFetches;

- (void)toggleGlossaryID:(NSString *)glossaryID
                    name:(NSString *)glossaryName
        forDocumentEntry:(GDataEntryTranslationDocument *)docEntry;

- (void)toggleMemoryID:(NSString *)memoryID
                  name:(NSString *)memoryName
      forDocumentEntry:(GDataEntryTranslationDocument *)docEntry;

- (void)uploadEntry;
- (void)downloadSelectedEntry;
- (void)renameSelectedEntry;
- (void)deleteSelectedEntry;

- (GDataFeedTranslationDocument *)documentFeed;
- (void)setDocumentFeed:(GDataFeedTranslationDocument *)feed;
- (NSError *)documentFeedFetchError;
- (void)setDocumentFeedFetchError:(NSError *)error;
- (GDataServiceTicket *)documentFeedTicket;
- (void)setDocumentFeedTicket:(GDataServiceTicket *)ticket;

- (GDataFeedTranslationGlossary *)glossaryFeed;
- (void)setGlossaryFeed:(GDataFeedTranslationGlossary *)feed;
- (NSError *)glossaryFeedFetchError;
- (void)setGlossaryFeedFetchError:(NSError *)error;
- (GDataServiceTicket *)glossaryFeedTicket;
- (void)setGlossaryFeedTicket:(GDataServiceTicket *)ticket;

- (GDataFeedTranslationMemory *)memoryFeed;
- (void)setMemoryFeed:(GDataFeedTranslationMemory *)feed;
- (NSError *)memoryFeedFetchError;
- (void)setMemoryFeedFetchError:(NSError *)error;
- (GDataServiceTicket *)memoryFeedTicket;
- (void)setMemoryFeedTicket:(GDataServiceTicket *)ticket;

@end

@implementation TranslateSampleWindowController

+ (TranslateSampleWindowController *)sharedWindowController {

  static TranslateSampleWindowController* gController = nil;

  if (!gController) {
    gController = [[TranslateSampleWindowController alloc] init];
  }
  return gController;
}


- (id)init {
  return [self initWithWindowNibName:@"TranslateSampleWindow"];
}

- (void)awakeFromNib {
  // Set the result text fields to have a distinctive color and mono-spaced font
  [mEntriesResultTextField setTextColor:[NSColor darkGrayColor]];

  NSFont *resultTextFont = [NSFont fontWithName:@"Monaco" size:9];
  [mEntriesResultTextField setFont:resultTextFont];

  [self updateUI];
}

- (void)dealloc {
  [mDocumentFeed release];
  [mDocumentFeedTicket release];
  [mDocumentFeedFetchError release];

  [mGlossaryFeed release];
  [mGlossaryFeedTicket release];
  [mGlossaryFeedFetchError release];

  [mMemoryFeed release];
  [mMemoryFeedTicket release];
  [mMemoryFeedFetchError release];

  [super dealloc];
}

#pragma mark -

- (void)updateUI {

  // current feed display
  [mEntriesTable reloadData];

  BOOL isFeedFetchPending = (mDocumentFeedTicket != nil ||
                             mGlossaryFeedTicket != nil ||
                             mMemoryFeedTicket != nil);
  if (isFeedFetchPending) {
    [mEntriesProgressIndicator startAnimation:self];
  } else {
    [mEntriesProgressIndicator stopAnimation:self];
  }

  if (mPendingEditTicketCounter > 0) {
    [mUpdateProgressIndicator startAnimation:self];
  } else {
    [mUpdateProgressIndicator stopAnimation:self];
  }

  // get selected entry or fetch error
  GDataEntryBase *selectedEntry = [self selectedEntry];
  NSString *entriesResultStr = @"";
  NSError *fetchError = [self fetchErrorForSelectedSegment];
  if (fetchError) {
    entriesResultStr = [fetchError description];
  } else {
    if (selectedEntry != nil) {
      entriesResultStr = [selectedEntry description];
    }
  }
  [mEntriesResultTextField setString:entriesResultStr];

  // enable/disable buttons
  [mCancelFeedFetchesButton setEnabled:isFeedFetchPending];

  int selectedSegment = [mEntriesSegmentedControl selectedSegment];
  BOOL isDocSegmentSelected = (selectedSegment == kDocumentsSegment);

  BOOL isEntrySelected = (selectedEntry != nil);
  BOOL isDocEntrySelected = isDocSegmentSelected && isEntrySelected;

  [mGlossariesPopup setEnabled:isDocEntrySelected];
  [mMemoriesPopup setEnabled:isDocEntrySelected];
  [mDownloadButton setEnabled:isDocEntrySelected];

  BOOL hasTitle = [[mTitleTextField stringValue] length] > 0;
  BOOL hasPath = [[mDocumentPathField stringValue] length] > 0;
  BOOL hasLangs = ([[mSourceLangField stringValue] length] > 0)
    && ([[mTargetLangField stringValue] length] > 0);

  BOOL canPost = ([[[self feedForSelectedSegment] postLink] URL] != nil);
  BOOL canEdit = ([[[self selectedEntry] editLink] URL] != nil);

  [mUploadButton setEnabled:(canPost && hasTitle && hasPath && hasLangs)];
  [mRenameButton setEnabled:(isEntrySelected && canEdit && hasTitle)];
  [mDeleteButton setEnabled:(isEntrySelected && canEdit)];

  [mSourceLangField setEnabled:isDocSegmentSelected];
  [mTargetLangField setEnabled:isDocSegmentSelected];
}

#pragma mark IBActions

- (IBAction)getFeedClicked:(id)sender {

  NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];

  NSString *username = [mUsernameField stringValue];
  username = [username stringByTrimmingCharactersInSet:whitespace];

  if ([username rangeOfString:@"@"].location == NSNotFound) {
    // if no domain was supplied, add @gmail.com
    username = [username stringByAppendingString:@"@gmail.com"];
  }

  [mUsernameField setStringValue:username];

  [self fetchFeeds];
}

- (IBAction)cancelFetchesClicked:(id)sender {
  [self cancelFetches];
}

- (IBAction)uploadEntryClicked:(id)sender {
  [self uploadEntry];
}

- (IBAction)downloadEntryClicked:(id)sender {
  [self downloadSelectedEntry];
}

- (IBAction)renameEntryClicked:(id)sender {
  [self renameSelectedEntry];
}

- (IBAction)deleteEntryClicked:(id)sender {
  [self deleteSelectedEntry];
}

- (IBAction)entriesSegmentClicked:(id)sender {
  [self updateUI];
}

- (IBAction)glossaryPopupSelected:(id)sender {
  GDataEntryTranslationDocument *selectedEntry;

  // add or remove the glossary item from the selected entry
  selectedEntry = (GDataEntryTranslationDocument *)[self selectedEntry];

  NSString *glossaryID = [[sender selectedItem] representedObject];
  if (glossaryID) {
    NSString *glossaryName = [[sender selectedItem] title];

    [self toggleGlossaryID:glossaryID
                      name:glossaryName
          forDocumentEntry:selectedEntry];
  }
}

- (IBAction)memoryPopupSelected:(id)sender {
  GDataEntryTranslationDocument *selectedEntry;

  // add or remove the memory item from the selected entry
  selectedEntry = (GDataEntryTranslationDocument *)[self selectedEntry];

  NSString *memoryID = [[sender selectedItem] representedObject];
  if (memoryID) {
    NSString *memoryName = [[sender selectedItem] title];

    [self toggleMemoryID:memoryID
                    name:memoryName
        forDocumentEntry:selectedEntry];
  }
}

- (IBAction)browseForFileClicked:(id)sender {
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setPrompt:@"Upload"];

  NSArray *extensions;

  int selectedSegment = [mEntriesSegmentedControl selectedSegment];
  if (selectedSegment == kDocumentsSegment) {
    // types of documents for translating
    //
    // http://code.google.com/apis/gtt/docs/1.0/reference.html#gtt:documentSource
    extensions = [NSArray arrayWithObjects:@"aea", @"html", @"htm",
                  @"txt", @"doc", @"rtf", @"odt", nil];
  } else if (selectedSegment == kGlossariesSegment) {
    // glossary files are comma-separated values
    extensions = [NSArray arrayWithObject:@"csv"];
  } else {
    // translation memory file
    extensions = [NSArray arrayWithObject:@"tmx"];
  }

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
    // save the selected file's path in the path text field
    NSString *filePath = [panel filename];
    [mDocumentPathField setStringValue:filePath];

    [self updateUI];
  }
}

- (IBAction)loggingCheckboxClicked:(id)sender {
  [GDataHTTPFetcher setIsLoggingEnabled:[sender state]];
}

#pragma mark -

// get a Google service object with the current username/password
//
// A "service" object handles networking tasks.  Service objects
// contain user authentication information as well as networking
// state information (such as cookies and the "last modified" date for
// fetched data.)

- (GDataServiceGoogleTranslation *)translationService {

  static GDataServiceGoogleTranslation* service = nil;

  if (!service) {
    service = [[GDataServiceGoogleTranslation alloc] init];

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

// get the entry selected in the list, or nil if none
- (GDataEntryBase *)selectedEntry {

  GDataFeedBase *feed = [self feedForSelectedSegment];
  NSArray *entries = [feed entries];

  int rowIndex = [mEntriesTable selectedRow];
  if ([entries count] > 0 && rowIndex > -1) {

    GDataEntryBase *entry = [entries objectAtIndex:rowIndex];
    return entry;
  }
  return nil;
}

- (GDataFeedBase *)feedForSelectedSegment {
  NSInteger selectedSegment = [mEntriesSegmentedControl selectedSegment];
  switch (selectedSegment) {
    case kDocumentsSegment:  return mDocumentFeed;
    case kGlossariesSegment: return mGlossaryFeed;
    case kMemoriesSegment:   return mMemoryFeed;
    default:                 return nil;
  };
}

- (NSError *)fetchErrorForSelectedSegment {
  NSInteger selectedSegment = [mEntriesSegmentedControl selectedSegment];
  switch (selectedSegment) {
    case kDocumentsSegment:  return mDocumentFeedFetchError;
    case kGlossariesSegment: return mGlossaryFeedFetchError;
    case kMemoriesSegment:   return mMemoryFeedFetchError;
    default:                 return nil;
  };
}

- (void)fetchFeeds {

  [self setDocumentFeed:nil];
  [self setDocumentFeedFetchError:nil];

  [self setGlossaryFeed:nil];
  [self setGlossaryFeedFetchError:nil];

  [self setMemoryFeed:nil];
  [self setMemoryFeedFetchError:nil];

  // fetch all three feeds
  GDataServiceGoogleTranslation *service = [self translationService];

  // for the translation documents feed, we may want a query to request
  // hidden or deleted documents
  BOOL shouldShowHiddenOnly = [mHiddenCheckbox state];
  BOOL shouldShowDeletedOnly = [mDeletedCheckbox state];

  NSURL *docFeedURL = [GDataServiceGoogleTranslation documentFeedURL];

  GDataQueryTranslation *docQuery;
  docQuery = [GDataQueryTranslation translationQueryWithFeedURL:docFeedURL];

  [docQuery setShouldShowOnlyDeleted:shouldShowDeletedOnly];
  if (shouldShowHiddenOnly) {
    [docQuery addCategoryFilterWithScheme:nil
                                     term:kGDataCategoryLabelHidden];
  }

  GDataServiceTicket *ticket;
  ticket = [service fetchFeedWithQuery:docQuery
                             feedClass:[GDataFeedTranslationDocument class]
                              delegate:self
                     didFinishSelector:@selector(documentFeedTicket:finishedWithFeed:error:)];
  [self setDocumentFeedTicket:ticket];

  // glossary feed
  NSURL *glossaryFeedURL = [GDataServiceGoogleTranslation glossaryFeedURL];
  ticket = [service fetchFeedWithURL:glossaryFeedURL
                           feedClass:[GDataFeedTranslationGlossary class]
                            delegate:self
                   didFinishSelector:@selector(glossaryFeedTicket:finishedWithFeed:error:)];
  [self setGlossaryFeedTicket:ticket];

  // memory feed
  NSURL *memoryFeedURL = [GDataServiceGoogleTranslation memoryFeedURL];
  ticket = [service fetchFeedWithURL:memoryFeedURL
                           feedClass:[GDataFeedTranslationMemory class]
                            delegate:self
                   didFinishSelector:@selector(memoryFeedTicket:finishedWithFeed:error:)];
  [self setMemoryFeedTicket:ticket];

  [self updateUI];
}

- (void)cancelFetches {
  [mDocumentFeedTicket cancelTicket];
  [self setDocumentFeedTicket:nil];

  [mGlossaryFeedTicket cancelTicket];
  [self setGlossaryFeedTicket:nil];

  [mMemoryFeedTicket cancelTicket];
  [self setMemoryFeedTicket:nil];

  [self updateUI];
}

// feed fetch callback
- (void)documentFeedTicket:(GDataServiceTicket *)ticket
          finishedWithFeed:(GDataFeedTranslationDocument *)feed
                     error:(NSError *)error {

  [self setDocumentFeed:feed];
  [self setDocumentFeedFetchError:error];
  [self setDocumentFeedTicket:nil];

  [self updateUI];
}

- (void)glossaryFeedTicket:(GDataServiceTicket *)ticket
          finishedWithFeed:(GDataFeedTranslationGlossary *)feed
                     error:(NSError *)error {

  [self setGlossaryFeed:feed];
  [self setGlossaryFeedFetchError:error];
  [self setGlossaryFeedTicket:nil];

  [self updateUI];
}

- (void)memoryFeedTicket:(GDataServiceTicket *)ticket
        finishedWithFeed:(GDataFeedTranslationMemory *)feed
                   error:(NSError *)error {

  [self setMemoryFeed:feed];
  [self setMemoryFeedFetchError:error];
  [self setMemoryFeedTicket:nil];

  [self updateUI];
}

#pragma mark Remove or add a glossary for a document

- (void)toggleGlossaryID:(NSString *)glossaryID
                      name:(NSString *)glossaryName
          forDocumentEntry:(GDataEntryTranslationDocument *)docEntry {

  // make a copy of the document entry so any changes we make to the entry
  // are not reflected in the feed if the update fails
  GDataEntryTranslationDocument *updatedEntry = [[docEntry copy] autorelease];

  GDataTranslationGlossary *glossary = [updatedEntry glossary];

  // search for a link with an href matching this ID
  GDataLink *glossaryLink;
  glossaryLink = [GDataUtilities firstObjectFromArray:[glossary links]
                                            withValue:glossaryID
                                           forKeyPath:@"href"];
  BOOL isAddingLink;

  if (glossaryLink) {
    // found a matching link; remove it
    [glossary removeLink:glossaryLink];

    if ([[glossary links] count] == 0) {
      // avoid updating with an empty list of links (bug 2323468)
      [updatedEntry setGlossary:nil];
    }
    isAddingLink = NO;
  } else {
    // no matching link found; add one
    GDataLink *newLink = [GDataLink linkWithRel:nil
                                           type:nil
                                           href:glossaryID];
    if (glossary != nil) {
      // add to the existing glossary
      [glossary addLink:newLink];
    } else {
      // make a new glossary in the document entry
      glossary = [GDataTranslationGlossary glossaryWithLink:newLink];
      [updatedEntry setGlossary:glossary];
    }
    isAddingLink = YES;
  }

  GDataServiceGoogleTranslation *service = [self translationService];
  GDataServiceTicket *ticket;
  ticket = [service fetchEntryByUpdatingEntry:updatedEntry
                                     delegate:self
                            didFinishSelector:@selector(glossaryUpdateTicket:finishedWithEntry:error:)];

  // pass the glossary name to the fetch callback for display to the user
  [ticket setProperty:glossaryName
               forKey:@"display name"];
  [ticket setProperty:(isAddingLink ? @"add" : @"remove")
               forKey:@"display operation"];

  ++mPendingEditTicketCounter;
  [self updateUI];
}

- (void)glossaryUpdateTicket:(GDataServiceTicket *)ticket
           finishedWithEntry:(GDataEntryTranslationDocument *)docEntry
                       error:(NSError *)error {
  --mPendingEditTicketCounter;

  NSString *glossaryName = [ticket propertyForKey:@"display name"];
  NSString *displayOp = [ticket propertyForKey:@"display operation"];

  if (error == nil) {
    // updated successfully
    NSBeginAlertSheet(@"Glossary update", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Updated translation document \"%@\" to %@ glossary \"%@\"",
                      [[docEntry title] stringValue], displayOp, glossaryName);
    [self fetchFeeds];
  } else {
    // failed to update
    NSBeginAlertSheet(@"Glossary update", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Failed to %@ for glossary \"%@\", error %@",
                      displayOp, glossaryName, error);

    [self updateUI];
  }
}

#pragma mark Remove or add a memory for a document

- (void)toggleMemoryID:(NSString *)memoryID
                  name:(NSString *)memoryName
      forDocumentEntry:(GDataEntryTranslationDocument *)docEntry {

  // make a copy of the document entry so any changes we make to the entry
  // are not reflected in the feed if the update fails
  GDataEntryTranslationDocument *updatedEntry = [[docEntry copy] autorelease];

  GDataTranslationMemory *memory = [updatedEntry translationMemory];

  // search for a link with an href matching this ID
  GDataLink *memoryLink = [GDataUtilities firstObjectFromArray:[memory links]
                                                     withValue:memoryID
                                                    forKeyPath:@"href"];
  BOOL isAddingLink;

  if (memoryLink) {
    // found a matching link; remove it
    [memory removeLink:memoryLink];

    if ([[memory links] count] == 0) {
      // avoid updating with an empty list (bug 2323468)
      [updatedEntry setTranslationMemory:nil];
    }
    isAddingLink = NO;
  } else {
    // no matching link found; add one
    GDataLink *newLink = [GDataLink linkWithRel:nil
                                           type:nil
                                           href:memoryID];
    if (memory != nil) {
      // add to the existing memory
      [memory addLink:newLink];
    } else {
      // make a new memory in the document entry
      memory = [GDataTranslationMemory memoryWithLink:newLink];
      [updatedEntry setTranslationMemory:memory];
    }
    isAddingLink = YES;
  }

  GDataServiceGoogleTranslation *service = [self translationService];
  GDataServiceTicket *ticket;
  ticket = [service fetchEntryByUpdatingEntry:updatedEntry
                                     delegate:self
                            didFinishSelector:@selector(memoryUpdateTicket:finishedWithEntry:error:)];

  // pass the memory name to the fetch callback for display to the user
  [ticket setProperty:memoryName
               forKey:@"display name"];
  [ticket setProperty:(isAddingLink ? @"add" : @"remove")
               forKey:@"display operation"];

  ++mPendingEditTicketCounter;
  [self updateUI];
}

- (void)memoryUpdateTicket:(GDataServiceTicket *)ticket
         finishedWithEntry:(GDataEntryTranslationDocument *)docEntry
                     error:(NSError *)error {
  --mPendingEditTicketCounter;

  NSString *memoryName = [ticket propertyForKey:@"display name"];
  NSString *displayOp = [ticket propertyForKey:@"display operation"];

  if (error == nil) {
    // updated successfully
    NSBeginAlertSheet(@"Memory update", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Updated translation document \"%@\" to %@ memory \"%@\"",
                      [[docEntry title] stringValue], displayOp, memoryName);
    [self fetchFeeds];
  } else {
    // failed to update
    NSBeginAlertSheet(@"Memory update", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Failed to %@ for memory \"%@\", error %@",
                      displayOp, memoryName, error);

    [self updateUI];
  }
}

#pragma mark Add an entry

- (void)uploadEntry {

  // get the data for the document, glossary, or memory file to upload
  NSString *filePath = [mDocumentPathField stringValue];
  NSData *fileData = [NSData dataWithContentsOfFile:filePath];
  if ([fileData length] == 0) {
    NSBeginAlertSheet(@"Error", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Cannot get file data for path: %@", filePath);
    return;
  }

  // make a new entry for the class appropriate to the selected segment
  GDataEntryBase *newEntry = nil;

  NSInteger selectedSegment = [mEntriesSegmentedControl selectedSegment];
  NSString *title = [mTitleTextField stringValue];
  NSString *mimeType = nil;

  switch (selectedSegment) {
    case kDocumentsSegment: {
      NSString *sourceLang = [mSourceLangField stringValue];
      NSString *targetLang = [mTargetLangField stringValue];

      newEntry = [GDataEntryTranslationDocument documentWithTitle:title
                                                   sourceLanguage:sourceLang
                                                   targetLanguage:targetLang];
      mimeType = [GDataUtilities MIMETypeForFileAtPath:filePath
                                       defaultMIMEType:@"text/plain"];
      break;
    }

    case kGlossariesSegment:
      newEntry = [GDataEntryTranslationGlossary glossaryWithTitle:title];
      mimeType = @"text/csv";
      break;

    case kMemoriesSegment:
      newEntry = [GDataEntryTranslationMemory documentWithTitle:title
                                                          scope:kGDataTranslationScopePrivate];
      mimeType = @"text/xml";
      break;
  };

  [newEntry setUploadData:fileData];
  [newEntry setUploadMIMEType:mimeType];

  NSURL *postURL = [[[self feedForSelectedSegment] postLink] URL];
  if (postURL != nil) {

    GDataServiceGoogleTranslation *service = [self translationService];

    [service fetchEntryByInsertingEntry:newEntry
                             forFeedURL:postURL
                               delegate:self
                      didFinishSelector:@selector(uploadEntryTicket:finishedWithEntry:error:)];
    ++mPendingEditTicketCounter;
    [self updateUI];
  }
}

- (void)uploadEntryTicket:(GDataServiceTicket *)ticket
        finishedWithEntry:(GDataEntryBase *)addedEntry
                    error:(NSError *)error {

  --mPendingEditTicketCounter;

  if (error == nil) {
    NSBeginAlertSheet(@"Add", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Added entry: %@",
                      [[addedEntry title] stringValue]);
    [self fetchFeeds];
    [mTitleTextField setStringValue:@""];
  } else {
    // failed to add entry
    GDataEntryBase *postedEntry = [ticket postedObject];
    NSBeginAlertSheet(@"Add", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Failed to add entry: %@\nError: %@",
                      [[postedEntry title] stringValue], error);
    [self updateUI];
  }
}

#pragma mark Download a translated document

- (void)downloadSelectedEntry {

  GDataEntryBase *selectedEntry = [self selectedEntry];
  NSString *sourceURI = [[selectedEntry content] sourceURI];
  if (sourceURI) {

    NSSavePanel *savePanel = [NSSavePanel savePanel];

    NSString *title = [[selectedEntry title] stringValue];
    SEL endSel = @selector(saveSheetDidEnd:returnCode:contextInfo:);
    [savePanel beginSheetForDirectory:nil
                                 file:title
                       modalForWindow:[self window]
                        modalDelegate:self
                       didEndSelector:endSel
                          contextInfo:[selectedEntry retain]];
  } else {
    NSBeep();
  }
}

- (void)saveSheetDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo {

  GDataEntryBase *selectedEntry = [(GDataEntryBase *)contextInfo autorelease];

  if (returnCode == NSOKButton) {
    // user clicked OK
    NSString *savePath = [panel filename];

    NSURL *sourceURL = [[selectedEntry content] sourceURL];

    // use the service to make an authenticated request for the entry source
    GDataServiceGoogleTranslation *service = [self translationService];

    NSURLRequest *request = [service requestForURL:sourceURL
                                              ETag:nil
                                        httpMethod:nil];

    GDataHTTPFetcher *fetcher = [GDataHTTPFetcher httpFetcherWithRequest:request];
    [fetcher setUserData:savePath];
    [fetcher beginFetchWithDelegate:self
                  didFinishSelector:@selector(fetcher:finishedWithData:)
                    didFailSelector:@selector(fetcher:failedWithError:)];
  }
}

- (void)fetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data {
  // save the file to the local path specified by the user
  NSString *savePath = [fetcher userData];
  NSError *error = nil;
  BOOL didWrite = [data writeToFile:savePath
                            options:NSAtomicWrite
                              error:&error];
  if (!didWrite) {
    NSLog(@"Error saving file: %@", error);
    NSBeep();
  } else {
    // successfully saved the document
  }
}

- (void)fetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error {
  NSLog(@"Fetcher error: %@", error);
  NSBeep();
}

#pragma mark Rename an entry

- (void)renameSelectedEntry {
  GDataEntryBase *selectedEntry = [self selectedEntry];

  // change a copy of the entry, so in case our update fails we haven't
  // altered the one in the feed
  GDataEntryBase *updatedEntry = [[selectedEntry copy] autorelease];

  NSString *newTitle = [mTitleTextField stringValue];
  [updatedEntry setTitleWithString:newTitle];

  GDataServiceGoogleTranslation *service = [self translationService];

  GDataServiceTicket *ticket;
  ticket = [service fetchEntryByUpdatingEntry:updatedEntry
                                     delegate:self
                            didFinishSelector:@selector(renameEntryTicket:finishedWithEntry:error:)];
  [ticket setProperty:[[selectedEntry title] stringValue]
             forKey:@"old name"];

  ++mPendingEditTicketCounter;
  [self updateUI];
}

- (void)renameEntryTicket:(GDataServiceTicket *)ticket
        finishedWithEntry:(GDataEntryBase *)updatedEntry
                    error:(NSError *)error {

  --mPendingEditTicketCounter;

  NSString *oldName = [ticket propertyForKey:@"old name"];

  if (error == nil) {
    NSBeginAlertSheet(@"Rename", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Renamed entry \"%@\" to \"%@\"",
                      oldName,
                      [[updatedEntry title] stringValue]);
    [self fetchFeeds];
    [mTitleTextField setStringValue:@""];
  } else {
    // failed to rename entry
    NSBeginAlertSheet(@"Error", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Failed to rename entry \"%@\"\nError: %@",
                      oldName, error);
    [self updateUI];
  }
}

#pragma mark Delete an entry

- (void)deleteSelectedEntry {
  GDataEntryBase *selectedEntry = [self selectedEntry];

  GDataServiceGoogleTranslation *service = [self translationService];

  GDataServiceTicket *ticket;
  ticket = [service deleteEntry:selectedEntry
                       delegate:self
              didFinishSelector:@selector(deleteEntryTicket:finishedWithNil:error:)];

  ++mPendingEditTicketCounter;
  [self updateUI];
}

- (void)deleteEntryTicket:(GDataServiceTicket *)ticket
          finishedWithNil:(GDataObject *)nilObject
                    error:(NSError *)error {

  --mPendingEditTicketCounter;

  GDataEntryBase *deletedEntry = [ticket postedObject];

  if (error == nil) {
    NSBeginAlertSheet(@"Delete", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Deleted entry \"%@\"",
                      [[deletedEntry title] stringValue]);
    [self fetchFeeds];
    [mTitleTextField setStringValue:@""];
  } else {

    // failed to rename entry
    NSBeginAlertSheet(@"Error", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Failed to delete entry \"%@'\"\nError: %@",
                      [[deletedEntry title] stringValue], error);
    [self updateUI];
  }
}

#pragma mark Text field delegate methods

- (void)controlTextDidChange:(NSNotification *)note {
  [self updateUI]; // enabled/disable buttons
}

#pragma mark TableView delegate methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  [self updateUI];
}

// table view data source methods

- (int)numberOfRowsInTableView:(NSTableView *)tableView {
  GDataFeedBase *feed = [self feedForSelectedSegment];
  return [[feed entries] count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
  GDataFeedBase *feed = [self feedForSelectedSegment];
  GDataEntryBase *entry = [feed entryAtIndex:row];
  NSString *title = [[entry title] stringValue];

  if ([entry isKindOfClass:[GDataEntryTranslationDocument class]]) {
    GDataEntryTranslationDocument *docEntry;

    docEntry = (GDataEntryTranslationDocument *)entry;

    BOOL isCompleted = [docEntry hasCompletedTranslation];
    if (isCompleted) {
      static const int kCheckmark = 0x2713;
      title = [title stringByAppendingFormat:@" %C", kCheckmark];
    }

    BOOL isHidden = [docEntry isHidden];
    if (isHidden) {
      title = [title stringByAppendingString:@" (hidden)"];
    }
  }

  BOOL isDeleted = [entry isDeleted];
  if (isDeleted) {
    static const int kBallotX = 0x2717; // fancy X to indicate deleted items
    title = [NSString stringWithFormat:@"%C %@", kBallotX, title];
  }
  return title;
}

#pragma mark Menu delegate methods

- (void)menuNeedsUpdate:(NSMenu *)menu {
  // the documents segment should be selected; otherwise, the pop-ups would
  // be disabled
  GDataFeedBase *feed;

  GDataEntryTranslationDocument *selectedDocument =
    (GDataEntryTranslationDocument *)[self selectedEntry];

  NSArray *hrefs; // glossary or memory links

  if (menu == [mGlossariesPopup menu]) {
    feed = mGlossaryFeed;
    hrefs = [[selectedDocument glossary] hrefs];
  } else {
    feed = mMemoryFeed;
    hrefs = [[selectedDocument translationMemory] hrefs];
  }

  // delete all items but the title, which is "Glossaries" or "Memories"
  while ([menu numberOfItems] > 1) {
    [menu removeItemAtIndex:1];
  }

  // step through all glossary or memory items and list them in the pop-up menu
  GDataEntryBase *entry;
  GDATA_FOREACH(entry, [feed entries]) {
    NSString *title = [[entry title] stringValue];
    NSString *entryID = [entry identifier];

    NSMenuItem *menuItem = [menu addItemWithTitle:title
                                           action:NULL
                                    keyEquivalent:@""];
    [menuItem setRepresentedObject:entryID];

    // if this item's href is in the href list of the selected entry in the list
    // view, add a checkmark to the new menu item
    if ([hrefs containsObject:entryID]) {
      [menuItem setState:NSOnState];
    }
  }
}

#pragma mark Setters and Getters

- (GDataFeedTranslationDocument *)documentFeed {
  return mDocumentFeed;
}

- (void)setDocumentFeed:(GDataFeedTranslationDocument *)feed {
  [mDocumentFeed autorelease];
  mDocumentFeed = [feed retain];
}

- (NSError *)documentFeedFetchError {
  return mDocumentFeedFetchError;
}

- (void)setDocumentFeedFetchError:(NSError *)error {
  [mDocumentFeedFetchError release];
  mDocumentFeedFetchError = [error retain];
}

- (GDataServiceTicket *)documentFeedTicket {
  return mDocumentFeedTicket;
}

- (void)setDocumentFeedTicket:(GDataServiceTicket *)ticket {
  [mDocumentFeedTicket autorelease];
  mDocumentFeedTicket = [ticket retain];
}


- (GDataFeedTranslationGlossary *)glossaryFeed {
  return mGlossaryFeed;
}

- (void)setGlossaryFeed:(GDataFeedTranslationGlossary *)feed {
  [mGlossaryFeed autorelease];
  mGlossaryFeed = [feed retain];
}

- (NSError *)glossaryFeedFetchError {
  return mGlossaryFeedFetchError;
}

- (void)setGlossaryFeedFetchError:(NSError *)error {
  [mGlossaryFeedFetchError release];
  mGlossaryFeedFetchError = [error retain];
}

- (GDataServiceTicket *)glossaryFeedTicket {
  return mGlossaryFeedTicket;
}

- (void)setGlossaryFeedTicket:(GDataServiceTicket *)ticket {
  [mGlossaryFeedTicket autorelease];
  mGlossaryFeedTicket = [ticket retain];
}


- (GDataFeedTranslationMemory *)memoryFeed {
  return mMemoryFeed;
}

- (void)setMemoryFeed:(GDataFeedTranslationMemory *)feed {
  [mMemoryFeed autorelease];
  mMemoryFeed = [feed retain];
}

- (NSError *)memoryFeedFetchError {
  return mMemoryFeedFetchError;
}

- (void)setMemoryFeedFetchError:(NSError *)error {
  [mMemoryFeedFetchError release];
  mMemoryFeedFetchError = [error retain];
}

- (GDataServiceTicket *)memoryFeedTicket {
  return mMemoryFeedTicket;
}

- (void)setMemoryFeedTicket:(GDataServiceTicket *)ticket {
  [mMemoryFeedTicket autorelease];
  mMemoryFeedTicket = [ticket retain];
}

@end
