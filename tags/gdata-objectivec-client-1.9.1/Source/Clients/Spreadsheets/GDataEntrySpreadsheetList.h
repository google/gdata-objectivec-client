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
//  GDataEntrySpreadsheetList.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE

#import "GDataEntryBase.h"

@class GDataSpreadsheetCustomElement;

// SpreadsheetListEntry extensions

@interface GDataEntrySpreadsheetList : GDataEntryBase

+ (GDataEntrySpreadsheetList *)listEntry;

// extensions
- (NSArray *)customElements; // array of GDataSpreadsheetCustomElement objects
- (void)setCustomElements:(NSArray *)array;
// there is no addCustomElement since that would not guarantee uniqueness;
// call setCustomElement instead

// extra convenience routines for manipulating custom elements
//
// pass nil obj to setCustomElement:forName: to remove the element
- (GDataSpreadsheetCustomElement *)customElementForName:(NSString *)name;
- (void)setCustomElement:(GDataSpreadsheetCustomElement *)obj;
- (NSDictionary *)customElementDictionary; // builds a name:customelement mapping

// ? should we override setTitle/setContent/setSummary as in Java API?

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_SPREADSHEET_SERVICE
