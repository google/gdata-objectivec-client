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
//  GDataCodeSearchPackage.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CODESEARCH_SERVICE

#import "GDataCodeSearchPackage.h"
#import "GDataEntryCodeSearch.h"

@implementation GDataCodeSearchPackage 

// For code search packages, like
//
//  <gcs:package name="http://www.w3.org/Library/Distribution/w3c-libwww-5.4.0.zip"
//    uri="http://www.w3.org/Library/Distribution/w3c-libwww-5.4.0.zip"/>
//
// See http://code.google.com/apis/codesearch/reference.html

+ (NSString *)extensionElementURI       { return kGDataNamespaceCodeSearch; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceCodeSearchPrefix; }
+ (NSString *)extensionElementLocalName { return @"package"; }

+ (id)packageWithName:(NSString *)name
                  URI:(NSString *)uri {

  GDataCodeSearchPackage *obj = [[[GDataCodeSearchPackage alloc] init] autorelease];
  [obj setName:name];
  [obj setURI:uri];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setName:[self stringForAttributeName:@"name" 
                                   fromElement:element]];
    [self setURI:[self stringForAttributeName:@"uri" 
                                  fromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [name_ release];
  [uri_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataCodeSearchPackage* newObj = [super copyWithZone:zone];
  [newObj setName:[self name]];
  [newObj setURI:[self URI]];
  return newObj;
}

- (BOOL)isEqual:(GDataCodeSearchPackage *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataCodeSearchPackage class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self name], [other name])
    && AreEqualOrBothNil([self URI], [other URI]);
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:name_ withName:@"name"];
  [self addToArray:items objectDescriptionIfNonNil:uri_  withName:@"URI"];
  
  return items;
}
#endif

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:nil];
  
  [self addToElement:element attributeValueIfNonNil:[self name] withName:@"name"];
  [self addToElement:element attributeValueIfNonNil:[self URI] withName:@"uri"];
  
  return element;
}

- (NSString *)name {
  return name_; 
}

- (void)setName:(NSString *)str {
  [name_ autorelease];
  name_ = [str copy];
}

- (NSString *)URI {
  return uri_; 
}

- (void)setURI:(NSString *)str {
  [uri_ autorelease];
  uri_ = [str copy];
}
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CODESEARCH_SERVICE
