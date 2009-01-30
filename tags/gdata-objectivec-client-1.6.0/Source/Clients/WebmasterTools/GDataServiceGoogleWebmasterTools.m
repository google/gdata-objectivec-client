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

#define GDATASERVICEGOOGLEWEBMASTERTOOLS_DEFINE_GLOBALS 1

#import "GDataServiceGoogleWebmasterTools.h"

@implementation GDataServiceGoogleWebmasterTools

+ (NSURL *)sitemapsFeedURLForSiteID:(NSString *)siteID {
  
  NSString *encodedSiteID;
  encodedSiteID = [GDataUtilities stringByURLEncodingStringParameter:siteID];
  
  NSString *const template = @"%@%@/sitemaps";
  
  NSString *rootURLStr = [self serviceRootURLString];
  
  NSString *urlString = [NSString stringWithFormat:template, 
                         rootURLStr, encodedSiteID];
  
  return [NSURL URLWithString:urlString];
}

- (GDataServiceTicket *)fetchWebmasterToolsFeedWithURL:(NSURL *)feedURL
                                              delegate:(id)delegate
                                     didFinishSelector:(SEL)finishedSelector
                                       didFailSelector:(SEL)failedSelector {
  
  return [self fetchAuthenticatedFeedWithURL:feedURL 
                                   feedClass:kGDataUseRegisteredClass
                                    delegate:delegate
                           didFinishSelector:finishedSelector
                             didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchWebmasterToolsEntryWithURL:(NSURL *)entryURL
                                               delegate:(id)delegate
                                      didFinishSelector:(SEL)finishedSelector
                                        didFailSelector:(SEL)failedSelector {
  
  return [self fetchAuthenticatedEntryWithURL:entryURL 
                                   entryClass:kGDataUseRegisteredClass
                                     delegate:delegate
                            didFinishSelector:finishedSelector
                              didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchWebmasterToolsEntryByInsertingEntry:(GDataEntryBase *)entryToInsert
                                                      forFeedURL:(NSURL *)feedURL
                                                        delegate:(id)delegate
                                               didFinishSelector:(SEL)finishedSelector
                                                 didFailSelector:(SEL)failedSelector {
  
  if ([entryToInsert namespaces] == nil) {
    [entryToInsert setNamespaces:[GDataEntrySite webmasterToolsNamespaces]]; 
  }
  
  return [self fetchAuthenticatedEntryByInsertingEntry:entryToInsert
                                            forFeedURL:feedURL
                                              delegate:delegate
                                     didFinishSelector:finishedSelector
                                       didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchWebmasterToolsEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                                    forEntryURL:(NSURL *)entryEditURL
                                                       delegate:(id)delegate
                                              didFinishSelector:(SEL)finishedSelector
                                                didFailSelector:(SEL)failedSelector {
  
  if ([entryToUpdate namespaces] == nil) {
    [entryToUpdate setNamespaces:[GDataEntrySite webmasterToolsNamespaces]]; 
  }
  
  return [self fetchAuthenticatedEntryByUpdatingEntry:entryToUpdate
                                          forEntryURL:entryEditURL
                                             delegate:delegate
                                    didFinishSelector:finishedSelector
                                      didFailSelector:failedSelector];
}

- (GDataServiceTicket *)deleteWebmasterToolsEntry:(GDataEntryBase *)entryToDelete
                                                       delegate:(id)delegate
                                              didFinishSelector:(SEL)finishedSelector
                                                didFailSelector:(SEL)failedSelector {
  
  return [self deleteAuthenticatedEntry:entryToDelete
                               delegate:delegate
                      didFinishSelector:finishedSelector
                        didFailSelector:failedSelector];
}

- (GDataServiceTicket *)deleteWebmasterToolsResourceURL:(NSURL *)resourceEditURL
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

- (NSString *)serviceID {
  return @"sitemaps";
}

+ (NSString *)serviceRootURLString {
  return @"https://www.google.com/webmasters/tools/feeds/"; 
}

+ (NSString *)defaultServiceVersion {
  return kGDataWebmasterToolsDefaultServiceVersion;
}

@end

