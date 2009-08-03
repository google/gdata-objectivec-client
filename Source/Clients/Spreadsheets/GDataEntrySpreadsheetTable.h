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
//  GDataEntrySpreadsheetTable.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE

#import "GDataEntryBase.h"

@class GDataSpreadsheetData;
@class GDataSpreadsheetHeader;

@interface GDataWorksheetName : GDataValueConstruct <GDataExtension>
// Worksheet name, like <gs:worksheet name="MySheet" />
//
// The worksheet name element is used when inserting a table entry
+ (GDataWorksheetName *)worksheetNameWithString:(NSString *)str;
@end


@interface GDataEntrySpreadsheetTable : GDataEntryBase
+ (GDataEntrySpreadsheetTable *)tableEntry;

- (GDataSpreadsheetData *)spreadsheetData;
- (void)setSpreadsheetData:(GDataSpreadsheetData *)obj;

- (GDataSpreadsheetHeader *)spreadsheetHeader;
- (void)setSpreadsheetHeader:(GDataSpreadsheetHeader *)obj;
- (void)setSpreadsheetHeaderWithRow:(int)row;

- (GDataWorksheetName *)worksheetName;
- (void)setWorksheetName:(GDataWorksheetName *)obj;
- (void)setWorksheetNameWithString:(NSString *)str;

// convenience accessor
- (NSURL *)recordFeedURL;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE
