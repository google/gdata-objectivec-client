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
//  GDataAnalyticsDataSource.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE

#import "GDataAnalyticsDataSource.h"

#import "GDataAnalyticsConstants.h"
#import "GDataAnalyticsElements.h"
#import "GDataUtilities.h"

@implementation GDataAnalyticsDataSource

+ (NSString *)extensionElementURI       { return kGDataNamespaceAnalyticsDXP; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAnalyticsDXPPrefix; }
+ (NSString *)extensionElementLocalName { return @"dataSource"; }

- (void)addExtensionDeclarations {
  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                 childClasses:
   [GDataAnalyticsProperty class],
   [GDataAnalyticsTableID class],
   [GDataAnalyticsTableName class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"tableID",    @"tableID",    kGDataDescValueLabeled },
    { @"tableName",  @"tableName",  kGDataDescValueLabeled },
    { @"properties", @"properties", kGDataDescArrayDescs   },
    { nil, nil, (GDataDescRecTypes)0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

#pragma mark -

- (NSString *)tableID {
  GDataAnalyticsTableID *obj;

  obj = [self objectForExtensionClass:[GDataAnalyticsTableID class]];
  return [obj stringValue];
}

- (void)setTableID:(NSString *)str {
  GDataAnalyticsTableID *obj = [GDataAnalyticsTableID valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataAnalyticsTableID class]];
}


- (NSString *)tableName {
  GDataAnalyticsTableName *obj;

  obj = [self objectForExtensionClass:[GDataAnalyticsTableName class]];
  return [obj stringValue];
}

- (void)setTableName:(NSString *)str {
  GDataAnalyticsTableName *obj = [GDataAnalyticsTableName valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataAnalyticsTableName class]];
}


- (NSArray *)analyticsProperties {
  return [self objectsForExtensionClass:[GDataAnalyticsProperty class]];
}

- (void)setAnalyticsProperties:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataAnalyticsProperty class]];
}

- (void)addAnalyticsProperty:(GDataAnalyticsProperty *)obj {
  [self addObject:obj forExtensionClass:[GDataAnalyticsProperty class]];
}

#pragma mark -

- (GDataAnalyticsProperty *)analyticsPropertyWithName:(NSString *)name {
  NSArray *array = [self analyticsProperties];
  GDataAnalyticsProperty *obj = [GDataUtilities firstObjectFromArray:array
                                                           withValue:name
                                                          forKeyPath:@"name"];
  return obj;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE
