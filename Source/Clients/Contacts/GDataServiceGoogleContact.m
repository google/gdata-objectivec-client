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
//  GDataServiceGoogleCalendar.m
//

#import "GDataServiceGoogleContact.h"
#import "GDataQueryContact.h"
#import "GDataFeedContact.h"

@class GDataFeedCalendar;
@class GDataFeedCalendarEvent;


@implementation GDataServiceGoogleContact

+ (NSURL *)contactFeedURLForUserID:(NSString *)userID {

  NSString *baseURLString = [self serviceRootURLString];
  
  NSString *template = @"%@contacts/%@/full";

  NSString *feedURLString = [NSString stringWithFormat:template, 
    baseURLString, userID];
  
  NSURL *url = [NSURL URLWithString:feedURLString];
  
  return url;
}

- (GDataServiceTicket *)fetchContactFeedForUsername:(NSString *)username
                                           delegate:(id)delegate
                                  didFinishSelector:(SEL)finishedSelector
                                    didFailSelector:(SEL)failedSelector {
  
  NSURL *url = [[self class] contactFeedURLForUserID:username];
  
  return [self fetchContactFeedWithURL:url
                              delegate:delegate
                     didFinishSelector:finishedSelector
                       didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchContactFeedWithURL:(NSURL *)feedURL
                                       delegate:(id)delegate
                              didFinishSelector:(SEL)finishedSelector
                                didFailSelector:(SEL)failedSelector {
  
  return [self fetchAuthenticatedFeedWithURL:feedURL 
                                   feedClass:[GDataFeedContact class]
                                    delegate:delegate
                           didFinishSelector:finishedSelector
                             didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchContactEntryByInsertingEntry:(GDataEntryContact *)entryToInsert
                                               forFeedURL:(NSURL *)contactFeedURL
                                                 delegate:(id)delegate
                                        didFinishSelector:(SEL)finishedSelector
                                          didFailSelector:(SEL)failedSelector {
  
  if ([entryToInsert namespaces] == nil) {
    [entryToInsert setNamespaces:[GDataEntryContact contactNamespaces]]; 
  }
  
  return [self fetchAuthenticatedEntryByInsertingEntry:entryToInsert
                                            forFeedURL:contactFeedURL
                                              delegate:delegate
                                     didFinishSelector:finishedSelector
                                       didFailSelector:failedSelector];
  
}

- (GDataServiceTicket *)fetchContactEntryByUpdatingEntry:(GDataEntryContact *)entryToUpdate
                                             forEntryURL:(NSURL *)contactEntryEditURL
                                                delegate:(id)delegate
                                       didFinishSelector:(SEL)finishedSelector
                                         didFailSelector:(SEL)failedSelector {
  
  if ([entryToUpdate namespaces] == nil) {
    [entryToUpdate setNamespaces:[GDataEntryContact contactNamespaces]]; 
  }
  
  return [self fetchAuthenticatedEntryByUpdatingEntry:entryToUpdate
                                          forEntryURL:contactEntryEditURL
                                             delegate:delegate
                                    didFinishSelector:finishedSelector
                                      didFailSelector:failedSelector];
  
}

- (GDataServiceTicket *)fetchContactQuery:(GDataQueryContact *)query
                                 delegate:(id)delegate
                        didFinishSelector:(SEL)finishedSelector
                          didFailSelector:(SEL)failedSelector {
  
  return [self fetchContactFeedWithURL:[query URL]
                              delegate:delegate
                     didFinishSelector:finishedSelector
                       didFailSelector:failedSelector];
  
}

- (GDataServiceTicket *)deleteContactResourceURL:(NSURL *)resourceEditURL
                                        delegate:(id)delegate
                               didFinishSelector:(SEL)finishedSelector
                                 didFailSelector:(SEL)failedSelector {
  
  return [self deleteAuthenticatedResourceURL:resourceEditURL
                                     delegate:delegate
                            didFinishSelector:finishedSelector
                              didFailSelector:failedSelector];
}

- (NSString *)serviceID {
  return @"cp";
}

+ (NSString *)serviceRootURLString {
  return @"http://www.google.com/m8/feeds/"; 
}

@end

