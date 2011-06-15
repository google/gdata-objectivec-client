/* Copyright (c) 2010 Google Inc.
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
//  GDataYouTubeRating.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataYouTubeRating.h"
#import "GDataYouTubeConstants.h"

static NSString* const kValueAttr       = @"value";
static NSString* const kNumLikesAttr    = @"numLikes";
static NSString* const kNumDislikesAttr = @"numDislikes";

@implementation GDataYouTubeRating
// <yt:rating numDislikes='28' numLikes='143'/>
// or
// <yt:rating value="like"/>

+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"rating"; }

+ (GDataYouTubeRating *)ratingWithValue:(NSString *)str {
  GDataYouTubeRating *obj = [self object];
  [obj setValue:str];
  return obj;
}

- (void)addParseDeclarations {
  NSArray *attrs = [NSArray arrayWithObjects:
                    kValueAttr, kNumLikesAttr, kNumDislikesAttr, nil];

  [self addLocalAttributeDeclarations:attrs];
}

#pragma mark -

- (NSString *)value {
  return [self stringValueForAttribute:kValueAttr];
}

- (void)setValue:(NSString *)str {
  [self setStringValue:str forAttribute:kValueAttr];
}

- (NSNumber *)numberOfLikes {
  return [self intNumberForAttribute:kNumLikesAttr];
}

- (void)setNumberOfLikes:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kNumLikesAttr];
}

- (NSNumber *)numberOfDislikes {
  return [self intNumberForAttribute:kNumDislikesAttr];
}

- (void)setNumberOfDislikes:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kNumDislikesAttr];
}
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
