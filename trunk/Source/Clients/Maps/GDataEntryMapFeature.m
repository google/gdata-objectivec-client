/* Copyright (c) 2009 Google Inc.
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
//  GDataEntryMapFeature.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_MAPS_SERVICE

#import "GDataMapConstants.h"
#import "GDataEntryMapFeature.h"

@implementation GDataEntryMapFeature

+ (id)featureEntryWithTitle:(NSString *)str {

  GDataEntryMapFeature *obj = [[[self alloc] init] autorelease];

  [obj setNamespaces:[GDataMapConstants mapsNamespaces]];

  [obj setTitleWithString:str];

  return obj;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategoryMapFeature;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  Class entryClass = [self class];

  [self addExtensionDeclarationForParentClass:entryClass
                                 childClasses:
   [GDataStructuredPostalAddress class],
   [GDataCustomProperty class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  NSString *kmlString = nil;
  NSArray *kmlValues = [self KMLValues];

  if ([kmlValues count] > 0) {
    NSXMLElement *kmlElem = [kmlValues objectAtIndex:0];
    kmlString = [kmlElem XMLString];
  }

  struct GDataDescriptionRecord descRecs[] = {
    { @"postal",     @"postalAddress",    kGDataDescValueLabeled   },
    { @"properties", @"customProperties", kGDataDescArrayDescs     },
    { @"KML",        kmlString,           kGDataDescValueIsKeyPath },
    { nil, nil, 0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

+ (NSString *)defaultServiceVersion {
  return kGDataMapsDefaultServiceVersion;
}

#pragma mark -

- (void)setPostalAddress:(GDataStructuredPostalAddress *)obj {
  [self setObject:obj forExtensionClass:[GDataStructuredPostalAddress class]];
}

- (GDataStructuredPostalAddress *)postalAddress {
  return [self objectForExtensionClass:[GDataStructuredPostalAddress class]];
}

- (NSArray *)customProperties {
  return [self objectsForExtensionClass:[GDataCustomProperty class]];
}

- (void)setCustomProperties:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataCustomProperty class]];
}

- (void)addCustomProperty:(GDataCustomProperty *)obj {
  [self addObject:obj forExtensionClass:[GDataCustomProperty class]];
}

// wrappers around the content element, which contains the KML

- (NSArray *)KMLValues {
  NSArray *array = [[self content] XMLValues];
  return array;
}

- (void)setKMLValues:(NSArray *)arr {
  GDataEntryContent *content = [self content];
  if (content == nil) {
    content = [GDataEntryContent contentWithXMLValue:nil
                                                type:kGDataContentTypeKML];
    [self setContent:content];
  } else {
    [content setType:kGDataContentTypeKML];
  }
  [content setChildXMLElements:arr];
}

- (void)addKMLValue:(NSXMLNode *)node {
  GDataEntryContent *content = [self content];
  if (content == nil) {
    content = [GDataEntryContent contentWithXMLValue:node
                                                type:kGDataContentTypeKML];
    [self setContent:content];
  } else {
    [content setType:kGDataContentTypeKML];
    [content addChildXMLElement:node];
  }
}

// convenience accessors
- (GDataCustomProperty *)customPropertyWithName:(NSString *)name {
  NSArray *array = [self customProperties];
  GDataCustomProperty *obj = [GDataUtilities firstObjectFromArray:array
                                                   withValue:name
                                                  forKeyPath:@"name"];
  return obj;
}

- (GDataLink *)viewLink {
  return [self linkWithRelAttributeValue:kGDataLinkMapView];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_MAPS_SERVICE
