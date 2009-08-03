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
//  GDataGoogleBaseMetadataAttributeList.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_GOOGLEBASE_SERVICE

#import "GDataGoogleBaseMetadataAttributeList.h"
#import "GDataEntryGoogleBase.h"

@implementation GDataGoogleBaseMetadataAttributeList
// for gm:attributes, like 
//   <gm:attributes>
//     <gm:attribute1   ...>
//     <gm:attribute2   ...>
//   </gm:attributes>


+ (NSString *)extensionElementURI       { return kGDataNamespaceGoogleBaseMetadata; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGoogleBaseMetadataPrefix; }
+ (NSString *)extensionElementLocalName { return @"attributes"; }

#pragma mark -

+ (GDataGoogleBaseMetadataAttributeList *)metadataAttributeList {
                      
  GDataGoogleBaseMetadataAttributeList *obj = [[[GDataGoogleBaseMetadataAttributeList alloc] init] autorelease];
  return obj;
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  // gm:attributes may contain gm:attribute (that is, the list element may
  // contain the attribute element)
  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataGoogleBaseMetadataAttribute class]];  
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataGoogleBaseMetadataAttributeList* newObj = [super copyWithZone:zone];
  return newObj;
}

- (BOOL)isEqual:(GDataGoogleBaseMetadataAttributeList *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataGoogleBaseMetadataAttributeList class]]) return NO;
  
  return [super isEqual:other];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:[self metadataAttributes]   
                                        withName:@"attributes"];
  
  return items;
}
#endif

- (NSXMLElement *)XMLElement {

  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"gm:attributes"];
  return element;
}

#pragma mark -

- (NSArray *)metadataAttributes {
  NSArray *attrs = [self objectsForExtensionClass:[GDataGoogleBaseMetadataAttribute class]];
  return attrs;
}

- (void)setMetadataAttributes:(NSArray *)attributes {
  [self setObjects:attributes forExtensionClass:[GDataGoogleBaseMetadataAttribute class]]; 
}

- (void)addMetadataAttribute:(GDataGoogleBaseMetadataAttribute *)attribute {
  [self addObject:attribute forExtensionClass:[GDataGoogleBaseMetadataAttribute class]]; 
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_GOOGLEBASE_SERVICE
