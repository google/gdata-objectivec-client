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
//  GDataRecurrence.m
//

#import "GDataRecurrence.h"

@implementation GDataRecurrence
// a gd:recurrence, as in
//
//  <gd:recurrence>
//  DTSTART;TZID=America/Los_Angeles:20060314T060000
//  DURATION:PT3600S ...
//  END:DAYLIGHT
//  END:VTIMEZONE
//  </gd:recurrence>
//
// http://code.google.com/apis/gdata/common-elements.html#gdRecurrence
//
// See RFC 2445: http://www.ietf.org/rfc/rfc2445.txt

+ (NSString *)extensionElementURI       { return kGDataNamespaceGData; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementLocalName { return @"recurrence"; }

+ (GDataRecurrence *)recurrenceWithString:(NSString *)str {
  GDataRecurrence* obj = [[[GDataRecurrence alloc] init] autorelease];
  [obj setStringValue:str];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setStringValue:[self stringValueFromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [value_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataRecurrence* newRecurrence = [super copyWithZone:zone];
  [newRecurrence setStringValue:[self stringValue]];
  return newRecurrence;
}

- (BOOL)isEqual:(GDataRecurrence *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataRecurrence class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self stringValue], [other stringValue]);
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:value_ withName:@"value"];
  
  return items;
}

- (NSXMLElement *)XMLElement {
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"gd:recurrence"];

  if ([[self stringValue] length]) {
    [element addStringValue:[self stringValue]];
  }
  
  return element;
}

- (NSString *)stringValue {
  return value_; 
}

- (void)setStringValue:(NSString *)str {
  [value_ autorelease];
  value_ = [str copy];
}
@end
