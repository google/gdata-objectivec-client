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
//  GDataAnalyticsDataSource.h
//

// data source, like
//
//  <dxp:dataSource>
//    <dxp:tableId>ga:179684</dxp:tableId>
//    <dxp:tableName>www.example.net</dxp:tableName>
//    <dxp:property name="ga:profileId" value="179684"/>
//    <dxp:property name="ga:webPropertyId" value="UA-892159-1"/>
//    <dxp:property name="ga:accountName" value="example"/>
//  </dxp:dataSource>

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE

#import "GDataObject.h"

@class GDataAnalyticsProperty;

@interface GDataAnalyticsDataSource : GDataObject <GDataExtension>
- (NSString *)tableID;
- (void)setTableID:(NSString *)str;

- (NSString *)tableName;
- (void)setTableName:(NSString *)str;

- (NSArray *)analyticsProperties;
- (void)setAnalyticsProperties:(NSArray *)array;
- (void)addAnalyticsProperty:(GDataAnalyticsProperty *)obj;

// convenience accessors
- (GDataAnalyticsProperty *)analyticsPropertyWithName:(NSString *)name;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE
