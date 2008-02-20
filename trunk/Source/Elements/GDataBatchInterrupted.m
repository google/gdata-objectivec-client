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
//  GDataBatchInterrupted.m
//

#import "GDataBatchInterrupted.h"

@implementation GDataBatchInterrupted

// for batch Interrupteds, like
//  <batch:interrupted reason="reason" success="N" failures="N" parsed="N" />

+ (NSString *)extensionElementURI       { return kGDataNamespaceBatch; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceBatchPrefix; }
+ (NSString *)extensionElementLocalName { return @"interrupted"; }

+ (GDataBatchInterrupted *)batchInterrupted {
  GDataBatchInterrupted* obj = [[[GDataBatchInterrupted alloc] init] autorelease];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setReason:[self stringForAttributeName:@"reason" fromElement:element]];
    [self setSuccessCount:[self intNumberForAttributeName:@"success" fromElement:element]];
    [self setErrorCount:[self intNumberForAttributeName:@"failures" fromElement:element]];
    [self setTotalCount:[self intNumberForAttributeName:@"parsed" fromElement:element]];
    [self setContentType:[self stringForAttributeName:@"content-type" fromElement:element]];
    [self setStringValue:[self stringValueFromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [reason_ release];
  [successCount_ release];
  [errorCount_ release];
  [totalCount_ release];
  [contentType_ release];
  [content_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataBatchInterrupted* newObj = [super copyWithZone:zone];
  [newObj setReason:reason_];
  [newObj setSuccessCount:successCount_];
  [newObj setErrorCount:errorCount_];
  [newObj setTotalCount:totalCount_];
  [newObj setContentType:contentType_];
  [newObj setStringValue:content_];
  return newObj;
}

- (BOOL)isEqual:(GDataBatchInterrupted *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataBatchInterrupted class]]) return NO;

  return [super isEqual:other]
    && AreEqualOrBothNil([self reason], [other reason])
    && AreEqualOrBothNil([self successCount], [other successCount])
    && AreEqualOrBothNil([self errorCount], [other errorCount])
    && AreEqualOrBothNil([self totalCount], [other totalCount])
    && AreEqualOrBothNil([self contentType], [other contentType])
    && AreEqualOrBothNil([self stringValue], [other stringValue]);
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:reason_ withName:@"reason"];
  [self addToArray:items objectDescriptionIfNonNil:successCount_ withName:@"successes"];
  [self addToArray:items objectDescriptionIfNonNil:errorCount_ withName:@"errors"];
  [self addToArray:items objectDescriptionIfNonNil:totalCount_ withName:@"total"];
  [self addToArray:items objectDescriptionIfNonNil:contentType_ withName:@"contentType"];
  [self addToArray:items objectDescriptionIfNonNil:content_ withName:@"content"];
  
  return items;
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"batch:Interrupted"];
  
  [self addToElement:element attributeValueIfNonNil:[self reason] withName:@"reason"];
  [self addToElement:element attributeValueIfNonNil:[[self successCount] stringValue] withName:@"success"];
  [self addToElement:element attributeValueIfNonNil:[[self errorCount] stringValue] withName:@"failures"];
  [self addToElement:element attributeValueIfNonNil:[[self totalCount] stringValue] withName:@"parsed"];
  [self addToElement:element attributeValueIfNonNil:[self contentType] withName:@"content-type"];
  if ([[self stringValue] length]) {
    [element addStringValue:[self stringValue]]; 
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

- (NSNumber *)successCount {
  return successCount_; 
}

- (void)setSuccessCount:(NSNumber *)val {
  [successCount_ autorelease];
  successCount_ = [val retain];
}

- (NSNumber *)errorCount {
  return errorCount_; 
}

- (void)setErrorCount:(NSNumber *)val {
  [errorCount_ autorelease];
  errorCount_ = [val retain];
}

- (NSNumber *)totalCount {
  return totalCount_; 
}

- (void)setTotalCount:(NSNumber *)val {
  [totalCount_ autorelease];
  totalCount_ = [val retain];
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

