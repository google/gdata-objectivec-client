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
//  CalendarSampleWindowController.h
//

#import <Cocoa/Cocoa.h>

#import "GData/GData.h"

@interface CalendarSampleWindowController : NSWindowController {
  IBOutlet NSTextField *mUsernameField;
  IBOutlet NSSecureTextField *mPasswordField;
  
  IBOutlet NSTableView *mCalendarTable;
  IBOutlet NSProgressIndicator *mCalendarProgressIndicator;
  IBOutlet NSTextView *mCalendarResultTextField;
  IBOutlet NSButton *mCalendarCancelButton;
  
  IBOutlet NSSegmentedControl *mCalendarSegmentedControl;
  IBOutlet NSButton *mAddCalendarButton;
  IBOutlet NSButton *mRenameCalendarButton;
  IBOutlet NSButton *mDeleteCalendarButton;
  IBOutlet NSTextField *mCalendarNameField;

  IBOutlet NSTableView *mEventTable;
  IBOutlet NSProgressIndicator *mEventProgressIndicator;
  IBOutlet NSTextView *mEventResultTextField;
  IBOutlet NSButton *mEventCancelButton;
  
  IBOutlet NSButton *mAddEventButton;
  IBOutlet NSButton *mDeleteEventButton;
  IBOutlet NSButton *mEditEventButton;
  IBOutlet NSButton *mMapEventButton;
  IBOutlet NSButton *mQueryTodayEventButton;
  
  IBOutlet NSSegmentedControl *mEntrySegmentedControl;
  
  GDataFeedCalendar *mCalendarFeed;
  GDataServiceTicket *mCalendarFetchTicket;
  NSError *mCalendarFetchError;
    
  GDataFeedCalendarEvent *mEventFeed;
  GDataServiceTicket *mEventFetchTicket;
  NSError *mEventFetchError;

  GDataFeedACL *mACLFeed;
  GDataServiceTicket *mACLFetchTicket;
  NSError *mACLFetchError;

  GDataFeedCalendarSettings *mSettingsFeed;
  GDataServiceTicket *mSettingsFetchTicket;
  NSError *mSettingsFetchError;
}

+ (CalendarSampleWindowController *)sharedCalendarSampleWindowController;

- (IBAction)getCalendarClicked:(id)sender;

- (IBAction)cancelCalendarFetchClicked:(id)sender;
- (IBAction)cancelEventFetchClicked:(id)sender;

- (IBAction)calendarSegmentClicked:(id)sender;
- (IBAction)addCalendarClicked:(id)sender;
- (IBAction)renameCalendarClicked:(id)sender;
- (IBAction)deleteCalendarClicked:(id)sender;

- (IBAction)addEventClicked:(id)sender;
- (IBAction)editEventClicked:(id)sender;
- (IBAction)deleteEventClicked:(id)sender;
- (IBAction)mapEventClicked:(id)sender;
- (IBAction)queryTodayClicked:(id)sender;

- (IBAction)entrySegmentClicked:(id)sender;

- (IBAction)loggingCheckboxClicked:(id)sender;

@end
