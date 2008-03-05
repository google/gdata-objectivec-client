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

#import <Foundation/Foundation.h>

@interface GDataUtilities : NSObject 

// utility for removing non-whitespace control characters
+ (NSString *)stringWithControlsFilteredForString:(NSString *)str;

// copy method helpers

// array with copies of the objects in the source array (1-deep)
+ (NSArray *)arrayWithCopiesOfObjectsInArray:(NSArray *)source;

// dicionary with copies of the objects in the source dictionary (1-deep)
+ (NSDictionary *)dictionaryWithCopiesOfObjectsInDictionary:(NSDictionary *)source;

// dictionary with 1-deep copies of the arrays which are the source dictionary's
// values (2-deep)
+ (NSDictionary *)dictionaryWithCopiesOfArraysInDictionary:(NSDictionary *)source;

// URL encoding, different for parts of URLs and parts of URL parameters
// (URL parameters get + in place of spaces)
+ (NSString *)stringByURLEncodingString:(NSString *)str;
+ (NSString *)stringByURLEncodingStringParameter:(NSString *)str;

@end
