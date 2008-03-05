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
//  GDataIM.m
//

#define GDATAIM_DEFINE_GLOBALS 1
#import "GDataIM.h"

@implementation GDataIM
// IM element, as in
//   <gd:im protocol="http://schemas.google.com/g/2005#MSN" 
//      address="foo@bar.example.com" label="Alternate"
//      rel="http://schemas.google.com/g/2005#other" >
//
// http://code.google.com/apis/gdata/common-elements.html#gdIm

+ (NSString *)extensionElementURI       { return kGDataNamespaceGData; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementLocalName { return @"im"; }

+ (GDataIM *)IMWithProtocol:(NSString *)protocol
                        rel:(NSString *)rel
                      label:(NSString *)label
                    address:(NSString *)address {
  
  GDataIM *obj = [[[GDataIM alloc] init] autorelease];
  [obj setProtocol:protocol];
  [obj setRel:rel];
  [obj setLabel:label];
  [obj setAddress:address];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setLabel:[self stringForAttributeName:@"label"
                                    fromElement:element]];
    [self setRel:[self stringForAttributeName:@"rel"
                                  fromElement:element]];
    [self setAddress:[self stringForAttributeName:@"address"
                                      fromElement:element]];
    [self setProtocol:[self stringForAttributeName:@"protocol"
                                       fromElement:element]];
    [self setIsPrimary:[self boolForAttributeName:@"primary"
                                      fromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [label_ release];
  [rel_ release];
  [address_ release];
  [protocol_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataIM* newObj = [super copyWithZone:zone];
  [newObj setLabel:[self label]];
  [newObj setRel:[self rel]];
  [newObj setAddress:[self address]];
  [newObj setProtocol:[self protocol]];
  [newObj setIsPrimary:[self isPrimary]];
  return newObj;
}

- (BOOL)isEqual:(GDataIM *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataIM class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self label], [other label])
    && AreEqualOrBothNil([self rel], [other rel])
    && AreEqualOrBothNil([self address], [other address])
    && AreEqualOrBothNil([self protocol], [other protocol])
    && AreBoolsEqual([self isPrimary], [other isPrimary]);
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:address_ withName:@"address"];
  [self addToArray:items objectDescriptionIfNonNil:protocol_ withName:@"protocol"];
  [self addToArray:items objectDescriptionIfNonNil:label_ withName:@"label"];
  [self addToArray:items objectDescriptionIfNonNil:rel_ withName:@"rel"];
 
  if (isPrimary_) [items addObject:@"primary"];

  return items;
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:nil];
  
  [self addToElement:element attributeValueIfNonNil:[self label] withName:@"label"];
  [self addToElement:element attributeValueIfNonNil:[self rel] withName:@"rel"];
  [self addToElement:element attributeValueIfNonNil:[self address] withName:@"address"];
  [self addToElement:element attributeValueIfNonNil:[self protocol] withName:@"protocol"];
  
  if ([self isPrimary]) {
    [self addToElement:element attributeValueIfNonNil:@"true" withName:@"primary"]; 
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

- (NSString *)rel {
  return rel_; 
}

- (void)setRel:(NSString *)str {
  [rel_ autorelease];
  rel_ = [str copy];
}

- (NSString *)address {
  return address_; 
}

- (void)setAddress:(NSString *)str {
  [address_ autorelease];
  address_ = [str copy];
}

- (NSString *)protocol {
  return protocol_; 
}

- (void)setProtocol:(NSString *)str {
  [protocol_ autorelease];
  protocol_ = [str copy];
}

- (BOOL)isPrimary {
  return isPrimary_; 
}

- (void)setIsPrimary:(BOOL)flag {
  isPrimary_ = flag;
}
@end


