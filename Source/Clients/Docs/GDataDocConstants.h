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
//  GDataDocConstants.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE

#import <Foundation/Foundation.h>

#import "GDataDefines.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATADOCCONSTANTS_DEFINE_GLOBALS
#define _EXTERN
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN GDATA_EXTERN
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataDocsServiceV2             _INITIALIZE_AS(@"2.0");
_EXTERN NSString* const kGDataDocsServiceV3             _INITIALIZE_AS(@"3.0");
_EXTERN NSString* const kGDataDocsDefaultServiceVersion _INITIALIZE_AS(@"3.0");

_EXTERN NSString* const kGDataNamespaceDocuments        _INITIALIZE_AS(@"http://schemas.google.com/docs/2007");
_EXTERN NSString* const kGDataNamespaceDocumentsPrefix  _INITIALIZE_AS(@"docs");

_EXTERN NSString* const kGDataCategoryDocFolders        _INITIALIZE_AS(@"http://schemas.google.com/docs/2007/folders");
_EXTERN NSString* const kGDataCategoryDocParent         _INITIALIZE_AS(@"http://schemas.google.com/docs/2007#parent");

_EXTERN NSString* const kGDataCategoryDrawingDoc        _INITIALIZE_AS(@"http://schemas.google.com/docs/2007#drawing");
_EXTERN NSString* const kGDataCategoryFolderDoc         _INITIALIZE_AS(@"http://schemas.google.com/docs/2007#folder");
_EXTERN NSString* const kGDataCategoryFileDoc           _INITIALIZE_AS(@"http://schemas.google.com/docs/2007#file");
_EXTERN NSString* const kGDataCategoryPDFDoc            _INITIALIZE_AS(@"http://schemas.google.com/docs/2007#pdf");
_EXTERN NSString* const kGDataCategoryPresentationDoc   _INITIALIZE_AS(@"http://schemas.google.com/docs/2007#presentation");
_EXTERN NSString* const kGDataCategorySiteDoc           _INITIALIZE_AS(@"http://schemas.google.com/docs/2007#site");
_EXTERN NSString* const kGDataCategorySpreadsheetDoc    _INITIALIZE_AS(@"http://schemas.google.com/docs/2007#spreadsheet");
_EXTERN NSString* const kGDataCategoryStandardDoc       _INITIALIZE_AS(@"http://schemas.google.com/docs/2007#document");
_EXTERN NSString* const kGDataCategoryTableDoc          _INITIALIZE_AS(@"http://schemas.google.com/docs/2007#table");

_EXTERN NSString* const kGDataCategoryDocChange        _INITIALIZE_AS(@"http://schemas.google.com/docs/2007#change"); // used for deleted documents

_EXTERN NSString* const kGDataCategoryDocListMetadata   _INITIALIZE_AS(@"http://schemas.google.com/docs/2007#metadata");

_EXTERN NSString* const kGDataCategoryDocItem           _INITIALIZE_AS(@"http://schemas.google.com/docs/2007#item");
_EXTERN NSString* const kGDataCategoryDocRevision       _INITIALIZE_AS(@"http://schemas.google.com/docs/2007#revision");

_EXTERN NSString* const kGDataDocsPublishedRel          _INITIALIZE_AS(@"http://schemas.google.com/docs/2007#publish");
_EXTERN NSString* const kGDataDocsRevisionsRel          _INITIALIZE_AS(@"http://schemas.google.com/docs/2007/revisions");
_EXTERN NSString* const kGDataDocsThumbnailRel          _INITIALIZE_AS(@"http://schemas.google.com/docs/2007/thumbnail");
_EXTERN NSString* const kGDataDocsAlternateSelfRel      _INITIALIZE_AS(@"http://schemas.google.com/docs/2007#alt-self");

_EXTERN NSString* const kGDataDocsRootFolderHref        _INITIALIZE_AS(@"https://docs.google.com/feeds/default/private/full/folder%3Aroot");

_EXTERN NSString* const kGDataDocsFeatureNameOCR         _INITIALIZE_AS(@"ocr");
_EXTERN NSString* const kGDataDocsFeatureNameTranslation _INITIALIZE_AS(@"translation");
_EXTERN NSString* const kGDataDocsFeatureNameUploadAny   _INITIALIZE_AS(@"upload_any");

@interface GDataDocConstants : NSObject

+ (NSString *)coreProtocolVersionForServiceVersion:(NSString *)serviceVersion;

+ (NSDictionary *)baseDocumentNamespaces;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE
