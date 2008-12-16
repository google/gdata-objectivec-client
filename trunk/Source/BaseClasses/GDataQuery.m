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
//  GDataQuery.m
//

#import "GDataQuery.h"

static NSString *const kAuthorParamName  = @"author";
static NSString *const kFullTextQueryStringParamName  = @"q";
static NSString *const kLanguageParamName  = @"hl";
static NSString *const kMaxResultsParamName = @"max-results";
static NSString *const kOrderByParamName  = @"orderby";
static NSString *const kPrettyPrintParamName  = @"prettyprint";
static NSString *const kProtocolVersionParamName  = @"v";
static NSString *const kPublishedMaxParamName  = @"published-max";
static NSString *const kPublishedMinParamName  = @"published-min";
static NSString *const kShowDeletedParamName  = @"showdeleted";
static NSString *const kSortOrderParamName  = @"sortorder";
static NSString *const kStartIndexParamName = @"start-index";
static NSString *const kStrictParamName  = @"strict";
static NSString *const kUpdatedMaxParamName  = @"updated-max";
static NSString *const kUpdatedMinParamName  = @"updated-min";

@implementation GDataCategoryFilter

+ (GDataCategoryFilter *)categoryFilter {
  return [[[self alloc] init] autorelease];  
}

- (void)dealloc {
  [categories_ release];
  [excludeCategories_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataCategoryFilter *newFilter = [[GDataCategoryFilter alloc] init];
  [newFilter setCategories:categories_];
  [newFilter setExcludeCategories:excludeCategories_];
  return newFilter;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@ 0x%lX: {%@}",
    [self class], self, [self stringValue]];
}

- (NSArray *)categories {
  return categories_;  
}

- (void)setCategories:(NSArray *)categories {
  [categories_ autorelease]; 
  categories_ = [categories_ mutableCopy];
}

- (void)addCategory:(GDataCategory *)category {
  if (!categories_) {
    categories_ = [[NSMutableArray alloc] init]; 
  }
  
  [categories_ addObject:category];
}

- (NSArray *)excludeCategories {
  return excludeCategories_;  
}

- (void)setExcludeCategories:(NSArray *)excludeCategories {
  [excludeCategories_ autorelease]; 
  excludeCategories_ = [excludeCategories_ mutableCopy];
}

- (void)addExcludeCategory:(GDataCategory *)excludeCategory {
  if (!excludeCategories_) {
    excludeCategories_ = [[NSMutableArray alloc] init]; 
  }
  
  [excludeCategories_ addObject:excludeCategory];
}

- (NSString *)queryStringForCategory:(GDataCategory *)category {
  
  // precede the category term with {scheme} if there's a scheme
  NSString *prefix = @"";
  NSString *scheme = [category scheme];
  if (scheme) {
    prefix = [NSString stringWithFormat:@"{%@}", scheme];
  }
  
  NSString *term = [category term];
  NSString *result = [NSString stringWithFormat:@"%@%@", prefix, term];
  return result;
}

- (NSString *)stringValue {
  
  NSMutableString *result = [NSMutableString string];
  
  // append include categories
  GDataCategory *cat;
  GDATA_FOREACH(cat, categories_) {
    if ([result length]) {
      [result appendString:@"|"]; 
    }
    [result appendString:[self queryStringForCategory:cat]];
  }

  // append exclude categories, preceded by "-"
  GDATA_FOREACH(cat, excludeCategories_) {
    if ([result length]) {
      [result appendString:@"|"]; 
    }
    [result appendFormat:@"-%@", [self queryStringForCategory:cat]];
  }
  return result;
}

@end

//
// GDataQuery 
// 
@implementation GDataQuery

+ (GDataQuery *)queryWithFeedURL:(NSURL *)feedURL {
  return [[[self alloc] initWithFeedURL:feedURL] autorelease];  
}

- (id)initWithFeedURL:(NSURL *)feedURL {
  self = [super init];
  if (self) {
    [self setFeedURL:feedURL];
  }
  return self;
}

- (void)dealloc {
  [feedURL_ release];
  [categoryFilters_ release];
  [customParameters_ release];
  [super dealloc];
}


- (id)copyWithZone:(NSZone *)zone {
  GDataQuery *query = [[GDataQuery alloc] init];
  [query setFeedURL:feedURL_];
  [query setCategoryFilters:categoryFilters_];
  [query setCustomParameters:customParameters_];
  return query;
}


- (NSString *)description {
 return [NSString stringWithFormat:@"%@ 0x%lX: {%@}",
   [self class], self, [[self URL] absoluteString]];
}

- (NSURL *)feedURL {
  return feedURL_;  
}

- (void)setFeedURL:(NSURL *)feedURL {
  [feedURL_ release]; 
  feedURL_ = [feedURL retain];
}

- (int)startIndex {
  return [self intValueForParameterWithName:kStartIndexParamName
                      missingParameterValue:-1];
}

- (void)setStartIndex:(int)startIndex {
  if (startIndex != -1) {
    [self addCustomParameterWithName:kStartIndexParamName
                            intValue:startIndex];
  } else {
    [self removeCustomParameterWithName:kStartIndexParamName];
  }
}

- (int)maxResults {
  return [self intValueForParameterWithName:kMaxResultsParamName
                      missingParameterValue:-1];
}

- (void)setMaxResults:(int)maxResults {
  if (maxResults != -1) {
    [self addCustomParameterWithName:kMaxResultsParamName
                            intValue:maxResults];
  } else {
    [self removeCustomParameterWithName:kMaxResultsParamName];
  }
}

- (NSString *)fullTextQueryString {
  NSString *str;

  str = [self valueForParameterWithName:kFullTextQueryStringParamName];
  return str;
}

- (void)setFullTextQueryString:(NSString *)str {
  [self addCustomParameterWithName:kFullTextQueryStringParamName
                             value:str];
}

- (NSString *)author {
  NSString *str = [self valueForParameterWithName:kAuthorParamName];
  return str;
}

- (void)setAuthor:(NSString *)str {
  [self addCustomParameterWithName:kAuthorParamName
                             value:str];
}

- (NSString *)orderBy {
  NSString *str = [self valueForParameterWithName:kOrderByParamName];
  return str;
}

- (void)setOrderBy:(NSString *)str {
  [self addCustomParameterWithName:kOrderByParamName
                             value:str];
}

- (BOOL)isAscendingOrder {
  NSString *str = [self valueForParameterWithName:kSortOrderParamName];

  BOOL isAscending = (str != nil)
    && ([str caseInsensitiveCompare:@"ascending"] == NSOrderedSame);

  return isAscending;
}

- (void)setIsAscendingOrder:(BOOL)flag {
  NSString *str = (flag ? @"ascending" : @"descending");

  [self addCustomParameterWithName:kSortOrderParamName
                             value:str];
}

- (BOOL)shouldShowDeleted {
  return [self boolValueForParameterWithName:kShowDeletedParamName
                                defaultValue:NO];
}

- (void)setShouldShowDeleted:(BOOL)flag {
  [self addCustomParameterWithName:kShowDeletedParamName
                         boolValue:flag
                      defaultValue:NO];
}

- (BOOL)isStrict {
  return [self boolValueForParameterWithName:kStrictParamName
                                defaultValue:NO];
}

- (void)setIsStrict:(BOOL)flag {
  [self addCustomParameterWithName:kStrictParamName
                         boolValue:flag
                      defaultValue:NO];
}

- (BOOL)shouldPrettyPrint {
  return [self boolValueForParameterWithName:kPrettyPrintParamName
                                defaultValue:NO];
}

- (void)setShouldPrettyPrint:(BOOL)flag {
  [self addCustomParameterWithName:kPrettyPrintParamName
                         boolValue:flag
                      defaultValue:NO];
}

- (NSString *)protocolVersion {
  return [self valueForParameterWithName:kProtocolVersionParamName];
}

- (void)setProtocolVersion:(NSString *)str {
  [self addCustomParameterWithName:kProtocolVersionParamName
                             value:str];
}

- (NSString *)language {
  return [self valueForParameterWithName:kLanguageParamName];
}

- (void)setLanguage:(NSString *)str {
  [self addCustomParameterWithName:kLanguageParamName
                             value:str];
}

- (GDataDateTime *)publishedMinDateTime {
  return [self dateTimeForParameterWithName:kPublishedMinParamName];
}

- (void)setPublishedMinDateTime:(GDataDateTime *)dateTime {
  [self addCustomParameterWithName:kPublishedMinParamName
                          dateTime:dateTime];
}

- (GDataDateTime *)publishedMaxDateTime {
  return [self dateTimeForParameterWithName:kPublishedMaxParamName];
}

- (void)setPublishedMaxDateTime:(GDataDateTime *)dateTime {
  [self addCustomParameterWithName:kPublishedMaxParamName
                          dateTime:dateTime];
}

- (GDataDateTime *)updatedMinDateTime {
  return [self dateTimeForParameterWithName:kUpdatedMinParamName];
}

- (void)setUpdatedMinDateTime:(GDataDateTime *)dateTime {
  [self addCustomParameterWithName:kUpdatedMinParamName
                          dateTime:dateTime];
}

- (GDataDateTime *)updatedMaxDateTime {
  return [self dateTimeForParameterWithName:kUpdatedMaxParamName];
}

- (void)setUpdatedMaxDateTime:(GDataDateTime *)dateTime {
  [self addCustomParameterWithName:kUpdatedMaxParamName
                          dateTime:dateTime];
}

- (NSArray *)categoryFilters {
  return categoryFilters_; 
}

- (void)setCategoryFilters:(NSArray *)filters {
  [categoryFilters_ autorelease];
  categoryFilters_ = [filters mutableCopy];
}

- (void)addCategoryFilter:(GDataCategoryFilter *)filter {
  if (!categoryFilters_) {
    categoryFilters_ = [[NSMutableArray alloc] init]; 
  }
  
  [categoryFilters_ addObject:filter];
}

#pragma mark -

- (NSDictionary *)customParameters {
  return customParameters_; 
}

- (void)setCustomParameters:(NSDictionary *)dict {
  [customParameters_ autorelease];
  customParameters_ = [dict mutableCopy];
}

- (void)addCustomParameterWithName:(NSString *)name
                             value:(NSString *)value {
  
  if (value == nil) {
    [self removeCustomParameterWithName:name];
    return;
  }
  
  if (!customParameters_) {
    customParameters_ = [[NSMutableDictionary alloc] init]; 
  }
  
  [customParameters_ setValue:value forKey:name];
}

- (void)removeCustomParameterWithName:(NSString *)name {
  [customParameters_ removeObjectForKey:name];
}

- (NSString *)valueForParameterWithName:(NSString *)name {
  NSString *str = [[self customParameters] objectForKey:name];
  return str; 
}

// convenience methods for dateTime parameters
- (void)addCustomParameterWithName:(NSString *)name
                          dateTime:(GDataDateTime *)dateTime {

  [self addCustomParameterWithName:name
                             value:[dateTime RFC3339String]];
}

- (GDataDateTime *)dateTimeForParameterWithName:(NSString *)name {

  NSString *str = [customParameters_ objectForKey:name];
  if (str) {
    return [GDataDateTime dateTimeWithRFC3339String:str];
  }
  return nil;
}

// convenience methods for int parameters
- (void)addCustomParameterWithName:(NSString *)name
                          intValue:(int)val {

  NSString *str = [[NSNumber numberWithInt:val] stringValue];

  [self addCustomParameterWithName:name
                             value:str];
}

- (int)intValueForParameterWithName:(NSString *)name
              missingParameterValue:(int)missingVal {

  NSString *str = [customParameters_ objectForKey:name];
  if (str != nil) return [str intValue];

  return missingVal;
}

// convenience method for boolean parameters
- (void)addCustomParameterWithName:(NSString *)name
                         boolValue:(BOOL)flag
                      defaultValue:(BOOL)defaultValue {

  NSString *str = nil;
  if (defaultValue) {
    // default is true
    if (!flag) str = @"false";
  } else {
    // default is false
    if (flag) str = @"true";
  }

  // nil value will remove the parameter
  [self addCustomParameterWithName:name
                             value:str];
}

- (BOOL)boolValueForParameterWithName:(NSString *)name
                         defaultValue:(BOOL)defaultValue {

  NSString *str = [self valueForParameterWithName:name];
  if (defaultValue) {
    // default is true, so return true if param is missing or
    // is "true"
    return (str == nil)
      || ([str caseInsensitiveCompare:@"true"] == NSOrderedSame);
  } else {
    // default is false, so return true only if the param is present
    // and "true"
    return (str != nil)
      && ([str caseInsensitiveCompare:@"true"] == NSOrderedSame);
  }
}

#pragma mark -

// categoryFilterString generates the category portion of the URL path
- (NSString *)categoryFilterString {

  // make a path string containing the category filters
  NSMutableString *pathStr = [NSMutableString string];

  if ([categoryFilters_ count] > 0) {
    [pathStr appendString:@"-"];

    id filter;
    GDATA_FOREACH(filter, categoryFilters_) {
      NSString *filterValue = [filter stringValue];
      NSString *filterStr = [GDataUtilities stringByURLEncodingString:filterValue];
      if ([filterStr length] > 0) {
        [pathStr appendFormat:@"/%@", filterStr];
      }
    }
  }

  return pathStr;
}

- (NSString *)queryParamString {
  // make a query string containing all the query params.  We'll put them
  // all into an array, then use NSArray's componentsJoinedByString:

  NSMutableArray *queryItems = [NSMutableArray array];

  // sort the custom parameter keys so that we have deterministic parameter
  // order for unit tests
  NSDictionary *customParameters = [self customParameters];
  NSArray *customKeys = [customParameters allKeys];
  NSArray *sortedCustomKeys = [customKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

  id paramKey;
  GDATA_FOREACH(paramKey, sortedCustomKeys) {
    NSString *paramValue = [customParameters valueForKey:paramKey];

    NSString *paramItem = [NSString stringWithFormat:@"%@=%@",
                           [GDataUtilities stringByURLEncodingStringParameter:paramKey],
                           [GDataUtilities stringByURLEncodingStringParameter:paramValue]];

    [queryItems addObject:paramItem];
  }

  NSString *paramStr = [queryItems componentsJoinedByString:@"&"];
  return paramStr;
}

- (NSURL *)URL {
  // add the category filter string and the query params to the feed base URL

  // NSURL's URLWithString:relativeToURL: would be appropriate, but it deletes the
  // last path component of the feed when we're appending something.
  // Note that a similar deletion occurs in Java's resolve call.
  //
  // CFURLCreateCopyAppendingPathComponent seems to implicitly percent-escape
  // the path component, including any ? character, so we can't use it here,
  // either.
  //
  // We'll just do simple string appending instead.

  NSString *categoryFilterStr = [self categoryFilterString];
  NSString *queryParamString = [self queryParamString];

  // split the original URL into path and query components

  NSString *feedURLString = [[self feedURL] absoluteString];

  NSString *origPath, *origQuery, *newURLStr, *newQuery;

  // find the first question mark
  NSRange quoteMark = [feedURLString rangeOfString:@"?"];
  if (quoteMark.location == NSNotFound) {
    // no query part
    origPath = feedURLString;
    origQuery = @"";
  } else {
    // has a query part
    origPath = [feedURLString substringToIndex:quoteMark.location];
    if (quoteMark.location < [feedURLString length]) {
      // skip the leading ? mark
      origQuery = [feedURLString substringFromIndex:quoteMark.location + 1];
    } else {
      // nothing follows the ? mark
      origQuery = @"";
    }
  }

  newURLStr = origPath;

  // add the generated category filter string, if any, to the URL string,
  // ensuring it's preceded by a slash
  if ([categoryFilterStr length] > 0) {
    if (![newURLStr hasSuffix:@"/"]) {
      newURLStr = [newURLStr stringByAppendingString:@"/"];
    }
    newURLStr = [newURLStr stringByAppendingString:categoryFilterStr];
  }

  // append the generated param query string, if any, to the original query
  if ([origQuery length] > 0) {
    // there was an original query
    if ([queryParamString length] > 0) {
      newQuery = [origQuery stringByAppendingFormat:@"&%@", queryParamString];
    } else {
      newQuery = origQuery;
    }
  } else {
    // there was no original query
    newQuery = queryParamString;
  }

  // append the query to the URL
  if ([newQuery length] > 0) {
    newURLStr = [newURLStr stringByAppendingFormat:@"?%@", newQuery];
  }

  NSURL *fullURL = [NSURL URLWithString:newURLStr];
  return fullURL;
}

@end
