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

#import <SenTestingKit/SenTestingKit.h>

#import "GDataUtilities.h"

@interface GDataUtilitiesTest : SenTestCase
@end

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

- (void)testUserAgentStringCleansing {

  NSString *input;
  NSString *output;

  input = nil;
  output = [GDataUtilities userAgentStringForString:input];
  STAssertNil(output, @"nil test");

  input = @"";
  output = [GDataUtilities userAgentStringForString:input];
  STAssertEqualObjects(output, @"", @"empty string");

  input = @"\\iPod ({Touch])\n\r";
  output = [GDataUtilities userAgentStringForString:input];
  STAssertEqualObjects(output, @"iPod_Touch", @"user agent is unclean");
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

- (void)testURLEncodingForURI {
  NSString *input;
  NSString *output;
  NSString *expected;

  input = nil;
  output = [GDataUtilities stringByURLEncodingForURI:input];
  STAssertNil(output, @"nil test");

  input = @"";
  output = [GDataUtilities stringByURLEncodingForURI:input];
  STAssertEqualObjects(output, input, @"empty string");

  input = @"abcdef";
  output = [GDataUtilities stringByURLEncodingForURI:input];
  expected = @"abcdef";
  STAssertEqualObjects(output, expected, @"plain string");

  input = @"abc def";
  output = [GDataUtilities stringByURLEncodingForURI:input];
  expected = @"abc%20def";
  STAssertEqualObjects(output, expected, @"plain string with space");

  input = @"abc!*'();:@&=+$,/?%#[]def";
  output = [GDataUtilities stringByURLEncodingForURI:input];
  expected = @"abc%21%2A%27%28%29%3B%3A%40%26%3D%2B%24%2C%2F%3F%25%23%5B%5Ddef";
  STAssertEqualObjects(output, expected, @"all chars to escape");
}

- (void)testURLEncodingForStringParameter {
  NSString *input;
  NSString *output;
  NSString *expected;

  input = nil;
  output = [GDataUtilities stringByURLEncodingStringParameter:input];
  STAssertNil(output, @"nil test");

  input = @"";
  output = [GDataUtilities stringByURLEncodingStringParameter:input];
  STAssertEqualObjects(output, input, @"empty string");

  input = @"abcdef";
  output = [GDataUtilities stringByURLEncodingStringParameter:input];
  expected = @"abcdef";
  STAssertEqualObjects(output, expected, @"plain string");

  input = @"abc def";
  output = [GDataUtilities stringByURLEncodingStringParameter:input];
  expected = @"abc+def";
  STAssertEqualObjects(output, expected, @"plain string with space");

  input = @"abc!*'();:@&=+$,/?%#[]def";
  output = [GDataUtilities stringByURLEncodingStringParameter:input];
  expected = @"abc%21%2A%27%28%29%3B%3A%40%26%3D%2B%24%2C%2F%3F%25%23%5B%5Ddef";
  STAssertEqualObjects(output, expected, @"all chars to escape");
}

#pragma mark -

- (void)doTestEqualAndDistinctElementsInArray:(NSArray *)testArray
                                 andArrayCopy:(NSArray *)copyArray {

  NSUInteger numItems = [testArray count];

  // test that we got an equal copy
  STAssertEqualObjects(copyArray, testArray,
                       @"Array copy failed (%lu items)",
                       (unsigned long) numItems);

  // check that the objects in the copy are actual copies, not retains
  // of the original objects
  NSEnumerator *enumTest = [testArray objectEnumerator];
  NSEnumerator *enumCopy = [copyArray objectEnumerator];

  id objTest = [enumTest nextObject];
  id objCopy = [enumCopy nextObject];

  while (objTest) {
    STAssertTrue(objTest != objCopy,
                  @"array copy is reusing original object (%lu items)",
                 (unsigned long) numItems);

    objTest = [enumTest nextObject];
    objCopy = [enumCopy nextObject];
  }
}

- (void)doArrayCopyTestsForArray:(NSArray *)testArray {

  NSUInteger numItems = [testArray count];

  // immutable copy
  id copyArray = [GDataUtilities arrayWithCopiesOfObjectsInArray:testArray];

  [self doTestEqualAndDistinctElementsInArray:testArray
                                 andArrayCopy:copyArray];

  // mutable copy
  copyArray = [GDataUtilities mutableArrayWithCopiesOfObjectsInArray:testArray];

  [self doTestEqualAndDistinctElementsInArray:testArray
                                 andArrayCopy:copyArray];

  // test that copy is mutable (isKindOfClass: will fail on the class
  // cluster, so brute-force it)
  @try {
    [copyArray addObject:@"foo"];
  }
  @catch(NSException *exc) {
    STFail(@"Array mutableCopy not mutable (%lu items)",
           (unsigned long) numItems);
  }
}

- (void)doTestEqualAndDistinctElementsInDictionary:(NSDictionary *)testDict
                                 andDictionaryCopy:(NSDictionary *)copyDict {

  NSUInteger numItems = [testDict count];

  // test that we got an equal copy
  STAssertEqualObjects(copyDict, testDict,
                       @"Dict copy failed (%lu items)",
                       (unsigned long) numItems);

  // check that the objects in the copy are actual copies, not retains
  // of the original objects
  NSEnumerator *enumTestKeys = [testDict keyEnumerator];

  id testKey = [enumTestKeys nextObject];
  while (testKey) {
    id objTest = [testDict objectForKey:testKey];
    id objCopy = [copyDict objectForKey:testKey];

    STAssertTrue(objTest != objCopy,
                  @"dict copy is reusing original object (%lu items)",
                 (unsigned long) numItems);

    // if the elements are arrays, apply the array comparison too
    if ([objTest isKindOfClass:[NSArray class]]) {

     [self doTestEqualAndDistinctElementsInArray:objTest
                                    andArrayCopy:objCopy];
    }

    testKey = [enumTestKeys nextObject];
  }
}


- (void)doDictionaryCopyTestsForDictionary:(NSDictionary *)testDict {

  NSUInteger numItems = [testDict count];

  // immutable copy
  id copyDict = [GDataUtilities dictionaryWithCopiesOfObjectsInDictionary:testDict];

  [self doTestEqualAndDistinctElementsInDictionary:testDict
                                 andDictionaryCopy:copyDict];

  // mutable copy
  copyDict = [GDataUtilities mutableDictionaryWithCopiesOfObjectsInDictionary:testDict];

  [self doTestEqualAndDistinctElementsInDictionary:testDict
                                 andDictionaryCopy:copyDict];

  // test that copy is mutable (isKindOfClass: will fail on the class
  // cluster, so brute-force it)
  @try {
     [copyDict setObject:@"foo" forKey:@"bar"];
  }
  @catch(NSException *exc) {
    STFail(@"Dict mutableCopy not mutable (%lu items)", (unsigned long) numItems);
  }
}


- (void)doDictionaryOfArraysCopyTestsForDictionary:(NSDictionary *)testDict {

  NSUInteger numItems = [testDict count];

  // immutable copy
  id copyDict = [GDataUtilities dictionaryWithCopiesOfArraysInDictionary:testDict];

  [self doTestEqualAndDistinctElementsInDictionary:testDict
                                 andDictionaryCopy:copyDict];

  // mutable copy
  copyDict = [GDataUtilities mutableDictionaryWithCopiesOfArraysInDictionary:testDict];

  [self doTestEqualAndDistinctElementsInDictionary:testDict
                                 andDictionaryCopy:copyDict];

  // test that copy is mutable
  @try {
    [copyDict setObject:@"foo" forKey:@"bar"];
  }
  @catch(NSException *exc) {
    STFail(@"Dict of arrays mutableCopy not mutable (%lu items)",
           (unsigned long) numItems);
  }
}


- (void)testCollectionCopying {

  // test array copies

  // mutable strings, when copied, will have unique pointers rather than
  // just increased refCounts, so we can ensure we made a copy of the
  // strings
  NSMutableString *str1 = [NSMutableString stringWithString:@"one"];
  NSMutableString *str2 = [NSMutableString stringWithString:@"two"];
  NSMutableString *str3 = [NSMutableString stringWithString:@"three"];

  NSArray *zeroArray = [NSArray array];
  NSArray *oneArray = [NSArray arrayWithObject:str1];
  NSArray *twoArray = [NSArray arrayWithObjects:str2, str3, nil];

  [self doArrayCopyTestsForArray:zeroArray];
  [self doArrayCopyTestsForArray:oneArray];
  [self doArrayCopyTestsForArray:twoArray];


  // test dictionary copies
  NSMutableDictionary *zeroDict = [NSMutableDictionary dictionary];
  NSMutableDictionary *oneDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  str1, @"1", nil];
  NSMutableDictionary *twoDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  str2, @"2", str3, @"3", nil];
  [self doDictionaryCopyTestsForDictionary:zeroDict];
  [self doDictionaryCopyTestsForDictionary:oneDict];
  [self doDictionaryCopyTestsForDictionary:twoDict];

  // test dictionary-of-arrays copies
  NSMutableDictionary *zeroArrayDict = [NSMutableDictionary dictionary];
  NSMutableDictionary *oneArrayDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       oneArray, @"1a", nil];
  NSMutableDictionary *twoArrayDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       oneArray, @"1aa", twoArray, @"2aa", nil];

  [self doDictionaryOfArraysCopyTestsForDictionary:zeroArrayDict];
  [self doDictionaryOfArraysCopyTestsForDictionary:oneArrayDict];
  [self doDictionaryOfArraysCopyTestsForDictionary:twoArrayDict];
}

@end
