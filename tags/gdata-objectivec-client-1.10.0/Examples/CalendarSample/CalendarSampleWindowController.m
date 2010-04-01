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
//  CalendarSampleWindowController.m
//

#import "CalendarSampleWindowController.h"

#import "EditEventWindowController.h"
#import "EditACLWindowController.h"

@interface CalendarSampleWindowController (PrivateMethods)
- (void)updateUI;

- (void)fetchAllCalendars;
- (void)fetchSelectedCalendar;

- (void)addACalendar;
- (void)renameSelectedCalendar;
- (void)deleteSelectedCalendar;

- (void)fetchSelectedCalendarEvents;
- (void)addAnEvent;
- (void)editSelectedEvent;
- (void)deleteSelectedEvents;
- (void)batchDeleteSelectedEvents;
- (void)queryTodaysEvents;

- (void)fetchSelectedCalendarACLEntries;
- (void)addAnACLEntry;
- (void)editSelectedACLEntry;
- (void)deleteSelectedACLEntry;

- (void)fetchSelectedCalendarSettingsEntries;

- (GDataServiceGoogleCalendar *)calendarService;
- (GDataEntryCalendar *)selectedCalendar;
- (GDataEntryCalendarEvent *)singleSelectedEvent;
- (NSArray *)selectedEvents;
- (GDataEntryACL *)selectedACLEntry;
- (GDataEntryCalendarSettings *)selectedSettingsEntry;

- (BOOL)isACLSegmentSelected;
- (BOOL)isEventsSegmentSelected;
- (BOOL)isSettingsSegmentSelected;
- (GDataFeedBase *)feedForSelectedSegment;

- (GDataFeedCalendar *)calendarFeed;
- (void)setCalendarFeed:(GDataFeedCalendar *)feed;
- (NSError *)calendarFetchError;
- (void)setCalendarFetchError:(NSError *)error;
- (GDataServiceTicket *)calendarFetchTicket;
- (void)setCalendarFetchTicket:(GDataServiceTicket *)ticket;

- (GDataFeedCalendarEvent *)eventFeed;
- (void)setEventFeed:(GDataFeedCalendarEvent *)feed;
- (NSError *)eventFetchError;
- (void)setEventFetchError:(NSError *)error;
- (GDataServiceTicket *)eventFetchTicket;
- (void)setEventFetchTicket:(GDataServiceTicket *)ticket;

- (GDataFeedACL *)ACLFeed;
- (void)setACLFeed:(GDataFeedACL *)feed;
- (NSError *)ACLFetchError;
- (void)setACLFetchError:(NSError *)error;
- (GDataServiceTicket *)ACLFetchTicket;
- (void)setACLFetchTicket:(GDataServiceTicket *)ticket;

- (GDataFeedCalendarSettings *)settingsFeed;
- (void)setSettingsFeed:(GDataFeedCalendarSettings *)feed;
- (NSError *)settingsFetchError;
- (void)setSettingsFetchError:(NSError *)error;
- (GDataServiceTicket *)settingsFetchTicket;
- (void)setSettingsFetchTicket:(GDataServiceTicket *)ticket;

@end

enum {
  // calendar segmented control segment index values
  kAllCalendarsSegment = 0,
  kOwnedCalendarsSegment = 1
};

enum {
  // event/ACL/settings segmented control segment index values
  kEventsSegment = 0,
  kACLSegment = 1,
  kSettingsSegment = 2
};

@implementation CalendarSampleWindowController

static CalendarSampleWindowController* gCalendarSampleWindowController = nil;


+ (CalendarSampleWindowController *)sharedCalendarSampleWindowController {

  if (!gCalendarSampleWindowController) {
    gCalendarSampleWindowController = [[CalendarSampleWindowController alloc] init];
  }
  return gCalendarSampleWindowController;
}


- (id)init {
  return [self initWithWindowNibName:@"CalendarSampleWindow"];
}

- (void)windowDidLoad {
}

- (void)awakeFromNib {
  // Set the result text fields to have a distinctive color and mono-spaced font
  // to aid in understanding of each calendar and event query operation.
  [mCalendarResultTextField setTextColor:[NSColor darkGrayColor]];
  [mEventResultTextField setTextColor:[NSColor darkGrayColor]];

  NSFont *resultTextFont = [NSFont fontWithName:@"Monaco" size:9];
  [mCalendarResultTextField setFont:resultTextFont];
  [mEventResultTextField setFont:resultTextFont];

  [mCalendarTable setDoubleAction:@selector(logEntryXML:)];
  [mEventTable setDoubleAction:@selector(logEntryXML:)];

  [self updateUI];
}

- (void)dealloc {
  [mCalendarFeed release];
  [mCalendarFetchError release];
  [mCalendarFetchTicket release];

  [mEventFeed release];
  [mEventFetchError release];
  [mEventFetchTicket release];

  [mACLFeed release];
  [mACLFetchError release];
  [mACLFetchTicket release];

  [mSettingsFeed release];
  [mSettingsFetchError release];
  [mSettingsFetchTicket release];

  [super dealloc];
}

#pragma mark -

- (void)updateUI {

  // calendar list display
  [mCalendarTable reloadData];

  if (mCalendarFetchTicket != nil) {
    [mCalendarProgressIndicator startAnimation:self];
  } else {
    [mCalendarProgressIndicator stopAnimation:self];
  }

  // calendar fetch result or selected item
  NSString *calendarResultStr = @"";
  if (mCalendarFetchError) {
    calendarResultStr = [mCalendarFetchError description];
  } else {
    GDataEntryCalendar *calendar = [self selectedCalendar];
    if (calendar) {
      calendarResultStr = [calendar description];
    }
  }
  [mCalendarResultTextField setString:calendarResultStr];

  // add/delete calendar controls
  BOOL canAddCalendar = ([mCalendarFeed postLink] != nil);
  BOOL hasNewCalendarName = ([[mCalendarNameField stringValue] length] > 0);
  [mAddCalendarButton setEnabled:(canAddCalendar && hasNewCalendarName)];

  BOOL canEditSelectedCalendar = ([[self selectedCalendar] editLink] != nil);
  [mDeleteCalendarButton setEnabled:canEditSelectedCalendar];
  [mRenameCalendarButton setEnabled:(hasNewCalendarName && canEditSelectedCalendar)];

  int calendarsSegment = [mCalendarSegmentedControl selectedSegment];
  BOOL canEditNewCalendarName = (calendarsSegment == kOwnedCalendarsSegment);
  [mCalendarNameField setEnabled:canEditNewCalendarName];

  // event/ACL/settings list display
  [mEventTable reloadData];

  // the bottom table displays event, ACL, or settings entries
  BOOL isEventDisplay = [self isEventsSegmentSelected];
  BOOL isACLDisplay = [self isACLSegmentSelected];

  GDataServiceTicket *entryTicket;
  NSError *error;

  if (isEventDisplay) {
    entryTicket = mEventFetchTicket;
    error = mEventFetchError;
  } else if (isACLDisplay) {
    entryTicket = mACLFetchTicket;
    error = mACLFetchError;
  } else {
    entryTicket = mSettingsFetchTicket;
    error = mSettingsFetchError;
  }

  if (entryTicket != nil) {
    [mEventProgressIndicator startAnimation:self];
  } else {
    [mEventProgressIndicator stopAnimation:self];
  }

  // display event, ACL, or settings fetch result or selected item
  NSString *eventResultStr = @"";
  if (error) {
    eventResultStr = [error description];
  } else {
    GDataEntryBase *entry = nil;
    if (isEventDisplay) {
      entry = [self singleSelectedEvent];
    } else if (isACLDisplay) {
      entry = [self selectedACLEntry];
    } else {
      entry = [self selectedSettingsEntry];
    }

    if (entry != nil) {
      eventResultStr = [entry description];
    }
  }
  [mEventResultTextField setString:eventResultStr];

  // enable/disable cancel buttons
  [mCalendarCancelButton setEnabled:(mCalendarFetchTicket != nil)];
  [mEventCancelButton setEnabled:(entryTicket != nil)];

  // enable/disable other buttons
  BOOL isCalendarSelected = ([self selectedCalendar] != nil);

  BOOL doesSelectedCalendarHaveACLFeed =
    ([[self selectedCalendar] ACLLink] != nil);

  [mMapEventButton setEnabled:NO];

  if (isEventDisplay) {

    [mAddEventButton setEnabled:isCalendarSelected];
    [mQueryTodayEventButton setEnabled:isCalendarSelected];

    // Events segment is selected
    NSArray *selectedEvents = [self selectedEvents];
    unsigned int numberOfSelectedEvents = [selectedEvents count];

    NSString *deleteTitle = (numberOfSelectedEvents <= 1) ?
      @"Delete Entry" : @"Delete Entries";
    [mDeleteEventButton setTitle:deleteTitle];

    if (numberOfSelectedEvents == 1) {

      // 1 selected event
      GDataEntryCalendarEvent *event = [selectedEvents objectAtIndex:0];
      BOOL isSelectedEntryEditable = ([event editLink] != nil);

      [mDeleteEventButton setEnabled:isSelectedEntryEditable];
      [mEditEventButton setEnabled:isSelectedEntryEditable];

      BOOL hasEventLocation = ([event geoLocation] != nil);
      [mMapEventButton setEnabled:hasEventLocation];

    } else {
      // zero or many selected events
      BOOL canBatchEdit = ([mEventFeed batchLink] != nil);
      BOOL canDeleteAll = (canBatchEdit && numberOfSelectedEvents > 1);

      [mDeleteEventButton setEnabled:canDeleteAll];
      [mEditEventButton setEnabled:NO];
    }
  } else if (isACLDisplay) {
    // ACL segment is selected
    BOOL isEditableACLEntrySelected =
      ([[self selectedACLEntry] editLink] != nil);

    [mDeleteEventButton setEnabled:isEditableACLEntrySelected];
    [mEditEventButton setEnabled:isEditableACLEntrySelected];

    [mAddEventButton setEnabled:doesSelectedCalendarHaveACLFeed];
    [mQueryTodayEventButton setEnabled:NO];
  } else {
    // settings segment is selected
    [mDeleteEventButton setEnabled:NO];
    [mEditEventButton setEnabled:NO];
    [mAddEventButton setEnabled:NO];
    [mQueryTodayEventButton setEnabled:NO];
  }

  // enable or disable the Events/ACL segment buttons
  [mEntrySegmentedControl setEnabled:isCalendarSelected
                          forSegment:kEventsSegment];
  [mEntrySegmentedControl setEnabled:isCalendarSelected
                          forSegment:kSettingsSegment];
  [mEntrySegmentedControl setEnabled:doesSelectedCalendarHaveACLFeed
                          forSegment:kACLSegment];
}

- (NSString *)displayStringForACLEntry:(GDataEntryACL *)aclEntry  {

  // make a concise, readable string showing the scope type, scope value,
  // and role value for an ACL entry, like:
  //
  //    scope: user "fred@flintstone.com"  role:owner

  NSMutableString *resultStr = [NSMutableString string];

  GDataACLScope *scope = [aclEntry scope];
  if (scope) {
    NSString *type = ([scope type] ? [scope type] : @"");
    NSString *value = @"";
    if ([scope value]) {
      value = [NSString stringWithFormat:@"\"%@\"", [scope value]];
    }
    [resultStr appendFormat:@"scope: %@ %@  ", type, value];
  }

  GDataACLRole *role = [aclEntry role];
  if (role) {
    // for the role value, display only anything after the # character
    // since roles may be rather long, like
    // http://schemas.google.com/calendar/2005/role#collaborator

    NSString *value = [role value];

    NSRange poundRange = [value rangeOfString:@"#" options:NSBackwardsSearch];
    if (poundRange.location != NSNotFound
        && [value length] > (1 + poundRange.location)) {
      value = [value substringFromIndex:(1 + poundRange.location)];
    }
    [resultStr appendFormat:@"role: %@", value];
  }
  return resultStr;
}

- (NSString *)displayStringForSettingsEntry:(GDataEntryCalendarSettings *)settingsEntry  {

  GDataCalendarSettingsProperty *prop = [settingsEntry settingsProperty];

  NSString *str = [NSString stringWithFormat:@"%@: %@",
                   [prop name], [prop value]];
  return str;
}

#pragma mark IBActions

- (IBAction)getCalendarClicked:(id)sender {

  NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];

  NSString *username = [mUsernameField stringValue];
  username = [username stringByTrimmingCharactersInSet:whitespace];

  if ([username rangeOfString:@"@"].location == NSNotFound) {
    // if no domain was supplied, add @gmail.com
    username = [username stringByAppendingString:@"@gmail.com"];
  }

  [mUsernameField setStringValue:username];

  [self fetchAllCalendars];
}

- (IBAction)calendarSegmentClicked:(id)sender {
  // get the new calendar list for the selected segment
  [self getCalendarClicked:sender];
}

- (IBAction)addCalendarClicked:(id)sender {
  [self addACalendar];
}

- (IBAction)renameCalendarClicked:(id)sender {
  [self renameSelectedCalendar];
}

- (IBAction)deleteCalendarClicked:(id)sender {
  [self deleteSelectedCalendar];
}

- (IBAction)cancelCalendarFetchClicked:(id)sender {
  [mCalendarFetchTicket cancelTicket];
  [self setCalendarFetchTicket:nil];
  [self updateUI];
}

- (IBAction)cancelEventFetchClicked:(id)sender {
  [mEventFetchTicket cancelTicket];
  [self setEventFetchTicket:nil];
  [self updateUI];
}

- (IBAction)addEventClicked:(id)sender {
  if ([self isEventsSegmentSelected]) {
    [self addAnEvent];
  } else {
    [self addAnACLEntry];
  }
}

- (IBAction)editEventClicked:(id)sender {
  if ([self isEventsSegmentSelected]) {
    [self editSelectedEvent];
  } else {
    [self editSelectedACLEntry];
  }
}

- (IBAction)deleteEventClicked:(id)sender {
  if ([self isEventsSegmentSelected]) {
    [self deleteSelectedEvents];
  } else {
    [self deleteSelectedACLEntry];
  }
}

- (IBAction)mapEventClicked:(id)sender {
  if ([self isEventsSegmentSelected]) {

    // open Google Maps to the event's location, displaying the event title
    GDataEntryCalendarEvent *event = [self singleSelectedEvent];
    GDataGeo *geoLocation = [event geoLocation];
    if (geoLocation) {

      double latitude = [geoLocation latitude];
      double longitude = [geoLocation longitude];

      NSString *title = [[event title] stringValue];
      NSString *titleParam = [GDataUtilities stringByURLEncodingStringParameter:title];

      NSString *template = @"http://maps.google.com/maps?q=%f,+%f+(%@)";
      NSString *urlStr = [NSString stringWithFormat:template,
                          latitude, longitude, titleParam];

      [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlStr]];
    }
  }
}

- (IBAction)queryTodayClicked:(id)sender {
  [self queryTodaysEvents];
}

- (IBAction)entrySegmentClicked:(id)sender {
  [self fetchSelectedCalendar];
}

- (IBAction)loggingCheckboxClicked:(id)sender {
  [GDataHTTPFetcher setIsLoggingEnabled:[sender state]];
}

// logEntryXML is called when the user double-clicks on a calendar,
// event entry, or ACL entry
- (IBAction)logEntryXML:(id)sender {

  int row = [sender selectedRow];

  if (sender == mCalendarTable) {
    // get the calendar entry's title
    GDataEntryCalendar *calendar = [[mCalendarFeed entries] objectAtIndex:row];
    NSLog(@"%@", [calendar XMLElement]);

  } else if (sender == mEventTable) {
    // get the selected entry
    GDataFeedBase *feed = [self feedForSelectedSegment];
    GDataEntryBase *entry = [[feed entries] objectAtIndex:row];
    NSLog(@"%@", [entry XMLElement]);
  }
}

#pragma mark -

// get a calendar service object with the current username/password
//
// A "service" object handles networking tasks.  Service objects
// contain user authentication information as well as networking
// state information (such as cookies and the "last modified" date for
// fetched data.)

- (GDataServiceGoogleCalendar *)calendarService {

  static GDataServiceGoogleCalendar* service = nil;

  if (!service) {
    service = [[GDataServiceGoogleCalendar alloc] init];

    [service setShouldCacheDatedData:YES];
    [service setServiceShouldFollowNextLinks:YES];
  }

  // update the username/password each time the service is requested
  NSString *username = [mUsernameField stringValue];
  NSString *password = [mPasswordField stringValue];

  [service setUserCredentialsWithUsername:username
                                 password:password];

  return service;
}

// get the calendar selected in the top list, or nil if none
- (GDataEntryCalendar *)selectedCalendar {

  NSArray *calendars = [mCalendarFeed entries];
  int rowIndex = [mCalendarTable selectedRow];
  if ([calendars count] > 0 && rowIndex > -1) {

    GDataEntryCalendar *calendar = [calendars objectAtIndex:rowIndex];
    return calendar;
  }
  return nil;
}

// get the events selected in the bottom list, or nil if none
- (NSArray *)selectedEvents {

  if ([self isEventsSegmentSelected]) {

    NSIndexSet *indexes = [mEventTable selectedRowIndexes];
    NSArray *events = [mEventFeed entries];
    NSArray *selectedEvents = [events objectsAtIndexes:indexes];

    if ([selectedEvents count] > 0) {
      return selectedEvents;
    }
  }
  return nil;
}

- (GDataEntryCalendarEvent *)singleSelectedEvent {

  NSArray *selectedEvents = [self selectedEvents];
  if ([selectedEvents count] == 1) {
    return [selectedEvents objectAtIndex:0];
  }
  return nil;
}


// get the ACL selected in the bottom list, or nil if none
- (GDataEntryACL *)selectedACLEntry {

  if ([self isACLSegmentSelected]) {

    NSArray *entries = [mACLFeed entries];
    int rowIndex = [mEventTable selectedRow];
    if ([entries count] > 0 && rowIndex > -1) {

      GDataEntryACL *entry = [entries objectAtIndex:rowIndex];
      return entry;
    }
  }
  return nil;
}

- (GDataEntryCalendarSettings *)selectedSettingsEntry {

  if ([self isSettingsSegmentSelected]) {

    NSArray *entries = [mSettingsFeed entries];
    int rowIndex = [mEventTable selectedRow];
    if ([entries count] > 0 && rowIndex > -1) {

      GDataEntryCalendarSettings *entry = [entries objectAtIndex:rowIndex];
      return entry;
    }
  }
  return nil;
}

- (BOOL)isACLSegmentSelected {
  return ([mEntrySegmentedControl selectedSegment] == kACLSegment);
}

- (BOOL)isEventsSegmentSelected {
  return ([mEntrySegmentedControl selectedSegment] == kEventsSegment);
}

- (BOOL)isSettingsSegmentSelected {
  return ([mEntrySegmentedControl selectedSegment] == kSettingsSegment);
}

- (GDataFeedBase *)feedForSelectedSegment {
  int segmentNum = [mEntrySegmentedControl selectedSegment];

  if (segmentNum == kEventsSegment) return mEventFeed;
  if (segmentNum == kACLSegment) return mACLFeed;
  return mSettingsFeed;
}

#pragma mark Add/delete calendars

- (void)addACalendar {

  NSString *newCalendarName = [mCalendarNameField stringValue];

  NSURL *postURL = [[mCalendarFeed postLink] URL];

  if ([newCalendarName length] > 0 && postURL != nil) {

    GDataServiceGoogleCalendar *service = [self calendarService];

    GDataEntryCalendar *newEntry = [GDataEntryCalendar calendarEntry];
    [newEntry setTitleWithString:newCalendarName];
    [newEntry setIsSelected:YES]; // check the calendar in the web display

    // as of Dec. '07 the server requires a color,
    // or returns a 404 (Not Found) error
    [newEntry setColor:[GDataColorProperty valueWithString:@"#2952A3"]];

    [service fetchEntryByInsertingEntry:newEntry
                             forFeedURL:postURL
                               delegate:self
                      didFinishSelector:@selector(addCalendarTicket:addedEntry:error:)];
  }
}

// add calendar callback
- (void)addCalendarTicket:(GDataServiceTicket *)ticket
               addedEntry:(GDataEntryCalendar *)object
                    error:(NSError *)error {
  if (error == nil) {
    // tell the user that the add worked
    NSBeginAlertSheet(@"Added Calendar", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Calendar added");

    [mCalendarNameField setStringValue:@""];

    // refetch the current calendars
    [self fetchAllCalendars];
    [self updateUI];
  } else {
    // add failed
    NSBeginAlertSheet(@"Add failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Calendar add failed: %@", error);
  }
}

- (void)renameSelectedCalendar {

  GDataEntryCalendar *selectedCalendar = [self selectedCalendar];
  NSString *newCalendarName = [mCalendarNameField stringValue];
  NSURL *editURL = [[[self selectedCalendar] editLink] URL];

  if (selectedCalendar && editURL && [newCalendarName length] > 0) {

    // make the user confirm that the selected calendar should be renamed
    NSBeginAlertSheet(@"Rename calendar", @"Rename", @"Cancel", nil,
                      [self window], self,
                      @selector(renameCalendarSheetDidEnd:returnCode:contextInfo:),
                      nil, nil, @"Rename the calendar \"%@\" as \"%@\"?",
                      [[selectedCalendar title] stringValue],
                      newCalendarName);
  }
}

- (void)renameCalendarSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {

  if (returnCode == NSAlertDefaultReturn) {

    NSString *newCalendarName = [mCalendarNameField stringValue];
    GDataEntryCalendar *selectedCalendar = [self selectedCalendar];

    GDataServiceGoogleCalendar *service = [self calendarService];

    // rename it
    [selectedCalendar setTitleWithString:newCalendarName];

    [service fetchEntryByUpdatingEntry:selectedCalendar
                              delegate:self
                     didFinishSelector:@selector(renameCalendarTicket:renamedEntry:error:)];
  }
}

// rename calendar callback
- (void)renameCalendarTicket:(GDataServiceTicket *)ticket
                renamedEntry:(GDataEntryCalendar *)object
                       error:(NSError *)error {
  if (error == nil) {
    // tell the user that the rename worked
    NSBeginAlertSheet(@"Renamed Calendar", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Calendar renamed");

    // refetch the current calendars
    [self fetchAllCalendars];
    [self updateUI];
  } else {
    // rename failed
    NSBeginAlertSheet(@"Rename failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Calendar rename failed: %@", error);
  }
}

- (void)deleteSelectedCalendar {

  GDataEntryCalendar *selectedCalendar = [self selectedCalendar];
  if (selectedCalendar) {
    // make the user confirm that the selected calendar should be deleted
    NSBeginAlertSheet(@"Delete calendar", @"Delete", @"Cancel", nil,
                      [self window], self,
                      @selector(deleteCalendarSheetDidEnd:returnCode:contextInfo:),
                      nil, nil, @"Delete the calendar \"%@\"?",
                      [[selectedCalendar title] stringValue]);
  }

}

- (void)deleteCalendarSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {

  if (returnCode == NSAlertDefaultReturn) {

    NSURL *editURL = [[[self selectedCalendar] editLink] URL];

    if (editURL != nil) {

      GDataServiceGoogleCalendar *service = [self calendarService];

      [service deleteEntry:[self selectedCalendar]
                  delegate:self
         didFinishSelector:@selector(deleteCalendarTicket:deletedEntry:error:)];
    }
  }
}

// delete calendar callback
- (void)deleteCalendarTicket:(GDataServiceTicket *)ticket
                deletedEntry:(GDataEntryCalendar *)object
                       error:(NSError *)error {
  if (error == nil) {
    // tell the user that the delete worked
    NSBeginAlertSheet(@"Deleted Calendar", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Calendar deleted");

    // refetch the current calendars
    [self fetchAllCalendars];
    [self updateUI];
  } else {
    NSBeginAlertSheet(@"Delete failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Calendar delete failed: %@", error);
  }
}

#pragma mark Fetch all calendars

// begin retrieving the list of the user's calendars
- (void)fetchAllCalendars {

  [self setCalendarFeed:nil];
  [self setCalendarFetchError:nil];
  [self setCalendarFetchTicket:nil];

  [self setEventFeed:nil];
  [self setEventFetchError:nil];
  [self setEventFetchTicket:nil];

  [self setACLFeed:nil];
  [self setACLFetchError:nil];
  [self setACLFetchTicket:nil];

  [self setSettingsFeed:nil];
  [self setSettingsFetchError:nil];
  [self setSettingsFetchTicket:nil];

  GDataServiceGoogleCalendar *service = [self calendarService];
  GDataServiceTicket *ticket;

  int segment = [mCalendarSegmentedControl selectedSegment];
  NSString *feedURLString;

  // The sample app shows the default, non-editable feed of calendars,
  // and the "OwnCalendars" feed, which allows calendars to be inserted
  // and deleted.  We're not demonstrating the "AllCalendars" feed, which
  // allows subscriptions to non-owned calendars to be inserted and deleted,
  // just because it's a bit too complex to easily keep distinct from add/
  // delete in the user interface.

  if (segment == kAllCalendarsSegment) {
    feedURLString = kGDataGoogleCalendarDefaultFeed;
  } else {
    feedURLString = kGDataGoogleCalendarDefaultOwnCalendarsFeed;
  }

  ticket = [service fetchFeedWithURL:[NSURL URLWithString:feedURLString]
                            delegate:self
                   didFinishSelector:@selector(calendarListTicket:finishedWithFeed:error:)];

  [self setCalendarFetchTicket:ticket];

  [self updateUI];
}

//
// calendar list fetch callbacks
//

// fetch calendar metafeed callback
- (void)calendarListTicket:(GDataServiceTicket *)ticket
          finishedWithFeed:(GDataFeedCalendar *)feed
                     error:(NSError *)error {
  [self setCalendarFeed:feed];
  [self setCalendarFetchError:error];
  [self setCalendarFetchTicket:nil];

  [self updateUI];
}

#pragma mark -

- (void)fetchSelectedCalendar {

  GDataEntryCalendar *calendar = [self selectedCalendar];
  if (calendar) {

    BOOL hasACL = ([[self selectedCalendar] ACLLink] != nil);
    BOOL isDisplayingEvents = [self isEventsSegmentSelected];
    BOOL isDisplayingACL = [self isACLSegmentSelected];

    if (isDisplayingEvents || (isDisplayingACL && !hasACL)) {
      [self fetchSelectedCalendarEvents];
    } else if (isDisplayingACL) {
      [self fetchSelectedCalendarACLEntries];
    } else {
      [self fetchSelectedCalendarSettingsEntries];
    }
  }
}

#pragma mark Fetch a calendar's events

// for the calendar selected in the top list, begin retrieving the list of
// events
- (void)fetchSelectedCalendarEvents {

  GDataEntryCalendar *calendar = [self selectedCalendar];
  if (calendar) {

    // fetch the events feed
    NSURL *feedURL = [[calendar alternateLink] URL];
    if (feedURL) {

      [self setEventFeed:nil];
      [self setEventFetchError:nil];
      [self setEventFetchTicket:nil];

      // The default feed of calendar events only has up to 25 events; since the
      // service object is set to automatically follow next links, that can lead
      // to many fetches to retrieve all of the event entries, and each fetch
      // may take a few seconds.
      //
      // To reduce the need for the library to fetch repeatedly to acquire all
      // of the entries, we'll specify a higher number of entries the server may
      // return in a feed.  For Mac applications, a fetch with 1000 entries is
      // reasonable; iPhone apps may want to avoid the memory hit of parsing
      // such a large number of entries, and limit it to 100.
      GDataQueryCalendar *query = [GDataQueryCalendar calendarQueryWithFeedURL:feedURL];
      [query setMaxResults:1000];

      GDataServiceGoogleCalendar *service = [self calendarService];
      GDataServiceTicket *ticket;
      ticket = [service fetchFeedWithQuery:query
                                  delegate:self
                         didFinishSelector:@selector(calendarEventsTicket:finishedWithFeed:error:)];
      [self setEventFetchTicket:ticket];

      [self updateUI];
    }
  }
}

// event list fetch callback
- (void)calendarEventsTicket:(GDataServiceTicket *)ticket
            finishedWithFeed:(GDataFeedCalendarEvent *)feed
                       error:(NSError *)error {

  [self setEventFeed:feed];
  [self setEventFetchError:error];
  [self setEventFetchTicket:nil];

  [self updateUI];
}

#pragma mark Add an event

- (void)addAnEvent {

  // make a new event
  GDataEntryCalendarEvent *newEvent = [GDataEntryCalendarEvent calendarEvent];

  // set a title and description (the author is the authenticated user adding
  // the entry)
  [newEvent setTitleWithString:@"Sample Added Event"];
  [newEvent setContentWithString:@"Description of sample added event"];

  // start time now, end time in an hour, reminder 10 minutes before
  NSDate *anHourFromNow = [NSDate dateWithTimeIntervalSinceNow:60*60];
  GDataDateTime *startDateTime = [GDataDateTime dateTimeWithDate:[NSDate date]
                                                        timeZone:[NSTimeZone systemTimeZone]];
  GDataDateTime *endDateTime = [GDataDateTime dateTimeWithDate:anHourFromNow
                                                      timeZone:[NSTimeZone systemTimeZone]];
  GDataReminder *reminder = [GDataReminder reminder];
  [reminder setMinutes:@"10"];

  GDataWhen *when = [GDataWhen whenWithStartTime:startDateTime
                                         endTime:endDateTime];
  [when addReminder:reminder];
  [newEvent addTime:when];

  // display the event edit dialog
  EditEventWindowController *controller = [[EditEventWindowController alloc] init];
  [controller runModalForTarget:self
                       selector:@selector(addEditControllerFinished:)
                          event:newEvent];
}

// callback from the edit event dialog
- (void)addEditControllerFinished:(EditEventWindowController *)addEventController {

  if ([addEventController wasSaveClicked]) {

    // insert the event into the selected calendar
    GDataEntryCalendarEvent *event = [addEventController event];
    if (event) {

      GDataServiceGoogleCalendar *service = [self calendarService];

      GDataEntryCalendar *calendar = [self selectedCalendar];
      NSURL *feedURL = [[calendar alternateLink] URL];

      [service fetchEntryByInsertingEntry:event
                               forFeedURL:feedURL
                                 delegate:self
                        didFinishSelector:@selector(addEventTicket:addedEntry:error:)];
    }
  }
  [addEventController autorelease];
}

// event added successfully
- (void)addEventTicket:(GDataServiceTicket *)ticket
            addedEntry:(GDataFeedCalendarEvent *)entry
                 error:(NSError *)error {
  if (error == nil) {
    // tell the user that the add worked
    NSBeginAlertSheet(@"Added Event", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Event added");

    // refetch the current calendar's events
    [self fetchSelectedCalendar];
    [self updateUI];
  } else {
    // the add failed
    NSBeginAlertSheet(@"Add failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Event add failed: %@", error);
  }
}

#pragma mark Edit an event

- (void)editSelectedEvent {

  // display the event edit dialog
  GDataEntryCalendarEvent *event = [self singleSelectedEvent];
  if (event) {
    EditEventWindowController *controller = [[EditEventWindowController alloc] init];
    [controller runModalForTarget:self
                         selector:@selector(editControllerFinished:)
                            event:event];
  }
}

// callback from the edit event dialog
- (void)editControllerFinished:(EditEventWindowController *)editEventController {
  if ([editEventController wasSaveClicked]) {

    // update the event with the changed settings
    GDataEntryCalendarEvent *event = [editEventController event];
    if (event) {

      GDataServiceGoogleCalendar *service = [self calendarService];
      [service fetchEntryByUpdatingEntry:event
                                delegate:self
                       didFinishSelector:@selector(editEventTicket:editedEntry:error:)];
    }
  }
  [editEventController autorelease];
}

// update event callback
- (void)editEventTicket:(GDataServiceTicket *)ticket
            editedEntry:(GDataFeedCalendarEvent *)object
                  error:(NSError *)error {
  if (error == nil) {
    // tell the user that the update worked
    NSBeginAlertSheet(@"Updated Event", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Event updated");

    // re-fetch the selected calendar's events
    [self fetchSelectedCalendar];
    [self updateUI];
  } else {
    // failed
    NSBeginAlertSheet(@"Update failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Event update failed: %@", error);
  }
}

#pragma mark Delete selected events

- (void)deleteSelectedEvents {

  NSArray *events = [self selectedEvents];
  unsigned int numberOfSelectedEvents = [events count];

  if (numberOfSelectedEvents == 1) {

    // 1 event selected
    GDataEntryCalendarEvent *event = [events objectAtIndex:0];

    // make the user confirm that the selected event should be deleted
    NSBeginAlertSheet(@"Delete Event", @"Delete", @"Cancel", nil,
                      [self window], self,
                      @selector(deleteSheetDidEnd:returnCode:contextInfo:),
                      nil, nil, @"Delete the event \"%@\"?",
                      [event title]);

  } else if (numberOfSelectedEvents >= 1) {

    NSBeginAlertSheet(@"Delete Events", @"Delete", @"Cancel", nil,
                      [self window], self,
                      @selector(batchDeleteSheetDidEnd:returnCode:contextInfo:),
                      nil, nil, @"Delete %d events?",
                      numberOfSelectedEvents);
  }
}

// delete dialog callback
- (void)deleteSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {

  if (returnCode == NSAlertDefaultReturn) {

    // delete the event
    GDataEntryCalendarEvent *event = [self singleSelectedEvent];
    GDataLink *link = [event editLink];

    if (link) {
      GDataServiceGoogleCalendar *service = [self calendarService];
      [service deleteEntry:event
                  delegate:self
         didFinishSelector:@selector(deleteTicket:deletedEntry:error:)];
    }
  }
}

// event deleted callback
- (void)deleteTicket:(GDataServiceTicket *)ticket
        deletedEntry:(GDataFeedCalendarEvent *)nilObject
               error:(NSError *)error {
  if (error == nil) {
    NSBeginAlertSheet(@"Deleted Event", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Event deleted");

    // re-fetch the selected calendar's events
    [self fetchSelectedCalendar];
    [self updateUI];
  } else {
    // failed
    NSBeginAlertSheet(@"Delete failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Event delete failed: %@", error);
  }
}

// delete dialog callback
- (void)batchDeleteSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {

  if (returnCode == NSAlertDefaultReturn) {
    // delete the events
    [self batchDeleteSelectedEvents];
  }
}

- (void)batchDeleteSelectedEvents {

  NSArray *selectedEvents = [self selectedEvents];

  for (int idx = 0; idx < [selectedEvents count]; idx++) {

    GDataEntryCalendarEvent *event = [selectedEvents objectAtIndex:idx];

    // add a batch ID to this entry
    static int staticID = 0;
    NSString *batchID = [NSString stringWithFormat:@"batchID_%u", ++staticID];
    [event setBatchIDWithString:batchID];

    // we don't need to add the batch operation to the entries since
    // we're putting it in the feed to apply to all entries

    // we could force an error on an item by nuking the entry's identifier
    //   if (idx == 1) { [event setIdentifier:nil]; }
  }

  NSURL *batchURL = [[mEventFeed batchLink] URL];
  if (batchURL != nil && [selectedEvents count] > 0) {

    // make a batch feed object: add entries, and since
    // we are doing the same operation for all entries in the feed,
    // add the operation

    GDataFeedCalendarEvent *batchFeed = [GDataFeedCalendarEvent calendarEventFeed];
    [batchFeed setEntriesWithEntries:selectedEvents];

    GDataBatchOperation *op = [GDataBatchOperation batchOperationWithType:kGDataBatchOperationDelete];
    [batchFeed setBatchOperation:op];

    // now do the usual steps for authenticating for this service, and issue
    // the fetch

    GDataServiceGoogleCalendar *service = [self calendarService];

    [service fetchFeedWithBatchFeed:batchFeed
                    forBatchFeedURL:batchURL
                           delegate:self
                  didFinishSelector:@selector(batchDeleteTicket:finishedWithFeed:error:)];
  } else {
    // the button shouldn't be enabled when we can't batch delete, so we
    // shouldn't get here
    NSBeep();
  }
}

// batch delete callback
- (void)batchDeleteTicket:(GDataServiceTicket *)ticket
         finishedWithFeed:(GDataFeedCalendarEvent *)feed
                    error:(NSError *)error {
  if (error == nil) {
    // the fetch succeeded, though individual entries may have failed

    // step through all the entries in the response feed,
    // and build a string reporting each

    // show the http status to start (should be 200)
    NSString *format = @"http status:%d\n\n";
    NSMutableString *reportStr = [NSMutableString stringWithFormat:format,
                                  [ticket statusCode]];

    NSArray *responseEntries = [feed entries];
    for (int idx = 0; idx < [responseEntries count]; idx++) {

      GDataEntryCalendarEvent *entry = [responseEntries objectAtIndex:idx];
      GDataBatchID *batchID = [entry batchID];

      // report the batch ID, entry title, and status for each item
      NSString *title= [[entry title] stringValue];
      [reportStr appendFormat:@"%@: %@\n", [batchID stringValue], title];

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

    NSBeginAlertSheet(@"Batch delete completed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Delete completed.\n%@", reportStr);

    // re-fetch the selected calendar's events
    [self fetchSelectedCalendar];

  } else {
    // fetch failed
    NSBeginAlertSheet(@"Batch delete failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Delete failed: %@", error);
  }
  [self updateUI];
}


#pragma mark Query today's events

// utility routine to make a GDataDateTime object for sometime today
- (GDataDateTime *)dateTimeForTodayAtHour:(int)hour
                                   minute:(int)minute
                                   second:(int)second {

  int const kComponentBits = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                              | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit);

  NSCalendar *cal = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];

  NSDateComponents *dateComponents = [cal components:kComponentBits fromDate:[NSDate date]];
  [dateComponents setHour:hour];
  [dateComponents setMinute:minute];
  [dateComponents setSecond:second];

  GDataDateTime *dateTime = [GDataDateTime dateTimeWithDate:[NSDate date]
                                                   timeZone:[NSTimeZone systemTimeZone]];
  [dateTime setDateComponents:dateComponents];
  return dateTime;
}

// submit a query about today's events in the selected calendar
// NOTE: See GDataQueryCalendar.h for a warning about exceptions to recurring
// events being returned twice for a query.
- (void)queryTodaysEvents {

  GDataServiceGoogleCalendar *service = [self calendarService];

  GDataEntryCalendar *calendar = [self selectedCalendar];
  NSURL *feedURL = [[calendar alternateLink] URL];

  // make start and end times for today, at the beginning and end of the day

  GDataDateTime *startOfDay = [self dateTimeForTodayAtHour:0 minute:0 second:0];
  GDataDateTime *endOfDay = [self dateTimeForTodayAtHour:23 minute:59 second:59];

  // make the query
  GDataQueryCalendar* queryCal;

  queryCal = [GDataQueryCalendar calendarQueryWithFeedURL:feedURL];
  [queryCal setStartIndex:1];
  [queryCal setMaxResults:10];
  [queryCal setMinimumStartTime:startOfDay];
  [queryCal setMaximumStartTime:endOfDay];

  [service fetchFeedWithQuery:queryCal
                     delegate:self
            didFinishSelector:@selector(queryTicket:finishedWithFeed:error:)];
}

// callback for query of today's events
- (void)queryTicket:(GDataServiceTicket *)ticket
   finishedWithFeed:(GDataFeedCalendarEvent *)feed
              error:(NSError *)error {
  if (error == nil) {
    // query succeeded
    NSArray *entries = [feed entries];

    // make a comma-separate list of the event titles to display
    NSMutableArray *titles = [NSMutableArray array];

    for (int idx = 0; idx < [entries count]; idx++) {
      GDataEntryCalendarEvent *event = [entries objectAtIndex:idx];
      NSString *title = [[event title] stringValue];
      if ([title length] > 0) {
        [titles addObject:title];
      }
    }

    NSString *resultStr = [titles componentsJoinedByString:@", "];

    NSBeginAlertSheet(@"Query ", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Query result: %@", resultStr);
  } else {
    // query failed
    NSBeginAlertSheet(@"Query failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Query failed: %@", error);
  }
}

////////////////////////////////////////////////////////
#pragma mark ACL

- (void)fetchSelectedCalendarACLEntries {

  GDataEntryCalendar *calendar = [self selectedCalendar];
  if (calendar) {

    NSURL *aclFeedURL = [[calendar ACLLink] URL];
    if (aclFeedURL) {

      // fetch the ACL feed
      [self setACLFeed:nil];
      [self setACLFetchError:nil];
      [self setACLFetchTicket:nil];

      GDataServiceGoogleCalendar *service = [self calendarService];
      GDataServiceTicket *ticket;
      ticket = [service fetchACLFeedWithURL:aclFeedURL
                                   delegate:self
                          didFinishSelector:@selector(calendarACLTicket:finishedWithFeed:error:)];

      [self setACLFetchTicket:ticket];

      [self updateUI];
    }
  }
}

// fetched ACL list callback
- (void)calendarACLTicket:(GDataServiceTicket *)ticket
         finishedWithFeed:(GDataFeedACL *)feed
                    error:(NSError *)error {

  [self setACLFeed:feed];
  [self setACLFetchError:error];
  [self setACLFetchTicket:nil];

  [self updateUI];
}

#pragma mark Add an ACL entry

- (void)addAnACLEntry {

  // make a new entry
  NSString *email = @"fred.flintstone@bounce.spuriousmail.com";

  GDataACLScope *scope = [GDataACLScope scopeWithType:@"user"
                                                value:email];
  GDataACLRole *role = [GDataACLRole roleWithValue:kGDataRoleCalendarRead];

  GDataEntryACL *newEntry = [GDataEntryACL ACLEntryWithScope:scope role:role];

  // display the ACL edit dialog
  EditACLWindowController *controller = [[EditACLWindowController alloc] init];
  [controller runModalForTarget:self
                       selector:@selector(addACLEditControllerFinished:)
                       ACLEntry:newEntry];
}

// callback from the edit ACL dialog
- (void)addACLEditControllerFinished:(EditACLWindowController *)addACLController {

  if ([addACLController wasSaveClicked]) {

    // insert the ACL into the selected calendar
    GDataEntryACL *entry = [addACLController ACLEntry];
    if (entry) {

      GDataServiceGoogleCalendar *service = [self calendarService];

      NSURL *postURL = [[mACLFeed postLink] URL];
      if (postURL) {
        [service fetchACLEntryByInsertingEntry:entry
                                    forFeedURL:postURL
                                      delegate:self
                             didFinishSelector:@selector(addACLEntryTicket:addedEntry:error:)];
      }
    }
  }
  [addACLController autorelease];
}

// add ACL callback
- (void)addACLEntryTicket:(GDataServiceTicket *)ticket
               addedEntry:(GDataEntryACL *)entry
                    error:(NSError *)error {
  if (error == nil) {
    // tell the user that the add worked
    NSBeginAlertSheet(@"Added ACL Entry", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"ACL Entry added");

    // refetch the current calendar's ACL entries
    [self fetchSelectedCalendar];
    [self updateUI];
  } else {
    NSBeginAlertSheet(@"Add failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"ACL Entry add failed: %@", error);
  }
}

#pragma mark Edit an ACLEntry

- (void)editSelectedACLEntry {

  // display the ACLEntry edit dialog
  GDataEntryACL *entry = [self selectedACLEntry];
  if (entry) {
    EditACLWindowController *controller = [[EditACLWindowController alloc] init];
    [controller runModalForTarget:self
                         selector:@selector(ACLEditControllerFinished:)
                         ACLEntry:entry];
  }
}

// callback from the edit ACLEntry dialog
- (void)ACLEditControllerFinished:(EditACLWindowController *)editACLEntryController {
  if ([editACLEntryController wasSaveClicked]) {

    // update the ACLEntry with the changed settings
    GDataEntryACL *entry = [editACLEntryController ACLEntry];
    if (entry) {

      GDataLink *link = [entry editLink];
      if (link) {
        GDataServiceGoogleCalendar *service = [self calendarService];
        [service fetchACLEntryByUpdatingEntry:entry
                                     delegate:self
                            didFinishSelector:@selector(editACLEntryTicket:editedEntry:error:)];
      }
    }
  }
  [editACLEntryController autorelease];
}

// ACLEntry edit callback
- (void)editACLEntryTicket:(GDataServiceTicket *)ticket
               editedEntry:(GDataFeedACL *)object
                     error:(NSError *)error {
  if (error == nil) {
    // tell the user that the update worked
    NSBeginAlertSheet(@"Updated ACLEntry", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"ACL Entry updated");

    // re-fetch the selected calendar's ACLEntries
    [self fetchSelectedCalendar];
    [self updateUI];
  } else {
    NSBeginAlertSheet(@"Update failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"ACLEntry update failed: %@", error);
  }
}

#pragma mark Delete an ACL Entry

- (void)deleteSelectedACLEntry {

  GDataEntryACL *entry = [self selectedACLEntry];
  if (entry) {
    // make the user confirm that the selected ACLEntry should be deleted
    NSString *entryDesc = [NSString stringWithFormat:@"%@ %@",
                           [[entry scope] type], [[entry scope] value]];

    NSBeginAlertSheet(@"Delete ACLEntry", @"Delete", @"Cancel", nil,
                      [self window], self,
                      @selector(deleteACLSheetDidEnd:returnCode:contextInfo:),
                      nil, nil, @"Delete the ACL entry \"%@\"?",
                      entryDesc);
  }
}

// delete dialog callback
- (void)deleteACLSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {

  if (returnCode == NSAlertDefaultReturn) {

    // delete the ACLEntry
    GDataEntryACL *entry = [self selectedACLEntry];

    if (entry) {
      GDataServiceGoogleCalendar *service = [self calendarService];
      [service deleteACLEntry:entry
                     delegate:self
            didFinishSelector:@selector(deleteACLEntryTicket:deletedEntry:error:)];
    }
  }
}

// ACLEntry deleted successfully
- (void)deleteACLEntryTicket:(GDataServiceTicket *)ticket
                deletedEntry:(GDataFeedACL *)object
                       error:(NSError *)error {
  if (error == nil) {
    NSBeginAlertSheet(@"Deleted ACLEntry", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"ACL Entry deleted");

    // re-fetch the selected calendar's events
    [self fetchSelectedCalendar];
    [self updateUI];
  } else {
    NSBeginAlertSheet(@"Delete failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"ACL Entry delete failed: %@", error);
  }
}

////////////////////////////////////////////////////////
#pragma mark Settings feed

- (void)fetchSelectedCalendarSettingsEntries {

  GDataEntryCalendar *calendar = [self selectedCalendar];
  if (calendar) {

    NSString *username = [mUsernameField stringValue];

    NSURL *settingsFeedURL = [GDataServiceGoogleCalendar settingsFeedURLForUsername:username];
    if (settingsFeedURL) {

      // fetch the settings feed
      [self setSettingsFeed:nil];
      [self setSettingsFetchError:nil];
      [self setSettingsFetchTicket:nil];

      GDataServiceGoogleCalendar *service = [self calendarService];
      GDataServiceTicket *ticket;

      // temporary fetch call, waiting until settings feed has kind categories, http://b/1694419
      ticket = [service fetchFeedWithURL:settingsFeedURL
                                delegate:self
                       didFinishSelector:@selector(calendarSettingsTicket:finishedWithFeed:error:)];

      [self setSettingsFetchTicket:ticket];

      [self updateUI];
    }
  }
}

// settings list fetch callback
- (void)calendarSettingsTicket:(GDataServiceTicket *)ticket
              finishedWithFeed:(GDataFeedCalendarSettings *)feed
                         error:(NSError *)error {

  [self setSettingsFeed:feed];
  [self setSettingsFetchError:error];
  [self setSettingsFetchTicket:nil];

  [self updateUI];
}

#pragma mark TableView delegate methods
//
// table view delegate methods
//

- (void)tableViewSelectionDidChange:(NSNotification *)notification {

  if ([notification object] == mCalendarTable) {
    // the user clicked on a calendar, so fetch its events

    // if the calendar lacks an ACL feed, select the events segment;
    // the updateUI routine will disable the ACL segment for us
    BOOL doesSelectedCalendarHaveACLFeed =
      ([[self selectedCalendar] ACLLink] != nil);

    if (!doesSelectedCalendarHaveACLFeed && [self isACLSegmentSelected]) {
      [mEntrySegmentedControl setSelectedSegment:kEventsSegment];
    }

    [self fetchSelectedCalendar];
  } else {
    // the user clicked on an event or an ACL entry;
    // just display it below the entry table

    [self updateUI];
  }
}

// table view data source methods
- (int)numberOfRowsInTableView:(NSTableView *)tableView {
  if (tableView == mCalendarTable) {
    return [[mCalendarFeed entries] count];
  } else {
    // entry table
    GDataFeedBase *feed = [self feedForSelectedSegment];
    return [[feed entries] count];
  }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {

  // calendar list table
  if (tableView == mCalendarTable) {
    // get the calendar entry's title
    GDataEntryCalendar *calendar = [[mCalendarFeed entries] objectAtIndex:row];
    return [[calendar title] stringValue];
  }

  // entries table

  // event entry
  if ([self isEventsSegmentSelected]) {
    // get the event entry's title
    GDataEntryCalendarEvent *eventEntry = [[mEventFeed entries] objectAtIndex:row];
    return [[eventEntry title] stringValue];
  }

  // ACL entry
  if ([self isACLSegmentSelected]) {
    GDataEntryACL *aclEntry = [[mACLFeed entries] objectAtIndex:row];
    return [self displayStringForACLEntry:aclEntry];
  }

  // settings entry
  GDataEntryCalendarSettings *settingsEntry = [[mSettingsFeed entries] objectAtIndex:row];
  return [self displayStringForSettingsEntry:settingsEntry];
}

#pragma mark Control delegate methods

- (void)controlTextDidChange:(NSNotification *)note {

  [self updateUI]; // enabled/disable the Add Calendar button
}

#pragma mark Setters and Getters

- (GDataFeedCalendar *)calendarFeed {
  return mCalendarFeed;
}

- (void)setCalendarFeed:(GDataFeedCalendar *)feed {
  [mCalendarFeed autorelease];
  mCalendarFeed = [feed retain];
}

- (NSError *)calendarFetchError {
  return mCalendarFetchError;
}

- (void)setCalendarFetchError:(NSError *)error {
  [mCalendarFetchError release];
  mCalendarFetchError = [error retain];
}

- (GDataServiceTicket *)calendarFetchTicket {
  return mCalendarFetchTicket;
}

- (void)setCalendarFetchTicket:(GDataServiceTicket *)ticket {
  [mCalendarFetchTicket release];
  mCalendarFetchTicket = [ticket retain];
}

- (GDataFeedCalendarEvent *)eventFeed {
  return mEventFeed;
}

- (void)setEventFeed:(GDataFeedCalendarEvent *)feed {
  [mEventFeed autorelease];
  mEventFeed = [feed retain];
}

- (NSError *)eventFetchError {
  return mEventFetchError;
}

- (void)setEventFetchError:(NSError *)error {
  [mEventFetchError release];
  mEventFetchError = [error retain];
}

- (GDataServiceTicket *)eventFetchTicket {
  return mEventFetchTicket;
}

- (void)setEventFetchTicket:(GDataServiceTicket *)ticket {
  [mEventFetchTicket release];
  mEventFetchTicket = [ticket retain];
}

- (GDataFeedACL *)ACLFeed {
  return mACLFeed;
}

- (void)setACLFeed:(GDataFeedACL *)feed {
  [mACLFeed autorelease];
  mACLFeed = [feed retain];
}

- (NSError *)ACLFetchError {
  return mACLFetchError;
}

- (void)setACLFetchError:(NSError *)error {
  [mACLFetchError release];
  mACLFetchError = [error retain];
}

- (GDataServiceTicket *)ACLFetchTicket {
  return mACLFetchTicket;
}

- (void)setACLFetchTicket:(GDataServiceTicket *)ticket {
  [mACLFetchTicket release];
  mACLFetchTicket = [ticket retain];
}

- (GDataFeedCalendarSettings *)settingsFeed {
  return mSettingsFeed;
}

- (void)setSettingsFeed:(GDataFeedCalendarSettings *)feed {
  [mSettingsFeed autorelease];
  mSettingsFeed = [feed retain];
}

- (NSError *)settingsFetchError {
  return mSettingsFetchError;
}

- (void)setSettingsFetchError:(NSError *)error {
  [mSettingsFetchError release];
  mSettingsFetchError = [error retain];
}

- (GDataServiceTicket *)settingsFetchTicket {
  return mSettingsFetchTicket;
}

- (void)setSettingsFetchTicket:(GDataServiceTicket *)ticket {
  [mACLFetchTicket release];
  mACLFetchTicket = [ticket retain];
}

@end
