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
//  GDataServiceGoogleDocs.h
//

#import "GDataServiceGoogle.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATASERVICEDOCS_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif


// doclist feed URL
_EXTERN NSString* kGDataGoogleDocsDefaultPrivateFullFeed _INITIALIZE_AS(@"http://docs.google.com/feeds/documents/private/full");


@class GDataEntryDocBase;
@class GDataQueryDocs;

// These routines are all simple wrappers around GDataServiceGoogle methods.

// finishedSelector has signature like:
//   serviceTicket:(GDataServiceTicket *)ticket finishedWithObject:(GDataObject *)object;
// failedSelector has signature like:
//   serviceTicket:(GDataServiceTicket *)ticket failedWithError:(NSError *)error

@interface GDataServiceGoogleDocs : GDataServiceGoogle 

// finished callback (see above) is passed an appropriate doc list feed
- (GDataServiceTicket *)fetchDocsFeedWithURL:(NSURL *)feedURL
                                    delegate:(id)delegate
                           didFinishSelector:(SEL)finishedSelector
                             didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the inserted entry
- (GDataServiceTicket *)fetchDocEntryByInsertingEntry:(GDataEntryDocBase *)entryToInsert
                                           forFeedURL:(NSURL *)feedURL
                                             delegate:(id)delegate
                                    didFinishSelector:(SEL)finishedSelector
                                      didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the updated entry
- (GDataServiceTicket *)fetchDocEntryByUpdatingEntry:(GDataEntryDocBase *)entryToUpdate
                                         forEntryURL:(NSURL *)entryEditURL
                                            delegate:(id)delegate
                                   didFinishSelector:(SEL)finishedSelector
                                     didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the doc list feed
- (GDataServiceTicket *)fetchDocsQuery:(GDataQueryDocs *)query
                              delegate:(id)delegate
                     didFinishSelector:(SEL)finishedSelector
                       didFailSelector:(SEL)failedSelector;

  // finished callback (see above) is passed a nil object
- (GDataServiceTicket *)deleteDocResourceURL:(NSURL *)resourceEditURL
                                    delegate:(id)delegate
                           didFinishSelector:(SEL)finishedSelector
                             didFailSelector:(SEL)failedSelector;
@end
