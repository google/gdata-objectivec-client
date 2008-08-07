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

#define GDATASERVICEGOOGLECONTACT_DEFINE_GLOBALS 1

#import "GDataServiceGoogleContact.h"
#import "GDataQueryContact.h"
#import "GDataFeedContact.h"

@class GDataFeedCalendar;
@class GDataFeedCalendarEvent;


@implementation GDataServiceGoogleContact

// feed is contacts or groups; projection is thin, default, or property-<key>
+ (NSURL *)feedURLForFeed:(NSString *)feed
                   userID:(NSString *)userID 
               projection:(NSString *)projection {
  
  NSString *baseURLString = [self serviceRootURLString];
  
  NSString *template = @"%@%@/%@/%@";
  
  NSString *feedURLString = [NSString stringWithFormat:template, 
                             baseURLString, 
                             [GDataUtilities stringByURLEncodingString:feed], 
                             [GDataUtilities stringByURLEncodingString:userID], 
                             [GDataUtilities stringByURLEncodingString:projection]];
  
  NSURL *url = [NSURL URLWithString:feedURLString];
  
  return url;
}

+ (NSURL *)contactFeedURLForPropertyName:(NSString *)property {
  
  NSString *projection = [NSString stringWithFormat:@"property-%@", property];
  NSURL *url = [self feedURLForFeed:@"contacts"
                             userID:@"default"
                         projection:projection];
  return url;
}

+ (NSURL *)contactGroupFeedURLForPropertyName:(NSString *)property {
  
  NSString *projection = [NSString stringWithFormat:@"property-%@", property];
  NSURL *url = [self feedURLForFeed:@"groups" 
                             userID:@"default" 
                         projection:projection];
  return url;
}

+ (NSURL *)contactFeedURLForUserID:(NSString *)userID {
  
  NSURL *url = [self feedURLForFeed:@"contacts" 
                             userID:userID
                         projection:@"full"];
  return url;
}

+ (NSURL *)contactFeedURLForUserID:(NSString *)userID 
                        projection:(NSString *)projection {
  
  NSURL *url = [self feedURLForFeed:@"contacts" 
                             userID:userID
                         projection:projection];
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
                                   feedClass:kGDataUseRegisteredClass
                                    delegate:delegate
                           didFinishSelector:finishedSelector
                             didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchContactEntryByInsertingEntry:(id)entryToInsert
                                               forFeedURL:(NSURL *)contactFeedURL
                                                 delegate:(id)delegate
                                        didFinishSelector:(SEL)finishedSelector
                                          didFailSelector:(SEL)failedSelector {
  
  if ([entryToInsert namespaces] == nil) {
    [(GDataObject *) entryToInsert setNamespaces:[GDataEntryContact contactNamespaces]]; 
  }
  
  return [self fetchAuthenticatedEntryByInsertingEntry:entryToInsert
                                            forFeedURL:contactFeedURL
                                              delegate:delegate
                                     didFinishSelector:finishedSelector
                                       didFailSelector:failedSelector];
  
}

- (GDataServiceTicket *)fetchContactEntryByUpdatingEntry:(id)entryToUpdate
                                             forEntryURL:(NSURL *)contactEntryEditURL
                                                delegate:(id)delegate
                                       didFinishSelector:(SEL)finishedSelector
                                         didFailSelector:(SEL)failedSelector {
  
  if ([entryToUpdate namespaces] == nil) {
    [(GDataObject *) entryToUpdate setNamespaces:[GDataEntryContact contactNamespaces]]; 
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

- (GDataServiceTicket *)deleteContactEntry:(id)entryToDelete
                                  delegate:(id)delegate
                         didFinishSelector:(SEL)finishedSelector
                           didFailSelector:(SEL)failedSelector {
  
  return [self deleteAuthenticatedEntry:entryToDelete
                               delegate:delegate
                      didFinishSelector:finishedSelector
                        didFailSelector:failedSelector];
}

- (GDataServiceTicket *)deleteContactResourceURL:(NSURL *)resourceEditURL
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

- (GDataServiceTicket *)fetchContactBatchFeedWithBatchFeed:(GDataFeedBase *)batchFeed
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
  return @"cp";
}

+ (NSString *)serviceRootURLString {
  return @"http://www.google.com/m8/feeds/"; 
}

@end

