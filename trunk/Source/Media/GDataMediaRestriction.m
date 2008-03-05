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
//  GDataMediaRestriction.m
//


#import "GDataMediaRestriction.h"
#import "GDataMediaGroup.h"

@implementation GDataMediaRestriction
// like <media:restriction relationship="allow" type="country">au us</media:restriction>
//
// http://search.yahoo.com/mrss

+ (NSString *)extensionElementURI       { return kGDataNamespaceMedia; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceMediaPrefix; }
+ (NSString *)extensionElementLocalName { return @"restriction"; }

+ (GDataMediaRestriction *)mediaRestrictionWithString:(NSString *)str
                                         relationship:(NSString *)rel
                                                 type:(NSString *)type {
  GDataMediaRestriction* obj = [[[GDataMediaRestriction alloc] init] autorelease];
  [obj setStringValue:str];
  [obj setRelationship:rel];
  [obj setType:type];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setRelationship:[self stringForAttributeName:@"relationship"
                                           fromElement:element]];
    [self setType:[self stringForAttributeName:@"type"
                                   fromElement:element]];
    [self setStringValue:[self stringValueFromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [relationship_ release];
  [type_ release];
  [content_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataMediaRestriction* newObj = [super copyWithZone:zone];
  [newObj setRelationship:[self relationship]];
  [newObj setType:[self type]];
  [newObj setStringValue:[self stringValue]];
  return newObj;
}

- (BOOL)isEqual:(GDataMediaRestriction *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataMediaRestriction class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self relationship], [other relationship])
    && AreEqualOrBothNil([self type], [other type])
    && AreEqualOrBothNil([self stringValue], [other stringValue]);
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:relationship_ withName:@"relationship"];
  [self addToArray:items objectDescriptionIfNonNil:type_ withName:@"type"];
  
  if ([content_ length]) {
    [self addToArray:items objectDescriptionIfNonNil:content_ withName:@"content"];
  }

  return items;
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"media:restriction"];
  
  [self addToElement:element attributeValueIfNonNil:relationship_ withName:@"relationship"];
  [self addToElement:element attributeValueIfNonNil:type_ withName:@"type"];
  if ([content_ length]) {
    [element addStringValue:content_]; 
  }

  return element;
}

- (NSString *)relationship {
  return relationship_; 
}

- (void)setRelationship:(NSString *)str {
  [relationship_ autorelease];
  relationship_ = [str copy];
}

- (NSString *)type {
  return type_; 
}

- (void)setType:(NSString *)str {
  [type_ autorelease];
  type_ = [str copy];
}

- (NSString *)stringValue {
  return content_;
}

- (void)setStringValue:(NSString *)str {
  [content_ autorelease];
  content_ = [str copy]; 
}

@end


