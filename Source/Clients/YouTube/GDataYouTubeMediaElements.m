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

// media content with YouTube's addition of an integer format attribute, 
// like yt:format="1"
//
// The library does not currently support attribute extensions, so we'll
// subclass GDataMediaContent to add our attribute

@implementation GDataYouTubeMediaContent

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    NSString *const kFormatAttr = @"format";
    
    NSString *ytFormatAttrName = kFormatAttr;
    NSString *ytPrefix;
    
    // prepend "yt:" or the appropriate prefix
    ytPrefix = [element resolvePrefixForNamespaceURI:kGDataNamespaceYouTube];
    
    if ([ytPrefix length] > 0) {
      
      ytFormatAttrName = [NSString stringWithFormat:@"%@:%@", 
        ytPrefix, kFormatAttr];
    }
    
    [self setYouTubeFormatNumber:[self intNumberForAttributeName:ytFormatAttrName
                                                     fromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [youTubeFormatNumber_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataYouTubeMediaContent* newObj = [super copyWithZone:zone];
  [newObj setYouTubeFormatNumber:[self youTubeFormatNumber]];
  return newObj; 
}

- (BOOL)isEqual:(GDataYouTubeMediaContent *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataYouTubeMediaContent class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self youTubeFormatNumber], [other youTubeFormatNumber]);
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [super XMLElement];
  
  NSString *str = [[self youTubeFormatNumber] stringValue];
  
  NSString *attributeName = [NSString stringWithFormat:@"%@:%@",
    kGDataNamespaceYouTubePrefix, @"format"];
  
  [self addToElement:element attributeValueIfNonNil:str withName:attributeName];
  
  return element;
}

- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  [self addToArray:items objectDescriptionIfNonNil:[self youTubeFormatNumber] withName:@"ytFormat"];
  
  return items;
}

- (NSNumber *)youTubeFormatNumber {
  return youTubeFormatNumber_; 
}

- (void)setYouTubeFormatNumber:(NSNumber *)num {
  [youTubeFormatNumber_ autorelease];
  youTubeFormatNumber_ = [num copy];
}

@end

@implementation GDataYouTubeMediaGroup

// a media group that uses the YouTube media content elements instead
// of the generic media content elements

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  // use our custom version of the MediaContent extension, replacing the
  // extension used by the superclass GDataMediaGroup
  [self removeExtensionDeclarationForParentClass:[self class]
                                      childClass:[GDataMediaContent class]];  
  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataYouTubeMediaContent class]];

  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataYouTubeDuration class]];
  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataYouTubePrivate class]];
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

#pragma mark -

// override the superclass's mediaContents to store 
// and retrieve GDataYouTubeMediaContent in the extensions
// list

- (NSArray *)mediaContents {
  NSArray *array = [self objectsForExtensionClass:[GDataYouTubeMediaContent class]];
  return array;
}

- (void)setMediaContents:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataYouTubeMediaContent class]]; 
}

- (void)addMediaContent:(GDataYouTubeMediaContent *)attribute {
  [self addObject:attribute forExtensionClass:[GDataYouTubeMediaContent class]]; 
}

@end
