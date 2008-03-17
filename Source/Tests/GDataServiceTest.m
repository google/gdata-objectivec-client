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
//  GDataServiceTest.m
//

#import "GDataServiceTest.h"

#define typeof __typeof__ // fixes http://www.brethorsting.com/blog/2006/02/stupid-issue-with-ocunit.html

@interface MyGDataFeedSpreadsheetSurrogate: GDataFeedSpreadsheet
- (NSString *)mySurrogateFeedName;
@end

@interface MyGDataEntrySpreadsheetSurrogate: GDataEntrySpreadsheet
- (NSString *)mySurrogateEntryName;
@end

@interface MyGDataLinkSurrogate: GDataLink
- (NSString *)mySurrogateLinkName;
@end

@implementation GDataServiceTest

static int kServerPortNumber = 54579;

- (void)setUp {
  
  // run the python http server, located in the Tests directory
  NSString *currentDir = [[NSFileManager defaultManager] currentDirectoryPath];
  NSString *serverPath = [currentDir stringByAppendingPathComponent:@"Tests/GDataTestHTTPServer.py"];
  
  // The framework builds as garbage collection-compatible, so unit tests run
  // with GC both enabled and disabled.  But launching the python http server
  // with GC disabled causes it to return an error.  To avoid that, we'll
  // change its launch environment to allow the python server run with GC.
  NSDictionary *env = [[NSProcessInfo processInfo] environment];
  NSMutableDictionary *mutableEnv = [NSMutableDictionary dictionaryWithDictionary:env];
  [mutableEnv removeObjectForKey:@"OBJC_DISABLE_GC"];
  
  NSArray *argArray = [NSArray arrayWithObjects:serverPath, 
    @"-p", [NSString stringWithFormat:@"%d", kServerPortNumber], 
    @"-r", [serverPath stringByDeletingLastPathComponent], nil];
  
  server_ = [[NSTask alloc] init];
  [server_ setArguments:argArray];
  [server_ setLaunchPath:@"/usr/bin/python"];
  [server_ setEnvironment:mutableEnv];
  
  // pipe will be cleaned up when server_ is torn down.
  NSPipe *pipe = [NSPipe pipe];
  [server_ setStandardOutput:pipe];
  [server_ setStandardError:pipe];
  [server_ launch];
  
  NSData *launchMessageData = [[pipe fileHandleForReading] availableData];
  NSString *launchStr = [[[NSString alloc] initWithData:launchMessageData
                                               encoding:NSUTF8StringEncoding] autorelease];
  
  // our server sends out a string to confirm that it launched;
  // launchStr either has the confirmation, or the error message.
  
  NSString *expectedLaunchStr = @"started GDataTestServer.py...";
  STAssertEqualObjects(launchStr, expectedLaunchStr,
       @">>> Python http test server failed to launch; skipping fetch tests\n"
        "Server path:%@\n", serverPath);
  isServerRunning_ = [launchStr isEqual:expectedLaunchStr];
  
  // create the GData service object, and set it to authenticate
  // from our own python http server
  service_ = [[GDataServiceGoogleSpreadsheet alloc] init];
  
  NSString *authDomain = [NSString stringWithFormat:@"localhost:%d", kServerPortNumber];  
  [service_ setSignInDomain:authDomain];
}

- (void)resetFetchResponse {
  [fetchedObject_ release];
  fetchedObject_ = nil;
  
  [fetcherError_ release];
  fetcherError_ = nil;
  
  [ticket_ release];
  ticket_ = nil;
  
  retryCounter_ = 0;
}

- (void)tearDown {
  
  [server_ terminate];
  [server_ waitUntilExit];
  [server_ release];
  server_ = nil;
  
  isServerRunning_ = NO;
  
  [service_ release];
  service_ = nil;
  
  [self resetFetchResponse];
}

- (NSURL *)fileURLToTestFileName:(NSString *)name {
  
  // we need to create http URLs referring to the desired
  // resource for the python http server running locally
  
  // return a localhost:port URL for the test file
  NSString *urlString = [NSString stringWithFormat:@"http://localhost:%d/%@",
    kServerPortNumber, name];
  
  NSURL *url = [NSURL URLWithString:urlString];
  
  // just for sanity, let's make sure we see the file locally, so
  // we can expect the Python http server to find it too
  NSString *filePath = [NSString stringWithFormat:@"Tests/%@", name];
  
  
  // we exclude the "?status=" that would indicate that the URL
  // should cause a retryable error
  NSRange range = [filePath rangeOfString:@"?status="];
  if (range.length > 0) {
    filePath = [filePath substringToIndex:range.location]; 
  }

  // we exclude the ".auth" extension that would indicate that the URL
  // should be tested with authentication
  if ([[filePath pathExtension] isEqual:@"auth"]) {
    filePath = [filePath stringByDeletingPathExtension]; 
  }
  
  BOOL doesExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
  STAssertTrue(doesExist, @"Missing test file %@", filePath);
  
  return url;  
}


// deleteResource calls don't return data or an error, so we'll use
// a global int for the callbacks to increment to say they're done
// (because NSURLConnection is performing the fetches, all this 
// will be safely executed on the same thread)
static int gFetchCounter = 0; 

- (void)waitForFetch {
  
  int fetchCounter = gFetchCounter;
  
  // Give time for the fetch to happen, but give up if 
  // 10 seconds elapse with no response
  NSDate* giveUpDate = [NSDate dateWithTimeIntervalSinceNow:10.0];
  
  while ((!fetchedObject_ && !fetcherError_) 
         && fetchCounter == gFetchCounter
         && [giveUpDate timeIntervalSinceNow] > 0) {
    
    NSDate *stopDate = [NSDate dateWithTimeIntervalSinceNow:0.001];
    [[NSRunLoop currentRunLoop] runUntilDate:stopDate]; 
  }  
  
}

- (void)testFetch {
  
  if (!isServerRunning_) return;
  
  NSDate *defaultUserData = [NSDate date]; 
  NSString *customUserData = @"my special ticket user data";
  
  [service_ setServiceUserData:defaultUserData];
  
  // an ".auth" extension tells the server to require the success auth token,
  // but the server will ignore the .auth extension when looking for the file
  NSURL *feedURL = [self fileURLToTestFileName:@"FeedSpreadsheetTest1.xml"];
  NSURL *authFeedURL = [self fileURLToTestFileName:@"FeedSpreadsheetTest1.xml.auth"];
  
  //
  // test:  download feed only, no auth, caching on
  //
  [service_ setShouldCacheDatedData:YES];
  
  ticket_ = (GDataServiceTicket *)
    [service_ fetchFeedWithURL:feedURL
                     feedClass:kGDataUseRegisteredClass
                      delegate:self
             didFinishSelector:@selector(ticket:finishedWithObject:)
               didFailSelector:@selector(ticket:failedWithError:)];
  [ticket_ retain];
  
  [self waitForFetch];
  
  // we'll call into the GDataObject to get its ID to confirm it's good
  NSString *sheetID = @"http://spreadsheets.google.com/feeds/spreadsheets/private/full";
  
  STAssertEqualObjects([(GDataFeedSpreadsheet *)fetchedObject_ identifier],
                     sheetID, @"fetching %@ error %@", feedURL, fetcherError_);
  STAssertNil(fetcherError_, @"fetcherError_=%@", fetcherError_);
  STAssertEqualObjects([ticket_ userData], defaultUserData, @"userdata error");

  // no cookies should be sent with our first request
  NSURLRequest *request = [[ticket_ objectFetcher] request];
  
  NSString *cookiesSent = [[request allHTTPHeaderFields] objectForKey:@"Cookie"];
  STAssertNil(cookiesSent, @"Cookies sent unexpectedly: %@", cookiesSent);
  
  // cookies should have been set with the response; specifically, TestCookie
  // should be set to the name of the file requested
  NSURLResponse *response = [[ticket_ objectFetcher] response];

  NSDictionary *responseHeaderFields = [(NSHTTPURLResponse *)response allHeaderFields];
  NSString *cookiesSetString = [responseHeaderFields objectForKey:@"Set-Cookie"];
  NSString *cookieExpected = [NSString stringWithFormat:@"TestCookie=%@",
    [[feedURL path] lastPathComponent]];
  
  STAssertEqualObjects(cookiesSetString, cookieExpected, @"Unexpected cookie");
  
  // save a copy of the retrieved object to compare with our cache responses
  // later
  GDataObject *objectCopy = [[fetchedObject_ copy] autorelease];
  
  
  //
  // test: download feed only, unmodified so fetching a cached copy
  //
  
  [self resetFetchResponse];
  
  ticket_ = (GDataServiceTicket *)
    [service_ fetchFeedWithURL:feedURL
                     feedClass:kGDataUseRegisteredClass
                      delegate:self
             didFinishSelector:@selector(ticket:finishedWithObject:)
               didFailSelector:@selector(ticket:failedWithError:)];
  [ticket_ retain];
  
  [self waitForFetch];
  
  // the TestCookie set previously should be sent with this request
  request = [[ticket_ objectFetcher] request];
  cookiesSent = [[request allHTTPHeaderFields] objectForKey:@"Cookie"];
  STAssertEqualObjects(cookiesSent, cookieExpected,
                       @"Cookie not sent");
  
  // verify the object is unchanged from the uncached fetch
  STAssertEqualObjects(fetchedObject_, objectCopy,
                       @"fetching from cache for %@", feedURL);
  STAssertNil(fetcherError_, @"fetcherError_=%@", fetcherError_);
  
  // verify the underlying fetcher got a 304 (not modified) status
  STAssertEquals([[ticket_ objectFetcher] statusCode],
                 kGDataHTTPFetcherStatusNotModified,
                 @"fetching cached copy of %@", feedURL);

  
  //
  // test: download feed only, caching turned off so we get an
  //       actual response again
  //
  
  [self resetFetchResponse];
  
  [service_ setShouldCacheDatedData:NO];
  
  ticket_ = (GDataServiceTicket *)
    [service_ fetchFeedWithURL:feedURL
                     feedClass:kGDataUseRegisteredClass
                      delegate:self
             didFinishSelector:@selector(ticket:finishedWithObject:)
               didFailSelector:@selector(ticket:failedWithError:)];
  [ticket_ retain];
  
  [self waitForFetch];
  
  // verify the object is unchanged from the original fetch
  STAssertEqualObjects(fetchedObject_, objectCopy,
                       @"fetching from cache for %@", feedURL);
  STAssertNil(fetcherError_, @"fetcherError_=%@", fetcherError_);
  
  // verify the underlying fetcher got a 200 (good) status
  STAssertEquals([[ticket_ objectFetcher] statusCode], 200,
                 @"fetching uncached copy of %@", feedURL);
  
  //
  // test: download feed only, no auth, allocating a surrogate feed class
  //
  [self resetFetchResponse];

  NSDictionary *surrogates = [NSDictionary dictionaryWithObjectsAndKeys:
    [MyGDataFeedSpreadsheetSurrogate class], [GDataFeedSpreadsheet class],
    [MyGDataEntrySpreadsheetSurrogate class], [GDataEntrySpreadsheet class],
    [MyGDataLinkSurrogate class], [GDataLink class],
    nil];
  [service_ setServiceSurrogates:surrogates];
  
  ticket_ = (GDataServiceTicket *)
    [service_ fetchFeedWithURL:feedURL
                     feedClass:kGDataUseRegisteredClass
                      delegate:self
             didFinishSelector:@selector(ticket:finishedWithObject:)
               didFailSelector:@selector(ticket:failedWithError:)];
  [ticket_ retain];
  
  [self waitForFetch];
  
  // we'll call into the GDataObject to get its ID to confirm it's good
  
  STAssertEqualObjects([(GDataFeedSpreadsheet *)fetchedObject_ identifier],
                       sheetID, @"fetching %@", feedURL);
  STAssertNil(fetcherError_, @"fetcherError_=%@", fetcherError_);
  STAssertEqualObjects([ticket_ userData], defaultUserData, @"userdata error");
  
  // be sure we really got an instance of the surrogate feed, entry, and
  // link classes
  MyGDataFeedSpreadsheetSurrogate *feed = (MyGDataFeedSpreadsheetSurrogate *)fetchedObject_;
  STAssertEqualObjects([feed mySurrogateFeedName],
                       @"mySurrogateFeedNameBar", @"fetching %@ with surrogate", feedURL);
  
  MyGDataEntrySpreadsheetSurrogate *entry = [[feed entries] objectAtIndex:0];
  STAssertEqualObjects([entry mySurrogateEntryName],
                       @"mySurrogateEntryNameFoo", @"fetching %@ with surrogate", feedURL);
  
  MyGDataLinkSurrogate *link = [[entry links] objectAtIndex:0];
  STAssertEqualObjects([link mySurrogateLinkName],
                       @"mySurrogateLinkNameBaz", @"fetching %@ with surrogate", feedURL);
  
  [service_ setServiceSurrogates:nil];

  //
  // test:  download feed only, successful auth, with custom ticket userdata
  //
  [self resetFetchResponse];

  // any username & password are considered valid unless the password 
  // begins with the string "bad"
  [service_ setUserCredentialsWithUsername:@"myaccount@mydomain.com"
                                  password:@"mypassword"];
  
  ticket_ = [service_ fetchAuthenticatedFeedWithURL:authFeedURL
                                          feedClass:kGDataUseRegisteredClass
                                           delegate:self
                                  didFinishSelector:@selector(ticket:finishedWithObject:)
                                    didFailSelector:@selector(ticket:failedWithError:)];
  [ticket_ retain];
  
  [ticket_ setUserData:customUserData];
  
  [self waitForFetch];

  STAssertEqualObjects([(GDataFeedSpreadsheet *)fetchedObject_ identifier],
                       sheetID, @"fetching %@", authFeedURL);
  STAssertNil(fetcherError_, @"fetcherError_=%@", fetcherError_);
  STAssertEqualObjects([ticket_ userData], customUserData, @"userdata error");
  
  //
  // test: repeat last authenticated download so we're reusing the auth token
  //
  
  [self resetFetchResponse];
    
  ticket_ = [service_ fetchAuthenticatedFeedWithURL:authFeedURL
                                          feedClass:kGDataUseRegisteredClass
                                           delegate:self
                                  didFinishSelector:@selector(ticket:finishedWithObject:)
                                    didFailSelector:@selector(ticket:failedWithError:)];
  [ticket_ retain];
  
  [self waitForFetch];
  
  STAssertEqualObjects([(GDataFeedSpreadsheet *)fetchedObject_ identifier],
                       sheetID, @"fetching %@", authFeedURL);
  STAssertNil(fetcherError_, @"fetcherError_=%@", fetcherError_);
  
  //
  // test: repeat last authenticated download so we're reusing the auth token,
  // but make the auth token invalid to force a re-auth
  //
  
  [self resetFetchResponse];
  
  [service_ setAuthToken:@"bogus"];
  
  ticket_ = [service_ fetchAuthenticatedFeedWithURL:authFeedURL
                                          feedClass:kGDataUseRegisteredClass
                                           delegate:self
                                  didFinishSelector:@selector(ticket:finishedWithObject:)
                                    didFailSelector:@selector(ticket:failedWithError:)];
  [ticket_ retain];
  
  [self waitForFetch];
  
  STAssertEqualObjects([(GDataFeedSpreadsheet *)fetchedObject_ identifier],
                       sheetID, @"fetching %@", authFeedURL);
  STAssertNil(fetcherError_, @"fetcherError_=%@", fetcherError_);
  
  //
  // test:  download feed only, unsuccessful auth
  //
  [self resetFetchResponse];
  
  [service_ setUserCredentialsWithUsername:@"myaccount@mydomain.com"
                                  password:@"bad"];
  
  ticket_ = [service_ fetchAuthenticatedFeedWithURL:authFeedURL
                                          feedClass:kGDataUseRegisteredClass
                                           delegate:self
                                  didFinishSelector:@selector(ticket:finishedWithObject:)
                                    didFailSelector:@selector(ticket:failedWithError:)];
  [ticket_ retain];
  
  [self waitForFetch];
  
  STAssertNil(fetchedObject_, @"fetchedObject_=%@", fetchedObject_);
  STAssertEquals([fetcherError_ code], 403, @"fetcherError_=%@", fetcherError_);
  STAssertEqualObjects([ticket_ userData], defaultUserData, @"userdata error");
  
  
  //
  // test:  download feed only, unsuccessful auth - captcha required
  //
  [self resetFetchResponse];
  
  [service_ setUserCredentialsWithUsername:@"myaccount@mydomain.com"
                                  password:@"captcha"];
  
  ticket_ = [service_ fetchAuthenticatedFeedWithURL:authFeedURL
                                          feedClass:kGDataUseRegisteredClass
                                           delegate:self
                                  didFinishSelector:@selector(ticket:finishedWithObject:)
                                    didFailSelector:@selector(ticket:failedWithError:)];
  [ticket_ retain];
  
  [self waitForFetch];
  
  STAssertNil(fetchedObject_, @"fetchedObject_=%@", fetchedObject_);
  STAssertEquals([fetcherError_ code], 403, @"fetcherError_=%@", fetcherError_);
  
  // get back the captcha token and partial and full URLs from the error
  NSDictionary *userInfo = [fetcherError_ userInfo];
  NSString *captchaToken = [userInfo objectForKey:@"CaptchaToken"];
  NSString *captchaUrl = [userInfo objectForKey:@"CaptchaUrl"];
  NSString *captchaFullUrl = [userInfo objectForKey:@"CaptchaFullUrl"];
  STAssertEqualObjects(captchaToken, @"CapToken", @"bad captcha token");
  STAssertEqualObjects(captchaUrl, @"CapUrl", @"bad captcha relative url");
  STAssertTrue([captchaFullUrl hasSuffix:@"/accounts/CapUrl"], @"bad captcha full:%@", captchaFullUrl);

  STAssertEqualObjects([ticket_ userData], defaultUserData, @"userdata error");
  
  //
  // test:  download feed only, good captcha provided
  //
  [self resetFetchResponse];
  
  [service_ setUserCredentialsWithUsername:@"myaccount2@mydomain.com"
                                  password:@"captcha"];
  [service_ setCaptchaToken:@"CapToken" captchaAnswer:@"good"];
  
  ticket_ = [service_ fetchAuthenticatedFeedWithURL:authFeedURL
                                          feedClass:kGDataUseRegisteredClass
                                           delegate:self
                                  didFinishSelector:@selector(ticket:finishedWithObject:)
                                    didFailSelector:@selector(ticket:failedWithError:)];
  [ticket_ retain];
  
  [self waitForFetch];
    
  // get back the captcha token and partial and full URLs from the error
  STAssertEqualObjects([(GDataFeedSpreadsheet *)fetchedObject_ identifier],
                       sheetID, @"fetching %@", feedURL);
  STAssertNil(fetcherError_, @"fetcherError_=%@", fetcherError_);
  STAssertEqualObjects([ticket_ userData], defaultUserData, @"userdata error");
  
  //
  // test:  download feed only, bad captcha provided
  //
  [self resetFetchResponse];
  
  [service_ setUserCredentialsWithUsername:@"myaccount3@mydomain.com"
                                  password:@"captcha"];
  [service_ setCaptchaToken:@"CapToken" captchaAnswer:@"bad"];

  ticket_ = [service_ fetchAuthenticatedFeedWithURL:authFeedURL
                                          feedClass:kGDataUseRegisteredClass
                                           delegate:self
                                  didFinishSelector:@selector(ticket:finishedWithObject:)
                                    didFailSelector:@selector(ticket:failedWithError:)];
  [ticket_ retain];
  
  [self waitForFetch];
  
  STAssertNil(fetchedObject_, @"fetchedObject_=%@", fetchedObject_);
  STAssertEquals([fetcherError_ code], 403, @"fetcherError_=%@", fetcherError_);
  
  // get back the captcha token and partial and full URLs from the error
  userInfo = [fetcherError_ userInfo];
  captchaToken = [userInfo objectForKey:@"CaptchaToken"];
  captchaUrl = [userInfo objectForKey:@"CaptchaUrl"];
  captchaFullUrl = [userInfo objectForKey:@"CaptchaFullUrl"];
  STAssertEqualObjects(captchaToken, @"CapToken", @"bad captcha token");
  STAssertEqualObjects(captchaUrl, @"CapUrl", @"bad captcha relative url");
  STAssertTrue([captchaFullUrl hasSuffix:@"/accounts/CapUrl"], @"bad captcha full:%@", captchaFullUrl);
  
  STAssertEqualObjects([ticket_ userData], defaultUserData, @"userdata error");
  
  
  //
  // test:  insert/download entry, successful auth
  //
  [self resetFetchResponse];

  [service_ setUserCredentialsWithUsername:@"myaccount@mydomain.com"
                                  password:@"good"];

  NSURL *authEntryURL = [self fileURLToTestFileName:@"EntrySpreadsheetCellTest1.xml.auth"];

  ticket_ = [service_ fetchAuthenticatedEntryByInsertingEntry:[GDataEntrySpreadsheetCell entry]
                                                   forFeedURL:authEntryURL
                                                     delegate:self
                                            didFinishSelector:@selector(ticket:finishedWithObject:)
                                              didFailSelector:@selector(ticket:failedWithError:)];
  [ticket_ retain];
  
  [self waitForFetch];
  
  NSString *entryID = @"http://spreadsheets.google.com/feeds/cells/o04181601172097104111.497668944883620000/od6/private/full/R1C1";
  
  STAssertEqualObjects([(GDataEntrySpreadsheetCell *)fetchedObject_ identifier],
                       entryID, @"updating %@", authEntryURL);
  STAssertNil(fetcherError_, @"fetcherError_=%@", fetcherError_);
  STAssertEqualObjects([ticket_ userData], defaultUserData, @"userdata error");
  
  //
  // test:  update/download entry, successful auth
  //
  [self resetFetchResponse];
  
  ticket_ = [service_ fetchAuthenticatedEntryByUpdatingEntry:[GDataEntrySpreadsheetCell entry]
                                                 forEntryURL:authEntryURL
                                                    delegate:self
                                           didFinishSelector:@selector(ticket:finishedWithObject:)
                                             didFailSelector:@selector(ticket:failedWithError:)];
  [ticket_ retain];
  
  [self waitForFetch];
  
  STAssertEqualObjects([(GDataEntrySpreadsheetCell *)fetchedObject_ identifier],
                       entryID, @"fetching %@", authFeedURL);
  STAssertNil(fetcherError_, @"fetcherError_=%@", fetcherError_);
  STAssertEqualObjects([ticket_ userData], defaultUserData, @"userdata error");
  
  //
  // test:  delete resource, successful auth
  //
  [self resetFetchResponse];
  
  ticket_ = [service_ deleteAuthenticatedResourceURL:authEntryURL
                                            delegate:self
                                   didFinishSelector:@selector(ticket:finishedWithObject:)
                                     didFailSelector:@selector(ticket:failedWithError:)];
  [ticket_ retain];
  
  [self waitForFetch];
  
  STAssertNil(fetchedObject_, @"deleting %@ returned \n%@", authEntryURL, fetchedObject_);
  STAssertNil(fetcherError_, @"fetcherError_=%@", fetcherError_);
  STAssertEqualObjects([ticket_ userData], defaultUserData, @"userdata error");

  //
  // test:  delete resource, successful auth, using method override header
  //
  [self resetFetchResponse];
  
  [service_ setShouldUseMethodOverrideHeader:YES];
  
  ticket_ = [service_ deleteAuthenticatedResourceURL:authEntryURL
                                            delegate:self
                                   didFinishSelector:@selector(ticket:finishedWithObject:)
                                     didFailSelector:@selector(ticket:failedWithError:)];
  [ticket_ retain];
  
  [self waitForFetch];
  
  STAssertNil(fetchedObject_, @"deleting %@ returned \n%@", authEntryURL, fetchedObject_);
  STAssertNil(fetcherError_, @"fetcherError_=%@", fetcherError_);
  STAssertEqualObjects([ticket_ userData], defaultUserData, @"userdata error");
}

// fetch callbacks

- (void)ticket:(GDataServiceTicket *)ticket finishedWithObject:(GDataObject *)object {

  STAssertEquals(ticket, ticket_, @"Got unexpected ticket");
  
  fetchedObject_ = [object retain]; // save the fetched object
  
  ++gFetchCounter;
}

- (void)ticket:(GDataServiceTicket *)ticket failedWithError:(NSError *)error {

  STAssertEquals(ticket, ticket_, @"Got unexpected ticket");
  
  fetcherError_ = [error retain]; // save the error
  
  ++gFetchCounter;
}

- (void)testRetryFetches {
  
  if (!isServerRunning_) return;

  // an ".auth" extension tells the server to require the success auth token,
  // but the server will ignore the .auth extension when looking for the file
  NSURL *authFeedStatusURL = [self fileURLToTestFileName:@"FeedSpreadsheetTest1.xml?status=503"];
  
  [service_ setIsServiceRetryEnabled:YES];
  
  //
  // test: retry until timeout, then expect failure to be passed to the callback
  //
  
  [service_ setServiceMaxRetryInterval:5.]; // retry intervals of 1, 2, 4
  [service_ setServiceRetrySelector:@selector(stopRetryTicket:willRetry:forError:)];

  ticket_ = (GDataServiceTicket *)
    [service_ fetchFeedWithURL:authFeedStatusURL
                     feedClass:kGDataUseRegisteredClass
                      delegate:self
             didFinishSelector:@selector(ticket:finishedWithObject:)
               didFailSelector:@selector(ticket:failedWithError:)];
  [ticket_ retain];
  
  [ticket_ setUserData:[NSNumber numberWithInt:1000]]; // lots of retries
  
  [self waitForFetch];
  
  STAssertNil(fetchedObject_, @"obtained object unexpectedly");
  STAssertEquals([fetcherError_ code], 503, 
                 @"fetcherError_ should be 503, was %@", fetcherError_);
  STAssertEquals([[ticket_ objectFetcher] retryCount], (unsigned) 3, 
               @"retry count should be 3, was %d", 
               [[ticket_ objectFetcher] retryCount]);
  
  //
  // test:  retry twice, then give up
  //
  [self resetFetchResponse];

  [service_ setServiceMaxRetryInterval:10.]; // retry intervals of 1, 2, 4, 8
  [service_ setServiceRetrySelector:@selector(stopRetryTicket:willRetry:forError:)];

  ticket_ = (GDataServiceTicket *)
    [service_ fetchFeedWithURL:authFeedStatusURL
                     feedClass:kGDataUseRegisteredClass
                      delegate:self
             didFinishSelector:@selector(ticket:finishedWithObject:)
               didFailSelector:@selector(ticket:failedWithError:)];
  [ticket_ retain];
  
  // set userData to the number of retries allowed
  [ticket_ setUserData:[NSNumber numberWithInt:2]];
  
  [self waitForFetch];
  
  STAssertNil(fetchedObject_, @"obtained object unexpectedly");
  STAssertEquals([fetcherError_ code], 503, 
                 @"fetcherError_ should be 503, was %@", fetcherError_);
  STAssertEquals([[ticket_ objectFetcher] retryCount], (unsigned) 2, 
                 @"retry count should be 2, was %d", 
                 [[ticket_ objectFetcher] retryCount]);
  
  //
  // test:  retry, making the request succeed on the first retry
  // by fixing the URL
  //
  [self resetFetchResponse];
  
  [service_ setServiceMaxRetryInterval:100.]; 
  [service_ setServiceRetrySelector:@selector(fixRequestRetryTicket:willRetry:forError:)];
  
  ticket_ = (GDataServiceTicket *)
    [service_ fetchFeedWithURL:authFeedStatusURL
                     feedClass:kGDataUseRegisteredClass
                      delegate:self
             didFinishSelector:@selector(ticket:finishedWithObject:)
               didFailSelector:@selector(ticket:failedWithError:)];
  [ticket_ retain];
  
  [self waitForFetch];
  
  STAssertNotNil(fetchedObject_, @"should have obtained fetched object");
  STAssertNil(fetcherError_, @"fetcherError_=%@", fetcherError_);
  STAssertEquals([[ticket_ objectFetcher] retryCount], (unsigned) 1, 
                 @"retry count should be 1, was %d", 
                 [[ticket_ objectFetcher] retryCount]);
  
  //
  // test:  download feed only, no auth, surrogate feed class
  //
  [self resetFetchResponse];
}  

-(BOOL)stopRetryTicket:(GDataServiceTicket *)ticket willRetry:(BOOL)suggestedWillRetry forError:(NSError *)error {
  
  GDataHTTPFetcher *fetcher = [ticket currentFetcher];
  [fetcher setMinRetryInterval:1.0]; // force exact starting interval of 1.0 sec
  
  int count = [fetcher retryCount];
  int allowedRetryCount = [[ticket userData] intValue];

  BOOL shouldRetry = (count < allowedRetryCount);
  
  STAssertEquals([fetcher nextRetryInterval], pow(2.0, [fetcher retryCount]),
                 @"unexpected next retry interval (expected %f, was %f)",
                 pow(2.0, [fetcher retryCount]),
                 [fetcher nextRetryInterval]);
  
  return shouldRetry;
}

-(BOOL)fixRequestRetryTicket:(GDataServiceTicket *)ticket willRetry:(BOOL)suggestedWillRetry forError:(NSError *)error {
  
  GDataHTTPFetcher *fetcher = [ticket currentFetcher];
  [fetcher setMinRetryInterval:1.0]; // force exact starting interval of 1.0 sec
  
  STAssertEquals([fetcher nextRetryInterval], pow(2.0, [fetcher retryCount]),
                 @"unexpected next retry interval (expected %f, was %f)",
                 pow(2.0, [fetcher retryCount]),
                 [fetcher nextRetryInterval]);
  
  // fix it - change the request to a URL which does not have a status value
  NSURL *authFeedStatusURL = [self fileURLToTestFileName:@"FeedSpreadsheetTest1.xml"]; 
  [fetcher setRequest:[NSURLRequest requestWithURL:authFeedStatusURL]];
  
  return YES; // do the retry fetch; it should succeed now
}

@end

@implementation MyGDataFeedSpreadsheetSurrogate
- (NSString *)mySurrogateFeedName {
  return @"mySurrogateFeedNameBar";
}
@end

@implementation MyGDataEntrySpreadsheetSurrogate
- (NSString *)mySurrogateEntryName {
  return @"mySurrogateEntryNameFoo";
}
@end

@implementation MyGDataLinkSurrogate
- (NSString *)mySurrogateLinkName {
  return @"mySurrogateLinkNameBaz";
}
@end

