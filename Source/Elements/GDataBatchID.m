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
//  GDataBatchID.m
//

#import "GDataBatchID.h"

@implementation GDataBatchID

// For batchID, like:
//   <batch:id>item2</batch:id>

+ (NSString *)extensionElementURI       { return kGDataNamespaceBatch; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceBatchPrefix; }
+ (NSString *)extensionElementLocalName { return @"id"; }


+ (GDataBatchID *)batchIDWithString:(NSString *)str {
  GDataBatchID *obj = [[[GDataBatchID alloc] init] autorelease];
  [obj setStringValue:str];
  return obj;
}

- (id)init {
  self = [super init];
  if (self) {
  }
  return self;
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
  [idString_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataBatchID* newObj = [super copyWithZone:zone];
  [newObj setStringValue:[self stringValue]];
  return newObj;
}

- (BOOL)isEqual:(GDataBatchID *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataBatchID class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self stringValue], [other stringValue]);
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:idString_ withName:@"ID"];
  
  return items;
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"batch:id"];

  if ([[self stringValue] length]) {
    [element addStringValue:[self stringValue]];
  }
  
  return element;
}

- (NSString *)stringValue {
  return idString_; 
}

- (void)setStringValue:(NSString *)str {
  [idString_ autorelease];
  idString_ = [str copy];
}

@end

