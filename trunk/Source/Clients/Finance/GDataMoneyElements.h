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
//  GDataMoneyElements.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_FINANCE_SERVICE

#import "GDataObject.h"
#import "GDataMoney.h"

//
// Finance elements which contain gd:money extensions
//


@interface GDataMoneyElementBase : GDataObject
+ (id)moneyGroupWithMoney:(GDataMoney *)money;

- (NSArray *)moneys;
- (void)setMoneys:(NSArray *)arr;
- (void)addMoney:(GDataMoney *)obj;

// convenience accessors: these return the first and second listed
// money, if available, or nil
- (GDataMoney *)moneyWithPrimaryCurrency;
- (GDataMoney *)moneyWithSecondaryCurrency;
  
@end

@interface GDataCommission : GDataMoneyElementBase <GDataExtension>
@end

@interface GDataCostBasis : GDataMoneyElementBase <GDataExtension>
@end

@interface GDataMarketValue : GDataMoneyElementBase <GDataExtension>
@end

@interface GDataGain : GDataMoneyElementBase <GDataExtension>
@end

@interface GDataDaysGain : GDataMoneyElementBase <GDataExtension>
@end

@interface GDataPrice : GDataMoneyElementBase <GDataExtension>
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_FINANCE_SERVICE
