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
//  GDataQueryFinance.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_FINANCE_SERVICE

#import "GDataQueryFinance.h"

#import "GDataServiceGoogleFinance.h"

static NSString *const kReturnsParamName = @"returns";
static NSString *const kPositionsParamName = @"positions";
static NSString *const kTransactionsParamName = @"transactions";

@implementation GDataQueryFinance

+ (GDataQueryFinance *)financeQueryWithFeedURL:(NSURL *)feedURL {
  return [self queryWithFeedURL:feedURL];   
}

#pragma mark -

- (void)setShouldIncludeReturns:(BOOL)flag {
  [self addCustomParameterWithName:kReturnsParamName
                         boolValue:flag
                      defaultValue:NO];
}

- (BOOL)shouldIncludeReturns {
  return [self boolValueForParameterWithName:kReturnsParamName
                                defaultValue:NO];
}

- (void)setShouldIncludePositions:(BOOL)flag {
  [self addCustomParameterWithName:kPositionsParamName
                         boolValue:flag
                      defaultValue:NO];
}

- (BOOL)shouldIncludePositions {
  return [self boolValueForParameterWithName:kPositionsParamName
                                defaultValue:NO];
}

- (void)setShouldIncludeTransactions:(BOOL)flag {
  [self addCustomParameterWithName:kTransactionsParamName
                         boolValue:flag
                      defaultValue:NO];
}

- (BOOL)shouldIncludeTransactions {
  return [self boolValueForParameterWithName:kTransactionsParamName
                                defaultValue:NO];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_FINANCE_SERVICE
