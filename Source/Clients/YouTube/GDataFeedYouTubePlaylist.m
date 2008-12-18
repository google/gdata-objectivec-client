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

#import "GDataFeedYouTubePlaylist.h"
#import "GDataEntryYouTubeVideo.h"

@implementation GDataFeedYouTubePlaylist

+ (GDataFeedYouTubePlaylist *)playlistFeed {
  
  GDataFeedYouTubePlaylist *feed = [[[self alloc] init] autorelease];
  
  [feed setNamespaces:[GDataEntryYouTubeVideo youTubeNamespaces]];
  
  return feed;
}

+ (void)load {
  [GDataObject registerFeedClass:[self class]
           forCategoryWithScheme:nil 
                            term:kGDataCategoryYouTubePlaylist];
}


- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class feedClass = [self class];
  [self addExtensionDeclarationForParentClass:feedClass
                                   childClass:[GDataYouTubePrivate class]];  

  // YouTubeMediaGroup encapsulates YouTubeMediaContent
  [self addExtensionDeclarationForParentClass:feedClass
                                   childClass:[GDataYouTubeMediaGroup class]];  
}

- (id)init {
  self = [super init];
  if (self) {
    [self addCategory:[GDataCategory categoryWithScheme:kGDataCategoryScheme
                                                   term:kGDataCategoryYouTubePlaylist]];
  }
  return self;
}


- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  if ([self isPrivate]) [items addObject:@"private"];

  [self addToArray:items objectDescriptionIfNonNil:[self mediaGroup] withName:@"mediaGroup"];

  return items;
}

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

+ (NSString *)defaultServiceVersion {
  return kGDataYouTubeDefaultServiceVersion;
}

@end
