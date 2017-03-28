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

#define typeof __typeof__ // fixes http://www.brethorsting.com/blog/2006/02/stupid-issue-with-ocunit.html

#import <XCTest/XCTest.h>

#import "GDataFramework.h"

@interface GDataFrameworkTest : XCTestCase
@end

@implementation GDataFrameworkTest

- (void)testFrameworkVersion {

  NSUInteger major = NSUIntegerMax;
  NSUInteger minor = NSUIntegerMax;
  NSUInteger release = NSUIntegerMax;

  GDataFrameworkVersion(&major, &minor, &release);

  XCTAssertTrue(major != NSUIntegerMax, @"version unset");
  XCTAssertTrue(minor != NSUIntegerMax, @"version unset");
  XCTAssertTrue(release != NSUIntegerMax, @"version unset");

  // Check that the Framework bundle's Info.plist has the proper version,
  // matching the GDataFrameworkVersion call

  // The unit test target should copy the framework bundle to the test resources directory.
  NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
  NSString *resourcesPath = [testBundle resourcePath];
  NSString *frameworkPath = [resourcesPath stringByAppendingPathComponent:@"GData.framework"];
  NSBundle *frameworkBundle = [NSBundle bundleWithPath:frameworkPath];
  NSDictionary *infoDict = [frameworkBundle infoDictionary];

  XCTAssertNotNil(infoDict, @"Could not find GDataFramework-Info.plist");

  if (infoDict) {

    NSString *binaryVersionStr = GDataFrameworkVersionString();

    NSString *plistVersionStr = [infoDict valueForKey:@"CFBundleVersion"];

    XCTAssertEqualObjects(plistVersionStr, binaryVersionStr,
                         @"Binary/plist version mismatch");
  }
}

@end
