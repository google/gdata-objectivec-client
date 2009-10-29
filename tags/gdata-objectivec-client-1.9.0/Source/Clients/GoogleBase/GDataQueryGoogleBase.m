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
//  GDataQueryGoogleBase.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_GOOGLEBASE_SERVICE

#import "GDataQueryGoogleBase.h"

static NSString *const kMaxValuesParamName = @"max-values";
static NSString *const kBQParamName = @"bq";

@implementation GDataQueryGoogleBase

+ (GDataQueryGoogleBase *)googleBaseQueryWithFeedURL:(NSURL *)feedURL {
  return [[[self alloc] initWithFeedURL:feedURL] autorelease];
}

- (NSString *)googleBaseQuery {
  NSString *str =  [self valueForParameterWithName:kBQParamName];
  return str;
}

- (void)setGoogleBaseQuery:(NSString *)str {
  [self addCustomParameterWithName:kBQParamName value:str];
}

- (NSInteger)maxValues {
  return [self intValueForParameterWithName:kMaxValuesParamName
                      missingParameterValue:0];
}

- (void)setMaxValues:(NSInteger)val {
  [self addCustomParameterWithName:kMaxValuesParamName
                          intValue:val
                    removeForValue:0];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_GOOGLEBASE_SERVICE
