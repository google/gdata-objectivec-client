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
//  GDataQueryGoogleHealth.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_HEALTH_SERVICE

#import "GDataQueryGoogleHealth.h"

static NSString *const kDigestParamName = @"digest";
static NSString *const kGroupedParamName = @"grouped";

static NSString *const kMaxResultsGroupParamName = @"max-results-group";
static NSString *const kMaxResultsInGroupParamName = @"max-results-in-group";

static NSString *const kStartIndexGroupParamName = @"start-index-group";
static NSString *const kStartIndexInGroupParamName = @"start-index-in-group";

@implementation GDataQueryGoogleHealth

+ (GDataQueryGoogleHealth *)healthQueryWithFeedURL:(NSURL *)feedURL {
  return [[[self alloc] initWithFeedURL:feedURL] autorelease];
}

- (void)setIsDigest:(BOOL)flag {
  [self addCustomParameterWithName:kDigestParamName
                         boolValue:flag
                      defaultValue:NO];
}

- (BOOL)isDigest {
  return [self boolValueForParameterWithName:kDigestParamName
                                defaultValue:NO];
}

- (void)setIsGrouped:(BOOL)flag {
  [self addCustomParameterWithName:kGroupedParamName
                         boolValue:flag
                      defaultValue:NO];
}

- (BOOL)isGrouped {
  return [self boolValueForParameterWithName:kGroupedParamName
                                defaultValue:NO];
}

- (void)setMaxResultsGroup:(NSInteger)val {
  [self addCustomParameterWithName:kMaxResultsGroupParamName
                          intValue:val
                    removeForValue:0];
}

- (NSInteger)maxResultsGroup {
  return [self intValueForParameterWithName:kMaxResultsGroupParamName
                      missingParameterValue:0];
}

- (void)setMaxResultsInGroup:(NSInteger)val {
  [self addCustomParameterWithName:kMaxResultsInGroupParamName
                          intValue:val
                    removeForValue:0];
}

- (NSInteger)maxResultsInGroup {
  return [self intValueForParameterWithName:kMaxResultsInGroupParamName
                      missingParameterValue:0];
}

- (void)setStartIndexGroup:(NSInteger)val {
  [self addCustomParameterWithName:kStartIndexGroupParamName
                          intValue:val
                    removeForValue:0];
}

- (NSInteger)startIndexGroup {
  return [self intValueForParameterWithName:kStartIndexGroupParamName
                      missingParameterValue:0];
}

- (void)setStartIndexInGroup:(NSInteger)val {
  [self addCustomParameterWithName:kStartIndexInGroupParamName
                          intValue:val
                    removeForValue:0];
}

- (NSInteger)startIndexInGroup {
  return [self intValueForParameterWithName:kStartIndexInGroupParamName
                      missingParameterValue:0];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_HEALTH_SERVICE
