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
//  GDataMapConstants.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_MAPS_SERVICE

#import <Foundation/Foundation.h>

#import "GDataDefines.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAMAPCONSTANTS_DEFINE_GLOBALS
#define _EXTERN
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN GDATA_EXTERN
#define _INITIALIZE_AS(x)
#endif


_EXTERN NSString* const kGDataMapsDefaultServiceVersion _INITIALIZE_AS(@"2.0");

_EXTERN NSString* const kGDataNamespaceKML       _INITIALIZE_AS(@"http://earth.google.com/kml/2.2");
_EXTERN NSString* const kGDataNamespaceKMLPrefix _INITIALIZE_AS(@"kml");

_EXTERN NSString* const kGDataCategoryMap        _INITIALIZE_AS(@"http://schemas.google.com/maps/2008#map");
_EXTERN NSString* const kGDataCategoryMapFeature _INITIALIZE_AS(@"http://schemas.google.com/maps/2008#feature");
_EXTERN NSString* const kGDataCategoryMapVersion _INITIALIZE_AS(@"http://schemas.google.com/maps/2008#version");

_EXTERN NSString* const kGDataLinkMapView        _INITIALIZE_AS(@"http://schemas.google.com/maps/2008#view");

_EXTERN NSString* const kGDataMapPropertyAPIVisible _INITIALIZE_AS(@"api_visible");

@interface GDataMapConstants : NSObject
+ (NSDictionary *)mapsNamespaces;

// temporary workaround: this namespace set has a default namespace of kml
+ (NSDictionary *)mapsServerNamespaces;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_MAPS_SERVICE
