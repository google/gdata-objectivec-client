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
//  GDataWhen.m
//

#import "GDataWhen.h"


@implementation GDataWhen
// when element, as in
// <gd:when startTime="2005-06-06" endTime="2005-06-07" valueString="This weekend"/>
//
// http://code.google.com/apis/gdata/common-elements.html#gdWhen

+ (NSString *)extensionElementURI       { return kGDataNamespaceGData; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementLocalName { return @"when"; }

+ (GDataWhen *)whenWithStartTime:(GDataDateTime *)startTime
                         endTime:(GDataDateTime *)endTime {
  GDataWhen *obj = [[[GDataWhen alloc] init] autorelease];
  [obj setStartTime:startTime];
  [obj setEndTime:endTime];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setValue:[self stringForAttributeName:@"valueString"
                                    fromElement:element]];    
    [self setStartTime:[self dateTimeForAttributeName:@"startTime"
                                          fromElement:element]];
    [self setEndTime:[self dateTimeForAttributeName:@"endTime"
                                        fromElement:element]];
    
  }
  return self;
}

- (void)dealloc {
  [startTime_ release];
  [endTime_ release];
  [value_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataWhen* when = [super copyWithZone:zone];
  [when setStartTime:startTime_];
  [when setEndTime:endTime_];
  [when setValue:value_];
  return when;
}

- (BOOL)isEqual:(GDataWhen *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataWhen class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self startTime], [other startTime])
    && AreEqualOrBothNil([self endTime], [other endTime])
    && AreEqualOrBothNil([self value], [other value]); 
}

- (NSString *)description {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:startTime_ withName:@"start"];
  [self addToArray:items objectDescriptionIfNonNil:endTime_ withName:@"end"];
  [self addToArray:items objectDescriptionIfNonNil:value_ withName:@"value"];

  return [NSString stringWithFormat:@"%@ 0x%lX: {%@}",
    [self class], self, [items componentsJoinedByString:@" "]];
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"gd:when"];
  
  [self addToElement:element attributeValueIfNonNil:[[self startTime] RFC3339String] withName:@"startTime"];
  [self addToElement:element attributeValueIfNonNil:[[self endTime] RFC3339String]   withName:@"endTime"];

  [self addToElement:element attributeValueIfNonNil:[self value] withName:@"valueString"];
    
  return element;
}


- (GDataDateTime *)startTime {
  return startTime_;
}

- (void)setStartTime:(GDataDateTime *)cdate {
  [startTime_ autorelease];
  startTime_ = [cdate retain];
}

- (GDataDateTime *)endTime {
  return endTime_; 
}

- (void)setEndTime:(GDataDateTime *)cdate {
  [endTime_ autorelease];
  endTime_ = [cdate retain];
}

- (NSString *)value {
  return value_; 
}

- (void)setValue:(NSString *)str {
  [value_ autorelease];
  value_ = [str copy];
}

@end
