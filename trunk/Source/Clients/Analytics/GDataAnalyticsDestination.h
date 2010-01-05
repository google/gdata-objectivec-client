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
//  GDataAnalyticsDestination.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE

#import "GDataObject.h"
#import "GDataAnalyticsStep.h"

// Destination, like
//
//   <ga:destination caseSensitive='false'
//          expression='/purchaseComplete.html'
//          matchType='regex'
//          step1Required='false'>
//       <ga:step name='View Product Categories'
//                number='1'
//                path='/Apps|Accessories'>
//   </ga:destination>

@interface GDataAnalyticsDestination : GDataObject <GDataExtension>

// Attributes

- (BOOL)isCaseSensitive;
- (void)setIsCaseSensitive:(BOOL)flag;

- (NSString *)expression;
- (void)setExpression:(NSString *)str;

- (NSString *)matchType;
- (void)setMatchType:(NSString *)str;

- (BOOL)isStep1Required;
- (void)setIsStep1Required:(BOOL)flag;

// Extensions

- (NSArray *)steps;
- (void)setSteps:(NSArray *)array;
- (void)addStep:(GDataAnalyticsStep *)obj;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE
