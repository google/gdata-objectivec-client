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
//  GDataQueryDocument.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE

#import "GDataQuery.h"

// Document-specific query params, per 
//   http://code.google.com/apis/document/reference.html#Parameters

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAQUERYDOCS_DEFINE_GLOBALS
#define _EXTERN
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

// sort orders
_EXTERN NSString* const kGDataQueryDocsLastModified _INITIALIZE_AS(@"last-modified");
_EXTERN NSString* const kGDataQueryDocsLastViewed   _INITIALIZE_AS(@"last-viewed");
_EXTERN NSString* const kGDataQueryDocsTitle        _INITIALIZE_AS(@"title");
_EXTERN NSString* const kGDataQueryDocsStarred      _INITIALIZE_AS(@"starred");


@interface GDataQueryDocs : GDataQuery 

+ (GDataQueryDocs *)documentQueryWithFeedURL:(NSURL *)feedURL;

- (NSString *)titleQuery;
- (void)setTitleQuery:(NSString *)str;

// non-exact title searches are keyword-based; exact title searches are literal
- (BOOL)isTitleQueryExact;
- (void)setIsTitleQueryExact:(BOOL)flag;

- (NSString *)parentFolderName;
- (void)setParentFolderName:(NSString *)str;

- (BOOL)shouldShowFolders;
- (void)setShouldShowFolders:(BOOL)flag;

// owner specified as an e-mail address
- (void)setOwner:(NSString *)str;
- (NSString *)owner;

// reader and writer specified as an e-mail address or comma-separated list
// of e-mail addresses
- (void)setReader:(NSString *)str;
- (NSString *)reader;

- (void)setWriter:(NSString *)str;
- (NSString *)writer;

- (void)setOpenedMinDateTime:(GDataDateTime *)dateTime;
- (GDataDateTime *)openedMinDateTime;

- (void)setOpenedMaxDateTime:(GDataDateTime *)dateTime;
- (GDataDateTime *)openedMaxDateTime;

- (void)setEditedMinDateTime:(GDataDateTime *)dateTime;
- (GDataDateTime *)editedMinDateTime;

- (void)setEditedMaxDateTime:(GDataDateTime *)dateTime;
- (GDataDateTime *)editedMaxDateTime;

// delete a document when deleting (default is moving to the trash on deleting)
- (void)setShouldActuallyDelete:(BOOL)flag;
- (BOOL)shouldActuallyDelete;

// uploading parameters
- (void)setShouldConvertUpload:(BOOL)flag;
- (BOOL)shouldConvertUpload;

- (void)setShouldOCRUpload:(BOOL)flag;
- (BOOL)shouldOCRUpload;

- (NSString *)sourceLanguage;
- (void)setSourceLanguage:(NSString *)str;

- (NSString *)targetLanguage;
- (void)setTargetLanguage:(NSString *)str;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE
