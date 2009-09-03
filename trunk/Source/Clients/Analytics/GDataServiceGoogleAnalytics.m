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
//  GDataServiceGoogleAnalytics.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE

#define GDATASERVICEGOOGLEANALYTICS_DEFINE_GLOBALS 1

#import "GDataServiceGoogleAnalytics.h"
#import "GDataQueryAnalytics.h"

#import "GDataAnalyticsConstants.h" // for namespaces


@implementation GDataServiceGoogleAnalytics

// warn the user off of the wrong method calls
- (GDataServiceTicket *)fetchFeedWithURL:(NSURL *)feedURL
                                delegate:(id)delegate
                       didFinishSelector:(SEL)finishedSelector {

  // this service does not provide "kind" elements so cannot support
  // automatic class determination
  //
  // call fetchFeedWithURL:feedClass: instead, specifying the expected class
  // of the feed
  GDATA_DEBUG_LOG(@"GDataServiceGoogleAnalytics: use fetchFeedWithURL:feedClass:");
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (GDataServiceTicket *)fetchEntryWithURL:(NSURL *)entryURL
                                 delegate:(id)delegate
                        didFinishSelector:(SEL)finishedSelector {

  // this service does not provide "kind" elements so cannot support
  // automatic class determination
  //
  // call fetchEntryWithURL:entryClass: instead, specifying the expected class
  // of the entry
  GDATA_DEBUG_LOG(@"GDataServiceGoogleAnalytics: use fetchEntryWithURL:entryClass:");
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

- (GDataServiceTicket *)fetchFeedWithQuery:(GDataQuery *)query
                                  delegate:(id)delegate
                         didFinishSelector:(SEL)finishedSelector {

  // this service does not provide "kind" elements so cannot support
  // automatic class determination
  //
  // call fetchFeedWithQuery:feedClass: instead, specifying the expected class
  // of the feed
  GDATA_DEBUG_LOG(@"GDataServiceGoogleAnalytics: use fetchFeedWithQueryL:feedClass:");
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

#pragma mark -

+ (NSString *)serviceID {
  return @"analytics";
}

+ (NSString *)serviceRootURLString {
  return @"https://www.google.com/analytics/feeds/";
}

+ (NSString *)defaultServiceVersion {
  return kGDataAnalyticsDefaultServiceVersion;
}

+ (NSDictionary *)standardServiceNamespaces {
  return [GDataAnalyticsConstants analyticsNamespaces];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE
