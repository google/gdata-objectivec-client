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
//  GDataEntrySpreadsheetList.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE

#import "GDataEntrySpreadsheetList.h"
#import "GDataSpreadsheetConstants.h"
#import "GDataSpreadsheetCustomElement.h"

@implementation GDataEntrySpreadsheetList

+ (NSString *)coreProtocolVersionForServiceVersion:(NSString *)serviceVersion {
  return [GDataSpreadsheetConstants coreProtocolVersionForServiceVersion:serviceVersion];
}

+ (GDataEntrySpreadsheetList *)listEntry {
  GDataEntrySpreadsheetList *entry = [[[self alloc] init] autorelease];

  [entry setNamespaces:[GDataSpreadsheetConstants spreadsheetNamespaces]];
  return entry;
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
  [GDataEntryBase registerEntryClass:[self class]
               forCategoryWithScheme:nil 
                                term:kGDataCategorySpreadsheetList];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];
  
  
  // SpreadsheetList extensions
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataSpreadsheetCustomElement class]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  // make a string of custom elements like {a:b, c:d}
  NSMutableString *str = [NSMutableString string];
  NSArray *customElements = [self customElements];
  NSEnumerator *elementEnumerator = [customElements objectEnumerator];
  GDataSpreadsheetCustomElement *obj;
  
  while ((obj = [elementEnumerator nextObject]) != nil) {
    [str appendFormat:@"%@%@:%@", ([str length] == 0 ? @"" : @" "),
      [obj name], [obj stringValue]];
  }
  
  if ([str length] > 0) {
    [self addToArray:items objectDescriptionIfNonNil:str withName:@"customElements"];
  }
  
  return items;
}
#endif

- (id)init {
  self = [super init];
  if (self) {
    [self addCategory:[GDataCategory categoryWithScheme:kGDataCategorySchemeSpreadsheet
                                                   term:kGDataCategorySpreadsheetList]];
  }
  return self;
}

+ (NSString *)defaultServiceVersion {
  return kGDataSpreadsheetDefaultServiceVersion;
}

#pragma mark -

- (NSArray *)customElements {
  return [self objectsForExtensionClass:[GDataSpreadsheetCustomElement class]];
}

- (void)setCustomElements:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataSpreadsheetCustomElement class]];
}

// there is no addCustomElement since that would not guarantee uniqueness;
// call setCustomElement instead

// additional convenience routines

- (GDataSpreadsheetCustomElement *)customElementForName:(NSString *)name {
  
  // look through the elements for a matching name, not case sensitive
  NSArray *customElements = [self customElements];
  
  NSEnumerator *elementEnumerator = [customElements objectEnumerator];
  GDataSpreadsheetCustomElement *obj;
  while ((obj = [elementEnumerator nextObject]) != nil) {
    
    if ([[obj name] caseInsensitiveCompare:name] == NSOrderedSame) {
      return obj;
    }
  }
  return nil;
}

- (void)setCustomElement:(GDataSpreadsheetCustomElement *)obj {
  
  NSString *name = [obj name];
  GDataSpreadsheetCustomElement *oldObj = [self customElementForName:name];
  if (obj != oldObj) {
    
    if (oldObj) {
      [self removeObject:oldObj forExtensionClass:[GDataSpreadsheetCustomElement class]];
    }
    
    if (obj) {
      [self addObject:obj forExtensionClass:[GDataSpreadsheetCustomElement class]];
    }
  }
}

- (NSDictionary *)customElementDictionary {
  
  // step through the custom elements, and build a dictionary 
  // mapping object names to objects
  NSArray *customElements = [self customElements];
  
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  NSEnumerator *elementEnumerator = [customElements objectEnumerator];
  GDataSpreadsheetCustomElement *obj;
  
  while ((obj = [elementEnumerator nextObject]) != nil) {
    [dict setObject:obj forKey:[obj name]];
  }
  return dict;  
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE
