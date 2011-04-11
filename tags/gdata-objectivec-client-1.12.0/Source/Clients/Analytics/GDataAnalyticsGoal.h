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
//  GDataAnalyticsGoal.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE

#import "GDataObject.h"
#import "GDataAnalyticsDestination.h"
#import "GDataAnalyticsEngagement.h"

// Goal, like
//
//  <ga:goal active='true' name='Completing Order' number='1' value='10.0'>
//    <ga:destination caseSensitive='false' expression='/purchaseComplete.html'
//                    matchType='regex' step1Required='false'>
//      <ga:step name='View Product Categories' number='1'
//               path='/Apps|Accessories'/>
//    </ga:destination>
//  </ga:goal>

@interface GDataAnalyticsGoal : GDataObject <GDataExtension>

- (BOOL)isActive;
- (void)setIsActive:(BOOL)flag;

- (NSString *)name;
- (void)setName:(NSString *)str;

- (NSNumber *)number; // int
- (void)setNumber:(NSNumber *)num;

- (NSNumber *)value; // double
- (void)setValue:(NSNumber *)num;

- (GDataAnalyticsDestination *)destination;
- (void)setDestination:(GDataAnalyticsDestination *)obj;

- (GDataAnalyticsEngagement *)engagement;
- (void)setEngagement:(GDataAnalyticsEngagement *)obj;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE
