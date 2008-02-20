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

#import "GDataEntrySpreadsheetCell.h"
#import "GDataEntrySpreadsheet.h"
#import "GDataFeedSpreadsheetCell.h"
#import "GDataCategory.h"
#import "GDataRowColumnCount.h"

@implementation GDataFeedSpreadsheetCell

+ (GDataFeedSpreadsheetCell *)spreadsheetCellFeedWithXMLData:(NSData *)data {
  return [[[self alloc] initWithData:data] autorelease];
}

+ (GDataFeedSpreadsheetCell *)spreadsheetCellFeed {
  GDataFeedSpreadsheetCell *feed = [[[self alloc] init] autorelease];
  [feed setNamespaces:[GDataEntrySpreadsheet spreadsheetNamespaces]];
  return feed;
}

#pragma mark -

+ (void)load {
  [GDataObject registerFeedClass:[self class]
           forCategoryWithScheme:nil
                            term:kGDataCategorySpreadsheetCell];
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

- (id)init {
  self = [super init];
  if (self) {
    [self addCategory:[GDataCategory categoryWithScheme:kGDataCategorySchemeSpreadsheet
                                                   term:kGDataCategorySpreadsheetCell]];
  }
  return self;
}

- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  NSString *colStr = [NSString stringWithFormat:@"%d", [self columnCount]];
  NSString *rowStr = [NSString stringWithFormat:@"%d", [self rowCount]];
  
  [self addToArray:items objectDescriptionIfNonNil:colStr withName:@"cols"];
  [self addToArray:items objectDescriptionIfNonNil:rowStr withName:@"rows"];
  
  return items;
}

- (Class)classForEntries {
  return [GDataEntrySpreadsheetCell class];
}

#pragma mark -

- (int)rowCount {
  GDataRowCount *rowCount = 
    (GDataRowCount *) [self objectForExtensionClass:[GDataRowCount class]];
  
  return [rowCount count];
}

- (int)columnCount {
  GDataColumnCount *columnCount = 
    (GDataColumnCount *) [self objectForExtensionClass:[GDataColumnCount class]];
  
  return [columnCount count];
}



@end
