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
//  GDataACLRole.m
//

#define GDATAACLROLE_DEFINE_GLOBALS 1
#import "GDataACLRole.h"

#import "GDataEntryACL.h"

@implementation GDataACLRole
// an element with type and value attributes, as in
//  <gAcl:role type='user' value='user@gmail.com'></gAcl:role>

+ (NSString *)extensionElementURI       { return kGDataNamespaceACL; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceACLPrefix; }
+ (NSString *)extensionElementLocalName { return @"role"; }

+ (GDataACLRole *)roleWithValue:(NSString *)value {
  GDataACLRole *obj = [[[self alloc] init] autorelease];
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
  }
  return self;
}

- (void)dealloc {
  [value_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataACLRole* newValue = [super copyWithZone:zone];
  [newValue setValue:value_];
  return newValue;
}

- (BOOL)isEqual:(GDataACLRole *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataACLRole class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self value], [other value]);
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:value_ withName:@"value"];
  
  return items;
}

- (NSXMLElement *)XMLElement {
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"gAcl:role"];
  
  [self addToElement:element attributeValueIfNonNil:[self value] withName:@"value"];
  
  return element;
}

- (NSString *)value {
  return value_; 
}

- (void)setValue:(NSString *)str {
  [value_ autorelease];
  value_ = [str copy];
}

@end
