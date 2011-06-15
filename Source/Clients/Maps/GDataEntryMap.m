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
//  GDataEntryMap.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_MAPS_SERVICE

#import "GDataEntryMap.h"
#import "GDataMapConstants.h"

@implementation GDataEntryMap

+ (id)mapEntryWithTitle:(NSString *)str {

  GDataEntryMap *obj = [self object];

  [obj setNamespaces:[GDataMapConstants mapsNamespaces]];
  [obj setTitleWithString:str];

  return obj;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategoryMap;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  Class entryClass = [self class];

  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataCustomProperty class]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"properties", @"customProperties", kGDataDescArrayDescs },
    { nil, nil, (GDataDescRecTypes)0 }
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

- (NSArray *)customProperties {
  return [self objectsForExtensionClass:[GDataCustomProperty class]];
}

- (void)setCustomProperties:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataCustomProperty class]];
}

- (void)addCustomProperty:(GDataCustomProperty *)obj {
  [self addObject:obj forExtensionClass:[GDataCustomProperty class]];
}

#pragma mark -

// convenience accessors

- (NSURL *)featuresFeedURL {
  NSURL *featuresFeedURL = [[self content] sourceURL];
  return featuresFeedURL;
}

- (GDataCustomProperty *)customPropertyWithName:(NSString *)name {
  NSArray *array = [self customProperties];
  GDataCustomProperty *obj = [GDataUtilities firstObjectFromArray:array
                                                        withValue:name
                                                       forKeyPath:@"name"];
  return obj;
}

- (BOOL)isAPIVisible {
  BOOL isAPIVisible = YES;

  GDataCustomProperty *prop;
  prop = [self customPropertyWithName:kGDataMapPropertyAPIVisible];

  if (prop != nil) {
    NSString *value = [prop value];
    isAPIVisible = ([value intValue] > 0);
  }
  return isAPIVisible;
}

- (GDataLink *)viewLink {
  return [self linkWithRelAttributeValue:kGDataLinkMapView];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_MAPS_SERVICE
