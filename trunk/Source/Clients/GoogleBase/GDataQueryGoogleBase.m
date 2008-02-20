/* Copyright (c) 2007 Google Inc.
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
//  GDataQueryGoogleBase.m
//

#import "GDataQueryGoogleBase.h"

NSString *const kMaxValuesParamName = @"max-values";
NSString *const kSortByParamName = @"sortorder";
NSString *const kBQParamName = @"bq";

@implementation GDataQueryGoogleBase


+ (GDataQueryGoogleBase *)googleBaseQueryWithFeedURL:(NSURL *)feedURL {
  return [[[self alloc] initWithFeedURL:feedURL] autorelease];   
}

- (NSString *)googleBaseQuery {
  NSString *str =  [[self customParameters] objectForKey:kBQParamName];
  return str;
}

- (void)setGoogleBaseQuery:(NSString *)str {
  [self addCustomParameterWithName:kBQParamName value:str];
}

- (int)maxValues {
  int maxVal = 0;
  NSString *str =  [[self customParameters] objectForKey:kMaxValuesParamName];
  if (str) {
    NSScanner *scanner = [NSScanner scannerWithString:str];
    [scanner scanInt:&maxVal];    
  }
  return maxVal;
}

- (void)setMaxValues:(int)val {
  NSNumber *intNum = [NSNumber numberWithInt:val];
  [self addCustomParameterWithName:kMaxValuesParamName
                             value:[intNum stringValue]];
}

@end
