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
//  GDataPortfolioElements.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_FINANCE_SERVICE

//
// GDataPortfolioBase is a common base class for both GDataPortfolioData (which
// adds currencyCode) and GDataPositionData (which adds shares).
//

#import "GDataObject.h"
#import "GDataMoney.h"

@class GDataCostBasis;
@class GDataGain;
@class GDataDaysGain;
@class GDataMarketValue;

@interface GDataPortfolioBase : GDataObject

// attributes

- (NSNumber *)gainPercentage; // double
- (void)setGainPercentage:(NSNumber *)num;

- (NSDecimalNumber *)return1w;
- (void)setReturn1w:(NSNumber *)num;

- (NSDecimalNumber *)return1y;
- (void)setReturn1y:(NSNumber *)num;

- (NSDecimalNumber *)return3m;
- (void)setReturn3m:(NSNumber *)num;

- (NSDecimalNumber *)return3y;
- (void)setReturn3y:(NSNumber *)num;

- (NSDecimalNumber *)return4w;
- (void)setReturn4w:(NSNumber *)num;

- (NSDecimalNumber *)return5y;
- (void)setReturn5y:(NSNumber *)num;

- (NSDecimalNumber *)returnOverall;
- (void)setReturnOverall:(NSNumber *)num;

- (NSDecimalNumber *)returnYTD;
- (void)setReturnYTD:(NSNumber *)num;

// extensions: these are derived from GDataMoneyElements

- (GDataCostBasis *)costBasis;
- (void)setCostBasis:(GDataCostBasis *)obj;

- (GDataGain *)gain;
- (void)setGain:(GDataGain *)obj;

- (GDataDaysGain *)daysGain;
- (void)setDaysGain:(GDataDaysGain *)obj;

- (GDataMarketValue *)marketValue;
- (void)setMarketValue:(GDataMarketValue *)obj;

@end

//  portfolio data, like
//
//  <gf:portfolioData currencyCode='USD' gainPercentage='1.894857932' 
//         return1w='-0.07711772724' return1y='0.3969560994' return3m='0.197468495'
//         return3y='1.228892613' return4w='-0.003721445821' return5y='1.894857932'
//         returnOverall='1.894857932' returnYTD='0.4172674026'>
//    <gf:costBasis>
//      <gd:money amount='52158.0' currencyCode='USD'/>
//    </gf:costBasis>
//    <gf:daysGain>
//      <gd:money amount='7321.0' currencyCode='USD'/>
//    </gf:daysGain>
//    <gf:gain>
//      <gd:money amount='98832.0' currencyCode='USD'/>
//    </gf:gain>
//    <gf:marketValue>
//      <gd:money amount='150990.0' currencyCode='USD'/>
//    </gf:marketValue>
//  </gf:portfolioData>

@interface GDataPortfolioData : GDataPortfolioBase <GDataExtension>
+ (GDataPortfolioData *)portfolioData;

- (NSString *)currencyCode;
- (void)setCurrencyCode:(NSString *)str;
@end

// position data element is like portfolioData, but has a shares attribute
// and lacks a currencyCode attribute

@interface GDataPositionData : GDataPortfolioBase <GDataExtension>
+ (GDataPositionData *)positionData;

- (NSDecimalNumber *)shares;
- (void)setShares:(NSNumber *)num;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_FINANCE_SERVICE
