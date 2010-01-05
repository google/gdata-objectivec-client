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
//  GDataAnalyticsDestination.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE

#import "GDataAnalyticsDestination.h"
#import "GDataAnalyticsConstants.h"

static NSString *const kCaseSensitiveAttr = @"caseSensitive";
static NSString *const kExpressionAttr = @"expression";
static NSString *const kMatchTypeAttr = @"matchType";
static NSString *const kStep1RequiredAttr = @"step1Required";

@implementation GDataAnalyticsDestination

+ (NSString *)extensionElementURI       { return kGDataNamespaceAnalyticsGA; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAnalyticsGAPrefix; }
+ (NSString *)extensionElementLocalName { return @"destination"; }

- (void)addParseDeclarations {

  NSArray *attrs = [NSArray arrayWithObjects:
                    kCaseSensitiveAttr, kExpressionAttr,
                    kMatchTypeAttr, kStep1RequiredAttr, nil];

  [self addLocalAttributeDeclarations:attrs];
}

- (void)addExtensionDeclarations {
  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataAnalyticsStep class]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"steps", @"steps", kGDataDescArrayDescs },
    { nil, nil, 0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

#pragma mark -

// Attributes

- (BOOL)isCaseSensitive {
  return [self boolValueForAttribute:kCaseSensitiveAttr
                        defaultValue:NO];
}

- (void)setIsCaseSensitive:(BOOL)flag {
  [self setExplicitBoolValue:flag forAttribute:kCaseSensitiveAttr];
}

- (NSString *)expression {
  return [self stringValueForAttribute:kExpressionAttr];
}

- (void)setExpression:(NSString *)str {
  [self setStringValue:str forAttribute:kExpressionAttr];
}

- (NSString *)matchType {
  return [self stringValueForAttribute:kMatchTypeAttr];
}

- (void)setMatchType:(NSString *)str {
  [self setStringValue:str forAttribute:kMatchTypeAttr];
}

- (BOOL)isStep1Required {
  return [self boolValueForAttribute:kStep1RequiredAttr
                        defaultValue:NO];
}

- (void)setIsStep1Required:(BOOL)flag {
  [self setExplicitBoolValue:flag forAttribute:kStep1RequiredAttr];
}

#pragma mark -

// Extensions

- (NSArray *)steps {
  return [self objectsForExtensionClass:[GDataAnalyticsStep class]];
}

- (void)setSteps:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataAnalyticsStep class]];
}

- (void)addStep:(GDataAnalyticsStep *)obj {
  [self addObject:obj forExtensionClass:[GDataAnalyticsStep class]];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE
