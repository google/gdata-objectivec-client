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
//  GDataNormalPlayTimeTest.m
//

#define typeof __typeof__ // fixes http://www.brethorsting.com/blog/2006/02/stupid-issue-with-ocunit.html

#import <SenTestingKit/SenTestingKit.h>

#import "GDataNormalPlayTime.h"

@interface GDataNormalPlayTimeTest : SenTestCase
@end

@implementation GDataNormalPlayTimeTest

- (void)testGDataNormalPlayTime {
  struct NPTTestRecord {
    NSString *str;
    long long ms;
    BOOL isNow;
    NSString *secondsStr;
    NSString *hhmmssStr;
  };
  
  struct NPTTestRecord tests[] = {
    { @"123", 123000, NO, @"123", @"0:02:03" },
    { @"123.45", 123450, NO, @"123.450", @"0:02:03.450" },
    { @"123.4567", 123456, NO, @"123.456", @"0:02:03.456" },
    { @"0:02:03.456", 123456, NO, @"123.456", @"0:02:03.456" },
    { @"now", -1, YES, @"now", @"now" },
    { @"flubber", 0, NO, @"0", @"0:00:00" },
    { nil, 0, 0, 0, 0 }
  };
  
  int idx;
  for (idx = 0; tests[idx].str != nil; idx++) {
    
    // make an NPT object from the string
    GDataNormalPlayTime *npt = [GDataNormalPlayTime normalPlayTimeWithString:tests[idx].str];
    
    // ensure the ms are as expected
    long long ms = [npt timeOffsetInMilliseconds];
    STAssertEquals(ms, tests[idx].ms, @"unexpected ms for NPT %@", tests[idx].str);
    
    // ensure seconds string is as expected
    NSString *secondsStr = [npt secondsString];  // seconds.fraction or "now"
    STAssertEqualObjects(secondsStr, tests[idx].secondsStr, @"unexpected seconds string for NPT %@", tests[idx].str);
    
    // ensure the HMS strings is as expected
    NSString *hhmmssStr = [npt HHMMSSString];  // hh:mm:ss.fraction or "now"
    STAssertEqualObjects(hhmmssStr, tests[idx].hhmmssStr, @"unexpected HHMMSS string for NPT %@",  tests[idx].str);
    
    // ensure "is now" flag is correct
    BOOL isNow = [npt isNow];
    STAssertTrue(isNow == tests[idx].isNow, @"isNow unexpected for NPT %@", tests[idx].isNow);
  }
  
  // garbage in, zero out
  GDataNormalPlayTime *npt = [GDataNormalPlayTime normalPlayTimeWithString:@"hooyah"];
  STAssertEquals([npt timeOffsetInMilliseconds], 0ll,
                 @"NPT should return 0 for garbage string 'hooyah', got %@ (%qd ms)",
                 npt, [npt timeOffsetInMilliseconds]);
}
@end
