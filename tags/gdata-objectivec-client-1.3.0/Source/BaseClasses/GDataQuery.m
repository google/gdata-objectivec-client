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

@implementation GDataCategoryFilter

+ (GDataCategoryFilter *)categoryFilter {
  return [[[[self class] alloc] init] autorelease];  
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
  NSEnumerator *catEnum = [categories_ objectEnumerator];
  GDataCategory *cat;
  while ((cat = [catEnum nextObject]) != nil) {    
    if ([result length]) {
      [result appendString:@"|"]; 
    }
    [result appendString:[self queryStringForCategory:cat]];
  }

  // append exclude categories, preceded by "-"
  catEnum = [excludeCategories_ objectEnumerator];
  while ((cat = [catEnum nextObject]) != nil) {    
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
  return [[[[self class] alloc] initWithFeedURL:feedURL] autorelease];  
}

- (id)initWithFeedURL:(NSURL *)feedURL {
  self = [super init];
  if (self) {
    startIndex_ = -1;
    maxResults_ = -1;
    [self setFeedURL:feedURL];
  }
  return self;
}

- (void)dealloc {
  [feedURL_ release];
  [fullTextQueryString_ release];
  [author_ release];
  [orderBy_ release];
  [publishedMinDateTime_ release];
  [publishedMaxDateTime_ release];
  [updatedMinDateTime_ release];
  [updatedMaxDateTime_ release];
  [categoryFilters_ release];
  [customParameters_ release];
  [super dealloc];
}


- (id)copyWithZone:(NSZone *)zone {
  GDataQuery *query = [[GDataQuery alloc] init];
  [query setFeedURL:feedURL_];
  [query setStartIndex:startIndex_];
  [query setMaxResults:maxResults_];
  [query setFullTextQueryString:fullTextQueryString_];
  [query setAuthor:author_];
  [query setOrderBy:orderBy_];
  if (sortOrder_ != 0) [query setIsAscendingOrder:(sortOrder_ > 0)];
  [query setShouldShowDeleted:shouldShowDeleted_];
  [query setPublishedMinDateTime:publishedMinDateTime_];
  [query setPublishedMaxDateTime:publishedMaxDateTime_];
  [query setUpdatedMinDateTime:updatedMinDateTime_];
  [query setUpdatedMaxDateTime:updatedMaxDateTime_];
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
  return startIndex_; 
}

- (void)setStartIndex:(int)startIndex {
  startIndex_ = startIndex; 
}

- (int)maxResults {
  return maxResults_; 
}

- (void)setMaxResults:(int)maxResults {
  maxResults_ = maxResults;  
}

- (NSString *)fullTextQueryString {
  return fullTextQueryString_; 
}

- (void)setFullTextQueryString:(NSString *)str {
  [fullTextQueryString_ autorelease];  
  fullTextQueryString_ = [str copy];
}

- (NSString *)author {
  return author_; 
}

- (void)setAuthor:(NSString *)author {
  [author_ autorelease];  
  author_ = [author copy];
}

- (NSString *)orderBy {
  return orderBy_; 
}

- (void)setOrderBy:(NSString *)str {
  [orderBy_ autorelease];  
  orderBy_ = [str copy];
}

- (BOOL)isAscendingOrder {
  return sortOrder_ > 0; 
}

- (void)setIsAscendingOrder:(BOOL)flag {
  sortOrder_ = (flag ? 1 : -1); 
}

- (BOOL)shouldShowDeleted {
  return shouldShowDeleted_;
}

- (void)setShouldShowDeleted:(BOOL)flag {
  shouldShowDeleted_ = flag; 
}

- (GDataDateTime *)publishedMinDateTime {
  return publishedMinDateTime_;
}

- (void)setPublishedMinDateTime:(GDataDateTime *)dateTime {
  [publishedMinDateTime_ autorelease];
  publishedMinDateTime_ = [dateTime retain]; 
}

- (GDataDateTime *)publishedMaxDateTime {
  return publishedMaxDateTime_;
}

- (void)setPublishedMaxDateTime:(GDataDateTime *)dateTime {
  [publishedMaxDateTime_ autorelease];
  publishedMaxDateTime_ = [dateTime retain]; 
}

- (GDataDateTime *)updatedMinDateTime {
  return updatedMinDateTime_;
}

- (void)setUpdatedMinDateTime:(GDataDateTime *)dateTime {
  [updatedMinDateTime_ autorelease];
  updatedMinDateTime_ = [dateTime retain]; 
}

- (GDataDateTime *)updatedMaxDateTime {
  return updatedMaxDateTime_;
}

- (void)setUpdatedMaxDateTime:(GDataDateTime *)dateTime {
  [updatedMaxDateTime_ autorelease];
  updatedMaxDateTime_ = [dateTime retain]; 
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

- (NSDictionary *)customParameters {
  return customParameters_; 
}

- (void)setCustomParameters:(NSDictionary *)dict {
  [customParameters_ autorelease];
  customParameters_ = [dict mutableCopy];
}

- (void)addCustomParameterWithName:(NSString *)name
                             value:(NSString *)value {
  if (!customParameters_) {
    customParameters_ = [[NSMutableDictionary alloc] init]; 
  }
  
  if (value) {
    [customParameters_ setValue:value forKey:name];
  } else {
    [customParameters_ removeObjectForKey:name];
  }
}

- (NSString *)pathQueryURI {
  
  // make a path string containing the category filters
  NSMutableString *pathStr = [NSMutableString string];
  
  if ([categoryFilters_ count] > 0) {
    [pathStr appendString:@"-"];
    
    NSEnumerator *filterEnum = [categoryFilters_ objectEnumerator];
    id filter;
    while ((filter = [filterEnum nextObject]) != nil) {
      NSString *filterValue = [filter stringValue];
      NSString *filterStr = [GDataQuery stringByURLEncodingString:filterValue];
      if ([filterStr length] > 0) {
        [pathStr appendFormat:@"/%@", filterStr];
      }
    }
  }
  
  // make a query string containing all the query params.  We'll put them
  // all into an array, then use NSArray's componentsJoinedByString:
  
  NSMutableArray *queryItems = [NSMutableArray array];
  
  NSString *ftQueryStr = [self fullTextQueryString];
  if ([ftQueryStr length] > 0) {
    
    NSString *param = [GDataQuery stringByURLEncodingStringParameter:ftQueryStr];
    NSString *ftQueryItem = [NSString stringWithFormat:@"q=%@", param];
    [queryItems addObject:ftQueryItem];
  }
 
  NSString *author = [self author];
  if ([author length] > 0) {
    NSString *param = [GDataQuery stringByURLEncodingStringParameter:author];
    NSString *authorItem = [NSString stringWithFormat:@"author=%@", param];
    [queryItems addObject:authorItem];
  }

  NSString *orderBy = [self orderBy];
  if ([orderBy length] > 0) {
    NSString *param = [GDataQuery stringByURLEncodingStringParameter:orderBy];
    NSString *orderByItem = [NSString stringWithFormat:@"orderby=%@", param];
    [queryItems addObject:orderByItem];
  }
  
  if (sortOrder_ != 0) {
    NSString *param = (sortOrder_ > 0 ? @"ascending" : @"descending");
    NSString *sortOrderItem = [NSString stringWithFormat:@"sortorder=%@", param];
    [queryItems addObject:sortOrderItem];
  }
  
  if (shouldShowDeleted_) {
    [queryItems addObject:@"showdeleted=true"];
  }
  
  GDataDateTime *minUpdatedDate = [self updatedMinDateTime];
  if (minUpdatedDate) {
    NSString *minUpdateDateItem = [NSString stringWithFormat:@"updated-min=%@",
      [GDataQuery stringByURLEncodingStringParameter:[minUpdatedDate RFC3339String]]];
    [queryItems addObject:minUpdateDateItem];
  }
  
  GDataDateTime *maxUpdatedDate = [self updatedMaxDateTime];
  if (maxUpdatedDate) {
    NSString *maxUpdateDateItem = [NSString stringWithFormat:@"updated-max=%@",
      [GDataQuery stringByURLEncodingStringParameter:[maxUpdatedDate RFC3339String]]];
    [queryItems addObject:maxUpdateDateItem];
  }
  
  GDataDateTime *minPublishedDate = [self publishedMinDateTime];
  if (minPublishedDate) {
    NSString *minPublishedDateItem = [NSString stringWithFormat:@"published-min=%@",
      [GDataQuery stringByURLEncodingStringParameter:[minPublishedDate RFC3339String]]];
    [queryItems addObject:minPublishedDateItem];
  }
  
  GDataDateTime *maxPublishedDate = [self publishedMaxDateTime];
  if (maxPublishedDate) {
    NSString *maxPublishedDateItem = [NSString stringWithFormat:@"published-max=%@",
      [GDataQuery stringByURLEncodingStringParameter:[maxPublishedDate RFC3339String]]];
    [queryItems addObject:maxPublishedDateItem];
  }
  
  int startIndex = [self startIndex];
  if (startIndex != -1) {
    NSString *startIndexItem = [NSString stringWithFormat:@"start-index=%d", startIndex];
    [queryItems addObject:startIndexItem];
  }
  
  int maxResults = [self maxResults];
  if (maxResults != -1) {
    NSString *maxResultsItem = [NSString stringWithFormat:@"max-results=%d", maxResults];
    [queryItems addObject:maxResultsItem];
  }

  // sort the custom parameter keys so that we have deterministic parameter
  // order for unit tests
  NSDictionary *customParameters = [self customParameters];
  NSArray *customKeys = [customParameters allKeys];
  NSArray *sortedCustomKeys = [customKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
  
  NSEnumerator *paramEnum = [sortedCustomKeys objectEnumerator];
  id paramKey;
  while ((paramKey = [paramEnum nextObject]) != nil) {
    NSString *paramValue = [customParameters valueForKey:paramKey];
    
    NSString *paramItem = [NSString stringWithFormat:@"%@=%@",
      [GDataQuery stringByURLEncodingStringParameter:paramKey],
      [GDataQuery stringByURLEncodingStringParameter:paramValue]];

    [queryItems addObject:paramItem];
  }
  
  NSString *queryStr = [queryItems componentsJoinedByString:@"&"];
  
  // combine the query and path strings, if either are non-empty
  NSString *result;
  if ([queryStr length] == 0) {
    result = pathStr;
  } else {
    result = [NSString stringWithFormat:@"%@?%@", pathStr, queryStr];
  }
  return result;
}

- (NSURL *)URL { 
   // append the resource URL to the feed base URL
  
  NSString *pathQueryURI = [self pathQueryURI]; // should conform to RFC 2396
  
  if ([pathQueryURI length] == 0) {
    return [self feedURL];
  }
  
  // NSURL's URLWithString:relativeToURL: would be appropriate, but it deletes the
  // last path component of the feed when we're appending something.
  // Note that a similar deletion occurs in Java's resolve call.
  //  
  // CFURLCreateCopyAppendingPathComponent seems to implicitly percent-escape
  // the path component, including any ? character, so we can't use it here,
  // either.
  //
  // We'll just do dumb string appending instead.
  
  NSString *feedURLString = [[self feedURL] absoluteString];
  if (![feedURLString hasSuffix:@"/"] && ![pathQueryURI hasPrefix:@"?"]) {
    feedURLString = [feedURLString stringByAppendingString:@"/"];
  }
  NSString *combinedURLString = [feedURLString stringByAppendingString:pathQueryURI];
  
  NSURL *fullURL = [NSURL URLWithString:combinedURLString];
  return fullURL;
}

+ (NSString *)stringByURLEncodingString:(NSString *)str {
  NSString *result = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  return result;
}

+ (NSString *)stringByURLEncodingStringParameter:(NSString *)str {
  
  // NSURL's stringByAddingPercentEscapesUsingEncoding: does not escape
  // some characters that should be escaped in URL parameters, like / and ?; 
  // we'll use CFURL to force the encoding of those
  //
  // We'll explictly leave spaces unescaped now, and replace them with +'s
  //
  // Reference: http://www.ietf.org/rfc/rfc3986.txt

  NSString *resultStr = str;

  CFStringRef originalString = (CFStringRef) str;
  CFStringRef leaveUnescaped = CFSTR(" ");
  CFStringRef forceEscaped = CFSTR("!*'();:@&=+$,/?%#[]");
  
  CFStringRef escapedStr;
  escapedStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                       originalString,
                                                       leaveUnescaped, 
                                                       forceEscaped,
                                                       kCFStringEncodingUTF8);
  
  if (escapedStr) {
    NSMutableString *mutableStr = [NSMutableString stringWithString:(NSString *)escapedStr];
    CFRelease(escapedStr);

    // replace spaces with plusses
    [mutableStr replaceOccurrencesOfString:@" "
                                withString:@"+"
                                   options:0
                                     range:NSMakeRange(0, [mutableStr length])];
    resultStr = mutableStr;
  }
  return resultStr;
}

@end
