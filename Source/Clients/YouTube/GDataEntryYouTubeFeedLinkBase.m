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
//  GDataEntryYouTubeFeedLinkBase.m
//

#import "GDataEntryYouTubeFeedLinkBase.h"
#import "GDataEntryYouTubeVideo.h"

// this is the superclass for GDataEntryYouTubeSubscription and
// GDataEntryYouTubePlaylistLink

@implementation GDataEntryYouTubeFeedLinkBase

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];

  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataFeedLink class]];
  
  // YouTube element extensions
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataYouTubeDescription class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataYouTubePrivate class]];

  // media extensions
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataMediaThumbnail class]];
}

- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];

  [self addToArray:items objectDescriptionIfNonNil:[self feedLink] withName:@"feedLink"]; 
  [self addToArray:items objectDescriptionIfNonNil:[self youTubeDescription] withName:@"description"]; 
  [self addToArray:items objectDescriptionIfNonNil:[self thumbnail] withName:@"thumbnail"]; 

  return items;
}

- (id)init {
  self = [super init];
  if (self) {
  }
  return self;
}

#pragma mark -

- (GDataFeedLink *)feedLink {
  return [self objectForExtensionClass:[GDataFeedLink class]]; 
}

- (void)setFeedLink:(GDataFeedLink *)feedLink {
  return [self setObject:feedLink forExtensionClass:[GDataFeedLink class]]; 
}

- (GDataMediaThumbnail *)thumbnail {
  GDataMediaThumbnail *obj = [self objectForExtensionClass:[GDataMediaThumbnail class]];
  return obj;
}

- (void)setThumbnail:(GDataMediaThumbnail *)obj {
  [self setObject:obj forExtensionClass:[GDataMediaThumbnail class]];
}

- (NSString *)youTubeDescription {
  GDataYouTubeDescription *obj = [self objectForExtensionClass:[GDataYouTubeDescription class]];
  return [obj stringValue];
}

- (void)setYouTubeDescription:(NSString *)str {
  GDataYouTubeDescription *obj = [GDataYouTubeDescription valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeDescription class]];
}

@end
