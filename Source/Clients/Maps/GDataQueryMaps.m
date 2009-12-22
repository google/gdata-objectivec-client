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
//  GDataQueryMaps.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_MAPS_SERVICE

#import "GDataQueryMaps.h"
#import "GDataServiceGoogleMaps.h"

static NSString *const kPrevIDParamName = @"previd";
static NSString *const kMQParamName = @"mq";
static NSString *const kBoxParamName = @"box";
static NSString *const kLatParamName = @"lat";
static NSString *const kLngParamName = @"lng";
static NSString *const kRadiusParamName = @"radius";
static NSString *const kSortByParamName = @"sortby";

@implementation GDataQueryMaps

+ (GDataQueryMaps *)mapsQueryWithFeedURL:(NSURL *)feedURL {
  return [[[self alloc] initWithFeedURL:feedURL] autorelease];
}

- (NSString *)prevID {
  NSString *str = [self valueForParameterWithName:kPrevIDParamName];
  return str;
}

- (void)setPrevID:(NSString *)str {
  [self addCustomParameterWithName:kPrevIDParamName
                             value:str];
}

- (NSString *)attributeQueryString  {
  NSString *str = [self valueForParameterWithName:kMQParamName];
  return str;
}

- (void)setAttributeQueryString:(NSString *)str {
  [self addCustomParameterWithName:kMQParamName
                             value:str];
}

- (NSString *)boxString {
  NSString *str = [self valueForParameterWithName:kBoxParamName];
  return str;
}

- (void)setBoxString:(NSString *)str {
  [self addCustomParameterWithName:kBoxParamName
                             value:str];
}

- (void)setBoxWithWest:(double)west
                 south:(double)south
                  east:(double)east
                 north:(double)north {
  NSString *str = [NSString stringWithFormat:@"%f,%f,%f,%f",
                   west, south, east, north];

  [self addCustomParameterWithName:kBoxParamName
                             value:str];
}

- (double)latitude { // degrees
  NSString *str = [self valueForParameterWithName:kLatParamName];
  return [str doubleValue];
}

- (void)setLatitude:(double)val {
  NSString *str = [NSString stringWithFormat:@"%f", val];
  [self addCustomParameterWithName:kLatParamName
                             value:str];
}

- (double)longitude { // degrees
  NSString *str = [self valueForParameterWithName:kLngParamName];
  return [str doubleValue];
}

- (void)setLongitude:(double)val {
  NSString *str = [NSString stringWithFormat:@"%f", val];
  [self addCustomParameterWithName:kLngParamName
                             value:str];
}

- (double)radius { // meters
  NSString *str = [self valueForParameterWithName:kRadiusParamName];
  return [str doubleValue];
}

- (void)setRadius:(double)val {
  NSString *str = [NSString stringWithFormat:@"%f", val];
  [self addCustomParameterWithName:kRadiusParamName
                             value:str];
}

- (NSString *)sortBy {
  NSString *str = [self valueForParameterWithName:kSortByParamName];
  return str;
}

- (void)setSortBy:(NSString *)str {
  [self addCustomParameterWithName:kSortByParamName
                             value:str];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_MAPS_SERVICE
