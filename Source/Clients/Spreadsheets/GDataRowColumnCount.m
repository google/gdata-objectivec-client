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
//  GDataColumnCount.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE

#import "GDataRowColumnCount.h"

#import "GDataEntrySpreadsheet.h" // for namespace

// For rowCount and colCount, like:
//   <gs:rowCount>100</gs:rowCount>
//   <gs:colCount>100</gs:colCount>
//
// http://code.google.com/apis/spreadsheets/reference.html#gs_reference

@implementation GDataColumnCount

+ (NSString *)extensionElementURI       { return kGDataNamespaceGSpread; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGSpreadPrefix; }
+ (NSString *)extensionElementLocalName { return @"colCount"; }


+ (GDataColumnCount *)columnCountWithInt:(NSInteger)val {
  GDataColumnCount *obj = [self object];
  [obj setCount:val];
  return obj;
}

@end

@implementation GDataRowCount

+ (NSString *)extensionElementURI       { return kGDataNamespaceGSpread; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGSpreadPrefix; }
+ (NSString *)extensionElementLocalName { return @"rowCount"; }


+ (GDataRowCount *)rowCountWithInt:(NSInteger)val {
  GDataRowCount *obj = [self object];
  [obj setCount:val];
  return obj;
}

@end

@implementation GDataRowColumnCount

- (id)init {
  self = [super init];
  if (self) {
    count_ = -1;
  }
  return self;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    NSString *countStr = [self stringValueFromElement:element];
    if (countStr) {
      [self setCount:[countStr intValue]];      
    }
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataRowColumnCount* newObj = [super copyWithZone:zone];
  [newObj setCount:[self count]];
  return newObj;
}

- (BOOL)isEqual:(GDataRowColumnCount *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataRowColumnCount class]]) return NO;
  
  return [super isEqual:other]
    && ([self count] == [other count]);
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  NSString *str = [NSString stringWithFormat:@"%ld", (long) [self count]];
  [self addToArray:items objectDescriptionIfNonNil:str withName:@"count"];
  
  return items;
}
#endif

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"gs:count"];
  
  NSInteger count = [self count];
  if (count >= 0) {
    NSString *str = [NSString stringWithFormat:@"%ld", (long) [self count]];
    [element addStringValue:str];
  }
  
  return element;
}

- (NSInteger)count {
  return count_; 
}

- (void)setCount:(NSInteger)val {
  count_ = val; 
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE
