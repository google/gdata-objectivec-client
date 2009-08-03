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
//  GDataEntryYouTubeVideoMessage.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataYouTubeConstants.h"
#import "GDataEntryYouTubeVideoMessage.h"

@implementation GDataEntryYouTubeVideoMessage

+ (GDataEntryYouTubeVideoMessage *)videoMessageEntry {
  
  GDataEntryYouTubeVideoMessage *entry;
  
  entry = [[[self alloc] init] autorelease];

  [entry setNamespaces:[GDataYouTubeConstants youTubeNamespaces]];
  
  return entry;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategoryYouTubeVideoMessage;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];

  // GDataYouTubeDescription has been deprecated for GData v2
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataYouTubeDescription class]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  [self addToArray:items objectDescriptionIfNonNil:[self youTubeDescription] withName:@"description"];

  return items;
}
#endif

#pragma mark -

- (GDataYouTubeDescription *)youTubeDescription {
  GDATA_DEBUG_ASSERT_MAX_SERVICE_V1();
  
  return [self objectForExtensionClass:[GDataYouTubeDescription class]];
}

- (void)setYouTubeDescription:(GDataYouTubeDescription *)obj {
  GDATA_DEBUG_ASSERT_MAX_SERVICE_V1();
  
  [self setObject:obj forExtensionClass:[GDataYouTubeDescription class]];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
