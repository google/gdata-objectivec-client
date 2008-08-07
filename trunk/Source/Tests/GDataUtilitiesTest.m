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

#define typeof __typeof__ // fixes http://www.brethorsting.com/blog/2006/02/stupid-issue-with-ocunit.html

#import "GDataUtilitiesTest.h"

@implementation GDataUtilitiesTest

- (void)testControlsFiltering {
  
  NSString *input;
  NSString *output;
  
  input = nil;
  output = [GDataUtilities stringWithControlsFilteredForString:input];
  STAssertNil(output, @"nil test");
  
  input = @"";
  output = [GDataUtilities stringWithControlsFilteredForString:input];
  STAssertEqualObjects(output, input, @"empty string");
  
  input = @"Fred & Wilma";
  output = [GDataUtilities stringWithControlsFilteredForString:input];
  STAssertEqualObjects(output, input, @"plain string");
  
  input = [NSString stringWithFormat:@"Nuts%CBolts", 0x0B]; // 0xB: vertical tab
  output = [GDataUtilities stringWithControlsFilteredForString:input];
  STAssertEqualObjects(output, @"NutsBolts", @"vt failure");
  
  // filter a string containing all chars from 0x01 to 0x7F
  NSMutableString *allCharStr = [NSMutableString string];
  for (int idx = 1; idx <= 127; idx++) {
    [allCharStr appendFormat:@"%c", idx];
  }
  input = allCharStr;
  output = [GDataUtilities stringWithControlsFilteredForString:input];
  NSString *expected = @"\t\n\r !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLM"
    "NOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
  STAssertEqualObjects(output, expected, @"all-chars failure");
}

- (void)testPercentEncodingUTF8 {
  
  NSString *input;
  NSString *output;
  
  input = nil;
  output = [GDataUtilities stringByPercentEncodingUTF8ForString:input];
  STAssertNil(output, @"nil test");
  
  input = @"";
  output = [GDataUtilities stringByPercentEncodingUTF8ForString:input];
  STAssertEqualObjects(output, input, @"empty string");
    
  input = @"Fred & Wilma";
  output = [GDataUtilities stringByPercentEncodingUTF8ForString:input];
  STAssertEqualObjects(output, input, @"plain string");
  
  input = [NSString stringWithFormat:@"The Beach at S%Cte", 0x00E8];
  output = [GDataUtilities stringByPercentEncodingUTF8ForString:input];
  STAssertEqualObjects(output, @"The Beach at S%C3%A8te", @"8-bit failure");

  input = @"\ttab\tline1\rline2%percent\nline3";
  output = [GDataUtilities stringByPercentEncodingUTF8ForString:input];
  STAssertEqualObjects(output, @"%09tab%09line1%0Dline2%25percent%0Aline3", 
                       @"control char");

  input = [NSString stringWithFormat:@"photo%C.jpg", 0x53C3];
  output = [GDataUtilities stringByPercentEncodingUTF8ForString:input];
  STAssertEqualObjects(output, @"photo%E5%8F%83.jpg", @"cjk failure");
}

@end
