/* Copyright (c) 2007 Google Inc.
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
//  GDataServiceGoogleCalendar.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_GOOGLEBASE_SERVICE

#define GDATASERVICEGOOGLEBASE_DEFINE_GLOBALS 1

#import "GDataServiceGoogleBase.h"
#import "GDataFeedGoogleBase.h"
#import "GDataEntryGoogleBase.h"
#import "GDataQueryGoogleBase.h"


@implementation GDataServiceGoogleBase

- (void)dealloc {
  [developerKey_ release];
  [super dealloc];
}

- (void)setDeveloperKey:(NSString *)str {
  [developerKey_ autorelease];
  developerKey_ = [str copy];
}

// Google Base feeds and entries lack kind categories, but there is only
// one feed class and one entry class for the Google Base API, so we can
// hardwire in here the expected classes of the returned objects

- (GDataServiceTicket *)fetchFeedWithURL:(NSURL *)feedURL
                                delegate:(id)delegate
                       didFinishSelector:(SEL)finishedSelector {

  return [self fetchFeedWithURL:feedURL
                      feedClass:[GDataFeedGoogleBase class]
                       delegate:delegate
              didFinishSelector:finishedSelector];
}

- (GDataServiceTicket *)fetchEntryWithURL:(NSURL *)entryURL
                                 delegate:(id)delegate
                        didFinishSelector:(SEL)finishedSelector {

  return [self fetchEntryWithURL:entryURL
                      entryClass:[GDataEntryGoogleBase class]
                        delegate:delegate
               didFinishSelector:finishedSelector];
}

- (GDataServiceTicket *)fetchFeedWithQuery:(GDataQueryGoogleBase *)query
                                  delegate:(id)delegate
                         didFinishSelector:(SEL)finishedSelector {

  return [self fetchFeedWithURL:[query URL]
                      feedClass:[GDataFeedGoogleBase class]
                       delegate:delegate
              didFinishSelector:finishedSelector];
}

#pragma mark -

+ (NSString *)serviceID {
  return @"gbase";
}

- (NSMutableURLRequest *)requestForURL:(NSURL *)url
                                  ETag:(NSString *)etag
                            httpMethod:(NSString *)httpMethod
                                ticket:(GDataServiceTicketBase *)ticket {

  NSMutableURLRequest *request = [super requestForURL:url
                                                 ETag:etag
                                           httpMethod:httpMethod
                                               ticket:ticket];

  // add the developer key to the header
  if ([developerKey_ length] > 0) {
    NSString *value = [NSString stringWithFormat:@"key=%@", developerKey_];
    [request setValue:value forHTTPHeaderField: @"X-Google-Key"];
  }
  return request;
}

+ (NSString *)defaultServiceVersion {
  return kGDataGoogleBaseDefaultServiceVersion;
}

+ (NSDictionary *)standardServiceNamespaces {
  return [GDataEntryGoogleBase googleBaseNamespaces];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_GOOGLEBASE_SERVICE
