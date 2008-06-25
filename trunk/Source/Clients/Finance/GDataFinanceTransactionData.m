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
//  GDataFinanceTransactionData.m
//

#import "GDataFinanceTransactionData.h"

#import "GDataEntryFinancePortfolio.h" // for namespaces

#import "GDataMoneyElements.h"
#import "GDataDateTime.h"

// transaction data, like
//  <gf:transactionData shares="20" date="2007-07-16T00:00:00" type="Buy">
//    <gf:price>
//      <gd:money amount="199" currencycode="USD"/>
//    </gf:price>
//    <gf:commission>
//      <gd:money amount="10" currencycode="USD"/>
//    </gf:commission>
//  </gf:transactionData>

static NSString* const kTypeAttr = @"type";
static NSString* const kSharesAttr = @"shares";
static NSString* const kDateAttr = @"date";
static NSString* const kNotesAttr = @"notes";


@implementation GDataFinanceTransactionData 

+ (NSString *)extensionElementPrefix { return kGDataNamespaceFinancePrefix; }
+ (NSString *)extensionElementURI { return kGDataNamespaceFinance; }
+ (NSString *)extensionElementLocalName { return @"transactionData"; }

+ (GDataFinanceTransactionData *)transactionDataWithType:(NSString *)str {
  
  GDataFinanceTransactionData *obj = [[[GDataFinanceTransactionData alloc] init] autorelease];
  [obj setType:str];
  return obj;
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataCommission class]];  
  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataPrice class]];  
}

- (void)addParseDeclarations {
  
  NSArray *attrs = [NSArray arrayWithObjects: 
                    kTypeAttr, kSharesAttr, kDateAttr, kNotesAttr, nil];
  
  [self addLocalAttributeDeclarations:attrs];
}

- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
    
  // add description for extensions
  [self addToArray:items objectDescriptionIfNonNil:[self price] withName:@"price"];
  [self addToArray:items objectDescriptionIfNonNil:[self commission] withName:@"commission"];

  return items;
}

#pragma mark -

- (NSString *)type {
  return [self stringValueForAttribute:kTypeAttr]; 
}

- (void)setType:(NSString *)str {
  [self setStringValue:str forAttribute:kTypeAttr];
}

- (GDataDateTime *)date {
  return [self dateTimeForAttribute:kDateAttr]; 
}

- (void)setDate:(GDataDateTime *)date {
  [self setStringValue:[date RFC3339String] forAttribute:kDateAttr];
}

- (NSNumber *)shares {
  return [self doubleNumberForAttribute:kSharesAttr]; 
}

- (void)setShares:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kSharesAttr];
}

- (NSString *)notes {
  return [self stringValueForAttribute:kNotesAttr]; 
}

- (void)setNotes:(NSString *)str {
  [self setStringValue:str forAttribute:kNotesAttr];
}

#pragma mark -

- (GDataCommission *)commission {
  return [self objectForExtensionClass:[GDataCommission class]];
}

- (void)setCommission:(GDataCommission *)obj {
  [self setObject:obj forExtensionClass:[obj class]];   
}

- (GDataPrice *)price {
  return [self objectForExtensionClass:[GDataPrice class]];
}

- (void)setPrice:(GDataPrice *)obj {
  [self setObject:obj forExtensionClass:[obj class]];
}

@end
