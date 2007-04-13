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
//  GDataWhere.m
//

#import "GDataWhere.h"

#import "GDataEntryLink.h"

@implementation GDataWhere
// where element, as in
// <gd:where rel="http://schemas.google.com/g/2005#event" valueString="Joe's Pub">
//    <gd:entryLink href="http://local.example.com/10018/JoesPub">
// </gd:where>
//
// http://code.google.com/apis/gdata/common-elements.html#gdWhere

+ (NSString *)extensionElementURI       { return kGDataNamespaceGData; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementLocalName { return @"where"; }

+ (GDataWhere *)whereWithString:(NSString *)str {
  GDataWhere* obj = [[[GDataWhere alloc] init] autorelease];
  [obj setStringValue:str];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setRel:[self stringForAttributeName:@"rel"
                                  fromElement:element]];
    [self setStringValue:[self stringForAttributeName:@"valueString"
                                          fromElement:element]];
    [self setLabel:[self stringForAttributeName:@"label"
                                    fromElement:element]];
    
    [self setEntryLink:[self objectForChildOfElement:element
                                       qualifiedName:@"gd:entryLink"
                                        namespaceURI:kGDataNamespaceGData
                                         objectClass:[GDataEntryLink class]]];
  }
  return self;
}

- (void)dealloc {
  [rel_ release];
  [label_ release];
  [valueString_ release];
  [entryLink_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataWhere* newWhere = [super copyWithZone:zone];
  [newWhere setRel:rel_];
  [newWhere setLabel:label_];
  [newWhere setStringValue:valueString_];
  [newWhere setEntryLink:entryLink_];
  return newWhere;
}

- (BOOL)isEqual:(GDataWhere *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataWhere class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self rel], [other rel])
    && AreEqualOrBothNil([self label], [other label])
    && AreEqualOrBothNil([self stringValue], [other stringValue])
    && AreEqualOrBothNil([self entryLink], [other entryLink]);
}

- (NSString *)description {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:rel_ withName:@"rel"];
  [self addToArray:items objectDescriptionIfNonNil:valueString_ withName:@"valueString"];
  [self addToArray:items objectDescriptionIfNonNil:label_ withName:@"label"];
  [self addToArray:items objectDescriptionIfNonNil:entryLink_ withName:@"entryLink"];
  
  return [NSString stringWithFormat:@"%@ 0x%lX: {%@}",
    [self class], self, [items componentsJoinedByString:@" "]];
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"gd:where"];
  
  [self addToElement:element attributeValueIfNonNil:[self rel]        withName:@"rel"];
  [self addToElement:element attributeValueIfNonNil:[self stringValue] withName:@"valueString"];
  [self addToElement:element attributeValueIfNonNil:[self label]       withName:@"label"];
  
  if (entryLink_) {
    NSXMLNode *entryLinkElement = [entryLink_ XMLElement];
    [element addChild:entryLinkElement];
  }
  
  return element;
}

- (NSString *)rel {
  return rel_;
}

- (void)setRel:(NSString *)str {
  [rel_ autorelease];
  rel_ = [str copy];
}

- (NSString *)label {
  return label_;
}

- (void)setLabel:(NSString *)str {
  [label_ autorelease];
  label_ = [str copy];
}

- (NSString *)stringValue {
  return valueString_;
}

- (void)setStringValue:(NSString *)str {
  [valueString_ autorelease];
  valueString_ = [str copy];
}

- (GDataEntryLink *)entryLink {
  return entryLink_;
}

- (void)setEntryLink:(GDataEntryLink *)entryLink {
  [entryLink_ autorelease];
  entryLink_ = [entryLink retain];
}

@end
