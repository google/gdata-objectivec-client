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
//  GDataAnalyticsEngagement.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE

#import "GDataObject.h"

// Engagement, like
//
//   <ga:engagement comparison='&gt;' thresholdValue='300' type='timeOnSite'/>


@interface GDataAnalyticsEngagement : GDataObject <GDataExtension>

// Attributes

- (NSString *)comparison;
- (void)setComparison:(NSString *)str;

- (NSNumber *)thresholdValue; // long long
- (void)setThresholdValue:(NSNumber *)num;

- (NSString *)type;
- (void)setType:(NSString *)str;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE
