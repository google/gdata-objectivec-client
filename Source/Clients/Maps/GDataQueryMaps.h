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
//  GDataQueryMaps.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_MAPS_SERVICE

// Maps API query parameters

#import "GDataQuery.h"

@interface GDataQueryMaps : GDataQuery 

+ (GDataQueryMaps *)mapsQueryWithFeedURL:(NSURL *)feedURL;

- (NSString *)prevID;
- (void)setPrevID:(NSString *)str;

- (NSString *)attributeQueryString; // "mq"
- (void)setAttributeQueryString:(NSString *)str;

- (NSString *)boxString;
- (void)setBoxString:(NSString *)str;
- (void)setBoxWithWest:(double)west south:(double)south east:(double)east north:(double)north;

- (double)latitude; // degrees
- (void)setLatitude:(double)val;

- (double)longitude; // degrees
- (void)setLongitude:(double)val;

- (double)radius; // meters
- (void)setRadius:(double)val;

- (NSString *)sortBy;
- (void)setSortBy:(NSString *)str;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_MAPS_SERVICE
