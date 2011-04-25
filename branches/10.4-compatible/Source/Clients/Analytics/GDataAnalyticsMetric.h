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
//  GDataAnalyticsMetric.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE

#import "GDataObject.h"

// Metric, like
//
//     <dxp:metric confidenceInterval="0.0"
//                 name="ga:pageviews"
//                 type="integer"
//                 value="1"/>
//
// Metrics are documented at
// http://code.google.com/apis/analytics/docs/gdata/gdataReferenceDimensionsMetrics.html

@interface GDataAnalyticsMetric : GDataObject <GDataExtension>

- (NSNumber *)confidenceInterval; // double
- (void)setConfidenceInterval:(NSNumber *)num;

- (NSString *)name;
- (void)setName:(NSString *)str;

- (NSString *)type;
- (void)setType:(NSString *)str;

- (NSString *)stringValue;
- (void)setStringValue:(NSString *)str;

// convenience accessors

// return the value attribute as a double
- (NSNumber *)doubleValue;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE
