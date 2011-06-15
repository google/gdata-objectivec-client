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
//  GDataCodeSearchFile.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CODESEARCH_SERVICE

#import "GDataCodeSearchFile.h"
#import "GDataEntryCodeSearch.h"

@implementation GDataCodeSearchFile 

// For code search files, like
//
//  <gcs:file name="w3c-libwww-5.4.0/Library/src/wwwsys.h"/>
//
// See http://code.google.com/apis/codesearch/reference.html

+ (NSString *)extensionElementURI       { return kGDataNamespaceCodeSearch; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceCodeSearchPrefix; }
+ (NSString *)extensionElementLocalName { return @"file"; }

+ (id)fileWithName:(NSString *)name {

  GDataCodeSearchFile *obj = [self object];
  [obj setName:name];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setName:[self stringForAttributeName:@"name" 
                                   fromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [name_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataCodeSearchFile* newObj = [super copyWithZone:zone];
  [newObj setName:[self name]];
  return newObj;
}

- (BOOL)isEqual:(GDataCodeSearchFile *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataCodeSearchFile class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self name], [other name]);
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:name_ withName:@"name"];
  
  return items;
}
#endif

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:nil];
  
  [self addToElement:element attributeValueIfNonNil:[self name] withName:@"name"];
  
  return element;
}

- (NSString *)name {
  return name_; 
}

- (void)setName:(NSString *)str {
  [name_ autorelease];
  name_ = [str copy];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CODESEARCH_SERVICE
