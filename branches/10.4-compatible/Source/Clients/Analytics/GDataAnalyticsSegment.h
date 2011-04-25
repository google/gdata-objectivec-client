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
//  GDataAnalyticsSegment.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE

#import "GDataObject.h"
#import "GDataAnalyticsElements.h"

// Segment, like
//
//  <dxp:segment id='gaid::-2' name='New Visitors'>
//    <dxp:definition>ga:visitorType==New Visitor</dxp:definition>
//    <dxp:property name='ga:accountId' value='30481'/>
//    <dxp:property name='ga:accountName' value='Google Store'/>
//  </dxp:segment>
//
// http://code.google.com/apis/analytics/docs/gdata/gdataReferenceAccountFeed.html

@interface GDataAnalyticsSegment : GDataObject <GDataExtension>

// Attributes

- (NSString *)name;
- (void)setName:(NSString *)str;

- (NSString *)analyticsID;
- (void)setAnalyticsID:(NSString *)str;

// Extensions

- (NSString *)definition;
- (void)setDefinition:(NSString *)str;

- (NSArray *)analyticsProperties;
- (void)setAnalyticsProperties:(NSArray *)array;
- (void)addAnalyticsProperty:(GDataAnalyticsProperty *)obj;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE
