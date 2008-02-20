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
//  GDataRating.m
//

#define GDATARATING_DEFINE_GLOBALS 1
#import "GDataRating.h"

@implementation GDataRating
// rating, as in
//  <gd:rating rel="http://schemas.google.com/g/2005#price" value="5" min="1" max="5"/>
//
// http://code.google.com/apis/gdata/common-elements.html#gdRating

+ (NSString *)extensionElementURI       { return kGDataNamespaceGData; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementLocalName { return @"rating"; }

+ (GDataRating *)ratingWithValue:(int)value
                             max:(int)max
                             min:(int)min {
  GDataRating *obj = [[[GDataRating alloc] init] autorelease];
  [obj setValue:[NSNumber numberWithInt:value]];
  [obj setMax:[NSNumber numberWithInt:max]];
  [obj setMin:[NSNumber numberWithInt:min]];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setRel:[self stringForAttributeName:@"rel"
                                  fromElement:element]];
    [self setValue:[self intNumberForAttributeName:@"value"
                                       fromElement:element]];
    [self setMax:[self intNumberForAttributeName:@"max"
                                     fromElement:element]];
    [self setMin:[self intNumberForAttributeName:@"min"
                                     fromElement:element]];
    [self setAverage:[self doubleNumberForAttributeName:@"average"
                                         fromElement:element]];
    [self setNumberOfRaters:[self intNumberForAttributeName:@"numRaters"
                                                fromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [rel_ release];
  [value_ release];
  [max_ release];
  [min_ release];
  [average_ release];
  [numberOfRaters_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataRating* newObj = [super copyWithZone:zone];
  [newObj setRel:rel_];
  [newObj setValue:value_];
  [newObj setMax:max_];
  [newObj setMin:min_];
  [newObj setAverage:average_];
  [newObj setNumberOfRaters:numberOfRaters_];
  return newObj;
}

- (BOOL)isEqual:(GDataRating *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataRating class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self rel], [other rel])
    && AreEqualOrBothNil([self value], [other value])
    && AreEqualOrBothNil([self max], [other max])
    && AreEqualOrBothNil([self min], [other min])
    && AreEqualOrBothNil([self average], [other average])
    && AreEqualOrBothNil([self numberOfRaters], [other numberOfRaters]);
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:rel_ withName:@"rel"];
  [self addToArray:items objectDescriptionIfNonNil:value_ withName:@"value"];
  [self addToArray:items objectDescriptionIfNonNil:max_ withName:@"max"];
  [self addToArray:items objectDescriptionIfNonNil:min_ withName:@"min"];
  [self addToArray:items objectDescriptionIfNonNil:average_ withName:@"average"];
  [self addToArray:items objectDescriptionIfNonNil:numberOfRaters_ withName:@"numberOfRaters"];
  
  return items;
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"gd:rating"];
  
  [self addToElement:element attributeValueIfNonNil:[self rel] withName:@"rel"];
  [self addToElement:element attributeValueIfNonNil:[[self value] stringValue] withName:@"value"];
  [self addToElement:element attributeValueIfNonNil:[[self max] stringValue] withName:@"max"];
  [self addToElement:element attributeValueIfNonNil:[[self min] stringValue] withName:@"min"];
  [self addToElement:element attributeValueIfNonNil:[[self average] stringValue] withName:@"average"];
  [self addToElement:element attributeValueIfNonNil:[[self numberOfRaters] stringValue] withName:@"numRaters"];
  
  return element;
}

- (NSString *)rel {
  return rel_; 
}

- (void)setRel:(NSString *)str {
  [rel_ autorelease];
  rel_ = [str copy];
}

- (NSNumber *)value {
  return value_; 
}

- (void)setValue:(NSNumber *)num {
  [value_ autorelease];
  value_ = [num copy];
}

- (NSNumber *)max {
  return max_; 
}

- (void)setMax:(NSNumber *)num {
  [max_ autorelease];
  max_ = [num copy];
}

- (NSNumber *)min {
  return min_; 
}

- (void)setMin:(NSNumber *)num {
  [min_ autorelease];
  min_ = [num copy];
}

- (NSNumber *)average {
  return average_; 
}

- (void)setAverage:(NSNumber *)num {
  [average_ autorelease];
  average_ = [num copy];
}

- (NSNumber *)numberOfRaters {
  return numberOfRaters_; 
}

- (void)setNumberOfRaters:(NSNumber *)num {
  [numberOfRaters_ autorelease];
  numberOfRaters_ = [num copy];
}

@end

