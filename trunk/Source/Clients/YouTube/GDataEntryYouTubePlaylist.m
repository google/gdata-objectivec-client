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
//  GDataEntryYouTubePlaylist.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataEntryYouTubePlaylist.h"
#import "GDataYouTubeConstants.h"

@implementation GDataEntryYouTubePlaylist

+ (GDataEntryYouTubePlaylist *)playlistEntry {
  
  GDataEntryYouTubePlaylist *entry = [self object];

  [entry setNamespaces:[GDataYouTubeConstants youTubeNamespaces]];
  
  return entry;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategoryYouTubePlaylist;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];
  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataYouTubePosition class]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];

  [self addToArray:items objectDescriptionIfNonNil:[self position] withName:@"position"]; 
    
  return items;
}
#endif

+ (NSString *)videoEntryCategoryTerm {
  // declare the term for the category that each entry gets in the superclass's
  // init method
  return kGDataCategoryYouTubePlaylist;
}

#pragma mark -

- (GDataYouTubePosition *)position {
  return [self objectForExtensionClass:[GDataYouTubePosition class]];
}

- (void)setPosition:(GDataYouTubePosition *)obj {
  [self setObject:obj forExtensionClass:[GDataYouTubePosition class]];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
