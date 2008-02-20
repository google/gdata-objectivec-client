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

#import "GDataEntryYouTubePlaylist.h"
#import "GDataEntryYouTubeVideo.h"

@implementation GDataEntryYouTubePlaylist

+ (GDataEntryYouTubePlaylist *)playlistEntry {
  
  GDataEntryYouTubePlaylist *entry = [[[self alloc] init] autorelease];

  [entry setNamespaces:[GDataEntryYouTubeVideo youTubeNamespaces]];
  
  return entry;
}

#pragma mark -

+ (void)load {
  [GDataObject registerEntryClass:[self class]
            forCategoryWithScheme:nil 
                             term:kGDataCategoryYouTubePlaylist];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];
  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataYouTubeDescription class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataYouTubePosition class]];
}

- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];

  [self addToArray:items objectDescriptionIfNonNil:[self position] withName:@"position"]; 
  [self addToArray:items objectDescriptionIfNonNil:[self youTubeDescription] withName:@"description"]; 
    
  return items;
}

- (id)init {
  self = [super init];
  if (self) {
    // replace the category from the YouTube video entry superclass
    [self removeCategory:[GDataCategory categoryWithScheme:kGDataCategoryScheme
                                                      term:kGDataCategoryYouTubeVideo]];
    
    [self addCategory:[GDataCategory categoryWithScheme:kGDataCategoryScheme
                                                   term:kGDataCategoryYouTubePlaylist]];
  }
  return self;
}

#pragma mark -

- (GDataYouTubePosition *)position {
  return [self objectForExtensionClass:[GDataYouTubePosition class]];
}

- (void)setPosition:(GDataYouTubePosition *)obj {
  [self setObject:obj forExtensionClass:[GDataYouTubePosition class]];
}

- (GDataYouTubeDescription *)youTubeDescription {
  return [self objectForExtensionClass:[GDataYouTubeDescription class]];
}

- (void)setYouTubeDescription:(GDataYouTubeDescription *)obj {
  [self setObject:obj forExtensionClass:[GDataYouTubeDescription class]];
}

@end
