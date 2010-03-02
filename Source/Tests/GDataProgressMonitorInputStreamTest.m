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
//  GDataProgressMonitorInputStreamTest.m
//

#import <SenTestingKit/SenTestingKit.h>

#import "GDataDefines.h"

#import "GDataProgressMonitorInputStream.h"

#define typeof __typeof__ // fixes http://www.brethorsting.com/blog/2006/02/stupid-issue-with-ocunit.html

@interface GDataProgressMonitorInputStreamTest : SenTestCase {
  NSMutableArray *callbackProgressArray_; // non-retained
  unsigned long long dataSize_;
}
@end

@implementation GDataProgressMonitorInputStreamTest

- (void)testGDataProgressMonitorInputStream {
  
  // make some data with lotsa bytes
  NSMutableData *data = [NSMutableData data];
  for (int idx = 0; idx < 100; idx++) {
    const char *str = "abcdefghijklmnopqrstuvwxyz ";
    [data appendBytes:str length:strlen(str)]; 
  }
  dataSize_ = [data length];
  
  // make a stream for the data
  NSInputStream *dataStream = [NSInputStream inputStreamWithData:data];
  
  // make a monitor stream, with self as the delegate
  GDataProgressMonitorInputStream *progressStream;
  progressStream = [GDataProgressMonitorInputStream inputStreamWithStream:dataStream
                                                                   length:[data length]];
  SEL theSel = @selector(inputStream:hasDeliveredBytes:ofTotalBytes:);
  [progressStream setMonitorDelegate:self];
  [progressStream setMonitorSelector:theSel];
  [progressStream setMonitorSource:self];
  
  // we'll make arrays to hold NSNumbers for expected and actual progress
  // reports
  NSMutableArray *actualProgressArray = [NSMutableArray array];
  callbackProgressArray_ = [NSMutableArray array]; // autoreleased 

  // now read random size chunks of data and append them to a mutable NSData
  srandomdev();
  NSMutableData *readData = [NSMutableData data];
  
  [progressStream open];
  while ([progressStream hasBytesAvailable]) {
    
    unsigned char buffer[101];
    NSUInteger numBytesToRead = (arc4random() % 100) + 1;
    
    NSInteger numRead = [progressStream read:buffer maxLength:numBytesToRead];
    if (numRead == 0) break;
    
    // append the read chunk to our buffer
    [readData appendBytes:buffer length:numRead];

    // add to the array holding actual total bytes read that
    // the progress callback should be seeing
    NSNumber *num = [NSNumber numberWithUnsignedLongLong:[readData length]];
    [actualProgressArray addObject:num];
  }
  [progressStream close];
  
  // verify we read all the data
  STAssertEqualObjects(data, readData, @"readData doesn't match stream data");
  
  // verify the callback saw the right progress info
  STAssertEqualObjects(callbackProgressArray_, actualProgressArray, 
                       @"callback progress doesn't match actual progress");
}


- (void)inputStream:(GDataProgressMonitorInputStream *)stream 
  hasDeliveredBytes:(unsigned long long)numRead
       ofTotalBytes:(unsigned long long)total {
  
  STAssertEquals(total, dataSize_, @"callback gets wrong data size");
  
  STAssertEqualObjects([stream monitorSource], self, @"monitor source wrong");
  
  // add to the array of progress we actually see
  NSNumber *num = [NSNumber numberWithUnsignedLongLong:numRead];
  [callbackProgressArray_ addObject:num];
}
@end

