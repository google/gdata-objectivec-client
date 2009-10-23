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
//  GDataSpreadsheetConstants.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE

#import <Foundation/Foundation.h>

#import "GDataDefines.h"


#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATASPREADSHEETCONSTANTS_DEFINE_GLOBALS
#define _EXTERN
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif


_EXTERN NSString* const kGDataSpreadsheetServiceV2 _INITIALIZE_AS(@"2.0");
_EXTERN NSString* const kGDataSpreadsheetServiceV3 _INITIALIZE_AS(@"3.0");
_EXTERN NSString* const kGDataSpreadsheetDefaultServiceVersion _INITIALIZE_AS(@"3.0");

_EXTERN NSString* const kGDataNamespaceGSpread             _INITIALIZE_AS(@"http://schemas.google.com/spreadsheets/2006");
_EXTERN NSString* const kGDataNamespaceGSpreadPrefix       _INITIALIZE_AS(@"gs");

_EXTERN NSString* const kGDataNamespaceGSpreadCustom       _INITIALIZE_AS(@"http://schemas.google.com/spreadsheets/2006/extended");
_EXTERN NSString* const kGDataNamespaceGSpreadCustomPrefix _INITIALIZE_AS(@"gsx");

_EXTERN NSString* const kGDataNamespaceGViz                _INITIALIZE_AS(@"http://schemas.google.com/visualization/2008");
_EXTERN NSString* const kGDataNamespaceGVizPrefix          _INITIALIZE_AS(@"gviz");

_EXTERN NSString* const kGDataLinkWorksheetsFeed           _INITIALIZE_AS(@"http://schemas.google.com/spreadsheets/2006#worksheetsfeed");
_EXTERN NSString* const kGDataLinkTablesFeed               _INITIALIZE_AS(@"http://schemas.google.com/spreadsheets/2006#tablesfeed");
_EXTERN NSString* const kGDataLinkListFeed                 _INITIALIZE_AS(@"http://schemas.google.com/spreadsheets/2006#listfeed");
_EXTERN NSString* const kGDataLinkCellsFeed                _INITIALIZE_AS(@"http://schemas.google.com/spreadsheets/2006#cellsfeed");
_EXTERN NSString* const kGDataLinkSource                   _INITIALIZE_AS(@"http://schemas.google.com/spreadsheets/2006#source"); // cell source
_EXTERN NSString* const kGDataLinkRecordsFeed              _INITIALIZE_AS(@"http://schemas.google.com/spreadsheets/2006#recordsfeed");
_EXTERN NSString* const kGDataLinkGviz                     _INITIALIZE_AS(@"http://schemas.google.com/visualization/2008#visualizationApi");

_EXTERN NSString* const kGDataCategorySchemeSpreadsheet    _INITIALIZE_AS(@"http://schemas.google.com/spreadsheets/2006");

_EXTERN NSString* const kGDataCategorySpreadsheet          _INITIALIZE_AS(@"http://schemas.google.com/spreadsheets/2006#spreadsheet");
_EXTERN NSString* const kGDataCategorySpreadsheetCell      _INITIALIZE_AS(@"http://schemas.google.com/spreadsheets/2006#cell");
_EXTERN NSString* const kGDataCategorySpreadsheetList      _INITIALIZE_AS(@"http://schemas.google.com/spreadsheets/2006#list");
_EXTERN NSString* const kGDataCategorySpreadsheetRecord    _INITIALIZE_AS(@"http://schemas.google.com/spreadsheets/2006#record");
_EXTERN NSString* const kGDataCategorySpreadsheetTable     _INITIALIZE_AS(@"http://schemas.google.com/spreadsheets/2006#table");

// SpreadsheetEntry extensions

@interface GDataSpreadsheetConstants : NSObject

+ (NSString *)coreProtocolVersionForServiceVersion:(NSString *)serviceVersion;

+ (NSDictionary *)spreadsheetNamespaces;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE
