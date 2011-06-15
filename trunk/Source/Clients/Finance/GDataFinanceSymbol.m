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
//  GDataFinanceSymbol.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_FINANCE_SERVICE

#import "GDataFinanceSymbol.h"

#import "GDataMoneyElements.h"
#import "GDataDateTime.h"
#import "GDataEntryFinancePortfolio.h" // for namespaces


// exchange symbol, like
//  <gf:symbol exchange='NASDAQ' fullName='Google Inc.' symbol='GOOG'/>

static NSString* const kExchangeAttr = @"exchange";
static NSString* const kFullNameAttr = @"fullName";
static NSString* const kSymbolAttr = @"symbol";

@implementation GDataFinanceSymbol 

+ (NSString *)extensionElementPrefix { return kGDataNamespaceFinancePrefix; }
+ (NSString *)extensionElementURI { return kGDataNamespaceFinance; }
+ (NSString *)extensionElementLocalName { return @"symbol"; }

+ (GDataFinanceSymbol *)symbolWithSymbol:(NSString *)symbol
                                fullName:(NSString *)fullName
                                exchange:(NSString *)exchange {
  
  GDataFinanceSymbol *obj = [self object];
  [obj setSymbol:symbol];
  [obj setFullName:fullName];
  [obj setExchange:exchange];
  return obj;
}

- (void)addParseDeclarations {
  
  NSArray *attrs = [NSArray arrayWithObjects: 
                    kSymbolAttr, kExchangeAttr, kFullNameAttr, nil];
  
  [self addLocalAttributeDeclarations:attrs];
}

#pragma mark -

- (NSString *)exchange {
  return [self stringValueForAttribute:kExchangeAttr]; 
}

- (void)setExchange:(NSString *)str {
  [self setStringValue:str forAttribute:kExchangeAttr];
}

- (NSString *)fullName {
  return [self stringValueForAttribute:kFullNameAttr]; 
}

- (void)setFullName:(NSString *)str {
  [self setStringValue:str forAttribute:kFullNameAttr];
}

- (NSString *)symbol {
  return [self stringValueForAttribute:kSymbolAttr]; 
}

- (void)setSymbol:(NSString *)str {
  [self setStringValue:str forAttribute:kSymbolAttr];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_FINANCE_SERVICE
