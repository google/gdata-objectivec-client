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
//  GDataEntryMapFeature.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_MAPS_SERVICE

#import "GDataEntryBase.h"
#import "GDataCustomProperty.h"
#import "GDataStructuredPostalAddress.h"

@interface GDataEntryMapFeature : GDataEntryBase

+ (id)featureEntryWithTitle:(NSString *)str;

// extensions

- (GDataStructuredPostalAddress *)postalAddress;
- (void)setPostalAddress:(GDataStructuredPostalAddress *)obj;

- (NSArray *)customProperties;
- (void)setCustomProperties:(NSArray *)array;
- (void)addCustomProperty:(GDataCustomProperty *)obj;

// KMLValues accesses the entry's content element, which contains the KML XML
- (NSArray *)KMLValues;
- (void)setKMLValues:(NSArray *)arr;
- (void)addKMLValue:(NSXMLNode *)node;

// convenience accessors
- (GDataCustomProperty *)customPropertyWithName:(NSString *)name;

- (GDataLink *)viewLink;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_MAPS_SERVICE
