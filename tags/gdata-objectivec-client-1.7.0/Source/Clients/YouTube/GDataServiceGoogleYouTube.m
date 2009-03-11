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
//  GDataServiceGoogleYouTube.m
//

#define GDATASERVICEYOUTUBE_DEFINE_GLOBALS 1
#import "GDataServiceGoogleYouTube.h"

#import "GDataEntryYouTubeVideo.h"

// These routines are all simple wrappers around GDataServiceGoogle methods

@implementation GDataServiceGoogleYouTube

- (void)dealloc {
  [developerKey_ release]; 
  [super dealloc];
}

+ (NSURL *)youTubeURLForFeedID:(NSString *)feedID {
  
  // like
  //
  //   http://gdata.youtube.com/feeds/api/videos
  //
  // or
  //
  //   http://gdata.youtube.com/feeds/api/standardfeeds/feedid
  //
  // See http://code.google.com/apis/youtube/2.0/reference.html#Standard_feeds for feed IDs
  
  NSString *endPart;
  
  if (feedID == nil) {
    endPart = @"videos";
  } else {
    endPart = [NSString stringWithFormat:@"standardfeeds/%@", feedID]; 
  }
  
  NSString *root = [self serviceRootURLString];
  
  NSString *template = @"%@api/%@";
  
  NSString *urlString = [NSString stringWithFormat:template, root, endPart];
  
  return [NSURL URLWithString:urlString];
}

+ (NSURL *)youTubeURLForUserID:(NSString *)userID
                    userFeedID:(NSString *)feedID {
  // Make a URL like
  //   http://gdata.youtube.com/feeds/api/users/username/favorites
  //
  // userID may be kGDataServiceDefaultUser

  NSString *encodedUserID = [GDataUtilities stringByURLEncodingString:userID];
  NSString *endPart;
  
  if (feedID == nil) {
    endPart = @"";
  } else {
    endPart = [NSString stringWithFormat:@"/%@", feedID]; 
  }
  
  NSString *root = [self serviceRootURLString];
  
  NSString *template = @"%@api/users/%@%@";
  
  NSString *urlString = [NSString stringWithFormat:template, root, 
    encodedUserID, endPart];
  
  return [NSURL URLWithString:urlString];  
}

+ (NSURL *)youTubeActivityFeedURLForUserID:(NSString *)userID {

  // Make a URL like
  //   http://gdata.youtube.com/feeds/api/events?author=usernames
  // (usernames can be a comma-separated list)
  //
  // For a friends activity feed, call youTubeURLForUserID:userFeedID:
  // with kGDataServiceDefaultUser and kGDataYouTubeUserFeedIDFriendsActivity

  NSString *encodedUserID = [GDataUtilities stringByURLEncodingStringParameter:userID];

  NSString *root = [self serviceRootURLString];

  NSString *template = @"%@api/events?author=%@";

  NSString *urlString = [NSString stringWithFormat:template,
                         root, encodedUserID];

  return [NSURL URLWithString:urlString];
}

+ (NSURL *)youTubeUploadURLForUserID:(NSString *)userID
                            clientID:(NSString *)clientID {
  // Make a URL like
  //   http://uploads.gdata.youtube.com/feeds/api/users/username/uploads?
  //       client=clientID
  //
  // userID may be "default" to indicate the currently authenticated user

  NSString *encodedUserID = [GDataUtilities stringByURLEncodingString:userID];
  NSString *encodedClientID = [GDataUtilities stringByURLEncodingString:clientID];

  NSString *root = [self serviceUploadRootURLString];

  NSString *template = @"%@api/users/%@/uploads?client=%@";

  NSString *urlString = [NSString stringWithFormat:template, root,
                         encodedUserID, encodedClientID];

  return [NSURL URLWithString:urlString];
}

- (NSString *)youTubeDeveloperKey {
  return developerKey_; 
}

- (void)setYouTubeDeveloperKey:(NSString *)str {
  [developerKey_ autorelease];
  developerKey_ = [str copy];
}


- (GDataServiceTicket *)fetchYouTubeFeedWithURL:(NSURL *)feedURL
                                       delegate:(id)delegate
                              didFinishSelector:(SEL)finishedSelector
                                didFailSelector:(SEL)failedSelector {
  
  return [self fetchAuthenticatedFeedWithURL:feedURL 
                                   feedClass:kGDataUseRegisteredClass
                                    delegate:delegate
                           didFinishSelector:finishedSelector
                             didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchYouTubeEntryWithURL:(NSURL *)entryURL
                                        delegate:(id)delegate
                               didFinishSelector:(SEL)finishedSelector
                                 didFailSelector:(SEL)failedSelector {
  
  return [self fetchAuthenticatedEntryWithURL:entryURL 
                                   entryClass:kGDataUseRegisteredClass
                                     delegate:delegate
                            didFinishSelector:finishedSelector
                              didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchYouTubeEntryByInsertingEntry:(GDataEntryBase *)entryToInsert
                                               forFeedURL:(NSURL *)youTubeFeedURL
                                                 delegate:(id)delegate
                                        didFinishSelector:(SEL)finishedSelector
                                          didFailSelector:(SEL)failedSelector {
  
  if ([entryToInsert namespaces] == nil) {
    [entryToInsert setNamespaces:[GDataEntryYouTubeVideo youTubeNamespaces]]; 
  }
  
  return [self fetchAuthenticatedEntryByInsertingEntry:entryToInsert
                                            forFeedURL:youTubeFeedURL
                                              delegate:delegate
                                     didFinishSelector:finishedSelector
                                       didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchYouTubeEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                             forEntryURL:(NSURL *)youTubeEntryEditURL
                                                delegate:(id)delegate
                                       didFinishSelector:(SEL)finishedSelector
                                         didFailSelector:(SEL)failedSelector {
  
  if ([entryToUpdate namespaces] == nil) {
    [entryToUpdate setNamespaces:[GDataEntryYouTubeVideo youTubeNamespaces]]; 
  }
  
  return [self fetchAuthenticatedEntryByUpdatingEntry:entryToUpdate
                                          forEntryURL:youTubeEntryEditURL
                                             delegate:delegate
                                    didFinishSelector:finishedSelector
                                      didFailSelector:failedSelector];
}

- (GDataServiceTicket *)deleteYouTubeEntry:(GDataEntryBase *)entryToDelete
                                  delegate:(id)delegate
                         didFinishSelector:(SEL)finishedSelector
                           didFailSelector:(SEL)failedSelector {
  
  return [self deleteAuthenticatedEntry:entryToDelete
                               delegate:delegate
                      didFinishSelector:finishedSelector
                        didFailSelector:failedSelector];
}

- (GDataServiceTicket *)deleteYouTubeResourceURL:(NSURL *)resourceEditURL
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

- (GDataServiceTicket *)fetchYouTubeQuery:(GDataQueryYouTube *)query
                                 delegate:(id)delegate
                        didFinishSelector:(SEL)finishedSelector
                          didFailSelector:(SEL)failedSelector {
  
  return [self fetchYouTubeFeedWithURL:[query URL]
                              delegate:delegate
                     didFinishSelector:finishedSelector
                       didFailSelector:failedSelector];
}

- (GDataServiceTicket *)fetchYouTubeBatchFeedWithBatchFeed:(GDataFeedBase *)batchFeed
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

#pragma mark -

// overrides of the superclass

- (NSMutableURLRequest *)requestForURL:(NSURL *)url 
                                  ETag:(NSString *)etag
                            httpMethod:(NSString *)httpMethod {

  // if the request is for posting, add the developer key, if it's known
  NSMutableURLRequest *request = [super requestForURL:url
                                                 ETag:etag
                                           httpMethod:httpMethod];
  
  // set the developer key, if any
  NSString *developerKey = [self youTubeDeveloperKey];
  if ([developerKey length] > 0) {
    
    NSString *value = [NSString stringWithFormat:@"key=%@", developerKey];
    [request setValue:value forHTTPHeaderField:@"X-GData-Key"];
  }
  
  return request;
}

// when authenticating, add the Content-Type header required by YouTube
- (NSMutableURLRequest *)authenticationRequestForURL:(NSURL *)url {
  
  NSMutableURLRequest *request = [super authenticationRequestForURL:url];
  
  [request setValue:@"application/x-www-form-urlencoded"
     forHTTPHeaderField:@"Content-Type"];
    
  return request;
}

- (NSString *)signInDomain {
  if (signInDomain_) {
    return signInDomain_; 
  }
  return @"www.google.com/youtube";
}

- (NSString *)serviceID {
  return @"youtube";
}

+ (NSString *)serviceRootURLString {
  return @"http://gdata.youtube.com/feeds/"; 
}

+ (NSString *)serviceUploadRootURLString {
  return @"http://uploads.gdata.youtube.com/feeds/";
}

+ (NSString *)defaultServiceVersion {
  return kGDataYouTubeDefaultServiceVersion;
}

@end

