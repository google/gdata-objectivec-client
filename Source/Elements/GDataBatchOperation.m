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
//  GDataBatchOperation.m
//

#define GDATABATCH_DEFINE_GLOBALS 1
#import "GDataBatchOperation.h"

@implementation GDataBatchOperation
// for batch operations, like
//  <batch:operation type="insert"/>

+ (NSString *)extensionElementURI       { return kGDataNamespaceBatch; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceBatchPrefix; }
+ (NSString *)extensionElementLocalName { return @"operation"; }

+ (GDataBatchOperation *)batchOperationWithType:(NSString *)type {
  GDataBatchOperation* obj = [[[GDataBatchOperation alloc] init] autorelease];
  [obj setType:type];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setType:[self stringForAttributeName:@"type" fromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [type_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataBatchOperation* newObj = [super copyWithZone:zone];
  [newObj setType:[self type]];
  return newObj;
}

- (BOOL)isEqual:(GDataBatchOperation *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataBatchOperation class]]) return NO;

  return [super isEqual:other]
    && AreEqualOrBothNil([self type], [other type]);
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:type_ withName:@"type"];
  
  return items;
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"batch:operation"];
  
  [self addToElement:element attributeValueIfNonNil:[self type] withName:@"type"];
  
  return element;
}

- (NSString *)type {
  return type_; 
}

- (void)setType:(NSString *)str {
  [type_ autorelease];
  type_ = [str copy];
}

@end

