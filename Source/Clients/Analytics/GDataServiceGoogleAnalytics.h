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
//  GDataServiceGoogleAnalytics.h
//

#import "GDataServiceGoogle.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATASERVICEGOOGLEANALYTICS_DEFINE_GLOBALS
#define _EXTERN
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataGoogleAnalyticsDefaultAccountFeed _INITIALIZE_AS(@"https://www.google.com/analytics/feeds/accounts/default");

@class GDataQueryAnalytics;

// These routines are all simple wrappers around GDataServiceGoogle methods.

// finishedSelector has a signature like:
//   serviceTicket:(GDataServiceTicket *)ticket finishedWithObject:(GDataObject *)object;
// failedSelector has a signature like:
//   serviceTicket:(GDataServiceTicket *)ticket failedWithError:(NSError *)error

@interface GDataServiceGoogleAnalytics : GDataServiceGoogle

// NOTE: Until the analytics server starts returning feeds and entries with kind
// category elements, fetchAnalyticsFeedWithURL: fetchAnalyticsEntryWithURL:,
// and fetchAnalyticsQuery: will not work since the class of the returned feed
// or entry cannot be determined from the XML.
//
// Instead, use GDataServiceGoogle's methods fetchAuthenticatedFeedWithURL: and
// fetchedAuthenticatedEntryWithURL:, and fetchAuthenticatedFeedWithQuery:

- (GDataServiceTicket *)fetchAnalyticsFeedWithURL:(NSURL *)feedURL // see note above
                                         delegate:(id)delegate
                                didFinishSelector:(SEL)finishedSelector
                                  didFailSelector:(SEL)failedSelector;

- (GDataServiceTicket *)fetchAnalyticsEntryWithURL:(NSURL *)entryURL // see note above
                                          delegate:(id)delegate
                                 didFinishSelector:(SEL)finishedSelector
                                   didFailSelector:(SEL)failedSelector;

- (GDataServiceTicket *)fetchAnalyticsEntryByInsertingEntry:(GDataEntryBase *)entryToInsert
                                                 forFeedURL:(NSURL *)feedURL
                                                   delegate:(id)delegate
                                          didFinishSelector:(SEL)finishedSelector
                                            didFailSelector:(SEL)failedSelector;

- (GDataServiceTicket *)fetchAnalyticsEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                               forEntryURL:(NSURL *)entryEditURL
                                                  delegate:(id)delegate
                                         didFinishSelector:(SEL)finishedSelector
                                           didFailSelector:(SEL)failedSelector;

- (GDataServiceTicket *)deleteAnalyticsEntry:(GDataEntryBase *)entryToDelete
                                    delegate:(id)delegate
                           didFinishSelector:(SEL)finishedSelector
                             didFailSelector:(SEL)failedSelector;

- (GDataServiceTicket *)deleteAnalyticsResourceURL:(NSURL *)resourceEditURL
                                              ETag:(NSString *)etag
                                          delegate:(id)delegate
                                 didFinishSelector:(SEL)finishedSelector
                                   didFailSelector:(SEL)failedSelector;

- (GDataServiceTicket *)fetchAnalyticsQuery:(GDataQueryAnalytics *)query // see note above
                                   delegate:(id)delegate
                          didFinishSelector:(SEL)finishedSelector
                            didFailSelector:(SEL)failedSelector;

@end
