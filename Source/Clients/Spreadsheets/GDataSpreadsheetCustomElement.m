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

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE

#import "GDataSpreadsheetCustomElement.h"

#import "GDataEntrySpreadsheet.h" // for namespaces

@implementation GDataSpreadsheetCustomElement 

// arbitrary spreadsheet custom tag, like
//  <gsx:e-mail>fitz@gmail.com</gsx:e-mail>
//
// http://code.google.com/apis/spreadsheets/reference.html#gsx_reference

// this object may be an extension, so declare its extension characteristics

+ (NSString *)extensionElementURI       { return kGDataNamespaceGSpreadCustom; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGSpreadCustomPrefix; }
+ (NSString *)extensionElementLocalName { 
  // wildcard * matches all elements with the proper namespace URI
  return @"*"; 
}

+ (GDataSpreadsheetCustomElement *)elementWithName:(NSString *)name
                                       stringValue:(NSString *)stringValue {
  
  GDataSpreadsheetCustomElement *obj = [self object];
  [obj setName:name];
  [obj setStringValue:stringValue];
  
  // we don't want the element to have the default name gsx:*
  [obj setElementName:[NSString stringWithFormat:@"%@:%@", 
    [self extensionElementPrefix], name]];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
        
    name_ = [[element localName] copy];
    stringValue_ = [[self stringValueFromElement:element] copy];
  }
  return self;
}

- (void)dealloc {
  [name_ release];
  [stringValue_ release];
  [super dealloc];
}

#pragma mark -



- (id)copyWithZone:(NSZone *)zone {
  GDataSpreadsheetCustomElement* newObj = [super copyWithZone:zone];
  
  [newObj setName:[self name]];
  [newObj setStringValue:[self stringValue]];
  
  return newObj;
}

- (BOOL)isEqual:(GDataSpreadsheetCustomElement *)other {
  
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataSpreadsheetCustomElement class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self name], [other name])
    && AreEqualOrBothNil([self stringValue], [other stringValue]);
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:name_ withName:@"name"];
  [self addToArray:items objectDescriptionIfNonNil:stringValue_ withName:@"stringValue"];
  
  return items;
}
#endif

- (NSXMLElement *)XMLElement {

  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:[self elementName]];
   
  if (stringValue_) {
    [element addStringValue:stringValue_];
  }
  
  return element;
}

#pragma mark -

- (NSString *)name {
  return name_;
}

- (void)setName:(NSString *)str {
  [name_ autorelease];
  name_ = [str copy];
}

- (NSString *)stringValue {
  return stringValue_;
}

- (void)setStringValue:(NSString *)str {
  [stringValue_ autorelease];
  stringValue_ = [str copy];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE
