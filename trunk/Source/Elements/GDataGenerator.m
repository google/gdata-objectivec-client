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
//  GDataGenerator.m
//

#import "GDataGenerator.h"

@implementation GDataGenerator
// Feed generator element, as in
//   <generator version='1.0' uri='http://www.google.com/calendar/'>CL2</generator>

+ (NSString *)extensionElementURI       { return kGDataNamespaceAtom; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAtomPrefix; }
+ (NSString *)extensionElementLocalName { return @"generator"; }

+ (GDataGenerator *)generatorWithName:(NSString *)name
                              version:(NSString *)version
                                  URI:(NSString *)uri {
  GDataGenerator *obj = [[[GDataGenerator alloc] init] autorelease];
  [obj setName:name];
  [obj setVersion:version];
  [obj setURI:uri];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setName:[self stringValueFromElement:element]];
    [self setVersion:[self stringForAttributeName:@"version"
                                      fromElement:element]];
    [self setURI:[self stringForAttributeName:@"uri"
                                  fromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [name_ release];
  [version_ release];
  [uri_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataGenerator* newGenerator = [super copyWithZone:zone];
  [newGenerator setName:name_];
  [newGenerator setVersion:version_];
  [newGenerator setURI:uri_];
  return newGenerator;
}

- (BOOL)isEqual:(GDataGenerator *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataGenerator class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self name], [other name])
    && AreEqualOrBothNil([self version], [other version])
    && AreEqualOrBothNil([self URI], [other URI]);
}

- (NSString *)description {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:name_     withName:@"name"];
  [self addToArray:items objectDescriptionIfNonNil:version_  withName:@"version"];
  [self addToArray:items objectDescriptionIfNonNil:uri_      withName:@"URI"];
  
  return [NSString stringWithFormat:@"%@ 0x%lX: {%@}",
    [self class], self, [items componentsJoinedByString:@" "]];
}

- (NSXMLElement *)XMLElement {

  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"generator"];
  
  if ([[self name] length]) {
    [element addStringValue:[self name]];
  }
  [self addToElement:element attributeValueIfNonNil:[self version]      withName:@"version"];
  [self addToElement:element attributeValueIfNonNil:[self URI]          withName:@"uri"];
  
  return element;
}

- (NSString *)name {
  return name_; 
}

- (void)setName:(NSString *)str {
  [name_ autorelease];
  name_ = [str copy];
}

- (NSString *)version {
  return version_; 
}

- (void)setVersion:(NSString *)str {
  [version_ autorelease];
  version_ = [str copy];
}

- (NSString *)URI {
  return uri_; 
}

- (void)setURI:(NSString *)str {
  [uri_ autorelease];
  uri_ = [str copy];
}

@end



