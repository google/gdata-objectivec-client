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
//  GDataEntryFinancePortfolio.h
//

#import "GDataEntryBase.h"


// We define constant symbols in the main entry class for the client service

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAENTRYFINANCEPORTFOLIO_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* kGDataNamespaceFinance       _INITIALIZE_AS(@"http://schemas.google.com/finance/2007");
_EXTERN NSString* kGDataNamespaceFinancePrefix _INITIALIZE_AS(@"gf");

_EXTERN NSString* kGDataCategoryFinancePortfolio    _INITIALIZE_AS(@"http://schemas.google.com/finance/2007#portfolio");
_EXTERN NSString* kGDataCategoryFinancePosition     _INITIALIZE_AS(@"http://schemas.google.com/finance/2007#position");
_EXTERN NSString* kGDataCategoryFinanceTransaction  _INITIALIZE_AS(@"http://schemas.google.com/finance/2007#transaction");


@class GDataPortfolioData;
@class GDataFeedLink;

@interface GDataEntryFinancePortfolio : GDataEntryBase

+ (NSDictionary *)financeNamespaces;

+ (GDataEntryFinancePortfolio *)portfolioEntry;

// extensions
- (void)setPortfolioData:(GDataPortfolioData *)obj;
- (GDataPortfolioData *)portfolioData;

- (void)setFeedLink:(GDataFeedLink *)feedLink;
- (GDataFeedLink *)feedLink;  

// convenience accessor

- (NSURL *)positionURL; // from the feedLink's href attribute

@end
