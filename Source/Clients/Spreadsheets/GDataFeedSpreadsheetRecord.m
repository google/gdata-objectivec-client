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
//  GDataFeedSpreadsheetRecord.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE

#import "GDataFeedSpreadsheetRecord.h"
#import "GDataSpreadsheetConstants.h"
#import "GDataEntrySpreadsheetRecord.h"
#import "GDataCategory.h"

@implementation GDataFeedSpreadsheetRecord

+ (NSString *)standardFeedKind {
  return kGDataCategorySpreadsheetRecord;
}

+ (void)load {
  [self registerFeedClass];
}

+ (GDataFeedSpreadsheetRecord *)spreadsheetRecordFeed {
  GDataFeedSpreadsheetRecord *feed = [self object];
  [feed setNamespaces:[GDataSpreadsheetConstants spreadsheetNamespaces]];
  return feed;
}

- (Class)classForEntries {
  return [GDataEntrySpreadsheetRecord class];
}

+ (NSString *)defaultServiceVersion {
  return kGDataSpreadsheetDefaultServiceVersion;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE
