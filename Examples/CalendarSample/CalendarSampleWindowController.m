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

// Note: Though this sample doesn't demonstrate it, GData responses are
//       typically chunked, so check all returned feeds for "next" links
//       (use -nextLink method from the GDataLinkArray category on the
//       links array of GData objects.)

#import "CalendarSampleWindowController.h"

#import "EditEventWindowController.h"

@interface CalendarSampleWindowController (PrivateMethods)
- (void)updateUI;

- (void)fetchAllCalendars;
- (void)fetchSelectedCalendarEvents;
- (void)addAnEvent;
- (void)editSelectedEvent;
- (void)deleteSelectedEvent;
- (void)queryTodaysEvents;

- (GDataServiceGoogleCalendar *)calendarService;
- (GDataEntryCalendar *)selectedCalendar;
- (GDataEntryCalendarEvent *)selectedEvent;

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
  
@end

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

  [self updateUI];
}

- (void)dealloc {
  [mCalendarFeed release];
  [mCalendarFetchError release];
  [mCalendarFetchTicket release];
  
  [mEventFeed release];
  [mEventFetchError release];
  [mEventFetchTicket release];
  
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
    } else {
      
    }
  }
  [mCalendarResultTextField setString:calendarResultStr];
  
  // event list display
  [mEventTable reloadData]; 
  
  if (mEventFetchTicket != nil) {
    [mEventProgressIndicator startAnimation:self];  
  } else {
    [mEventProgressIndicator stopAnimation:self];  
  }
  
  // event fetch result or selected item
  NSString *eventResultStr = @"";
  if (mEventFetchError) {
    eventResultStr = [mEventFetchError description];
  } else {
    GDataEntryCalendarEvent *event = [self selectedEvent];
    if (event) {
      eventResultStr = [event description];
    }
  }
  [mEventResultTextField setString:eventResultStr];
  
  // enable/disable cancel buttons
  [mCalendarCancelButton setEnabled:(mCalendarFetchTicket != nil)];
  [mEventCancelButton setEnabled:(mEventFetchTicket != nil)];
  
  // enable/disable buttons
  BOOL isEventSelected = ([self selectedEvent] != nil);
  [mDeleteEventButton setEnabled:isEventSelected];
  [mEditEventButton setEnabled:isEventSelected];
  
  BOOL isCalendarSelected = ([self selectedCalendar] != nil);
  [mAddEventButton setEnabled:isCalendarSelected];
  [mQueryTodayEventButton setEnabled:isCalendarSelected];
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
  [self addAnEvent];
}

- (IBAction)editEventClicked:(id)sender {
  [self editSelectedEvent];
}

- (IBAction)deleteEventClicked:(id)sender {
  [self deleteSelectedEvent];
}

- (IBAction)queryTodayClicked:(id)sender {
  [self queryTodaysEvents];
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
    
    [service setUserAgent:@"SampleCalendarApp"];
    [service setShouldCacheDatedData:YES];
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

// get the event selected in the bottom list, or nil if none
- (GDataEntryCalendarEvent *)selectedEvent {
  
  NSArray *events = [mEventFeed entries];
  int rowIndex = [mEventTable selectedRow];
  if ([events count] > 0 && rowIndex > -1) {
    
    GDataEntryCalendarEvent *event = [events objectAtIndex:rowIndex];
    return event;
  }
  return nil;
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

  NSString *username = [mUsernameField stringValue];
  
  GDataServiceGoogleCalendar *service = [self calendarService];
  GDataServiceTicket *ticket;
  ticket = [service fetchCalendarFeedForUsername:username
                                        delegate:self
                               didFinishSelector:@selector(calendarListFetchTicket:finishedWithFeed:)
                                 didFailSelector:@selector(calendarListFetchTicket:failedWithError:)];
  [self setCalendarFetchTicket:ticket];
  
  [self updateUI];
}

//
// calendar list fetch callbacks
//

// finished calendar list successfully
- (void)calendarListFetchTicket:(GDataServiceTicket *)ticket
               finishedWithFeed:(GDataFeedCalendar *)object {
  
  [self setCalendarFeed:object];
  [self setCalendarFetchError:nil];    
  [self setCalendarFetchTicket:nil];

  [self updateUI];
} 

// failed
- (void)calendarListFetchTicket:(GDataServiceTicket *)ticket
                failedWithError:(NSError *)error {
  
  [self setCalendarFeed:nil];
  [self setCalendarFetchError:error];    
  [self setCalendarFetchTicket:nil];

  [self updateUI];
}

#pragma mark Fetch a calendar's events

// for the calendar selected in the top list, begin retrieving the list of
// events
- (void)fetchSelectedCalendarEvents {
  
  GDataEntryCalendar *calendar = [self selectedCalendar];
  if (calendar) {
    
    GDataLink *link = [[calendar links] alternateLink];
    NSURL *feedURL = [link URL];
    
    if (feedURL) {
      
      [self setEventFeed:nil];
      [self setEventFetchError:nil];
      [self setEventFetchTicket:nil];

      GDataServiceGoogleCalendar *service = [self calendarService];
      GDataServiceTicket *ticket;
      ticket = [service fetchCalendarEventFeedWithURL:feedURL
                                             delegate:self
                                    didFinishSelector:@selector(calendarEventsTicket:finishedWithEntries:)
                                      didFailSelector:@selector(calendarEventsTicket:failedWithError:)];
      [self setEventFetchTicket:ticket];

      [self updateUI];  
    }
  }
}

//
// entries list fetch callbacks
//

// fetched event list successfully
- (void)calendarEventsTicket:(GDataServiceTicket *)ticket
         finishedWithEntries:(GDataFeedCalendarEvent *)object {
  
  [self setEventFeed:object];
  [self setEventFetchError:nil];
  [self setEventFetchTicket:nil];
  
  [self updateUI];
} 

// failed
- (void)calendarEventsTicket:(GDataServiceTicket *)ticket
             failedWithError:(NSError *)error {
  
  [self setEventFeed:nil];
  [self setEventFetchError:error];
  [self setEventFetchTicket:nil];
  
  [self updateUI];
  
}

#pragma mark Add an event

- (void)addAnEvent {
  
  // make a new event
  GDataEntryCalendarEvent *newEvent = [GDataEntryCalendarEvent calendarEvent];
  
  // set a title, description, and author
  [newEvent setTitle:[GDataTextConstruct textConstructWithString:@"Sample Added Event"]];
  [newEvent setSummary:[GDataTextConstruct textConstructWithString:@"Description of sample added event"]];
  
  GDataPerson *authorPerson = [GDataPerson personWithName:@"Fred Flintstone"
                                                    email:@"fred.flinstone@bounce.spuriousmail.com"];
  [newEvent addAuthor:authorPerson];
  
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
  [when addReminders:reminder];
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
      NSURL *feedURL = [NSURL URLWithString:[[[calendar links] alternateLink] href]];
      
      [service fetchCalendarEventByInsertingEntry:event
                                       forFeedURL:feedURL
                                         delegate:self
                                didFinishSelector:@selector(addEventTicket:addedEntry:)
                                  didFailSelector:@selector(addEventTicket:failedWithError:)];
    }
  }
  [addEventController autorelease];
}

// event added successfully
- (void)addEventTicket:(GDataServiceTicket *)ticket
            addedEntry:(GDataFeedCalendarEvent *)object {
  
  // tell the user that the add worked
  NSBeginAlertSheet(@"Added Event", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Event added");
  
  // refetch the current calendar's events
  [self fetchSelectedCalendarEvents];
  [self updateUI];
} 

// failure to add event
- (void)addEventTicket:(GDataServiceTicket *)ticket
       failedWithError:(NSError *)error {
  
  NSBeginAlertSheet(@"Add failed", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Event add failed: %@", error);
  
}


#pragma mark Edit an event

- (void)editSelectedEvent {
  
  // display the event edit dialog
  GDataEntryCalendarEvent *event = [self selectedEvent];
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
      
      GDataLink *link = [[event links] editLink];
      NSString *href = [link href];
      
      GDataServiceGoogleCalendar *service = [self calendarService];
      [service fetchCalendarEventEntryByUpdatingEntry:event
                                          forEntryURL:[NSURL URLWithString:href]
                                             delegate:self
                                    didFinishSelector:@selector(editEventTicket:editedEntry:)
                                      didFailSelector:@selector(editEventTicket:failedWithError:)];
      
    }
  }
  [editEventController autorelease];
}

// event edited successfully
- (void)editEventTicket:(GDataServiceTicket *)ticket
            editedEntry:(GDataFeedCalendarEvent *)object {
  
  // tell the user that the update worked
  NSBeginAlertSheet(@"Updated Event", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Event updated");
  
  // re-fetch the selected calendar's events
  [self fetchSelectedCalendarEvents];
  [self updateUI];
} 

// failure to submit edited event
- (void)editEventTicket:(GDataServiceTicket *)ticket
        failedWithError:(NSError *)error {
  
  NSBeginAlertSheet(@"Update failed", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Event update failed: %@", error);
  
}

#pragma mark Delete an event

- (void)deleteSelectedEvent {
  
  GDataEntryCalendarEvent *event = [self selectedEvent];
  if (event) {
    // make the user confirm that the selected event should be deleted
    NSBeginAlertSheet(@"Delete Event", @"Delete", @"Cancel", nil,
                      [self window], self, 
                      @selector(deleteSheetDidEnd:returnCode:contextInfo:),
                      nil, nil, @"Delete the event \"%@\"?",
                      [event title]);
  }
}

// delete dialog callback
- (void)deleteSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
  
  if (returnCode == NSAlertDefaultReturn) {
    
    // delete the event
    GDataEntryCalendarEvent *event = [self selectedEvent];
    GDataLink *link = [[event links] editLink];
    NSString *href = [link href];
    
    if (href) {
      GDataServiceGoogleCalendar *service = [self calendarService];
      [service deleteCalendarResourceURL:[NSURL URLWithString:href]
                                delegate:self 
                       didFinishSelector:@selector(deleteTicket:deletedEntry:)
                         didFailSelector:@selector(deleteTicket:failedWithError:)];
    }
  }
}

// event deleted successfully
- (void)deleteTicket:(GDataServiceTicket *)ticket
        deletedEntry:(GDataFeedCalendarEvent *)object {
  
  NSBeginAlertSheet(@"Deleted Event", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Event deleted");
  
  // re-fetch the selected calendar's events
  [self fetchSelectedCalendarEvents];
  [self updateUI];
} 

// failure to delete event
- (void)deleteTicket:(GDataServiceTicket *)ticket
     failedWithError:(NSError *)error {
  
  NSBeginAlertSheet(@"Delete failed", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Event delete failed: %@", error);
  
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
- (void)queryTodaysEvents {

  GDataServiceGoogleCalendar *service = [self calendarService];
  
  GDataEntryCalendar *calendar = [self selectedCalendar];
  NSURL *feedURL = [NSURL URLWithString:[[[calendar links] alternateLink] href]];

  // make start and end times for today, at the beginning and end of the day
  
  GDataDateTime *startOfDay = [self dateTimeForTodayAtHour:0 minute:0 second:0];
  GDataDateTime *endOfDay = [self dateTimeForTodayAtHour:23 minute:59 second:59];
  
  // make the query
  GDataQueryCalendar* queryCal = [GDataQueryCalendar calendarQueryWithFeedURL:feedURL];
  [queryCal setStartIndex:1];
  [queryCal setMaxResults:10];
  [queryCal setMinimumStartTime:startOfDay]; 
  [queryCal setMaximumStartTime:endOfDay];

  [service fetchCalendarEventFeedWithURL:[queryCal URL]
                                delegate:self
                       didFinishSelector:@selector(queryTicket:finishedWithEntries:)
                         didFailSelector:@selector(queryTicket:failedWithError:)];
}

// today's events successfully retrieved
- (void)queryTicket:(GDataServiceTicket *)ticket
finishedWithEntries:(GDataFeedCalendarEvent *)object {
  
  NSArray *entries = [object entries];
  
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
  
} 

// failure to fetch today's events
- (void)queryTicket:(GDataServiceTicket *)ticket
    failedWithError:(NSError *)error {
  
  NSBeginAlertSheet(@"Query failed", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Query failed: %@", error);
  
}


#pragma mark TableView delegate methods
//
// table view delegate methods
//

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  
  if ([notification object] == mCalendarTable) {
    // the user clicked on a calendar, so fetch its events
    [self fetchSelectedCalendarEvents];
  } else {
    // the user clicked on an event; just display it below the event table
    [self updateUI]; 
  }
}

// table view data source methods
- (int)numberOfRowsInTableView:(NSTableView *)tableView {
  if (tableView == mCalendarTable) {
    return [[mCalendarFeed entries] count];
  } else {
    return [[mEventFeed entries] count];
  }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
  if (tableView == mCalendarTable) {
    // get the calendar entry's title
    GDataEntryCalendar *calendar = [[mCalendarFeed entries] objectAtIndex:row];
    return [[calendar title] stringValue];
  } else {
    // get the event entry's title
    GDataEntryCalendarEvent *eventEntry = [[mEventFeed entries] objectAtIndex:row];
    return [[eventEntry title] stringValue];
  }
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

- (void)setCalendarFetchTicket:(GDataServiceTicket *)ticket {
  [mCalendarFetchTicket release];
  mCalendarFetchTicket = [ticket retain];
}

- (GDataServiceTicket *)calendarFetchTicket {
  return mCalendarFetchTicket; 
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

- (void)setEventFetchTicket:(GDataServiceTicket *)ticket {
  [mEventFetchTicket release];
  mEventFetchTicket = [ticket retain];
}

- (GDataServiceTicket *)eventFetchTicket {
  return mEventFetchTicket; 
}
@end
