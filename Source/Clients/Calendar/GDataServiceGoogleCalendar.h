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

#import <Cocoa/Cocoa.h>

#import "GDataServiceGoogle.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATASERVICEGOOGLECALENDAR_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* kGDataGoogleCalendarDefaultFeed _INITIALIZE_AS(@"http://www.google.com/calendar/feeds/default");
_EXTERN NSString* kGDataGoogleCalendarDefaultPrivateFullFeed _INITIALIZE_AS(@"http://www.google.com/calendar/feeds/default/private/full");

@class GDataEntryCalendar;
@class GDataEntryCalendarEvent;
@class GDataQueryCalendar;

// These routines are all simple wrappers around GDataServiceGoogle methods.

// finishedSelector has signature like:
//   serviceTicket:(GDataServiceTicket *)fetcher finishedWithObject:(GDataObject *)object;
// failedSelector has signature like:
//   serviceTicket:(GDataServiceTicket *)ticket failedWithError:(NSError *)error

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
// then pass the event to fetchCalendarEventByInsertingEntry:
//


@interface GDataServiceGoogleCalendar : GDataServiceGoogle 

- (NSString *)serviceRootURLString;

// finished callback (see above) is passed a GDataFeedCalendar
- (GDataServiceTicket *)fetchCalendarFeedForUsername:(NSString *)username
                                            delegate:(id)delegate
                                   didFinishSelector:(SEL)finishedSelector
                                     didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed a GDataFeedCalendar
- (GDataServiceTicket *)fetchCalendarFeedWithURL:(NSURL *)feedURL
                                        delegate:(id)delegate
                               didFinishSelector:(SEL)finishedSelector
                                 didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed a GDataEntryCalendar
- (GDataServiceTicket *)fetchCalendarEntryByInsertingEntry:(GDataEntryCalendar *)entryToInsert
                                                forFeedURL:(NSURL *)calendarFeedURL
                                                  delegate:(id)delegate
                                         didFinishSelector:(SEL)finishedSelector
                                           didFailSelector:(SEL)failedSelector;  


// finished callback (see above) is passed a GDataFeedCalendarEvent
- (GDataServiceTicket *)fetchCalendarEventFeedWithURL:(NSURL *)feedURL
                                             delegate:(id)delegate
                                    didFinishSelector:(SEL)finishedSelector
                                      didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the GDataEntryCalendarEvent
- (GDataServiceTicket *)fetchCalendarEventByInsertingEntry:(GDataEntryCalendarEvent *)entryToInsert
                                                forFeedURL:(NSURL *)calendarEventFeedURL
                                                  delegate:(id)delegate
                                         didFinishSelector:(SEL)finishedSelector
                                           didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the GDataEntryCalendarEvent
- (GDataServiceTicket *)fetchCalendarEventEntryByUpdatingEntry:(GDataEntryCalendarEvent *)entryToUpdate
                                                         forEntryURL:(NSURL *)calendarEventEntryEditURL
                                                            delegate:(id)delegate
                                                   didFinishSelector:(SEL)finishedSelector
                                                     didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the GDataFeedCalendar
- (GDataServiceTicket *)fetchCalendarQuery:(GDataQueryCalendar *)query
                                  delegate:(id)delegate
                         didFinishSelector:(SEL)finishedSelector
                           didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the GDataFeedCalendarEvent
- (GDataServiceTicket *)fetchCalendarEventQuery:(GDataQueryCalendar *)query
                                       delegate:(id)delegate
                              didFinishSelector:(SEL)finishedSelector
                                didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed a nil object
- (GDataServiceTicket *)deleteCalendarResourceURL:(NSURL *)resourceEditURL
                                         delegate:(id)delegate
                                didFinishSelector:(SEL)finishedSelector
                                  didFailSelector:(SEL)failedSelector;

@end
