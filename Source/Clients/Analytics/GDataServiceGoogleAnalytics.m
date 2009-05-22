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

#define GDATASERVICEGOOGLEANALYTICS_DEFINE_GLOBALS 1

#import "GDataServiceGoogleAnalytics.h"
#import "GDataQueryAnalytics.h"

#import "GDataAnalyticsConstants.h" // for namespaces


@implementation GDataServiceGoogleAnalytics

- (GDataServiceTicket *)fetchAnalyticsFeedWithURL:(NSURL *)feedURL
                                         delegate:(id)delegate
                                didFinishSelector:(SEL)finishedSelector
                                  didFailSelector:(SEL)failedSelector {

  return [self fetchAuthenticatedFeedWithURL:feedURL
                                   feedClass:kGDataUseRegisteredClass
                                    delegate:delegate
                           didFinishSelector:finishedSelector
                             didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchAnalyticsEntryWithURL:(NSURL *)entryURL
                                          delegate:(id)delegate
                                 didFinishSelector:(SEL)finishedSelector
                                   didFailSelector:(SEL)failedSelector {

  return [self fetchAuthenticatedEntryWithURL:entryURL
                                   entryClass:kGDataUseRegisteredClass
                                     delegate:delegate
                            didFinishSelector:finishedSelector
                              didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchAnalyticsEntryByInsertingEntry:(GDataEntryBase *)entryToInsert
                                                 forFeedURL:(NSURL *)feedURL
                                                   delegate:(id)delegate
                                          didFinishSelector:(SEL)finishedSelector
                                            didFailSelector:(SEL)failedSelector {

  if ([entryToInsert namespaces] == nil) {
    [entryToInsert setNamespaces:[GDataAnalyticsConstants analyticsNamespaces]];
  }

  return [self fetchAuthenticatedEntryByInsertingEntry:entryToInsert
                                            forFeedURL:feedURL
                                              delegate:delegate
                                     didFinishSelector:finishedSelector
                                       didFailSelector:failedSelector];

}

- (GDataServiceTicket *)fetchAnalyticsEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                               forEntryURL:(NSURL *)entryEditURL
                                                  delegate:(id)delegate
                                         didFinishSelector:(SEL)finishedSelector
                                           didFailSelector:(SEL)failedSelector {

  if ([entryToUpdate namespaces] == nil) {
    [entryToUpdate setNamespaces:[GDataAnalyticsConstants analyticsNamespaces]];
  }

  return [self fetchAuthenticatedEntryByUpdatingEntry:entryToUpdate
                                          forEntryURL:entryEditURL
                                             delegate:delegate
                                    didFinishSelector:finishedSelector
                                      didFailSelector:failedSelector];

}

- (GDataServiceTicket *)deleteAnalyticsEntry:(GDataEntryBase *)entryToDelete
                                    delegate:(id)delegate
                           didFinishSelector:(SEL)finishedSelector
                             didFailSelector:(SEL)failedSelector {

  return [self deleteAuthenticatedEntry:entryToDelete
                               delegate:delegate
                      didFinishSelector:finishedSelector
                        didFailSelector:failedSelector];
}

- (GDataServiceTicket *)deleteAnalyticsResourceURL:(NSURL *)resourceEditURL
                                              ETag:(NSString *)etag
                                          delegate:(id)delegate
                                 didFinishSelector:(SEL)finishedSelector
                                   didFailSelector:(SEL)failedSelector {

  return [self deleteAuthenticatedResourceURL:resourceEditURL
                                         ETag:etag
                                     delegate:delegate
                            didFinishSelector:finishedSelector
                              didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchAnalyticsQuery:(GDataQueryAnalytics *)query
                                   delegate:(id)delegate
                          didFinishSelector:(SEL)finishedSelector
                            didFailSelector:(SEL)failedSelector {

  return [self fetchAnalyticsFeedWithURL:[query URL]
                                delegate:delegate
                       didFinishSelector:finishedSelector
                         didFailSelector:failedSelector];
}

- (NSString *)serviceID {
  return @"analytics";
}

+ (NSString *)serviceRootURLString {
  return @"https://www.google.com/analytics/feeds/";
}

+ (NSString *)defaultServiceVersion {
  return kGDataAnalyticsDefaultServiceVersion;
}

@end
