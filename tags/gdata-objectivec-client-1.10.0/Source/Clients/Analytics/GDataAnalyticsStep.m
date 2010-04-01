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
//  GDataAnalyticsStep.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE

#import "GDataAnalyticsStep.h"
#import "GDataAnalyticsConstants.h"

static NSString *const kNameAttr = @"name";
static NSString *const kNumberAttr = @"number";
static NSString *const kPathAttr = @"path";

@implementation GDataAnalyticsStep

+ (NSString *)extensionElementURI       { return kGDataNamespaceAnalyticsGA; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAnalyticsGAPrefix; }
+ (NSString *)extensionElementLocalName { return @"step"; }

- (void)addParseDeclarations {

  NSArray *attrs = [NSArray arrayWithObjects:
                    kNameAttr, kNumberAttr, kPathAttr, nil];

  [self addLocalAttributeDeclarations:attrs];
}

#pragma mark -

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

- (NSString *)path {
  NSString *str = [self stringValueForAttribute:kPathAttr];
  return str;
}

- (void)setPath:(NSString *)str {
  [self setStringValue:str forAttribute:kPathAttr];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE
