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
//  GDataServiceGoogleHealth.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_HEALTH_SERVICE

#define GDATASERVICEGOOGLEHEALTH_DEFINE_GLOBALS 1
#import "GDataServiceGoogleHealth.h"

#import "GDataQueryGoogleHealth.h"
#import "GDataHealthConstants.h"

@implementation GDataServiceGoogleHealthSandbox
+ (NSString *)serviceID {
  return @"weaver";
}

+ (NSString *)serviceRootURLString {
  return @"https://www.google.com/h9/feeds/";
}
@end


@implementation GDataServiceGoogleHealth

+ (NSURL *)profileListFeedURL {

  NSString *const template = @"%@profile/list";

  NSString *rootURLStr = [self serviceRootURLString];

  NSString *urlString = [NSString stringWithFormat:template, rootURLStr];

  return [NSURL URLWithString:urlString];
}

+ (NSURL *)profileFeedURLForProfileID:(NSString *)profileID {

  NSString *const template = @"%@profile/ui/%@";

  NSString *rootURLStr = [self serviceRootURLString];

  NSString *urlString = [NSString stringWithFormat:template, rootURLStr,
                         profileID];

  return [NSURL URLWithString:urlString];
}

+ (NSURL *)registerFeedURLForProfileID:(NSString *)profileID {

  NSString *const template = @"%@register/ui/%@";

  NSString *rootURLStr = [self serviceRootURLString];

  NSString *urlString = [NSString stringWithFormat:template, rootURLStr,
                         profileID];

  return [NSURL URLWithString:urlString];
}

#pragma mark -

+ (NSString *)serviceID {
  return @"health";
}

+ (NSString *)serviceRootURLString {
  return @"https://www.google.com/health/feeds/";
}

+ (NSString *)defaultServiceVersion {
  return kGDataHealthDefaultServiceVersion;
}

+ (NSDictionary *)standardServiceNamespaces {
  return [GDataHealthConstants healthNamespaces];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_HEALTH_SERVICE
