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
//  GDataAnalyticsElements.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE

#import "GDataAnalyticsConstants.h"
#import "GDataAnalyticsElements.h"

@implementation GDataAnalyticsDimension
+ (NSString *)extensionElementURI       { return kGDataNamespaceAnalyticsDXP; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAnalyticsDXPPrefix; }
+ (NSString *)extensionElementLocalName { return @"dimension"; }
@end

@implementation GDataAnalyticsProperty
+ (NSString *)extensionElementURI       { return kGDataNamespaceAnalyticsDXP; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAnalyticsDXPPrefix; }
+ (NSString *)extensionElementLocalName { return @"property"; }

#if !GDATA_SIMPLE_DESCRIPTIONS
// helper method for displaying descriptions of properties
+ (NSString *)descriptionItemForProperties:(NSArray *)array {

  NSString *propsDescValue = nil;
  NSMutableArray *propsDisplayArray = nil;

  // display properties as "(name=value, name2=value2)"
  for (GDataAnalyticsProperty *prop in array) {
    NSString *propDisplay = [NSString stringWithFormat:@"%@=%@",
                             [prop name], [prop stringValue]];
    if (propsDisplayArray == nil) {
      propsDisplayArray = [NSMutableArray array];
    }
    [propsDisplayArray addObject:propDisplay];
  }

  if (propsDisplayArray) {
    propsDescValue = [NSString stringWithFormat:@"(%@)",
                      [propsDisplayArray componentsJoinedByString:@", "]];
  }
  return propsDescValue;
}
#endif

@end

@implementation GDataAnalyticsStartDate
+ (NSString *)extensionElementURI       { return kGDataNamespaceAnalyticsDXP; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAnalyticsDXPPrefix; }
+ (NSString *)extensionElementLocalName { return @"startDate"; }
@end

@implementation GDataAnalyticsEndDate
+ (NSString *)extensionElementURI       { return kGDataNamespaceAnalyticsDXP; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAnalyticsDXPPrefix; }
+ (NSString *)extensionElementLocalName { return @"endDate"; }
@end

@implementation GDataAnalyticsTableID
+ (NSString *)extensionElementURI       { return kGDataNamespaceAnalyticsDXP; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAnalyticsDXPPrefix; }
+ (NSString *)extensionElementLocalName { return @"tableId"; }
@end

@implementation GDataAnalyticsTableName
+ (NSString *)extensionElementURI       { return kGDataNamespaceAnalyticsDXP; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAnalyticsDXPPrefix; }
+ (NSString *)extensionElementLocalName { return @"tableName"; }
@end

@implementation GDataAnalyticsDefinition
+ (NSString *)extensionElementURI       { return kGDataNamespaceAnalyticsDXP; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAnalyticsDXPPrefix; }
+ (NSString *)extensionElementLocalName { return @"definition"; }
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE
