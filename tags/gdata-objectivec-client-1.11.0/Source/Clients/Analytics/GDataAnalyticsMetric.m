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
//  GDataAnalyticsMetric.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE

#import "GDataAnalyticsMetric.h"
#import "GDataAnalyticsConstants.h"

static NSString *const kConfidenceIntervalAttr = @"confidenceInterval";
static NSString *const kNameAttr = @"name";
static NSString *const kTypeAttr = @"type";
static NSString *const kValueAttr = @"value";

@implementation GDataAnalyticsMetric

+ (NSString *)extensionElementURI       { return kGDataNamespaceAnalyticsDXP; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAnalyticsDXPPrefix; }
+ (NSString *)extensionElementLocalName { return @"metric"; }

- (void)addParseDeclarations {

  NSArray *attrs = [NSArray arrayWithObjects:
                    kNameAttr, kTypeAttr, kValueAttr,
                    kConfidenceIntervalAttr, nil];

  [self addLocalAttributeDeclarations:attrs];
}

#pragma mark -

- (NSNumber *)confidenceInterval {
  NSNumber *num = [self doubleNumberForAttribute:kConfidenceIntervalAttr];
  return num;
}

- (void)setConfidenceInterval:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kConfidenceIntervalAttr];
}

- (NSString *)name {
  NSString *str = [self stringValueForAttribute:kNameAttr];
  return str;
}

- (void)setName:(NSString *)str {
  [self setStringValue:str forAttribute:kNameAttr];
}

- (NSString *)type {
  NSString *str = [self stringValueForAttribute:kTypeAttr];
  return str;
}

- (void)setType:(NSString *)str {
  [self setStringValue:str forAttribute:kTypeAttr];
}

- (NSString *)stringValue {
  NSString *str = [self stringValueForAttribute:kValueAttr];
  return str;
}

- (void)setStringValue:(NSString *)str {
  [self setStringValue:str forAttribute:kValueAttr];
}

// convenience accessors
- (NSNumber *)doubleValue {
  NSNumber *num = [self doubleNumberForAttribute:kValueAttr];
  return num;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE
