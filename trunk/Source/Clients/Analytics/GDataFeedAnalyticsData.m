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
//  GDataFeedAnalyticsData.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE

#import "GDataFeedAnalyticsData.h"
#import "GDataEntryAnalyticsData.h"

#import "GDataAnalyticsConstants.h"
#import "GDataAnalyticsElements.h"

@implementation GDataFeedAnalyticsData

+ (GDataFeedAnalyticsData *)dataFeed {

  GDataFeedAnalyticsData *feed = [self object];

  [feed setNamespaces:[GDataAnalyticsConstants analyticsNamespaces]];

  return feed;
}

+ (NSString *)standardKindAttributeValue {
  return @"analytics#data";
}

+ (void)load {
  [self registerFeedClass];
}

- (void)addExtensionDeclarations {
  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                 childClasses:
   [GDataAnalyticsAggregateGroup class],
   [GDataAnalyticsDataSource class],
   [GDataAnalyticsStartDate class],
   [GDataAnalyticsEndDate class],
   [GDataAnalyticsSegment class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"start",       @"startDateString", kGDataDescValueLabeled },
    { @"end",         @"endDateString",   kGDataDescValueLabeled },
    { @"aggregates",  @"aggregateGroup",  kGDataDescValueLabeled },
    { @"dataSources", @"dataSources",     kGDataDescArrayDescs   },
    { @"segments",    @"segments",        kGDataDescArrayDescs   },
    { nil, nil, (GDataDescRecTypes)0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif


- (Class)classForEntries {
  return [GDataEntryAnalyticsData class];
}

+ (NSString *)defaultServiceVersion {
  return kGDataAnalyticsDefaultServiceVersion;
}

#pragma mark -

- (GDataAnalyticsAggregateGroup *)aggregateGroup {
  return [self objectForExtensionClass:[GDataAnalyticsAggregateGroup class]];
}

- (void)setAggregateGroup:(GDataAnalyticsAggregateGroup *)obj {
  [self setObject:obj forExtensionClass:[GDataAnalyticsAggregateGroup class]];
}


- (NSArray *)dataSources {
  return [self objectsForExtensionClass:[GDataAnalyticsDataSource class]];
}

- (void)setDataSources:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataAnalyticsDataSource class]];
}

- (void)addDataSource:(GDataAnalyticsDataSource *)obj {
  [self addObject:obj forExtensionClass:[GDataAnalyticsDataSource class]];
}

- (NSString *)startDateString {
  GDataAnalyticsStartDate *obj;
  obj = [self objectForExtensionClass:[GDataAnalyticsStartDate class]];

  return [obj stringValue];
}

- (void)setStartDateString:(NSString *)str {
  GDataAnalyticsStartDate *obj;
  obj = [GDataAnalyticsStartDate valueWithString:str];

  [self setObject:obj forExtensionClass:[GDataAnalyticsStartDate class]];
}


- (NSString *)endDateString {
  GDataAnalyticsEndDate *obj;
  obj = [self objectForExtensionClass:[GDataAnalyticsEndDate class]];

  return [obj stringValue];
}

- (void)setEndDateString:(NSString *)str {
  GDataAnalyticsEndDate *obj;
  obj = [GDataAnalyticsEndDate valueWithString:str];

  [self setObject:obj forExtensionClass:[GDataAnalyticsEndDate class]];
}


- (NSArray *)segments {
  return [self objectsForExtensionClass:[GDataAnalyticsSegment class]];
}

- (void)setSegments:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataAnalyticsSegment class]];
}

- (void)addSegment:(GDataAnalyticsSegment *)obj {
  [self addObject:obj forExtensionClass:[GDataAnalyticsSegment class]];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE
