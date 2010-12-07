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
//  GDataEntryAnalyticsData.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE

#import "GDataEntryAnalyticsData.h"
#import "GDataAnalyticsConstants.h"
#import "GDataAnalyticsElements.h"
#import "GDataAnalyticsMetric.h"

@implementation GDataEntryAnalyticsData

+ (GDataEntryAnalyticsData *)dataEntry {

  GDataEntryAnalyticsData *obj;
  obj = [[[self alloc] init] autorelease];

  [obj setNamespaces:[GDataAnalyticsConstants analyticsNamespaces]];

  return obj;
}

#pragma mark -

+ (NSString *)standardKindAttributeValue {
  return @"analytics#datarow";
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {
  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                 childClasses:
   [GDataAnalyticsDimension class],
   [GDataAnalyticsMetric class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"metrics",    @"metrics",    kGDataDescArrayDescs },
    { @"dimensions", @"dimensions", kGDataDescArrayDescs },
    { nil, nil, 0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

+ (NSString *)defaultServiceVersion {
  return kGDataAnalyticsDefaultServiceVersion;
}

#pragma mark -

- (NSArray *)dimensions {
  return [self objectsForExtensionClass:[GDataAnalyticsDimension class]];
}

- (void)setDimensions:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataAnalyticsDimension class]];
}

- (void)addDimension:(GDataAnalyticsDimension *)obj {
  [self addObject:obj forExtensionClass:[GDataAnalyticsDimension class]];
}

- (GDataAnalyticsDimension *)dimensionWithName:(NSString *)name {
  NSArray *array = [self dimensions];

  GDataAnalyticsDimension *obj = [GDataUtilities firstObjectFromArray:array
                                                            withValue:name
                                                           forKeyPath:@"name"];
  return obj;
}


- (NSArray *)metrics {
  return [self objectsForExtensionClass:[GDataAnalyticsMetric class]];
}

- (void)setMetrics:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataAnalyticsMetric class]];
}

- (void)addMetric:(GDataAnalyticsMetric *)obj {
  [self addObject:obj forExtensionClass:[GDataAnalyticsMetric class]];
}

- (GDataAnalyticsMetric *)metricWithName:(NSString *)name {
  NSArray *array = [self metrics];

  GDataAnalyticsMetric *obj = [GDataUtilities firstObjectFromArray:array
                                                         withValue:name
                                                        forKeyPath:@"name"];
  return obj;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE
