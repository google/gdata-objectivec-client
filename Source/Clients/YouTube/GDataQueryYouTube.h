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
//  GDataQueryYouTube.h
//


#import "GDataQuery.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAQUERYYOUTUBE_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* kGDataYouTubeOrderByUpdated   _INITIALIZE_AS(@"updated");
_EXTERN NSString* kGDataYouTubeOrderByViewCount _INITIALIZE_AS(@"viewCount");
_EXTERN NSString* kGDataYouTubeOrderByRating    _INITIALIZE_AS(@"rating");
_EXTERN NSString* kGDataYouTubeOrderByRelevance _INITIALIZE_AS(@"relevance");

_EXTERN NSString* kGDataYouTubePeriodToday     _INITIALIZE_AS(@"today");
_EXTERN NSString* kGDataYouTubePeriodThisWeek  _INITIALIZE_AS(@"this_week");
_EXTERN NSString* kGDataYouTubePeriodThisMonth _INITIALIZE_AS(@"this_month");
_EXTERN NSString* kGDataYouTubePeriodAllTime   _INITIALIZE_AS(@"all_time");

@interface GDataQueryYouTube : GDataQuery 
  
+ (GDataQueryYouTube *)youTubeQueryWithFeedURL:(NSURL *)feedURL;

- (void)setVideoQuery:(NSString *)str;
- (NSString *)videoQuery;

- (void)setFormat:(NSString *)str;
- (NSString *)format;

- (void)setTimePeriod:(NSString *)str;
- (NSString *)timePeriod;

- (void)setAllowRacy:(BOOL)flag;
- (BOOL)allowRacy;
@end

