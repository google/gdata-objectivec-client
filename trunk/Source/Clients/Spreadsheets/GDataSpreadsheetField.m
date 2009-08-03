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
//  GDataSpreadsheetField.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE

#import "GDataSpreadsheetField.h"

#import "GDataEntrySpreadsheet.h"

// For table fields, like:
//    <gs:field name="Name">Noah</gs:field>

static NSString* const kNameAttr = @"name";
static NSString* const kIndexAttr = @"index";
static NSString* const kFormulaAttr = @"formula";

@implementation GDataSpreadsheetField

+ (NSString *)extensionElementURI       { return kGDataNamespaceGSpread; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGSpreadPrefix; }
+ (NSString *)extensionElementLocalName { return @"field"; }

+ (GDataSpreadsheetField *)fieldWithName:(NSString *)name
                                   value:(NSString *)value {

  GDataSpreadsheetField *obj = [[[self alloc] init] autorelease];
  [obj setName:name];
  [obj setValue:value];
  return obj;
}

- (void)addParseDeclarations {
  NSArray *attrs = [NSArray arrayWithObjects:
                    kNameAttr, kIndexAttr, kFormulaAttr, nil];

  [self addLocalAttributeDeclarations:attrs];

  [self addContentValueDeclaration];
}


#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"name",    @"name",        kGDataDescValueLabeled },
    { @"index",   @"indexString", kGDataDescValueLabeled },
    { @"formula", @"formula",     kGDataDescValueLabeled },
    { @"value",   @"value",       kGDataDescValueLabeled },
    { nil, nil, 0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

- (NSString *)name {
  return [self stringValueForAttribute:kNameAttr];
}

- (void)setName:(NSString *)str {
  [self setStringValue:str forAttribute:kNameAttr];
}

- (NSString *)indexString {
  return [self stringValueForAttribute:kIndexAttr];
}

- (void)setIndexString:(NSString *)str {
  [self setStringValue:str forAttribute:kIndexAttr];
}

- (NSString *)formula {
  return [self stringValueForAttribute:kFormulaAttr];
}

- (void)setFormula:(NSString *)str {
  [self setStringValue:str forAttribute:kFormulaAttr];
}

- (NSString *)value {
  return [self contentStringValue];
}

- (void)setValue:(NSString *)str {
  [self setContentStringValue:str];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE
