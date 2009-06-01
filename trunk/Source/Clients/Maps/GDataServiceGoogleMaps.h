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
//  GDataServiceGoogleMaps.h
//

#import "GDataServiceGoogle.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATASERVICEGOOGLEMAPS_DEFINE_GLOBALS
#define _EXTERN
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

// projections
_EXTERN NSString* const kGDataMapsProjectionFull       _INITIALIZE_AS(@"full");
_EXTERN NSString* const kGDataMapsProjectionBookmarked _INITIALIZE_AS(@"bookmarked");
_EXTERN NSString* const kGDataMapsProjectionOwned      _INITIALIZE_AS(@"owned");
_EXTERN NSString* const kGDataMapsProjectionPublic     _INITIALIZE_AS(@"public");
_EXTERN NSString* const kGDataMapsProjectionUnlisted   _INITIALIZE_AS(@"unlisted");

// currently, no service-specific query parameters
@interface GDataQueryGoogleMaps : GDataQuery
@end


// These routines are all simple wrappers around GDataServiceGoogle methods.

// finishedSelector has a signature like:
//   serviceTicket:(GDataServiceTicket *)ticket finishedWithObject:(GDataObject *)object;
// failedSelector has a signature like:
//   serviceTicket:(GDataServiceTicket *)ticket failedWithError:(NSError *)error

@interface GDataServiceGoogleMaps : GDataServiceGoogle

// Utility for making feed URLs.
//
// For the authenticated user, pass kGDataServiceDefaultUser
//
// Projections are listed above
+ (NSURL *)mapsFeedURLForUserID:(NSString *)userID
                     projection:(NSString *)projection;

// finished callback (see above) is passed an appropriate Google Maps feed
- (GDataServiceTicket *)fetchMapsFeedWithURL:(NSURL *)feedURL
                                    delegate:(id)delegate
                           didFinishSelector:(SEL)finishedSelector
                             didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed an appropriate entry
- (GDataServiceTicket *)fetchMapsEntryWithURL:(NSURL *)entryURL
                                     delegate:(id)delegate
                            didFinishSelector:(SEL)finishedSelector
                              didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the inserted entry
- (GDataServiceTicket *)fetchMapsEntryByInsertingEntry:(GDataEntryBase *)entryToInsert
                                            forFeedURL:(NSURL *)feedURL
                                              delegate:(id)delegate
                                     didFinishSelector:(SEL)finishedSelector
                                       didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the updated entry
- (GDataServiceTicket *)fetchMapsEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                          forEntryURL:(NSURL *)entryEditURL
                                             delegate:(id)delegate
                                    didFinishSelector:(SEL)finishedSelector
                                      didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the appropriate maps feed
- (GDataServiceTicket *)fetchMapsQuery:(GDataQueryGoogleMaps *)query
                              delegate:(id)delegate
                     didFinishSelector:(SEL)finishedSelector
                       didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed a nil object
- (GDataServiceTicket *)deleteMapsEntry:(GDataEntryBase *)entryToDelete
                               delegate:(id)delegate
                      didFinishSelector:(SEL)finishedSelector
                        didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed a nil object
- (GDataServiceTicket *)deleteMapsResourceURL:(NSURL *)resourceEditURL
                                         ETag:(NSString *)etag
                                     delegate:(id)delegate
                            didFinishSelector:(SEL)finishedSelector
                              didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed a feed of batch results
- (GDataServiceTicket *)fetchMapsBatchFeedWithBatchFeed:(GDataFeedBase *)batchFeed
                                        forBatchFeedURL:(NSURL *)feedURL
                                               delegate:(id)delegate
                                      didFinishSelector:(SEL)finishedSelector
                                        didFailSelector:(SEL)failedSelector;

+ (NSString *)serviceRootURLString;

@end
