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
//  GDataAnalyticsConstants.h
//

#import <Foundation/Foundation.h>

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAANALYTICSCONSTANTS_DEFINE_GLOBALS
#define _EXTERN
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataAnalyticsDefaultServiceVersion _INITIALIZE_AS(@"2.0");

_EXTERN NSString* const kGDataNamespaceAnalytics       _INITIALIZE_AS(@"http://schemas.google.com/analytics/2009");
_EXTERN NSString* const kGDataNamespaceAnalyticsPrefix _INITIALIZE_AS(@"dxp");

// TODO check these once proper kind categories are added to the feeds
_EXTERN NSString* const kGDataCategoryAnalyticsAccount  _INITIALIZE_AS(@"http://schemas.google.com/analytics/2009#account");
_EXTERN NSString* const kGDataCategoryAnalyticsData     _INITIALIZE_AS(@"http://schemas.google.com/analytics/2009#data");

_EXTERN NSString* const kGDataMetricTypeCurrency   _INITIALIZE_AS(@"currency");
_EXTERN NSString* const kGDataMetricTypeFloat      _INITIALIZE_AS(@"float");
_EXTERN NSString* const kGDataMetricTypeInteger    _INITIALIZE_AS(@"integer");
_EXTERN NSString* const kGDataMetricTypePercent    _INITIALIZE_AS(@"percent");
_EXTERN NSString* const kGDataMetricTypeTime       _INITIALIZE_AS(@"time");
_EXTERN NSString* const kGDataMetricTypeUSCurrency _INITIALIZE_AS(@"us_currency");


@interface GDataAnalyticsConstants : NSObject
+ (NSDictionary *)analyticsNamespaces;
@end
