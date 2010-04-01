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
//  GDataQueryTranslation.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_TRANSLATION_SERVICE

#import "GDataQueryTranslation.h"

static NSString *const kDeleteParamName = @"delete";
static NSString *const kScopeParamName = @"scope";

@implementation GDataQueryTranslation

+ (GDataQueryTranslation *)translationQueryWithFeedURL:(NSURL *)feedURL {
  return [[[self alloc] initWithFeedURL:feedURL] autorelease];
}

#pragma mark -

- (void)setScope:(NSString *)str {
  [self addCustomParameterWithName:kScopeParamName
                             value:str];
}

- (NSString *)scope {
  NSString *str = [self valueForParameterWithName:kScopeParamName];
  return str;
}

- (void)setDeleteForAllUsers:(BOOL)flag {
  [self addCustomParameterWithName:kDeleteParamName
                         boolValue:flag
                      defaultValue:NO];
}

- (BOOL)deleteForAllUsers {
  BOOL flag = [self boolValueForParameterWithName:kDeleteParamName
                                     defaultValue:NO];
  return flag;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_TRANSLATION_SERVICE
