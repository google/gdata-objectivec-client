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
//  GDataEntrySpreadsheetRecord.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE

#import "GDataEntrySpreadsheetRecord.h"

#import "GDataSpreadsheetConstants.h"
#import "GDataSpreadsheetField.h"

@implementation GDataEntrySpreadsheetRecord

+ (GDataEntrySpreadsheetRecord *)recordEntry {

  GDataEntrySpreadsheetRecord *entry = [[[self alloc] init] autorelease];

  [entry setNamespaces:[GDataSpreadsheetConstants spreadsheetNamespaces]];
  return entry;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategorySpreadsheetRecord;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  Class entryClass = [self class];

  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataSpreadsheetField class]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  static struct GDataDescriptionRecord descRecs[] = {
    { @"fields", @"fields", kGDataDescArrayCount },
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

- (NSArray *)fields {
  return [self objectsForExtensionClass:[GDataSpreadsheetField class]];
}

- (void)setFields:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataSpreadsheetField class]];
}

- (void)addField:(GDataSpreadsheetField *)obj {
  [self addObject:obj forExtensionClass:[GDataSpreadsheetField class]];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE
