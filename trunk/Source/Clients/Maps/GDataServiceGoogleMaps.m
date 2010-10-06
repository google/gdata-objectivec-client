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
//  GDataServiceGoogleMaps.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_MAPS_SERVICE

#define GDATASERVICEGOOGLEMAPS_DEFINE_GLOBALS 1
#import "GDataServiceGoogleMaps.h"

#import "GDataMapConstants.h"
#import "GDataEntryMapFeature.h"

@implementation GDataServiceGoogleMaps

+ (NSURL *)mapsFeedURLForUserID:(NSString *)userID
                     projection:(NSString *)projection {

  NSString *const template = @"%@maps/%@/%@";

  NSString *encodedUserID = [GDataUtilities stringByURLEncodingStringParameter:userID];

  NSString *rootURLStr = [self serviceRootURLString];

  NSString *urlString = [NSString stringWithFormat:template,
                         rootURLStr, encodedUserID, projection];

  return [NSURL URLWithString:urlString];
}

// override the superclass's update method to use the namespaces that match
// those provided by the server
- (GDataServiceTicket *)fetchEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                         delegate:(id)delegate
                                didFinishSelector:(SEL)finishedSelector {

  if ([entryToUpdate namespaces] == nil) {
    if ([entryToUpdate isKindOfClass:[GDataEntryMapFeature class]]) {
      // we're updating a feature. Presumably it was supplied by the server
      // with a default kml namespace
      [entryToUpdate setNamespaces:[GDataMapConstants mapsServerNamespaces]];
    } else {
      // for other kinds of entries, the default namespace is atom
      [entryToUpdate setNamespaces:[GDataMapConstants mapsNamespaces]];
    }
  }

  return [super fetchEntryByUpdatingEntry:entryToUpdate
                                 delegate:delegate
                        didFinishSelector:finishedSelector];
}

#pragma mark -

+ (NSString *)serviceID {
  return @"local";
}

+ (NSString *)serviceRootURLString {
  return @"https://maps.google.com/maps/feeds/";
}

+ (NSString *)defaultServiceVersion {
  return kGDataMapsDefaultServiceVersion;
}

+ (NSDictionary *)standardServiceNamespaces {
  return [GDataMapConstants mapsNamespaces];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_MAPS_SERVICE
