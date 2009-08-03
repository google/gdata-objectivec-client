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
//  GDataFeedYouTubePlaylist.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataFeedYouTubePlaylist.h"
#import "GDataYouTubeConstants.h"

@implementation GDataFeedYouTubePlaylist

+ (GDataFeedYouTubePlaylist *)playlistFeed {
  
  GDataFeedYouTubePlaylist *feed = [[[self alloc] init] autorelease];
  
  [feed setNamespaces:[GDataYouTubeConstants youTubeNamespaces]];
  
  return feed;
}

+ (NSString *)standardFeedKind {
  return kGDataCategoryYouTubePlaylist;
}

+ (void)load {
  [self registerFeedClass];
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  Class feedClass = [self class];
  [self addExtensionDeclarationForParentClass:feedClass
                                 childClasses:
   [GDataYouTubePrivate class],
   [GDataYouTubePlaylistID class],

   // YouTubeMediaGroup encapsulates YouTubeMediaContent
   [GDataYouTubeMediaGroup class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  if ([self isPrivate]) [items addObject:@"private"];

  [self addToArray:items objectDescriptionIfNonNil:[self mediaGroup] withName:@"mediaGroup"];

  return items;
}
#endif

- (Class)classForEntries {
  return kUseRegisteredEntryClass;
}

#pragma mark -

- (BOOL)isPrivate {
  GDataYouTubePrivate *obj = [self objectForExtensionClass:[GDataYouTubePrivate class]];
  return (obj != nil);
}

- (void)setIsPrivate:(BOOL)flag {
  if (flag) {
    GDataYouTubePrivate *private = [GDataYouTubePrivate implicitValue];
    [self setObject:private forExtensionClass:[GDataYouTubePrivate class]];
  } else {
    [self setObject:nil forExtensionClass:[GDataYouTubePrivate class]];
  }
}

- (GDataYouTubeMediaGroup *)mediaGroup {
  return [self objectForExtensionClass:[GDataYouTubeMediaGroup class]];
}

- (void)setMediaGroup:(GDataYouTubeMediaGroup *)obj {
  [self setObject:obj forExtensionClass:[GDataYouTubeMediaGroup class]];
}

- (NSString *)playlistID {
  GDataYouTubePlaylistID *obj = [self objectForExtensionClass:[GDataYouTubePlaylistID class]];
  return [obj stringValue];
}

- (void)setPlaylistID:(NSString *)str {
  GDataYouTubePlaylistID *obj = [GDataYouTubePlaylistID valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubePlaylistID class]];
}

+ (NSString *)defaultServiceVersion {
  return kGDataYouTubeDefaultServiceVersion;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
