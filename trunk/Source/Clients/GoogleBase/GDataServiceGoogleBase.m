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

#define GDATASERVICEGOOGLEBASE_DEFINE_GLOBALS 1

#import "GDataServiceGoogleBase.h"
#import "GDataFeedGoogleBase.h"
#import "GDataEntryGoogleBase.h"
#import "GDataQueryGoogleBase.h"

// These routines are all simple wrappers around GDataServiceGoogle methods

@implementation GDataServiceGoogleBase

- (void)dealloc {
  [developerKey_ release];
  [super dealloc]; 
}

- (void)setDeveloperKey:(NSString *)str {
  [developerKey_ autorelease];
  developerKey_ = [str copy];
}

- (GDataServiceTicket *)fetchGoogleBaseFeedWithURL:(NSURL *)feedURL
                                          delegate:(id)delegate
                                 didFinishSelector:(SEL)finishedSelector
                                   didFailSelector:(SEL)failedSelector {
  
  return [self fetchAuthenticatedFeedWithURL:feedURL 
                                   feedClass:[GDataFeedGoogleBase class]
                                    delegate:delegate
                           didFinishSelector:finishedSelector
                             didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchGoogleBaseEntryWithURL:(NSURL *)entryURL
                                           delegate:(id)delegate
                                  didFinishSelector:(SEL)finishedSelector
                                    didFailSelector:(SEL)failedSelector {
  
  return [self fetchAuthenticatedEntryWithURL:entryURL
                                   entryClass:[GDataEntryGoogleBase class]
                                     delegate:delegate
                            didFinishSelector:finishedSelector
                              didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchGoogleBaseEntryByInsertingEntry:(GDataEntryGoogleBase *)entryToInsert
                                                  forFeedURL:(NSURL *)googleBaseFeedURL
                                                    delegate:(id)delegate
                                           didFinishSelector:(SEL)finishedSelector
                                             didFailSelector:(SEL)failedSelector {
  
  if ([entryToInsert namespaces] == nil) {
    [entryToInsert setNamespaces:[GDataEntryGoogleBase googleBaseNamespaces]]; 
  }
  
  return [self fetchAuthenticatedEntryByInsertingEntry:entryToInsert
                                            forFeedURL:googleBaseFeedURL
                                              delegate:delegate
                                     didFinishSelector:finishedSelector
                                       didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchGoogleBaseEntryByUpdatingEntry:(GDataEntryGoogleBase *)entryToUpdate
                                                forEntryURL:(NSURL *)googleBaseEntryEditURL
                                                   delegate:(id)delegate
                                          didFinishSelector:(SEL)finishedSelector
                                            didFailSelector:(SEL)failedSelector {
  
  if ([entryToUpdate namespaces] == nil) {
    [entryToUpdate setNamespaces:[GDataEntryGoogleBase googleBaseNamespaces]]; 
  }
  
  
  return [self fetchAuthenticatedEntryByUpdatingEntry:entryToUpdate
                                          forEntryURL:googleBaseEntryEditURL
                                             delegate:delegate
                                    didFinishSelector:finishedSelector
                                      didFailSelector:failedSelector];
  
}

- (GDataServiceTicket *)deleteGoogleBaseEntry:(GDataEntryGoogleBase *)entryToDelete
                                     delegate:(id)delegate
                            didFinishSelector:(SEL)finishedSelector
                              didFailSelector:(SEL)failedSelector {

  return [self deleteAuthenticatedEntry:entryToDelete
                               delegate:delegate
                      didFinishSelector:finishedSelector
                        didFailSelector:failedSelector];
}

- (GDataServiceTicket *)deleteGoogleBaseResourceURL:(NSURL *)resourceEditURL
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

- (GDataServiceTicket *)fetchGoogleBaseQuery:(GDataQueryGoogleBase *)query
                                    delegate:(id)delegate
                           didFinishSelector:(SEL)finishedSelector
                             didFailSelector:(SEL)failedSelector {
  
  return [self fetchGoogleBaseFeedWithURL:[query URL]
                                 delegate:delegate
                        didFinishSelector:finishedSelector
                          didFailSelector:failedSelector];  
}

- (GDataServiceTicket *)fetchGoogleBaseFeedWithBatchFeed:(GDataFeedBase *)batchFeed
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
  return @"gbase";
}

- (NSMutableURLRequest *)requestForURL:(NSURL *)url
                                  ETag:(NSString *)etag
                            httpMethod:(NSString *)httpMethod {
  
  NSMutableURLRequest *request = [super requestForURL:url
                                                 ETag:etag
                                           httpMethod:httpMethod];
  
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

@end
