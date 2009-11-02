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
//  GDataEntryYouTubeUpload.m
//
//  This entry is used to upload to YouTube.
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataEntryYouTubeUpload.h"
#import "GDataYouTubeConstants.h"
#import "GDataYouTubeElements.h"

@implementation GDataEntryYouTubeUpload

+ (GDataEntryYouTubeUpload *)uploadEntryWithMediaGroup:(GDataYouTubeMediaGroup *)mediaGroup
                                                  data:(NSData *)data
                                              MIMEType:(NSString *)mimeType
                                                  slug:(NSString *)fileName {
  
  GDataEntryYouTubeUpload *entry = [[[self alloc] init] autorelease];

  [entry setNamespaces:[GDataYouTubeConstants youTubeNamespaces]];
  
  [entry setMediaGroup:mediaGroup];
  [entry setUploadData:data];
  [entry setUploadMIMEType:mimeType];
  [entry setUploadSlug:fileName];
  
  return entry;
}

#pragma mark -

+ (NSString *)defaultServiceVersion {
  return kGDataYouTubeDefaultServiceVersion;
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];

  // YouTubeMediaGroup encapsulates YouTubeMediaContent
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataYouTubeMediaGroup class]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  [self addToArray:items objectDescriptionIfNonNil:[self mediaGroup] withName:@"mediaGroup"];

  return items;
}
#endif

- (id)init {
  self = [super init];
  if (self) {
  }
  return self;
}

#pragma mark -

- (GDataYouTubeMediaGroup *)mediaGroup {
  return [self objectForExtensionClass:[GDataYouTubeMediaGroup class]];
}

- (void)setMediaGroup:(GDataYouTubeMediaGroup *)obj {
  [self setObject:obj forExtensionClass:[GDataYouTubeMediaGroup class]];
}
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
