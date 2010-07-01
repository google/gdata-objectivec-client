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

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

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
_EXTERN NSString* const kGDataYouTubeFeedIDFull                      _INITIALIZE_AS(nil);
_EXTERN NSString* const kGDataYouTubeFeedIDTopRated                  _INITIALIZE_AS(@"top_rated");
_EXTERN NSString* const kGDataYouTubeFeedIDTopFavorites              _INITIALIZE_AS(@"top_favorites");
_EXTERN NSString* const kGDataYouTubeFeedIDMostViewed                _INITIALIZE_AS(@"most_viewed");
_EXTERN NSString* const kGDataYouTubeFeedIDMostPopular               _INITIALIZE_AS(@"most_popular");
_EXTERN NSString* const kGDataYouTubeFeedIDMostRecent                _INITIALIZE_AS(@"most_recent");
_EXTERN NSString* const kGDataYouTubeFeedIDMostDiscussed             _INITIALIZE_AS(@"most_discussed");
// _EXTERN NSString* const kGDataYouTubeFeedIDMostLinked                _INITIALIZE_AS(@"most_linked"); deprecated
_EXTERN NSString* const kGDataYouTubeFeedIDMostResponded             _INITIALIZE_AS(@"most_responded");
_EXTERN NSString* const kGDataYouTubeFeedIDRecentlyFeatured          _INITIALIZE_AS(@"recently_featured");
_EXTERN NSString* const kGDataYouTubeFeedIDWatchOnMobile             _INITIALIZE_AS(@"watch_on_mobile");

// user feed IDs
_EXTERN NSString* const kGDataYouTubeUserFeedIDProfile               _INITIALIZE_AS(nil);
_EXTERN NSString* const kGDataYouTubeUserFeedIDContacts              _INITIALIZE_AS(@"contacts");
_EXTERN NSString* const kGDataYouTubeUserFeedIDFavorites             _INITIALIZE_AS(@"favorites");
_EXTERN NSString* const kGDataYouTubeUserFeedIDInbox                 _INITIALIZE_AS(@"inbox");
_EXTERN NSString* const kGDataYouTubeUserFeedIDPlaylists             _INITIALIZE_AS(@"playlists");
_EXTERN NSString* const kGDataYouTubeUserFeedIDSubscriptions         _INITIALIZE_AS(@"subscriptions");
_EXTERN NSString* const kGDataYouTubeUserFeedIDUploads               _INITIALIZE_AS(@"uploads");
_EXTERN NSString* const kGDataYouTubeUserFeedIDNewSubscriptionVideos _INITIALIZE_AS(@"newsubscriptionvideos");
_EXTERN NSString* const kGDataYouTubeUserFeedIDFriendsActivity       _INITIALIZE_AS(@"friendsactivity");
_EXTERN NSString* const kGDataYouTubeUserFeedIDRecommendations       _INITIALIZE_AS(@"recommendations");


@class GDataQueryYouTube;
@class GDataEntryYouTubeVideo;


// Note that setUserCredentialsWithUsername:password: may require either the
// Google account e-mail address or the YouTube account name, depending on
// how the account was created.

@interface GDataServiceGoogleYouTube : GDataServiceGoogle {
  NSString *developerKey_; // required for uploading 
}

+ (NSString *)serviceRootURLString;

// Utilities for making feed URLs.  To set query parameters, use the
// methods in GDataQueryYouTube.
//
// feedID may be nil (or equivalently kGDataYouTubeFeedIDFull)
//
// userID may be kGDataServiceDefaultUser

+ (NSURL *)youTubeURLForFeedID:(NSString *)feedID;

+ (NSURL *)youTubeURLForUserID:(NSString *)userID
                    userFeedID:(NSString *)feedID;

+ (NSURL *)youTubeUploadURLForUserID:(NSString *)userID;

+ (NSURL *)youTubeActivityFeedURLForUserID:(NSString *)userID;

// Note:
//
// A developer key is required for uploading, and for updating or deleting
// videos.  Entries in feeds retrieved without a developer key will 
// not have edit links. 
- (NSString *)youTubeDeveloperKey;
- (void)setYouTubeDeveloperKey:(NSString *)str;
  
// clients may use these fetch methods of GDataServiceGoogle
//
//  - (GDataServiceTicket *)fetchFeedWithURL:(NSURL *)feedURL delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//  - (GDataServiceTicket *)fetchFeedWithQuery:(GDataQuery *)query delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//  - (GDataServiceTicket *)fetchEntryWithURL:(NSURL *)entryURL delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//  - (GDataServiceTicket *)fetchEntryByInsertingEntry:(GDataEntryBase *)entryToInsert forFeedURL:(NSURL *)feedURL delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//  - (GDataServiceTicket *)fetchEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//  - (GDataServiceTicket *)deleteEntry:(GDataEntryBase *)entryToDelete delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//  - (GDataServiceTicket *)deleteResourceURL:(NSURL *)resourceEditURL ETag:(NSString *)etag delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//  - (GDataServiceTicket *)fetchFeedWithBatchFeed:(GDataFeedBase *)batchFeed forBatchFeedURL:(NSURL *)feedURL delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//
// finishedSelector has a signature like this for feed fetches:
// - (void)serviceTicket:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedBase *)feed error:(NSError *)error;
//
// or this for entry fetches:
// - (void)serviceTicket:(GDataServiceTicket *)ticket finishedWithEntry:(GDataEntryBase *)entry error:(NSError *)error;
//
// The class of the returned feed or entry is determined by the URL fetched.

+ (NSString *)serviceRootURLString;  

+ (NSString *)serviceUploadRootURLString;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
