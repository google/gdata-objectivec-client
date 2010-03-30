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
//  GDataServiceGoogleSpreadsheet.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE

#define GDATASERVICEGOOGLESPREADSHEET_DEFINE_GLOBALS 1
#import "GDataServiceGoogleSpreadsheet.h"

#import "GDataFeedSpreadsheet.h"
#import "GDataSpreadsheetConstants.h"
#import "GDataEntryWorksheet.h"
#import "GDataQuerySpreadsheet.h"


@implementation GDataServiceGoogleSpreadsheet

+ (NSString *)serviceID {
  return @"wise";
}

+ (NSString *)defaultServiceVersion {
  return kGDataSpreadsheetDefaultServiceVersion;
}

+ (NSDictionary *)standardServiceNamespaces {
  return [GDataSpreadsheetConstants spreadsheetNamespaces];
}

+ (NSString *)serviceRootURLString {
  return @"https://spreadsheets.google.com/feeds/";
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE
