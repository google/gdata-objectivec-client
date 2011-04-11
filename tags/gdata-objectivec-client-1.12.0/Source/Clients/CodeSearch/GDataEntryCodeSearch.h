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
//  GDataEntryCodeSearch.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CODESEARCH_SERVICE

#import "GDataEntryBase.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAENTRYCODESEARCH_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN GDATA_EXTERN
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataCodeSearchDefaultServiceVersion _INITIALIZE_AS(@"2.0");

_EXTERN NSString* const kGDataCategoryCodeSearch _INITIALIZE_AS(@"http://schemas.google.com/codesearch/2006#result"); // from CodeSearchEntry.java

_EXTERN NSString* const kGDataNamespaceCodeSearch _INITIALIZE_AS(@"http://schemas.google.com/codesearch/2006");
_EXTERN NSString* const kGDataNamespaceCodeSearchPrefix _INITIALIZE_AS(@"gcs");

_EXTERN NSString* const kGDataCodeSearchFeed _INITIALIZE_AS(@"http://www.google.com/codesearch/feeds/search");

#import "GDataCodeSearchFile.h"
#import "GDataCodeSearchMatch.h"
#import "GDataCodeSearchPackage.h"

@interface GDataEntryCodeSearch : GDataEntryBase {
}

+ (NSDictionary *)codeSearchNamespaces;

+ (GDataEntryCodeSearch *)codeSearchEntryWithFile:(GDataCodeSearchFile *)file
                                          package:(GDataCodeSearchPackage *)package;

- (GDataCodeSearchFile *)file;
- (void)setFile:(GDataCodeSearchFile *)file;

- (GDataCodeSearchPackage *)package;
- (void)setPackage:(GDataCodeSearchPackage *)package;

- (NSArray *)matches;
- (void)setMatches:(NSArray *)matches;
- (void)addMatch:(GDataCodeSearchMatch *)match;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CODESEARCH_SERVICE
