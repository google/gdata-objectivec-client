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
//  GDataServiceGooglePicasaWeb.m
//

#define GDATASERVICEPICASAWEB_DEFINE_GLOBALS 1
#import "GDataServiceGooglePicasaWeb.h"
#import "GDataEntryPhotoBase.h"
#import "GDataQueryPicasaWeb.h"

// These routines are all simple wrappers around GDataServiceGoogle methods

@implementation GDataServiceGooglePicasaWeb

+ (NSURL *)picasaWebFeedURLForUserID:(NSString *)userID
                             albumID:(NSString *)albumIDorNil
                           albumName:(NSString *)albumNameOrNil
                             photoID:(NSString *)photoIDorNil
                                kind:(NSString *)feedKindOrNil
                              access:(NSString *)accessOrNil {
  
  NSString *albumID = @"";
  if (albumIDorNil) {
    albumID = [NSString stringWithFormat:@"/albumid/%@", 
      [GDataUtilities stringByURLEncodingString:albumIDorNil]]; 
  }
  
  NSString *albumName = @"";
  if (albumNameOrNil && !albumIDorNil) {
    albumName = [NSString stringWithFormat:@"/album/%@", 
      [GDataUtilities stringByURLEncodingString:albumNameOrNil]];
  }
  
  NSString *photo = @"";
  if (photoIDorNil) {
    photo = [NSString stringWithFormat:@"/photoid/%@", photoIDorNil]; 
  }
  
  // make an array for the kind and access query params, and join the arra items
  // into a query string
  NSString *query = @"";
  NSMutableArray *queryItems = [NSMutableArray array];
  if (feedKindOrNil) {
    feedKindOrNil = [GDataUtilities stringByURLEncodingStringParameter:feedKindOrNil];
    
    NSString *kindStr = [NSString stringWithFormat:@"kind=%@", feedKindOrNil];
    [queryItems addObject:kindStr];
  }
  
  if (accessOrNil) {
    accessOrNil = [GDataUtilities stringByURLEncodingStringParameter:accessOrNil];
    
    NSString *accessStr = [NSString stringWithFormat:@"access=%@", accessOrNil];
    [queryItems addObject:accessStr];
  }
  
  if ([queryItems count]) {
    NSString *queryList = [queryItems componentsJoinedByString:@"&"];
    
    query = [NSString stringWithFormat:@"?%@", queryList];
  }
  
  NSString *root = [self serviceRootURLString];
  
  NSString *template = @"%@feed/api/user/%@%@%@%@%@";
  NSString *urlString = [NSString stringWithFormat:template,
    root, [GDataUtilities stringByURLEncodingString:userID], 
    albumID, albumName, photo, query];
  
  return [NSURL URLWithString:urlString];
}

+ (NSURL *)picasaWebContactsFeedURLForUserID:(NSString *)userID {
    
  NSString *root = [self serviceRootURLString];
  
  NSString *template = @"%@feed/api/user/%@/contacts?kind=user";
  
  NSString *urlString = [NSString stringWithFormat:template,
    root, [GDataUtilities stringByURLEncodingString:userID]];
  
  return [NSURL URLWithString:urlString];
}

- (GDataServiceTicket *)fetchPicasaWebFeedWithURL:(NSURL *)feedURL
                                         delegate:(id)delegate
                                didFinishSelector:(SEL)finishedSelector
                                  didFailSelector:(SEL)failedSelector {
  
  return [self fetchAuthenticatedFeedWithURL:feedURL 
                                   feedClass:kGDataUseRegisteredClass
                                    delegate:delegate
                           didFinishSelector:finishedSelector
                             didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchPicasaWebEntryByInsertingEntry:(GDataEntryPhotoBase *)entryToInsert
                                                 forFeedURL:(NSURL *)picasaWebFeedURL
                                                   delegate:(id)delegate
                                          didFinishSelector:(SEL)finishedSelector
                                            didFailSelector:(SEL)failedSelector {
  
  if ([entryToInsert namespaces] == nil) {
    [entryToInsert setNamespaces:[GDataEntryPhotoBase photoNamespaces]]; 
  }
  
  return [self fetchAuthenticatedEntryByInsertingEntry:entryToInsert
                                            forFeedURL:picasaWebFeedURL
                                              delegate:delegate
                                     didFinishSelector:finishedSelector
                                       didFailSelector:failedSelector];
  
}

- (GDataServiceTicket *)fetchPicasaWebEntryByUpdatingEntry:(GDataEntryPhotoBase *)entryToUpdate
                                               forEntryURL:(NSURL *)picasaWebEntryEditURL
                                                  delegate:(id)delegate
                                         didFinishSelector:(SEL)finishedSelector
                                           didFailSelector:(SEL)failedSelector {
  
  if ([entryToUpdate namespaces] == nil) {
    [entryToUpdate setNamespaces:[GDataEntryPhotoBase photoNamespaces]]; 
  }
  
  
  return [self fetchAuthenticatedEntryByUpdatingEntry:entryToUpdate
                                          forEntryURL:picasaWebEntryEditURL
                                             delegate:delegate
                                    didFinishSelector:finishedSelector
                                      didFailSelector:failedSelector];
  
}

- (GDataServiceTicket *)deletePicasaWebResourceURL:(NSURL *)resourceEditURL
                                          delegate:(id)delegate
                                 didFinishSelector:(SEL)finishedSelector
                                   didFailSelector:(SEL)failedSelector {
  
  return [self deleteAuthenticatedResourceURL:resourceEditURL
                                     delegate:delegate
                            didFinishSelector:finishedSelector
                              didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchPicasaWebQuery:(GDataQueryPicasaWeb *)query
                                   delegate:(id)delegate
                          didFinishSelector:(SEL)finishedSelector
                            didFailSelector:(SEL)failedSelector {
  
  return [self fetchPicasaWebFeedWithURL:[query URL]
                                delegate:delegate
                       didFinishSelector:finishedSelector
                         didFailSelector:failedSelector];
  
}

- (NSString *)serviceID {
  return @"lh2";
}

+ (NSString *)serviceRootURLString {
  return @"http://picasaweb.google.com/data/"; 
}

@end

