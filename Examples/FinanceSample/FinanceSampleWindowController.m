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
  
  if (mIsPortfolioFetchPending) {
    [mPortfoliosProgressIndicator startAnimation:self];  
  } else {
    [mPortfoliosProgressIndicator stopAnimation:self];  
  }
  
  // portfolio fetch result or selected item
  NSString *portfolioResultStr = @"";
  if (mPortfolioFetchError) {
    portfolioResultStr = [mPortfolioFetchError description];
  } else {
    GDataEntryFinancePortfolio *portfolio = [self selectedPortfolio];
    if (portfolio) {
      portfolioResultStr = [portfolio description];
    } 
  }
  [mPortfoliosResultTextField setString:portfolioResultStr];
  
  
  // position list display
  [mPositionsTable reloadData]; 
  
  if (mIsPositionFetchPending) {
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
  
  if (mIsTransactionFetchPending) {
    [mTransactionsProgressIndicator startAnimation:self];  
  } else {
    [mTransactionsProgressIndicator stopAnimation:self];  
  }
  
  // transaction fetch result or selected item
  NSString *transactionResultStr = @"";
  if (mTransactionFetchError) {
    transactionResultStr = [mTransactionFetchError description];
  } else {
    GDataEntryFinanceTransaction *transaction = [self selectedTransaction];
    if (transaction) {
      transactionResultStr = [transaction description];
    }
  }
  [mTransactionsResultTextField setString:transactionResultStr];  
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

- (IBAction)feedSegmentClicked:(id)sender {
  // user switched between cell and list feed
  [self fetchSelectedPosition];
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

    // iPhone apps will typically disable caching dated data or will call
    // clearLastModifiedDates after done fetching to avoid wasting
    // memory.
  }

  // username/password may change
  NSString *username = [mUsernameField stringValue];
  NSString *password = [mPasswordField stringValue];
  
  [service setUserAgent:@"MyCompany-SampleFinanceApp-1.0"]; // set this to yourName-appName-appVersion
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
  
  mIsPortfolioFetchPending = YES;
  
  GDataServiceGoogleFinance *service = [self financeService];
  NSURL *feedURL = [NSURL URLWithString:kGDataGoogleFinanceDefaultPortfoliosFeed];
  [service fetchFeedWithURL:feedURL
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

  mIsPortfolioFetchPending = NO;
  [self updateUI];
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
      mIsPositionFetchPending = YES;

      [self setTransactionFeed:nil];
      [self setTransactionFetchError:nil];

      GDataServiceGoogleFinance *service = [self financeService];
      [service fetchFeedWithURL:feedURL
                       delegate:self
              didFinishSelector:@selector(positionFeedTicket:finishedWithFeed:error:)];
      [self updateUI];
    }
  }
}

// positions fetch callback
- (void)positionFeedTicket:(GDataServiceTicket *)ticket
          finishedWithFeed:(GDataFeedFinancePosition *)feed
                     error:(NSError *)error {

  [self setPositionFeed:feed];
  [self setPositionFetchError:error];

  mIsPositionFetchPending = NO;

  [self updateUI];
}

#pragma mark Fetch a position's entries

// for the position selected, fetch the transactions feed

- (void)fetchSelectedPosition {

  GDataEntryFinancePosition *position = [self selectedPosition];
  if (position) {

    NSURL *feedURL = [position transactionURL];
    if (feedURL) {

      [self setTransactionFeed:nil];
      [self setTransactionFetchError:nil];
      mIsTransactionFetchPending = YES;

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

  mIsTransactionFetchPending = NO;

  [self updateUI];
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
