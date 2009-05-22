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


#import "GDataAnalyticsConstants.h"
#import "GDataAnalyticsElements.h"

@implementation GDataAnalyticsDimension
+ (NSString *)extensionElementURI       { return kGDataNamespaceAnalytics; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAnalyticsPrefix; }
+ (NSString *)extensionElementLocalName { return @"dimension"; }
@end

@implementation GDataAnalyticsProperty
+ (NSString *)extensionElementURI       { return kGDataNamespaceAnalytics; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAnalyticsPrefix; }
+ (NSString *)extensionElementLocalName { return @"property"; }
@end

@implementation GDataAnalyticsStartDate
+ (NSString *)extensionElementURI       { return kGDataNamespaceAnalytics; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAnalyticsPrefix; }
+ (NSString *)extensionElementLocalName { return @"startDate"; }
@end

@implementation GDataAnalyticsEndDate
+ (NSString *)extensionElementURI       { return kGDataNamespaceAnalytics; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAnalyticsPrefix; }
+ (NSString *)extensionElementLocalName { return @"endDate"; }
@end

@implementation GDataAnalyticsTableID
+ (NSString *)extensionElementURI       { return kGDataNamespaceAnalytics; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAnalyticsPrefix; }
+ (NSString *)extensionElementLocalName { return @"tableId"; }
@end

@implementation GDataAnalyticsTableName
+ (NSString *)extensionElementURI       { return kGDataNamespaceAnalytics; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAnalyticsPrefix; }
+ (NSString *)extensionElementLocalName { return @"tableName"; }
@end
