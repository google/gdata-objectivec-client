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

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

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

_EXTERN NSString* const kGDataYouTubeOrderByUpdated   _INITIALIZE_AS(@"updated");
_EXTERN NSString* const kGDataYouTubeOrderByViewCount _INITIALIZE_AS(@"viewCount");
_EXTERN NSString* const kGDataYouTubeOrderByRating    _INITIALIZE_AS(@"rating");
_EXTERN NSString* const kGDataYouTubeOrderByRelevance _INITIALIZE_AS(@"relevance");

_EXTERN NSString* const kGDataYouTubePeriodToday     _INITIALIZE_AS(@"today");
_EXTERN NSString* const kGDataYouTubePeriodThisWeek  _INITIALIZE_AS(@"this_week");
_EXTERN NSString* const kGDataYouTubePeriodThisMonth _INITIALIZE_AS(@"this_month");
_EXTERN NSString* const kGDataYouTubePeriodAllTime   _INITIALIZE_AS(@"all_time");

_EXTERN NSString* const kGDataYouTubeSafeSearchNone     _INITIALIZE_AS(@"none");
_EXTERN NSString* const kGDataYouTubeSafeSearchStrict   _INITIALIZE_AS(@"strict");
_EXTERN NSString* const kGDataYouTubeSafeSearchModerate _INITIALIZE_AS(@"moderate");


// http://code.google.com/apis/youtube/reference.html#Parameters

@interface GDataQueryYouTube : GDataQuery 
  
+ (GDataQueryYouTube *)youTubeQueryWithFeedURL:(NSURL *)feedURL;

- (void)setVideoQuery:(NSString *)str;
- (NSString *)videoQuery;

- (void)setFormat:(NSString *)str;
- (NSString *)format;

- (void)setTimePeriod:(NSString *)str;
- (NSString *)timePeriod;

// restriction is a country code or IP address
- (void)setRestriction:(NSString *)str;
- (NSString *)restriction;

// language restriction is a ISO 639-1 2-letter language code
- (void)setLanguageRestriction:(NSString *)str;
- (NSString *)languageRestriction;

// location as latitude,longitude
- (void)setLocation:(NSString *)str;
- (NSString *)location;

// radius like "100km" with units "ft", "mi", "m", or "km"
- (void)setLocationRadius:(NSString *)str;
- (NSString *)locationRadius;

- (void)setHasCaptions:(BOOL)flag;
- (BOOL)hasCaptions;

// put video entries into link elements for activity feed entries
- (void)setShouldInline:(BOOL)flag;
- (BOOL)shouldInline;

- (void)setUploader:(NSString *)str;
- (NSString *)uploader;

// safeSearch replaces allowRacy
- (void)setSafeSearch:(NSString *)str;
- (NSString *)safeSearch;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
