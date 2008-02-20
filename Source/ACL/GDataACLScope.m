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
//  GDataACLScope.m
//

#define GDATAACLSCOPE_DEFINE_GLOBALS 1
#import "GDataACLScope.h"

#import "GDataEntryACL.h"

@implementation GDataACLScope
// an element with type and value attributes, as in
//  <gAcl:scope type='user' value='user@gmail.com'></gAcl:scope>

+ (NSString *)extensionElementURI       { return kGDataNamespaceACL; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceACLPrefix; }
+ (NSString *)extensionElementLocalName { return @"scope"; }

+ (GDataACLScope *)scopeWithType:(NSString *)type value:(NSString *)value {
  GDataACLScope *obj = [[[self alloc] init] autorelease];
  [obj setType:type];
  [obj setValue:value];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setValue:[self stringForAttributeName:@"value"
                                    fromElement:element]];
    [self setType:[self stringForAttributeName:@"type"
                                   fromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [value_ release];
  [type_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataACLScope* newValue = [super copyWithZone:zone];
  [newValue setValue:value_];
  [newValue setType:type_];
  return newValue;
}

- (BOOL)isEqual:(GDataACLScope *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataACLScope class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self value], [other value])
    && AreEqualOrBothNil([self type], [other type]);
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:type_ withName:@"type"];
  [self addToArray:items objectDescriptionIfNonNil:value_ withName:@"value"];
  
  return items;
}

- (NSXMLElement *)XMLElement {
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"gAcl:scope"];
  
  [self addToElement:element attributeValueIfNonNil:[self value] withName:@"value"];
  [self addToElement:element attributeValueIfNonNil:[self type] withName:@"type"];
  
  return element;
}

- (NSString *)value {
  return value_; 
}

- (void)setValue:(NSString *)str {
  [value_ autorelease];
  value_ = [str copy];
}

- (NSString *)type {
  return type_; 
}

- (void)setType:(NSString *)str {
  [type_ autorelease];
  type_ = [str copy];
}

@end
