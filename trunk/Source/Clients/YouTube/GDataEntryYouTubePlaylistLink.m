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
//  GDataEntryYouTubePlaylistLink.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataEntryYouTubePlaylistLink.h"
#import "GDataYouTubeConstants.h"
#import "GDataYouTubeElements.h"

@implementation GDataEntryYouTubePlaylistLink

+ (GDataEntryYouTubePlaylistLink *)playlistLinkEntry {
  
  GDataEntryYouTubePlaylistLink *entry = [self object];

  [entry setNamespaces:[GDataYouTubeConstants youTubeNamespaces]];
  
  return entry;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategoryYouTubePlaylistLink;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];

  // YouTube element extensions
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataYouTubePrivate class]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];

  if ([self isPrivate]) [items addObject:@"private"];

  return items;
}
#endif

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

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
