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
//  GDataPerson.m
//

#import "GDataPerson.h"

@implementation GDataPerson
// a person, as in
// <author>
//   <name>Greg Robbins</name>
//   <email>test@coldnose.net</email>
// </author>

+ (GDataPerson *)personWithName:(NSString *)name email:(NSString *)email {
  GDataPerson* obj = [[[GDataPerson alloc] init] autorelease];
  [obj setName:name];
  [obj setEmail:email];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setNameLang:[self stringForAttributeName:@"xml:lang"
                                       fromElement:element]];
    
    NSXMLElement *child = [self childWithQualifiedName:@"name"
                                          namespaceURI:kGDataNamespaceAtom
                                           fromElement:element];
    [self setName:[self stringValueFromElement:child]];
    
    child = [self childWithQualifiedName:@"uri"
                            namespaceURI:kGDataNamespaceAtom
                             fromElement:element];
    [self setURI:[self stringValueFromElement:child]];
    
    element = [self childWithQualifiedName:@"email"
                              namespaceURI:kGDataNamespaceAtom
                               fromElement:element];
    [self setEmail:[self stringValueFromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [name_ release];
  [nameLang_ release];
  [uri_ release];
  [email_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataPerson* newPerson = [super copyWithZone:zone];
  [newPerson setName:name_];
  [newPerson setNameLang:nameLang_];
  [newPerson setURI:uri_];
  [newPerson setEmail:email_];
  return newPerson;
}

- (BOOL)isEqual:(GDataPerson *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataPerson class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self name], [other name])
    && AreEqualOrBothNil([self nameLang], [other nameLang])
    && AreEqualOrBothNil([self URI], [other URI])
    && AreEqualOrBothNil([self email], [other email]);
}

- (NSString *)description {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:name_ withName:@"name"];
  [self addToArray:items objectDescriptionIfNonNil:nameLang_ withName:@"nameLang"];
  [self addToArray:items objectDescriptionIfNonNil:uri_ withName:@"URI"];
  [self addToArray:items objectDescriptionIfNonNil:email_ withName:@"email"];

  return [NSString stringWithFormat:@"%@ 0x%lX: {%@}",
    [self class], self, [items componentsJoinedByString:@" "]];
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"GDataPerson"];  // author typically; is this ever "person"?
  
  [self addToElement:element childWithStringValueIfNonEmpty:[self name]     withName:@"name"];
  [self addToElement:element childWithStringValueIfNonEmpty:[self URI]      withName:@"uri"];
  [self addToElement:element childWithStringValueIfNonEmpty:[self email]    withName:@"email"];

  [self addToElement:element attributeValueIfNonNil:nameLang_ withName:@"xml:lang"];

  return element;
}

- (NSString *)name {
  return name_;
}

- (void)setName:(NSString *)str {
  [name_ autorelease];
  name_ = [str copy];
}

- (NSString *)nameLang {
  return nameLang_;
}

- (void)setNameLang:(NSString *)str {
  [nameLang_ autorelease];
  nameLang_ = [str copy];
}

- (NSString *)URI {
  return uri_;
}

- (void)setURI:(NSString *)str {
  [uri_ autorelease];
  uri_ = [str copy];
}

- (NSString *)email {
  return email_;
}

- (void)setEmail:(NSString *)str {
  [email_ autorelease];
  email_ = [str copy];
}
@end

