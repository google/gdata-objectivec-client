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
//  GDataFeedSpreadsheet.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE

#import "GDataEntrySpreadsheet.h"
#import "GDataFeedSpreadsheet.h"
#import "GDataCategory.h"

@implementation GDataFeedSpreadsheet

+ (NSString *)coreProtocolVersionForServiceVersion:(NSString *)serviceVersion {
  return [GDataSpreadsheetConstants coreProtocolVersionForServiceVersion:serviceVersion];
}

+ (NSString *)standardFeedKind {
  // spreadsheet categories do not use the standard Kind scheme
  // (kGDataCategoryScheme) so cannot be init'd by GDataFeedBase
  return nil;
}

+ (void)load {
  // spreadsheet categories do not use the standard Kind scheme
  // (kGDataCategoryScheme) so cannot be registered with +registerEntryClass
  [GDataFeedBase registerFeedClass:[self class]
             forCategoryWithScheme:nil 
                              term:kGDataCategorySpreadsheet];
}

+ (GDataFeedSpreadsheet *)spreadsheetFeedWithXMLData:(NSData *)data {
  return [[[self alloc] initWithData:data] autorelease];
}

+ (GDataFeedSpreadsheet *)spreadsheetFeed {
  GDataFeedSpreadsheet *feed = [[[self alloc] init] autorelease];
  [feed setNamespaces:[GDataSpreadsheetConstants spreadsheetNamespaces]];
  return feed;
}

- (id)init {
  self = [super init];
  if (self) {
    [self addCategory:[GDataCategory categoryWithScheme:kGDataCategorySchemeSpreadsheet
                                                   term:kGDataCategorySpreadsheet]];
  }
  return self;
}

- (Class)classForEntries {
  return [GDataEntrySpreadsheet class];
}

+ (NSString *)defaultServiceVersion {
  return kGDataSpreadsheetDefaultServiceVersion;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE
