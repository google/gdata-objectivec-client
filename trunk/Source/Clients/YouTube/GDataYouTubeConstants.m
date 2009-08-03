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
//  GDataEntryYouTubeVideo.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#define GDATAYOUTUBECONSTANTS_DEFINE_GLOBALS 1
#import "GDataYouTubeConstants.h"

#import "GDataMediaGroup.h"
#import "GDataEntryBase.h"
#import "GDataGeo.h"

@implementation GDataYouTubeConstants

+ (NSDictionary *)youTubeNamespaces {

  NSMutableDictionary *namespaces = [NSMutableDictionary dictionaryWithDictionary:
    [GDataEntryBase baseGDataNamespaces]];

  [namespaces setObject:kGDataNamespaceYouTube
                 forKey:kGDataNamespaceYouTubePrefix]; // "yt"

  [namespaces setObject:kGDataNamespaceMedia
                 forKey:kGDataNamespaceMediaPrefix]; // "media"

  [namespaces addEntriesFromDictionary:[GDataGeo geoNamespaces]]; // geo, georss, gml

  return namespaces;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
