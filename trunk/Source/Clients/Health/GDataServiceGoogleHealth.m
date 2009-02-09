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

#define GDATASERVICEGOOGLEHEALTH_DEFINE_GLOBALS 1

#import "GDataServiceGoogleHealth.h"
#import "GDataQueryGoogleHealth.h"
#import "GDataEntryHealthProfile.h"

@implementation GDataServiceGoogleHealthSandbox
- (NSString *)serviceID {
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



- (GDataServiceTicket *)fetchHealthFeedWithURL:(NSURL *)feedURL
                                      delegate:(id)delegate
                             didFinishSelector:(SEL)finishedSelector
                               didFailSelector:(SEL)failedSelector {

  return [self fetchAuthenticatedFeedWithURL:feedURL
                                   feedClass:kGDataUseRegisteredClass
                                    delegate:delegate
                           didFinishSelector:finishedSelector
                             didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchHealthEntryWithURL:(NSURL *)entryURL
                                       delegate:(id)delegate
                              didFinishSelector:(SEL)finishedSelector
                                didFailSelector:(SEL)failedSelector {

  return [self fetchAuthenticatedEntryWithURL:entryURL
                                   entryClass:kGDataUseRegisteredClass
                                     delegate:delegate
                            didFinishSelector:finishedSelector
                              didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchHealthEntryByInsertingEntry:(GDataEntryBase *)entryToInsert
                                              forFeedURL:(NSURL *)feedURL
                                                delegate:(id)delegate
                                       didFinishSelector:(SEL)finishedSelector
                                         didFailSelector:(SEL)failedSelector {

  if ([entryToInsert namespaces] == nil) {
    [entryToInsert setNamespaces:[GDataEntryHealthProfile healthNamespaces]];
  }

  return [self fetchAuthenticatedEntryByInsertingEntry:entryToInsert
                                            forFeedURL:feedURL
                                              delegate:delegate
                                     didFinishSelector:finishedSelector
                                       didFailSelector:failedSelector];

}

- (GDataServiceTicket *)fetchHealthEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                            forEntryURL:(NSURL *)entryEditURL
                                               delegate:(id)delegate
                                      didFinishSelector:(SEL)finishedSelector
                                        didFailSelector:(SEL)failedSelector {

  if ([entryToUpdate namespaces] == nil) {
    [entryToUpdate setNamespaces:[GDataEntryHealthProfile healthNamespaces]];
  }

  return [self fetchAuthenticatedEntryByUpdatingEntry:entryToUpdate
                                          forEntryURL:entryEditURL
                                             delegate:delegate
                                    didFinishSelector:finishedSelector
                                      didFailSelector:failedSelector];

}

- (GDataServiceTicket *)deleteHealthEntry:(GDataEntryBase *)entryToDelete
                                 delegate:(id)delegate
                        didFinishSelector:(SEL)finishedSelector
                          didFailSelector:(SEL)failedSelector {

  return [self deleteAuthenticatedEntry:entryToDelete
                               delegate:delegate
                      didFinishSelector:finishedSelector
                        didFailSelector:failedSelector];
}

- (GDataServiceTicket *)deleteHealthResourceURL:(NSURL *)resourceEditURL
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

- (GDataServiceTicket *)fetchHealthQuery:(GDataQueryGoogleHealth *)query
                                delegate:(id)delegate
                       didFinishSelector:(SEL)finishedSelector
                         didFailSelector:(SEL)failedSelector {

  return [self fetchHealthFeedWithURL:[query URL]
                             delegate:delegate
                    didFinishSelector:finishedSelector
                      didFailSelector:failedSelector];
}

- (NSString *)serviceID {
  return @"health";
}

+ (NSString *)serviceRootURLString {
  return @"https://www.google.com/health/feeds/";
}

+ (NSString *)defaultServiceVersion {
  return kGDataHealthDefaultServiceVersion;
}

@end
