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

#import "GDataIM.h"

@implementation GDataIM
// IM element, as in
//   <gd:im protocol="sip" address="foo@bar.example.com"/ label="Fred">
//
// http://code.google.com/apis/gdata/common-elements.html#gdIm

+ (NSString *)extensionElementURI       { return kGDataNamespaceGData; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementLocalName { return @"im"; }

+ (GDataIM *)IMWithProtocol:(NSString *)protocol
                      label:(NSString *)label
                    address:(NSString *)address {
  GDataIM *obj = [[[GDataIM alloc] init] autorelease];
  [obj setProtocol:protocol];
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
    [self setAddress:[self stringForAttributeName:@"address"
                                      fromElement:element]];
    [self setProtocol:[self stringForAttributeName:@"protocol"
                                       fromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [label_ release];
  [address_ release];
  [protocol_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataIM* newObj = [super copyWithZone:zone];
  [newObj setLabel:label_];
  [newObj setAddress:address_];
  [newObj setProtocol:protocol_];
  return newObj;
}

- (BOOL)isEqual:(GDataIM *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataIM class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self label], [other label])
    && AreEqualOrBothNil([self address], [other address])
    && AreEqualOrBothNil([self protocol], [other protocol]);
}

- (NSString *)description {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:label_ withName:@"label"];
  [self addToArray:items objectDescriptionIfNonNil:address_ withName:@"address"];
  [self addToArray:items objectDescriptionIfNonNil:address_ withName:@"protocol"];
  
  return [NSString stringWithFormat:@"%@ 0x%lX: {%@}",
    [self class], self, [items componentsJoinedByString:@" "]];
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"gd:im"];
  
  [self addToElement:element attributeValueIfNonNil:[self label] withName:@"label"];
  [self addToElement:element attributeValueIfNonNil:[self address] withName:@"address"];
  [self addToElement:element attributeValueIfNonNil:[self protocol] withName:@"protocol"];
  
  return element;
}

- (NSString *)label {
  return label_; 
}

- (void)setLabel:(NSString *)str {
  [label_ autorelease];
  label_ = [str copy];
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

@end


