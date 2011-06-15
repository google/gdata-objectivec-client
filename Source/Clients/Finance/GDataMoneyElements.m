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
//  GDataMoneyElements.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_FINANCE_SERVICE

#import "GDataMoneyElements.h"

#import "GDataEntryFinancePortfolio.h" // for namespaces

//  Elements containing one or more money elements as children, like
//
//  <gf:commission>
//    <gd:money amount='0.0' currencyCode='USD'/>
//  </gf:commission>

@implementation GDataCommission
+ (NSString *)extensionElementPrefix { return kGDataNamespaceFinancePrefix; }
+ (NSString *)extensionElementURI { return kGDataNamespaceFinance; }
+ (NSString *)extensionElementLocalName { return @"commission"; }
@end

@implementation GDataCostBasis
+ (NSString *)extensionElementPrefix { return kGDataNamespaceFinancePrefix; }
+ (NSString *)extensionElementURI { return kGDataNamespaceFinance; }
+ (NSString *)extensionElementLocalName { return @"costBasis"; }
@end

@implementation GDataMarketValue
+ (NSString *)extensionElementPrefix { return kGDataNamespaceFinancePrefix; }
+ (NSString *)extensionElementURI { return kGDataNamespaceFinance; }
+ (NSString *)extensionElementLocalName { return @"marketValue"; }
@end

@implementation GDataGain
+ (NSString *)extensionElementPrefix { return kGDataNamespaceFinancePrefix; }
+ (NSString *)extensionElementURI { return kGDataNamespaceFinance; }
+ (NSString *)extensionElementLocalName { return @"gain"; }
@end

@implementation GDataDaysGain
+ (NSString *)extensionElementPrefix { return kGDataNamespaceFinancePrefix; }
+ (NSString *)extensionElementURI { return kGDataNamespaceFinance; }
+ (NSString *)extensionElementLocalName { return @"daysGain"; }
@end

@implementation GDataPrice
+ (NSString *)extensionElementPrefix { return kGDataNamespaceFinancePrefix; }
+ (NSString *)extensionElementURI { return kGDataNamespaceFinance; }
+ (NSString *)extensionElementLocalName { return @"price"; }
@end

@implementation GDataMoneyElementBase 

+ (id)moneyGroupWithMoney:(GDataMoney *)money {
  
  GDataMoneyElementBase *obj;
  obj = [self object];
  
  [obj addMoney:money];
  
  return obj;
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  // this element may contain one or more gd:money child elements
  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataMoney class]];  
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  // extensions
  [self addToArray:items objectDescriptionIfNonNil:[self moneys] withName:@"moneys"];

  return items;
}
#endif

#pragma mark -

- (NSArray *)moneys {
  return [self objectsForExtensionClass:[GDataMoney class]]; 
}

- (void)setMoneys:(NSArray *)arr {
  [self setObjects:arr forExtensionClass:[GDataMoney class]];
}

- (void)addMoney:(GDataMoney *)obj {
  [self addObject:obj forExtensionClass:[GDataMoney class]];
}

#pragma mark Convenience accessors

- (GDataMoney *)moneyWithPrimaryCurrency {
  
  // get the first listed money, which has the primary currency
  NSArray *moneys = [self moneys];
  
  if ([moneys count] >= 1) {
    return [moneys objectAtIndex:0]; 
  }
  return nil;
}

- (GDataMoney *)moneyWithSecondaryCurrency {
  
  // get the second listed currency
  NSArray *moneys = [self moneys];
  
  if ([moneys count] >= 2) {
    return [moneys objectAtIndex:1]; 
  }
  return nil;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_FINANCE_SERVICE
