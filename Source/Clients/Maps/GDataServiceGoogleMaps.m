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
//  GDataServiceGoogleMaps.m
//

#define GDATASERVICEGOOGLEMAPS_DEFINE_GLOBALS 1

#import "GDataServiceGoogleMaps.h"

#import "GDataMapConstants.h"

// currently, no service-specific query parameters
@implementation GDataQueryGoogleMaps
@end

@implementation GDataServiceGoogleMaps

+ (NSURL *)mapsFeedURLForUserID:(NSString *)userID
                     projection:(NSString *)projection {

  NSString *const template = @"%@maps/%@/%@";

  NSString *encodedUserID = [GDataUtilities stringByURLEncodingStringParameter:userID];

  NSString *rootURLStr = [self serviceRootURLString];

  NSString *urlString = [NSString stringWithFormat:template,
                         rootURLStr, encodedUserID, projection];

  return [NSURL URLWithString:urlString];
}

- (GDataServiceTicket *)fetchMapsFeedWithURL:(NSURL *)feedURL
                                    delegate:(id)delegate
                           didFinishSelector:(SEL)finishedSelector
                             didFailSelector:(SEL)failedSelector {

  return [self fetchAuthenticatedFeedWithURL:feedURL
                                   feedClass:kGDataUseRegisteredClass
                                    delegate:delegate
                           didFinishSelector:finishedSelector
                             didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchMapsEntryWithURL:(NSURL *)entryURL
                                     delegate:(id)delegate
                            didFinishSelector:(SEL)finishedSelector
                              didFailSelector:(SEL)failedSelector {

  return [self fetchAuthenticatedEntryWithURL:entryURL
                                   entryClass:kGDataUseRegisteredClass
                                     delegate:delegate
                            didFinishSelector:finishedSelector
                              didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchMapsEntryByInsertingEntry:(GDataEntryBase *)entryToInsert
                                            forFeedURL:(NSURL *)feedURL
                                              delegate:(id)delegate
                                     didFinishSelector:(SEL)finishedSelector
                                       didFailSelector:(SEL)failedSelector {

  if ([entryToInsert namespaces] == nil) {
    [entryToInsert setNamespaces:[GDataMapConstants mapsNamespaces]];
  }

  return [self fetchAuthenticatedEntryByInsertingEntry:entryToInsert
                                            forFeedURL:feedURL
                                              delegate:delegate
                                     didFinishSelector:finishedSelector
                                       didFailSelector:failedSelector];

}

- (GDataServiceTicket *)fetchMapsEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                          forEntryURL:(NSURL *)entryEditURL
                                             delegate:(id)delegate
                                    didFinishSelector:(SEL)finishedSelector
                                      didFailSelector:(SEL)failedSelector {

  if ([entryToUpdate namespaces] == nil) {
    [entryToUpdate setNamespaces:[GDataMapConstants mapsNamespaces]];
  }

  return [self fetchAuthenticatedEntryByUpdatingEntry:entryToUpdate
                                          forEntryURL:entryEditURL
                                             delegate:delegate
                                    didFinishSelector:finishedSelector
                                      didFailSelector:failedSelector];

}

- (GDataServiceTicket *)deleteMapsEntry:(GDataEntryBase *)entryToDelete
                               delegate:(id)delegate
                      didFinishSelector:(SEL)finishedSelector
                        didFailSelector:(SEL)failedSelector {

  return [self deleteAuthenticatedEntry:entryToDelete
                               delegate:delegate
                      didFinishSelector:finishedSelector
                        didFailSelector:failedSelector];
}

- (GDataServiceTicket *)deleteMapsResourceURL:(NSURL *)resourceEditURL
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

- (GDataServiceTicket *)fetchMapsQuery:(GDataQueryGoogleMaps *)query
                              delegate:(id)delegate
                     didFinishSelector:(SEL)finishedSelector
                       didFailSelector:(SEL)failedSelector {

  return [self fetchMapsFeedWithURL:[query URL]
                           delegate:delegate
                  didFinishSelector:finishedSelector
                    didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchMapsBatchFeedWithBatchFeed:(GDataFeedBase *)batchFeed
                                        forBatchFeedURL:(NSURL *)feedURL
                                               delegate:(id)delegate
                                      didFinishSelector:(SEL)finishedSelector
                                        didFailSelector:(SEL)failedSelector {

  return [self fetchAuthenticatedFeedWithBatchFeed:batchFeed
                                   forBatchFeedURL:feedURL
                                          delegate:delegate
                                 didFinishSelector:finishedSelector
                                   didFailSelector:failedSelector];
}

- (NSString *)serviceID {
  return @"local";
}

+ (NSString *)serviceRootURLString {
  return @"http://maps.google.com/maps/feeds/";
}

+ (NSString *)defaultServiceVersion {
  return kGDataMapsDefaultServiceVersion;
}

@end
