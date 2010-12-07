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
//  GDataEntryYouTubeSubscription.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataEntryBase.h"
#import "GDataEntryYouTubeFeedLinkBase.h"

@interface GDataEntryYouTubeSubscription : GDataEntryYouTubeFeedLinkBase

+ (GDataEntryYouTubeSubscription *)subscriptionEntry;

// subscriptionType is a convenience accessor to get the term value from
// the subscription category element for this entry
- (NSString *)subscriptionType;

- (NSString *)username;
- (void)setUsername:(NSString *)str;

- (NSString *)youTubeQueryString;
- (void)setYouTubeQueryString:(NSString *)str;

- (NSString *)playlistTitle;
- (void)setPlaylistTitle:(NSString *)str;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
