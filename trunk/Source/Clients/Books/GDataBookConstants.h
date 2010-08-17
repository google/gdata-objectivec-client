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
//  GDataBookConstants.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BOOKS_SERVICE

#import <Foundation/Foundation.h>

#import "GDataDefines.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATABOOKCONSTANTS_DEFINE_GLOBALS
#define _EXTERN
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataBooksDefaultServiceVersion _INITIALIZE_AS(@"2.0");

_EXTERN NSString* const kGDataNamespaceBooks            _INITIALIZE_AS(@"http://schemas.google.com/books/2008");
_EXTERN NSString* const kGDataNamespaceBooksPrefix      _INITIALIZE_AS(@"gbs");

_EXTERN NSString* const kGDataCategoryBooksVolume       _INITIALIZE_AS(@"http://schemas.google.com/books/2008#volume");
_EXTERN NSString* const kGDataCategoryBooksCollection   _INITIALIZE_AS(@"http://schemas.google.com/books/2008#collection");

_EXTERN NSString* const kGDataBooksViewAllPages         _INITIALIZE_AS(@"http://schemas.google.com/books/2008#view_all_pages");
_EXTERN NSString* const kGDataBooksViewNoPages          _INITIALIZE_AS(@"http://schemas.google.com/books/2008#view_no_pages");
_EXTERN NSString* const kGDataBooksViewPartial          _INITIALIZE_AS(@"http://schemas.google.com/books/2008#view_partial");
_EXTERN NSString* const kGDataBooksViewUnknown          _INITIALIZE_AS(@"http://schemas.google.com/books/2008#view_unknown");

_EXTERN NSString* const kGDataBooksEmbeddable           _INITIALIZE_AS(@"http://schemas.google.com/books/2008#embeddable");
_EXTERN NSString* const kGDataBooksNotEmbeddable        _INITIALIZE_AS(@"http://schemas.google.com/books/2008#not_embeddable");

_EXTERN NSString* const kGDataBooksEnabled              _INITIALIZE_AS(@"http://schemas.google.com/books/2008#enabled");
_EXTERN NSString* const kGDataBooksDisabled             _INITIALIZE_AS(@"http://schemas.google.com/books/2008#disabled");

_EXTERN NSString* const kGDataBooksActionChooseBookmark _INITIALIZE_AS(@"ChooseBookmark");
_EXTERN NSString* const kGDataBooksActionSearchInBook   _INITIALIZE_AS(@"SearchWithinBook");
                        // was kGDataBooksActionFindResult
_EXTERN NSString* const kGDataBooksActionNextPage       _INITIALIZE_AS(@"NextPage");
_EXTERN NSString* const kGDataBooksActionPrevPage       _INITIALIZE_AS(@"PrevPage");
_EXTERN NSString* const kGDataBooksActionScrollToPage   _INITIALIZE_AS(@"ScrollToPage");
_EXTERN NSString* const kGDataBooksActionSelectChapter  _INITIALIZE_AS(@"SelectChapter");

_EXTERN NSString* const kGDataBooksInfoRel              _INITIALIZE_AS(@"http://schemas.google.com/books/2008/info");
_EXTERN NSString* const kGDataBooksPreviewRel           _INITIALIZE_AS(@"http://schemas.google.com/books/2008/preview");
_EXTERN NSString* const kGDataBooksThumbnailRel         _INITIALIZE_AS(@"http://schemas.google.com/books/2008/thumbnail");
_EXTERN NSString* const kGDataBooksAnnotationRel        _INITIALIZE_AS(@"http://schemas.google.com/books/2008/annotation");
_EXTERN NSString* const kGDataBooksBuyLinkRel           _INITIALIZE_AS(@"http://schemas.google.com/books/2008/buylink");
_EXTERN NSString* const kGDataBooksEPubDownloadRel      _INITIALIZE_AS(@"http://schemas.google.com/books/2008/epubdownload");
_EXTERN NSString* const kGDataBooksEPubToken            _INITIALIZE_AS(@"http://schemas.google.com/books/2008/acsepubfulfillmenttoken");

_EXTERN NSString* const kGDataBooksLabelsScheme         _INITIALIZE_AS(@"http://schemas.google.com/books/2008/labels");
_EXTERN NSString* const kGDataBooksTypeIDScheme         _INITIALIZE_AS(@"http://schemas.google.com/books/2008/collections#type_id");


@interface GDataBookConstants : NSObject

+ (NSString *)coreProtocolVersionForServiceVersion:(NSString *)serviceVersion;

+ (NSDictionary *)booksNamespaces;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BOOKS_SERVICE
