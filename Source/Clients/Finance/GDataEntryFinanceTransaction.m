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
//  GDataEntryFinanceTransaction.m
//


#import "GDataEntryFinanceTransaction.h"

#import "GDataFinanceTransactionData.h"

#import "GDataEntryFinancePortfolio.h" // for namespace and constants

@implementation GDataEntryFinanceTransaction

+ (GDataEntryFinanceTransaction *)transactionEntry {
  
  GDataEntryFinanceTransaction *obj;
  obj = [[[GDataEntryFinanceTransaction alloc] init] autorelease];
  
  [obj setNamespaces:[GDataEntryFinancePortfolio financeNamespaces]];
  
  return obj;
}

#pragma mark -

+ (void)load {
  [GDataObject registerEntryClass:[self class]
            forCategoryWithScheme:kGDataCategoryScheme 
                             term:kGDataCategoryFinanceTransaction];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataFinanceTransactionData class]];  
}

- (id)init {
  self = [super init];
  if (self) {
    GDataCategory *category;
    
    category = [GDataCategory categoryWithScheme:kGDataCategoryScheme
                                            term:kGDataCategoryFinanceTransaction];
    [self addCategory:category];
  }
  return self;
}

- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  [self addToArray:items objectDescriptionIfNonNil:[self transactionData] withName:@"transaction"];
  
  return items;
}

+ (NSString *)defaultServiceVersion {
  return kGDataFinanceDefaultServiceVersion;
}

#pragma mark -

- (void)setTransactionData:(GDataFinanceTransactionData *)obj {
  [self setObject:obj forExtensionClass:[GDataFinanceTransactionData class]];
}

- (GDataFinanceTransactionData *)transactionData {
  return [self objectForExtensionClass:[GDataFinanceTransactionData class]]; 
}
@end

