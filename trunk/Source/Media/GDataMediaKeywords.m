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
//  GDataMediaKeywords.m
//


#import "GDataMediaKeywords.h"
#import "GDataMediaGroup.h"

@interface GDataMediaKeywords (PrivateMethods)
+ (NSString *)trimString:(NSString *)str;
@end

@implementation GDataMediaKeywords
// like <media:keywords>kitty, cat, big dog, yarn, fluffy</media:keywords>
// http://search.yahoo.com/mrss

+ (NSString *)extensionElementURI       { return kGDataNamespaceMedia; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceMediaPrefix; }
+ (NSString *)extensionElementLocalName { return @"keywords"; }

+ (GDataMediaKeywords *)keywordsWithStrings:(NSArray *)array {
  GDataMediaKeywords* obj = [[[GDataMediaKeywords alloc] init] autorelease];
  [obj setKeywords:array];
  return obj;
}

+ (GDataMediaKeywords *)keywordsWithString:(NSString *)str {
  // takes a string with a comma-separated list of keywords
  GDataMediaKeywords* obj = [[[GDataMediaKeywords alloc] init] autorelease];
  
  NSArray *array = [GDataMediaKeywords keywordsFromString:str];
  [obj setKeywords:array];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    NSString *itemListStr = [self stringValueFromElement:element];
    NSArray *array = [GDataMediaKeywords keywordsFromString:itemListStr];
    
    // keywordsFromString returns nil of there are no non-empty keywords
    [self setKeywords:array]; 
  }
  return self;
}

- (void)dealloc {
  [keywords_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataMediaKeywords* newObj = [super copyWithZone:zone];
  [newObj setKeywords:[GDataUtilities arrayWithCopiesOfObjectsInArray:[self keywords]]];
  return newObj;
}

- (BOOL)isEqual:(GDataMediaKeywords *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataMediaKeywords class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self keywords], [other keywords]);
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  NSString *keywordsStr = [GDataMediaKeywords stringFromKeywords:keywords_];
  // stringFromKeywords returns nil if keywords is nil or empty

  [self addToArray:items objectDescriptionIfNonNil:keywordsStr withName:@"keywords"];

  return items;
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"media:keywords"];
  
  NSString *keywordsStr = [GDataMediaKeywords stringFromKeywords:keywords_];
  // stringFromKeywords returns nil if keywords is nil or empty
  if (keywordsStr) {
    [element addStringValue:keywordsStr];
  }
  
  return element;
}

#pragma mark -

- (NSArray *)keywords {
  return keywords_; 
}

- (void)setKeywords:(NSArray *)array {
  [keywords_ autorelease];
  keywords_ = [array mutableCopy];
}

- (void)addKeyword:(NSString *)str {
  if (!keywords_) {
    keywords_ = [[NSMutableArray alloc] init];
  }
  
  str = [GDataMediaKeywords trimString:str];
  
  if ([str length] > 0) {
    if (! [keywords_ containsObject:str]) {
      [keywords_ addObject:str]; 
    }
  }
}

- (NSString *)stringValue {
  // convenient for unit testing
  NSString *keywordsStr = [GDataMediaKeywords stringFromKeywords:keywords_];
  return keywordsStr;
}

#pragma mark Utilities

+ (NSString *)trimString:(NSString *)str {
  // remove leading and trailing whitespace from the string
  NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  return [str stringByTrimmingCharactersInSet:whitespace];
}

+ (NSArray *)keywordsFromString:(NSString *)commaSeparatedString {
  // split the words into strings at the commas
  NSArray *rawWordArray = [commaSeparatedString componentsSeparatedByString:@","];
  
  NSEnumerator *wordEnum = [rawWordArray objectEnumerator];
  NSString *word;
  NSMutableArray *keywordArray = [NSMutableArray array];
  
  // trim each word in the array, and if a trimmed word is non-empty,
  // add it to the array
  while ((word = [wordEnum nextObject]) != nil) {
    NSString *trimmedWord = [GDataMediaKeywords trimString:word];
    if ([trimmedWord length] > 0) {
      [keywordArray addObject:trimmedWord]; 
    }
  }
  
  // return only non-empty arrays
  if ([keywordArray count] > 0) {
    return keywordArray; 
  }
  return nil;
}

+ (NSString *)stringFromKeywords:(NSArray *)keywords {
  // join keywords with commas; return the string if it's non-empty,
  // or nil otherwise
  if ([keywords count] > 0) {
    return [keywords componentsJoinedByString:@", "];
  }
  return nil;
}
@end


