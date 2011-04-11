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
//  GDataTranslationConstants.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_TRANSLATION_SERVICE

#define GDATATRANSLATIONCONSTANTS_DEFINE_GLOBALS 1
#import "GDataTranslationConstants.h"

#import "GDataEntryBase.h"

@implementation GDataTranslationConstants

+ (NSString *)coreProtocolVersionForServiceVersion:(NSString *)serviceVersion {
  // Translation v1: core v2.1
  return @"2.1";
}

+ (NSDictionary *)translationNamespaces {
  NSMutableDictionary *namespaces;

  namespaces = [NSMutableDictionary dictionaryWithObject:kGDataNamespaceTranslation
                                                  forKey:kGDataNamespaceTranslationPrefix];

  [namespaces addEntriesFromDictionary:[GDataEntryBase baseGDataNamespaces]];

  return namespaces;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_TRANSLATION_SERVICE
