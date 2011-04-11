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

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataEntryBase.h"
#import "GDataYouTubeMediaElements.h"
#import "GDataYouTubeStatistics.h"
#import "GDataYouTubePublicationState.h"
#import "GDataYouTubeAccessControl.h"
#import "GDataYouTubeRating.h"
#import "GDataGeo.h"
#import "GDataComment.h"
#import "GDataLink.h"

@interface GDataEntryYouTubeVideo : GDataEntryBase

+ (GDataEntryYouTubeVideo *)videoEntry;

- (GDataYouTubeStatistics *)statistics;
- (void)setStatistics:(GDataYouTubeStatistics *)obj;

- (GDataComment *)comment;
- (void)setComment:(GDataComment *)obj;

- (BOOL)isEmbeddable;
- (void)setIsEmbeddable:(BOOL)flag;

// rating previously was a GDataRating element <gd:rating> but has
// changed to GDataYouTubeRating <yt:rating>
- (GDataYouTubeRating *)rating;
- (void)setRating:(GDataYouTubeRating *)obj;

- (GDataYouTubeMediaGroup *)mediaGroup;
- (void)setMediaGroup:(GDataYouTubeMediaGroup *)obj;

// setGeoLocation requires an instance of a subclass of GDataGeo, not an
// instance of GDataGeo; see GDataGeo.h
//
// for YouTube, use GDataGeoRSSWhere for the geo location
- (GDataGeo *)geoLocation;
- (void)setGeoLocation:(GDataGeo *)geo;

- (GDataYouTubePublicationState *)publicationState;
- (void)setGDataYouTubePublicationState:(GDataYouTubePublicationState *)obj;

- (NSString *)location; // yt:location
- (void)setLocation:(NSString *)str;

- (GDataDateTime *)recordedDate;
- (void)setRecordedDate:(GDataDateTime *)dateTime;

- (NSArray *)accessControls;
- (void)setAccessControls:(NSArray *)array;
- (void)addAccessControl:(GDataYouTubeAccessControl *)obj;

// convenience accessors
- (GDataLink *)videoResponsesLink;
- (GDataLink *)ratingsLink;
- (GDataLink *)complaintsLink;
- (GDataLink *)captionTracksLink;

@end

@interface GDataLink (GDataYouTubeVideoEntryAdditions)
- (GDataYouTubeToken *)youTubeToken;
- (void)setYouTubeToken:(GDataYouTubeToken *)obj;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
