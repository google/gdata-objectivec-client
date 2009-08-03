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
//  GDataGoogleBaseMetadataItemType.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_GOOGLEBASE_SERVICE

#import "GDataGoogleBaseMetadataItemType.h"
#import "GDataEntryGoogleBase.h"

@implementation GDataGoogleBaseMetadataItemType
// for values, like <gm:item_type>fred's thing</gm:item_type>


+ (NSString *)extensionElementURI       { return kGDataNamespaceGoogleBaseMetadata; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGoogleBaseMetadataPrefix; }
+ (NSString *)extensionElementLocalName { return @"item_type"; }

#pragma mark -

+ (GDataGoogleBaseMetadataItemType *)metadataItemTypeWithValue:(NSString *)value {
                      
  GDataGoogleBaseMetadataItemType *obj = [[[GDataGoogleBaseMetadataItemType alloc] init] autorelease];
  [obj setValue:value];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setValue:[self stringValueFromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [value_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataGoogleBaseMetadataItemType* newObj = [super copyWithZone:zone];
  [newObj setValue:[self value]];
  return newObj;
}

- (BOOL)isEqual:(GDataGoogleBaseMetadataItemType *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataGoogleBaseMetadataItemType class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self value], [other value]);
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:value_ withName:@"value"];
  
  return items;
}
#endif

- (NSXMLElement *)XMLElement {

  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"gm:item_type"];
  if ([self value]) {
    [element addStringValue:[self value]];
  }
  return element;
}

#pragma mark -

- (NSString *)value {
  return value_;
}

- (void)setValue:(NSString *)str {
  [value_ autorelease];
  value_ = [str copy];
}


@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_GOOGLEBASE_SERVICE
