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
//  AnalyticsSampleWindowController.m
//

#import "AnalyticsSampleWindowController.h"

@interface AnalyticsSampleWindowController (PrivateMethods)
- (void)updateUI;

- (void)fetchFeedOfAccounts;
- (void)fetchSelectedAccount;
- (void)fetchSelectedAnalyticsData;

- (GDataServiceGoogleAnalytics *)analyticsService;
- (GDataEntryAnalyticsAccount *)selectedAccount;
- (GDataEntryAnalyticsData *)selectedAnalyticsData;

- (NSString *)itemListForPopup:(NSPopUpButton *)popup;
- (NSString *)analyticsDateStringForDatePicker:(NSDatePicker *)picker;

- (GDataFeedAnalyticsAccount *)accountFeed;
- (void)setAccountFeed:(GDataFeedAnalyticsAccount *)feed;
- (NSError *)accountFetchError;
- (void)setAccountFetchError:(NSError *)error;

- (GDataFeedAnalyticsData *)analyticsDataFeed;
- (void)setAnalyticsDataFeed:(GDataFeedAnalyticsData *)feed;
- (NSError *)analyticsDataFetchError;
- (void)setAnalyticsDataFetchError:(NSError *)error;
@end

@implementation AnalyticsSampleWindowController

static AnalyticsSampleWindowController* gWindowController = nil;

+ (AnalyticsSampleWindowController *)sharedAnalyticsSampleWindowController {

  if (!gWindowController) {
    gWindowController = [[AnalyticsSampleWindowController alloc] init];
  }
  return gWindowController;
}

- (id)init {
  return [self initWithWindowNibName:@"AnalyticsSampleWindow"];
}

// dimensions and metrics, from
// http://code.google.com/apis/analytics/docs/gdata/gdataReferenceDimensionsMetrics.html

- (NSArray *)dimensionNames {
  return [NSArray arrayWithObjects:
          @"ga:browser", @"ga:browserVersion", @"ga:city",
          @"ga:connectionSpeed", @"ga:continent", @"ga:visitCount",
          @"ga:country", @"ga:date", @"ga:day", @"ga:daysSinceLastVisit",
          @"ga:flashVersion", @"ga:hostname", @"ga:hour", @"ga:javaEnabled",
          @"ga:language", @"ga:latitude", @"ga:longitude", @"ga:month",
          @"ga:networkDomain", @"ga:networkLocation", @"ga:pageDepth",
          @"ga:operatingSystem", @"ga:operatingSystemVersion", @"ga:region",
          @"ga:screenColors", @"ga:screenResolution", @"ga:subContinent",
          @"ga:userDefinedValue", @"ga:visitLength", @"ga:visitorType",
          @"ga:week", @"ga:year", @"ga:adContent", @"ga:adGroup", @"ga:adSlot",
          @"ga:adSlotPosition", @"ga:campaign", @"ga:keyword", @"ga:medium",
          @"ga:referralPath", @"ga:source", @"ga:exitPagePath",
          @"ga:landingPagePath",  @"ga:secondPagePath", @"ga:pagePath",
          @"ga:pageTitle", @"ga:affiliation", @"ga:daysToTransaction",
          @"ga:productCategory", @"ga:productName", @"ga:productSku",
          @"ga:transactionId", @"ga:searchCategory",
          @"ga:searchDestinationPage", @"ga:searchKeyword",
          @"ga:searchKeywordRefinement", @"ga:searchStartPage",
          @"ga:searchUsed", @"ga:nextPagePath", @"ga:previousPagePath",
          @"ga:eventCategory", @"ga:eventAction", @"ga:eventLabel", nil];
}

- (NSArray *)metricNames {
  return [NSArray arrayWithObjects:
          @"ga:adClicks", @"ga:adCost", @"ga:bounces ", @"ga:CPC", @"ga:CPM",
          @"ga:CTR", @"ga:entrances", @"ga:exits", @"ga:goal1Completions",
          @"ga:goal1Starts", @"ga:goal1Value", @"ga:goal2Completions",
          @"ga:goal2Starts", @"ga:goal2Value", @"ga:goal3Completions",
          @"ga:goal3Starts", @"ga:goal3Value", @"ga:goal4Completions",
          @"ga:goal4Starts", @"ga:goal4Value", @"ga:goalCompletionsAll",
          @"ga:goalStartsAll", @"ga:goalValueAll", @"ga:impressions",
          @"ga:itemQuantity", @"ga:itemRevenue", @"ga:newVisits",
          @"ga:pageviews", @"ga:searchDepth", @"ga:searchDuration",
          @"ga:searchExits", @"ga:searchRefinements", @"ga:searchUniques",
          @"ga:searchVisits", @"ga:timeOnPage", @"ga:timeOnSite",
          @"ga:transactionRevenue", @"ga:transactions",
          @"ga:transactionShipping", @"ga:transactionTax",
          @"ga:uniquePageviews", @"ga:uniquePurchases",
          @"ga:visitors", @"ga:visits",
          @"ga:totalEvents", @"ga:uniqueEvents", @"ga:eventValue", nil];
}

- (void)awakeFromNib {
  // Set the result text fields to have a distinctive color and mono-spaced font
  // to aid in understanding of each query operation.

  [mAccountsResultTextField setTextColor:[NSColor darkGrayColor]];
  [mAnalyticsDataResultTextField setTextColor:[NSColor darkGrayColor]];

  NSFont *resultTextFont = [NSFont fontWithName:@"Monaco" size:9];
  [mAccountsResultTextField setFont:resultTextFont];
  [mAnalyticsDataResultTextField setFont:resultTextFont];

  // set the date pickers to run from last week to today
  NSTimeInterval aWeekAgo = -7 * 24 * 60 * 60;
  [mStartDatePicker setDateValue:[NSDate dateWithTimeIntervalSinceNow:aWeekAgo]];
  [mEndDatePicker setDateValue:[NSDate date]];

  // load the pop-ups for dimensions and metrics, and check one item for each
  [mDimensionsPopup addItemsWithTitles:[self dimensionNames]];
  [[mDimensionsPopup itemWithTitle:@"ga:country"] setState:NSOnState];

  [mMetricsPopup addItemsWithTitles:[self metricNames]];
  [[mMetricsPopup itemWithTitle:@"ga:pageviews"] setState:NSOnState];

  [self updateUI];
}

- (void)dealloc {
  [mAccountFeed release];
  [mAccountFetchError release];

  [mAnalyticsDataFeed release];
  [mAnalyticsDataFetchError release];

  [super dealloc];
}

#pragma mark -

- (void)updateUI {

  // account list display
  [mAccountsTable reloadData];

  if (mIsAccountFetchPending) {
    [mAccountsProgressIndicator startAnimation:self];
  } else {
    [mAccountsProgressIndicator stopAnimation:self];
  }

  // account fetch result or selected item
  NSString *accountResultStr = @"";
  if (mAccountFetchError) {
    accountResultStr = [mAccountFetchError description];
  } else {
    GDataEntryAnalyticsAccount *account = [self selectedAccount];
    if (account) {
      accountResultStr = [account description];
    }
  }
  [mAccountsResultTextField setString:accountResultStr];


  // analyticsData list display
  [mAnalyticsDataTable reloadData];

  if (mIsAnalyticsDataFetchPending) {
    [mAnalyticsDataProgressIndicator startAnimation:self];
  } else {
    [mAnalyticsDataProgressIndicator stopAnimation:self];
  }

  // analyticsData fetch result or selected item
  NSString *analyticsDataResultStr = @"";
  if (mAnalyticsDataFetchError) {
    analyticsDataResultStr = [mAnalyticsDataFetchError description];
  } else {
    GDataEntryAnalyticsData *analyticsData = [self selectedAnalyticsData];
    if (analyticsData) {
      analyticsDataResultStr = [analyticsData description];
    }
  }
  [mAnalyticsDataResultTextField setString:analyticsDataResultStr];


  // the reload button is useful after the user changes dates or checkboxes
  // for metrics and dimensions
  GDataEntryAnalyticsAccount *selectedAccount = [self selectedAccount];
  [mReloadButton setEnabled:(selectedAccount != nil)];


  // update the comma-separated lists of dimensions and metrics to match the
  // checked items in the pop-up menus
  NSString *dimensions = [self itemListForPopup:mDimensionsPopup];
  [mDimensionsField setStringValue:dimensions];

  NSString *metrics = [self itemListForPopup:mMetricsPopup];
  [mMetricsField setStringValue:metrics];
}

- (IBAction)loggingCheckboxClicked:(id)sender {
  [GDataHTTPFetcher setIsLoggingEnabled:[sender state]];
}

#pragma mark IBActions

- (IBAction)getAccountsClicked:(id)sender {

  NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];

  NSString *username = [mUsernameField stringValue];
  username = [username stringByTrimmingCharactersInSet:whitespace];

  if ([username rangeOfString:@"@"].location == NSNotFound) {
    // if no domain was supplied, add @gmail.com
    username = [username stringByAppendingString:@"@gmail.com"];
  }

  [mUsernameField setStringValue:username];

  [self fetchFeedOfAccounts];
}

#pragma mark -

// get a account service object with the current username/password
//
// A "service" object handles networking tasks.  Service objects
// contain user authentication information as well as networking
// state information (such as cookies and the "last modified" date for
// fetched data.)

- (GDataServiceGoogleAnalytics *)analyticsService {

  static GDataServiceGoogleAnalytics* service = nil;

  if (!service) {
    service = [[GDataServiceGoogleAnalytics alloc] init];

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

// get the account selected in the top list, or nil if none
- (GDataEntryAnalyticsAccount *)selectedAccount {

  NSArray *accounts = [mAccountFeed entries];
  int rowIndex = [mAccountsTable selectedRow];
  if ([accounts count] > 0 && rowIndex > -1) {

    GDataEntryAnalyticsAccount *account = [accounts objectAtIndex:rowIndex];
    return account;
  }
  return nil;
}

// get the analyticsData selected in the second list, or nil if none
- (GDataEntryAnalyticsData *)selectedAnalyticsData {

  NSArray *entries = [mAnalyticsDataFeed entries];
  int rowIndex = [mAnalyticsDataTable selectedRow];
  if ([entries count] > 0 && rowIndex > -1) {

    GDataEntryAnalyticsData *analyticsData = [entries objectAtIndex:rowIndex];
    return analyticsData;
  }
  return nil;
}

- (IBAction)refreshAccountData:(id)sender {
  [self fetchSelectedAccount];
}

#pragma mark Fetch feed of all of the user's accounts

// begin retrieving the list of the user's accounts
- (void)fetchFeedOfAccounts {

  [self setAccountFeed:nil];
  [self setAccountFetchError:nil];

  [self setAnalyticsDataFeed:nil];
  [self setAnalyticsDataFetchError:nil];

  mIsAccountFetchPending = YES;

  GDataServiceGoogleAnalytics *service = [self analyticsService];
  NSURL *feedURL = [NSURL URLWithString:kGDataGoogleAnalyticsDefaultAccountFeed];
  [service fetchFeedWithURL:feedURL
                  feedClass:[GDataFeedAnalyticsAccount class]
                   delegate:self
          didFinishSelector:@selector(accountFeedTicket:finishedWithFeed:error:)];

  [self updateUI];
}

// account list fetch callback
- (void)accountFeedTicket:(GDataServiceTicket *)ticket
         finishedWithFeed:(GDataFeedAnalyticsAccount *)feed
                    error:(NSError *)error {

  [self setAccountFeed:feed];
  [self setAccountFetchError:error];

  mIsAccountFetchPending = NO;
  [self updateUI];
}

#pragma mark Fetch a account's analyticsData

// for the account selected in the top list, begin retrieving the feed of
// analytics data

- (void)fetchSelectedAccount {

  GDataEntryAnalyticsAccount *accountEntry = [self selectedAccount];
  if (accountEntry != nil) {

    [self setAnalyticsDataFeed:nil];
    [self setAnalyticsDataFetchError:nil];
    mIsAnalyticsDataFetchPending = YES;

    NSString *tableID = [accountEntry tableID];

    NSString *startDateStr, *endDateStr;
    startDateStr = [self analyticsDateStringForDatePicker:mStartDatePicker];
    endDateStr = [self analyticsDateStringForDatePicker:mEndDatePicker];

    GDataQueryAnalytics *query;
    query = [GDataQueryAnalytics analyticsDataQueryWithTableID:tableID
                                               startDateString:startDateStr
                                                 endDateString:endDateStr];

    NSString *dimensions = [self itemListForPopup:mDimensionsPopup];
    [query setDimensions:dimensions];

    NSString *metrics = [self itemListForPopup:mMetricsPopup];
    [query setMetrics:metrics];

    GDataServiceGoogleAnalytics *service = [self analyticsService];
    [service fetchFeedWithQuery:query
                      feedClass:[GDataFeedAnalyticsData class]
                       delegate:self
              didFinishSelector:@selector(analyticsDataFeedTicket:finishedWithFeed:error:)];
    [self updateUI];
  }
}

// analytics data fetch callback
- (void)analyticsDataFeedTicket:(GDataServiceTicket *)ticket
               finishedWithFeed:(GDataFeedAnalyticsData *)feed
                          error:(NSError *)error {

  [self setAnalyticsDataFeed:feed];
  [self setAnalyticsDataFetchError:error];

  mIsAnalyticsDataFetchPending = NO;

  [self updateUI];
}

#pragma mark TableView delegate methods
//
// table view delegate methods
//

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  id obj = [notification object];
  if (obj == mAccountsTable) {
    // the user clicked on an account, so fetch its analytics data
    [self fetchSelectedAccount];
  } else {
    // the user clicked on an analytics data entry
    [self updateUI];
  }
}

// table view data source methods
- (int)numberOfRowsInTableView:(NSTableView *)tableView {
  if (tableView == mAccountsTable) {
    return [[mAccountFeed entries] count];
  } else  {
    return [[mAnalyticsDataFeed entries] count];
  }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
  if (tableView == mAccountsTable) {
    // get the account entry's title
    GDataEntryAnalyticsAccount *entry;
    entry = [[mAccountFeed entries] objectAtIndex:row];

    return [[entry title] stringValue];
  } else {
    // get the analyticsData entry's title
    GDataEntryAnalyticsData *entry;
    entry = [[mAnalyticsDataFeed entries] objectAtIndex:row];

    return [[entry title] stringValue];
  }
}

#pragma mark Menu item actions

- (IBAction)menuItemClicked:(id)sender {
  // toggle the checkmark for the selected pop-up menu item
  NSMenuItem *item = [sender selectedItem];
  int oldState = [item state];
  [item setState:(!oldState)];

  [self updateUI];
}

#pragma mark UI-related utilities

// return a date string like @"2001-03-15" for the date picker
- (NSString *)analyticsDateStringForDatePicker:(NSDatePicker *)picker {
  NSDate *date = [picker dateValue];

  unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit
                       | NSDayCalendarUnit;
  NSCalendar *calendar = [NSCalendar currentCalendar];

  NSDateComponents *dateComponents = [calendar components:unitFlags
                                                 fromDate:date];
  NSString *dateString = [NSString stringWithFormat:@"%04u-%02u-%02u",
                          [dateComponents year], [dateComponents month],
                          [dateComponents day]];
  return dateString;
}

// return a comma-separated list string like @"ga:country,ga:networkDomain"
- (NSString *)itemListForPopup:(NSPopUpButton *)popup {

  NSArray *checkedItems = [GDataUtilities objectsFromArray:[popup itemArray]
                                                 withValue:[NSNumber numberWithInt:NSOnState]
                                                forKeyPath:@"state"];

  NSArray *titles = [checkedItems valueForKey:@"title"];
  NSString *commaSeparatedList = [titles componentsJoinedByString:@","];
  return commaSeparatedList;
}

#pragma mark Setters and Getters

- (GDataFeedAnalyticsAccount *)accountFeed {
  return mAccountFeed;
}

- (void)setAccountFeed:(GDataFeedAnalyticsAccount *)feed {
  [mAccountFeed autorelease];
  mAccountFeed = [feed retain];
}

- (NSError *)accountFetchError {
  return mAccountFetchError;
}

- (void)setAccountFetchError:(NSError *)error {
  [mAccountFetchError release];
  mAccountFetchError = [error retain];
}


- (GDataFeedAnalyticsData *)analyticsDataFeed {
  return mAnalyticsDataFeed;
}

- (void)setAnalyticsDataFeed:(GDataFeedAnalyticsData *)feed {
  [mAnalyticsDataFeed autorelease];
  mAnalyticsDataFeed = [feed retain];
}

- (NSError *)analyticsDataFetchError {
  return mAnalyticsDataFetchError;
}

- (void)setAnalyticsDataFetchError:(NSError *)error {
  [mAnalyticsDataFetchError release];
  mAnalyticsDataFetchError = [error retain];
}

@end
