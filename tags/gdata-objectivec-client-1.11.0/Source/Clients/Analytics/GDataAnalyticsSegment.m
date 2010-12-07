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
//  GDataAnalyticsSegment.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE

#import "GDataAnalyticsSegment.h"
#import "GDataAnalyticsConstants.h"

static NSString *const kNameAttr = @"name";
static NSString *const kIDAttr = @"id";

@implementation GDataAnalyticsSegment

+ (NSString *)extensionElementURI       { return kGDataNamespaceAnalyticsDXP; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAnalyticsDXPPrefix; }
+ (NSString *)extensionElementLocalName { return @"segment"; }

- (void)addParseDeclarations {

  NSArray *attrs = [NSArray arrayWithObjects:
                    kNameAttr, kIDAttr, nil];

  [self addLocalAttributeDeclarations:attrs];
}

- (void)addExtensionDeclarations {
  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                 childClasses:
   [GDataAnalyticsDefinition class],
   [GDataAnalyticsProperty class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  NSArray *props = [self analyticsProperties];
  NSString *propsDescValue;
  propsDescValue = [GDataAnalyticsProperty descriptionItemForProperties:props];

  struct GDataDescriptionRecord descRecs[] = {
    { @"definition", @"definition", kGDataDescValueLabeled },
    { @"properties", propsDescValue, kGDataDescValueIsKeyPath },
    { nil, nil, 0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

#pragma mark -

// Attributes

- (NSString *)name {
  NSString *str = [self stringValueForAttribute:kNameAttr];
  return str;
}

- (void)setName:(NSString *)str {
  [self setStringValue:str forAttribute:kNameAttr];
}

- (NSString *)analyticsID {
  NSString *str = [self stringValueForAttribute:kIDAttr];
  return str;
}

- (void)setAnalyticsID:(NSString *)str {
  [self setStringValue:str forAttribute:kIDAttr];
}

#pragma mark -

// Extensions

- (NSString *)definition {
  GDataAnalyticsDefinition *obj;
  obj = [self objectForExtensionClass:[GDataAnalyticsDefinition class]];

  return [obj stringValue];
}

- (void)setDefinition:(NSString *)str {
  GDataAnalyticsDefinition *obj;
  obj = [GDataAnalyticsDefinition valueWithString:str];

  [self setObject:obj forExtensionClass:[GDataAnalyticsDefinition class]];
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

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE
