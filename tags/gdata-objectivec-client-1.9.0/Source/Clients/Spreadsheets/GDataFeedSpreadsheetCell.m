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
//  GDataFeedSpreadsheetCell.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE

#import "GDataEntrySpreadsheetCell.h"
#import "GDataSpreadsheetConstants.h"
#import "GDataFeedSpreadsheetCell.h"
#import "GDataCategory.h"
#import "GDataRowColumnCount.h"

@implementation GDataFeedSpreadsheetCell

+ (NSString *)coreProtocolVersionForServiceVersion:(NSString *)serviceVersion {
  return [GDataSpreadsheetConstants coreProtocolVersionForServiceVersion:serviceVersion];
}

+ (GDataFeedSpreadsheetCell *)spreadsheetCellFeedWithXMLData:(NSData *)data {
  return [[[self alloc] initWithData:data] autorelease];
}

+ (GDataFeedSpreadsheetCell *)spreadsheetCellFeed {
  GDataFeedSpreadsheetCell *feed = [[[self alloc] init] autorelease];
  [feed setNamespaces:[GDataSpreadsheetConstants spreadsheetNamespaces]];
  return feed;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  // spreadsheet categories do not use the standard Kind scheme
  // (kGDataCategoryScheme) so cannot be init'd by GDataEntryBase
  return nil;
}

+ (void)load {
  // spreadsheet categories do not use the standard Kind scheme
  // (kGDataCategoryScheme) so cannot be registered with +registerEntryClass
  [GDataFeedBase registerFeedClass:[self class]
             forCategoryWithScheme:nil
                              term:kGDataCategorySpreadsheetCell];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];
  
  
  // Worksheet extensions
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClasses:
   [GDataColumnCount class],
   [GDataRowCount class],
   nil];  
}

- (id)init {
  self = [super init];
  if (self) {
    [self addCategory:[GDataCategory categoryWithScheme:kGDataCategorySchemeSpreadsheet
                                                   term:kGDataCategorySpreadsheetCell]];
  }
  return self;
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  NSString *colStr = [NSString stringWithFormat:@"%d", [self columnCount]];
  NSString *rowStr = [NSString stringWithFormat:@"%d", [self rowCount]];
  
  [self addToArray:items objectDescriptionIfNonNil:colStr withName:@"cols"];
  [self addToArray:items objectDescriptionIfNonNil:rowStr withName:@"rows"];
  
  return items;
}
#endif

- (Class)classForEntries {
  return [GDataEntrySpreadsheetCell class];
}

+ (NSString *)defaultServiceVersion {
  return kGDataSpreadsheetDefaultServiceVersion;
}

#pragma mark -

- (NSInteger)rowCount {
  GDataRowCount *rowCount = 
    (GDataRowCount *) [self objectForExtensionClass:[GDataRowCount class]];
  
  return [rowCount count];
}

- (NSInteger)columnCount {
  GDataColumnCount *columnCount = 
    (GDataColumnCount *) [self objectForExtensionClass:[GDataColumnCount class]];
  
  return [columnCount count];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE
