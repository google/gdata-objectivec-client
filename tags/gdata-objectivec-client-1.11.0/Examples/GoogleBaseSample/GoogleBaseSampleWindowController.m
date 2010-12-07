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
//  GoogleBaseSampleWindowController.m
//

#import "GoogleBaseSampleWindowController.h"

@interface GoogleBaseSampleWindowController (PrivateMethods)
- (void)updateUI;

- (GDataServiceGoogleBase *)googleBaseService;
- (GDataEntryGoogleBase *)selectedGoogleBaseEntry;
- (GDataGoogleBaseAttribute *)selectedAttribute;
- (GDataGoogleBaseMetadataAttribute *)selectedMetadataAttribute;
- (GDataGoogleBaseMetadataAttribute *)selectedMetadataAttributeListAttribute;

- (GDataFeedGoogleBase *)googleBaseFeed;
- (void)setGoogleBaseFeed:(GDataFeedGoogleBase *)feed;
- (NSError *)googleBaseFetchError;
- (void)setGoogleBaseFetchError:(NSError *)error;  
@end

@implementation GoogleBaseSampleWindowController

static GoogleBaseSampleWindowController* gGoogleBaseSampleWindowController = nil;

+ (GoogleBaseSampleWindowController *)sharedGoogleBaseSampleWindowController {
  
  if (!gGoogleBaseSampleWindowController) {
    gGoogleBaseSampleWindowController = [[GoogleBaseSampleWindowController alloc] init];
  }  
  return gGoogleBaseSampleWindowController;
}


- (id)init {
  return [self initWithWindowNibName:@"GoogleBaseSampleWindow"];
}

- (void)windowDidLoad {
}

- (void)awakeFromNib {
  [self updateUI];
}

- (void)dealloc {
  [mGoogleBaseFeed release];
  [mGoogleBaseFetchError release];
  
  [super dealloc];
}

#pragma mark -

- (void)updateTextField:(NSTextField *)textField
  withObjectDescription:(id)obj {

  // put the object description into the text field and
  // as the field's tooltip, or else clear the field and
  // tooltip
  NSString *attrResultStr = @"";
  if (obj) {
    attrResultStr = [obj description];
  }

  [textField setStringValue:attrResultStr];
  [textField setToolTip:attrResultStr];
}

- (void)updateUI {
 
  // reload the table data
  [mGoogleBaseTable reloadData]; 
  [mAttributesTable reloadData];
  [mMetadataAttributesTable reloadData];
  [mMetadataAttributesListTable reloadData];

  // turn on or off the "loading" spinner
  if (mIsGoogleBaseFetchPending) {
    [mGoogleBaseProgressIndicator startAnimation:self];  
  } else {
    [mGoogleBaseProgressIndicator stopAnimation:self];  
  }
  
  // update the selected item text (or the fetch error)  
  id obj;
  if (mGoogleBaseFetchError) {
    obj = mGoogleBaseFetchError;
  } else {
    GDataEntryGoogleBase *entry = [self selectedGoogleBaseEntry]; 
    obj = entry; 
  }
  [self updateTextField:mGoogleBaseResultTextField withObjectDescription:obj];

  // attributes list display
  GDataGoogleBaseAttribute *attr = [self selectedAttribute]; 
  [self updateTextField:mAttributesResultTextField withObjectDescription:attr];

  // metadata attributes list display
  GDataGoogleBaseMetadataAttribute *attr2 = [self selectedMetadataAttribute]; 
  [self updateTextField:mMetadataAttributesResultTextField withObjectDescription:attr2];
  
  // metatdata attributes list display
  GDataGoogleBaseMetadataAttribute *attr3 = [self selectedMetadataAttributeListAttribute]; 
  [self updateTextField:mMetadataAttributesListResultTextField withObjectDescription:attr3];
  
  // enable the batch update button when appropriate (note: this does not
  // really indicate if any of the items can be updated)
  BOOL doEnableBatchUpdate = NO;
  NSString *batchHref = [[mGoogleBaseFeed batchLink] href];
  if ([batchHref length] > 0 
      && [[mGoogleBaseFeed entries] count] > 0
      && [[mUsernameField stringValue] length] > 0
      && [[mPasswordField stringValue] length] > 0) {
    doEnableBatchUpdate = YES;
  }
  
  [mBatchUpdateButton setEnabled:doEnableBatchUpdate];
}

#pragma mark IBActions
- (IBAction)runGoogleBaseQueryClicked:(id)sender {
  
  NSString *queryString = [mBaseQueryField stringValue];
  
  NSString *googleBaseSnippetsFeed = kGDataGoogleBaseSnippetsFeed; // "http://base.google.com/base/feeds/snippets";
  NSURL *feedURL = [NSURL URLWithString:googleBaseSnippetsFeed];
  
  GDataQueryGoogleBase *query = [GDataQueryGoogleBase googleBaseQueryWithFeedURL:feedURL];
  [query setGoogleBaseQuery:queryString];
  
  mIsGoogleBaseFetchPending = YES;
  
  GDataServiceGoogleBase *service = [self googleBaseService];
  [service setUserCredentialsWithUsername:nil
                                 password:nil];
    
  [service fetchFeedWithQuery:query
                     delegate:self
            didFinishSelector:@selector(ticket:finishedWithObject:error:)];
  
  [mBaseQueryURLField setStringValue:[[query URL] absoluteString]];
  
  [self updateUI];
}

- (IBAction)getItemTypesClicked:(id)sender {
  NSString *itemTypesString = [mItemTypesField stringValue];
  
  NSString *googleBaseSnippetsEntry = [kGDataGoogleBaseItemTypesFeed // "http://base.google.com/base/feeds/itemtypes/"
                     stringByAppendingFormat:@"/%@", itemTypesString];
  NSURL *entryURL = [NSURL URLWithString:googleBaseSnippetsEntry];
  
  mIsGoogleBaseFetchPending = YES;
  
  GDataServiceGoogleBase *service = [self googleBaseService];
  [service setUserCredentialsWithUsername:nil
                                 password:nil];
  [service fetchEntryWithURL:entryURL
                    delegate:self
           didFinishSelector:@selector(ticket:finishedWithObject:error:)];
  
  [self updateUI];
}

- (IBAction)getAttributesClicked:(id)sender {
  NSString *attributesString = [mAttributesField stringValue];
  
  NSString *googleBaseSnippetsFeed = [kGDataGoogleBaseAttributesFeed // "http://base.google.com/base/feeds/attributes/"
                     stringByAppendingFormat:@"/%@", attributesString];
  NSURL *feedURL = [NSURL URLWithString:googleBaseSnippetsFeed];
  
  mIsGoogleBaseFetchPending = YES;
  
  GDataServiceGoogleBase *service = [self googleBaseService];
  [service setUserCredentialsWithUsername:nil
                                 password:nil];
  [service fetchFeedWithURL:feedURL
                   delegate:self
          didFinishSelector:@selector(ticket:finishedWithObject:error:)];
  
  [self updateUI];
}

- (IBAction)getUserItemsClicked:(id)sender {
  
  NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  
  NSString *username = [mUsernameField stringValue];
  username = [username stringByTrimmingCharactersInSet:whitespace];
  
  if ([username rangeOfString:@"@"].location == NSNotFound) {
    // if no domain was supplied, add @gmail.com
    username = [username stringByAppendingString:@"@gmail.com"];
  }
  
  [mUsernameField setStringValue:username];
  
  NSString *password = [mPasswordField stringValue];
  
  NSURL *feedURL = [NSURL URLWithString:kGDataGoogleBaseUserItemsFeed]; // http://www.google.com/base/feeds/items
  
  mIsGoogleBaseFetchPending = YES;
  
  GDataServiceGoogleBase *service = [self googleBaseService];
  
  [service setUserCredentialsWithUsername:username
                                 password:password];
  
  [service fetchFeedWithURL:feedURL
                   delegate:self
          didFinishSelector:@selector(ticket:finishedWithObject:error:)];
  
  [self updateUI];
}

- (void)ticket:(GDataServiceTicket *)ticket
  finishedWithObject:(GDataObject *)object
         error:(NSError *)error {

  GDataFeedGoogleBase *feed;

  if ([object isKindOfClass:[GDataEntryGoogleBase class]]) {
    // the fetch was for an entry, not a feed; wrap the entry in a feed
    // for our user interface

    feed = [GDataFeedGoogleBase googleBaseFeed];

    [feed addEntry:(GDataEntryGoogleBase *) object];
  } else {
    // the object was a Google Base feed
    feed = (GDataFeedGoogleBase *) object;
  }

  [self setGoogleBaseFeed:feed];
  [self setGoogleBaseFetchError:error];

  mIsGoogleBaseFetchPending = NO;

  // the feed has changed, so the table displaying the feed needs its data
  // refreshed
  [mGoogleBaseTable reloadData];

  // select an appropriate tab by checking for attributes, metadata attributes,
  // or a metadata attribute list in the first entry
  if ([[feed entries] count] > 0) {
    int tabIndex;
    GDataEntryGoogleBase *entry = [[feed entries] objectAtIndex:0];

    if ([[entry entryAttributes] count]) {
      tabIndex = 0;
    } else if ([[entry metadataAttributes] count]) {
      tabIndex = 1;
    } else if ([[[entry metadataAttributeList] metadataAttributes] count]) {
      tabIndex = 2;
    } else {
      tabIndex = 0;
    }
    [mTabView selectTabViewItemAtIndex:tabIndex];
  }

  [self updateUI];
}

#pragma mark -

- (IBAction)batchUpdateContentClicked:(id)sender {

  // for each entry, we'll add a timestamp to the end of the
  // content field, and batch update the whole group

  NSArray *entries = [mGoogleBaseFeed entries];
  NSMutableArray *updatedEntries = [NSMutableArray array];

  for (int idx = 0; idx < [entries count]; idx++) {

    // get this entry's content string
    GDataEntryGoogleBase *entry = [entries objectAtIndex:idx];
    GDataEntryContent *content = [entry content];
    NSString *str = [content stringValue];
    if (str) {

      // append newline and the current date/time to this entry's content
      str = [NSString stringWithFormat:@"%@\n%@", str, [NSDate date]];
      [content setStringValue:str];

      // add a batch ID to this entry
      static int staticID = 0;
      NSString *batchID = [NSString stringWithFormat:@"batchID_%u", ++staticID];
      [entry setBatchIDWithString:batchID];

      // we don't need to add the batch operation to the entries since
      // we're putting it in the feed to apply to all entries
      [updatedEntries addObject:entry];

      // we could force an error on an item by nuking the entry's identifier
      //   if (idx == 1) { [entry setIdentifier:nil]; }
    }
  }

  NSURL *batchURL = [[mGoogleBaseFeed batchLink] URL];
  if (batchURL != nil && [updatedEntries count] > 0) {

    // make a batch feed object: add entries, and since
    // we are doing the same operation for all entries in the feed,
    // add the operation

    GDataFeedGoogleBase *batchFeed = [GDataFeedGoogleBase googleBaseFeed];
    [batchFeed setEntriesWithEntries:updatedEntries];

    GDataBatchOperation *op = [GDataBatchOperation batchOperationWithType:kGDataBatchOperationUpdate];
    [batchFeed setBatchOperation:op];

    // now do the usual steps for authenticating for this service, and issue
    // the fetch

    NSString *username = [mUsernameField stringValue];
    NSString *password = [mPasswordField stringValue];

    GDataServiceGoogleBase *service = [self googleBaseService];

    [service setUserCredentialsWithUsername:username
                                   password:password];

    mIsGoogleBaseFetchPending = YES;

    [service fetchFeedWithBatchFeed:batchFeed
                    forBatchFeedURL:batchURL
                           delegate:self
                  didFinishSelector:@selector(batchTicket:finishedWithFeed:error:)];

    [self updateUI];
  } else {
    // the button shouldn't be enabled when we can't batch update, so we
    // shouldn't get here
    NSBeep();
  }
}

// batch fetch callback
- (void)batchTicket:(GDataServiceTicket *)ticket
   finishedWithFeed:(GDataFeedGoogleBase *)feed
              error:(NSError *)error {

  if (error == nil) {
    // fetch succeeded

    // step through all the entries in the response feed,
    // and build a string reporting each entry's status

    // show the http status to start (should be 200)
    NSMutableString *reportStr;

    reportStr = [NSMutableString stringWithFormat:@"http status:%d\n\n",
                 [ticket statusCode]];

    NSArray *responseEntries = [feed entries];
    for (int idx = 0; idx < [responseEntries count]; idx++) {

      GDataEntryGoogleBase *entry = [responseEntries objectAtIndex:idx];
      GDataBatchID *batchID = [entry batchID];

      // report the batch ID and status for each item
      [reportStr appendFormat:@"%@\n", [batchID stringValue]];

      GDataBatchInterrupted *interrupted = [entry batchInterrupted];
      if (interrupted) {
        [reportStr appendFormat:@"%@\n", [interrupted description]];
      }

      GDataBatchStatus *status = [entry batchStatus];
      if (status) {
        [reportStr appendFormat:@"%d %@\n", [[status code] intValue],
         [status reason]];
      }
      [reportStr appendString:@"\n"];
    }

    NSBeginAlertSheet(@"Batch update completed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Update completed.\n%@", reportStr);
  } else {
    // fetch failed
    NSBeginAlertSheet(@"Batch update failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Update failed: %@", error);
  }

  mIsGoogleBaseFetchPending = NO;
  [self updateUI];
}

#pragma mark -

// get a GoogleBase service object 
- (GDataServiceGoogleBase *)googleBaseService {

  static GDataServiceGoogleBase* service = nil;
  
  if (!service) {
    service = [[GDataServiceGoogleBase alloc] init];
    
    [service setShouldCacheDatedData:YES];

    // Note: Though this sample doesn't demonstrate it, GData responses are
    //       typically chunked, so check all returned feeds for "next" links
    //       (use -nextLink method from the GDataLinkArray category on the
    //       links array of GData objects) or call the service's
    //       setShouldFollowNextLinks: method.     
  }
  return service;
}

// get the GoogleBase selected in the top list, or nil if none
- (GDataEntryGoogleBase *)selectedGoogleBaseEntry {
  
  NSArray *entries = [mGoogleBaseFeed entries];
  int rowIndex = [mGoogleBaseTable selectedRow];
  if ([entries count] > 0 && rowIndex > -1) {
    
    GDataEntryGoogleBase *entry = [entries objectAtIndex:rowIndex];
    return entry;
  }
  return nil;
}

// get the attribute selected in the table, if any
- (GDataGoogleBaseAttribute *)selectedAttribute {
  
  NSArray *attrs = [[self selectedGoogleBaseEntry] entryAttributes];
  int rowIndex = [mAttributesTable selectedRow];
  if ([attrs count] > 0 && rowIndex > -1) {
    
    GDataGoogleBaseAttribute *attr = [attrs objectAtIndex:rowIndex];
    return attr;
  }
  return nil;
}

// get the metadata attribute selected in the table, if any
- (GDataGoogleBaseMetadataAttribute *)selectedMetadataAttribute {
  
  NSArray *attrs = [[self selectedGoogleBaseEntry] metadataAttributes];
  int rowIndex = [mMetadataAttributesTable selectedRow];
  if ([attrs count] > 0 && rowIndex > -1) {
    
    GDataGoogleBaseMetadataAttribute *attr = [attrs objectAtIndex:rowIndex];
    return attr;
  }
  return nil;
}

// get the metadata attribute selected in the attribute list table, if any
- (GDataGoogleBaseMetadataAttribute *)selectedMetadataAttributeListAttribute {
  
  NSArray *attrs = [[[self selectedGoogleBaseEntry] metadataAttributeList] metadataAttributes];
  int rowIndex = [mMetadataAttributesListTable selectedRow];
  if ([attrs count] > 0 && rowIndex > -1) {
    
    GDataGoogleBaseMetadataAttribute *attr = [attrs objectAtIndex:rowIndex];
    return attr;
  }
  return nil;
}

#pragma mark TableView delegate methods
//
// table view delegate methods
//
- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  
    // the user clicked on an entry; just display it below the table
    [self updateUI]; 
}

// table view data source methods
- (int)numberOfRowsInTableView:(NSTableView *)tableView {
  
  if (tableView == mGoogleBaseTable) {
      return [[mGoogleBaseFeed entries] count];
  }
  
  if (tableView == mAttributesTable) {
      return [[[self selectedGoogleBaseEntry] entryAttributes] count];
  }
  
  if (tableView == mMetadataAttributesTable) {
      return [[[self selectedGoogleBaseEntry] metadataAttributes] count];
  }
  
  if (tableView == mMetadataAttributesListTable) {
      return [[[[self selectedGoogleBaseEntry] metadataAttributeList] metadataAttributes] count];
  }
  return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
  
  if (tableView == mGoogleBaseTable) {
    // get the GoogleBase entry's title
    GDataEntryGoogleBase *entry = [[mGoogleBaseFeed entries] objectAtIndex:row];
    return [[entry title] stringValue];
  } 
  
  // GDataGoogleBaseAttributes have fields for name, type, and text value
  if (tableView == mAttributesTable) {
    GDataGoogleBaseAttribute *attr = [[[self selectedGoogleBaseEntry] entryAttributes] objectAtIndex:row];
    NSString *displayStr = [NSString stringWithFormat:@"%@ (%@): %@",
      [attr name], [attr type], [attr textValue]];
    return displayStr;
  }
  
  // GDataGoogleBaseMetadataAttributes have fields for type, name, and 
  // sometimes count, plus possble "values" child items
  
  GDataGoogleBaseMetadataAttribute *attr2 = nil;
  if (tableView == mMetadataAttributesTable) {
    attr2 = [[[self selectedGoogleBaseEntry] metadataAttributes] objectAtIndex:row];
  }
  
  if (tableView == mMetadataAttributesListTable) {
    attr2 = [[[[self selectedGoogleBaseEntry] metadataAttributeList] metadataAttributes] objectAtIndex:row];
  }

  NSString *displayStr = [NSString stringWithFormat:@"%@ (%@)",
    [attr2 name], [attr2 type]]; // format without a count field initially
  
  if ([attr2 count]) {
    // if there's a count field, add that
    displayStr = [displayStr stringByAppendingFormat:@": count=%@", [attr2 count]];
  }

  if ([[attr2 values] count]) {
    // if there are "values" sub-items, add the number of those, too
    displayStr = [displayStr stringByAppendingFormat:@" (%d values)", [[attr2 values] count]];
  }

  return displayStr;
}


#pragma mark Setters and Getters

// the most recently retrieved feed
- (GDataFeedGoogleBase *)googleBaseFeed {
  return mGoogleBaseFeed; 
}

- (void)setGoogleBaseFeed:(GDataFeedGoogleBase *)feed {
  [mGoogleBaseFeed autorelease];
  mGoogleBaseFeed = [feed retain];
}

// the most recent fetch error
- (NSError *)googleBaseFetchError {
  return mGoogleBaseFetchError; 
}

- (void)setGoogleBaseFetchError:(NSError *)error {
  [mGoogleBaseFetchError release];
  mGoogleBaseFetchError = [error retain];
}

@end
