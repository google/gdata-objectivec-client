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
//  GDataQueryBooks.h
//

#import "GDataQuery.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAQUERYBOOKS_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* kGDataGoogleBooksMinViewabilityFull    _INITIALIZE_AS(@"full");
_EXTERN NSString* kGDataGoogleBooksMinViewabilityNone    _INITIALIZE_AS(@"none");
_EXTERN NSString* kGDataGoogleBooksMinViewabilityPartial _INITIALIZE_AS(@"partial");

@interface GDataQueryBooks : GDataQuery 
  
+ (GDataQueryBooks *)booksQueryWithFeedURL:(NSURL *)feedURL;

- (void)setMinimumViewability:(NSString *)str;
- (NSString *)minimumViewability;

@end

