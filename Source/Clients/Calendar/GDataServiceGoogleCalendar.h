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
//  GDataServiceGoogleCalendar.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE

#import "GDataServiceGoogle.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATASERVICEGOOGLECALENDAR_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN GDATA_EXTERN
#define _INITIALIZE_AS(x)
#endif

// default feed of calendars
_EXTERN NSString* const kGDataGoogleCalendarDefaultFeed _INITIALIZE_AS(@"https://www.google.com/calendar/feeds/default");

// owned calendars; supports inserting and deleting calendars
_EXTERN NSString* const kGDataGoogleCalendarDefaultOwnCalendarsFeed _INITIALIZE_AS(@"https://www.google.com/calendar/feeds/default/owncalendars/full");

// subscribed calendars; insert adds a subscription, delete removes a subscription
_EXTERN NSString* const kGDataGoogleCalendarDefaultAllCalendarsFeed _INITIALIZE_AS(@"https://www.google.com/calendar/feeds/default/allcalendars/full");

// calendar events feed
_EXTERN NSString* const kGDataGoogleCalendarDefaultPrivateFullFeed _INITIALIZE_AS(@"https://www.google.com/calendar/feeds/default/private/full");


// QuickAdd:  
//
// Google Calendar can parse natural language text to create a
// Calendar entry.  Create the entry by setting the content, 
// then insert it into the calendar:
//
//  GDataEntryCalendarEvent *newEvent = [GDataEntryCalendarEvent calendarEvent];
//  [newEvent setContentWithString:@"Party today at 4pm"];
//  [newEvent setIsQuickAdd:YES];
//
// then pass the event to fetchEntryByInsertingEntry:
//


@interface GDataServiceGoogleCalendar : GDataServiceGoogle

+ (NSURL *)calendarFeedURLForUsername:(NSString *)username;

+ (NSURL *)settingsFeedURLForUsername:(NSString *)username;

+ (NSURL *)freeBusyURLForUsername:(NSString *)username;

+ (NSURL *)freeBusyURLForGroup:(NSString *)groupname;

- (GDataServiceTicket *)fetchCalendarFeedForUsername:(NSString *)username
                                            delegate:(id)delegate
                                   didFinishSelector:(SEL)finishedSelector;

// clients may use these fetch methods of GDataServiceGoogle
//
//  - (GDataServiceTicket *)fetchFeedWithURL:(NSURL *)feedURL delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//  - (GDataServiceTicket *)fetchFeedWithQuery:(GDataQuery *)query delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//  - (GDataServiceTicket *)fetchEntryWithURL:(NSURL *)entryURL delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//  - (GDataServiceTicket *)fetchEntryByInsertingEntry:(GDataEntryBase *)entryToInsert forFeedURL:(NSURL *)feedURL delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//  - (GDataServiceTicket *)fetchEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//  - (GDataServiceTicket *)deleteEntry:(GDataEntryBase *)entryToDelete delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//  - (GDataServiceTicket *)deleteResourceURL:(NSURL *)resourceEditURL ETag:(NSString *)etag delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//  - (GDataServiceTicket *)fetchFeedWithBatchFeed:(GDataFeedBase *)batchFeed forBatchFeedURL:(NSURL *)feedURL delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//
// finishedSelector has a signature like this for feed fetches:
// - (void)serviceTicket:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedBase *)feed error:(NSError *)error;
//
// or this for entry fetches:
// - (void)serviceTicket:(GDataServiceTicket *)ticket finishedWithEntry:(GDataEntryBase *)entry error:(NSError *)error;
//
// The class of the returned feed or entry is determined by the URL fetched.


+ (NSString *)serviceRootURLString;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE
