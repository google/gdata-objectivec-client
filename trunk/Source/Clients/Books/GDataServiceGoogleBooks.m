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

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BOOKS_SERVICE

#define GDATASERVICEGOOGLEBOOKS_DEFINE_GLOBALS 1

#import "GDataServiceGoogleBooks.h"
#import "GDataQueryBooks.h"

#import "GDataBookConstants.h"


@implementation GDataServiceGoogleBooks

+ (NSURL *)booksURLForVolumeID:(NSString *)volumeID {
  
  NSString *rootURLStr = [self serviceRootURLString];
  NSString *urlStr;

  if (volumeID) {
    NSString *const templateStr = @"%@users/me/volumes/%@";
    urlStr = [NSString stringWithFormat:templateStr, rootURLStr, volumeID];
  } else {
    // no volume ID, so return the volumes feed URL
    NSString *const templateStr = @"%@users/me/volumes";
    urlStr = [NSString stringWithFormat:templateStr, rootURLStr];
  }
  
  return [NSURL URLWithString:urlStr];
}

+ (NSURL *)booksURLForCollectionID:(NSString *)collectionID {

  NSString *rootURLStr = [self serviceRootURLString];

  NSString *const templateStr = @"%@users/me/collections/%@/volumes";
  NSString *urlStr = [NSString stringWithFormat:templateStr,
                      rootURLStr, collectionID];

  return [NSURL URLWithString:urlStr];
}

+ (NSURL *)collectionsURL {
  NSString *rootURLStr = [self serviceRootURLString];

  NSString *const templateStr = @"%@users/me/collections";
  NSString *urlStr = [NSString stringWithFormat:templateStr,
                      rootURLStr];

  return [NSURL URLWithString:urlStr];
}

+ (NSString *)serviceID {
  return @"print";
}

+ (NSString *)serviceRootURLString {
  return @"http://books.google.com/books/feeds/";
}

+ (NSString *)defaultServiceVersion {
  return kGDataBooksDefaultServiceVersion;
}

+ (NSDictionary *)standardServiceNamespaces {
  return [GDataBookConstants booksNamespaces];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BOOKS_SERVICE
