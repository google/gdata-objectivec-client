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

static NSString *const kSpreadsheetQueryParamName = @"sq";
static NSString *const kReverseParamName = @"reverse";
static NSString *const kMinRowParamName = @"min-row";
static NSString *const kMaxRowParamName = @"max-row";
static NSString *const kMinColParamName = @"min-col";
static NSString *const kMaxColParamName = @"max-col";
static NSString *const kRangeParamName = @"range";
static NSString *const kReturnEmptyParamName = @"return-empty";

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
  return [self valueForParameterWithName:kSpreadsheetQueryParamName];
}

- (void)setIsReverseSort:(BOOL)isReverse {
  [self addCustomParameterWithName:kReverseParamName
                         boolValue:isReverse
                      defaultValue:NO];
}

- (BOOL)isReverseSort {
  return [self boolValueForParameterWithName:kReverseParamName
                                defaultValue:NO];
}

// cell feed parameters
- (NSString *)stringParamOrNilForInt:(int)val {
  if (val > 0) {
    return [NSString stringWithFormat:@"%d", val]; 
  }
  return nil;
}

- (void)setMinimumRow:(int)val {
  [self addCustomParameterWithName:kMinRowParamName
                             value:[self stringParamOrNilForInt:val]];
}

- (int)minimumRow {
  return [self intValueForParameterWithName:kMinRowParamName
                      missingParameterValue:0];
}

- (void)setMaximumRow:(int)val {
  [self addCustomParameterWithName:kMaxRowParamName
                             value:[self stringParamOrNilForInt:val]];
}

- (int)maximumRow {
  return [self intValueForParameterWithName:kMaxRowParamName
                      missingParameterValue:0];
}


- (void)setMinimumColumn:(int)val {
  [self addCustomParameterWithName:kMinColParamName
                             value:[self stringParamOrNilForInt:val]];
}

- (int)minimumColumn {
  return [self intValueForParameterWithName:kMinColParamName
                      missingParameterValue:0];
}

- (void)setMaximumColumn:(int)val {
  [self addCustomParameterWithName:kMaxColParamName
                             value:[self stringParamOrNilForInt:val]];
}

- (int)maximumColumn {
  return [self intValueForParameterWithName:kMaxColParamName
                      missingParameterValue:0];
}

- (void)setRange:(NSString *)str {
  [self addCustomParameterWithName:kRangeParamName
                             value:str];
}
- (NSString *)range {
  return [self valueForParameterWithName:kRangeParamName];
}

- (void)setShouldReturnEmpty:(BOOL)flag {
  [self addCustomParameterWithName:kReturnEmptyParamName
                         boolValue:flag
                      defaultValue:NO];
}
- (BOOL)shouldReturnEmpty {
  return [self boolValueForParameterWithName:kReturnEmptyParamName
                                defaultValue:NO];
}


@end
