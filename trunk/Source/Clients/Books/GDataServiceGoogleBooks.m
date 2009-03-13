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
//  GDataServiceGoogleBooks.m
//

#define GDATASERVICEGOOGLEBOOKS_DEFINE_GLOBALS 1

#import "GDataServiceGoogleBooks.h"
#import "GDataQueryBooks.h"

#import "GDataEntryVolume.h" // for namespaces


@implementation GDataServiceGoogleBooks

- (GDataServiceTicket *)fetchBooksFeedWithURL:(NSURL *)feedURL
                                       delegate:(id)delegate
                              didFinishSelector:(SEL)finishedSelector
                                didFailSelector:(SEL)failedSelector {
  
  return [self fetchAuthenticatedFeedWithURL:feedURL 
                                   feedClass:kGDataUseRegisteredClass
                                    delegate:delegate
                           didFinishSelector:finishedSelector
                             didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchBooksEntryWithURL:(NSURL *)entryURL
                                        delegate:(id)delegate
                               didFinishSelector:(SEL)finishedSelector
                                 didFailSelector:(SEL)failedSelector {
  
  return [self fetchAuthenticatedEntryWithURL:entryURL 
                                   entryClass:kGDataUseRegisteredClass
                                     delegate:delegate
                            didFinishSelector:finishedSelector
                              didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchBooksEntryByInsertingEntry:(GDataEntryBase *)entryToInsert
                                               forFeedURL:(NSURL *)booksFeedURL
                                                 delegate:(id)delegate
                                        didFinishSelector:(SEL)finishedSelector
                                          didFailSelector:(SEL)failedSelector {
  
  if ([entryToInsert namespaces] == nil) {
    [entryToInsert setNamespaces:[GDataEntryVolume booksNamespaces]]; 
  }
  
  return [self fetchAuthenticatedEntryByInsertingEntry:entryToInsert
                                            forFeedURL:booksFeedURL
                                              delegate:delegate
                                     didFinishSelector:finishedSelector
                                       didFailSelector:failedSelector];
  
}

- (GDataServiceTicket *)fetchBooksEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                             forEntryURL:(NSURL *)booksEntryEditURL
                                                delegate:(id)delegate
                                       didFinishSelector:(SEL)finishedSelector
                                         didFailSelector:(SEL)failedSelector {
  
  if ([entryToUpdate namespaces] == nil) {
    [entryToUpdate setNamespaces:[GDataEntryVolume booksNamespaces]]; 
  }
  
  
  return [self fetchAuthenticatedEntryByUpdatingEntry:entryToUpdate
                                          forEntryURL:booksEntryEditURL
                                             delegate:delegate
                                    didFinishSelector:finishedSelector
                                      didFailSelector:failedSelector];
  
}

- (GDataServiceTicket *)deleteBooksEntry:(GDataEntryBase *)entryToDelete
                                delegate:(id)delegate
                       didFinishSelector:(SEL)finishedSelector
                         didFailSelector:(SEL)failedSelector {
  
  return [self deleteAuthenticatedEntry:entryToDelete
                               delegate:delegate
                      didFinishSelector:finishedSelector
                        didFailSelector:failedSelector];  
}

- (GDataServiceTicket *)deleteBooksResourceURL:(NSURL *)resourceEditURL
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

- (GDataServiceTicket *)fetchBooksQuery:(GDataQueryBooks *)query
                                 delegate:(id)delegate
                        didFinishSelector:(SEL)finishedSelector
                          didFailSelector:(SEL)failedSelector {
  
  return [self fetchBooksFeedWithURL:[query URL]
                              delegate:delegate
                     didFinishSelector:finishedSelector
                       didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchBooksBatchFeedWithBatchFeed:(GDataFeedBase *)batchFeed
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
  return @"print";
}

+ (NSString *)serviceRootURLString {
  return @"http://books.google.com/books/feeds/"; 
}

+ (NSString *)defaultServiceVersion {
  return kGDataBooksDefaultServiceVersion;
}

@end

