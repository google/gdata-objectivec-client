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
//  GDataYouTubeConstants.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#import <Foundation/Foundation.h>

#import "GDataDefines.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAYOUTUBECONSTANTS_DEFINE_GLOBALS
#define _EXTERN
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataYouTubeDefaultServiceVersion _INITIALIZE_AS(@"2.0");

_EXTERN NSString* const kGDataNamespaceYouTube       _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007");
_EXTERN NSString* const kGDataNamespaceYouTubePrefix _INITIALIZE_AS(@"yt");

_EXTERN NSString* const kGDataCategoryYouTubeVideo          _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#video");
_EXTERN NSString* const kGDataCategoryYouTubeCaptionTrack   _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#captionTrack");
_EXTERN NSString* const kGDataCategoryYouTubeComplaint      _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#complaint");
_EXTERN NSString* const kGDataCategoryYouTubeComment        _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#comment");
_EXTERN NSString* const kGDataCategoryYouTubePlaylistLink   _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#playlistLink");
_EXTERN NSString* const kGDataCategoryYouTubeSubscription   _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#subscription");
_EXTERN NSString* const kGDataCategoryYouTubeFavorite       _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#favorite");
_EXTERN NSString* const kGDataCategoryYouTubeFriend         _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#friend");
_EXTERN NSString* const kGDataCategoryYouTubeRating         _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#rating");
_EXTERN NSString* const kGDataCategoryYouTubeUserProfile    _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#userProfile");
_EXTERN NSString* const kGDataCategoryYouTubeUserEvent      _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#userEvent");
_EXTERN NSString* const kGDataCategoryYouTubeChannel        _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#channel");
_EXTERN NSString* const kGDataCategoryYouTubePlaylist       _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#playlist");
_EXTERN NSString* const kGDataCategoryYouTubeVideoMessage   _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#videoMessage");

_EXTERN NSString* const kGDataSchemeYouTubeSubscription     _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007/subscriptiontypes.cat");
_EXTERN NSString* const kGDataSchemeYouTubeChannel          _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007/channeltypes.cat");
_EXTERN NSString* const kGDataSchemeYouTubeContact          _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007/contact.cat");
_EXTERN NSString* const kGDataSchemeYouTubeChannelType      _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007/channeltypes.cat");
_EXTERN NSString* const kGDataSchemeYouTubeTag              _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007/tags.cat");
_EXTERN NSString* const kGDataSchemeYouTubeKeyword          _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007/keywords.cat");
_EXTERN NSString* const kGDataSchemeYouTubeCategory         _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007/categories.cat");
_EXTERN NSString* const kGDataSchemeYouTubeDeveloper        _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007/developertags.cat");
_EXTERN NSString* const kGDataSchemeYouTubeUserEvents       _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007/userevents.cat");
_EXTERN NSString* const kGDataSchemeYouTubeComplaintReasons _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007/complaint-reasons.cat");

// for a list of valid categories, do
//   curl "http://gdata.youtube.com/schemas/2007/categories.cat"

_EXTERN NSString* const kGDataLinkYouTubePlaylist              _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#playlist");
_EXTERN NSString* const kGDataLinkYouTubeUploads               _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#user.uploads");
_EXTERN NSString* const kGDataLinkYouTubeFeatured              _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#featured-video");
_EXTERN NSString* const kGDataLinkYouTubeSubscriptions         _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#user.subscriptions");
_EXTERN NSString* const kGDataLinkYouTubePlaylists             _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#user.playlists");
_EXTERN NSString* const kGDataLinkYouTubeFriendsActivity       _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#user.friendsactivity");
_EXTERN NSString* const kGDataLinkYouTubeRecentActivity        _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#user.recentactivity");
_EXTERN NSString* const kGDataLinkYouTubeFavorites             _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#user.favorites");
_EXTERN NSString* const kGDataLinkYouTubeContacts              _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#user.contacts");
_EXTERN NSString* const kGDataLinkYouTubeInbox                 _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#user.inbox");
_EXTERN NSString* const kGDataLinkYouTubeMobile                _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#mobile");
_EXTERN NSString* const kGDataLinkYouTubeResponses             _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#video.responses");
_EXTERN NSString* const kGDataLinkYouTubeRatings               _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#video.ratings");
_EXTERN NSString* const kGDataLinkYouTubeCaptionTracks         _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#video.captionTracks");
_EXTERN NSString* const kGDataLinkYouTubeComments              _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#comments");
_EXTERN NSString* const kGDataLinkYouTubeComplaints            _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#video.complaints");
_EXTERN NSString* const kGDataLinkYouTubeRelated               _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#video.related");
_EXTERN NSString* const kGDataLinkYouTubeChannelContent        _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#channel.content");
_EXTERN NSString* const kGDataLinkYouTubeInReplyTo             _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#in-reply-to");
_EXTERN NSString* const kGDataLinkYouTubeVideoQuery            _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#video.query");
_EXTERN NSString* const kGDataLinkYouTubeNewSubscriptionVideos _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#user.newsubscriptionvideos");
_EXTERN NSString* const kGDataLinkYouTubeVlog                  _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#user.vlog");
_EXTERN NSString* const kGDataLinkYouTubeGetUploadToken        _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#action.getUploadToken");
_EXTERN NSString* const kGDataLinkYouTubeVideo                 _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#video");
_EXTERN NSString* const kGDataLinkYouTubeInsightViews          _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#insight.views");

// user event types
_EXTERN NSString* const kGDataYouTubeUserEventVideoUploaded         _INITIALIZE_AS(@"video_uploaded");
_EXTERN NSString* const kGDataYouTubeUserEventVideoRated            _INITIALIZE_AS(@"video_rated");
_EXTERN NSString* const kGDataYouTubeUserEventVideoFavorited        _INITIALIZE_AS(@"video_favorited");
_EXTERN NSString* const kGDataYouTubeUserEventVideoShared           _INITIALIZE_AS(@"video_shared");
_EXTERN NSString* const kGDataYouTubeUserEventVideoCommented        _INITIALIZE_AS(@"video_commented");
_EXTERN NSString* const kGDataYouTubeUserEventUserSubscriptionAdded _INITIALIZE_AS(@"user_subscription_added");
_EXTERN NSString* const kGDataYouTubeUserEventFriendAdded           _INITIALIZE_AS(@"friend_added");

// rating values
_EXTERN NSString* const kGDataYouTubeRatingValueLike                _INITIALIZE_AS(@"like");
_EXTERN NSString* const kGDataYouTubeRatingValueDislike             _INITIALIZE_AS(@"dislike");

@interface GDataYouTubeConstants : NSObject

+ (NSDictionary *)youTubeNamespaces;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
