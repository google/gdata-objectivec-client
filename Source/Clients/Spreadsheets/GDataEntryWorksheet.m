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
//  GDataEntryWorksheet.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE

#define GDATAENTRYWORKSHEET_DEFINE_GLOBALS 1

#import "GDataEntryWorksheet.h"
#import "GDataSpreadsheetConstants.h"
#import "GDataRowColumnCount.h"


@implementation GDataEntryWorksheet


+ (GDataEntryWorksheet *)worksheetEntry {
  GDataEntryWorksheet *entry = [[[GDataEntryWorksheet alloc] init] autorelease];

  [entry setNamespaces:[GDataSpreadsheetConstants spreadsheetNamespaces]];
  return entry;
}

#pragma mark -

+ (NSString *)coreProtocolVersionForServiceVersion:(NSString *)serviceVersion {
  return [GDataSpreadsheetConstants coreProtocolVersionForServiceVersion:serviceVersion];
}

+ (NSString *)standardEntryKind {
  // spreadsheet categories do not use the standard Kind scheme
  // (kGDataCategoryScheme) so cannot be init'd by GDataEntryBase
  return nil;
}

+ (void)load {
  // spreadsheet categories do not use the standard Kind scheme
  // (kGDataCategoryScheme) so cannot be registered with +registerEntryClass
  [GDataEntryBase registerEntryClass:[self class]
               forCategoryWithScheme:kGDataCategorySchemeSpreadsheet 
                                term:kGDataCategoryWorksheet];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];
  
  // Worksheet extensions
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataColumnCount class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataRowCount class]];  
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

- (id)init {
  self = [super init];
  if (self) {
    [self addCategory:[GDataCategory categoryWithScheme:kGDataCategorySchemeSpreadsheet
                                                   term:kGDataCategoryWorksheet]];

    // set a default row & column count, as in the Java
    [self setRowCount:100];
    [self setColumnCount:20];
  }
  return self;
}

+ (NSString *)defaultServiceVersion {
  return kGDataSpreadsheetDefaultServiceVersion;
}

#pragma mark -

- (NSInteger)rowCount {
  GDataRowCount *rowCount = [self objectForExtensionClass:[GDataRowCount class]];
  
  return [rowCount count];
}

- (void)setRowCount:(NSInteger)val {
  GDataRowCount *obj = [GDataRowCount rowCountWithInt:val];
  [self setObject:obj forExtensionClass:[GDataRowCount class]];
}

- (NSInteger)columnCount {
  GDataColumnCount *columnCount = [self objectForExtensionClass:[GDataColumnCount class]];
  
  return [columnCount count];
}

- (void)setColumnCount:(NSInteger)val {
  GDataColumnCount *obj = [GDataColumnCount columnCountWithInt:val];
  [self setObject:obj forExtensionClass:[GDataColumnCount class]];
}

#pragma mark -

- (GDataLink *)spreadsheetLink {
  return [self alternateLink]; 
}

- (GDataLink *)cellsLink {
  return [self linkWithRelAttributeValue:kGDataLinkCellsFeed];
}

- (NSURL *)listFeedURL {

  // the worksheets feed URL is the URI in the entry's content element
  GDataEntryContent *content = [self content];

  if ([[content type] hasPrefix:@"application/atom+xml"]) {
    return [content sourceURL];
  }

  // prior to V2 feeds, the URL is in a link
  return [[self linkWithRelAttributeValue:kGDataLinkListFeed] URL];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE
