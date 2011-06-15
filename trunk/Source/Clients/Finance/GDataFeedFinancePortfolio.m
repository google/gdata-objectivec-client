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
//  GDataFeedFinancePortfolio.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_FINANCE_SERVICE

#import "GDataFeedFinancePortfolio.h"
#import "GDataEntryFinancePortfolio.h"

@implementation GDataFeedFinancePortfolio

+ (GDataFeedFinancePortfolio *)portfolioFeed {
  
  GDataFeedFinancePortfolio *feed = [self object];
  
  [feed setNamespaces:[GDataEntryFinancePortfolio financeNamespaces]];
  
  return feed;
}

+ (NSString *)standardFeedKind {
  return kGDataCategoryFinancePortfolio;
}

+ (void)load {
  [self registerFeedClass];
}

- (Class)classForEntries {
  return [GDataEntryFinancePortfolio class]; 
}

+ (NSString *)defaultServiceVersion {
  return kGDataFinanceDefaultServiceVersion;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_FINANCE_SERVICE
