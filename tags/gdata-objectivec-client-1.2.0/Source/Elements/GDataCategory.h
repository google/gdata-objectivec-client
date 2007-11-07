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
//  GDataCategory.h
//

#import <Cocoa/Cocoa.h>

#import "GDataObject.h"


// for categories, like
//  <category scheme="http://schemas.google.com/g/2005#kind"
//        term="http://schemas.google.com/g/2005#event"/>
@interface GDataCategory : GDataObject <NSCopying, GDataExtension> {
  NSString *scheme_;
  NSString *term_;
  NSString *label_;
  NSString *labelLang_;
}

+ (GDataCategory *)categoryWithScheme:(NSString *)scheme
                                 term:(NSString *)term;

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent;

- (NSXMLElement *)XMLElement;

- (NSString *)scheme;
- (void)setScheme:(NSString *)str;
- (NSString *)term;
- (void)setTerm:(NSString *)str;
- (NSString *)label;
- (void)setLabel:(NSString *)str;
- (NSString *)labelLang;
- (void)setLabelLang:(NSString *)str;

@end

@interface NSArray(GDataCategoryArray)
// utilities for extracting a subset of categories
- (NSArray *)categoriesWithScheme:(NSString *)scheme;
- (NSArray *)categoriesWithSchemePrefix:(NSString *)prefix;
@end
