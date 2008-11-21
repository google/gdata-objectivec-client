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
//  GDataEntryYouTubeVideo.h
//

#import "GDataEntryBase.h"
#import "GDataYouTubeMediaElements.h"
#import "GDataYouTubeStatistics.h"
#import "GDataYouTubePublicationState.h"
#import "GDataGeo.h"
#import "GDataComment.h"
#import "GDataRating.h"
#import "GDataLink.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAENTRYYOUTUBEVIDEO_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* kGDataNamespaceYouTube       _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007");
_EXTERN NSString* kGDataNamespaceYouTubePrefix _INITIALIZE_AS(@"yt");

_EXTERN NSString* kGDataCategoryYouTubeVideo        _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#video");
_EXTERN NSString* kGDataCategoryYouTubeComplaint    _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#complaint");
_EXTERN NSString* kGDataCategoryYouTubeComment      _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#comment");
_EXTERN NSString* kGDataCategoryYouTubePlaylistLink _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#playlistLink");
_EXTERN NSString* kGDataCategoryYouTubeSubscription _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#subscription");
_EXTERN NSString* kGDataCategoryYouTubeFavorite     _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#favorite");
_EXTERN NSString* kGDataCategoryYouTubeFriend       _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#friend");
_EXTERN NSString* kGDataCategoryYouTubeRating       _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#rating");
_EXTERN NSString* kGDataCategoryYouTubeUserProfile  _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#userProfile");
_EXTERN NSString* kGDataCategoryYouTubeChannel      _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#channel");
_EXTERN NSString* kGDataCategoryYouTubePlaylist     _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#playlist");
_EXTERN NSString* kGDataCategoryYouTubeVideoMessage _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#videoMessage");

_EXTERN NSString* kGDataSchemeYouTubeSubscription _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007/subscriptiontypes.cat");
_EXTERN NSString* kGDataSchemeYouTubeChannel      _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007/channeltypes.cat");
_EXTERN NSString* kGDataSchemeYouTubeContact      _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007/contact.cat");
_EXTERN NSString* kGDataSchemeYouTubeChannelType  _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007/channeltypes.cat");
_EXTERN NSString* kGDataSchemeYouTubeTag          _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007/tags.cat");
_EXTERN NSString* kGDataSchemeYouTubeKeyword      _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007/keywords.cat");
_EXTERN NSString* kGDataSchemeYouTubeCategory     _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007/categories.cat");
_EXTERN NSString* kGDataSchemeYouTubeDeveloper    _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007/developertags.cat");

// for a list of valid categories, do
//   curl "http://gdata.youtube.com/schemas/2007/categories.cat"

_EXTERN NSString* kGDataLinkYouTubePlaylist      _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#playlist");
_EXTERN NSString* kGDataLinkYouTubeUploads       _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#user.uploads");
_EXTERN NSString* kGDataLinkYouTubeFeatured      _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#featured-video");
_EXTERN NSString* kGDataLinkYouTubeSubscriptions _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#user.subscriptions");
_EXTERN NSString* kGDataLinkYouTubePlaylists     _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#user.playlists");
_EXTERN NSString* kGDataLinkYouTubeFavorites     _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#user.favorites");
_EXTERN NSString* kGDataLinkYouTubeContacts      _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#user.contacts");
_EXTERN NSString* kGDataLinkYouTubeInbox         _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#user.inbox");
_EXTERN NSString* kGDataLinkYouTubeMobile        _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#mobile");
_EXTERN NSString* kGDataLinkYouTubeResponses     _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#video.responses");
_EXTERN NSString* kGDataLinkYouTubeRatings       _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#video.ratings");
_EXTERN NSString* kGDataLinkYouTubeComments      _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#comments");
_EXTERN NSString* kGDataLinkYouTubeComplaints    _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#video.complaints");
_EXTERN NSString* kGDataLinkYouTubeRelated       _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#video.related");
_EXTERN NSString* kGDataLinkYouTubeInReplyTo     _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#in-reply-to");
_EXTERN NSString* kGDataLinkYouTubeVideoQuery    _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#video.query");
_EXTERN NSString* kGDataLinkYouTubeVlog          _INITIALIZE_AS(@"http://gdata.youtube.com/schemas/2007#user.vlog");




@interface GDataEntryYouTubeVideo : GDataEntryBase

+ (NSDictionary *)youTubeNamespaces;

+ (GDataEntryYouTubeVideo *)videoEntry;

- (GDataYouTubeStatistics *)statistics;
- (void)setStatistics:(GDataYouTubeStatistics *)obj;

- (GDataComment *)comment;
- (void)setComment:(GDataComment *)obj;

- (BOOL)isEmbeddable;
- (void)setIsEmbeddable:(BOOL)flag;

- (GDataRating *)rating;
- (void)setRating:(GDataRating *)obj;

- (GDataYouTubeMediaGroup *)mediaGroup;
- (void)setMediaGroup:(GDataYouTubeMediaGroup *)obj;

// setGeoLocation requires an instance of a subclass of GDataGeo, not an
// instance of GDataGeo; see GDataGeo.h
- (GDataGeo *)geoLocation;
- (void)setGeoLocation:(GDataGeo *)geo;

- (GDataYouTubePublicationState *)publicationState;
- (void)setGDataYouTubePublicationState:(GDataYouTubePublicationState *)obj;

- (NSString *)location; // yt:location
- (void)setLocation:(NSString *)str;

- (GDataDateTime *)recordedDate;
- (void)setRecordedDate:(GDataDateTime *)dateTime;

// isRacy is deprecated for GData v2, replaced by GDataMediaRating
- (BOOL)isRacy;
- (void)setIsRacy:(BOOL)flag;


// convenience accessors
- (GDataLink *)videoResponsesLink;
- (GDataLink *)ratingsLink;
- (GDataLink *)complaintsLink;

// protected methods (for subclasses only)
+ (NSString *)videoEntryCategoryTerm;

@end

@interface GDataLink (GDataYouTubeVideoEntryAdditions)
- (GDataYouTubeToken *)youTubeToken;
- (void)setYouTubeToken:(GDataYouTubeToken *)obj;
@end

