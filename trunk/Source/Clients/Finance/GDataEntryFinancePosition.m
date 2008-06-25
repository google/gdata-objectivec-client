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
//  GDataEntryFinancePosition.m
//


#import "GDataEntryFinancePosition.h"

#import "GDataPortfolioElements.h"

#import "GDataEntryFinancePortfolio.h" // for namespace and constants
#import "GDataFeedLink.h"
#import "GDataFinanceSymbol.h"

@implementation GDataEntryFinancePosition

+ (GDataEntryFinancePosition *)positionEntry {
  
  GDataEntryFinancePosition *obj;
  obj = [[[GDataEntryFinancePosition alloc] init] autorelease];
  
  [obj setNamespaces:[GDataEntryFinancePortfolio financeNamespaces]];
  
  return obj;
}

#pragma mark -

+ (void)load {
  [GDataObject registerEntryClass:[self class]
            forCategoryWithScheme:kGDataCategoryScheme 
                             term:kGDataCategoryFinancePosition];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];
  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataPositionData class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataFinanceSymbol class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataFeedLink class]];  
}

- (id)init {
  self = [super init];
  if (self) {
    GDataCategory *category;
    
    category = [GDataCategory categoryWithScheme:kGDataCategoryScheme
                                            term:kGDataCategoryFinancePosition];
    [self addCategory:category];
  }
  return self;
}

- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  [self addToArray:items objectDescriptionIfNonNil:[self symbol] withName:@"symbol"];
  [self addToArray:items objectDescriptionIfNonNil:[self positionData] withName:@"position"];
  [self addToArray:items objectDescriptionIfNonNil:[self feedLink] withName:@"feedLink"];
  
  return items;
}


#pragma mark -

- (void)setPositionData:(GDataPositionData *)obj {
  [self setObject:obj forExtensionClass:[GDataPositionData class]];
}

- (GDataPositionData *)positionData {
  return [self objectForExtensionClass:[GDataPositionData class]]; 
}

- (void)setFeedLink:(GDataFeedLink *)feedLink {
  [self setObject:feedLink forExtensionClass:[GDataFeedLink class]];
}

- (GDataFeedLink *)feedLink {
  return [self objectForExtensionClass:[GDataFeedLink class]]; 
}

- (void)setSymbol:(GDataFinanceSymbol *)obj {
  [self setObject:obj forExtensionClass:[GDataFinanceSymbol class]];
}

- (GDataFinanceSymbol *)symbol {
  return [self objectForExtensionClass:[GDataFinanceSymbol class]]; 
}

#pragma mark Convenience accessors

- (NSURL *)transactionURL {
  
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

