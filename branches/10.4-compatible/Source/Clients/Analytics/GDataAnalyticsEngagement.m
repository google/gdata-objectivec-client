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
//  GDataAnalyticsEngagement.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE

#import "GDataAnalyticsEngagement.h"
#import "GDataAnalyticsConstants.h"

static NSString *const kComparisonAttr = @"comparison";
static NSString *const kThresholdValue = @"thresholdValue";
static NSString *const kTypeAttr = @"type";

@implementation GDataAnalyticsEngagement

+ (NSString *)extensionElementURI       { return kGDataNamespaceAnalyticsGA; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAnalyticsGAPrefix; }
+ (NSString *)extensionElementLocalName { return @"engagement"; }

- (void)addParseDeclarations {

  NSArray *attrs = [NSArray arrayWithObjects:
                    kComparisonAttr, kThresholdValue, kTypeAttr, nil];

  [self addLocalAttributeDeclarations:attrs];
}

#pragma mark -

// Attributes

- (NSString *)comparison {
  return [self stringValueForAttribute:kComparisonAttr];
}

- (void)setComparison:(NSString *)str {
  [self setStringValue:str forAttribute:kComparisonAttr];
}

- (NSNumber *)thresholdValue {
  return [self longLongNumberForAttribute:kThresholdValue];
}

- (void)setThresholdValue:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kThresholdValue];
}

- (NSString *)type {
  return [self stringValueForAttribute:kTypeAttr];
}

- (void)setType:(NSString *)str {
  [self setStringValue:str forAttribute:kTypeAttr];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE
