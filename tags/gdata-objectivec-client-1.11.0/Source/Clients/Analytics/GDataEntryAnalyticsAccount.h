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
//  GDataEntryAnalyticsAccount.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE

#import "GDataEntryBase.h"
#import "GDataAnalyticsGoal.h"
#import "GDataAnalyticsCustomVariable.h"
#import "GDataAnalyticsElements.h"


@interface GDataEntryAnalyticsAccount : GDataEntryBase

+ (GDataEntryAnalyticsAccount *)accountEntry;

// extensions

- (NSString *)tableID;
- (void)setTableID:(NSString *)str;

- (NSArray *)analyticsProperties;
- (void)setAnalyticsProperties:(NSArray *)array;
- (void)addAnalyticsProperty:(GDataAnalyticsProperty *)obj;

- (NSArray *)goals;
- (void)setGoals:(NSArray *)array;
- (void)addGoal:(GDataAnalyticsGoal *)obj;

- (NSArray *)customVariables;
- (void)setCustomVariables:(NSArray *)array;
- (void)addCustomVariable:(GDataAnalyticsCustomVariable *)obj;

// convenience accessor
- (GDataAnalyticsProperty *)analyticsPropertyWithName:(NSString *)name;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE
