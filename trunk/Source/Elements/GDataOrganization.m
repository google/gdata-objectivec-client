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
//  GDataOrganization.m
//

#import "GDataOrganization.h"

@implementation GDataOrgTitle 
+ (NSString *)extensionElementPrefix { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementURI    { return kGDataNamespaceGData; }
+ (NSString *)extensionElementLocalName { return @"orgTitle"; }
@end

@implementation GDataOrgName 
+ (NSString *)extensionElementPrefix { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementURI    { return kGDataNamespaceGData; }
+ (NSString *)extensionElementLocalName { return @"orgName"; }
@end

@implementation GDataOrganization
// organization, as in 
//  <gd:organization primary="true" rel="http://schemas.google.com/g/2005#work">
//    <gd:orgName>Acme Corp</gd:orgName>
//    <gd:orgTitle>Prezident</gd:orgTitle>
//  </gd:organization>

+ (NSString *)extensionElementURI       { return kGDataNamespaceGData; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementLocalName { return @"organization"; }

+ (GDataOrganization *)organizationWithName:(NSString *)str {
  GDataOrganization *obj = [[[GDataOrganization alloc] init] autorelease];
  [obj setOrgName:str];
  return obj;
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];

  Class elementClass = [self class];
  
  [self addExtensionDeclarationForParentClass:elementClass
                                   childClass:[GDataOrgTitle class]];  
  [self addExtensionDeclarationForParentClass:elementClass
                                   childClass:[GDataOrgName class]];  
  
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setRel:[self stringForAttributeName:@"rel"
                                  fromElement:element]];
    [self setLabel:[self stringForAttributeName:@"label"
                                    fromElement:element]];
    [self setIsPrimary:[self boolForAttributeName:@"primary"
                                      fromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [rel_ release];
  [label_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataOrganization* newObj = [super copyWithZone:zone];
  [newObj setRel:[self rel]];
  [newObj setLabel:[self label]];
  [newObj setIsPrimary:[self isPrimary]];
  return newObj;
}

- (BOOL)isEqual:(GDataOrganization *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataOrganization class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self label], [other label])
    && AreEqualOrBothNil([self rel], [other rel])
    && AreBoolsEqual([self isPrimary], [other isPrimary]);
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:[self orgTitle] withName:@"title"];
  [self addToArray:items objectDescriptionIfNonNil:[self orgName] withName:@"name"];
  [self addToArray:items objectDescriptionIfNonNil:[self rel] withName:@"rel"];
  [self addToArray:items objectDescriptionIfNonNil:[self label] withName:@"label"];
  
  if ([self isPrimary]) [items addObject:@"primary"];
  
  return items;
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:nil];
  
  [self addToElement:element attributeValueIfNonNil:[self rel] withName:@"rel"];
  [self addToElement:element attributeValueIfNonNil:[self label] withName:@"label"];
  
  if ([self isPrimary]) {
    [self addToElement:element attributeValueIfNonNil:@"true" withName:@"primary"]; 
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

- (BOOL)isPrimary {
  return isPrimary_; 
}

- (void)setIsPrimary:(BOOL)flag {
  isPrimary_ = flag;
}

- (NSString *)orgName {
  GDataOrgName *obj = [self objectForExtensionClass:[GDataOrgName class]];
  return [obj stringValue];
}

- (void)setOrgName:(NSString *)str {
  
  GDataOrgName *obj = nil;
  if ([str length] > 0) {
    obj = [GDataOrgName valueWithString:str];
  }
  [self setObject:obj forExtensionClass:[GDataOrgName class]]; 
}

- (NSString *)orgTitle {
  GDataOrgTitle *obj = [self objectForExtensionClass:[GDataOrgTitle class]];
  return [obj stringValue];
}

- (void)setOrgTitle:(NSString *)str {
  
  GDataOrgTitle *obj = nil;
  if ([str length] > 0) {
    obj = [GDataOrgTitle valueWithString:str];
  }
  [self setObject:obj forExtensionClass:[GDataOrgTitle class]]; 
}

@end
