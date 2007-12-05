/* Copyright (c) 2007 Google Inc.
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
//  GDataMediaGroup.m
//

#define GDATAMEDIAGROUP_DEFINE_GLOBALS 1
#import "GDataMediaGroup.h"

#import "GDataMediaContent.h"
#import "GDataMediaCredit.h"
#import "GDataMediaThumbnail.h"
#import "GDataMediaKeywords.h"

// we'll define MediaDescription and MediaTitle here, since they're
// just derived classes of GDataTextConstruct

@implementation GDataMediaDescription
+ (NSString *)extensionElementURI       { return kGDataNamespaceMedia; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceMediaPrefix; }
+ (NSString *)extensionElementLocalName { return @"description"; }
@end

@implementation GDataMediaTitle
+ (NSString *)extensionElementURI       { return kGDataNamespaceMedia; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceMediaPrefix; }
+ (NSString *)extensionElementLocalName { return @"title"; }
@end


@implementation GDataMediaGroup
// for media:group, like 
// <media:group> <media:contents  ... /> </media:group>

+ (NSString *)extensionElementURI       { return kGDataNamespaceMedia; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceMediaPrefix; }
+ (NSString *)extensionElementLocalName { return @"group"; }

#pragma mark -

+ (GDataMediaGroup *)mediaGroup {
                      
  GDataMediaGroup *obj = [[[GDataMediaGroup alloc] init] autorelease];
  return obj;
}

- (void)initExtensionDeclarations {
  
  [super initExtensionDeclarations];
  
  // media:group may contain media:content
  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataMediaContent class]];  
  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataMediaCredit class]];  
  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataMediaDescription class]];  
  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataMediaThumbnail class]];  
  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataMediaKeywords class]];  
  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataMediaTitle class]];  
  
  // still unsupported:
  // MediaCategory, MediaCopyright, MediaHash, MediaPlayer, MediaRating,
  // MediaText, MediaRestriction
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataMediaGroup* newObj = [super copyWithZone:zone];
  return newObj;
}

- (BOOL)isEqual:(GDataMediaGroup *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataMediaGroup class]]) return NO;
  
  return [super isEqual:other];
}

- (NSString *)description {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:[self mediaContents] withName:@"contents"];
  [self addToArray:items objectDescriptionIfNonNil:[self mediaCredits] withName:@"credits"];
  [self addToArray:items objectDescriptionIfNonNil:[self mediaThumbnails] withName:@"thumbnails"];
  [self addToArray:items objectDescriptionIfNonNil:[self mediaKeywords] withName:@"keywords"];
  [self addToArray:items objectDescriptionIfNonNil:[self mediaDescription] withName:@"description"];
  [self addToArray:items objectDescriptionIfNonNil:[self mediaTitle] withName:@"title"];
  
  return [NSString stringWithFormat:@"%@ 0x%lX: {%@}",
    [self class], self, [items componentsJoinedByString:@" "]];
}

- (NSXMLElement *)XMLElement {

  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"media:group"];
  return element;
}

#pragma mark -

// there are many more possible extensions; see MediaGroup.java
//
// Initially, we're just supporting the ones needed for Google Photos

// MediaContents

- (NSArray *)mediaContents {
  NSArray *array = [self objectsForExtensionClass:[GDataMediaContent class]];
  return array;
}

- (void)setMediaContents:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataMediaContent class]]; 
}

- (void)addMediaContent:(GDataMediaContent *)attribute {
  [self addObject:attribute forExtensionClass:[GDataMediaContent class]]; 
}

// MediaCredits

- (NSArray *)mediaCredits {
  NSArray *array = [self objectsForExtensionClass:[GDataMediaCredit class]];
  return array;
}

- (void)setMediaCredits:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataMediaCredit class]]; 
}

- (void)addMediaCredit:(GDataMediaCredit *)attribute {
  [self addObject:attribute forExtensionClass:[GDataMediaCredit class]]; 
}

// MediaThumbnails

- (NSArray *)mediaThumbnails {
  NSArray *array = [self objectsForExtensionClass:[GDataMediaThumbnail class]];
  return array;
}

- (void)setMediaThumbnails:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataMediaThumbnail class]]; 
}

- (void)addMediaThumbnail:(GDataMediaThumbnail *)attribute {
  [self addObject:attribute forExtensionClass:[GDataMediaThumbnail class]]; 
}

// MediaKeywords

- (GDataMediaKeywords *)mediaKeywords {
  GDataMediaKeywords *obj = 
      [self objectForExtensionClass:[GDataMediaKeywords class]];
  return obj;
}

- (void)setMediaKeywords:(GDataMediaKeywords *)obj {
  [self setObject:obj forExtensionClass:[GDataMediaKeywords class]]; 
}

// MediaDescription

- (GDataMediaDescription *)mediaDescription {
  GDataMediaDescription *obj = 
      [self objectForExtensionClass:[GDataMediaDescription class]];
  return obj;
}

- (void)setMediaDescription:(GDataMediaDescription *)obj {
  [self setObject:obj forExtensionClass:[GDataMediaDescription class]]; 
}

// MediaTitle

- (GDataMediaTitle *)mediaTitle {
  GDataMediaTitle *obj =
    [self objectForExtensionClass:[GDataMediaTitle class]];
  return obj;
}

- (void)setMediaTitle:(GDataMediaTitle *)obj {
  [self setObject:obj forExtensionClass:[GDataMediaTitle class]]; 
}

@end
