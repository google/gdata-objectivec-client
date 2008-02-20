/* Copyright (c) 2008 Google Inc.
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
//  GDataMediaRating.m
//


#import "GDataMediaRating.h"
#import "GDataMediaGroup.h"

@implementation GDataMediaRating
// like  <media:rating scheme="urn:simple">adult</media:rating>
// http://search.yahoo.com/mrss

+ (NSString *)extensionElementURI       { return kGDataNamespaceMedia; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceMediaPrefix; }
+ (NSString *)extensionElementLocalName { return @"rating"; }

+ (GDataMediaRating *)mediaRatingWithString:(NSString *)str {
  GDataMediaRating* obj = [[[GDataMediaRating alloc] init] autorelease];
  [obj setStringValue:str];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setScheme:[self stringForAttributeName:@"scheme"
                                     fromElement:element]];
    [self setStringValue:[self stringValueFromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [scheme_ release];
  [content_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataMediaRating* newObj = [super copyWithZone:zone];
  [newObj setScheme:scheme_];
  [newObj setStringValue:content_];
  return newObj;
}

- (BOOL)isEqual:(GDataMediaRating *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataMediaRating class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self scheme], [other scheme])
    && AreEqualOrBothNil([self stringValue], [other stringValue]);
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:scheme_ withName:@"scheme"];
  
  if ([content_ length]) {
    [self addToArray:items objectDescriptionIfNonNil:content_ withName:@"content"];
  }

  return items;
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:nil];
  
  [self addToElement:element attributeValueIfNonNil:scheme_ withName:@"scheme"];
  if ([content_ length]) {
    [element addStringValue:content_]; 
  }

  return element;
}

- (NSString *)scheme {
  return scheme_; 
}

- (void)setScheme:(NSString *)str {
  [scheme_ autorelease];
  scheme_ = [str copy];
}

- (NSString *)stringValue {
  return content_;
}

- (void)setStringValue:(NSString *)str {
  [content_ autorelease];
  content_ = [str copy]; 
}

@end


