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
//  GDataQueryTranslation.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_TRANSLATION_SERVICE

#import "GDataQuery.h"

@interface GDataQueryTranslation : GDataQuery

+ (GDataQueryTranslation *)translationQueryWithFeedURL:(NSURL *)feedURL;

// for scope, use kGDataTranslationScopePrivate and kGDataTranslationScopePublic
// from GDataTranslationConstants
- (void)setScope:(NSString *)str;
- (NSString *)scope;

// on deletes, this causes deletion for all users, ignoring the ACL roles
- (void)setDeleteForAllUsers:(BOOL)flag;
- (BOOL)deleteForAllUsers;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_TRANSLATION_SERVICE
