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
//  GDataServiceGooglePhotos.h
//

#import "GDataServiceGoogle.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATASERVICEGOOGLEPHOTOS_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

// feed of all Google Photos photos, useful for queries searching for photos
_EXTERN NSString* kGDataGooglePhotosAllFeed _INITIALIZE_AS(@"http://photos.googleapis.com/data/feed/api/all");

// values for photoFeedURLForUserID:
_EXTERN NSString* kGDataGooglePhotosAccessAll _INITIALIZE_AS(@"all");
_EXTERN NSString* kGDataGooglePhotosAccessPublic _INITIALIZE_AS(@"public");
_EXTERN NSString* kGDataGooglePhotosAccessProtected _INITIALIZE_AS(@"protected"); // "sign-in required"
_EXTERN NSString* kGDataGooglePhotosAccessPrivate _INITIALIZE_AS(@"private");

_EXTERN NSString* kGDataGooglePhotosKindAlbum   _INITIALIZE_AS(@"album");
_EXTERN NSString* kGDataGooglePhotosKindPhoto   _INITIALIZE_AS(@"photo");
_EXTERN NSString* kGDataGooglePhotosKindComment _INITIALIZE_AS(@"comment");
_EXTERN NSString* kGDataGooglePhotosKindTag     _INITIALIZE_AS(@"tag");
_EXTERN NSString* kGDataGooglePhotosKindUser    _INITIALIZE_AS(@"user");

@class GDataQueryGooglePhotos;
@class GDataEntryPhotoBase;

// These routines are all simple wrappers around GDataServiceGoogle methods.

// finishedSelector has signature like:
//   serviceTicket:(GDataServiceTicket *)ticket finishedWithObject:(GDataObject *)object;
// failedSelector has signature like:
//   serviceTicket:(GDataServiceTicket *)ticket failedWithError:(NSError *)error

@interface GDataServiceGooglePhotos : GDataServiceGoogle 

+ (NSString *)serviceRootURLString;

// utility for making a feed URL.  To set other query parameters, use the
// methods in GDataQueryGooglePhotos instead of this
+ (NSURL *)photoFeedURLForUserID:(NSString *)userID
                         albumID:(NSString *)albumIDorNil
                       albumName:(NSString *)albumNameOrNil
                         photoID:(NSString *)photoIDorNil
                            kind:(NSString *)feedKindOrNil
                          access:(NSString *)accessOrNil;

// utility for making a feed URL for a user's contacts feed
+ (NSURL *)photoContactsFeedURLForUserID:(NSString *)userID;

// finished callback (see above) is passed an appropriate GooglePhotos feed
- (GDataServiceTicket *)fetchPhotoFeedWithURL:(NSURL *)feedURL
                                     delegate:(id)delegate
                            didFinishSelector:(SEL)finishedSelector
                              didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the inserted entry
- (GDataServiceTicket *)fetchPhotoEntryByInsertingEntry:(GDataEntryPhotoBase *)entryToInsert
                                             forFeedURL:(NSURL *)photoFeedURL
                                               delegate:(id)delegate
                                      didFinishSelector:(SEL)finishedSelector
                                        didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the updated entry
- (GDataServiceTicket *)fetchPhotoEntryByUpdatingEntry:(GDataEntryPhotoBase *)entryToUpdate
                                           forEntryURL:(NSURL *)photoEntryEditURL
                                              delegate:(id)delegate
                                     didFinishSelector:(SEL)finishedSelector
                                       didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the appropriate GooglePhotos feed
- (GDataServiceTicket *)fetchPhotoQuery:(GDataQueryGooglePhotos *)query
                               delegate:(id)delegate
                      didFinishSelector:(SEL)finishedSelector
                        didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed a nil object
- (GDataServiceTicket *)deletePhotoEntry:(GDataEntryPhotoBase *)entryToUpdate
                                delegate:(id)delegate
                       didFinishSelector:(SEL)finishedSelector
                         didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed a nil object
- (GDataServiceTicket *)deletePhotoResourceURL:(NSURL *)resourceEditURL
                                          ETag:(NSString *)etag
                                      delegate:(id)delegate
                             didFinishSelector:(SEL)finishedSelector
                               didFailSelector:(SEL)failedSelector;
@end
