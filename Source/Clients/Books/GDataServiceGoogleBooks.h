/* Copyright (c) 2008 Google Inc.
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
//  GDataServiceGoogleBooks.h
//

#import "GDataServiceGoogle.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATASERVICEGOOGLEBOOKS_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

// feed for querying all volumes
_EXTERN NSString* const kGDataGoogleBooksVolumeFeed _INITIALIZE_AS(@"http://books.google.com/books/feeds/volumes");

// feeds for the authenticated user's annotations and collections
_EXTERN NSString* const kGDataGoogleBooksDefaultVolumeFeed     _INITIALIZE_AS(@"http://www.google.com/books/feeds/users/me/volumes");
_EXTERN NSString* const kGDataGoogleBooksDefaultCollectionFeed _INITIALIZE_AS(@"http://www.google.com/books/feeds/users/me/collections/library/volumes");

@class GDataQueryBooks;

// These routines are all simple wrappers around GDataServiceGoogle methods.

// finishedSelector has a signature like:
//   serviceTicket:(GDataServiceTicket *)ticket finishedWithObject:(GDataObject *)object;
// failedSelector has a signature like:
//   serviceTicket:(GDataServiceTicket *)ticket failedWithError:(NSError *)error

@interface GDataServiceGoogleBooks : GDataServiceGoogle

// finished callback (see above) is passed an appropriate Google Books feed
- (GDataServiceTicket *)fetchBooksFeedWithURL:(NSURL *)feedURL
                                     delegate:(id)delegate
                            didFinishSelector:(SEL)finishedSelector
                              didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed an appropriate entry
- (GDataServiceTicket *)fetchBooksEntryWithURL:(NSURL *)entryURL
                                      delegate:(id)delegate
                             didFinishSelector:(SEL)finishedSelector
                               didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the inserted entry
- (GDataServiceTicket *)fetchBooksEntryByInsertingEntry:(GDataEntryBase *)entryToInsert
                                             forFeedURL:(NSURL *)booksFeedURL
                                               delegate:(id)delegate
                                      didFinishSelector:(SEL)finishedSelector
                                        didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the updated entry
- (GDataServiceTicket *)fetchBooksEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                           forEntryURL:(NSURL *)booksEntryEditURL
                                              delegate:(id)delegate
                                     didFinishSelector:(SEL)finishedSelector
                                       didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the appropriate books feed
- (GDataServiceTicket *)fetchBooksQuery:(GDataQueryBooks *)query
                               delegate:(id)delegate
                      didFinishSelector:(SEL)finishedSelector
                        didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed a nil object
- (GDataServiceTicket *)deleteBooksEntry:(GDataEntryBase *)entryToDelete
                                delegate:(id)delegate
                       didFinishSelector:(SEL)finishedSelector
                         didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed a nil object
- (GDataServiceTicket *)deleteBooksResourceURL:(NSURL *)resourceEditURL
                                          ETag:(NSString *)etag
                                      delegate:(id)delegate
                             didFinishSelector:(SEL)finishedSelector
                               didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed a batch feed
- (GDataServiceTicket *)fetchBooksBatchFeedWithBatchFeed:(GDataFeedBase *)batchFeed
                                         forBatchFeedURL:(NSURL *)feedURL
                                                delegate:(id)delegate
                                       didFinishSelector:(SEL)finishedSelector
                                         didFailSelector:(SEL)failedSelector;

+ (NSString *)serviceRootURLString;  

@end
