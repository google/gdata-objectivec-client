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
//  GDataQuerySpreadsheet.m
//

#import "GDataQuerySpreadsheet.h"

NSString *const kSpreadsheetQueryParamName = @"sq";
NSString *const kReverseParamName = @"reverse";
NSString *const kMinRowParamName = @"min-row";
NSString *const kMaxRowParamName = @"max-row";
NSString *const kMinColParamName = @"min-col";
NSString *const kMaxColParamName = @"max-col";
NSString *const kRangeParamName = @"range";
NSString *const kReturnEmptyParamName = @"return-empty";

@implementation GDataQuerySpreadsheet

+ (GDataQuerySpreadsheet *)spreadsheetQueryWithFeedURL:(NSURL *)feedURL {
  return [[[self alloc] initWithFeedURL:feedURL] autorelease];   
}


// list feed parameters
- (void)setSpreadsheetQuery:(NSString *)queryStr {
  [self addCustomParameterWithName:kSpreadsheetQueryParamName
                             value:queryStr];
}

- (NSString *)spreadsheetQuery {
  return [[self customParameters] objectForKey:kSpreadsheetQueryParamName];
}

- (void)setIsReverseSort:(BOOL)isReverse {
  [self addCustomParameterWithName:kReverseParamName
                             value:(isReverse ? @"true" : nil)];
}

- (BOOL)isReverseSort {
  NSString *reverse = [[self customParameters] objectForKey:kReverseParamName];
  return reverse && [reverse isEqual:@"true"];
}

// cell feed parameters
- (NSString *)stringParamForInt:(int)val {
  if (val > 0) {
    return [NSString stringWithFormat:@"%d", val]; 
  }
  return nil;
}

- (void)setMinimumRow:(int)val {
  [self addCustomParameterWithName:kMinRowParamName
                             value:[self stringParamForInt:val]];
}

- (int)minimumRow {
  return [[[self customParameters] objectForKey:kMinRowParamName] intValue];
}

- (void)setMaximumRow:(int)val {
  [self addCustomParameterWithName:kMaxRowParamName
                             value:[self stringParamForInt:val]];
}

- (int)maximumRow {
  return [[[self customParameters] objectForKey:kMaxRowParamName] intValue];
}


- (void)setMinimumColumn:(int)val {
  [self addCustomParameterWithName:kMinColParamName
                             value:[self stringParamForInt:val]];
}

- (int)minimumColumn {
  return [[[self customParameters] objectForKey:kMinColParamName] intValue];
}

- (void)setMaximumColumn:(int)val {
  [self addCustomParameterWithName:kMaxColParamName
                             value:[self stringParamForInt:val]];
}

- (int)maximumColumn {
  return [[[self customParameters] objectForKey:kMaxColParamName] intValue];
}

- (void)setRange:(NSString *)str {
  [self addCustomParameterWithName:kRangeParamName
                             value:str];
}
- (NSString *)range {
  return [[self customParameters] objectForKey:kRangeParamName];
}

- (void)setShouldReturnEmpty:(BOOL)flag {
  [self addCustomParameterWithName:kReturnEmptyParamName
                             value:(flag ? @"true" : nil)];
}
- (BOOL)shouldReturnEmpty {
  NSString *reverse = [[self customParameters] objectForKey:kReturnEmptyParamName];
  return reverse && [reverse isEqual:@"true"];
}


@end
