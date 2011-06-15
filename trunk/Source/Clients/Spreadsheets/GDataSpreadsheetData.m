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
//  GDataSpreadsheetData.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE

#define GDATASPREADSHEETDATA_DEFINE_GLOBALS 1
#import "GDataSpreadsheetData.h"

#import "GDataEntrySpreadsheet.h"
#import "GDataSpreadsheetColumn.h"

// For table data, like
//  <gs:data startRow="2" numRows="6" >
//    <gs:column index="a" name="Name" />
//    <gs:column index="b" name="Birthday" />
//  </gs:data>

static NSString* const kInsertionModeAttr = @"insertionMode";
static NSString* const kNumRowsAttr = @"numRows";
static NSString* const kStartRowAttr = @"startRow";

@implementation GDataSpreadsheetData

+ (NSString *)extensionElementURI       { return kGDataNamespaceGSpread; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGSpreadPrefix; }
+ (NSString *)extensionElementLocalName { return @"data"; }

+ (GDataSpreadsheetData *)spreadsheetDataWithStartIndex:(int)startRow
                                           numberOfRows:(int)numRows
                                          insertionMode:(NSString *)insertionMode {

  GDataSpreadsheetData *obj = [self object];

  [obj setStartIndex:[NSNumber numberWithInt:startRow]];
  [obj setNumberOfRows:[NSNumber numberWithInt:numRows]];
  [obj setInsertionMode:insertionMode];
  return obj;
}

- (void)addParseDeclarations {
  NSArray *attrs = [NSArray arrayWithObjects:
                    kStartRowAttr, kNumRowsAttr, kInsertionModeAttr, nil];

  [self addLocalAttributeDeclarations:attrs];
}

- (void)addExtensionDeclarations {
  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataSpreadsheetColumn class]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"columns", @"columns", kGDataDescArrayCount   },
    { nil, nil, (GDataDescRecTypes)0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

#pragma mark Attributes

- (NSNumber *)startIndex {
  return [self intNumberForAttribute:kStartRowAttr];
}

- (void)setStartIndex:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kStartRowAttr];
}

- (NSNumber *)numberOfRows {
  return [self intNumberForAttribute:kNumRowsAttr];
}

- (void)setNumberOfRows:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kNumRowsAttr];
}

- (NSString *)insertionMode {
  return [self stringValueForAttribute:kInsertionModeAttr];
}

- (void)setInsertionMode:(NSString *)str {
  [self setStringValue:str forAttribute:kInsertionModeAttr];
}

#pragma mark Extensions

- (NSArray *)columns {
  return [self objectsForExtensionClass:[GDataSpreadsheetColumn class]];
}

- (void)setColumns:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataSpreadsheetColumn class]];
}

- (void)addColumn:(GDataSpreadsheetColumn *)obj {
  [self addObject:obj forExtensionClass:[GDataSpreadsheetColumn class]];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE
