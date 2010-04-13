/* Copyright (c) 2008 Google Inc.
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
//  GDataEntryFinancePortfolio.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_FINANCE_SERVICE

#define GDATAENTRYFINANCEPORTFOLIO_DEFINE_GLOBALS 1

#import "GDataEntryFinancePortfolio.h"

@implementation GDataEntryFinancePortfolio

+ (NSDictionary *)financeNamespaces {
  NSMutableDictionary *namespaces;
  
  namespaces = [NSMutableDictionary dictionaryWithObject:kGDataNamespaceFinance
                                                  forKey:kGDataNamespaceFinancePrefix];
  
  [namespaces addEntriesFromDictionary:[GDataEntryBase baseGDataNamespaces]];
  
  return namespaces;
}

+ (GDataEntryFinancePortfolio *)portfolioEntry {
  
  GDataEntryFinancePortfolio *obj;
  obj = [[[GDataEntryFinancePortfolio alloc] init] autorelease];
  
  [obj setNamespaces:[GDataEntryFinancePortfolio financeNamespaces]];
  
  return obj;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategoryFinancePortfolio;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];
  
  [self addExtensionDeclarationForParentClass:entryClass
                                 childClasses:
   [GDataPortfolioData class],
   [GDataFeedLink class],
   nil];  
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  [self addToArray:items objectDescriptionIfNonNil:[self portfolioData] withName:@"portfolio"];
  [self addToArray:items objectDescriptionIfNonNil:[self feedLink] withName:@"feedLink"];

  return items;
}
#endif

+ (NSString *)defaultServiceVersion {
  return kGDataFinanceDefaultServiceVersion;
}

#pragma mark -

- (void)setPortfolioData:(GDataPortfolioData *)obj {
  [self setObject:obj forExtensionClass:[GDataPortfolioData class]];
}

- (GDataPortfolioData *)portfolioData {
  return [self objectForExtensionClass:[GDataPortfolioData class]]; 
}

- (void)setFeedLink:(GDataFeedLink *)feedLink {
  [self setObject:feedLink forExtensionClass:[GDataFeedLink class]];
}

- (GDataFeedLink *)feedLink {
  return [self objectForExtensionClass:[GDataFeedLink class]]; 
}

#pragma mark Convenience accessors

- (NSURL *)positionURL {
  
  GDataFeedLink *feedLink = [self feedLink];
  if (feedLink) {
    
    NSString *urlStr = [feedLink href];
    if ([urlStr length] > 0) {
      
      NSURL *url = [NSURL URLWithString:urlStr];
      return url;
    }
  }
  return nil;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_FINANCE_SERVICE
