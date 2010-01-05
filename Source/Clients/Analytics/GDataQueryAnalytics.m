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
//  GDataQueryAnalytics.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE

#import "GDataQueryAnalytics.h"

static NSString *const kDimensionsParamName = @"dimensions";
static NSString *const kMetricsParamName    = @"metrics";
static NSString *const kStartDateParamName  = @"start-date";
static NSString *const kEndDateParamName    = @"end-date";
static NSString *const kFiltersParamName    = @"filters";
static NSString *const kIDsParamName        = @"ids";
static NSString *const kSortParamName       = @"sort";
static NSString *const kSegmentParamName    = @"segment";

@implementation GDataQueryAnalytics

+ (GDataQueryAnalytics *)analyticsQueryWithFeedURL:(NSURL *)feedURL {
  return [[[self alloc] initWithFeedURL:feedURL] autorelease];
}

+ (GDataQueryAnalytics *)analyticsDataQueryWithTableID:(NSString *)tableID
                                       startDateString:(NSString *)startDateStr
                                         endDateString:(NSString *)endDateStr {

  NSString *const kDataURI = @"https://www.google.com/analytics/feeds/data";

  NSURL *dataURL = [NSURL URLWithString:kDataURI];

  GDataQueryAnalytics *query = [self analyticsQueryWithFeedURL:dataURL];
  [query setIDs:tableID];
  [query setStartDateString:startDateStr];
  [query setEndDateString:endDateStr];
  return query;
}

#pragma mark -


- (void)setDimensions:(NSString *)str {
  [self addCustomParameterWithName:kDimensionsParamName
                             value:str];
}

- (NSString *)dimensions {
  NSString *str = [self valueForParameterWithName:kDimensionsParamName];
  return str;
}

- (void)setMetrics:(NSString *)str {
  [self addCustomParameterWithName:kMetricsParamName
                             value:str];
}

- (NSString *)metrics {
  NSString *str = [self valueForParameterWithName:kMetricsParamName];
  return str;
}

- (void)setStartDateString:(NSString *)str {
  [self addCustomParameterWithName:kStartDateParamName
                             value:str];
}

- (NSString *)startDateString {
  NSString *str = [self valueForParameterWithName:kStartDateParamName];
  return str;
}

- (void)setEndDateString:(NSString *)str {
  [self addCustomParameterWithName:kEndDateParamName
                             value:str];
}

- (NSString *)endDateString {
  NSString *str = [self valueForParameterWithName:kEndDateParamName];
  return str;
}

- (void)setFilters:(NSString *)str {
  [self addCustomParameterWithName:kFiltersParamName
                             value:str];
}

- (NSString *)filters {
  NSString *str = [self valueForParameterWithName:kFiltersParamName];
  return str;
}

- (void)setIDs:(NSString *)str {
  [self addCustomParameterWithName:kIDsParamName
                             value:str];
}

- (NSString *)IDs {
  NSString *str = [self valueForParameterWithName:kIDsParamName];
  return str;
}

- (void)setSort:(NSString *)str {
  [self addCustomParameterWithName:kSortParamName
                             value:str];
}

- (NSString *)sort {
  NSString *str = [self valueForParameterWithName:kSortParamName];
  return str;
}

- (void)setSegment:(NSString *)str {
  [self addCustomParameterWithName:kSegmentParamName
                             value:str];
}

- (NSString *)segment {
  NSString *str = [self valueForParameterWithName:kSegmentParamName];
  return str;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE
