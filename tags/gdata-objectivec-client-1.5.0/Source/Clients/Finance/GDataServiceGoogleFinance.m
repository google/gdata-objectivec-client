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
//  GDataServiceGoogleFinance.m
//

#define GDATASERVICEGOOGLEFINANCE_DEFINE_GLOBALS 1

#import "GDataServiceGoogleFinance.h"

#import "GDataEntryFinancePortfolio.h"


@implementation GDataServiceGoogleFinance

+ (NSURL *)portfolioFeedURLForUserID:(NSString *)userID {
    
  NSString *const template = @"%@%@/portfolios";
  
  NSString *encodedUserID = [GDataUtilities stringByURLEncodingString:userID];
  
  NSString *rootURLStr = [self serviceRootURLString];

  NSString *urlString = [NSString stringWithFormat:template, 
                           rootURLStr, encodedUserID];
  
  return [NSURL URLWithString:urlString];
}

- (GDataServiceTicket *)fetchFinanceFeedWithURL:(NSURL *)feedURL
                                       delegate:(id)delegate
                              didFinishSelector:(SEL)finishedSelector
                                didFailSelector:(SEL)failedSelector {
  
  return [self fetchAuthenticatedFeedWithURL:feedURL 
                                   feedClass:kGDataUseRegisteredClass
                                    delegate:delegate
                           didFinishSelector:finishedSelector
                             didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchFinanceEntryWithURL:(NSURL *)entryURL
                                        delegate:(id)delegate
                               didFinishSelector:(SEL)finishedSelector
                                 didFailSelector:(SEL)failedSelector {
  
  return [self fetchAuthenticatedEntryWithURL:entryURL 
                                   entryClass:kGDataUseRegisteredClass
                                     delegate:delegate
                            didFinishSelector:finishedSelector
                              didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchFinanceEntryByInsertingEntry:(GDataEntryBase *)entryToInsert
                                               forFeedURL:(NSURL *)financeFeedURL
                                                 delegate:(id)delegate
                                        didFinishSelector:(SEL)finishedSelector
                                          didFailSelector:(SEL)failedSelector {
  
  if ([entryToInsert namespaces] == nil) {
    [entryToInsert setNamespaces:[GDataEntryFinancePortfolio financeNamespaces]]; 
  }
  
  return [self fetchAuthenticatedEntryByInsertingEntry:entryToInsert
                                            forFeedURL:financeFeedURL
                                              delegate:delegate
                                     didFinishSelector:finishedSelector
                                       didFailSelector:failedSelector];
  
}

- (GDataServiceTicket *)fetchFinanceEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                             forEntryURL:(NSURL *)financeEntryEditURL
                                                delegate:(id)delegate
                                       didFinishSelector:(SEL)finishedSelector
                                         didFailSelector:(SEL)failedSelector {
  
  if ([entryToUpdate namespaces] == nil) {
    [entryToUpdate setNamespaces:[GDataEntryFinancePortfolio financeNamespaces]]; 
  }
  
  
  return [self fetchAuthenticatedEntryByUpdatingEntry:entryToUpdate
                                          forEntryURL:financeEntryEditURL
                                             delegate:delegate
                                    didFinishSelector:finishedSelector
                                      didFailSelector:failedSelector];
  
}

- (GDataServiceTicket *)deleteFinanceEntry:(GDataEntryBase *)entryToDelete
                                  delegate:(id)delegate
                         didFinishSelector:(SEL)finishedSelector
                           didFailSelector:(SEL)failedSelector {
  
  return [self deleteAuthenticatedEntry:entryToDelete
                               delegate:delegate
                      didFinishSelector:finishedSelector
                        didFailSelector:failedSelector];  
}

- (GDataServiceTicket *)deleteFinanceResourceURL:(NSURL *)resourceEditURL
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

- (GDataServiceTicket *)fetchFinanceQuery:(GDataQueryFinance *)query
                                 delegate:(id)delegate
                        didFinishSelector:(SEL)finishedSelector
                          didFailSelector:(SEL)failedSelector {
  
  return [self fetchFinanceFeedWithURL:[query URL]
                              delegate:delegate
                     didFinishSelector:finishedSelector
                       didFailSelector:failedSelector];
}

- (NSString *)serviceID {
  return @"finance";
}

+ (NSString *)serviceRootURLString {
  return @"http://finance.google.com/finance/feeds/"; 
}

@end

