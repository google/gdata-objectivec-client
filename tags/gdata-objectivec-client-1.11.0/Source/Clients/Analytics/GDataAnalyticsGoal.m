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
//  GDataAnalyticsGoal.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE

#import "GDataAnalyticsGoal.h"
#import "GDataAnalyticsConstants.h"

static NSString *const kActiveAttr = @"active";
static NSString *const kNameAttr = @"name";
static NSString *const kNumberAttr = @"number";
static NSString *const kValueAttr = @"value";

@implementation GDataAnalyticsGoal

+ (NSString *)extensionElementURI       { return kGDataNamespaceAnalyticsGA; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAnalyticsGAPrefix; }
+ (NSString *)extensionElementLocalName { return @"goal"; }

- (void)addParseDeclarations {

  NSArray *attrs = [NSArray arrayWithObjects:
                    kActiveAttr, kNameAttr, kNumberAttr, kValueAttr, nil];

  [self addLocalAttributeDeclarations:attrs];
}

- (void)addExtensionDeclarations {
  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                 childClasses:
   [GDataAnalyticsDestination class],
   [GDataAnalyticsEngagement class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"destination", @"destination", kGDataDescValueLabeled },
    { @"engagement",  @"engagement",  kGDataDescValueLabeled },
    { nil, nil, 0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

#pragma mark -

// Attributes

- (BOOL)isActive {
  BOOL flag = [self boolValueForAttribute:kActiveAttr
                             defaultValue:NO];
  return flag;
}

- (void)setIsActive:(BOOL)flag {
  [self setExplicitBoolValue:flag forAttribute:kActiveAttr];
}

- (NSString *)name {
  NSString *str = [self stringValueForAttribute:kNameAttr];
  return str;
}

- (void)setName:(NSString *)str {
  [self setStringValue:str forAttribute:kNameAttr];
}

- (NSNumber *)number { // int
  NSNumber *num = [self intNumberForAttribute:kNumberAttr];
  return num;
}

- (void)setNumber:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kNumberAttr];
}

- (NSNumber *)value { // double
  NSNumber *num = [self doubleNumberForAttribute:kValueAttr];
  return num;
}

- (void)setValue:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kValueAttr];
}

// Extensions

- (GDataAnalyticsDestination *)destination {
  return [self objectForExtensionClass:[GDataAnalyticsDestination class]];
}

- (void)setDestination:(GDataAnalyticsDestination *)obj {
  [self setObject:obj forExtensionClass:[GDataAnalyticsDestination class]];
}

- (GDataAnalyticsEngagement *)engagement {
  return [self objectForExtensionClass:[GDataAnalyticsEngagement class]];
}

- (void)setEngagement:(GDataAnalyticsEngagement *)obj {
  [self setObject:obj forExtensionClass:[GDataAnalyticsEngagement class]];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE
