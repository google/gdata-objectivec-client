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
//  GDataEntrySpreadsheetDoc.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE

#import "GDataEntrySpreadsheetDoc.h"

@implementation GDataEntrySpreadsheetDoc

+ (NSString *)standardEntryKind {
  return kGDataCategorySpreadsheetDoc;
}

+ (void)load {
  [self registerEntryClass];
}

// convenience accessors

- (GDataLink *)worksheetsLink {
  // kWorksheetRel is the same as kGDataLinkWorksheetsFeed, but we want
  // to avoid a cross dependency between the doc list and spreadsheet APIs,
  // so the rel is defined explicitly here

  NSString *const kWorksheetRel = @"http://schemas.google.com/spreadsheets/2006#worksheetsfeed";

  return [self linkWithRelAttributeValue:kWorksheetRel];
}

- (GDataLink *)tablesLink {
  NSString *const kTablesRel = @"http://schemas.google.com/spreadsheets/2006#tablesfeed";

  return [self linkWithRelAttributeValue:kTablesRel];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE
