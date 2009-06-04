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

#import "GDataServiceGoogleBlogger.h"

#import "GDataBloggerConstants.h" // for namespaces


@implementation GDataServiceGoogleBlogger

+ (NSURL *)blogFeedURLForUserID:(NSString *)userID {
  NSString *encodedUserID = [GDataUtilities stringByURLEncodingForURI:userID];

  NSString *const template = @"%@%@/blogs";

  NSString *rootURLStr = [self serviceRootURLString];

  NSString *urlString = [NSString stringWithFormat:template,
                         rootURLStr, encodedUserID];

  return [NSURL URLWithString:urlString];
}

//- (GDataServiceTicket *)fetchBloggerFeedWithURL:(NSURL *)feedURL
//                                       delegate:(id)delegate
//                              didFinishSelector:(SEL)finishedSelector
//                                didFailSelector:(SEL)failedSelector {
//
//  return [self fetchAuthenticatedFeedWithURL:feedURL
//                                   feedClass:kGDataUseRegisteredClass
//                                    delegate:delegate
//                           didFinishSelector:finishedSelector
//                             didFailSelector:failedSelector];
//}
//
//- (GDataServiceTicket *)fetchBloggerEntryWithURL:(NSURL *)entryURL
//                                        delegate:(id)delegate
//                               didFinishSelector:(SEL)finishedSelector
//                                 didFailSelector:(SEL)failedSelector {
//
//  return [self fetchAuthenticatedEntryWithURL:entryURL
//                                   entryClass:kGDataUseRegisteredClass
//                                     delegate:delegate
//                            didFinishSelector:finishedSelector
//                              didFailSelector:failedSelector];
//}

- (GDataServiceTicket *)fetchBloggerEntryByInsertingEntry:(GDataEntryBase *)entryToInsert
                                               forFeedURL:(NSURL *)feedURL
                                                 delegate:(id)delegate
                                        didFinishSelector:(SEL)finishedSelector
                                          didFailSelector:(SEL)failedSelector {

  if ([entryToInsert namespaces] == nil) {
    [entryToInsert setNamespaces:[GDataBloggerConstants bloggerNamespaces]];
  }

  return [self fetchAuthenticatedEntryByInsertingEntry:entryToInsert
                                            forFeedURL:feedURL
                                              delegate:delegate
                                     didFinishSelector:finishedSelector
                                       didFailSelector:failedSelector];

}

- (GDataServiceTicket *)fetchBloggerEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                             forEntryURL:(NSURL *)entryEditURL
                                                delegate:(id)delegate
                                       didFinishSelector:(SEL)finishedSelector
                                         didFailSelector:(SEL)failedSelector {

  if ([entryToUpdate namespaces] == nil) {
    [entryToUpdate setNamespaces:[GDataBloggerConstants bloggerNamespaces]];
  }

  return [self fetchAuthenticatedEntryByUpdatingEntry:entryToUpdate
                                          forEntryURL:entryEditURL
                                             delegate:delegate
                                    didFinishSelector:finishedSelector
                                      didFailSelector:failedSelector];

}

- (GDataServiceTicket *)deleteBloggerEntry:(GDataEntryBase *)entryToDelete
                                  delegate:(id)delegate
                         didFinishSelector:(SEL)finishedSelector
                           didFailSelector:(SEL)failedSelector {

  return [self deleteAuthenticatedEntry:entryToDelete
                               delegate:delegate
                      didFinishSelector:finishedSelector
                        didFailSelector:failedSelector];
}

- (GDataServiceTicket *)deleteBloggerResourceURL:(NSURL *)resourceEditURL
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

//- (GDataServiceTicket *)fetchBloggerQuery:(GDataQuery *)query
//                                 delegate:(id)delegate
//                        didFinishSelector:(SEL)finishedSelector
//                          didFailSelector:(SEL)failedSelector {
//
//  return [self fetchBloggerFeedWithURL:[query URL]
//                              delegate:delegate
//                     didFinishSelector:finishedSelector
//                       didFailSelector:failedSelector];
//}

- (NSString *)serviceID {
  return @"blogger";
}

+ (NSString *)serviceRootURLString {
  return @"http://www.blogger.com/feeds/";
}

+ (NSString *)defaultServiceVersion {
  return kGDataBloggerDefaultServiceVersion;
}

@end
