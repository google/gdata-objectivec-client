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
//  FinanceSampleWindowController.m
//

#import "FinanceSampleWindowController.h"

@interface FinanceSampleWindowController (PrivateMethods)
- (void)updateUI;

- (void)fetchFeedOfPortfolios;
- (void)fetchSelectedPortfolio;
- (void)fetchSelectedPosition;

- (void)createPortfolioWithName:(NSString *)portfolioName;
- (void)deletePortfolio:(GDataEntryFinancePortfolio *)portfolioEntry;

- (void)createTransactionWithDate:(NSDate *)date shares:(double)shares price:(double)price type:(NSString *)type;
- (void)deleteTransaction:(GDataEntryFinanceTransaction *)transactionEntry;

- (GDataServiceGoogleFinance *)financeService;
- (GDataEntryFinancePortfolio *)selectedPortfolio;
- (GDataEntryFinancePosition *)selectedPosition;
- (GDataEntryFinanceTransaction *)selectedTransaction;

- (GDataFeedFinancePortfolio *)portfolioFeed;
- (void)setPortfolioFeed:(GDataFeedFinancePortfolio *)feed;
- (NSError *)portfolioFetchError;
- (void)setPortfolioFetchError:(NSError *)error;

- (GDataFeedFinancePosition *)positionFeed;
- (void)setPositionFeed:(GDataFeedFinancePosition *)feed;
- (NSError *)positionFetchError;
- (void)setPositionFetchError:(NSError *)error;

- (GDataFeedBase *)transactionFeed;
- (void)setTransactionFeed:(GDataFeedBase *)feed;
- (NSError *)transactionFetchError;
- (void)setTransactionFetchError:(NSError *)error;
@end

@implementation FinanceSampleWindowController

static FinanceSampleWindowController* gFinanceSampleWindowController = nil;

+ (FinanceSampleWindowController *)sharedFinanceSampleWindowController {
  
  if (!gFinanceSampleWindowController) {
    gFinanceSampleWindowController = [[FinanceSampleWindowController alloc] init];
  }  
  return gFinanceSampleWindowController;
}


- (id)init {
  return [self initWithWindowNibName:@"FinanceSampleWindow"];
}

- (void)awakeFromNib {
  // Set the result text fields to have a distinctive color and mono-spaced font
  // to aid in understanding of each query operation.

  [mPortfoliosResultTextField setTextColor:[NSColor darkGrayColor]];
  [mPositionsResultTextField setTextColor:[NSColor darkGrayColor]];
  [mTransactionsResultTextField setTextColor:[NSColor darkGrayColor]];

  NSFont *resultTextFont = [NSFont fontWithName:@"Monaco" size:9];
  [mPortfoliosResultTextField setFont:resultTextFont];
  [mPositionsResultTextField setFont:resultTextFont];
  [mTransactionsResultTextField setFont:resultTextFont];

  [mTransactionDatePicker setDateValue:[NSDate date]];

  [self updateUI];
}

- (void)dealloc {
  [mPortfolioFeed release];
  [mPortfolioFetchError release];
  
  [mPositionFeed release];
  [mPositionFetchError release];
  
  [mTransactionFeed release];
  [mTransactionFetchError release];
  
  [super dealloc];
}

#pragma mark -

- (void)updateUI {
  
  // portfolio list display
  [mPortfoliosTable reloadData]; 
  
  if (mPortfolioFetchesPendingCount > 0) {
    [mPortfoliosProgressIndicator startAnimation:self];  
  } else {
    [mPortfoliosProgressIndicator stopAnimation:self];  
  }
  
  // portfolio fetch result or selected item
  NSString *portfolioResultStr = @"";
  GDataEntryFinancePortfolio *selectedPortfolio = [self selectedPortfolio];
  if (mPortfolioFetchError) {
    portfolioResultStr = [mPortfolioFetchError description];
  } else {
    if (selectedPortfolio) {
      portfolioResultStr = [selectedPortfolio description];
    } 
  }
  [mPortfoliosResultTextField setString:portfolioResultStr];
  
  // enable the create and delete portfolio buttons
  BOOL canInsertPortfolio = ([mPortfolioFeed postLink] != nil);
  BOOL hasPortfolioName = ([[mPortfolioNameField stringValue] length] > 0);
  [mCreatePortfolioButton setEnabled:(canInsertPortfolio && hasPortfolioName)];

  BOOL isEditablePortfolioSelected = ([selectedPortfolio editLink] != nil);
  [mDeletePortfolioButton setEnabled:isEditablePortfolioSelected];
  
  // position list display
  [mPositionsTable reloadData]; 
  
  if (mPositionFetchesPendingCount > 0) {
    [mPositionsProgressIndicator startAnimation:self];  
  } else {
    [mPositionsProgressIndicator stopAnimation:self];  
  }
  
  // position fetch result or selected item
  NSString *positionResultStr = @"";
  if (mPositionFetchError) {
    positionResultStr = [mPositionFetchError description];
  } else {
    GDataEntryFinancePosition *position = [self selectedPosition];
    if (position) {
      positionResultStr = [position description];
    }
  }
  [mPositionsResultTextField setString:positionResultStr];
  
  
  // transaction list display
  [mTransactionsTable reloadData];
  
  if (mTransactionFetchesPendingCount > 0) {
    [mTransactionsProgressIndicator startAnimation:self];  
  } else {
    [mTransactionsProgressIndicator stopAnimation:self];  
  }

  // transaction fetch result or selected item
  NSString *transactionResultStr = @"";
  GDataEntryFinanceTransaction *selectedTransaction = [self selectedTransaction];
  if (mTransactionFetchError) {
    transactionResultStr = [mTransactionFetchError description];
  } else {
    if (selectedTransaction) {
      transactionResultStr = [selectedTransaction description];
    }
  }
  [mTransactionsResultTextField setString:transactionResultStr];

  // enable the create and delete transaction buttons and related controls
  double shares = [mTransactionSharesField doubleValue];
  double price = [mTransactionPriceField doubleValue];
  BOOL hasSharedAndPrice = (shares > 0 && price > 0);
  [mCreateTransactionButton setEnabled:hasSharedAndPrice];

  BOOL isTransactionSelected = (selectedTransaction != nil);
  [mDeleteTransactionButton setEnabled:isTransactionSelected];
}

- (IBAction)loggingCheckboxClicked:(id)sender {
  [GDataHTTPFetcher setIsLoggingEnabled:[sender state]]; 
}

#pragma mark IBActions

- (IBAction)getPortfoliosClicked:(id)sender {
  
  NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  
  NSString *username = [mUsernameField stringValue];
  username = [username stringByTrimmingCharactersInSet:whitespace];
  
  if ([username rangeOfString:@"@"].location == NSNotFound) {
    // if no domain was supplied, add @gmail.com
    username = [username stringByAppendingString:@"@gmail.com"];
  }
  
  [mUsernameField setStringValue:username];

  [self fetchFeedOfPortfolios];
}

- (IBAction)createPortfolioClicked:(id)sender {
  NSString *name = [mPortfolioNameField stringValue];
  if ([name length] > 0) {
    [self createPortfolioWithName:name];
  }
}

- (IBAction)deletePortfolioClicked:(id)sender {
  GDataEntryFinancePortfolio *entry = [self selectedPortfolio];
  if (entry) {
    [self deletePortfolio:entry];
  }
}

- (IBAction)createTransactionClicked:(id)sender {

  NSDate *date = [mTransactionDatePicker dateValue];
  double shares = [mTransactionSharesField doubleValue];
  double price = [mTransactionPriceField doubleValue];
  NSString *type = [mTransactionTypePopup titleOfSelectedItem];

  [self createTransactionWithDate:date
                           shares:shares
                            price:price
                             type:type];
}

- (IBAction)deleteTransactionClicked:(id)sender {
  GDataEntryFinanceTransaction *entry = [self selectedTransaction];
  if (entry) {
    [self deleteTransaction:entry];
  }
}

#pragma mark -

// get a portfolio service object with the current username/password
//
// A "service" object handles networking tasks.  Service objects
// contain user authentication information as well as networking
// state information (such as cookies and the "last modified" date for
// fetched data.)

- (GDataServiceGoogleFinance *)financeService {
  
  static GDataServiceGoogleFinance* service = nil;
  
  if (!service) {
    service = [[GDataServiceGoogleFinance alloc] init];
    
    [service setShouldCacheDatedData:YES];
    [service setServiceShouldFollowNextLinks:YES];
  }

  // username/password may change
  NSString *username = [mUsernameField stringValue];
  NSString *password = [mPasswordField stringValue];
  
  [service setUserCredentialsWithUsername:username
                                 password:password];
  
  return service;
}

// get the portfolio selected in the top list, or nil if none
- (GDataEntryFinancePortfolio *)selectedPortfolio {
  
  NSArray *portfolios = [mPortfolioFeed entries];
  int rowIndex = [mPortfoliosTable selectedRow];
  if ([portfolios count] > 0 && rowIndex > -1) {
    
    GDataEntryFinancePortfolio *portfolio = [portfolios objectAtIndex:rowIndex];
    return portfolio;
  }
  return nil;
}

// get the position selected in the second list, or nil if none
- (GDataEntryFinancePosition *)selectedPosition {
  
  NSArray *positions = [mPositionFeed entries];
  int rowIndex = [mPositionsTable selectedRow];
  if ([positions count] > 0 && rowIndex > -1) {
    
    GDataEntryFinancePosition *position = [positions objectAtIndex:rowIndex];
    return position;
  }
  return nil;
}

// get the cell or list entry selected in the bottom list
- (GDataEntryFinanceTransaction *)selectedTransaction {
  
  NSArray *entries = [mTransactionFeed entries];
  
  int rowIndex = [mTransactionsTable selectedRow];
  if ([entries count] > 0 && rowIndex > -1) {
    
    GDataEntryFinanceTransaction *transaction = [entries objectAtIndex:rowIndex];
    return transaction;
  }
  return nil;
}

#pragma mark Fetch feed of all of the user's portfolios

// begin retrieving the list of the user's portfolios
- (void)fetchFeedOfPortfolios {
  
  [self setPortfolioFeed:nil];
  [self setPortfolioFetchError:nil];    
  
  [self setPositionFeed:nil];
  [self setPositionFetchError:nil];
  
  [self setTransactionFeed:nil];
  [self setTransactionFetchError:nil];
  
  mPortfolioFetchesPendingCount++;
  
  GDataServiceGoogleFinance *service = [self financeService];

  NSURL *feedURL = [NSURL URLWithString:kGDataGoogleFinanceDefaultPortfoliosFeed];
  GDataQueryFinance *query = [GDataQueryFinance financeQueryWithFeedURL:feedURL];
  [query setShouldIncludeReturns:YES];

  [service fetchFeedWithQuery:query
                     delegate:self
            didFinishSelector:@selector(portfolioFeedTicket:finishedWithFeed:error:)];
  
  [self updateUI];
}

// portfolio list fetch callback
- (void)portfolioFeedTicket:(GDataServiceTicket *)ticket
           finishedWithFeed:(GDataFeedFinancePortfolio *)feed
                      error:(NSError *)error {

  [self setPortfolioFeed:feed];
  [self setPortfolioFetchError:error];

  mPortfolioFetchesPendingCount--;
  [self updateUI];
}

#pragma mark Create a portfolio

- (void)createPortfolioWithName:(NSString *)portfolioName {

  NSURL *postURL = [[mPortfolioFeed postLink] URL];
  if (postURL) {

    GDataPortfolioData *portfolioData = [GDataPortfolioData portfolioData];
    [portfolioData setCurrencyCode:@"USD"];

    GDataEntryFinancePortfolio *newEntry = [GDataEntryFinancePortfolio portfolioEntry];
    [newEntry setTitleWithString:portfolioName];
    [newEntry setPortfolioData:portfolioData];

    GDataServiceGoogleFinance *service = [self financeService];
    [service fetchEntryByInsertingEntry:newEntry
                             forFeedURL:postURL
                               delegate:self
                      didFinishSelector:@selector(createPortfolioTicket:finishedWithEntry:error:)];
    mPortfolioFetchesPendingCount++;
    [self updateUI];
  }
}

- (void)createPortfolioTicket:(GDataServiceTicket *)ticket
            finishedWithEntry:(GDataEntryFinancePortfolio *)entry
                        error:(NSError *)error {

  mPortfolioFetchesPendingCount--;

  if (error == nil) {
    // add portfolio succeeded
    NSString *portfolioName = [[entry title] stringValue];

    NSBeginAlertSheet(@"Created portfolio", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Created portfolio \"%@\"",
                      portfolioName);

    // refresh the portfolio list
    [self fetchFeedOfPortfolios];

    // erase the portfolio name so the placeholder text shows again
    [mPortfolioNameField setStringValue:@""];

  } else {
    // add portfolio failed
    NSBeginAlertSheet(@"Create portfolio failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Create portfolio failed: %@", error);

    [self updateUI];
  }
}

#pragma mark Delete a portfolio

// begin retrieving the list of the user's portfolios
- (void)deletePortfolio:(GDataEntryFinancePortfolio *)portfolioEntry {

  GDataServiceGoogleFinance *service = [self financeService];
  GDataServiceTicket *ticket;
  ticket = [service deleteEntry:portfolioEntry
                       delegate:self
              didFinishSelector:@selector(deletePortfolioTicket:finishedWithNil:error:)];

  // hold on to the name of the portfolio being deleted so we can report it
  // when the delete has finished
  [ticket setProperty:[[portfolioEntry title] stringValue]
               forKey:@"portfolio name"];

  mPortfolioFetchesPendingCount++;
  [self updateUI];
}

- (void)deletePortfolioTicket:(GDataServiceTicket *)ticket
              finishedWithNil:(GDataObject *)nilObject
                        error:(NSError *)error {

  mPortfolioFetchesPendingCount--;

  if (error == nil) {
    // delete portfolio succeeded
    NSString *portfolioName = [ticket propertyForKey:@"portfolio name"];

    NSBeginAlertSheet(@"Deleted portfolio", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Deleted portfolio \"%@\"",
                      portfolioName);

    // refresh the portfolio list
    [self fetchFeedOfPortfolios];
  } else {
    // delete portfolio failed
    NSBeginAlertSheet(@"Delete portfolio failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Delete portfolio failed: %@", error);
    [self updateUI];
  }
}

#pragma mark Fetch a portfolio's positions

// for the portfolio selected in the top list, begin retrieving the list of
// positions
- (void)fetchSelectedPortfolio {

  GDataEntryFinancePortfolio *portfolio = [self selectedPortfolio];
  if (portfolio) {

    NSURL *feedURL = [portfolio positionURL];
    if (feedURL) {

      [self setPositionFeed:nil];
      [self setPositionFetchError:nil];
      mPositionFetchesPendingCount++;

      [self setTransactionFeed:nil];
      [self setTransactionFetchError:nil];

      GDataServiceGoogleFinance *service = [self financeService];

      GDataQueryFinance *query = [GDataQueryFinance financeQueryWithFeedURL:feedURL];
      [query setShouldIncludeReturns:YES];

      [service fetchFeedWithQuery:query
                         delegate:self
                didFinishSelector:@selector(positionFeedTicket:finishedWithFeed:error:)];
    }
  }

  [self updateUI];
}

// positions fetch callback
- (void)positionFeedTicket:(GDataServiceTicket *)ticket
          finishedWithFeed:(GDataFeedFinancePosition *)feed
                     error:(NSError *)error {

  [self setPositionFeed:feed];
  [self setPositionFetchError:error];

  mPositionFetchesPendingCount--;

  [self updateUI];
}

#pragma mark Fetch a position's transactions

// for the position selected, fetch the transactions feed

- (void)fetchSelectedPosition {

  GDataEntryFinancePosition *position = [self selectedPosition];
  if (position) {

    NSURL *feedURL = [position transactionURL];
    if (feedURL) {

      [self setTransactionFeed:nil];
      [self setTransactionFetchError:nil];
      mTransactionFetchesPendingCount++;

      [self setTransactionFeed:nil];
      [self setTransactionFetchError:nil];

      GDataServiceGoogleFinance *service = [self financeService];
      [service fetchFeedWithURL:feedURL
                       delegate:self
              didFinishSelector:@selector(transactionFeedTicket:finishedWithFeed:error:)];
      [self updateUI];
    }
  }
}

// entry list fetch callbacks
- (void)transactionFeedTicket:(GDataServiceTicket *)ticket
             finishedWithFeed:(GDataFeedFinanceTransaction *)feed
                        error:(NSError *)error {

  [self setTransactionFeed:feed];
  [self setTransactionFetchError:error];

  mTransactionFetchesPendingCount--;

  [self updateUI];
}

#pragma mark Create a transaction

- (void)createTransactionWithDate:(NSDate *)date
                           shares:(double)shares
                            price:(double)price
                             type:(NSString *)type {

  NSURL *postURL = [[mTransactionFeed postLink] URL];
  if (postURL) {

    GDataMoney *money;
    money = [GDataMoney moneyWithAmount:[NSNumber numberWithDouble:price]
                           currencyCode:@"USD"];
    GDataPrice *price = [GDataPrice moneyGroupWithMoney:money];

    GDataFinanceTransactionData *transData;
    transData = [GDataFinanceTransactionData transactionDataWithType:type];

    [transData setDate:[GDataDateTime dateTimeWithDate:date
                                              timeZone:[NSTimeZone defaultTimeZone]]];
    [transData setShares:[NSNumber numberWithDouble:shares]];
    [transData setPrice:price];

    GDataEntryFinanceTransaction *newEntry;
    newEntry = [GDataEntryFinanceTransaction transactionEntry];
    [newEntry setTransactionData:transData];

    GDataServiceGoogleFinance *service = [self financeService];
    [service fetchEntryByInsertingEntry:newEntry
                             forFeedURL:postURL
                               delegate:self
                      didFinishSelector:@selector(createTransactionTicket:finishedWithEntry:error:)];
    mTransactionFetchesPendingCount++;
    [self updateUI];
  }
}

- (void)createTransactionTicket:(GDataServiceTicket *)ticket
              finishedWithEntry:(GDataEntryFinanceTransaction *)entry
                          error:(NSError *)error {

  mTransactionFetchesPendingCount--;

  if (error == nil) {
    // add transaction succeeded
    NSDate *date = [[[entry transactionData] date] date];

    NSBeginAlertSheet(@"Created transaction", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Created transaction dated \"%@\"",
                      date);

    // refresh the list of transactions
    [self fetchSelectedPosition];

    // erase the share and price numbers in the text field so the
    // placeholder text shows again
    [mTransactionSharesField setStringValue:@""];
    [mTransactionPriceField setStringValue:@""];

  } else {
    // add transaction failed
    NSBeginAlertSheet(@"Create transaction failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Create transaction failed: %@", error);

    [self updateUI];
  }
}

#pragma mark Delete a transaction

// delete a transaction
- (void)deleteTransaction:(GDataEntryFinanceTransaction *)transactionEntry {

  GDataServiceGoogleFinance *service = [self financeService];
  GDataServiceTicket *ticket;
  ticket = [service deleteEntry:transactionEntry
                       delegate:self
              didFinishSelector:@selector(deleteTransactionTicket:finishedWithNil:error:)];

  // hold on to the date of the transaction being deleted so we can report it
  // when the delete has finished
  NSDate *date = [[[transactionEntry transactionData] date] date];
  [ticket setProperty:date
               forKey:@"transaction date"];

  mTransactionFetchesPendingCount++;
  [self updateUI];
}

- (void)deleteTransactionTicket:(GDataServiceTicket *)ticket
                finishedWithNil:(GDataObject *)nilObject
                          error:(NSError *)error {

  mTransactionFetchesPendingCount--;

  if (error == nil) {

    NSString *date = [ticket propertyForKey:@"transaction date"];

    NSBeginAlertSheet(@"Deleted transaction", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Deleted transaction \"%@\"",
                      date);

    // refresh the list of transactions
    [self fetchSelectedPosition];

  } else {
    // delete portfolio failed
    NSBeginAlertSheet(@"Delete transaction failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Delete transaction failed: %@", error);
    [self updateUI];
  }
}

#pragma mark TableView delegate methods
//
// table view delegate methods
//

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  id obj = [notification object];
  if (obj == mPortfoliosTable) {

    // the user clicked on a portfolio, so fetch its positions
    [self fetchSelectedPortfolio];
    
  } else if (obj == mPositionsTable) {
    
    // the user clicked on a position, so fetch its transactions
    [self fetchSelectedPosition];
    
  } else {
    // the user clicked on a transaction
    [self updateUI];
  }
}

// table view data source methods
- (int)numberOfRowsInTableView:(NSTableView *)tableView {
  
  if (tableView == mPortfoliosTable) {
    
    return [[mPortfolioFeed entries] count];
    
  } else if (tableView == mPositionsTable) {
    
    return [[mPositionFeed entries] count];
    
  } else {
    
    return [[mTransactionFeed entries] count]; 
  }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
  
  if (tableView == mPortfoliosTable) {
    
    // get the portfolio entry's title
    GDataEntryFinancePortfolio *entry = [[mPortfolioFeed entries] objectAtIndex:row];
    return [[entry title] stringValue];
    
  } else if (tableView == mPositionsTable) {
    
    // get the position entry's title
    GDataEntryFinancePosition *entry = [[mPositionFeed entries] objectAtIndex:row];
    return [[entry title] stringValue];
    
  } else {

    // get the transaction entry's title
    GDataEntryFinanceTransaction *entry = [[mTransactionFeed entries] objectAtIndex:row];
    return [[entry title] stringValue];    
  }  
}

#pragma mark Text Field Delegate Methods

- (void)controlTextDidChange:(NSNotification *)note {
  // enable and disable buttons
  [self updateUI];
}

#pragma mark Setters and Getters

- (GDataFeedFinancePortfolio *)portfolioFeed {
  return mPortfolioFeed; 
}

- (void)setPortfolioFeed:(GDataFeedFinancePortfolio *)feed {
  [mPortfolioFeed autorelease];
  mPortfolioFeed = [feed retain];
}

- (NSError *)portfolioFetchError {
  return mPortfolioFetchError; 
}

- (void)setPortfolioFetchError:(NSError *)error {
  [mPortfolioFetchError release];
  mPortfolioFetchError = [error retain];
}


- (GDataFeedFinancePosition *)positionFeed {
  return mPositionFeed; 
}

- (void)setPositionFeed:(GDataFeedFinancePosition *)feed {
  [mPositionFeed autorelease];
  mPositionFeed = [feed retain];
}

- (NSError *)positionFetchError {
  return mPositionFetchError; 
}

- (void)setPositionFetchError:(NSError *)error {
  [mPositionFetchError release];
  mPositionFetchError = [error retain];
}


- (GDataFeedBase *)transactionFeed {
  return mTransactionFeed; 
}

- (void)setTransactionFeed:(GDataFeedBase *)feed {
  [mTransactionFeed autorelease];
  mTransactionFeed = [feed retain];
}

- (NSError *)transactionFetchError {
  return mTransactionFetchError; 
}

- (void)setTransactionFetchError:(NSError *)error {
  [mTransactionFetchError release];
  mTransactionFetchError = [error retain];
}

@end
