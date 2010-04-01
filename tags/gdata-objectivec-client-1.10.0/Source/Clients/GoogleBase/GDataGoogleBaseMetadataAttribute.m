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
//  GDataGoogleBaseMetadataAttribute.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_GOOGLEBASE_SERVICE

#import "GDataGoogleBaseMetadataAttribute.h"
#import "GDataEntryGoogleBase.h"

@implementation GDataGoogleBaseMetadataAttribute
// for gm:attribute, like 
// <gm:attribute name='item type' type='text' count='116353'>
//   <gm:value count='87269'>products</gm:value>
//   <gm:value count='2401'>produkte</gm:value>
// </gm:attribute>

// this object may be an extension, so declare its extension characteristics

+ (NSString *)extensionElementURI       { return kGDataNamespaceGoogleBaseMetadata; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGoogleBaseMetadataPrefix; }
+ (NSString *)extensionElementLocalName { return @"attribute"; }

+ (GDataGoogleBaseMetadataAttribute *)metadataAttributeWithType:(NSString *)type
                      name:(NSString *)name
                      count:(NSNumber *)count {
                      
  GDataGoogleBaseMetadataAttribute *obj = [[[GDataGoogleBaseMetadataAttribute alloc] init] autorelease];
  [obj setName:name];
  [obj setType:type];
  [obj setCount:count];
  return obj;
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  // gm:attribute may contain gm:value
  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataGoogleBaseMetadataValue class]];  
  
}


- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setName:[self stringForAttributeName:@"name"
                                  fromElement:element]];
    [self setType:[self stringForAttributeName:@"type"
                                   fromElement:element]];
    [self setCount:[self intNumberForAttributeName:@"count"
                                                fromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [name_ release];
  [type_ release];
  [count_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataGoogleBaseMetadataAttribute* newObj = [super copyWithZone:zone];
  [newObj setName:[self name]];
  [newObj setType:[self type]];
  [newObj setCount:[self count]];
  return newObj;
}

- (BOOL)isEqual:(GDataGoogleBaseMetadataAttribute *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataGoogleBaseMetadataAttribute class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self name], [other name])
    && AreEqualOrBothNil([self type], [other type])
    && AreEqualOrBothNil([self count], [other count]);
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:name_   withName:@"name"];
  [self addToArray:items objectDescriptionIfNonNil:type_   withName:@"type"];
  [self addToArray:items objectDescriptionIfNonNil:count_  withName:@"count"];
  
  if ([[self values] count]) {
    [self addToArray:items objectDescriptionIfNonNil:[self values]  withName:@"metadataValues"];
  }
  
  return items;
}
#endif

- (NSXMLElement *)XMLElement {

  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"gm:attribute"];
  
  [self addToElement:element attributeValueIfNonNil:[self name]  withName:@"name"];
  [self addToElement:element attributeValueIfNonNil:[self type]  withName:@"type"];
  [self addToElement:element attributeValueIfNonNil:[[self count] stringValue] 
                                           withName:@"count"];

  return element;
}

- (NSString *)name {
  return name_;
}

- (void)setName:(NSString *)str {
  [name_ autorelease];
  name_ = [str copy];
}

- (NSString *)type {
  return type_; 
}

- (void)setType:(NSString *)str {
  [type_ autorelease];
  type_ = [str copy];
}

- (NSNumber *)count {
  return count_; 
}

- (void)setCount:(NSNumber *)num {
  [count_ autorelease];
  count_ = [num copy];
}

#pragma mark -

- (NSArray *)values {
  NSArray *values = [self objectsForExtensionClass:[GDataGoogleBaseMetadataValue class]];
  return values;
}

- (void)setValues:(NSArray *)values {
  [self setObjects:values forExtensionClass:[GDataGoogleBaseMetadataValue class]]; 
}

- (void)addValue:(GDataGoogleBaseMetadataValue *)value {
  [self addObject:value forExtensionClass:[GDataGoogleBaseMetadataValue class]]; 
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_GOOGLEBASE_SERVICE
