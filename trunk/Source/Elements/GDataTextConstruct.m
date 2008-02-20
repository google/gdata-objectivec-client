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
//  GDataTextConstruct.m
//

#import "GDataTextConstruct.h"

@implementation GDataTextConstruct
// For typed text, like: <title type="text">Event title</title>

+ (id)textConstructWithString:(NSString *)str {
  GDataTextConstruct *obj = [[[self alloc] init] autorelease];
  [obj setStringValue:str];
  return obj;
}

- (id)init {
  self = [super init];
  if (self) {
    // RFC4287 Sec 3.1 says that omitted type attributes are assumed to be
    // "text", so we don't need to explicitly set it
    // [self setType:@"text"];
  }
  return self;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    
    [self setLang:[self stringForAttributeName:@"xml:lang"
                                   fromElement:element]];
    [self setType:[self stringForAttributeName:@"type"
                                   fromElement:element]];
    [self setStringValue:[self stringValueFromElement:element]]; // TODO: handle according to the type
  }
  return self;
}

- (void)dealloc {
  [content_ release];
  [lang_ release];
  [type_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataTextConstruct* newText = [super copyWithZone:zone];
  [newText setStringValue:content_];
  [newText setLang:lang_];
  [newText setType:type_];
  return newText;
}

- (BOOL)isEqual:(GDataTextConstruct *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataTextConstruct class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self stringValue], [other stringValue])
    && AreEqualOrBothNil([self lang], [other lang])
    
    // missing type attribute is equal to "text" per RFC 4287 3.1.1
    && (AreEqualOrBothNil([self type], [other type])
        || ([self type] == nil && [[other type] isEqual:@"text"])
        || ([other type] == nil && [[self type] isEqual:@"text"]));
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:content_ withName:@"text"];
  [self addToArray:items objectDescriptionIfNonNil:lang_    withName:@"lang"];
  [self addToArray:items objectDescriptionIfNonNil:type_    withName:@"type"];
  
  return items;
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:nil];

  if ([[self stringValue] length]) {
    [element addStringValue:[self stringValue]];
  }
  [self addToElement:element attributeValueIfNonNil:[self lang] withName:@"xml:lang"];
  [self addToElement:element attributeValueIfNonNil:[self type] withName:@"type"];
  
  return element;
}

- (NSString *)stringValue {
  return content_; 
}

- (void)setStringValue:(NSString *)str {
  [content_ autorelease];
  content_ = [str copy];
}

- (NSString *)lang {
  return lang_; 
}

- (void)setLang:(NSString *)str {
  [lang_ autorelease];
  lang_ = [str copy];
}

- (NSString *)type {
  return type_; 
}

- (void)setType:(NSString *)str {
  [type_ autorelease];
  type_ = [str copy];
}

@end

