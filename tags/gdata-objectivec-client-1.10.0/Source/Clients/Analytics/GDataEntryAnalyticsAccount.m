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
//  GDataEntryAnalyticsAccount.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE

#import "GDataEntryAnalyticsAccount.h"
#import "GDataAnalyticsConstants.h"
#import "GDataAnalyticsElements.h"

@implementation GDataEntryAnalyticsAccount

+ (GDataEntryAnalyticsAccount *)accountEntry {

  GDataEntryAnalyticsAccount *obj;
  obj = [[[self alloc] init] autorelease];

  [obj setNamespaces:[GDataAnalyticsConstants analyticsNamespaces]];

  return obj;
}

#pragma mark -

+ (NSString *)standardKindAttributeValue {
  return @"analytics#account";
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {
  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                 childClasses:
   [GDataAnalyticsProperty class],
   [GDataAnalyticsTableID class],
   [GDataAnalyticsGoal class],
   [GDataAnalyticsCustomVariable class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  NSArray *props = [self analyticsProperties];
  NSString *propsDescValue;
  propsDescValue = [GDataAnalyticsProperty descriptionItemForProperties:props];

  struct GDataDescriptionRecord descRecs[] = {
    { @"tableID",    @"tableID",     kGDataDescValueLabeled   },
    { @"properties", propsDescValue, kGDataDescValueIsKeyPath },
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

- (NSString *)tableID {
  GDataAnalyticsTableID *obj;

  obj = [self objectForExtensionClass:[GDataAnalyticsTableID class]];
  return [obj stringValue];
}

- (void)setTableID:(NSString *)str {
  GDataAnalyticsTableID *obj = [GDataAnalyticsTableID valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataAnalyticsTableID class]];
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


- (NSArray *)goals {
  return [self objectsForExtensionClass:[GDataAnalyticsGoal class]];
}

- (void)setGoals:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataAnalyticsGoal class]];
}

- (void)addGoal:(GDataAnalyticsGoal *)obj {
  [self addObject:obj forExtensionClass:[GDataAnalyticsGoal class]];
}

- (NSArray *)customVariables {
  return [self objectsForExtensionClass:[GDataAnalyticsCustomVariable class]];
}

- (void)setCustomVariables:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataAnalyticsCustomVariable class]];
}

- (void)addCustomVariable:(GDataAnalyticsCustomVariable *)obj {
  [self addObject:obj forExtensionClass:[GDataAnalyticsCustomVariable class]];
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
