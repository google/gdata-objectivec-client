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
//  GDataEntryContent.m
//

#import "GDataEntryContent.h"

@implementation GDataEntryContent
// For content which may be text, like
//  <content type="text">Event title</title>
//
// or media content with a source URI specified,
//  <content src="http://lh.google.com/image/Car.jpg" type="image/jpeg"/>

+ (id)contentWithSourceURI:(NSString *)str type:(NSString *)type {
  
  GDataEntryContent *obj = [[[GDataEntryContent alloc] init] autorelease];
  [obj setSourceURI:str];
  [obj setType:type]; // type is part of the superclass
  return obj;
}

- (id)init {
  self = [super init];
  if (self) {
    [self setType:@"text"];
  }
  return self;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    
    [self setSourceURI:[self stringForAttributeName:@"src"
                                        fromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [src_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataEntryContent* newObj = [super copyWithZone:zone];
  [newObj setSourceURI:[self sourceURI]];
  return newObj;
}

- (BOOL)isEqual:(GDataEntryContent *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataEntryContent class]]) return NO;
  
  // note: type and other fields are part of the superclass, GDataTextConstruct
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self sourceURI], [other sourceURI]);
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:content_ withName:@""];
  [self addToArray:items objectDescriptionIfNonNil:lang_    withName:@"lang"];
  [self addToArray:items objectDescriptionIfNonNil:type_    withName:@"type"];
  [self addToArray:items objectDescriptionIfNonNil:src_     withName:@"src"];
  
  return items;
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [super XMLElement];

  [self addToElement:element attributeValueIfNonNil:[self sourceURI] withName:@"src"];
  
  return element;
}

- (NSString *)sourceURI {
  return src_; 
}

- (void)setSourceURI:(NSString *)str {
  [src_ autorelease];
  src_ = [str copy];
}

@end

