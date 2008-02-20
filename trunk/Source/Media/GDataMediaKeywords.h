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
//  GDataMediaKeywords.h
//

#import "GDataObject.h"

// like <media:keywords>kitty, cat, big dog, yarn, fluffy</media:keywords>
// http://search.yahoo.com/mrss

@interface GDataMediaKeywords : GDataObject <NSCopying, GDataExtension> {
  NSMutableArray *keywords_;
}

+ (GDataMediaKeywords *)keywordsWithStrings:(NSArray *)array;

// convenience function taking keywords as a comma-separated list in a
// single string
+ (GDataMediaKeywords *)keywordsWithString:(NSString *)str;

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent;

- (NSXMLElement *)XMLElement;

- (NSArray *)keywords;
- (void)setKeywords:(NSArray *)array;
- (void)addKeyword:(NSString *)keyword;

- (NSString *)stringValue; // comma-separated, for convenience of unit testing

// convenience utilities

// these are used to convert to and from the comma-separated keyword
// list in the element body
+ (NSString *)stringFromKeywords:(NSArray *)keywords;
+ (NSArray *)keywordsFromString:(NSString *)commaSeparatedString;

@end
