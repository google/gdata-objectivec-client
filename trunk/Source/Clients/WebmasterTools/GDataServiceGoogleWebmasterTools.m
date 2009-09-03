/* Copyright (c) 2008 Google Inc.
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
//  GDataServiceGoogleWebmasterTools.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE

#define GDATASERVICEGOOGLEWEBMASTERTOOLS_DEFINE_GLOBALS 1

#import "GDataServiceGoogleWebmasterTools.h"
#import "GDataWebmasterToolsConstants.h"

@implementation GDataServiceGoogleWebmasterTools

+ (NSURL *)webmasterToolsFeedURLForSiteID:(NSString *)siteID
                                 feedType:(NSString *)feedType {
  
  NSString *encodedSiteID;
  encodedSiteID = [GDataUtilities stringByURLEncodingForURI:siteID];
  
  NSString *const template = @"%@%@/%@";
  
  NSString *rootURLStr = [self serviceRootURLString];
  
  NSString *urlString = [NSString stringWithFormat:template, 
                         rootURLStr, encodedSiteID, feedType];
  
  return [NSURL URLWithString:urlString];
}

#pragma mark -

+ (NSString *)serviceID {
  return @"sitemaps";
}

+ (NSString *)serviceRootURLString {
  return @"https://www.google.com/webmasters/tools/feeds/"; 
}

+ (NSString *)defaultServiceVersion {
  return kGDataWebmasterToolsDefaultServiceVersion;
}

+ (NSDictionary *)standardServiceNamespaces {
  return [GDataWebmasterToolsConstants webmasterToolsNamespaces];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE
