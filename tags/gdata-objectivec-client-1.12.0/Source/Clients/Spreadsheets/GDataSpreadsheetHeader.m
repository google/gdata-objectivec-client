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
//  GDataSpreadsheetHeader.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE

#import "GDataSpreadsheetHeader.h"

#import "GDataEntrySpreadsheet.h"

// For spreadsheet header, like
//    <gs:header row="1" />

static NSString* const kRowAttr = @"row";

@implementation GDataSpreadsheetHeader

+ (NSString *)extensionElementURI       { return kGDataNamespaceGSpread; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGSpreadPrefix; }
+ (NSString *)extensionElementLocalName { return @"header"; }

- (NSString *)attributeName {
  return @"row";
}

+ (GDataSpreadsheetHeader *)headerWithRow:(int)row {
  return [self valueWithInt:row];
}

#pragma mark -

- (NSNumber *)row {
  return [self intNumberValue];
}

- (void)setRow:(NSNumber *)str {
  [self setStringValue:[str stringValue]];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE
