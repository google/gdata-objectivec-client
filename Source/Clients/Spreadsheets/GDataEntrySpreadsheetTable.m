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
//  GDataEntrySpreadsheetTable.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE

#define GDATAENTRYSPREADSHEETTABLE_DEFINE_GLOBALS 1
#import "GDataEntrySpreadsheetTable.h"

#import "GDataSpreadsheetConstants.h"
#import "GDataSpreadsheetData.h"
#import "GDataSpreadsheetHeader.h"

@implementation GDataWorksheetName

+ (NSString *)extensionElementURI       { return kGDataNamespaceGSpread; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGSpreadPrefix; }
+ (NSString *)extensionElementLocalName { return @"worksheet"; }

- (NSString *)attributeName {
  return @"name";
}

+ (GDataWorksheetName *)worksheetNameWithString:(NSString *)str {
  return [self valueWithString:str];
}

@end

@implementation GDataEntrySpreadsheetTable

+ (GDataEntrySpreadsheetTable *)tableEntry {

  GDataEntrySpreadsheetTable *entry = [[[self alloc] init] autorelease];

  [entry setNamespaces:[GDataSpreadsheetConstants spreadsheetNamespaces]];
  return entry;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategorySpreadsheetTable;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  Class entryClass = [self class];

  [self addExtensionDeclarationForParentClass:entryClass
                                 childClasses:
   [GDataSpreadsheetData class],
   [GDataSpreadsheetHeader class],
   [GDataWorksheetName class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  static struct GDataDescriptionRecord descRecs[] = {
    { @"header",    @"spreadsheetHeader",         kGDataDescValueLabeled },
    { @"data",      @"spreadsheetData",           kGDataDescValueLabeled },
    { @"worksheet", @"worksheetName.stringValue", kGDataDescValueLabeled },
    { nil, nil, 0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

+ (NSString *)defaultServiceVersion {
  return kGDataSpreadsheetDefaultServiceVersion;
}

#pragma mark -

- (GDataSpreadsheetData *)spreadsheetData {
  return [self objectForExtensionClass:[GDataSpreadsheetData class]];
}

- (void)setSpreadsheetData:(GDataSpreadsheetData *)obj {
  [self setObject:obj forExtensionClass:[GDataSpreadsheetData class]];
}

- (GDataSpreadsheetHeader *)spreadsheetHeader {
  return [self objectForExtensionClass:[GDataSpreadsheetHeader class]];
}

- (void)setSpreadsheetHeader:(GDataSpreadsheetHeader *)obj {
  [self setObject:obj forExtensionClass:[GDataSpreadsheetHeader class]];
}

- (void)setSpreadsheetHeaderWithRow:(int)row {
  GDataSpreadsheetHeader *header = [GDataSpreadsheetHeader headerWithRow:row];
  [self setSpreadsheetHeader:header];
}

- (GDataWorksheetName *)worksheetName {
  return [self objectForExtensionClass:[GDataWorksheetName class]];
}

- (void)setWorksheetName:(GDataWorksheetName *)obj {
  [self setObject:obj forExtensionClass:[GDataWorksheetName class]];
}

- (void)setWorksheetNameWithString:(NSString *)str {
  [self setWorksheetName:[GDataWorksheetName worksheetNameWithString:str]];
}

#pragma mark -

- (NSURL *)recordFeedURL {
  GDataEntryContent *content = [self content];
  NSURL *sourceURL = [content sourceURL];
  return sourceURL;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE
