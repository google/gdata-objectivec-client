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
//  GDataAnalyticsElements.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE

#import "GDataObject.h"
#import "GDataValueConstruct.h"

// dimension, like <dxp:dimension name="ga:country" value="United States"/>
@interface GDataAnalyticsDimension : GDataNameValueConstruct <GDataExtension>
@end

// property name/value pair, like
// <dxp:property name="ga:accountId" value="8925159"/>
@interface GDataAnalyticsProperty : GDataNameValueConstruct <GDataExtension>
#if !GDATA_SIMPLE_DESCRIPTIONS
+ (NSString *)descriptionItemForProperties:(NSArray *)array;
#endif
@end

// start date, YYYY-MM-DD, like <dxp:startDate>2009-05-18</dxp:startDate>
@interface GDataAnalyticsStartDate : GDataValueElementConstruct <GDataExtension>
@end

// end date, YYYY-MM-DD, like <dxp:endDate>2009-05-18</dxp:endDate>
@interface GDataAnalyticsEndDate : GDataValueElementConstruct <GDataExtension>
@end

// table ID, like <dxp:tableId>ga:7966084</dxp:tableId>
@interface GDataAnalyticsTableID : GDataValueElementConstruct <GDataExtension>
@end

// table name, like <dxp:tableName>www.example.net</dxp:tableName>
@interface GDataAnalyticsTableName : GDataValueElementConstruct <GDataExtension>
@end

// definition, like <dxp:definition>ga:visitorType==New Visitor</dxp:definition>
@interface GDataAnalyticsDefinition : GDataValueElementConstruct <GDataExtension>
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE
