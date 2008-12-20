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
//  GDataEntrySpreadsheet.h
//

#import "GDataEntryBase.h"


#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATASPREADSHEET_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataSpreadsheetDefaultServiceVersion _INITIALIZE_AS(@"2.0");

_EXTERN NSString* const kGDataNamespaceGSpread _INITIALIZE_AS(@"http://schemas.google.com/spreadsheets/2006");
_EXTERN NSString* const kGDataNamespaceGSpreadPrefix _INITIALIZE_AS(@"gs");

_EXTERN NSString* const kGDataNamespaceGSpreadCustom _INITIALIZE_AS(@"http://schemas.google.com/spreadsheets/2006/extended");
_EXTERN NSString* const kGDataNamespaceGSpreadCustomPrefix _INITIALIZE_AS(@"gsx");

_EXTERN NSString* const kGDataLinkWorksheetsFeed  _INITIALIZE_AS(@"http://schemas.google.com/spreadsheets/2006#worksheetsfeed");
_EXTERN NSString* const kGDataLinkListFeed  _INITIALIZE_AS(@"http://schemas.google.com/spreadsheets/2006#listfeed");
_EXTERN NSString* const kGDataLinkCellsFeed _INITIALIZE_AS(@"http://schemas.google.com/spreadsheets/2006#cellsfeed");
_EXTERN NSString* const kGDataLinkSource    _INITIALIZE_AS(@"http://schemas.google.com/spreadsheets/2006#source"); // cell source

_EXTERN NSString* const kGDataCategorySchemeSpreadsheet    _INITIALIZE_AS(@"http://schemas.google.com/spreadsheets/2006");

_EXTERN NSString* const kGDataCategorySpreadsheet    _INITIALIZE_AS(@"http://schemas.google.com/spreadsheets/2006#spreadsheet");

// SpreadsheetEntry extensions

@interface GDataEntrySpreadsheet : GDataEntryBase {
}

+ (NSDictionary *)spreadsheetNamespaces;

+ (GDataEntrySpreadsheet *)spreadsheetEntry;

// convenience accessors
- (GDataLink *)spreadsheetLink; // link to web version
- (GDataLink *)worksheetsLink;
@end
