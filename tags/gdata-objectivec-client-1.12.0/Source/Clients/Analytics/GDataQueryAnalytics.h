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
//  GDataQueryAnalytics.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE

#import "GDataQuery.h"

@interface GDataQueryAnalytics : GDataQuery

+ (GDataQueryAnalytics *)analyticsQueryWithFeedURL:(NSURL *)feedURL;

+ (GDataQueryAnalytics *)analyticsDataQueryWithTableID:(NSString *)tableID
                                       startDateString:(NSString *)startDateStr
                                         endDateString:(NSString *)endDateStr;

- (void)setDimensions:(NSString *)str;
- (NSString *)dimensions;

- (void)setMetrics:(NSString *)str;
- (NSString *)metrics;

- (void)setStartDateString:(NSString *)str; // YYYY-MM-DD
- (NSString *)startDateString;

- (void)setEndDateString:(NSString *)str; // YYYY-MM-DD
- (NSString *)endDateString;

- (void)setFilters:(NSString *)str;
- (NSString *)filters;

- (void)setIDs:(NSString *)str;
- (NSString *)IDs;

- (void)setSort:(NSString *)str;
- (NSString *)sort;

- (void)setSegment:(NSString *)str;
- (NSString *)segment;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE
