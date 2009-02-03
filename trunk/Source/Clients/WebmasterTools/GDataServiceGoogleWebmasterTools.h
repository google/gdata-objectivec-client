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
//  GDataServiceGoogleWebmasterTools.h
//

#import "GDataServiceGoogle.h"
#import "GDataEntrySite.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATASERVICEGOOGLEWEBMASTERTOOLS_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataGoogleWebmasterToolsSitesFeed _INITIALIZE_AS(@"https://www.google.com/webmasters/tools/feeds/sites/");


// These routines are all simple wrappers around GDataServiceGoogle methods.

// finishedSelector has a signature like:
//   serviceTicket:(GDataServiceTicket *)ticket finishedWithObject:(GDataObject *)object;
// failedSelector has a signature like:
//   serviceTicket:(GDataServiceTicket *)ticket failedWithError:(NSError *)error

@interface GDataServiceGoogleWebmasterTools : GDataServiceGoogle

// Utility for making feed URLs. 
+ (NSURL *)sitemapsFeedURLForSiteID:(NSString *)siteID;


// finished callback (see above) is passed an appropriate WebmasterTools feed
- (GDataServiceTicket *)fetchWebmasterToolsFeedWithURL:(NSURL *)feedURL
                                              delegate:(id)delegate
                                     didFinishSelector:(SEL)finishedSelector
                                       didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed an appropriate entry
- (GDataServiceTicket *)fetchWebmasterToolsEntryWithURL:(NSURL *)entryURL
                                               delegate:(id)delegate
                                      didFinishSelector:(SEL)finishedSelector
                                        didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the inserted entry
- (GDataServiceTicket *)fetchWebmasterToolsEntryByInsertingEntry:(GDataEntryBase *)entryToInsert
                                                      forFeedURL:(NSURL *)feedURL
                                                        delegate:(id)delegate
                                               didFinishSelector:(SEL)finishedSelector
                                                 didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the updated entry
- (GDataServiceTicket *)fetchWebmasterToolsEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                                    forEntryURL:(NSURL *)entryEditURL
                                                       delegate:(id)delegate
                                              didFinishSelector:(SEL)finishedSelector
                                                didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed a nil object
- (GDataServiceTicket *)deleteWebmasterToolsEntry:(GDataEntryBase *)entryToDelete
                                         delegate:(id)delegate
                                didFinishSelector:(SEL)finishedSelector
                                  didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed a nil object
- (GDataServiceTicket *)deleteWebmasterToolsResourceURL:(NSURL *)resourceEditURL
                                                   ETag:(NSString *)etag
                                               delegate:(id)delegate
                                      didFinishSelector:(SEL)finishedSelector
                                        didFailSelector:(SEL)failedSelector;

+ (NSString *)serviceRootURLString;  

@end
