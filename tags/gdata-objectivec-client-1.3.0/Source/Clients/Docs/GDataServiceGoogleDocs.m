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
//  GDataServiceGoogleDocs.m
//

#define GDATASERVICEDOCS_DEFINE_GLOBALS 1
#import "GDataServiceGoogleDocs.h"
#import "GDataEntryDocBase.h"
#import "GDataQueryDocs.h"
#import "GDataFeedDocList.h"

// These routines are all simple wrappers around GDataServiceGoogle methods

@implementation GDataServiceGoogleDocs


- (GDataServiceTicket *)fetchDocsFeedWithURL:(NSURL *)feedURL
                                    delegate:(id)delegate
                           didFinishSelector:(SEL)finishedSelector
                             didFailSelector:(SEL)failedSelector {
  
  return [self fetchAuthenticatedFeedWithURL:feedURL 
                                   feedClass:[GDataFeedDocList class]
                                    delegate:delegate
                           didFinishSelector:finishedSelector
                             didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchDocEntryByInsertingEntry:(GDataEntryDocBase *)entryToInsert
                                            forFeedURL:(NSURL *)docsFeedURL
                                              delegate:(id)delegate
                                     didFinishSelector:(SEL)finishedSelector
                                       didFailSelector:(SEL)failedSelector {
  
  if ([entryToInsert namespaces] == nil) {
    [entryToInsert setNamespaces:[GDataEntryDocBase baseDocumentNamespaces]]; 
  }
  
  return [self fetchAuthenticatedEntryByInsertingEntry:entryToInsert
                                            forFeedURL:docsFeedURL
                                              delegate:delegate
                                     didFinishSelector:finishedSelector
                                       didFailSelector:failedSelector];
  
}

- (GDataServiceTicket *)fetchDocEntryByUpdatingEntry:(GDataEntryDocBase *)entryToUpdate
                                          forEntryURL:(NSURL *)docEntryEditURL
                                             delegate:(id)delegate
                                    didFinishSelector:(SEL)finishedSelector
                                      didFailSelector:(SEL)failedSelector {
  
  if ([entryToUpdate namespaces] == nil) {
    [entryToUpdate setNamespaces:[GDataEntryDocBase baseDocumentNamespaces]]; 
  }
  
  
  return [self fetchAuthenticatedEntryByUpdatingEntry:entryToUpdate
                                          forEntryURL:docEntryEditURL
                                             delegate:delegate
                                    didFinishSelector:finishedSelector
                                      didFailSelector:failedSelector];
  
}

// finished callback (see above) is passed the doc list feed
- (GDataServiceTicket *)fetchDocsQuery:(GDataQueryDocs *)query
                              delegate:(id)delegate
                     didFinishSelector:(SEL)finishedSelector
                       didFailSelector:(SEL)failedSelector {
 
  NSURL *feedURL = [query URL];
  
  return [self fetchDocsFeedWithURL:feedURL
                           delegate:delegate
                  didFinishSelector:finishedSelector
                    didFailSelector:failedSelector];  
}

- (GDataServiceTicket *)deleteDocResourceURL:(NSURL *)resourceEditURL
                                    delegate:(id)delegate
                           didFinishSelector:(SEL)finishedSelector
                             didFailSelector:(SEL)failedSelector {
  
  return [self deleteAuthenticatedResourceURL:resourceEditURL
                                     delegate:delegate
                            didFinishSelector:finishedSelector
                              didFailSelector:failedSelector];
}

- (NSString *)serviceID {
  return @"writely";
}

@end

