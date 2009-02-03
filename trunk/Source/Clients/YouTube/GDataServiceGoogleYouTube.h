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
//  GDataServiceGoogleYouTube.h
//

#import "GDataServiceGoogle.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATASERVICEYOUTUBE_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

// standard feed IDs
_EXTERN NSString* const kGDataYouTubeFeedIDFull                _INITIALIZE_AS(nil);
_EXTERN NSString* const kGDataYouTubeFeedIDMostDiscussed       _INITIALIZE_AS(@"most_discussed");
_EXTERN NSString* const kGDataYouTubeFeedIDMostLinked          _INITIALIZE_AS(@"most_linked");
_EXTERN NSString* const kGDataYouTubeFeedIDMostPopular         _INITIALIZE_AS(@"most_popular");
_EXTERN NSString* const kGDataYouTubeFeedIDMostResponded       _INITIALIZE_AS(@"most_responded");
_EXTERN NSString* const kGDataYouTubeFeedIDMostViewed          _INITIALIZE_AS(@"most_viewed");
_EXTERN NSString* const kGDataYouTubeFeedIDTopFavorites        _INITIALIZE_AS(@"top_favorites");
_EXTERN NSString* const kGDataYouTubeFeedIDTopRecentlyFeatured _INITIALIZE_AS(@"recently_featured");
_EXTERN NSString* const kGDataYouTubeFeedIDWatchOnMobile       _INITIALIZE_AS(@"watch_on_mobile");

// user feed IDs
_EXTERN NSString* const kGDataYouTubeUserFeedIDProfile         _INITIALIZE_AS(nil);
_EXTERN NSString* const kGDataYouTubeUserFeedIDContacts        _INITIALIZE_AS(@"contacts");
_EXTERN NSString* const kGDataYouTubeUserFeedIDFavorites       _INITIALIZE_AS(@"favorites");
_EXTERN NSString* const kGDataYouTubeUserFeedIDInbox           _INITIALIZE_AS(@"inbox");
_EXTERN NSString* const kGDataYouTubeUserFeedIDPlaylists       _INITIALIZE_AS(@"playlists");
_EXTERN NSString* const kGDataYouTubeUserFeedIDSubscriptions   _INITIALIZE_AS(@"subscriptions");
_EXTERN NSString* const kGDataYouTubeUserFeedIDUploads         _INITIALIZE_AS(@"uploads");

@class GDataQueryYouTube;
@class GDataEntryYouTubeVideo;

// These routines are all simple wrappers around GDataServiceGoogle methods.

// finishedSelector has signature like:
//   serviceTicket:(GDataServiceTicket *)ticket finishedWithObject:(GDataObject *)object;
// failedSelector has signature like:
//   serviceTicket:(GDataServiceTicket *)ticket failedWithError:(NSError *)error

@interface GDataServiceGoogleYouTube : GDataServiceGoogle {
  NSString *developerKey_; // required for uploading 
}

+ (NSString *)serviceRootURLString;

// Utilities for making feed URLs.  To set query parameters, use the
// methods in GDataQueryYouTube.
//
// feedID may be nil (or equivalently kGDataYouTubeFeedIDFull) 

+ (NSURL *)youTubeURLForFeedID:(NSString *)feedID;

+ (NSURL *)youTubeURLForUserID:(NSString *)userID
                    userFeedID:(NSString *)feedID;

+ (NSURL *)youTubeUploadURLForUserID:(NSString *)userID
                            clientID:(NSString *)clientID;

// a developer key is required for uploading, and for updating or deleting
// videos.  Entries in feeds retrieved without a developer key will 
// not have edit links. 
- (NSString *)youTubeDeveloperKey;
- (void)setYouTubeDeveloperKey:(NSString *)str;
  
// finished callback (see above) is passed an appropriate YouTube feed
- (GDataServiceTicket *)fetchYouTubeFeedWithURL:(NSURL *)feedURL
                                       delegate:(id)delegate
                              didFinishSelector:(SEL)finishedSelector
                                didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed an appropriate YouTube entry
- (GDataServiceTicket *)fetchYouTubeEntryWithURL:(NSURL *)feedURL
                                        delegate:(id)delegate
                               didFinishSelector:(SEL)finishedSelector
                                 didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the inserted entry
- (GDataServiceTicket *)fetchYouTubeEntryByInsertingEntry:(GDataEntryBase *)entryToInsert
                                               forFeedURL:(NSURL *)youTubeFeedURL
                                                 delegate:(id)delegate
                                        didFinishSelector:(SEL)finishedSelector
                                          didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the updated entry
- (GDataServiceTicket *)fetchYouTubeEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                             forEntryURL:(NSURL *)youTubeEntryEditURL
                                                delegate:(id)delegate
                                       didFinishSelector:(SEL)finishedSelector
                                         didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the appropriate YouTube feed
- (GDataServiceTicket *)fetchYouTubeQuery:(GDataQueryYouTube *)query
                                 delegate:(id)delegate
                        didFinishSelector:(SEL)finishedSelector
                          didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed a nli object
- (GDataServiceTicket *)deleteYouTubeEntry:(GDataEntryBase *)entryToDelete
                                  delegate:(id)delegate
                         didFinishSelector:(SEL)finishedSelector
                           didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed a nil object
- (GDataServiceTicket *)deleteYouTubeResourceURL:(NSURL *)resourceEditURL
                                            ETag:(NSString *)etag
                                        delegate:(id)delegate
                               didFinishSelector:(SEL)finishedSelector
                                 didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed a batch feed
- (GDataServiceTicket *)fetchYouTubeBatchFeedWithBatchFeed:(GDataFeedBase *)batchFeed
                                           forBatchFeedURL:(NSURL *)feedURL
                                                  delegate:(id)delegate
                                         didFinishSelector:(SEL)finishedSelector
                                           didFailSelector:(SEL)failedSelector;

+ (NSString *)serviceRootURLString;  

+ (NSString *)serviceUploadRootURLString;

@end
