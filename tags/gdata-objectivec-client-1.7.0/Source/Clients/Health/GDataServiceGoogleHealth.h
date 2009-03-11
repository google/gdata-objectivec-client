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
//  GDataServiceGoogleHealth.h
//

#import "GDataServiceGoogle.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATASERVICEGOOGLEHEALTH_DEFINE_GLOBALS
#define _EXTERN
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

//
// During development, use an instance of the sandbox class,
// GDataServiceGoogleHealthSandbox, as explained at
// http://code.google.com/apis/health/getting_started.html#H9
//
// Create your sandbox account at https://www.google.com/h9
//

// These routines are all simple wrappers around GDataServiceGoogle methods.

// finishedSelector has a signature like:
//   serviceTicket:(GDataServiceTicket *)ticket finishedWithObject:(GDataObject *)object;
// failedSelector has a signature like:
//   serviceTicket:(GDataServiceTicket *)ticket failedWithError:(NSError *)error

@class GDataQueryGoogleHealth;

@interface GDataServiceGoogleHealth : GDataServiceGoogle

// Utilities for making feed URLs.  See
//   http://code.google.com/apis/health/docs/2.0/reference.html#ClientLoginFeeds
//
// The profileID is available from entries of the profile list feed, as
//   NSString *profileID = [[profileListEntry content] stringValue];

+ (NSURL *)profileListFeedURL;
+ (NSURL *)profileFeedURLForProfileID:(NSString *)profileID;
+ (NSURL *)registerFeedURLForProfileID:(NSString *)profileID;
  
// finished callback (see above) is passed an appropriate Google Health feed
- (GDataServiceTicket *)fetchHealthFeedWithURL:(NSURL *)feedURL
                                      delegate:(id)delegate
                             didFinishSelector:(SEL)finishedSelector
                               didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed an appropriate entry
- (GDataServiceTicket *)fetchHealthEntryWithURL:(NSURL *)entryURL
                                       delegate:(id)delegate
                              didFinishSelector:(SEL)finishedSelector
                                didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the inserted entry
- (GDataServiceTicket *)fetchHealthEntryByInsertingEntry:(GDataEntryBase *)entryToInsert
                                              forFeedURL:(NSURL *)feedURL
                                                delegate:(id)delegate
                                       didFinishSelector:(SEL)finishedSelector
                                         didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the updated entry
- (GDataServiceTicket *)fetchHealthEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                            forEntryURL:(NSURL *)entryEditURL
                                               delegate:(id)delegate
                                      didFinishSelector:(SEL)finishedSelector
                                        didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the appropriate Health feed
- (GDataServiceTicket *)fetchHealthQuery:(GDataQueryGoogleHealth *)query
                                delegate:(id)delegate
                       didFinishSelector:(SEL)finishedSelector
                         didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed a nil object
- (GDataServiceTicket *)deleteHealthEntry:(GDataEntryBase *)entryToDelete
                                 delegate:(id)delegate
                        didFinishSelector:(SEL)finishedSelector
                          didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed a nil object
- (GDataServiceTicket *)deleteHealthResourceURL:(NSURL *)resourceEditURL
                                           ETag:(NSString *)etag
                                       delegate:(id)delegate
                              didFinishSelector:(SEL)finishedSelector
                                didFailSelector:(SEL)failedSelector;

+ (NSString *)serviceRootURLString;

@end

@interface GDataServiceGoogleHealthSandbox : GDataServiceGoogleHealth
@end

