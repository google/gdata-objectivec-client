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
//  GDataEntryWorksheet.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE

#import "GDataEntryBase.h"


#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAENTRYWORKSHEET_DEFINE_GLOBALS
#define _EXTERN
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN GDATA_EXTERN
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataCategoryWorksheet _INITIALIZE_AS(@"http://schemas.google.com/spreadsheets/2006#worksheet");

// WorksheetEntry extensions

@interface GDataEntryWorksheet : GDataEntryBase

+ (GDataEntryWorksheet *)worksheetEntry;

// Hard upper bound of rows and columns, perhaps including
// empty rows and columns.
- (NSInteger)rowCount;
- (void)setRowCount:(NSInteger)val;

- (NSInteger)columnCount;
- (void)setColumnCount:(NSInteger)val;

// convenience accessors
- (GDataLink *)cellsLink;
- (NSURL *)listFeedURL;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE
