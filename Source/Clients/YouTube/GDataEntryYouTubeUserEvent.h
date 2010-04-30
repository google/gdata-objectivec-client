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
//  GDataEntryYouTubeUserEvent.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataEntryBase.h"
#import "GDataYouTubeRating.h"

@interface GDataEntryYouTubeUserEvent : GDataEntryBase

+ (GDataEntryYouTubeUserEvent *)userEventEntry;

// event type category

- (NSString *)userEventType;
- (void)setUserEventType:(NSString *)typeStr;

// extensions

- (NSString *)videoID;
- (void)setVideoID:(NSString *)str;

- (NSString *)username;
- (void)setUsername:(NSString *)str;

// rating previously was a GDataRating element <gd:rating> but has
// changed to GDataYouTubeRating <yt:rating>
- (GDataYouTubeRating *)rating;
- (void)setRating:(GDataYouTubeRating *)obj;

// convenience accessors

- (GDataLink *)videoLink;
- (GDataLink *)commentLink;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
