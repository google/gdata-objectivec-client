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
//  GDataAnalyticsAggregateGroup.h
//

// aggregate of metrics, like
//
//  <dxp:aggregates>
//    <dxp:metric confidenceInterval="0.0"
//                name="ga:pageviews"
//                type="integer"
//                value="1" />
//  </dxp:aggregates>

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE

#import "GDataObject.h"

@class GDataAnalyticsMetric;

@interface GDataAnalyticsAggregateGroup : GDataObject <GDataExtension>
- (NSArray *)metrics;
- (void)setMetrics:(NSArray *)array;
- (void)addMetric:(GDataAnalyticsMetric *)obj;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE
