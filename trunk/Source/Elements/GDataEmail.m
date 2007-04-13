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
//  GDataEmail.m
//

#import "GDataEmail.h"

@implementation GDataEmail
// email element
// <gd:email label="Personal" address="fubar@gmail.com"/>
//
// http://code.google.com/apis/gdata/common-elements.html#gdEmail

+ (NSString *)extensionElementURI       { return kGDataNamespaceGData; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementLocalName { return @"email"; }

+ (GDataEmail *)emailWithLabel:(NSString *)label
                       address:(NSString *)address {
  GDataEmail *obj = [[[GDataEmail alloc] init] autorelease];
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
  }
  return self;
}

- (void)dealloc {
  [label_ release];
  [address_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataEmail* newObj = [super copyWithZone:zone];
  [newObj setLabel:label_];
  [newObj setAddress:address_];
  return newObj; 
}

- (BOOL)isEqual:(GDataEmail *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataEmail class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self label], [other label])
    && AreEqualOrBothNil([self address], [other address]);
}

- (NSString *)description {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:label_ withName:@"label"];
  [self addToArray:items objectDescriptionIfNonNil:address_ withName:@"address"];
  
  return [NSString stringWithFormat:@"%@ 0x%lX: {%@}",
    [self class], self, [items componentsJoinedByString:@" "]];
}

- (NSXMLElement *)XMLElement {

  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"gd:email"];
  
  [self addToElement:element attributeValueIfNonNil:[self label] withName:@"label"];
  [self addToElement:element attributeValueIfNonNil:[self address] withName:@"address"];
    
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

@end


