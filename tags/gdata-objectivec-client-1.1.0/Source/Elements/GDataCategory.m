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
//  GDataCategory.m
//

#import "GDataCategory.h"

@implementation GDataCategory
// for categories, like
//  <category scheme="http://schemas.google.com/g/2005#kind"
//        term="http://schemas.google.com/g/2005#event"/>

+ (NSString *)extensionElementURI       { return kGDataNamespaceAtom; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAtomPrefix; }
+ (NSString *)extensionElementLocalName { return @"category"; }

+ (GDataCategory *)categoryWithScheme:(NSString *)scheme
                                 term:(NSString *)term {
  GDataCategory* obj = [[[GDataCategory alloc] init] autorelease];
  [obj setScheme:scheme];
  [obj setTerm:term];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setScheme:[self stringForAttributeName:@"scheme" fromElement:element]];
    [self setTerm:[self stringForAttributeName:@"term" fromElement:element]];
    [self setLabel:[self stringForAttributeName:@"label" fromElement:element]];
    [self setLabelLang:[self stringForAttributeName:@"xml:lang" fromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [scheme_ release];
  [term_ release];
  [label_ release];
  [labelLang_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataCategory* newCategory = [super copyWithZone:zone];
  [newCategory setScheme:scheme_];
  [newCategory setTerm:term_];
  [newCategory setLabel:label_];
  [newCategory setLabelLang:labelLang_];
  return newCategory;
}

- (BOOL)isEqual:(GDataCategory *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataCategory class]]) return NO;

  return [super isEqual:other]
    && AreEqualOrBothNil([self scheme], [other scheme])
    && AreEqualOrBothNil([self term], [other term]);
  // excluding label and labelLang
}

- (NSString *)description {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:scheme_    withName:@"scheme"];
  [self addToArray:items objectDescriptionIfNonNil:term_      withName:@"term"];
  [self addToArray:items objectDescriptionIfNonNil:label_     withName:@"label"];
  [self addToArray:items objectDescriptionIfNonNil:labelLang_ withName:@"labelLang"];
  
  return [NSString stringWithFormat:@"%@ 0x%lX: {%@}",
    [self class], self, [items componentsJoinedByString:@" "]];
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"category"];
  
  [self addToElement:element attributeValueIfNonNil:[self scheme]    withName:@"scheme"];
  [self addToElement:element attributeValueIfNonNil:[self term]      withName:@"term"];
  [self addToElement:element attributeValueIfNonNil:[self label]     withName:@"label"];
  [self addToElement:element attributeValueIfNonNil:[self labelLang] withName:@"xml:lang"];
  
  return element;
}

// should we override hash function like Java does?

- (NSString *)scheme {
  return scheme_; 
}

- (void)setScheme:(NSString *)str {
  [scheme_ autorelease];
  scheme_ = [str copy];
}

- (NSString *)term {
  return term_; 
}

- (void)setTerm:(NSString *)str {
  [term_ autorelease];
  term_ = [str copy];
}

- (void)setLabel:(NSString *)str {
  [label_ autorelease];
  label_ = [str copy];
}

- (NSString *)label {
  return label_; 
}

- (void)setLabelLang:(NSString *)str {
  [labelLang_ autorelease];
  labelLang_ = [str copy];
}

- (NSString *)labelLang {
  return labelLang_; 
}
@end

