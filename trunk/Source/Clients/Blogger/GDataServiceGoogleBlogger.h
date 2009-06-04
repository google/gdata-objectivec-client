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
//  GDataServiceGoogleBlogger.h
//

#import "GDataServiceGoogle.h"


// These routines are all simple wrappers around GDataServiceGoogle methods.

// finishedSelector has a signature like:
//   serviceTicket:(GDataServiceTicket *)ticket finishedWithObject:(GDataObject *)object;
// failedSelector has a signature like:
//   serviceTicket:(GDataServiceTicket *)ticket failedWithError:(NSError *)error

@interface GDataServiceGoogleBlogger : GDataServiceGoogle

// use kGDataServiceDefaultUser for the feed for the authenticated user
+ (NSURL *)blogFeedURLForUserID:(NSString *)user;

// Fetches with dynamic feed/class types are not yet supported by the
// Blogger API server.
//
// Use fetchAuthenticatedFeedWithURL:, fetchAuthenticatedEntryWithURL:,
// and fetchAuthenticatedFeedWithQuery: instead for now.
//
//- (GDataServiceTicket *)fetchBloggerFeedWithURL:(NSURL *)feedURL
//                                       delegate:(id)delegate
//                              didFinishSelector:(SEL)finishedSelector
//                                didFailSelector:(SEL)failedSelector;
//
//- (GDataServiceTicket *)fetchBloggerEntryWithURL:(NSURL *)entryURL
//                                        delegate:(id)delegate
//                               didFinishSelector:(SEL)finishedSelector
//                                 didFailSelector:(SEL)failedSelector;

- (GDataServiceTicket *)fetchBloggerEntryByInsertingEntry:(GDataEntryBase *)entryToInsert
                                               forFeedURL:(NSURL *)feedURL
                                                 delegate:(id)delegate
                                        didFinishSelector:(SEL)finishedSelector
                                          didFailSelector:(SEL)failedSelector;

- (GDataServiceTicket *)fetchBloggerEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                             forEntryURL:(NSURL *)entryEditURL
                                                delegate:(id)delegate
                                       didFinishSelector:(SEL)finishedSelector
                                         didFailSelector:(SEL)failedSelector;

- (GDataServiceTicket *)deleteBloggerEntry:(GDataEntryBase *)entryToDelete
                                  delegate:(id)delegate
                         didFinishSelector:(SEL)finishedSelector
                           didFailSelector:(SEL)failedSelector;

- (GDataServiceTicket *)deleteBloggerResourceURL:(NSURL *)resourceEditURL
                                            ETag:(NSString *)etag
                                        delegate:(id)delegate
                               didFinishSelector:(SEL)finishedSelector
                                 didFailSelector:(SEL)failedSelector;

//- (GDataServiceTicket *)fetchBloggerQuery:(GDataQuery *)query
//                                 delegate:(id)delegate
//                        didFinishSelector:(SEL)finishedSelector
//                          didFailSelector:(SEL)failedSelector;

+ (NSString *)serviceRootURLString;

@end
