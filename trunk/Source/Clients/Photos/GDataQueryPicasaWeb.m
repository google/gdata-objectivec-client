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
//  GDataQueryPicasaWeb.m
//

#define GDATAQUERYPICASAWEB_DEFINE_GLOBALS 1
#import "GDataQueryPicasaWeb.h"

#import "GDataServiceGooglePicasaWeb.h"

NSString *const kKindParamName = @"kind";
NSString *const kAccessParamName = @"access";
NSString *const kThumbsizeParamName = @"thumbsize";
NSString *const kImageSizeParamName = @"imgmax";
NSString *const kTagParamName = @"tag";

NSString *const kImageSizeOriginalPhoto = @"d";

@implementation GDataQueryPicasaWeb

+ (GDataQueryPicasaWeb *)picasaWebQueryWithFeedURL:(NSURL *)feedURL {
  return [[[[self class] alloc] initWithFeedURL:feedURL] autorelease];   
}

+ (GDataQueryPicasaWeb *)picasaWebQueryForUserID:(NSString *)userID
                                         albumID:(NSString *)albumIDorNil
                                       albumName:(NSString *)albumNameOrNil
                                         photoID:(NSString *)photoIDorNil {  
  NSURL *url;
  url = [GDataServiceGooglePicasaWeb picasaWebFeedURLForUserID:userID
                                                       albumID:albumIDorNil
                                                     albumName:albumNameOrNil
                                                       photoID:photoIDorNil
                                                          kind:nil
                                                        access:nil];
  return [self picasaWebQueryWithFeedURL:url];
}

- (NSString *)stringParamForInt:(int)val {
  if (val > 0) {
    return [NSString stringWithFormat:@"%d", val]; 
  }
  return nil;
}

- (void)setThumbsize:(int)val {
  [self addCustomParameterWithName:kThumbsizeParamName
                             value:[self stringParamForInt:val]];
}

- (int)thumbsize {
  return [[[self customParameters] objectForKey:kThumbsizeParamName] intValue];
}

- (void)setKind:(NSString *)str {
  [self addCustomParameterWithName:kKindParamName
                             value:str];
}

- (NSString *)kind {
  return [[self customParameters] objectForKey:kKindParamName];
}

- (void)setAccess:(NSString *)str {
  [self addCustomParameterWithName:kAccessParamName
                             value:str];
}

- (NSString *)access {
  return [[self customParameters] objectForKey:kAccessParamName];
}

- (void)setImageSize:(int)val {
  NSString *valStr;
  
  if (val == kGDataPicasaWebImageSizeDownloadable) {
    valStr = kImageSizeOriginalPhoto; // imgmax=d
  } else {
    valStr = [self stringParamForInt:val]; 
  }
  
  [self addCustomParameterWithName:kImageSizeParamName
                             value:valStr]; 
}

- (int)imageSize {
  NSString *valStr = [[self customParameters] objectForKey:kImageSizeParamName];

  if ([valStr isEqual:kImageSizeOriginalPhoto]) {
    return kGDataPicasaWebImageSizeDownloadable;
  }
  return [valStr intValue];
}

- (void)setTag:(NSString *)str {
  [self addCustomParameterWithName:kTagParamName
                             value:str];
}

- (NSString *)tag {
  return [[self customParameters] objectForKey:kTagParamName];
}
@end
