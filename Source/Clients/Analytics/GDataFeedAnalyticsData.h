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
//  GDataFeedAnalyticsData.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE

#import "GDataFeedBase.h"
#import "GDataAnalyticsAggregateGroup.h"
#import "GDataAnalyticsDataSource.h"
#import "GDataAnalyticsSegment.h"

@interface GDataFeedAnalyticsData : GDataFeedBase
+ (GDataFeedAnalyticsData *)dataFeed;

- (GDataAnalyticsAggregateGroup *)aggregateGroup;
- (void)setAggregateGroup:(GDataAnalyticsAggregateGroup *)obj;

- (NSArray *)dataSources;
- (void)setDataSources:(NSArray *)array;
- (void)addDataSource:(GDataAnalyticsDataSource *)obj;

- (NSString *)startDateString; // yyyy-mm-dd
- (void)setStartDateString:(NSString *)str;

- (NSString *)endDateString; // yyyy-mm-dd
- (void)setEndDateString:(NSString *)str;

- (NSArray *)segments;
- (void)setSegments:(NSArray *)array;
- (void)addSegment:(GDataAnalyticsSegment *)obj;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE
