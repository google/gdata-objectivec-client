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
//  HealthSampleWindowController.m
//

#import "HealthSampleWindowController.h"

@interface HealthSampleWindowController (PrivateMethods)
- (void)updateUI;
- (void)updateServiceClass;

- (void)fetchFeedOfProfileList;
- (void)fetchSelectedProfile;

- (GDataServiceGoogleHealth *)healthService;
- (GDataEntryBase *)selectedProfileListEntry;
- (GDataEntryHealthProfile *)selectedProfile;
- (GDataEntryHealthRegister *)selectedRegister;

- (GDataFeedBase *)profileListFeed;
- (void)setProfileListFeed:(GDataFeedBase *)feed;
- (NSError *)profileListFetchError;
- (void)setProfileListFetchError:(NSError *)error;

- (GDataFeedHealthProfile *)profileFeed;
- (void)setProfileFeed:(GDataFeedHealthProfile *)feed;
- (NSError *)profileFetchError;
- (void)setProfileFetchError:(NSError *)error;

- (GDataFeedHealthRegister *)registerFeed;
- (void)setRegisterFeed:(GDataFeedHealthRegister *)feed;
- (NSError *)registerFetchError;
- (void)setRegisterFetchError:(NSError *)error;
@end

@implementation HealthSampleWindowController

static HealthSampleWindowController* gWindowController = nil;

+ (HealthSampleWindowController *)sharedHealthSampleWindowController {

  if (!gWindowController) {
    gWindowController = [[HealthSampleWindowController alloc] init];
  }
  return gWindowController;
}

- (id)init {
  return [self initWithWindowNibName:@"HealthSampleWindow"];
}

- (void)awakeFromNib {
  // Set the result text fields to have a distinctive color and mono-spaced font
  // to aid in understanding of each query operation.

  [mProfileListResultTextField setTextColor:[NSColor darkGrayColor]];
  [mProfileResultTextField setTextColor:[NSColor darkGrayColor]];

  NSFont *resultTextFont = [NSFont fontWithName:@"Monaco" size:9];
  [mProfileListResultTextField setFont:resultTextFont];
  [mProfileResultTextField setFont:resultTextFont];

  // initialize the service class to match the selected radio button
  // (sandbox or production)
  [self updateServiceClass];

  [self updateUI];
}

- (void)dealloc {
  [mProfileListFeed release];
  [mProfileListFetchError release];

  [mProfileFeed release];
  [mProfileFetchError release];

  [mRegisterFeed release];
  [mRegisterFetchError release];

  [super dealloc];
}

#pragma mark -

- (BOOL)isProfileSegmentSelected {
  // index 0 is profile, index 1 is register (notices)
  int index = [mEntrySegmentedControl selectedSegment];
  return (index == 0);
}

- (BOOL)isCCRSegmentSelected {
  // index 0 is CCR, index 1 is metadata
  int index = [mXMLSegmentedControl selectedSegment];
  return (index == 0);
}

- (void)updateUI {

  // profile list display
  [mProfileListTable reloadData];

  if (mIsProfileListFetchPending) {
    [mProfileListProgressIndicator startAnimation:self];
  } else {
    [mProfileListProgressIndicator stopAnimation:self];
  }

  // profileList fetch result or selected item
  NSString *profileListResultStr = @"";
  if (mProfileListFetchError) {
    profileListResultStr = [mProfileListFetchError description];
  } else {
    GDataEntryBase *profileList = [self selectedProfileListEntry];
    if (profileList) {
      profileListResultStr = [profileList description];
    }
  }
  [mProfileListResultTextField setString:profileListResultStr];


  // profile/register list display
  [mProfileTable reloadData];

  if (mIsProfileFetchPending || mIsRegisterFetchPending) {
    [mProfileProgressIndicator startAnimation:self];
  } else {
    [mProfileProgressIndicator stopAnimation:self];
  }

  NSString *xmlString = @"";

  // profile fetch result or selected item
  BOOL isProfileSegmentSelected = [self isProfileSegmentSelected];
  [mXMLSegmentedControl setEnabled:isProfileSegmentSelected];

  NSString *resultStr = @"";
  if (isProfileSegmentSelected) {
    // profile feed displayed
    if (mProfileFetchError) {
      resultStr = [mProfileFetchError description];
    } else {
      GDataEntryHealthProfile *profile = [self selectedProfile];
      if (profile) {
        resultStr = [profile description];

        // also show the xml for the profile entry's CCR or metadata
        GDataObject *xmlObject;
        if ([self isCCRSegmentSelected]) {
          xmlObject = [profile continuityOfCareRecord];
        } else {
          xmlObject = [profile profileMetaData];
        }

        NSXMLElement *element = [xmlObject XMLElement];
        xmlString = [element XMLStringWithOptions:NSXMLNodePrettyPrint];
      }
    }
  } else {
    // register (notices) feed displayed
    if (mRegisterFetchError) {
      resultStr = [mRegisterFetchError description];
    } else {
      GDataEntryHealthRegister *registerEntry = [self selectedRegister];
      if (registerEntry) {
        resultStr = [registerEntry description];
      }
    }
  }

  [mXMLField setString:xmlString];

  [mProfileResultTextField setString:resultStr];
}

- (void)updateServiceClass {
  NSButtonCell *cell = [mRadioMatrix selectedCell];
  int tag = [cell tag];

  if (tag == 1) {
    mServiceClass = [GDataServiceGoogleHealthSandbox class];
  } else {
    mServiceClass = [GDataServiceGoogleHealth class];
  }
}

- (IBAction)loggingCheckboxClicked:(id)sender {
  [GDataHTTPFetcher setIsLoggingEnabled:[sender state]];
}

#pragma mark IBActions

- (IBAction)getProfileListClicked:(id)sender {

  NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];

  NSString *username = [mUsernameField stringValue];
  username = [username stringByTrimmingCharactersInSet:whitespace];

  if ([username rangeOfString:@"@"].location == NSNotFound) {
    // if no domain was supplied, add @gmail.com
    username = [username stringByAppendingString:@"@gmail.com"];
  }

  [mUsernameField setStringValue:username];

  [self fetchFeedOfProfileList];
}

- (IBAction)entrySegmentClicked:(id)sender {
  // fetch the profile or the register (notices)
  [self fetchSelectedProfile];
}

- (IBAction)xmlSegmentClicked:(id)sender {
  // show the CCR or profileMetadata XML
  [self updateUI];
}

- (IBAction)radioButtonClicked:(id)sender {
  // user changed to or from the sandbox service
  [self updateServiceClass];

  [self fetchFeedOfProfileList];
}

#pragma mark -

// get a service object with the current username/password
//
// A "service" object handles networking tasks.  Service objects
// contain user authentication information as well as networking
// state information (such as cookies and the "last modified" date for
// fetched data.)
//
// For Google Health, there are separate classes for the testing (sandbox)
// service and the production service

- (GDataServiceGoogleHealth *)healthService {

  static GDataServiceGoogleHealth* service = nil;

  // the service class may have changed if the user clicked the sandbox
  // radio buttons
  if (service == nil || ![service isMemberOfClass:mServiceClass]) {

    // allocate the currently-selected service class
    [service release];
    service = [[mServiceClass alloc] init];

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

// get the profileList selected in the top list, or nil if none
- (GDataEntryBase *)selectedProfileListEntry {

  NSArray *profileLists = [mProfileListFeed entries];
  int rowIndex = [mProfileListTable selectedRow];
  if ([profileLists count] > 0 && rowIndex > -1) {

    GDataEntryBase *profileList = [profileLists objectAtIndex:rowIndex];
    return profileList;
  }
  return nil;
}

// get the profile selected in the second list, or nil if none
- (GDataEntryHealthProfile *)selectedProfile {

  if (![self isProfileSegmentSelected]) return nil;

  NSArray *entries = [mProfileFeed entries];
  int rowIndex = [mProfileTable selectedRow];
  if ([entries count] > 0 && rowIndex > -1) {

    GDataEntryHealthProfile *profile = [entries objectAtIndex:rowIndex];
    return profile;
  }
  return nil;
}

// get the register selected in the second list, or nil if none
- (GDataEntryHealthRegister *)selectedRegister {

  if ([self isProfileSegmentSelected]) return nil;

  NSArray *entries = [mRegisterFeed entries];
  int rowIndex = [mProfileTable selectedRow];
  if ([entries count] > 0 && rowIndex > -1) {

    GDataEntryHealthRegister *registerEntry = [entries objectAtIndex:rowIndex];
    return registerEntry;
  }
  return nil;
}


#pragma mark Fetch feed of all of the user's profileLists

// begin retrieving the list of the user's profileLists
- (void)fetchFeedOfProfileList {

  [self setProfileListFeed:nil];
  [self setProfileListFetchError:nil];

  [self setProfileFeed:nil];
  [self setProfileFetchError:nil];

  [self setRegisterFeed:nil];
  [self setRegisterFetchError:nil];

  mIsProfileListFetchPending = YES;

  GDataServiceGoogleHealth *service = [self healthService];
  NSURL *feedURL = [mServiceClass profileListFeedURL];
  [service fetchFeedWithURL:feedURL
                   delegate:self
          didFinishSelector:@selector(profileListFeedTicket:finishedWithFeed:error:)];

  [self updateUI];
}

// profile list fetch callback
- (void)profileListFeedTicket:(GDataServiceTicket *)ticket
             finishedWithFeed:(GDataFeedBase *)feed
                        error:(NSError *)error {

  [self setProfileListFeed:feed];
  [self setProfileListFetchError:error];

  mIsProfileListFetchPending = NO;
  [self updateUI];
}

#pragma mark Fetch a profileList's profile

// for the profileList selected in the top list, begin retrieving the feed of
// analytics data

- (void)fetchSelectedProfile {

  GDataEntryBase *profileListEntry = [self selectedProfileListEntry];
  if (profileListEntry != nil) {

    [self setProfileFeed:nil];
    [self setProfileFetchError:nil];

    [self setRegisterFeed:nil];
    [self setRegisterFetchError:nil];

    NSString *profileID = [[profileListEntry content] stringValue];

    GDataServiceGoogleHealth *service = [self healthService];

    NSURL *feedURL;
    if ([self isProfileSegmentSelected]) {
      // fetch a profile feed
      feedURL = [mServiceClass profileFeedURLForProfileID:profileID];
      [service fetchFeedWithURL:feedURL
                       delegate:self
              didFinishSelector:@selector(profileFeedTicket:finishedWithFeed:error:)];
      mIsProfileFetchPending = YES;
    } else {
      // fetch notices in the register feed
      feedURL = [mServiceClass registerFeedURLForProfileID:profileID];
      [service fetchFeedWithURL:feedURL
                       delegate:self
              didFinishSelector:@selector(registerFeedTicket:finishedWithFeed:error:)];
      mIsRegisterFetchPending = YES;
    }

    [self updateUI];
  }
}

// profiles/notices fetch callback
- (void)profileFeedTicket:(GDataServiceTicket *)ticket
         finishedWithFeed:(GDataFeedHealthProfile *)feed
                    error:(NSError *)error {

  [self setProfileFeed:feed];
  [self setProfileFetchError:error];

  mIsProfileFetchPending = NO;

  [self updateUI];
}

- (void)registerFeedTicket:(GDataServiceTicket *)ticket
         finishedWithFeed:(GDataFeedHealthRegister *)feed
                    error:(NSError *)error {

  [self setRegisterFeed:feed];
  [self setRegisterFetchError:error];

  mIsRegisterFetchPending = NO;

  [self updateUI];
}

#pragma mark TableView delegate methods

//
// table view delegate methods
//

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  id obj = [notification object];
  if (obj == mProfileListTable) {
    // the user clicked on an profile list entry, so fetch the profile or
    // notices
    [self fetchSelectedProfile];
  } else {
    // the user clicked on a profile or register entry
    [self updateUI];
  }
}

// table view data source methods
- (int)numberOfRowsInTableView:(NSTableView *)tableView {
  GDataFeedBase *displayFeed;

  if (tableView == mProfileListTable) {
    displayFeed = mProfileListFeed;
  } else if ([self isProfileSegmentSelected]) {
    displayFeed = mProfileFeed;
  } else {
    displayFeed = mRegisterFeed;
  }

  return [[displayFeed entries] count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
  if (tableView == mProfileListTable) {
    GDataEntryBase *entry = [[mProfileListFeed entries] objectAtIndex:row];
    return [[entry title] stringValue];
  } else {
    if ([self isProfileSegmentSelected]) {
      // identify the profile entry with the CCR and health item
      // categories
      GDataEntryHealthProfile *profileEntry;
      profileEntry = [[mProfileFeed entries] objectAtIndex:row];

      NSDate *editDate = [[profileEntry editedDate] date];
      NSString *ccrTerm = [[profileEntry CCRCategory] term];
      NSString *itemTerm = [[profileEntry healthItemCategory] term];

      NSString *displayStr = [NSString stringWithFormat:@"%@: %@/%@",
                              editDate, ccrTerm, itemTerm];
      return displayStr;
    } else {
      GDataEntryHealthProfile *registerEntry;
      registerEntry = [[mRegisterFeed entries] objectAtIndex:row];

      return [[registerEntry title] stringValue];
    }
  }
}

#pragma mark Setters and Getters

- (GDataFeedBase *)profileListFeed {
  return mProfileListFeed;
}

- (void)setProfileListFeed:(GDataFeedBase *)feed {
  [mProfileListFeed autorelease];
  mProfileListFeed = [feed retain];
}

- (NSError *)profileListFetchError {
  return mProfileListFetchError;
}

- (void)setProfileListFetchError:(NSError *)error {
  [mProfileListFetchError release];
  mProfileListFetchError = [error retain];
}


- (GDataFeedHealthProfile *)profileFeed {
  return mProfileFeed;
}

- (void)setProfileFeed:(GDataFeedHealthProfile *)feed {
  [mProfileFeed autorelease];
  mProfileFeed = [feed retain];
}

- (NSError *)profileFetchError {
  return mProfileFetchError;
}

- (void)setProfileFetchError:(NSError *)error {
  [mProfileFetchError release];
  mProfileFetchError = [error retain];
}


- (GDataFeedHealthRegister *)registerFeed {
  return mRegisterFeed;
}

- (void)setRegisterFeed:(GDataFeedHealthRegister *)feed {
  [mRegisterFeed autorelease];
  mRegisterFeed = [feed retain];
}

- (NSError *)registerFetchError {
  return mRegisterFetchError;
}

- (void)setRegisterFetchError:(NSError *)error {
  [mRegisterFetchError release];
  mRegisterFetchError = [error retain];
}

@end
