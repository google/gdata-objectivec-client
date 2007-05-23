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
//  GDataServiceGooglePicasaWeb.h
//

#import <Cocoa/Cocoa.h>

#import "GDataServiceGoogle.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATASERVICEPICASAWEB_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* kGDataPicasaWebAccessAll _INITIALIZE_AS(@"all");
_EXTERN NSString* kGDataPicasaWebAccessPublic _INITIALIZE_AS(@"public");
_EXTERN NSString* kGDataPicasaWebAccessPrivate _INITIALIZE_AS(@"private");

_EXTERN NSString* kGDataPicasaWebKindAlbum _INITIALIZE_AS(@"album");
_EXTERN NSString* kGDataPicasaWebKindPhoto _INITIALIZE_AS(@"photo");
_EXTERN NSString* kGDataPicasaWebKindComment _INITIALIZE_AS(@"comment");
_EXTERN NSString* kGDataPicasaWebKindTag _INITIALIZE_AS(@"tag");

@class GDataQueryPicasaWeb;
@class GDataEntryPhotoBase;

// These routines are all simple wrappers around GDataServiceGoogle methods.

// finishedSelector has signature like:
//   serviceTicket:(GDataServiceTicket *)ticket finishedWithObject:(GDataObject *)object;
// failedSelector has signature like:
//   serviceTicket:(GDataServiceTicket *)ticket failedWithError:(NSError *)error

@interface GDataServiceGooglePicasaWeb : GDataServiceGoogle 

// utility for making a feed URL.  To set other query parameters, use the
// methods in GDataQueryPicasaWeb instead of this
+ (NSURL *)picasaWebFeedURLForUserID:(NSString *)userID
                             albumID:(NSString *)albumIDorNil
                           albumName:(NSString *)albumNameOrNil
                             photoID:(NSString *)photoIDorNil
                                kind:(NSString *)feedKindOrNil
                              access:(NSString *)accessOrNil;

// finished callback (see above) is passed an appropriate PicasaWeb feed
- (GDataServiceTicket *)fetchPicasaWebFeedWithURL:(NSURL *)feedURL
                                         delegate:(id)delegate
                                didFinishSelector:(SEL)finishedSelector
                                  didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the inserted entry
- (GDataServiceTicket *)fetchPicasaWebEntryByInsertingEntry:(GDataEntryPhotoBase *)entryToInsert
                                                 forFeedURL:(NSURL *)picasaWebFeedURL
                                                   delegate:(id)delegate
                                          didFinishSelector:(SEL)finishedSelector
                                            didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the updated entry
- (GDataServiceTicket *)fetchPicasaWebEntryByUpdatingEntry:(GDataEntryPhotoBase *)entryToUpdate
                                               forEntryURL:(NSURL *)picasaWebEntryEditURL
                                                  delegate:(id)delegate
                                         didFinishSelector:(SEL)finishedSelector
                                           didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the appropriate PicasaWeb feed
- (GDataServiceTicket *)fetchPicasaWebQuery:(GDataQueryPicasaWeb *)query
                                   delegate:(id)delegate
                          didFinishSelector:(SEL)finishedSelector
                            didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed a nil object
- (GDataServiceTicket *)deletePicasaWebResourceURL:(NSURL *)resourceEditURL
                                          delegate:(id)delegate
                                 didFinishSelector:(SEL)finishedSelector
                                   didFailSelector:(SEL)failedSelector;
@end
