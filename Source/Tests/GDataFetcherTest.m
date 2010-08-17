/* Copyright (c) 2009 Google Inc.
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
//  GDataFetcherTest.m
//

#import <SenTestingKit/SenTestingKit.h>

#import "GData.h"

#define typeof __typeof__ // fixes http://brethorsting.com/blog/2006/02/25/stupid-issue-with-ocunit/


// copies of interfaces to private fetch history classes
@interface GDataCachedURLResponse : NSObject
- (id)initWithResponse:(NSURLResponse *)response data:(NSData *)data;
- (NSURLResponse *)response;
- (NSData *)data;
- (NSDate *)useDate;
- (void)setUseDate:(NSDate *)date;
- (NSDate *)reservationDate;
- (void)setReservationDate:(NSDate *)date;
@end

@interface GDataURLCache : NSObject
- (id)initWithMemoryCapacity:(NSUInteger)totalBytes;
- (GDataCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request;
- (void)storeCachedResponse:(GDataCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request;
- (void)removeCachedResponseForRequest:(NSURLRequest *)request;
- (void)removeAllCachedResponses;
- (NSUInteger)memoryCapacity;
- (void)setMemoryCapacity:(NSUInteger)totalBytes;
- (NSDictionary *)responses;
- (NSUInteger)totalDataSize;
- (void)setReservationInterval:(NSTimeInterval)secs;
@end

@interface GDataFetcherTest : SenTestCase
@end

@implementation GDataFetcherTest

- (void)testURLCache {
  // allocate a cache that prunes at 30 bytes of response data
  NSUInteger cacheCapacity = 30;
  GDataURLCache *cache = [[[GDataURLCache alloc] initWithMemoryCapacity:cacheCapacity] autorelease];

  // set the reservation interval for our cache to something quick
  const NSTimeInterval resInterval = 0.1;
  [cache setReservationInterval:resInterval];

  // allocate 6 responses with 10 bytes of data each; put a reservation on just
  // the second of the 6
  NSMutableArray *requests = [NSMutableArray array];
  NSMutableArray *cachedResponses = [NSMutableArray array];

  for (int idx = 0; idx < 6; idx++) {
    NSString *urlStr = [NSString stringWithFormat:@"http://example.com/%d", idx];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [requests addObject:request];

    NSURLResponse *response;
    response = [[[NSURLResponse alloc] initWithURL:url
                                          MIMEType:@"text/xml"
                             expectedContentLength:-1
                                  textEncodingName:nil] autorelease];

    GDataCachedURLResponse *cachedResponse;
    NSData *data = [@"1234567890" dataUsingEncoding:NSUTF8StringEncoding];
    STAssertEquals((int)[data length], 10, @"data should be 10 bytes");

    cachedResponse = [[[GDataCachedURLResponse alloc] initWithResponse:response
                                                                  data:data] autorelease];
    [cachedResponses addObject:cachedResponse];
    if (idx == 1) {
      [cachedResponse setReservationDate:[NSDate date]];
    }

    [cache storeCachedResponse:cachedResponse
                    forRequest:request];
  }

  // step through retrieving all previous requests
  //
  // the cache should contain the second response (since it's reserved) and the
  // last two responses
  for (int idx = 0; idx < 6; idx++) {
    NSURLRequest *request = [requests objectAtIndex:idx];
    GDataCachedURLResponse *cachedResponse, *expectedResponse;

    cachedResponse = [cache cachedResponseForRequest:request];
    if (idx == 1 || idx >= 4) {
      expectedResponse = [cachedResponses objectAtIndex:idx];
      STAssertEqualObjects(cachedResponse, expectedResponse, @"wrong response");
    } else {
      // these should be pruned out
      STAssertNil(cachedResponse, @"unexpected response present");
    }
  }

  // wait for the reservation to expire
  [NSThread sleepForTimeInterval:(2 * resInterval)];

  // re-store the first response, with its date set to now; the
  // previously-reserved response should be oldest and thus pruned out
  NSURLRequest *firstRequest = [requests objectAtIndex:0];
  GDataCachedURLResponse *firstResponse = [cachedResponses objectAtIndex:0];
  [firstResponse setUseDate:[NSDate date]];

  [cache storeCachedResponse:firstResponse
                  forRequest:firstRequest];

  // again, step through retrieving all previous requests
  //
  // now the cache should contain the first response and the last two responses
  for (int idx = 0; idx < 6; idx++) {
    NSURLRequest *request = [requests objectAtIndex:idx];
    GDataCachedURLResponse *cachedResponse, *expectedResponse;

    cachedResponse = [cache cachedResponseForRequest:request];
    if (idx == 0 || idx >= 4) {
      expectedResponse = [cachedResponses objectAtIndex:idx];
      STAssertEqualObjects(cachedResponse, expectedResponse, @"wrong response");
    } else {
      // these should be aged out
      STAssertNil(cachedResponse, @"unexpected response present");
    }
  }

  // create a response too big to fit in the cache, and verify that it wasn't
  NSString *hugeUrlStr = [NSString stringWithFormat:@"http://example.com/huge"];
  NSURL *hugeURL = [NSURL URLWithString:hugeUrlStr];
  NSURLRequest *hugeRequest = [NSURLRequest requestWithURL:hugeURL];

  NSURLResponse *response;
  response = [[[NSURLResponse alloc] initWithURL:hugeURL
                                        MIMEType:@"text/xml"
                           expectedContentLength:-1
                                textEncodingName:nil] autorelease];

  NSMutableData *hugeData = [NSMutableData data];
  [hugeData setLength:cacheCapacity];
  GDataCachedURLResponse *hugeResponse;
  hugeResponse = [[[GDataCachedURLResponse alloc] initWithResponse:response
                                                              data:hugeData] autorelease];
  [cache storeCachedResponse:hugeResponse
                  forRequest:hugeRequest];

  // verify that the response wasn't really stored in the cache
  STAssertEquals([[cache responses] count], (NSUInteger)3,
                 @"huge not ignored");
  GDataCachedURLResponse *foundResponse;
  foundResponse = [cache cachedResponseForRequest:hugeRequest];
  STAssertNil(foundResponse, @"huge was cached");

  // make the huge response size just right for pushing everything else out of
  // the cache
  [hugeData setLength:(cacheCapacity - 1)];
  hugeResponse = [[[GDataCachedURLResponse alloc] initWithResponse:response
                                                              data:hugeData] autorelease];
  [cache storeCachedResponse:hugeResponse
                  forRequest:hugeRequest];

  // verify that it crowded out the other responses
  STAssertEquals([[cache responses] count], (NSUInteger)1,
                 @"huge didn't fill the cache");
  foundResponse = [cache cachedResponseForRequest:hugeRequest];
  STAssertNotNil(foundResponse, @"huge was not cached");
}

- (void)testCookieStorage {
  GDataCookieStorage *cookieStorage = [[[GDataCookieStorage alloc] init] autorelease];
  NSArray *foundCookies;

  NSURL *fullURL = [NSURL URLWithString:@"http://photos.example.com"];
  NSURL *subdomainURL = [NSURL URLWithString:@"http://frogbreath.example.com"];

  foundCookies = [cookieStorage cookiesForURL:fullURL];
  STAssertEquals((int)[foundCookies count], 0, @"no cookies expected");

  // make two unique cookies
  NSDictionary *cookie1Props = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"TRUE", NSHTTPCookieDiscard,
                               @"photos.example.com", NSHTTPCookieDomain,
                               @"Snark", NSHTTPCookieName,
                               @"/", NSHTTPCookiePath,
                               @"cook1=foo", NSHTTPCookieValue, nil];
  NSHTTPCookie *testCookie1 = [NSHTTPCookie cookieWithProperties:cookie1Props];

  NSDictionary *cookie2Props = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"FALSE", NSHTTPCookieDiscard,
                                @".example.com", NSHTTPCookieDomain,
                                @"Trump", NSHTTPCookieName,
                                @"/", NSHTTPCookiePath,
                                @"cook2=gnu", NSHTTPCookieValue, nil];
  NSHTTPCookie *testCookie2 = [NSHTTPCookie cookieWithProperties:cookie2Props];

  // make a cookie that would replace cookie 2, and make this one expire
  //
  // expirations have to be in the future or the cookie won't get stored
  NSTimeInterval kExpirationInterval = 0.1;
  NSDate *expiredDate = [NSDate dateWithTimeIntervalSinceNow:0.1];
  NSDictionary *cookie2aProps = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"FALSE", NSHTTPCookieDiscard,
                                @".example.com", NSHTTPCookieDomain,
                                @"Trump", NSHTTPCookieName,
                                @"/", NSHTTPCookiePath,
                                expiredDate, NSHTTPCookieExpires,
                                @"cook2=snu", NSHTTPCookieValue, nil];
  NSHTTPCookie *testCookie2a = [NSHTTPCookie cookieWithProperties:cookie2aProps];

  // store the first two cookies
  NSArray *array = [NSArray arrayWithObjects:
                    testCookie1, testCookie2, nil];
  [cookieStorage setCookies:array];

  foundCookies = [cookieStorage cookiesForURL:fullURL];
  STAssertEquals((int)[foundCookies count], 2, @"full domain cookie retrieval");

  foundCookies = [cookieStorage cookiesForURL:subdomainURL];
  STAssertEquals((int)[foundCookies count], 1, @"subdomain cookie retrieval");

  // store cookie 2a, replacing cookie 2
  array = [NSArray arrayWithObject:testCookie2a];
  [cookieStorage setCookies:array];

  foundCookies = [cookieStorage cookiesForURL:subdomainURL];
  STAssertEquals((int)[foundCookies count], 1, @"subdomain 2a retrieval");

  NSHTTPCookie *foundCookie = [foundCookies lastObject];
  STAssertEquals([foundCookie value], [testCookie2a value],
                 @"cookie replacement");

  // wait for cookie 2a to expire, then remove expired cookies
  [NSThread sleepForTimeInterval:(2 * kExpirationInterval)];
  [cookieStorage removeExpiredCookies];

  foundCookies = [cookieStorage cookiesForURL:subdomainURL];
  STAssertEquals((int)[foundCookies count], 0, @"pruned removal");

  foundCookies = [cookieStorage cookiesForURL:fullURL];
  STAssertEquals((int)[foundCookies count], 1, @"pruned removal remaining");

  // remove all cookies
  [cookieStorage removeAllCookies];
  foundCookies = [cookieStorage cookiesForURL:fullURL];
  STAssertEquals((int)[foundCookies count], 0, @"remove all");
}

@end
