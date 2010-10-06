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

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#define GDATASERVICEYOUTUBE_DEFINE_GLOBALS 1
#import "GDataServiceGoogleYouTube.h"

#import "GDataYouTubeConstants.h"
#import "GDataQueryYouTube.h"


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

  NSString *encodedUserID = [GDataUtilities stringByURLEncodingForURI:userID];
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

+ (NSURL *)youTubeUploadURLForUserID:(NSString *)userID {
  // Make a URL like
  //   http://uploads.gdata.youtube.com/feeds/api/users/username/uploads
  //
  // userID may be "default" to indicate the currently authenticated user

  NSString *encodedUserID = [GDataUtilities stringByURLEncodingForURI:userID];

  NSString *root = [self serviceUploadRootURLString];

  NSString *template = @"%@api/users/%@/uploads";

  NSString *urlString = [NSString stringWithFormat:template,
                         root, encodedUserID];

  return [NSURL URLWithString:urlString];
}

- (NSString *)youTubeDeveloperKey {
  return developerKey_;
}

- (void)setYouTubeDeveloperKey:(NSString *)str {
  [developerKey_ autorelease];
  developerKey_ = [str copy];
}

#pragma mark -

// overrides of the superclass

- (NSMutableURLRequest *)requestForURL:(NSURL *)url
                                  ETag:(NSString *)etag
                            httpMethod:(NSString *)httpMethod
                                ticket:(GDataServiceTicketBase *)ticket {

  // if the request is for posting, add the developer key, if it's known
  NSMutableURLRequest *request = [super requestForURL:url
                                                 ETag:etag
                                           httpMethod:httpMethod
                                               ticket:ticket];

  // set the developer key, if any
  NSString *developerKey = [self youTubeDeveloperKey];
  if ([developerKey length] > 0) {

    NSString *value = [NSString stringWithFormat:@"key=%@", developerKey];
    [request setValue:value forHTTPHeaderField:@"X-GData-Key"];
  }

  return request;
}

// when authenticating, add the Content-Type header required by YouTube
- (NSDictionary *)customAuthenticationRequestHeaders {
  return [NSDictionary dictionaryWithObject:@"application/x-www-form-urlencoded"
                                     forKey:@"Content-Type"];
}

- (NSString *)signInDomain {
  if (signInDomain_) {
    return signInDomain_;
  }
  return @"www.google.com/youtube";
}

+ (NSString *)serviceID {
  return @"youtube";
}

+ (NSString *)serviceRootURLString {
  return @"https://gdata.youtube.com/feeds/";
}

+ (NSString *)serviceUploadRootURLString {
  return @"http://uploads.gdata.youtube.com/resumable/feeds/";
}

+ (NSString *)defaultServiceVersion {
  return kGDataYouTubeDefaultServiceVersion;
}

+ (NSUInteger)defaultServiceUploadChunkSize {
  return kGDataStandardUploadChunkSize;
}

+ (NSDictionary *)standardServiceNamespaces {
  return [GDataYouTubeConstants youTubeNamespaces];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
