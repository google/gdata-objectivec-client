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
//  GDataMediaCategory.m
//


#import "GDataMediaCategory.h"
#import "GDataMediaGroup.h"

@implementation GDataMediaCategory
// like <media:category scheme="http://search.yahoo.com/mrss/category_schema" label="foo">
//             music/artist/album/song</media:category>
// http://search.yahoo.com/mrss

+ (NSString *)extensionElementURI       { return kGDataNamespaceMedia; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceMediaPrefix; }
+ (NSString *)extensionElementLocalName { return @"category"; }

+ (GDataMediaCategory *)mediaCategoryWithString:(NSString *)str {
  GDataMediaCategory* obj = [[[GDataMediaCategory alloc] init] autorelease];
  [obj setStringValue:str];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setLabel:[self stringForAttributeName:@"label"
                                     fromElement:element]];
    [self setScheme:[self stringForAttributeName:@"scheme"
                                          fromElement:element]];
    [self setStringValue:[self stringValueFromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [label_ release];
  [scheme_ release];
  [content_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataMediaCategory* newObj = [super copyWithZone:zone];
  [newObj setLabel:[self label]];
  [newObj setScheme:[self scheme]];
  [newObj setStringValue:[self stringValue]];
  return newObj;
}

- (BOOL)isEqual:(GDataMediaCategory *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataMediaCategory class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self label], [other label])
    && AreEqualOrBothNil([self scheme], [other scheme])
    && AreEqualOrBothNil([self stringValue], [other stringValue]);
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:label_ withName:@"label"];
  [self addToArray:items objectDescriptionIfNonNil:scheme_ withName:@"scheme"];
  
  if ([content_ length]) {
    [self addToArray:items objectDescriptionIfNonNil:content_ withName:@"content"];
  }

  return items;
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:nil];
  
  [self addToElement:element attributeValueIfNonNil:label_ withName:@"label"];
  [self addToElement:element attributeValueIfNonNil:scheme_ withName:@"scheme"];
  if ([content_ length]) {
    [element addStringValue:content_]; 
  }

  return element;
}

- (NSString *)label {
  return label_; 
}

- (void)setLabel:(NSString *)str {
  [label_ autorelease];
  label_ = [str copy];
}

- (NSString *)scheme {
  return scheme_; 
}

- (void)setScheme:(NSString *)str {
  [scheme_ autorelease];
  scheme_ = [str copy];
}

- (NSString *)stringValue {
  return content_;
}

- (void)setStringValue:(NSString *)str {
  [content_ autorelease];
  content_ = [str copy]; 
}

@end


