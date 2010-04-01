/* Copyright (c) 2008 Google Inc.
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
//  GDataWebmasterToolsConstants.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE

#define GDATAWEBMASTERTOOLS_DEFINE_GLOBALS 1

#import "GDataWebmasterToolsConstants.h"

#import "GDataEntryBase.h"

@implementation GDataWebmasterToolsConstants

+ (NSDictionary *)webmasterToolsNamespaces {

  NSMutableDictionary *namespaces;

  namespaces = [NSMutableDictionary dictionaryWithObject:kGDataNamespaceWebmasterTools
                                                  forKey:kGDataNamespaceWebmasterToolsPrefix];

  [namespaces addEntriesFromDictionary:[GDataEntryBase baseGDataNamespaces]];

  return namespaces;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE
