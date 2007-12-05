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
//  GDataServiceGoogleCalendar.m
//

#define GDATASERVICEGOOGLECALENDAR_DEFINE_GLOBALS 1
#import "GDataServiceGoogleCalendar.h"

#import "GDataEntryCalendarEvent.h"
#import "GDataEntryCalendar.h"
#import "GDataFeedCalendar.h"
#import "GDataFeedCalendarEvent.h"
#import "GDataQueryCalendar.h"

// These routines are all simple wrappers around GDataServiceGoogle methods

@implementation GDataServiceGoogleCalendar

- (GDataServiceTicket *)fetchCalendarFeedForUsername:(NSString *)username
                                            delegate:(id)delegate
                                   didFinishSelector:(SEL)finishedSelector
                                     didFailSelector:(SEL)failedSelector {
  
  // the calendar feed is the base feed plus the username
  NSString *usernameEscaped = [self stringByURLEncoding:username];
  
  NSString *rootURLString = [self serviceRootURLString];
  NSString *feedURLString = [rootURLString stringByAppendingString:usernameEscaped];
  
  NSURL *url = [NSURL URLWithString:feedURLString];
  
  return [self fetchCalendarFeedWithURL:url
                               delegate:delegate
                      didFinishSelector:finishedSelector
                        didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchCalendarFeedWithURL:(NSURL *)feedURL
                                        delegate:(id)delegate
                               didFinishSelector:(SEL)finishedSelector
                                 didFailSelector:(SEL)failedSelector {
  
  return [self fetchAuthenticatedFeedWithURL:feedURL 
                                   feedClass:[GDataFeedCalendar class]
                                    delegate:delegate
                           didFinishSelector:finishedSelector
                             didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchCalendarEntryByInsertingEntry:(GDataEntryCalendar *)entryToInsert
                                                forFeedURL:(NSURL *)calendarFeedURL
                                                  delegate:(id)delegate
                                         didFinishSelector:(SEL)finishedSelector
                                           didFailSelector:(SEL)failedSelector {
  
  if ([entryToInsert namespaces] == nil) {
    [entryToInsert setNamespaces:[GDataEntryCalendar calendarNamespaces]]; 
  }
  
  return [self fetchAuthenticatedEntryByInsertingEntry:entryToInsert
                                            forFeedURL:calendarFeedURL
                                              delegate:delegate
                                     didFinishSelector:finishedSelector
                                       didFailSelector:failedSelector];
  
}

- (GDataServiceTicket *)fetchCalendarEntryByUpdatingEntry:(GDataEntryCalendar *)entryToUpdate
                                              forEntryURL:(NSURL *)calendarEntryEditURL
                                                 delegate:(id)delegate
                                        didFinishSelector:(SEL)finishedSelector
                                          didFailSelector:(SEL)failedSelector {
  
  if ([entryToUpdate namespaces] == nil) {
    [entryToUpdate setNamespaces:[GDataEntryCalendar calendarNamespaces]]; 
  }
  
  return [self fetchAuthenticatedEntryByUpdatingEntry:entryToUpdate
                                          forEntryURL:calendarEntryEditURL
                                             delegate:delegate
                                    didFinishSelector:finishedSelector
                                      didFailSelector:failedSelector];
  
}

- (GDataServiceTicket *)fetchCalendarEventFeedWithURL:(NSURL *)feedURL
                                             delegate:(id)delegate
                                    didFinishSelector:(SEL)finishedSelector
                                      didFailSelector:(SEL)failedSelector {
  
  return [self fetchAuthenticatedFeedWithURL:feedURL 
                                   feedClass:[GDataFeedCalendarEvent class]
                                    delegate:delegate
                           didFinishSelector:finishedSelector
                             didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchCalendarEventByInsertingEntry:(GDataEntryCalendarEvent *)entryToInsert
                                                forFeedURL:(NSURL *)calendarEventFeedURL
                                                  delegate:(id)delegate
                                         didFinishSelector:(SEL)finishedSelector
                                           didFailSelector:(SEL)failedSelector {
  
  if ([entryToInsert namespaces] == nil) {
    [entryToInsert setNamespaces:[GDataEntryCalendarEvent calendarEventNamespaces]]; 
  }
  
  return [self fetchAuthenticatedEntryByInsertingEntry:entryToInsert
                                            forFeedURL:calendarEventFeedURL
                                              delegate:delegate
                                     didFinishSelector:finishedSelector
                                       didFailSelector:failedSelector];
  
}

- (GDataServiceTicket *)fetchCalendarEventEntryByUpdatingEntry:(GDataEntryCalendarEvent *)entryToUpdate
                                                   forEntryURL:(NSURL *)calendarEventEntryEditURL
                                                      delegate:(id)delegate
                                             didFinishSelector:(SEL)finishedSelector
                                               didFailSelector:(SEL)failedSelector {
  
  if ([entryToUpdate namespaces] == nil) {
    [entryToUpdate setNamespaces:[GDataEntryCalendarEvent calendarEventNamespaces]]; 
  }
  
  
  return [self fetchAuthenticatedEntryByUpdatingEntry:entryToUpdate
                                          forEntryURL:calendarEventEntryEditURL
                                             delegate:delegate
                                    didFinishSelector:finishedSelector
                                      didFailSelector:failedSelector];
  
}

- (GDataServiceTicket *)deleteCalendarResourceURL:(NSURL *)resourceEditURL
                                         delegate:(id)delegate
                                didFinishSelector:(SEL)finishedSelector
                                  didFailSelector:(SEL)failedSelector {
  
  return [self deleteAuthenticatedResourceURL:resourceEditURL
                                     delegate:delegate
                            didFinishSelector:finishedSelector
                              didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchCalendarQuery:(GDataQueryCalendar *)query
                                  delegate:(id)delegate
                         didFinishSelector:(SEL)finishedSelector
                           didFailSelector:(SEL)failedSelector {
  
  return [self fetchCalendarFeedWithURL:[query URL]
                               delegate:delegate
                      didFinishSelector:finishedSelector
                        didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchCalendarEventQuery:(GDataQueryCalendar *)query
                                       delegate:(id)delegate
                              didFinishSelector:(SEL)finishedSelector
                                didFailSelector:(SEL)failedSelector {
  
  return [self fetchCalendarEventFeedWithURL:[query URL]
                                    delegate:delegate
                           didFinishSelector:finishedSelector
                             didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchCalendarEventBatchFeedWithBatchFeed:(GDataFeedCalendarEvent *)batchFeed
                                                 forBatchFeedURL:(NSURL *)feedURL
                                                        delegate:(id)delegate
                                               didFinishSelector:(SEL)finishedSelector
                                                 didFailSelector:(SEL)failedSelector {
  
  return [self fetchAuthenticatedFeedWithBatchFeed:batchFeed
                                   forBatchFeedURL:feedURL
                                          delegate:delegate
                                 didFinishSelector:finishedSelector
                                   didFailSelector:failedSelector];
}

- (NSString *)serviceID {
  return @"cl";
}

- (NSString *)serviceRootURLString {
  return @"http://www.google.com/calendar/feeds/"; 
}


@end

