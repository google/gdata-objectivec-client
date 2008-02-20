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
//  GDataPhoneNumber.m
//

#define GDATAPHONENUMBER_DEFINE_GLOBALS 1
#import "GDataPhoneNumber.h"

@implementation GDataPhoneNumber
// phone number, as in 
//  <gd:phoneNumber rel="http://schemas.google.com/g/2005#work" uri="tel:+1-425-555-8080;ext=52585">
//    (425) 555-8080 ext. 52585
//  </gd:phoneNumber>
//
// http://code.google.com/apis/gdata/common-elements.html#gdPhoneNumber

+ (NSString *)extensionElementURI       { return kGDataNamespaceGData; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementLocalName { return @"phoneNumber"; }

+ (GDataPhoneNumber *)phoneNumberWithString:(NSString *)str {
  GDataPhoneNumber *obj = [[[GDataPhoneNumber alloc] init] autorelease];
  [obj setStringValue:str];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setRel:[self stringForAttributeName:@"rel"
                                  fromElement:element]];
    [self setLabel:[self stringForAttributeName:@"label"
                                    fromElement:element]];
    [self setURI:[self stringForAttributeName:@"uri"
                                  fromElement:element]];
    [self setIsPrimary:[self boolForAttributeName:@"primary"
                                      fromElement:element]];
    
    [self setStringValue:[self stringValueFromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [rel_ release];
  [label_ release];
  [uri_ release];
  [phoneNumber_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataPhoneNumber* newObj = [super copyWithZone:zone];
  [newObj setLabel:label_];
  [newObj setURI:uri_];
  [newObj setRel:rel_];
  [newObj setStringValue:phoneNumber_];
  [newObj setIsPrimary:isPrimary_];
  return newObj;
}

- (BOOL)isEqual:(GDataPhoneNumber *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataPhoneNumber class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self label], [other label])
    && AreEqualOrBothNil([self rel], [other rel])
    && AreEqualOrBothNil([self URI], [other URI])
    && AreEqualOrBothNil([self stringValue], [other stringValue])
    && AreBoolsEqual([self isPrimary], [other isPrimary]);
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:rel_ withName:@"rel"];
  [self addToArray:items objectDescriptionIfNonNil:label_ withName:@"label"];
  [self addToArray:items objectDescriptionIfNonNil:uri_ withName:@"uri"];
  [self addToArray:items objectDescriptionIfNonNil:phoneNumber_ withName:@"phoneNumber"];
  
  if (isPrimary_) [items addObject:@"primary"];
  
  return items;
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"gd:phoneNumber"];
  
  [self addToElement:element attributeValueIfNonNil:[self rel] withName:@"rel"];
  [self addToElement:element attributeValueIfNonNil:[self label] withName:@"label"];
  [self addToElement:element attributeValueIfNonNil:[self URI] withName:@"uri"];
  
  if ([self isPrimary]) {
    [self addToElement:element attributeValueIfNonNil:@"true" withName:@"primary"]; 
  }

  if ([self stringValue]) {
    [element addStringValue:[self stringValue]];
  }
  
  return element;
}

- (NSString *)rel {
  return rel_; 
}

- (void)setRel:(NSString *)str {
  [rel_ autorelease];
  rel_ = [str copy];
}

- (NSString *)label {
  return label_; 
}

- (void)setLabel:(NSString *)str {
  [label_ autorelease];
  label_ = [str copy];
}

- (NSString *)URI {
  return uri_; 
}

- (void)setURI:(NSString *)str {
  [uri_ autorelease];
  uri_ = [str copy];
}

- (NSString *)stringValue {
  return phoneNumber_; 
}

- (void)setStringValue:(NSString *)str {
  [phoneNumber_ autorelease];
  phoneNumber_ = [str copy];
}

- (BOOL)isPrimary {
  return isPrimary_; 
}

- (void)setIsPrimary:(BOOL)flag {
  isPrimary_ = flag;
}
@end
