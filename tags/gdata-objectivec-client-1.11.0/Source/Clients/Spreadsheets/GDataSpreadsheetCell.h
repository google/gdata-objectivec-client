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
//  GDataSpreadsheetCell.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE

#import "GDataObject.h"

// For spreadsheet cells like:
//   <gs:cell row="2" col="4" inputValue="=FLOOR(R[0]C[-1]/(R[0]C[-2]*60),.0001)"
//            numericValue="0.0033">0.0033</gs:cell>
//
// http://code.google.com/apis/spreadsheets/reference.html#gs_reference

@interface GDataSpreadsheetCell : GDataObject <NSCopying, GDataExtension> {
  NSInteger row_;
  NSInteger column_;
  NSString *inputString_;
  NSNumber *numericValue_;
  NSString *resultString_;
}

+ (GDataSpreadsheetCell *)cellWithRow:(NSInteger)row
                               column:(NSInteger)column
                          inputString:(NSString *)inputStr
                         numericValue:(NSNumber *)numericValue
                         resultString:(NSString *)resultStr;

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent;

- (NSXMLElement *)XMLElement;

- (NSInteger)row;
- (void)setRow:(NSInteger)row;

- (NSInteger)column;
- (void)setColumn:(NSInteger)column;

- (NSString *)inputString;
- (void)setInputString:(NSString *)str;

- (NSNumber *)numericValue;
- (void)setNumericValue:(NSNumber *)num;

- (NSString *)resultString;
- (void)setResultString:(NSString *)str;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE
