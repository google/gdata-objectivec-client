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
//  SpreadsheetSampleWindowController.m
//

#import "SpreadsheetSampleWindowController.h"

@interface SpreadsheetSampleWindowController (PrivateMethods)
- (void)updateUI;

- (void)fetchFeedOfSpreadsheets;
- (void)fetchSelectedSpreadsheet;
- (void)fetchSelectedWorksheet;

- (GDataServiceGoogleSpreadsheet *)spreadsheetService;
- (GDataEntrySpreadsheet *)selectedSpreadsheet;
- (GDataEntryWorksheet *)selectedWorksheet;
- (GDataEntryBase *)selectedEntry;

- (GDataFeedSpreadsheet *)spreadsheetFeed;
- (void)setSpreadsheetFeed:(GDataFeedSpreadsheet *)feed;
- (NSError *)spreadsheetFetchError;
- (void)setSpreadsheetFetchError:(NSError *)error;  

- (GDataFeedWorksheet *)worksheetFeed;
- (void)setWorksheetFeed:(GDataFeedWorksheet *)feed;
- (NSError *)worksheetFetchError;
- (void)setWorksheetFetchError:(NSError *)error;
  
- (GDataFeedBase *)entryFeed;
- (void)setEntryFeed:(GDataFeedBase *)feed;
- (NSError *)entryFetchError;
- (void)setEntryFetchError:(NSError *)error;

@end

@implementation SpreadsheetSampleWindowController

static SpreadsheetSampleWindowController* gSpreadsheetSampleWindowController = nil;


+ (SpreadsheetSampleWindowController *)sharedSpreadsheetSampleWindowController {
  
  if (!gSpreadsheetSampleWindowController) {
    gSpreadsheetSampleWindowController = [[SpreadsheetSampleWindowController alloc] init];
  }  
  return gSpreadsheetSampleWindowController;
}


- (id)init {
  return [self initWithWindowNibName:@"SpreadsheetSampleWindow"];
}

- (void)windowDidLoad {
}

- (void)awakeFromNib {
  // Set the result text fields to have a distinctive color and mono-spaced font
  // to aid in understanding of each query operation.
  [mSpreadsheetResultTextField setTextColor:[NSColor darkGrayColor]];
  [mWorksheetResultTextField setTextColor:[NSColor darkGrayColor]];
  [mEntryResultTextField setTextColor:[NSColor darkGrayColor]];

  NSFont *resultTextFont = [NSFont fontWithName:@"Monaco" size:9];
  [mSpreadsheetResultTextField setFont:resultTextFont];
  [mWorksheetResultTextField setFont:resultTextFont];
  [mEntryResultTextField setFont:resultTextFont];

  [self updateUI];
}

- (void)dealloc {
  [mSpreadsheetFeed release];
  [mSpreadsheetFetchError release];
  
  [mWorksheetFeed release];
  [mWorksheetFetchError release];
  
  [mEntryFeed release];
  [mEntryFetchError release];
  
  [super dealloc];
}

#pragma mark -

- (void)updateUI {
  
  // spreadsheet list display
  [mSpreadsheetTable reloadData]; 
  
  if (mIsSpreadsheetFetchPending) {
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
    } else {
      
    }
  }
  [mSpreadsheetResultTextField setString:spreadsheetResultStr];
  
  
  // Worksheet list display
  [mWorksheetTable reloadData]; 
  
  if (mIsWorksheetFetchPending) {
    [mWorksheetProgressIndicator startAnimation:self];  
  } else {
    [mWorksheetProgressIndicator stopAnimation:self];  
  }
  
  // Worksheet fetch result or selected item
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
  
  
  // cell/list entry display
  [mEntryTable reloadData];
  
  if (mIsEntryFetchPending) {
    [mEntryProgressIndicator startAnimation:self];  
  } else {
    [mEntryProgressIndicator stopAnimation:self];  
  }
  
  // entry fetch result or selected item
  NSString *entryResultStr = @"";
  if (mEntryFetchError) {
    entryResultStr = [mEntryFetchError description];
  } else {
    GDataEntryBase *entry = [self selectedEntry];
    if (entry) {
      entryResultStr = [entry description];
    }
  }
  [mEntryResultTextField setString:entryResultStr];
  
}

#pragma mark IBActions

- (IBAction)getSpreadsheetClicked:(id)sender {
  
  NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  
  NSString *username = [mUsernameField stringValue];
  username = [username stringByTrimmingCharactersInSet:whitespace];
  
  if ([username rangeOfString:@"@"].location == NSNotFound) {
    // if no domain was supplied, add @gmail.com
    username = [username stringByAppendingString:@"@gmail.com"];
  }
  
  [mUsernameField setStringValue:username];

  [self fetchFeedOfSpreadsheets];
}

- (IBAction)feedSegmentClicked:(id)sender {
  // user switched between cell and list feed
  [self fetchSelectedWorksheet];
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
  }

  // username/password may change
  NSString *username = [mUsernameField stringValue];
  NSString *password = [mPasswordField stringValue];
  
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

// get the Worksheet selected in the second list, or nil if none
- (GDataEntryWorksheet *)selectedWorksheet {
  
  NSArray *Worksheets = [mWorksheetFeed entries];
  int rowIndex = [mWorksheetTable selectedRow];
  if ([Worksheets count] > 0 && rowIndex > -1) {
    
    GDataEntryWorksheet *Worksheet = [Worksheets objectAtIndex:rowIndex];
    return Worksheet;
  }
  return nil;
}

// get the cell or list entry selected in the bottom list
- (GDataEntryBase *)selectedEntry {
  
  NSArray *entries = [mEntryFeed entries];
  
  int rowIndex = [mEntryTable selectedRow];
  if ([entries count] > 0 && rowIndex > -1) {
    
    GDataEntryBase *entry = [entries objectAtIndex:rowIndex];
    return entry;
  }
  return nil;
}

#pragma mark Fetch feed of all of the user's spreadsheets

// begin retrieving the list of the user's spreadsheets
- (void)fetchFeedOfSpreadsheets {

  [self setSpreadsheetFeed:nil];
  [self setSpreadsheetFetchError:nil];

  [self setWorksheetFeed:nil];
  [self setWorksheetFetchError:nil];

  [self setEntryFeed:nil];
  [self setEntryFetchError:nil];

  mIsSpreadsheetFetchPending = YES;

  GDataServiceGoogleSpreadsheet *service = [self spreadsheetService];
  NSURL *feedURL = [NSURL URLWithString:kGDataGoogleSpreadsheetsPrivateFullFeed];
  [service fetchFeedWithURL:feedURL
                   delegate:self
          didFinishSelector:@selector(feedTicket:finishedWithFeed:error:)];

  [self updateUI];
}

// spreadsheet list fetch callback
- (void)feedTicket:(GDataServiceTicket *)ticket
  finishedWithFeed:(GDataFeedSpreadsheet *)feed
             error:(NSError *)error {

  [self setSpreadsheetFeed:feed];
  [self setSpreadsheetFetchError:error];

  mIsSpreadsheetFetchPending = NO;
  [self updateUI];
}

#pragma mark Fetch a spreadsheet's Worksheets

// for the spreadsheet selected in the top list, begin retrieving the list of
// Worksheets
- (void)fetchSelectedSpreadsheet {
  
  GDataEntrySpreadsheet *spreadsheet = [self selectedSpreadsheet];
  if (spreadsheet) {
    
    NSURL *feedURL = [spreadsheet worksheetsFeedURL];
    if (feedURL) {
      
      [self setWorksheetFeed:nil];
      [self setWorksheetFetchError:nil];
      mIsWorksheetFetchPending = YES;
      
      [self setEntryFeed:nil];
      [self setEntryFetchError:nil];      

      GDataServiceGoogleSpreadsheet *service = [self spreadsheetService];
      [service fetchFeedWithURL:feedURL
                       delegate:self
              didFinishSelector:@selector(worksheetsTicket:finishedWithFeed:error:)];
      [self updateUI];
    }
  }
}

// fetch worksheet feed callback
- (void)worksheetsTicket:(GDataServiceTicket *)ticket
        finishedWithFeed:(GDataFeedWorksheet *)feed
                   error:(NSError *)error {

  [self setWorksheetFeed:feed];
  [self setWorksheetFetchError:error];

  mIsWorksheetFetchPending = NO;

  [self updateUI];
}

#pragma mark Fetch a worksheet's entries

// for the worksheet selected, fetch either a cell feed or a list feed
// of its contents, depending on the segmented control's setting

- (void)fetchSelectedWorksheet {
  
  GDataEntryWorksheet *worksheet = [self selectedWorksheet];
  if (worksheet) {
    
    // the segmented control lets the user retrieve cell entries (position 0)
    // or list entries (position 1)
    int segmentIndex = [mFeedSelectorSegments selectedSegment];
    NSURL *feedURL;

    if (segmentIndex == 0) {
      feedURL = [[worksheet cellsLink] URL];

    } else {
      feedURL = [worksheet listFeedURL];
    }

    if (feedURL) {

      [self setEntryFeed:nil];
      [self setEntryFetchError:nil];

      mIsEntryFetchPending = YES;

      GDataServiceGoogleSpreadsheet *service = [self spreadsheetService];
      [service fetchFeedWithURL:feedURL
                       delegate:self
              didFinishSelector:@selector(entriesTicket:finishedWithFeed:error:)];
      [self updateUI];
    }
  }
}

// fetch entries callback
- (void)entriesTicket:(GDataServiceTicket *)ticket
     finishedWithFeed:(GDataFeedBase *)feed
                error:(NSError *)error {

  [self setEntryFeed:feed];
  [self setEntryFetchError:error];

  mIsEntryFetchPending = NO;

  [self updateUI];
}

#pragma mark TableView delegate methods
//
// table view delegate methods
//

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  id obj = [notification object];
  if (obj == mSpreadsheetTable) {
    // the user clicked on a spreadsheet, so fetch its Worksheets
    [self fetchSelectedSpreadsheet];
  } else if (obj == mWorksheetTable) {
    [self fetchSelectedWorksheet];
  } else {
    [self updateUI];
  }
}

// table view data source methods
- (int)numberOfRowsInTableView:(NSTableView *)tableView {
  if (tableView == mSpreadsheetTable) {
    return [[mSpreadsheetFeed entries] count];
  } else if (tableView == mWorksheetTable) {
    return [[mWorksheetFeed entries] count];
  } else {
    return [[mEntryFeed entries] count]; 
  }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
  
  if (tableView == mSpreadsheetTable) {
    
    // get the spreadsheet entry's title
    GDataEntrySpreadsheet *spreadsheet = [[mSpreadsheetFeed entries] objectAtIndex:row];
    return [[spreadsheet title] stringValue];
    
  } else if (tableView == mWorksheetTable) {
    
    // get the worksheet entry's title
    GDataEntryWorksheet *worksheetEntry = [[mWorksheetFeed entries] objectAtIndex:row];
    return [[worksheetEntry title] stringValue];
    
  } else {
    
    // entry table; get a string for the cell or the list item
    GDataEntryBase *entry = [[mEntryFeed entries] objectAtIndex:row];
    NSString *displayStr;
    
    if ([entry isKindOfClass:[GDataEntrySpreadsheetCell class]]) {
      
      // format cell entry data
      GDataSpreadsheetCell *cell = [(GDataEntrySpreadsheetCell *)entry cell];
      
      NSString *resultStr = [cell resultString]; // like "3.1415926"
      NSString *inputStr = [cell inputString]; // like "=pi()"
      NSString *title = [[entry title] stringValue]; // like "A3"

      // show the input string (like =pi()) only if it differs
      // from the result string
      if (!inputStr || (resultStr && [inputStr isEqual:resultStr])) {
       inputStr = @""; 
      }
      
      displayStr = [NSString stringWithFormat:@"%@: %@  %@",
        title, inputStr, (resultStr ? resultStr : @"")];
      
    } else {
      
      // format list entry data
      //
      // a list entry we will show as a sequence of (name,value) items from
      // the entry's custom elements
      GDataEntrySpreadsheetList *listEntry = (GDataEntrySpreadsheetList *)entry;
      NSDictionary *customElements = [listEntry customElementDictionary];

      NSMutableArray *array = [NSMutableArray array];
      NSEnumerator *enumerator = [customElements objectEnumerator];
      GDataSpreadsheetCustomElement *element;
      
      while ((element = [enumerator nextObject]) != nil) {
        
        NSString *elemStr = [NSString stringWithFormat:@"(%@, %@)",
          [element name], [element stringValue]];
        [array addObject:elemStr];
      }
      displayStr = [array componentsJoinedByString:@", "];
    }
    return displayStr;
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

- (GDataFeedBase *)entryFeed {
  return mEntryFeed; 
}

- (void)setEntryFeed:(GDataFeedBase *)feed {
  [mEntryFeed autorelease];
  mEntryFeed = [feed retain];
}

- (NSError *)entryFetchError {
  return mEntryFetchError; 
}

- (void)setEntryFetchError:(NSError *)error {
  [mEntryFetchError release];
  mEntryFetchError = [error retain];
}

@end
