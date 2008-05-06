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
//  GDataPostalAddress.m
//

#import "GDataPostalAddress.h"

@implementation GDataPostalAddress
// postal address, as in
//  <gd:postalAddress>
//    500 West 45th Street
//    New York, NY 10036
//  </gd:postalAddress>
//
// http://code.google.com/apis/gdata/common-elements.html#gdPostalAddress

+ (NSString *)extensionElementURI       { return kGDataNamespaceGData; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementLocalName { return @"postalAddress"; }

+ (GDataPostalAddress *)postalAddressWithString:(NSString *)str {
  GDataPostalAddress* obj = [[[GDataPostalAddress alloc] init] autorelease];
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
    
    [self setStringValue:[self stringValueFromElement:element]]; // ? should we strip leading/trailing whitespace? strip per line or just for the whole block?
    
    [self setRel:[self stringForAttributeName:@"rel"
                                  fromElement:element]];
    [self setIsPrimary:[self boolForAttributeName:@"primary"
                                      fromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [label_ release];
  [value_ release];
  [rel_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataPostalAddress* newObj = [super copyWithZone:zone];
  [newObj setLabel:[self label]];
  [newObj setStringValue:[self stringValue]];
  [newObj setRel:[self rel]];
  [newObj setIsPrimary:[self isPrimary]];
  return newObj;
}

- (BOOL)isEqual:(GDataPostalAddress *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataPostalAddress class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self label], [other label])
    && AreEqualOrBothNil([self stringValue], [other stringValue])
    && AreEqualOrBothNil([self rel], [other rel]);
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:label_ withName:@"label"];
  [self addToArray:items objectDescriptionIfNonNil:value_ withName:@"value"];
  [self addToArray:items objectDescriptionIfNonNil:rel_ withName:@"rel"];
  
  if (isPrimary_) [items addObject:@"primary"];
  
  return items;
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"gd:postalAddress"];
  
  [self addToElement:element attributeValueIfNonNil:[self label] withName:@"label"];
  [self addToElement:element attributeValueIfNonNil:[self rel] withName:@"rel"];
  
  if ([self isPrimary]) {
    [self addToElement:element attributeValueIfNonNil:@"true" withName:@"primary"]; 
  }
  
  if ([self stringValue]) {
    [element addStringValue:[self stringValue]];
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

- (NSString *)stringValue {
  return value_; 
}

- (void)setStringValue:(NSString *)str {
  [value_ autorelease];
  value_ = [str copy];
}

- (NSString *)rel {
  return rel_; 
}

- (void)setRel:(NSString *)str {
  [rel_ autorelease];
  rel_ = [str copy];
}

- (BOOL)isPrimary {
  return isPrimary_; 
}

- (void)setIsPrimary:(BOOL)flag {
  isPrimary_ = flag;
}
@end

