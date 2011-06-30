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
//  SpreadsheetTableSampleWindowController.m
//

#import "SpreadsheetTableSampleWindowController.h"

@interface SpreadsheetTableSampleWindowController (PrivateMethods)
- (void)updateUI;

- (void)fetchFeedOfSpreadsheets;
- (void)fetchSelectedSpreadsheet;
- (void)fetchSelectedTable;

- (void)addTableToSelectedWorksheet;
- (void)deleteSelectedTable;
- (void)randomizeSelectedTable;


- (GDataServiceGoogleSpreadsheet *)spreadsheetService;
- (GDataEntrySpreadsheet *)selectedSpreadsheet;
- (GDataEntryWorksheet *)selectedWorksheet;
- (GDataEntrySpreadsheetTable *)selectedTable;
- (GDataEntrySpreadsheetRecord *)selectedRecord;


- (GDataFeedSpreadsheet *)spreadsheetFeed;
- (void)setSpreadsheetFeed:(GDataFeedSpreadsheet *)feed;
- (NSError *)spreadsheetFetchError;
- (void)setSpreadsheetFetchError:(NSError *)error;
- (GDataServiceTicket *)spreadsheetFeedTicket;
- (void)setSpreadsheetFeedTicket:(GDataServiceTicket *)obj;

- (GDataFeedWorksheet *)worksheetFeed;
- (void)setWorksheetFeed:(GDataFeedWorksheet *)feed;
- (NSError *)worksheetFetchError;
- (void)setWorksheetFetchError:(NSError *)error;
- (GDataServiceTicket *)worksheetFeedTicket;
- (void)setWorksheetFeedTicket:(GDataServiceTicket *)obj;

- (GDataFeedSpreadsheetTable *)tableFeed;
- (void)setTableFeed:(GDataFeedSpreadsheetTable *)feed;
- (NSError *)tableFetchError;
- (void)setTableFetchError:(NSError *)error;
- (GDataServiceTicket *)tableFeedTicket;
- (void)setTableFeedTicket:(GDataServiceTicket *)obj;

- (GDataFeedSpreadsheetRecord *)recordFeed;
- (void)setRecordFeed:(GDataFeedSpreadsheetRecord *)feed;
- (NSError *)recordFetchError;
- (void)setRecordFetchError:(NSError *)error;
- (GDataServiceTicket *)recordFeedTicket;
- (void)setRecordFeedTicket:(GDataServiceTicket *)obj;


@end

@implementation SpreadsheetTableSampleWindowController

+ (SpreadsheetTableSampleWindowController *)sharedWindowController {

  static SpreadsheetTableSampleWindowController* gWindowController = nil;

  if (!gWindowController) {
    gWindowController = [[SpreadsheetTableSampleWindowController alloc] init];
  }
  return gWindowController;
}


- (id)init {
  return [self initWithWindowNibName:@"SpreadsheetTableSampleWindow"];
}

- (void)windowDidLoad {
}

- (void)awakeFromNib {
  // Set the result text fields to have a distinctive color and mono-spaced font
  [mSpreadsheetResultTextField setTextColor:[NSColor darkGrayColor]];
  [mWorksheetResultTextField setTextColor:[NSColor darkGrayColor]];
  [mTableResultTextField setTextColor:[NSColor darkGrayColor]];
  [mRecordResultTextField setTextColor:[NSColor darkGrayColor]];

  NSFont *resultTextFont = [NSFont fontWithName:@"Monaco" size:9];
  [mSpreadsheetResultTextField setFont:resultTextFont];
  [mWorksheetResultTextField setFont:resultTextFont];
  [mTableResultTextField setFont:resultTextFont];
  [mRecordResultTextField setFont:resultTextFont];

  // add notifications so we can track global starts and stops of fetching
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self
         selector:@selector(fetchStateChanged:)
             name:kGTMHTTPFetcherStartedNotification
           object:nil];
  [nc addObserver:self
         selector:@selector(fetchStateChanged:)
             name:kGTMHTTPFetcherStoppedNotification
           object:nil];

  [self updateUI];
}

- (void)dealloc {

  [mSpreadsheetFeed release];
  [mSpreadsheetFeedTicket release];
  [mSpreadsheetFetchError release];

  [mWorksheetFeed release];
  [mWorksheetFeedTicket release];
  [mWorksheetFetchError release];

  [mTableFeed release];
  [mTableFeedTicket release];
  [mTableFetchError release];

  [mRecordFeed release];
  [mRecordFeedTicket release];
  [mRecordFetchError release];

  [mRecordUpdateTickets release];

  [super dealloc];
}

#pragma mark -

- (void)updateUI {

  // spreadsheet list display
  [mSpreadsheetTable reloadData];

  if (mSpreadsheetFeedTicket != nil) {
    [mSpreadsheetProgressIndicator startAnimation:self];
  } else {
    [mSpreadsheetProgressIndicator stopAnimation:self];
  }

  // spreadsheet fetch result or selected item
  NSString *spreadsheetResultStr = @"";
  if (mSpreadsheetFetchError) {
    spreadsheetResultStr = [mSpreadsheetFetchError description];
  } else {
    GDataEntrySpreadsheet *spreadsheet = [self selectedSpreadsheet];
    if (spreadsheet) {
      spreadsheetResultStr = [spreadsheet description];
    }
  }
  [mSpreadsheetResultTextField setString:spreadsheetResultStr];


  // worksheets list display
  [mWorksheetTable reloadData];

  if (mWorksheetFeedTicket != nil) {
    [mWorksheetProgressIndicator startAnimation:self];
  } else {
    [mWorksheetProgressIndicator stopAnimation:self];
  }

  // worksheet fetch result or selected item
  NSString *worksheetResultStr = @"";
  if (mWorksheetFetchError) {
    worksheetResultStr = [mWorksheetFetchError description];
  } else {
    GDataEntryWorksheet *worksheet = [self selectedWorksheet];
    if (worksheet) {
      worksheetResultStr = [worksheet description];
    }
  }
  [mWorksheetResultTextField setString:worksheetResultStr];


  // tables list display
  [mTableTable reloadData];

  if (mTableFeedTicket != nil) {
    [mTableProgressIndicator startAnimation:self];
  } else {
    [mTableProgressIndicator stopAnimation:self];
  }

  // table fetch result or selected item
  NSString *tableResultStr = @"";
  if (mTableFetchError) {
    tableResultStr = [mTableFetchError description];
  } else {
    GDataEntrySpreadsheetTable *table = [self selectedTable];
    if (table) {
      tableResultStr = [table description];
    }
  }
  [mTableResultTextField setString:tableResultStr];


  // record display
  [mRecordTable reloadData];

  if (mRecordFeedTicket != nil || [mRecordUpdateTickets count] > 0) {
    [mRecordProgressIndicator startAnimation:self];
  } else {
    [mRecordProgressIndicator stopAnimation:self];
  }

  // record fetch result or selected item
  NSString *recordResultStr = @"";
  if (mRecordFetchError) {
    recordResultStr = [mRecordFetchError description];
  } else {
    GDataEntrySpreadsheetRecord *record = [self selectedRecord];
    if (record) {
      recordResultStr = [record description];
    }
  }
  [mRecordResultTextField setString:recordResultStr];

  BOOL isWorksheetSelected = ([self selectedWorksheet] != nil);
  BOOL canPostToTable = ([mTableFeed postLink] != nil);
  BOOL canAddTableToWorksheet = (isWorksheetSelected && canPostToTable);
  [mAddTableButton setEnabled:canAddTableToWorksheet];

  BOOL isTableSelected = ([self selectedTable] != nil);
  [mDeleteTableButton setEnabled:isTableSelected];

  BOOL hasEditableRecordFeed = ([mRecordFeed postLink] != nil);
  [mRandomizeTableButton setEnabled:hasEditableRecordFeed];
}

#pragma mark IBActions

- (IBAction)getSpreadsheetClicked:(id)sender {

  NSCharacterSet *wsSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];

  NSString *username = [mUsernameField stringValue];
  username = [username stringByTrimmingCharactersInSet:wsSet];

  if ([username rangeOfString:@"@"].location == NSNotFound) {
    // if no domain was supplied, add @gmail.com
    username = [username stringByAppendingString:@"@gmail.com"];
  }

  [mUsernameField setStringValue:username];

  [self fetchFeedOfSpreadsheets];
}

- (IBAction)addTableClicked:(id)sender {
  [self addTableToSelectedWorksheet];
}

- (IBAction)deleteTableClicked:(id)sender {

  GDataEntrySpreadsheetTable *table = [self selectedTable];

  NSBeginAlertSheet(@"Delete", nil, @"Cancel", nil,
                    [self window], self,
                    @selector(deleteSheetDidEnd:returnCode:contextInfo:),
                    nil, nil, @"Delete table \"%@\"?",
                    [[table title] stringValue]);
}

- (void)deleteSheetDidEnd:(NSWindow *)sheet
               returnCode:(int)returnCode
              contextInfo:(void  *)contextInfo {
  if (returnCode == NSOKButton) {
    [self deleteSelectedTable];
  }
}


- (IBAction)randomizeTableClicked:(id)sender {
  GDataEntrySpreadsheetTable *table = [self selectedTable];

  NSBeginAlertSheet(@"Randomize", nil, @"Cancel", nil,
                    [self window], self,
                    @selector(randomizeSheetDidEnd:returnCode:contextInfo:),
                    nil, nil, @"Load random data into table \"%@\"?",
                    [[table title] stringValue]);
}

- (void)randomizeSheetDidEnd:(NSWindow *)sheet
                  returnCode:(int)returnCode
                 contextInfo:(void  *)contextInfo {
  if (returnCode == NSOKButton) {
    [self randomizeSelectedTable];
  }
}

- (IBAction)loggingCheckboxClicked:(id)sender {
  [GTMHTTPFetcher setLoggingEnabled:[sender state]];
}

#pragma mark -

// get a spreadsheet service object with the current username/password
//
// A "service" object handles networking tasks.  Service objects
// contain user authentication information as well as networking
// state information (such as cookies and the "last modified" date for
// fetched data.)

- (GDataServiceGoogleSpreadsheet *)spreadsheetService {

  static GDataServiceGoogleSpreadsheet* service = nil;

  if (!service) {
    service = [[GDataServiceGoogleSpreadsheet alloc] init];

    [service setShouldCacheResponseData:YES];
    [service setServiceShouldFollowNextLinks:YES];

    // iPhone apps will typically disable caching dated data or will call
    // clearLastModifiedDates after done fetching to avoid wasting
    // memory.
  }

  // username/password may change
  NSString *username = [mUsernameField stringValue];
  NSString *password = [mPasswordField stringValue];

  [service setUserAgent:@"MyCompany-SampleSpreadsheetApp-1.0"]; // set this to yourName-appName-appVersion
  [service setUserCredentialsWithUsername:username
                                 password:password];

  return service;
}

// get the spreadsheet selected in the top list, or nil if none
- (GDataEntrySpreadsheet *)selectedSpreadsheet {

  NSArray *spreadsheets = [mSpreadsheetFeed entries];
  int rowIndex = [mSpreadsheetTable selectedRow];
  if ([spreadsheets count] > 0 && rowIndex > -1) {

    GDataEntrySpreadsheet *spreadsheet = [spreadsheets objectAtIndex:rowIndex];
    return spreadsheet;
  }
  return nil;
}

// get the worksheet selected in the second list, or nil if none
- (GDataEntryWorksheet *)selectedWorksheet {

  NSArray *worksheets = [mWorksheetFeed entries];
  int rowIndex = [mWorksheetTable selectedRow];
  if ([worksheets count] > 0 && rowIndex > -1) {

    GDataEntryWorksheet *worksheet = [worksheets objectAtIndex:rowIndex];
    return worksheet;
  }
  return nil;
}

// get the table selected in the third list, or nil if none
- (GDataEntrySpreadsheetTable *)selectedTable {

  NSArray *tables = [mTableFeed entries];
  int rowIndex = [mTableTable selectedRow];
  if ([tables count] > 0 && rowIndex > -1) {

    GDataEntrySpreadsheetTable *table = [tables objectAtIndex:rowIndex];
    return table;
  }
  return nil;
}

// get the record selected in the bottom list
- (GDataEntrySpreadsheetRecord *)selectedRecord {

  NSArray *records = [mRecordFeed entries];

  int rowIndex = [mRecordTable selectedRow];
  if ([records count] > 0 && rowIndex > -1) {

    GDataEntrySpreadsheetRecord *record = [records objectAtIndex:rowIndex];
    return record;
  }
  return nil;
}

#pragma mark Fetch feed of all of the user's spreadsheets

// begin retrieving the list of the user's spreadsheets
- (void)fetchFeedOfSpreadsheets {

  [self setSpreadsheetFeed:nil];
  [self setSpreadsheetFetchError:nil];

  [self setWorksheetFeed:nil];
  [self setWorksheetFeedTicket:nil];
  [self setWorksheetFetchError:nil];

  [self setTableFeed:nil];
  [self setTableFeedTicket:nil];
  [self setTableFetchError:nil];

  [self setRecordFeed:nil];
  [self setRecordFeedTicket:nil];
  [self setRecordFetchError:nil];

  GDataServiceGoogleSpreadsheet *service = [self spreadsheetService];
  NSURL *feedURL = [NSURL URLWithString:kGDataGoogleSpreadsheetsPrivateFullFeed];

  GDataServiceTicket *ticket;
  ticket = [service fetchFeedWithURL:feedURL
                            delegate:self
                   didFinishSelector:@selector(spreadsheetsTicket:finishedWithFeed:error:)];
  [self setSpreadsheetFeedTicket:ticket];

  [self updateUI];
}

// spreadsheet feed fetch callback
- (void)spreadsheetsTicket:(GDataServiceTicket *)ticket
          finishedWithFeed:(GDataFeedSpreadsheet *)feed
                     error:(NSError *)error {

  [self setSpreadsheetFeed:feed];
  [self setSpreadsheetFetchError:error];
  [self setSpreadsheetFeedTicket:nil];

  [self updateUI];
}

#pragma mark Fetch a spreadsheet's worksheets and tables

// for the spreadsheet selected in the top list, begin retrieving the lists of
// worksheets and tables
- (void)fetchSelectedSpreadsheet {

  GDataEntrySpreadsheet *spreadsheet = [self selectedSpreadsheet];
  if (spreadsheet) {

    GDataServiceGoogleSpreadsheet *service = [self spreadsheetService];

    // fetch the feed of worksheets
    NSURL *worksheetsFeedURL = [spreadsheet worksheetsFeedURL];
    if (worksheetsFeedURL) {

      [self setWorksheetFeed:nil];
      [self setWorksheetFetchError:nil];

      GDataServiceTicket *ticket;
      ticket = [service fetchFeedWithURL:worksheetsFeedURL
                                delegate:self
                       didFinishSelector:@selector(worksheetsTicket:finishedWithFeed:error:)];
      [self setWorksheetFeedTicket:ticket];
    }

    // fetch the feed of tables
    NSURL *tablesFeedURL = [[spreadsheet tablesFeedLink] URL];

    // TODO - temporary code -
    // rely just on the link to the tables feed once that finally is available
    if (tablesFeedURL == nil) {
      NSString *key = [[spreadsheet identifier] lastPathComponent];
      NSString *template = @"http://spreadsheets.google.com/feeds/%@/tables";
      NSString *tableFeedURLString = [NSString stringWithFormat:template, key];
      tablesFeedURL = [NSURL URLWithString:tableFeedURLString];
    }

    if (tablesFeedURL) {

      [self setTableFeed:nil];
      [self setTableFetchError:nil];

      // clear the record feed, since the user will need to select a table again
      // and the record feed will be refetched
      [self setRecordFeed:nil];
      [self setRecordFetchError:nil];

      GDataServiceTicket *ticket;
      ticket = [service fetchFeedWithURL:tablesFeedURL
                                delegate:self
                       didFinishSelector:@selector(tablesTicket:finishedWithFeed:error:)];
      [self setTableFeedTicket:ticket];
    }

    [self updateUI];
  }
}

// worksheets feed fetch callback
- (void)worksheetsTicket:(GDataServiceTicket *)ticket
        finishedWithFeed:(GDataFeedWorksheet *)feed
                   error:(NSError *)error {

  [self setWorksheetFeed:feed];
  [self setWorksheetFetchError:error];
  [self setWorksheetFeedTicket:nil];

  [self updateUI];
}

// tables feed fetch callback
- (void)tablesTicket:(GDataServiceTicket *)ticket
    finishedWithFeed:(GDataFeedSpreadsheetTable *)feed
               error:(NSError *)error {

  [self setTableFeed:feed];
  [self setTableFetchError:error];
  [self setTableFeedTicket:nil];

  [self updateUI];
}

#pragma mark Fetch a table's records

- (void)fetchSelectedTable {

  GDataEntrySpreadsheetTable *table = [self selectedTable];
  if (table) {

    GDataServiceGoogleSpreadsheet *service = [self spreadsheetService];

    // fetch the feed of records
    NSURL *recordFeedURL = [table recordFeedURL];
    if (recordFeedURL) {

      [self setRecordFeed:nil];
      [self setRecordFetchError:nil];

      GDataServiceTicket *ticket;
      ticket = [service fetchFeedWithURL:recordFeedURL
                                delegate:self
                       didFinishSelector:@selector(recordsTicket:finishedWithFeed:error:)];
      [self setRecordFeedTicket:ticket];

      [self updateUI];
    }
  }
}

// records feed fetch callback
- (void)recordsTicket:(GDataServiceTicket *)ticket
     finishedWithFeed:(GDataFeedSpreadsheetRecord *)feed
                error:(NSError *)error {

  [self setRecordFeed:feed];
  [self setRecordFetchError:error];
  [self setRecordFeedTicket:nil];

  [self updateUI];
}

#pragma mark Add a table to the selected worksheet

- (void)addTableToSelectedWorksheet {

  GDataEntryWorksheet *selectedWorksheet = [self selectedWorksheet];
  NSString *worksheetName = [[selectedWorksheet title] stringValue];

  NSURL *postURL = [[mTableFeed postLink] URL];

  if (worksheetName != nil && postURL != nil) {

    // add a 2-column, 3-row table to the selected worksheet
    GDataEntrySpreadsheetTable *newEntry;
    newEntry = [GDataEntrySpreadsheetTable tableEntry];

    NSString *title = [NSString stringWithFormat:@"Table Created %@",
                       [NSDate date]];
    [newEntry setTitleWithString:title];
    [newEntry setWorksheetNameWithString:worksheetName];
    [newEntry setSpreadsheetHeaderWithRow:3];

    GDataSpreadsheetData *spData;
    spData = [GDataSpreadsheetData spreadsheetDataWithStartIndex:4
                                                    numberOfRows:3
                                                   insertionMode:kGDataSpreadsheetModeInsert];
    [spData addColumn:[GDataSpreadsheetColumn columnWithIndexString:@"A"
                                                               name:@"Column Alpha"]];
    [spData addColumn:[GDataSpreadsheetColumn columnWithIndexString:@"B"
                                                               name:@"Column Beta"]];
    [newEntry setSpreadsheetData:spData];

    GDataServiceGoogleSpreadsheet *service = [self spreadsheetService];
    GDataServiceTicket *ticket;

    ticket = [service fetchEntryByInsertingEntry:newEntry
                                      forFeedURL:postURL
                                        delegate:self
                               didFinishSelector:@selector(addTableTicket:finishedWithEntry:error:)];
  }
}

- (void)addTableTicket:(GDataServiceTicket *)ticket
     finishedWithEntry:(GDataEntrySpreadsheetTable *)entry
                 error:(NSError *)error {
  if (error == nil) {
    NSBeginAlertSheet(@"Table added", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Added table \"%@\"",
                      [[entry title] stringValue]);

    [self fetchSelectedSpreadsheet];
  } else {
    NSBeginAlertSheet(@"Add Table Error", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"%@", error);
  }
}

#pragma mark Delete the selected table

- (void)deleteSelectedTable {

  GDataEntrySpreadsheetTable *selectedTable = [self selectedTable];
  if (selectedTable) {

    GDataServiceGoogleSpreadsheet *service = [self spreadsheetService];
    GDataServiceTicket *ticket;

    ticket = [service deleteEntry:selectedTable
                         delegate:self
                didFinishSelector:@selector(deleteTableTicket:finishedWithNil:error:)];
    // save the name in the ticket
    [ticket setProperty:[[selectedTable title] stringValue]
                 forKey:@"tableName"];
  }
}

- (void)deleteTableTicket:(GDataServiceTicket *)ticket
          finishedWithNil:(GDataObject *)nilObj
                    error:(NSError *)error {
  if (error == nil) {
    // succeeded
    NSString *tableName = [ticket propertyForKey:@"tableName"];

    NSBeginAlertSheet(@"Table deleted", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Deleted table \"%@\"", tableName);

    [self fetchSelectedSpreadsheet];
  } else {
    // failed
    NSBeginAlertSheet(@"Delete Table Error", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"%@", error);
  }
}

#pragma mark Randomize the data in the records of the selected table

- (void)randomizeSelectedTable {

  if (mRecordFeed != nil) {

    NSArray *words = [NSArray arrayWithObjects:@"cat", @"dog", @"unicycle",
                      @"airplane", @"boat", @"treehouse", @"doghouse",
                      @"clouds", @"moon", @"sun", @"mars", @"venus", nil];

    // for each field in each record, assign a random word
    for (GDataEntrySpreadsheetRecord *recordEntry in mRecordFeed) {

      for (GDataSpreadsheetField *field in [recordEntry fields]) {

        NSString *word = [words objectAtIndex:(random() % [words count])];
        [field setValue:word];
      }

      // if this API supported batch updates, we wouldn't have to fetch
      // once per record here
      GDataServiceGoogleSpreadsheet *service = [self spreadsheetService];
      GDataServiceTicket *ticket;

      ticket = [service fetchEntryByUpdatingEntry:recordEntry
                                         delegate:self
                                didFinishSelector:@selector(editRecordTicket:finishedWithEntry:error:)];

      if (mRecordUpdateTickets == nil) {
        mRecordUpdateTickets = [[NSMutableArray alloc] init];
      }
      [mRecordUpdateTickets addObject:ticket];
    }
  }
}

- (void)editRecordTicket:(GDataServiceTicket *)ticket
       finishedWithEntry:(GDataEntrySpreadsheetTable *)entry
                   error:(NSError *)error {

  [mRecordUpdateTickets removeObject:ticket];
  if (error == nil) {
    // succeeded
    if ([mRecordUpdateTickets count] == 0) {
      // no more udpate tickets pending, so refresh the table's list of records
      [self fetchSelectedTable];
    }
  } else {
    // failed
    NSLog(@"record update error: %@", error);
  }

  [self updateUI];
}

#pragma mark Global fetch progress indicator

- (void)fetchStateChanged:(NSNotification *)note {

  // This notification observer is invoked whenever fetching starts or stops.
  //
  // If we turn on fetch retries in the service or the ticket, we can also
  // display an indicator of fetch retry delays by observing
  // kGTMHTTPFetcherRetryDelayStartedNotification and
  // kGTMHTTPFetcherRetryDelayStoppedNotification

  static int gCounter = 0;
  if ([[note name] isEqual:kGTMHTTPFetcherStartedNotification]) {
    // started
    ++gCounter;
  } else {
    // stopped
    --gCounter;
  }

  if (gCounter > 0) {
    [mGlobalFetchProgressIndicator startAnimation:self];
  } else {
    [mGlobalFetchProgressIndicator stopAnimation:self];
  }
}

#pragma mark TableView delegate and data source methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  id obj = [notification object];
  if (obj == mSpreadsheetTable) {
    // the user clicked on a spreadsheet, so fetch its worksheets and tables
    [self fetchSelectedSpreadsheet];
  } else if (obj == mTableTable) {
    // the user clicked on a table, so fetch its records
    [self fetchSelectedTable];
  } else {
    // just update the results view for the selected item
    [self updateUI];
  }
}

// table view data source methods
- (GDataFeedBase *)feedForTableView:(NSTableView *)tableView {
  if (tableView == mSpreadsheetTable) return mSpreadsheetFeed;
  if (tableView == mWorksheetTable)   return mWorksheetFeed;
  if (tableView == mTableTable)       return mTableFeed;
  if (tableView == mRecordTable)      return mRecordFeed;
  return nil;
}

- (int)numberOfRowsInTableView:(NSTableView *)tableView {
  GDataFeedBase *feed = [self feedForTableView:tableView];
  return [[feed entries] count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
  GDataFeedBase *feed = [self feedForTableView:tableView];
  GDataEntryBase *entry = [[feed entries] objectAtIndex:row];

  if (tableView == mRecordTable) {
    // for records, return the content, since it conveniently summarizes all
    // fields of the record
    return [[entry content] stringValue];
  } else {
    return [[entry title] stringValue];
  }
}

#pragma mark Setters and Getters

- (GDataFeedSpreadsheet *)spreadsheetFeed {
  return mSpreadsheetFeed;
}

- (void)setSpreadsheetFeed:(GDataFeedSpreadsheet *)feed {
  [mSpreadsheetFeed autorelease];
  mSpreadsheetFeed = [feed retain];
}

- (NSError *)spreadsheetFetchError {
  return mSpreadsheetFetchError;
}

- (void)setSpreadsheetFetchError:(NSError *)error {
  [mSpreadsheetFetchError release];
  mSpreadsheetFetchError = [error retain];
}

- (GDataServiceTicket *)spreadsheetFeedTicket {
  return mSpreadsheetFeedTicket;
}

- (void)setSpreadsheetFeedTicket:(GDataServiceTicket *)obj {
  [mSpreadsheetFeedTicket autorelease];
  mSpreadsheetFeedTicket = [obj retain];
}


- (GDataFeedWorksheet *)worksheetFeed {
  return mWorksheetFeed;
}

- (void)setWorksheetFeed:(GDataFeedWorksheet *)feed {
  [mWorksheetFeed autorelease];
  mWorksheetFeed = [feed retain];
}

- (NSError *)worksheetFetchError {
  return mWorksheetFetchError;
}

- (void)setWorksheetFetchError:(NSError *)error {
  [mWorksheetFetchError release];
  mWorksheetFetchError = [error retain];
}

- (GDataServiceTicket *)worksheetFeedTicket {
  return mWorksheetFeedTicket;
}

- (void)setWorksheetFeedTicket:(GDataServiceTicket *)obj {
  [mWorksheetFeedTicket autorelease];
  mWorksheetFeedTicket = [obj retain];
}


- (GDataFeedSpreadsheetTable *)tableFeed {
  return mTableFeed;
}

- (void)setTableFeed:(GDataFeedSpreadsheetTable *)feed {
  [mTableFeed autorelease];
  mTableFeed = [feed retain];
}

- (NSError *)tableFetchError {
  return mTableFetchError;
}

- (void)setTableFetchError:(NSError *)error {
  [mTableFetchError release];
  mTableFetchError = [error retain];
}

- (GDataServiceTicket *)tableFeedTicket {
  return mTableFeedTicket;
}

- (void)setTableFeedTicket:(GDataServiceTicket *)obj {
  [mTableFeedTicket autorelease];
  mTableFeedTicket = [obj retain];
}


- (GDataFeedSpreadsheetRecord *)recordFeed {
  return mRecordFeed;
}

- (void)setRecordFeed:(GDataFeedSpreadsheetRecord *)feed {
  [mRecordFeed autorelease];
  mRecordFeed = [feed retain];
}

- (NSError *)recordFetchError {
  return mRecordFetchError;
}

- (void)setRecordFetchError:(NSError *)error {
  [mRecordFetchError release];
  mRecordFetchError = [error retain];
}

- (GDataServiceTicket *)recordFeedTicket {
  return mRecordFeedTicket;
}

- (void)setRecordFeedTicket:(GDataServiceTicket *)obj {
  [mRecordFeedTicket autorelease];
  mRecordFeedTicket = [obj retain];
}

@end
