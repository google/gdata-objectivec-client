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
//  GDataSpreadsheetData.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE

#import "GDataObject.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATASPREADSHEETDATA_DEFINE_GLOBALS
#define _EXTERN
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataSpreadsheetModeInsert    _INITIALIZE_AS(@"insert");
_EXTERN NSString* const kGDataSpreadsheetModeOverwrite _INITIALIZE_AS(@"overwrite");

// For table data, like
//  <gs:data startRow="2" numRows="6" >
//    <gs:column index="a" name="Name" />
//    <gs:column index="b" name="Birthday" />
//  </gs:data>

@class GDataSpreadsheetColumn;

@interface GDataSpreadsheetData : GDataObject <GDataExtension>

+ (GDataSpreadsheetData *)spreadsheetDataWithStartIndex:(int)startRow
                                           numberOfRows:(int)numRows
                                          insertionMode:(NSString *)insertionMode;

- (NSNumber *)startIndex; // int
- (void)setStartIndex:(NSNumber *)num;

- (NSNumber *)numberOfRows; // int
- (void)setNumberOfRows:(NSNumber *)num;

- (NSString *)insertionMode;
- (void)setInsertionMode:(NSString *)str;

- (NSArray *)columns;
- (void)setColumns:(NSArray *)array;
- (void)addColumn:(GDataSpreadsheetColumn *)obj;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE
