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
//  GDataYouTubeMediaElements.m
//

#define GDATAYOUTUBEMEDIAELEMENTS_DEFINE_GLOBALS 1
#import "GDataYouTubeMediaElements.h"
#import "GDataEntryYouTubeVideo.h"

@interface GDataYouTubeFormatAttribute : GDataAttribute <GDataExtension>
@end

@implementation GDataYouTubeFormatAttribute
+ (NSString *)extensionElementURI { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"format"; }
@end

@implementation GDataMediaContent (YouTubeExtensions)

// media content with YouTube's addition of an integer format attribute, 
// like yt:format="1"
- (NSNumber *)youTubeFormatNumber {
  NSString *str = [self attributeValueForExtensionClass:[GDataYouTubeFormatAttribute class]];
  NSNumber *number = [NSNumber numberWithInt:[str intValue]]; 
  return number;
}

- (void)setYouTubeFormatNumber:(NSNumber *)num {
  [self setAttributeValue:[num stringValue] forExtensionClass:[GDataYouTubeFormatAttribute class]];
}

@end

@implementation GDataYouTubeMediaGroup

// a media group with YouTube extensions

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataYouTubeDuration class]];
  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataYouTubePrivate class]];
  
  // add the yt:format attribute to GDataMediaContent
  [self addAttributeExtensionDeclarationForParentClass:[GDataMediaContent class]
                                            childClass:[GDataYouTubeFormatAttribute class]];
}

- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  [self addToArray:items objectDescriptionIfNonNil:[self duration] withName:@"duration"];
  
  if ([self isPrivate]) [items addObject:@"private"];
  
  return items;
}

#pragma mark -

- (NSNumber *)duration {
  GDataYouTubeDuration *obj = [self objectForExtensionClass:[GDataYouTubeDuration class]];
  return [obj intNumberValue];
}

- (void)setDuration:(NSNumber *)num {
  GDataYouTubeDuration *obj = [GDataYouTubeDuration valueWithNumber:num];
  [self setObject:obj forExtensionClass:[GDataYouTubeDuration class]];
}

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
