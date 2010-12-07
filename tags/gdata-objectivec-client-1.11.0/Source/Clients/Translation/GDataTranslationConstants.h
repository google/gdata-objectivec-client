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
//  GDataTranslationConstants.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_TRANSLATION_SERVICE

#import <Foundation/Foundation.h>

#import "GDataDefines.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATATRANSLATIONCONSTANTS_DEFINE_GLOBALS
#define _EXTERN
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataTranslationDefaultServiceVersion _INITIALIZE_AS(@"1.0");

// namespaces
_EXTERN NSString* const kGDataNamespaceTranslation       _INITIALIZE_AS(@"http://schemas.google.com/gtt/2009/11");
_EXTERN NSString* const kGDataNamespaceTranslationPrefix _INITIALIZE_AS(@"gtt");

// feed/entry kinds
_EXTERN NSString* const kGDataKindTranslationDocument   _INITIALIZE_AS(@"gtrans#document");
_EXTERN NSString* const kGDataKindTranslationMemory     _INITIALIZE_AS(@"gtrans#memory");
_EXTERN NSString* const kGDataKindTranslationGlossary   _INITIALIZE_AS(@"gtrans#glossary");

// categories
_EXTERN NSString* const kGDataCategoryTranslationState      _INITIALIZE_AS(@"http://schemas.google.com/gtt/2009/11#translationState");
_EXTERN NSString* const kGDataCategoryTranslationCompleted  _INITIALIZE_AS(@"http://schemas.google.com/gtt/2009/11#completed");
_EXTERN NSString* const kGDataCategoryTranslationLabels     _INITIALIZE_AS(@"http://schemas.google.com/g/2005#labels");
_EXTERN NSString* const kGDataCategoryTranslationHidden     _INITIALIZE_AS(@"http://schemas.google.com/g/2005#hidden");

// query values
_EXTERN NSString* const kGDataTranslationScopePrivate _INITIALIZE_AS(@"private");
_EXTERN NSString* const kGDataTranslationScopePublic  _INITIALIZE_AS(@"public");


@interface GDataTranslationConstants : NSObject

+ (NSString *)coreProtocolVersionForServiceVersion:(NSString *)serviceVersion;

+ (NSDictionary *)translationNamespaces;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_TRANSLATION_SERVICE
