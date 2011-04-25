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
//  GDataServiceGoogleBlogger.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BLOGGER_SERVICE

#import "GDataServiceGoogleBlogger.h"

#import "GDataBloggerConstants.h" // for namespaces


@implementation GDataServiceGoogleBlogger

+ (NSURL *)blogFeedURLForUserID:(NSString *)userID {
  NSString *encodedUserID = [GDataUtilities stringByURLEncodingForURI:userID];

  NSString *const templateStr = @"%@%@/blogs";

  NSString *rootURLStr = [self serviceRootURLString];

  NSString *urlString = [NSString stringWithFormat:templateStr,
                         rootURLStr, encodedUserID];

  return [NSURL URLWithString:urlString];
}

#pragma mark -

// warn the user off of the wrong method calls
- (GDataServiceTicket *)fetchFeedWithURL:(NSURL *)feedURL
                                delegate:(id)delegate
                       didFinishSelector:(SEL)finishedSelector {

  // this service does not provide "kind" elements so cannot support
  // automatic class determination
  //
  // call fetchFeedWithURL:feedClass: instead, specifying the expected class
  // for the feed
  GDATA_DEBUG_LOG(@"GDataServiceGoogleBlogger: use fetchFeedWithURL:feedClass:");
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
  GDATA_DEBUG_LOG(@"GDataServiceGoogleBlogger: use fetchEntryWithURL:entryClass:");
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
  GDATA_DEBUG_LOG(@"GDataServiceGoogleBlogger: use fetchFeedWithQuery:feedClass:");
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

#pragma mark -

+ (NSString *)serviceID {
  return @"blogger";
}

+ (NSString *)serviceRootURLString {
  return @"https://www.blogger.com/feeds/";
}

+ (NSString *)defaultServiceVersion {
  return kGDataBloggerDefaultServiceVersion;
}

+ (NSDictionary *)standardServiceNamespaces {
  return [GDataBloggerConstants bloggerNamespaces];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BLOGGER_SERVICE
