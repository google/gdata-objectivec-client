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
//  GDataEntryYouTubeComment.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataEntryYouTubeComment.h"
#import "GDataYouTubeConstants.h"
#import "GDataYouTubeElements.h"

@implementation GDataEntryYouTubeComment

+ (GDataEntryYouTubeComment *)commentEntry {

  GDataEntryYouTubeComment *entry = [self object];

  [entry setNamespaces:[GDataYouTubeConstants youTubeNamespaces]];

  return entry;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategoryYouTubeComment;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                 childClasses:
   [GDataYouTubeCommentRating class],
   [GDataYouTubeSpam class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  NSMutableArray *items = [super itemsForDescription];

  [self addToArray:items objectDescriptionIfNonNil:[self totalRating] withName:@"rating"];

  if ([self hasSpam]) [items addObject:@"spam"];

  return items;
}
#endif

+ (NSString *)defaultServiceVersion {
  return kGDataYouTubeDefaultServiceVersion;
}

#pragma mark -

- (NSNumber *)totalRating {
  GDataYouTubeCommentRating *obj;

  obj = [self objectForExtensionClass:[GDataYouTubeCommentRating class]];
  return [obj intNumberValue];
}

- (void)setTotalRating:(NSNumber *)num {
  GDataYouTubeCommentRating *obj;

  obj = [GDataYouTubeCommentRating valueWithNumber:num];
  [self setObject:obj forExtensionClass:[GDataYouTubeCommentRating class]];
}

- (BOOL)hasSpam {
  GDataYouTubeSpam *obj;

  obj = [self objectForExtensionClass:[GDataYouTubeSpam class]];
  return (obj != nil);
}

- (void)setHasSpam:(BOOL)flag {
  if (flag) {
    GDataYouTubeSpam *spam = [GDataYouTubeSpam implicitValue];

    [self setObject:spam forExtensionClass:[GDataYouTubeSpam class]];
  } else {
    [self setObject:nil forExtensionClass:[GDataYouTubeSpam class]];
  }
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
