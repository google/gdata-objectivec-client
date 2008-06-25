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

#import "GDataQueryFinance.h"

#import "GDataServiceGoogleFinance.h"

static NSString *const kReturnsParamName = @"returns";
static NSString *const kPositionsParamName = @"positions";
static NSString *const kTransactionsParamName = @"transactions";

@implementation GDataQueryFinance

+ (GDataQueryFinance *)financeQueryWithFeedURL:(NSURL *)feedURL {
  return [[[self alloc] initWithFeedURL:feedURL] autorelease];   
}

#pragma mark -

- (void)setShouldIncludeReturns:(BOOL)flag {
  [self addCustomParameterWithName:kReturnsParamName
                             value:(flag ? @"true" : nil)];
}

- (BOOL)shouldIncludeReturns {
  NSString *str = [[self customParameters] objectForKey:kReturnsParamName];
  return str && [str isEqual:@"true"];
}

- (void)setShouldIncludePositions:(BOOL)flag {
  [self addCustomParameterWithName:kPositionsParamName
                             value:(flag ? @"true" : nil)];
}

- (BOOL)shouldIncludePositions {
  NSString *str = [[self customParameters] objectForKey:kPositionsParamName];
  return str && [str isEqual:@"true"];
}

- (void)setShouldIncludeTransactions:(BOOL)flag {
  [self addCustomParameterWithName:kTransactionsParamName
                             value:(flag ? @"true" : nil)];
}

- (BOOL)shouldIncludeTransactions {
  NSString *str = [[self customParameters] objectForKey:kTransactionsParamName];
  return str && [str isEqual:@"true"];
}

@end
