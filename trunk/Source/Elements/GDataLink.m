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
//  GDataLink.m
//

#define GDATALINK_DEFINE_GLOBALS 1
#import "GDataLink.h"


@implementation GDataLink
// for links, like <link rel="alternate" type="text/html"
//     href="http://www.google.com/calendar/event?eid=b..." title="alternate"/>

+ (NSString *)extensionElementURI       { return kGDataNamespaceAtom; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAtomPrefix; }
+ (NSString *)extensionElementLocalName { return @"link"; }

+ (GDataLink *)linkWithRel:(NSString *)rel
                      type:(NSString *)type
                      href:(NSString *)href {
  GDataLink *link = [[[GDataLink alloc] init] autorelease];
  [link setRel:rel];
  [link setType:type];
  [link setHref:href];
  return link;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setRel:[self stringForAttributeName:@"rel"
                                  fromElement:element]];
    [self setType:[self stringForAttributeName:@"type"
                                   fromElement:element]];
    [self setHref:[self stringForAttributeName:@"href"
                                   fromElement:element]];
    [self setHrefLang:[self stringForAttributeName:@"hreflang"
                                       fromElement:element]];
    [self setTitle:[self stringForAttributeName:@"title"
                                    fromElement:element]];
    [self setTitleLang:[self stringForAttributeName:@"xml:lang"
                                        fromElement:element]];
    [self setResourceLength:[self intNumberForAttributeName:@"length"
                                                fromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [rel_ release];
  [type_ release];
  [href_ release];
  [hrefLang_ release];
  [title_ release];
  [titleLang_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataLink* newLink = [super copyWithZone:zone];
  [newLink setRel:rel_];
  [newLink setType:type_];
  [newLink setHref:href_];
  [newLink setHrefLang:hrefLang_];
  [newLink setTitle:title_];
  [newLink setTitleLang:titleLang_];
  [newLink setResourceLength:resourceLength_];
  return newLink;
}

- (BOOL)isEqual:(GDataLink *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataLink class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self rel], [other rel])
    && AreEqualOrBothNil([self type], [other type])
    && AreEqualOrBothNil([self href], [other href])
    && AreEqualOrBothNil([self hrefLang], [other hrefLang])
    && AreEqualOrBothNil([self title], [other title])
    && AreEqualOrBothNil([self titleLang], [other titleLang])
    && AreEqualOrBothNil([self resourceLength], [other resourceLength]);
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:rel_       withName:@"rel"];
  [self addToArray:items objectDescriptionIfNonNil:type_      withName:@"type"];
  [self addToArray:items objectDescriptionIfNonNil:href_      withName:@"href"];
  [self addToArray:items objectDescriptionIfNonNil:hrefLang_  withName:@"hrefLang"];
  [self addToArray:items objectDescriptionIfNonNil:title_     withName:@"title"];
  [self addToArray:items objectDescriptionIfNonNil:titleLang_ withName:@"xml:lang"];
  [self addToArray:items objectDescriptionIfNonNil:resourceLength_ withName:@"resourceLength"];
  
  return items;
}

- (NSXMLElement *)XMLElement {

  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"link"];
  
  [self addToElement:element attributeValueIfNonNil:[self rel]       withName:@"rel"];
  [self addToElement:element attributeValueIfNonNil:[self type]      withName:@"type"];
  [self addToElement:element attributeValueIfNonNil:[self href]      withName:@"href"];
  [self addToElement:element attributeValueIfNonNil:[self hrefLang]  withName:@"hrefLang"];
  [self addToElement:element attributeValueIfNonNil:[self title]     withName:@"title"];
  [self addToElement:element attributeValueIfNonNil:[self titleLang] withName:@"xml:lang"];
  
  [self addToElement:element attributeValueIfNonNil:[[self resourceLength] stringValue] withName:@"length"];
  
  return element;
}

- (NSString *)rel {
  return [rel_ length] ? rel_ : @"alternate"; // per Link.java
}

- (void)setRel:(NSString *)str {
  [rel_ autorelease];
  rel_ = [str copy];
}

- (NSString *)type {
  return type_; 
}

- (void)setType:(NSString *)str {
  [type_ autorelease];
  type_ = [str copy];
}

- (NSString *)href {
  return href_; 
}

- (void)setHref:(NSString *)str {
  [href_ autorelease];
  href_ = [str copy];
}

- (NSString *)hrefLang {
  return hrefLang_; 
}

- (void)setHrefLang:(NSString *)str {
  [hrefLang_ autorelease];
  hrefLang_ = [str copy];
}

- (NSString *)title {
  return title_; 
}

- (void)setTitle:(NSString *)str {
  [title_ autorelease];
  title_ = [str copy];
}

- (NSString *)titleLang {
  return titleLang_; 
}

- (void)setTitleLang:(NSString *)str {
  [titleLang_ autorelease];
  titleLang_ = [str copy];
}

- (NSNumber *)resourceLength {
  return resourceLength_; 
}

- (void)setResourceLength:(NSNumber *)length {
  [resourceLength_ release];
  resourceLength_ = [length retain];
}

// convenience method

- (NSURL *)URL {
  if ([href_ length]) {
    return [NSURL URLWithString:href_]; 
  }
  return nil;
}

// utility method

+ (NSArray *)linkNamesFromLinks:(NSArray *)links {
  // we'll make a list of short, readable link names
  // by grabbing the rel values, and removing anything before
  // the last pound sign if there is one
  
  NSMutableArray *names = [NSMutableArray array];
  
  NSEnumerator *linkEnum = [links objectEnumerator];
  GDataLink *link;
  while ((link = [linkEnum nextObject]) != nil) {
    
    NSString *rel = [link rel];
    NSRange range = [rel rangeOfString:@"#" options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
      NSString *suffix = [rel substringFromIndex:(1 + range.location)];
      [names addObject:suffix];
    } else {
      [names addObject:rel];
    }
  }
  return names;
}
@end

@implementation NSArray(GDataLinkArray)
- (GDataLink *)linkWithRelAttributeValue:(NSString *)relValue {
  
  return [self linkWithRel:relValue type:nil];
}

// Find the first link with the given rel and type values. Either argument
// may be nil, which means "match any value".
- (GDataLink *)linkWithRel:(NSString *)relValue type:(NSString *)typeValue {
  
  NSEnumerator *linkEnumerator = [self objectEnumerator]; 
  GDataLink *link;
  
  while ((link = [linkEnumerator nextObject]) != nil) {
    
    NSString *foundRelValue = [link rel];
    NSString *foundTypeValue = [link type];
    
    if ((relValue == nil || AreEqualOrBothNil(relValue, foundRelValue))
        && (typeValue == nil || AreEqualOrBothNil(typeValue, foundTypeValue))) {
      return link;
    }
  }
  return nil;  
}

- (GDataLink *)linkWithRelAttributeSuffix:(NSString *)relSuffix {
  
  NSEnumerator *linkEnumerator = [self objectEnumerator]; 
  GDataLink *link;
  
  while ((link = [linkEnumerator nextObject]) != nil) {
    
    NSString *attrValue = [link rel];
    if (attrValue && [attrValue hasSuffix:relSuffix]) {
      return link;
    }
  }
  return nil;  
}  

- (GDataLink *)feedLink {
  return [self linkWithRelAttributeValue:kGDataLinkRelFeed]; 
}

- (GDataLink *)postLink {
  return [self linkWithRelAttributeValue:kGDataLinkRelPost]; 
}

- (GDataLink *)editLink {
  return [self linkWithRelAttributeValue:@"edit"]; 
}

- (GDataLink *)editMediaLink {
  return [self linkWithRelAttributeValue:@"edit-media"]; 
}

- (GDataLink *)alternateLink {
  return [self linkWithRelAttributeValue:@"alternate"]; 
}

- (GDataLink *)relatedLink {
  return [self linkWithRelAttributeValue:@"related"]; 
}

- (GDataLink *)selfLink {
  return [self linkWithRelAttributeValue:@"self"]; 
}

- (GDataLink *)nextLink {
  return [self linkWithRelAttributeValue:@"next"]; 
}

- (GDataLink *)previousLink {
  return [self linkWithRelAttributeValue:@"previous"]; 
}

- (GDataLink *)HTMLLink {
  return [self linkWithRel:@"alternate" type:@"text/html"];
}

- (GDataLink *)batchLink {
  return [self linkWithRelAttributeValue:kGDataLinkRelBatch]; 
}
@end

