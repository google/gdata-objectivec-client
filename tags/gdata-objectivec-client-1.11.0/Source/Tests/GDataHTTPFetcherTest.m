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

// service tests are slow, so we might skip them when developing other
// unit tests
#if !GDATA_SKIPSERVICETEST

#import <SenTestingKit/SenTestingKit.h>

#import "GDataHTTPFetcher.h"

static int kServerPortNumber = 54579;
extern NSTask *StartHTTPServerTask(int portNumber);

@interface GDataHTTPFetcherTest : SenTestCase {

  // these ivars are checked after fetches, and are reset by resetFetchResponse
  NSData *fetchedData_;
  NSError *fetcherError_;
  int fetchedStatus_;
  NSURLResponse *fetchedResponse_;
  NSMutableURLRequest *fetchedRequest_;
  int retryCounter_;

  // setup/teardown ivars
  GDataHTTPFetchHistory *fetchHistory_;
  NSTask *testServer_;
  BOOL isServerRunning_;
}

- (void)testFetch;
- (void)testWrongFetch;
- (void)testRetryFetches;

- (GDataHTTPFetcher *)doFetchWithURLString:(NSString *)urlString
                          cachingDatedData:(BOOL)doCaching;

- (GDataHTTPFetcher *)doFetchWithURLString:(NSString *)urlString
                          cachingDatedData:(BOOL)doCaching
                             retrySelector:(SEL)retrySel
                          maxRetryInterval:(NSTimeInterval)maxRetryInterval
                                credential:(NSURLCredential *)credential
                        downloadFileHandle:(NSFileHandle *)fileHandle
                                  userData:(id)userData;

- (NSString *)fileURLStringToTestFileName:(NSString *)name;
@end

@implementation GDataHTTPFetcherTest

static const NSTimeInterval kRunLoopInterval = 0.01;

//  The wrong-fetch test can take >10s to pass.
static const NSTimeInterval kGiveUpInterval = 30.0;

// file available in Tests folder
static NSString *const kValidFileName = @"FeedYouTubeVideo1.xml";
static NSString *const kBasicAuthFileName = @"FeedYouTubeVideo1.xml.authwww";

- (void)setUp {
  fetchHistory_ = [[GDataHTTPFetchHistory alloc] init];

  testServer_ = StartHTTPServerTask(kServerPortNumber);
  isServerRunning_ = (testServer_ != nil);

  STAssertTrue(isServerRunning_,
               @">>> Python http test server failed to launch; skipping"
               " fetcher tests\n");
}

- (void)resetFetchResponse {
  [fetchedData_ release];
  fetchedData_ = nil;

  [fetcherError_ release];
  fetcherError_ = nil;

  [fetchedRequest_ release];
  fetchedRequest_ = nil;

  [fetchedResponse_ release];
  fetchedResponse_ = nil;

  fetchedStatus_ = 0;

  retryCounter_ = 0;
}

- (void)tearDown {
  [testServer_ terminate];
  [testServer_ waitUntilExit];
  [testServer_ release];
  testServer_ = nil;

  isServerRunning_ = NO;

  [self resetFetchResponse];

  [fetchHistory_ release];
  fetchHistory_ = nil;
}

- (void)testFetch {

  if (!isServerRunning_) return;

  NSString *urlString = [self fileURLStringToTestFileName:kValidFileName];

  [self doFetchWithURLString:urlString cachingDatedData:YES];

  STAssertNotNil(fetchedData_,
                 @"failed to fetch data, status:%d error:%@, URL:%@",
                 fetchedStatus_, fetcherError_, urlString);
  STAssertNotNil(fetchedResponse_,
                 @"failed to get fetch response, status:%d error:%@",
                 fetchedStatus_, fetcherError_);
  STAssertNotNil(fetchedRequest_,
                 @"failed to get fetch request, URL %@", urlString);
  STAssertNil(fetcherError_, @"fetching data gave error: %@", fetcherError_);
  STAssertTrue(fetchedStatus_ == 200,
               @"fetching data expected status 200, instead got %d, for URL %@",
               fetchedStatus_, urlString);

  // no cookies should be sent with our first request
  NSDictionary *headers = [fetchedRequest_ allHTTPHeaderFields];
  NSString *cookiesSent = [headers objectForKey:@"Cookie"];
  STAssertNil(cookiesSent, @"Cookies sent unexpectedly: %@", cookiesSent);


  // cookies should have been set by the response; specifically, TestCookie
  // should be set to the name of the file requested
  NSDictionary *responseHeaders;

  responseHeaders = [(NSHTTPURLResponse *)fetchedResponse_ allHeaderFields];
  NSString *cookiesSetString = [responseHeaders objectForKey:@"Set-Cookie"];
  NSString *cookieExpected = [NSString stringWithFormat:@"TestCookie=%@",
    kValidFileName];
  STAssertEqualObjects(cookiesSetString, cookieExpected, @"Unexpected cookie");

  // make a copy of the fetched data to compare with our next fetch from the
  // cache
  NSData *originalFetchedData = [[fetchedData_ copy] autorelease];

  // Now fetch again so the "If modified since" header will be set (because
  // we're calling setFetchHistory: below) and caching ON, and verify that we
  // got a good data from the cache, along with a "Not modified" status

  [self resetFetchResponse];

  [self doFetchWithURLString:urlString cachingDatedData:YES];

  STAssertEqualObjects(fetchedData_, originalFetchedData,
                       @"cache data mismatch");

  STAssertNotNil(fetchedData_,
                 @"failed to fetch data, status:%d error:%@, URL:%@",
                 fetchedStatus_, fetcherError_, urlString);
  STAssertNotNil(fetchedResponse_,
                 @"failed to get fetch response, status:%d error:%@",
                 fetchedStatus_, fetcherError_);
  STAssertNotNil(fetchedRequest_,
                 @"failed to get fetch request, URL %@",
                 urlString);
  STAssertNil(fetcherError_, @"fetching data gave error: %@", fetcherError_);

  STAssertTrue(fetchedStatus_ == kGDataHTTPFetcherStatusNotModified, // 304
               @"fetching data expected status 304, instead got %d, for URL %@",
               fetchedStatus_, urlString);

  // the TestCookie set previously should be sent with this request
  cookiesSent = [[fetchedRequest_ allHTTPHeaderFields] objectForKey:@"Cookie"];
  STAssertEqualObjects(cookiesSent, cookieExpected, @"Cookie not sent");

  // Now fetch twice without caching enabled, and verify that we got a
  // "Not modified" status, along with a non-nil but empty NSData (which
  // is normal for that status code)

  [self resetFetchResponse];

  [fetchHistory_ clearHistory];

  [self doFetchWithURLString:urlString cachingDatedData:NO];

  STAssertEqualObjects(fetchedData_, originalFetchedData,
                       @"cache data mismatch");

  [self resetFetchResponse];
  [self doFetchWithURLString:urlString cachingDatedData:NO];

  STAssertNotNil(fetchedData_, @"");
  STAssertTrue(0 == [fetchedData_ length], @"unexpected data");
  STAssertTrue(fetchedStatus_ == kGDataHTTPFetcherStatusNotModified ,
         @"fetching data expected status 304, instead got %d", fetchedStatus_);
  STAssertNil(fetcherError_, @"unexpected error: %@", fetcherError_);

  // Fetch requiring basic auth
  //
  // attempt first without the auth name/password, then attempt with them
  [self resetFetchResponse];
  [fetchHistory_ clearHistory];

  NSString *authURLString = [self fileURLStringToTestFileName:kBasicAuthFileName];
  [self doFetchWithURLString:authURLString
            cachingDatedData:NO
               retrySelector:nil
            maxRetryInterval:0
                  credential:nil
          downloadFileHandle:nil
                    userData:nil]; // should fail

  STAssertNil(fetchedData_, @"unexpected data");
  STAssertTrue(fetchedStatus_ == 0,
               @"fetching data expected status 0, instead got %d",
               fetchedStatus_);
  STAssertNil(fetchedResponse_, @"expected response");
  STAssertNotNil(fetcherError_, @"missing error");

  [self resetFetchResponse];

  NSURLCredential *credential;
  credential = [[[NSURLCredential alloc] initWithUser:@"GoodWWWUser"
                                             password:@"GoodWWWPassword"
                                          persistence:NSURLCredentialPersistenceNone] autorelease];
  [self doFetchWithURLString:authURLString
            cachingDatedData:NO
               retrySelector:nil
            maxRetryInterval:0
                  credential:credential
          downloadFileHandle:nil
                    userData:nil]; // should succeed

  STAssertNotNil(fetchedData_, @"failed to fetch data, status:%d error:%@, URL:%@",
              fetchedStatus_, fetcherError_, urlString);
  STAssertTrue(fetchedStatus_ == 200,
               @"fetching data expected status 200, instead got %d", fetchedStatus_);
  STAssertNotNil(fetchedResponse_,
                 @"failed to get fetch response, status:%d error:%@",
                 fetchedStatus_, fetcherError_);
  STAssertNotNil(fetchedRequest_,
                 @"failed to get fetch request, URL %@", urlString);
}

- (void)testFetchToFileHandle {
  if (!isServerRunning_) return;

  // create an empty file from which we can make an NSFileHandle
  NSString *path = [NSTemporaryDirectory() stringByAppendingFormat:@"fhTest_%u",
                    TickCount()];
  [[NSData data] writeToFile:path atomically:YES];

  NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
  STAssertNotNil(fileHandle, @"missing filehandle for %@", path);

  // make the http request to our test server
  NSString *urlString = [self fileURLStringToTestFileName:kValidFileName];

  [self doFetchWithURLString:urlString
            cachingDatedData:NO
               retrySelector:nil
            maxRetryInterval:0
                  credential:nil
          downloadFileHandle:fileHandle
                    userData:nil];

  STAssertNil(fetchedData_, @"unexpected data");
  STAssertNil(fetcherError_, @"unexpected error");

  NSString *fetchedContents = [NSString stringWithContentsOfFile:path
                                                        encoding:NSUTF8StringEncoding
                                                           error:NULL];
  NSString *origPath = [NSString stringWithFormat:@"Tests/%@", kValidFileName];
  NSString *origContents = [NSString stringWithContentsOfFile:origPath
                                                     encoding:NSUTF8StringEncoding
                                                        error:NULL];
  STAssertEqualObjects(fetchedContents, origContents, @"fetch to FH error");
}

- (void)testWrongFetch {

  if (!isServerRunning_) return;

  // fetch a live, invalid URL
  NSString *badURLString = @"http://localhost:86/";
  [self doFetchWithURLString:badURLString cachingDatedData:NO];

  const int kServiceUnavailableStatus = 503;

  if (fetchedStatus_ == kServiceUnavailableStatus) {
    // our internal Google proxy gives a "service unavailable" error
    // for bogus fetches
  } else {

    if (fetchedData_) {
      NSString *str = [[[NSString alloc] initWithData:fetchedData_
                                             encoding:NSUTF8StringEncoding] autorelease];
      STAssertNil(fetchedData_, @"fetched unexpected data: %@", str);
    }

    STAssertNotNil(fetcherError_, @"failed to receive fetching error");
    STAssertTrue(fetchedStatus_ == 0,
                 @"fetching data expected no status from no response, instead got %d",
                 fetchedStatus_);
  }

  // fetch with a specific status code from our http server
  [self resetFetchResponse];

  NSString *invalidWebPageFile = [kValidFileName stringByAppendingString:@"?status=400"];
  NSString *statusUrlString = [self fileURLStringToTestFileName:invalidWebPageFile];

  [self doFetchWithURLString:statusUrlString cachingDatedData:NO];

  STAssertNotNil(fetchedData_, @"fetch lacked data with error info");
  STAssertNil(fetcherError_, @"expected bad status but got an error");
  STAssertEquals(fetchedStatus_, 400,
                 @"unexpected status, error=%@", fetcherError_);
}

- (void)testRetryFetches {

  if (!isServerRunning_) return;

  GDataHTTPFetcher *fetcher;

  NSString *invalidFile = [kValidFileName stringByAppendingString:@"?status=503"];
  NSString *urlString = [self fileURLStringToTestFileName:invalidFile];

  SEL countRetriesSel = @selector(countRetriesfetcher:willRetry:forError:);
  SEL fixRequestSel = @selector(fixRequestFetcher:willRetry:forError:);

  //
  // test: retry until timeout, then expect failure with status message
  //

  NSNumber *lotsOfRetriesNumber = [NSNumber numberWithInt:1000];

  fetcher= [self doFetchWithURLString:urlString
                     cachingDatedData:NO
                        retrySelector:countRetriesSel
                     maxRetryInterval:5.0 // retry intervals of 1, 2, 4
                           credential:nil
                   downloadFileHandle:nil
                             userData:lotsOfRetriesNumber];

  STAssertNotNil(fetchedData_, @"error data is expected");
  STAssertEquals(fetchedStatus_, 503,
                 @"fetchedStatus_ should be 503, was %@", fetchedStatus_);
  STAssertEquals([fetcher retryCount], (unsigned) 3, @"retry count unexpected");

  //
  // test:  retry twice, then give up
  //
  [self resetFetchResponse];

  NSNumber *twoRetriesNumber = [NSNumber numberWithInt:2];

  fetcher= [self doFetchWithURLString:urlString
                     cachingDatedData:NO
                        retrySelector:countRetriesSel
                     maxRetryInterval:10.0 // retry intervals of 1, 2, 4, 8
                           credential:nil
                   downloadFileHandle:nil
                             userData:twoRetriesNumber];

  STAssertNotNil(fetchedData_, @"error data is expected");
  STAssertEquals(fetchedStatus_, 503,
                 @"fetchedStatus_ should be 503, was %@", fetchedStatus_);
  STAssertEquals([fetcher retryCount], (unsigned) 2, @"retry count unexpected");


  //
  // test:  retry, making the request succeed on the first retry
  //        by fixing the URL
  //
  [self resetFetchResponse];

  fetcher= [self doFetchWithURLString:urlString
                     cachingDatedData:NO
                        retrySelector:fixRequestSel
                     maxRetryInterval:30.0 // should only retry once due to selector
                           credential:nil
                   downloadFileHandle:nil
                             userData:lotsOfRetriesNumber];

  STAssertNotNil(fetchedData_, @"data is expected");
  STAssertEquals(fetchedStatus_, 200,
                 @"fetchedStatus_ should be 200, was %@", fetchedStatus_);
  STAssertEquals([fetcher retryCount], (unsigned) 1, @"retry count unexpected");
}

#pragma mark -

- (GDataHTTPFetcher *)doFetchWithURLString:(NSString *)urlString
                          cachingDatedData:(BOOL)doCaching {

  return [self doFetchWithURLString:(NSString *)urlString
                   cachingDatedData:doCaching
                      retrySelector:nil
                   maxRetryInterval:0
                         credential:nil
                 downloadFileHandle:nil
                           userData:nil];
}

- (GDataHTTPFetcher *)doFetchWithURLString:(NSString *)urlString
                          cachingDatedData:(BOOL)doCaching
                             retrySelector:(SEL)retrySel
                          maxRetryInterval:(NSTimeInterval)maxRetryInterval
                                credential:(NSURLCredential *)credential
                        downloadFileHandle:(NSFileHandle *)fileHandle
                                  userData:(id)userData {
  
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLRequest *req = [NSURLRequest requestWithURL:url
                                       cachePolicy:NSURLRequestReloadIgnoringCacheData
                                   timeoutInterval:kGiveUpInterval];
  GDataHTTPFetcher *fetcher = [GDataHTTPFetcher httpFetcherWithRequest:req];

  STAssertNotNil(fetcher, @"Failed to allocate fetcher");

  // setting the fetch history will add the "If-modified-since" header
  // to repeat requests
  [fetcher setFetchHistory:fetchHistory_];
  [fetcher setShouldCacheDatedData:doCaching];

  if (retrySel) {
    [fetcher setIsRetryEnabled:YES];
    [fetcher setRetrySelector:retrySel];
    [fetcher setMaxRetryInterval:maxRetryInterval];
    [fetcher setUserData:userData];

    // we force a minimum retry interval for unit testing; otherwise,
    // we'd have no idea how many retries will occur before the max
    // retry interval occurs, since the minimum would be random
    [fetcher setMinRetryInterval:1.0];
  }

  [fetcher setCredential:credential];
  [fetcher setDownloadFileHandle:fileHandle];

  BOOL isFetching = [fetcher beginFetchWithDelegate:self
                                  didFinishSelector:@selector(testFetcher:finishedWithData:)
                          didFailWithStatusSelector:@selector(testFetcher:failedWithStatus:data:)
                           didFailWithErrorSelector:@selector(testFetcher:failedWithError:)];
  STAssertTrue(isFetching, @"Begin fetch failed");

  if (isFetching) {

    // Give time for the fetch to happen, but give up if 10 seconds elapse with no response
    NSDate* giveUpDate = [NSDate dateWithTimeIntervalSinceNow:kGiveUpInterval];
    while ((!fetchedData_ && !fetcherError_) && [giveUpDate timeIntervalSinceNow] > 0) {
      NSDate* loopIntervalDate = [NSDate dateWithTimeIntervalSinceNow:kRunLoopInterval];
      [[NSRunLoop currentRunLoop] runUntilDate:loopIntervalDate];
    }
  }

  return fetcher;
}

- (NSString *)fileURLStringToTestFileName:(NSString *)name {

  // we need to create http URLs referring to the desired
  // resource to be found by the python http server running locally

  // return a localhost:port URL for the test file
  NSString *urlString = [NSString stringWithFormat:@"http://localhost:%d/%@",
    kServerPortNumber, name];

  // we exclude the "?status=" that would indicate that the URL
  // should cause a retryable error
  NSRange range = [name rangeOfString:@"?status="];
  if (range.length > 0) {
    name = [name substringToIndex:range.location];
  }

  // we exclude the ".auth" extensions that would indicate that the URL
  // should be tested with authentication
  NSString *pathExtension = [name pathExtension];
  NSArray *authExtensions = [NSArray arrayWithObjects:
                             @"auth", @"authsub", @"authwww", nil];
  if ([authExtensions containsObject:pathExtension]) {
    name = [name stringByDeletingPathExtension];
  }

  // just for sanity, let's make sure we see the file locally, so
  // we can expect the Python http server to find it too
  NSString *filePath = [NSString stringWithFormat:@"Tests/%@", name];
  BOOL doesExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
  STAssertTrue(doesExist, @"Missing test file %@", filePath);

  return urlString;
}



- (void)testFetcher:(GDataHTTPFetcher *)fetcher
   finishedWithData:(NSData *)data {
  fetchedData_ = [data copy];
  fetchedStatus_ = [fetcher statusCode]; // this implicitly tests that the fetcher has kept the response
  fetchedRequest_ = [[fetcher request] retain];
  fetchedResponse_ = [[fetcher response] retain];
}

- (void)testFetcher:(GDataHTTPFetcher *)fetcher 
   failedWithStatus:(int)status 
               data:(NSData *)data {
  fetchedData_ = [data copy];
  fetchedStatus_ = status; // this implicitly tests that the fetcher has kept the response
}

- (void)testFetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error {
  fetcherError_ = [error retain];
  fetchedStatus_ = [fetcher statusCode];
}


// Selector for allowing up to N retries, where N is an NSNumber in the
// fetcher's userData
- (BOOL)countRetriesfetcher:(GDataHTTPFetcher *)fetcher
                  willRetry:(BOOL)suggestedWillRetry
                   forError:(NSError *)error {

  int count = [fetcher retryCount];
  int allowedRetryCount = [[fetcher userData] intValue];

  BOOL shouldRetry = (count < allowedRetryCount);

  STAssertEquals([fetcher nextRetryInterval], pow(2.0, [fetcher retryCount]),
                 @"unexpected next retry interval (expected %f, was %f)",
                 pow(2.0, [fetcher retryCount]),
                 [fetcher nextRetryInterval]);

  return shouldRetry;
}

// Selector for retrying and changing the request to one that will succeed
- (BOOL)fixRequestFetcher:(GDataHTTPFetcher *)fetcher
                willRetry:(BOOL)suggestedWillRetry
                 forError:(NSError *)error {

  STAssertEquals([fetcher nextRetryInterval], pow(2.0, [fetcher retryCount]),
                 @"unexpected next retry interval (expected %f, was %f)",
                 pow(2.0, [fetcher retryCount]),
                 [fetcher nextRetryInterval]);

  // fix it - change the request to a URL which does not have a status value
  NSString *urlString = [self fileURLStringToTestFileName:kValidFileName];

  NSURL *url = [NSURL URLWithString:urlString];
  [fetcher setRequest:[NSURLRequest requestWithURL:url]];

  return YES; // do the retry fetch; it should succeed now
}

@end

#endif // !GDATA_SKIPSERVICETEST
