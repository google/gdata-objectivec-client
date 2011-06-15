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
//  GDataSpreadsheetCell.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE

#import "GDataSpreadsheetCell.h"

#import "GDataEntrySpreadsheet.h" // for namespaces

@implementation GDataSpreadsheetCell

// For spreadsheet cells like:
//   <gs:cell row="2" col="4" inputValue="=FLOOR(R[0]C[-1]/(R[0]C[-2]*60),.0001)"
//            numericValue="0.0033">0.0033</gs:cell>
//
// http://code.google.com/apis/spreadsheets/reference.html#gs_reference

+ (NSString *)extensionElementURI       { return kGDataNamespaceGSpread; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGSpreadPrefix; }
+ (NSString *)extensionElementLocalName { return @"cell"; }

+ (GDataSpreadsheetCell *)cellWithRow:(NSInteger)row
                               column:(NSInteger)column
                          inputString:(NSString *)inputStr
                         numericValue:(NSNumber *)numericValue
                         resultString:(NSString *)resultStr {
  
  GDataSpreadsheetCell *obj = [self object];
  [obj setRow:row];
  [obj setColumn:column];
  [obj setInputString:inputStr];
  [obj setNumericValue:numericValue];
  [obj setResultString:resultStr];
  return obj;
}

- (id)init {
  self = [super init];
  if (self) {
    row_ = -1;
    column_ = -1;
  }
  return self;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    NSString *rowStr = [self stringForAttributeName:@"row"
                                        fromElement:element];
    if (rowStr) {
      [self setRow:[rowStr intValue]];
    }

    NSString *columnStr = [self stringForAttributeName:@"col"
                                        fromElement:element];
    if (columnStr) {
      [self setColumn:[columnStr intValue]];
    }

    [self setInputString:[self stringForAttributeName:@"inputValue"
                                          fromElement:element]];

    [self setNumericValue:[self doubleNumberForAttributeName:@"numericValue"
                                                 fromElement:element]];
      
    [self setResultString:[self stringValueFromElement:element]];

  }
  return self;
}

- (void)dealloc {
  [inputString_ release];
  [numericValue_ release];
  [resultString_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataSpreadsheetCell* newObj = [super copyWithZone:zone];
  [newObj setRow:[self row]];
  [newObj setColumn:[self column]];
  [newObj setInputString:[self inputString]];
  [newObj setNumericValue:[self numericValue]];
  [newObj setResultString:[self resultString]];
  return newObj;
}

- (BOOL)isEqual:(GDataSpreadsheetCell *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataSpreadsheetCell class]]) return NO;
  
  return [super isEqual:other]
    && ([self row] == [other row])
    && ([self column] == [other column])
    && AreEqualOrBothNil([self inputString], [other inputString])
    && AreEqualOrBothNil([self numericValue], [other numericValue])
    && AreEqualOrBothNil([self resultString], [other resultString]);
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:inputString_ withName:@"inputString"];
  [self addToArray:items objectDescriptionIfNonNil:numericValue_ withName:@"numericValue"];
  [self addToArray:items objectDescriptionIfNonNil:resultString_ withName:@"resultString"];
  
  return items;
}
#endif

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"gs:cell"];

  if (row_ > 0) {
    [self addToElement:element attributeValueWithInteger:row_ withName:@"row"];
  }
  if (column_ > 0) {
    [self addToElement:element attributeValueWithInteger:column_ withName:@"col"];
  }
  
  [self addToElement:element attributeValueIfNonNil:inputString_ withName:@"inputValue"];

  [self addToElement:element
 attributeValueIfNonNil:[numericValue_ stringValue]
            withName:@"numericValue"];

  if ([resultString_ length] > 0) {
    [element addStringValue:resultString_]; 
  }
    
  return element;
}

- (NSInteger)row {
  return row_; 
}
- (void)setRow:(NSInteger)row {
  row_ = row; 
}

- (NSInteger)column {
  return column_; 
}
- (void)setColumn:(NSInteger)column {
  column_ = column; 
}

- (NSString *)inputString {
  return inputString_; 
}
- (void)setInputString:(NSString *)str {
  [inputString_ autorelease];
  inputString_ = [str copy];
}

- (NSNumber *)numericValue {
  return numericValue_;
}
- (void)setNumericValue:(NSNumber *)num {
  [numericValue_ autorelease];
  numericValue_ = [num copy]; 
}

- (NSString *)resultString {
  return resultString_; 
}
- (void)setResultString:(NSString *)str {
  [resultString_ autorelease];
  resultString_ = [str copy];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE
