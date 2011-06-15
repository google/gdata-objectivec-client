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
//  GDataPortfolioElements.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_FINANCE_SERVICE

#import "GDataPortfolioElements.h"
#import "GDataMoneyElements.h"
#import "GDataEntryFinancePortfolio.h" // for namespaces

static NSString *const kGainPercentageAttr = @"gainPercentage";
static NSString *const kReturn1wAttr = @"return1w";
static NSString *const kReturn1yAttr = @"return1y";
static NSString *const kReturn3mAttr = @"return3m";
static NSString *const kReturn3yAttr = @"return3y";
static NSString *const kReturn4wAttr = @"return4w";
static NSString *const kReturn5yAttr = @"return5y";
static NSString *const kReturnOverallAttr = @"returnOverall";
static NSString *const kReturnYTDAttr = @"returnYTD";

// portfolio-only
static NSString *const kCurrencyCodeAttr = @"currencyCode";

// position-only
static NSString *const kSharesAttr = @"shares";


//
// Portfolio subclass
//

@implementation GDataPortfolioData
+ (NSString *)extensionElementPrefix { return kGDataNamespaceFinancePrefix; }
+ (NSString *)extensionElementURI { return kGDataNamespaceFinance; }
+ (NSString *)extensionElementLocalName { return @"portfolioData"; }

+ (GDataPortfolioData *)portfolioData {
  GDataPortfolioData *obj = [self object];
  return obj;
}

- (void)addParseDeclarations {
  
  [super addParseDeclarations];
  
  NSArray *attrs = [NSArray arrayWithObject:kCurrencyCodeAttr];
  
  [self addLocalAttributeDeclarations:attrs];
}

- (NSString *)currencyCode {
  return [self stringValueForAttribute:kCurrencyCodeAttr];
}

- (void)setCurrencyCode:(NSString *)str {
  [self setStringValue:str forAttribute:kCurrencyCodeAttr]; 
}
@end

// 
// Position subclass
//

@implementation GDataPositionData
+ (NSString *)extensionElementPrefix { return kGDataNamespaceFinancePrefix; }
+ (NSString *)extensionElementURI { return kGDataNamespaceFinance; }
+ (NSString *)extensionElementLocalName { return @"positionData"; }

+ (GDataPositionData *)positionData {
  GDataPositionData *obj = [self object];
  return obj;
}

- (void)addParseDeclarations {
    
  // add shares before adding the superclass's attributes so it shows
  // first in the description's list of attributes
  
  NSArray *attrs = [NSArray arrayWithObject:kSharesAttr];
  [self addLocalAttributeDeclarations:attrs];
  
  [super addParseDeclarations];
}

- (NSDecimalNumber *)shares {
  return [self decimalNumberForAttribute:kSharesAttr];
}

- (void)setShares:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kSharesAttr]; 
}
@end

//
// common base
//
@implementation GDataPortfolioBase 

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  Class elementClass = [self class];
  [self addExtensionDeclarationForParentClass:elementClass
                                 childClasses:
   [GDataCostBasis class],
   [GDataDaysGain class],
   [GDataGain class],
   [GDataMarketValue class],
   nil];
}

- (void)addParseDeclarations {
  
  NSArray *attrs = [NSArray arrayWithObjects:
                    kGainPercentageAttr, kReturnOverallAttr, kReturnYTDAttr,
                    kReturn1wAttr, kReturn1yAttr, kReturn3mAttr, kReturn3yAttr,
                    kReturn4wAttr, kReturn5yAttr, nil];
                    
  [self addLocalAttributeDeclarations:attrs];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"costBasis", @"costBasis", kGDataDescValueLabeled },
    { @"daysGain",  @"daysGain",  kGDataDescValueLabeled },
    { @"gain",      @"gain",      kGDataDescValueLabeled },
    { @"daysGain",  @"daysGain",  kGDataDescValueLabeled },
    { nil, nil, (GDataDescRecTypes)0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

// common attributes

- (NSNumber *)gainPercentage {
  return [self doubleNumberForAttribute:kGainPercentageAttr];
}

- (void)setGainPercentage:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kGainPercentageAttr]; 
}

- (NSDecimalNumber *)return1w {
  return [self decimalNumberForAttribute:kReturn1wAttr];
}

- (void)setReturn1w:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kReturn1wAttr]; 
}

- (NSDecimalNumber *)return1y {
  return [self decimalNumberForAttribute:kReturn1yAttr];
}

- (void)setReturn1y:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kReturn1yAttr]; 
}

- (NSDecimalNumber *)return3m {
  return [self decimalNumberForAttribute:kReturn3mAttr];
}

- (void)setReturn3m:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kReturn3mAttr]; 
}

- (NSDecimalNumber *)return3y {
  return [self decimalNumberForAttribute:kReturn3yAttr];
}

- (void)setReturn3y:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kReturn3yAttr]; 
}

- (NSDecimalNumber *)return4w {
  return [self decimalNumberForAttribute:kReturn4wAttr];
}

- (void)setReturn4w:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kReturn4wAttr]; 
}

- (NSDecimalNumber *)return5y {
  return [self decimalNumberForAttribute:kReturn5yAttr];
}

- (void)setReturn5y:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kReturn5yAttr]; 
}

- (NSDecimalNumber *)returnOverall {
  return [self decimalNumberForAttribute:kReturnOverallAttr];
}

- (void)setReturnOverall:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kReturnOverallAttr]; 
}

- (NSDecimalNumber *)returnYTD {
  return [self decimalNumberForAttribute:kReturnYTDAttr];
}

- (void)setReturnYTD:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kReturnYTDAttr]; 
}

// extensions

- (GDataCostBasis *)costBasis {
  return [self objectForExtensionClass:[GDataCostBasis class]];
}

 - (void)setCostBasis:(GDataCostBasis *)obj {
   [self setObject:obj forExtensionClass:[GDataCostBasis class]];
 }

- (GDataGain *)gain {
  return [self objectForExtensionClass:[GDataGain class]];
}

- (void)setGain:(GDataGain *)obj {
  [self setObject:obj forExtensionClass:[GDataGain class]];
}

- (GDataDaysGain *)daysGain {
  return [self objectForExtensionClass:[GDataDaysGain class]];
}

- (void)setDaysGain:(GDataDaysGain *)obj {
  [self setObject:obj forExtensionClass:[GDataDaysGain class]];
}

- (GDataMarketValue *)marketValue {
  return [self objectForExtensionClass:[GDataMarketValue class]];
}

- (void)setMarketValue:(GDataMarketValue *)obj {
  [self setObject:obj forExtensionClass:[GDataMarketValue class]];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_FINANCE_SERVICE
