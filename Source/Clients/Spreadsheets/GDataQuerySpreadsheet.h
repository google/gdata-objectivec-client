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
//  GDataQuerySpreadsheet.h
//

#import "GDataQuery.h"

@interface GDataQuerySpreadsheet : GDataQuery 

+ (GDataQuerySpreadsheet *)spreadsheetQueryWithFeedURL:(NSURL *)feedURL;

// list feed parameters

// Note: for list feed, setOrderBy: parameter
// can be "position" or "column:column_name"

- (void)setSpreadsheetQuery:(NSString *)queryStr;
- (NSString *)spreadsheetQuery; // sq query

- (void)setIsReverseSort:(BOOL)isReverse;
- (BOOL)isReverseSort;

- (NSString *)titleQuery;
- (void)setTitleQuery:(NSString *)str;

- (BOOL)isTitleQueryExact;
- (void)setIsTitleQueryExact:(BOOL)flag;

// cell feed parameters
- (void)setMinimumRow:(int)val;
- (int)minimumRow;

- (void)setMaximumRow:(int)val;
- (int)maximumRow;

- (void)setMaximumColumn:(int)val;
- (int)maximumColumn;

- (void)setMinimumColumn:(int)val;
- (int)minimumColumn;

- (void)setRange:(NSString *)str;
- (NSString *)range;

- (void)setShouldReturnEmpty:(BOOL)flag;
- (BOOL)shouldReturnEmpty;
@end

