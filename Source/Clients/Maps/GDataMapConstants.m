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

#define GDATAMAPCONSTANTS_DEFINE_GLOBALS 1
#import "GDataMapConstants.h"

#import "GDataEntryBase.h"

@implementation GDataMapConstants

+ (NSDictionary *)mapsNamespaces {
  // default namespace "atom"
  NSDictionary *baseNS = [GDataEntryBase baseGDataNamespaces];

  NSMutableDictionary *namespaces;
  namespaces = [NSMutableDictionary dictionaryWithDictionary:baseNS];

  [namespaces setObject:kGDataNamespaceKML
                 forKey:@"kml"];

  return namespaces;
}

+ (NSDictionary *)mapsServerNamespaces {
  // temporary workaround until the library can create from scratch
  // elements with a non-atom default namespace
  // (or until the Maps server can send XML with a non-kml namespace)
  //
  // For creating entries and feeds from scratch, we'll use the namespace
  // set above, with the default namespace "atom"
  //
  // For updating entries, which presumably came from the server, we'll use
  // this namespace set, with the default namespace "kml"

  NSDictionary *baseNS = [GDataEntryBase baseGDataNamespaces];

  NSMutableDictionary *namespaces;
  namespaces = [NSMutableDictionary dictionaryWithDictionary:baseNS];

  // kml is the default namespace; atom is explicitly "atom"
  [namespaces setObject:kGDataNamespaceKML
                 forKey:@""];
  [namespaces setObject:kGDataNamespaceAtom
                 forKey:kGDataNamespaceAtomPrefix];

  return namespaces;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_MAPS_SERVICE
