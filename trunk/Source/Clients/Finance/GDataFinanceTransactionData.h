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
//  GDataFinanceTransactionData.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_FINANCE_SERVICE

#import "GDataObject.h"

//
// transaction data, like
//  <gf:transactionData shares="20" date="2007-07-16T00:00:00" type="Buy">
//    <gf:price>
//      <gd:money amount="199" currencycode="USD"/>
//    </gf:price>
//    <gf:commission>
//      <gd:money amount="10" currencycode="USD"/>
//    </gf:commission>
//  </gf:transactionData>
//

@class GDataCommission;
@class GDataPrice;

@interface GDataFinanceTransactionData : GDataObject <GDataExtension>

+ (GDataFinanceTransactionData *)transactionDataWithType:(NSString *)str;

- (NSString *)type;
- (void)setType:(NSString *)str;

- (GDataDateTime *)date;
- (void)setDate:(GDataDateTime *)date;

- (NSString *)notes;
- (void)setNotes:(NSString *)str;

- (NSDecimalNumber *)shares;
- (void)setShares:(NSNumber *)num;

- (GDataCommission *)commission;
- (void)setCommission:(GDataCommission *)obj;

- (GDataPrice *)price;
- (void)setPrice:(GDataPrice *)obj;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_FINANCE_SERVICE
