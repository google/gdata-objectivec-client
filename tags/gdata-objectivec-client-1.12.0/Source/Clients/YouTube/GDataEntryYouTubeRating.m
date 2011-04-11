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
//  GDataEntryYouTubeRating.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataEntryYouTubeRating.h"
#import "GDataYouTubeConstants.h"

@implementation GDataEntryYouTubeRating

+ (GDataEntryYouTubeRating *)ratingEntryWithValue:(NSString *)value {
  GDataEntryYouTubeRating *entry = [[[self alloc] init] autorelease];
  [entry setNamespaces:[GDataYouTubeConstants youTubeNamespaces]];
  [entry setRating:[GDataYouTubeRating ratingWithValue:value]];
  return entry;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategoryYouTubeRating;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];

  // YouTube element extensions
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataYouTubeRating class]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  [self addToArray:items objectDescriptionIfNonNil:[self rating] withName:@"rating"];

  return items;
}
#endif

+ (NSString *)defaultServiceVersion {
  return kGDataYouTubeDefaultServiceVersion;
}

#pragma mark -

- (GDataYouTubeRating *)rating {
  return [self objectForExtensionClass:[GDataYouTubeRating class]];
}

- (void)setRating:(GDataYouTubeRating *)obj {
  [self setObject:obj forExtensionClass:[GDataYouTubeRating class]];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
