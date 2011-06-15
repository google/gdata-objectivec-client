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

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_FINANCE_SERVICE

#import "GDataEntryFinancePosition.h"

#import "GDataEntryFinancePortfolio.h" // for namespace and constants

@implementation GDataEntryFinancePosition

+ (GDataEntryFinancePosition *)positionEntry {
  
  GDataEntryFinancePosition *obj;
  obj = [self object];
  
  [obj setNamespaces:[GDataEntryFinancePortfolio financeNamespaces]];
  
  return obj;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategoryFinancePosition;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];
  
  [self addExtensionDeclarationForParentClass:entryClass
                                 childClasses:
   [GDataPositionData class],
   [GDataFinanceSymbol class],
   [GDataFeedLink class],
   nil];  
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  [self addToArray:items objectDescriptionIfNonNil:[self symbol] withName:@"symbol"];
  [self addToArray:items objectDescriptionIfNonNil:[self positionData] withName:@"position"];
  [self addToArray:items objectDescriptionIfNonNil:[self feedLink] withName:@"feedLink"];
  
  return items;
}
#endif

+ (NSString *)defaultServiceVersion {
  return kGDataFinanceDefaultServiceVersion;
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

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_FINANCE_SERVICE
