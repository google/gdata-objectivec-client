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
//  GDataBatchStatus.m
//


#import "GDataBatchStatus.h"

@implementation GDataBatchStatus
// a batch response status
//  <batch:status  code="404"
//    reason="Bad request"
//    content-type="application/xml">
//    <errors>
//      <error type="request" reason="Cannot find item"/>
//    </errors>
//  </batch:status>

+ (NSString *)extensionElementURI       { return kGDataNamespaceBatch; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceBatchPrefix; }
+ (NSString *)extensionElementLocalName { return @"status"; }

+ (GDataBatchStatus *)batchStatusWithCode:(int)code
                                   reason:(NSString *)reason {
  GDataBatchStatus* obj = [[[GDataBatchStatus alloc] init] autorelease];
  [obj setReason:reason];
  [obj setCode:[NSNumber numberWithInt:code]];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setCode:[self intNumberForAttributeName:@"code"
                                      fromElement:element]];
    [self setReason:[self stringForAttributeName:@"reason"
                                     fromElement:element]];
    [self setContentType:[self stringForAttributeName:@"content-type"
                                          fromElement:element]];
    [self setStringValue:[self stringValueFromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [code_ release];
  [reason_ release];
  [contentType_ release];
  [content_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataBatchStatus* newObj = [super copyWithZone:zone];
  [newObj setCode:code_];
  [newObj setReason:reason_];
  [newObj setContentType:contentType_];
  [newObj setStringValue:content_];
  return newObj;
}

- (BOOL)isEqual:(GDataBatchStatus *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataBatchStatus class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self reason], [other reason])
    && AreEqualOrBothNil([self code], [other code])
    && AreEqualOrBothNil([self contentType], [other contentType])
    && AreEqualOrBothNil([self stringValue], [other stringValue]);
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:[code_ stringValue] withName:@"code"];
  [self addToArray:items objectDescriptionIfNonNil:reason_ withName:@"reason"];
  [self addToArray:items objectDescriptionIfNonNil:contentType_ withName:@"contentType"];
  
  if ([content_ length]) {
    [self addToArray:items objectDescriptionIfNonNil:content_ withName:@"content"];
  }

  return items;
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"batch:status"];
  
  [self addToElement:element attributeValueIfNonNil:[code_ stringValue] withName:@"code"];
  [self addToElement:element attributeValueIfNonNil:reason_ withName:@"reason"];
  [self addToElement:element attributeValueIfNonNil:contentType_ withName:@"content-type"];
  if ([content_ length]) {
    [element addStringValue:content_]; 
  }

  return element;
}

- (NSString *)reason {
  return reason_; 
}

- (void)setReason:(NSString *)str {
  [reason_ autorelease];
  reason_ = [str copy];
}

- (NSNumber *)code {
  return code_; 
}

- (void)setCode:(NSNumber *)num {
  [code_ autorelease];
  code_ = [num retain];
}

- (NSString *)contentType {
  return contentType_; 
}

- (void)setContentType:(NSString *)str {
  [contentType_ autorelease];
  contentType_ = [str copy];
}

- (NSString *)stringValue {
  return content_;
}

- (void)setStringValue:(NSString *)str {
  [content_ autorelease];
  content_ = [str copy]; 
}

@end


