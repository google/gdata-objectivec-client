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
//  GDataYouTubeStatistics.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataObject.h"
#import "GDataDateTime.h"

// <yt:statistics viewCount="2" 
//                videoWatchCount="77" 
//                lastWebAccess="2008-01-26T10:32:41.000-08:00"/>

@interface GDataYouTubeStatistics : GDataObject <GDataExtension> 
+ (GDataYouTubeStatistics *)youTubeStatistics;

// long long value
- (NSNumber *)viewCount;
- (void)setViewCount:(NSNumber *)num;

// long long value
- (NSNumber *)videoWatchCount;
- (void)setVideoWatchCount:(NSNumber *)num;

// long long value
- (NSNumber *)subscriberCount;
- (void)setSubscriberCount:(NSNumber *)num;

// long long value
- (NSNumber *)favoriteCount;
- (void)setFavoriteCount:(NSNumber *)num;

- (GDataDateTime *)lastWebAccess;
- (void)setLastWebAccess:(GDataDateTime *)dateTime;

- (NSNumber *)totalUploadViews;
- (void)setTotalUploadViews:(NSNumber *)num;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
