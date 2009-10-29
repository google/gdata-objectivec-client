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
//  GDataHealthConstants.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_HEALTH_SERVICE

#import <Foundation/Foundation.h>

#import "GDataDefines.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAHEALTHCONSTANTS_DEFINE_GLOBALS
#define _EXTERN
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataHealthDefaultServiceVersion _INITIALIZE_AS(@"2.0");

// Continuity of Care Record namespace 
_EXTERN NSString* const kGDataNamespaceCCR       _INITIALIZE_AS(@"urn:astm-org:CCR");
_EXTERN NSString* const kGDataNamespaceCCRPrefix _INITIALIZE_AS(@"ccr");

_EXTERN NSString* const kGDataNamespaceH9M       _INITIALIZE_AS(@"http://schemas.google.com/health/metadata");
_EXTERN NSString* const kGDataNamespaceH9MPrefix _INITIALIZE_AS(@"h9m");

_EXTERN NSString* const kGDataCategoryH9Profile  _INITIALIZE_AS(@"http://schemas.google.com/health/kinds#profile");
_EXTERN NSString* const kGDataCategoryH9Register _INITIALIZE_AS(@"http://schemas.google.com/health/kinds#register");

_EXTERN NSString* const kGDataHealthSchemeCCR    _INITIALIZE_AS(@"http://schemas.google.com/health/ccr");
_EXTERN NSString* const kGDataHealthSchemeItem   _INITIALIZE_AS(@"http://schemas.google.com/health/item");

_EXTERN NSString* const kGDataHealthRelComplete  _INITIALIZE_AS(@"http://schemas.google.com/health/data#complete");


@interface GDataHealthConstants : NSObject 
+ (NSDictionary *)healthNamespaces;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_HEALTH_SERVICE
