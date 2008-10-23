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
//  GDataServiceGoogleSpreadsheet.m
//

#define GDATASERVICEGOOGLESPREADSHEET_DEFINE_GLOBALS 1
#import "GDataServiceGoogleSpreadsheet.h"

#import "GDataFeedSpreadsheet.h"
#import "GDataEntrySpreadsheet.h"
#import "GDataEntrySpreadsheetList.h"
#import "GDataEntrySpreadsheetCell.h"
#import "GDataEntryWorksheet.h"
#import "GDataQuerySpreadsheet.h"

// These routines are all simple wrappers around GDataServiceGoogle methods

@implementation GDataServiceGoogleSpreadsheet

- (GDataServiceTicket *)fetchSpreadsheetFeedWithURL:(NSURL *)feedURL
                                           delegate:(id)delegate
                                  didFinishSelector:(SEL)finishedSelector
                                    didFailSelector:(SEL)failedSelector {
  
  return [self fetchAuthenticatedFeedWithURL:feedURL 
                                   feedClass:kGDataUseRegisteredClass
                                    delegate:delegate
                           didFinishSelector:finishedSelector
                             didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchSpreadsheetEntryByInsertingEntry:(GDataEntryBase *)entryToInsert
                                                   forFeedURL:(NSURL *)spreadsheetFeedURL
                                                     delegate:(id)delegate
                                            didFinishSelector:(SEL)finishedSelector
                                              didFailSelector:(SEL)failedSelector {
  
  if ([entryToInsert namespaces] == nil) {
    [entryToInsert setNamespaces:[GDataEntrySpreadsheet spreadsheetNamespaces]]; 
  }
  
  return [self fetchAuthenticatedEntryByInsertingEntry:entryToInsert
                                            forFeedURL:spreadsheetFeedURL
                                              delegate:delegate
                                     didFinishSelector:finishedSelector
                                       didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchSpreadsheetEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                                 forEntryURL:(NSURL *)spreadsheetEntryEditURL
                                                    delegate:(id)delegate
                                           didFinishSelector:(SEL)finishedSelector
                                             didFailSelector:(SEL)failedSelector {
  
  if ([entryToUpdate namespaces] == nil) {
    [entryToUpdate setNamespaces:[GDataEntrySpreadsheet spreadsheetNamespaces]]; 
  }
  
  
  return [self fetchAuthenticatedEntryByUpdatingEntry:entryToUpdate
                                          forEntryURL:spreadsheetEntryEditURL
                                             delegate:delegate
                                    didFinishSelector:finishedSelector
                                      didFailSelector:failedSelector];
}

- (GDataServiceTicket *)deleteSpreadsheetEntry:(GDataEntryBase *)entryToDelete
                                      delegate:(id)delegate
                             didFinishSelector:(SEL)finishedSelector
                               didFailSelector:(SEL)failedSelector {
  
  return [self deleteAuthenticatedEntry:entryToDelete
                               delegate:delegate
                      didFinishSelector:finishedSelector
                        didFailSelector:failedSelector];  
}

- (GDataServiceTicket *)deleteSpreadsheetResourceURL:(NSURL *)resourceEditURL
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

- (GDataServiceTicket *)fetchSpreadsheetQuery:(GDataQuerySpreadsheet *)query
                                     delegate:(id)delegate
                            didFinishSelector:(SEL)finishedSelector
                              didFailSelector:(SEL)failedSelector {
  
  return [self fetchSpreadsheetFeedWithURL:[query URL]
                                  delegate:delegate
                         didFinishSelector:finishedSelector
                           didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchSpreadsheetFeedWithBatchFeed:(GDataFeedBase *)batchFeed
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
  return @"wise";
}

@end

