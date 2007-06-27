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
//  GDataCodeSearchMatch.m
//

#import "GDataCodeSearchMatch.h"
#import "GDataEntryCodeSearch.h"

@implementation GDataCodeSearchMatch 

// For code search source matches, like
//
//  <gcs:match lineNumber="23" type="text/html">
//    found &lt;b&gt; query &lt;/b&gt;
//  </gcs:match>
//
// See http://code.google.com/apis/codesearch/reference.html

+ (NSString *)extensionElementURI       { return kGDataNamespaceCodeSearch; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceCodeSearchPrefix; }
+ (NSString *)extensionElementLocalName { return @"match"; }

+ (id)matchWithStringValue:(NSString *)valueStr
                      type:(NSString *)type
          lineNumberString:(NSString *)lineNumberStr {

  GDataCodeSearchMatch *obj = [[[GDataCodeSearchMatch alloc] init] autorelease];
  [obj setStringValue:valueStr];
  [obj setType:type];
  [obj setLineNumberString:lineNumberStr];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setLineNumberString:[self stringForAttributeName:@"lineNumber" 
                                               fromElement:element]];
    // stringValue and type are set by the superclass, GDataTextConstruct
  }
  return self;
}

- (void)dealloc {
  [lineNumberString_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataCodeSearchMatch* newObj = [super copyWithZone:zone];
  [newObj setLineNumberString:lineNumberString_];
  return newObj;
}

- (BOOL)isEqual:(GDataCodeSearchMatch *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataCodeSearchMatch class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self lineNumberString], [other lineNumberString]);
}

- (NSString *)description {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:content_ withName:@"content"];
  [self addToArray:items objectDescriptionIfNonNil:type_    withName:@"type"];
  [self addToArray:items objectDescriptionIfNonNil:lineNumberString_ withName:@"lineNumber"];
  
  return [NSString stringWithFormat:@"%@ 0x%lX: {%@}",
    [self class], self, [items componentsJoinedByString:@" "]];
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [super XMLElement];
  
  [self addToElement:element attributeValueIfNonNil:[self lineNumberString] withName:@"lineNumber"];
  
  return element;
}

- (NSString *)lineNumberString {
  return lineNumberString_; 
}

- (void)setLineNumberString:(NSString *)str {
  [lineNumberString_ autorelease];
  lineNumberString_ = [str copy];
}
@end

