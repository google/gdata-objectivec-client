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
//  GDataEntryYouTubeFeedLinkBase.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataEntryBase.h"
#import "GDataFeedLink.h"
#import "GDataMediaGroup.h"
#import "GDataYouTubeElements.h"

// this is the superclass for GDataEntryYouTubeSubscription and
// GDataEntryYouTubePlaylistLink

@interface GDataEntryYouTubeFeedLinkBase : GDataEntryBase

- (GDataMediaGroup *)mediaGroup;
- (void)setMediaGroup:(GDataMediaGroup *)obj;

- (NSString *)countHint;
- (void)setCountHint:(NSString *)str;

- (NSString *)playlistID;
- (void)setPlaylistID:(NSString *)str;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
