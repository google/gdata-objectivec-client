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

// service tests are slow, so we might skip them when developing other
// unit tests
#if !GDATA_SKIPSERVICETEST

#import <SenTestingKit/SenTestingKit.h>

#import "GData.h"

@interface GDataServiceTest : SenTestCase {
  NSTask *server_;
  BOOL isServerRunning_;

  GDataServiceGoogle *service_;

  GDataServiceTicket *ticket_;
  GDataObject *fetchedObject_;
  NSError *fetcherError_;
  int fetchStartedNotificationCount_;
  int fetchStoppedNotificationCount_;
  unsigned long long lastProgressDeliveredCount_;
  unsigned long long lastProgressTotalCount_;
  int retryCounter_;
  int retryDelayStartedNotificationCount_;
  int retryDelayStoppedNotificationCount_;

  NSString *authToken_;
  NSError *authError_;
}
@end

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
  // We also remove the Malloc debugging variables, since they interfere with
  // the program output.
  NSDictionary *env = [[NSProcessInfo processInfo] environment];
  NSMutableDictionary *mutableEnv = [NSMutableDictionary dictionaryWithDictionary:env];
  [mutableEnv removeObjectForKey:@"OBJC_DISABLE_GC"];
  [mutableEnv removeObjectForKey:@"MallocGuardEdges"];
  [mutableEnv removeObjectForKey:@"MallocPreScribble"];
  [mutableEnv removeObjectForKey:@"MallocScribble"];

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

  // install observers for fetcher notifications
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self selector:@selector(fetchStateChanged:) name:kGDataHTTPFetcherStartedNotification object:nil];
  [nc addObserver:self selector:@selector(fetchStateChanged:) name:kGDataHTTPFetcherStoppedNotification object:nil];
  [nc addObserver:self selector:@selector(retryDelayStateChanged:) name:kGDataHTTPFetcherRetryDelayStartedNotification object:nil];
  [nc addObserver:self selector:@selector(retryDelayStateChanged:) name:kGDataHTTPFetcherRetryDelayStoppedNotification object:nil];
}

- (void)fetchStateChanged:(NSNotification *)note {
  GDataHTTPFetcher *fetcher = [note object];
  GDataServiceTicketBase *ticket = [fetcher ticket];

  STAssertNotNil(ticket, @"cannot get ticket from fetch notification");

  if ([[note name] isEqual:kGDataHTTPFetcherStartedNotification]) {
    ++fetchStartedNotificationCount_;
  } else {
    ++fetchStoppedNotificationCount_;
  }

  STAssertTrue(retryDelayStartedNotificationCount_ <= fetchStartedNotificationCount_,
               @"fetch notification imbalance: starts=%d stops=%d",
               fetchStartedNotificationCount_, retryDelayStartedNotificationCount_);
}

- (void)retryDelayStateChanged:(NSNotification *)note {
  GDataHTTPFetcher *fetcher = [note object];
  GDataServiceTicketBase *ticket = [fetcher ticket];

  STAssertNotNil(ticket, @"cannot get ticket from retry delay notification");

  if ([[note name] isEqual:kGDataHTTPFetcherRetryDelayStartedNotification]) {
    ++retryDelayStartedNotificationCount_;
  } else {
    ++retryDelayStoppedNotificationCount_;
  }

  STAssertTrue(retryDelayStoppedNotificationCount_ <= retryDelayStartedNotificationCount_,
               @"retry delay notification imbalance: starts=%d stops=%d",
               retryDelayStartedNotificationCount_,
               retryDelayStoppedNotificationCount_);
}

- (void)resetFetchResponse {
  [fetchedObject_ release];
  fetchedObject_ = nil;

  [fetcherError_ release];
  fetcherError_ = nil;

  [ticket_ release];
  ticket_ = nil;

  retryCounter_ = 0;

  lastProgressDeliveredCount_ = 0;
  lastProgressTotalCount_ = 0;

  // Set the UA to avoid log warnings during tests, except the first test,
  // which will use an auto-generated user agent
  if ([service_ userAgent] == nil) {
    [service_ setUserAgent:@"GData-UnitTests-99.99"];
  }

  if (![service_ shouldCacheDatedData]) {
    // we don't want to see 304s in our service response tests now,
    // though the tests below will check for them in the underlying
    // fetchers when we get a cached response
    [service_ clearLastModifiedDates];
  }

  fetchStartedNotificationCount_ = 0;
  fetchStoppedNotificationCount_ = 0;
  retryDelayStartedNotificationCount_ = 0;
  retryDelayStoppedNotificationCount_ = 0;
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
  if (range.location == NSNotFound) {
    range = [filePath rangeOfString:@"?statusxml="];
  }
  if (range.length > 0) {
    filePath = [filePath substringToIndex:range.location];
  }

  // we exclude the ".auth" and ".authsub" extensions that would indicate
  // that the URL should be tested with authentication
  if ([[filePath pathExtension] isEqual:@"auth"] ||
      [[filePath pathExtension] isEqual:@"authsub"]) {
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

  // values & keys for testing that userdata is passed from
  // service to ticket
  NSDate *defaultUserData = [NSDate date];
  NSString *customUserData = @"my special ticket user data";

  NSString *testPropertyKey = @"testPropertyKey";
  NSDate *defaultPropertyValue = [NSDate dateWithTimeIntervalSinceNow:999];
  NSString *customPropertyValue = @"ticket properties override service props";

  [service_ setServiceUserData:defaultUserData];
  [service_ setServiceProperty:defaultPropertyValue forKey:testPropertyKey];

  // an ".auth" extension tells the server to require the success auth token,
  // but the server will ignore the .auth extension when looking for the file
  NSURL *feedURL = [self fileURLToTestFileName:@"FeedSpreadsheetTest1.xml"];
  NSURL *feedErrorURL = [self fileURLToTestFileName:@"FeedSpreadsheetTest1.xml?statusxml=499"];
  NSURL *authFeedURL = [self fileURLToTestFileName:@"FeedSpreadsheetTest1.xml.auth"];
  NSURL *authSubFeedURL = [self fileURLToTestFileName:@"FeedSpreadsheetTest1.xml.authsub"];

  //
  // test:  download feed only, no auth, caching on
  //
  [service_ setShouldCacheDatedData:YES];

  ticket_ = (GDataServiceTicket *)
    [service_ fetchPublicFeedWithURL:feedURL
                           feedClass:kGDataUseRegisteredClass
                            delegate:self
                   didFinishSelector:@selector(ticket:finishedWithObject:error:)];
  [ticket_ retain];

  [self waitForFetch];

  // we'll call into the GDataObject to get its ID to confirm it's good
  NSString *sheetID = @"http://spreadsheets.google.com/feeds/spreadsheets/private/full";

  STAssertEqualObjects([(GDataFeedSpreadsheet *)fetchedObject_ identifier],
                     sheetID, @"fetching %@ error %@", feedURL, fetcherError_);
  STAssertNil(fetcherError_, @"fetcherError_=%@", fetcherError_);
  STAssertEqualObjects([ticket_ userData], defaultUserData, @"userdata error");
  STAssertEqualObjects([ticket_ propertyForKey:testPropertyKey],
                       defaultPropertyValue, @"default property missing");

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

  // check that the expected notifications happened
  STAssertEquals(fetchStartedNotificationCount_, 1, @"start note missing");
  STAssertEquals(fetchStoppedNotificationCount_, 1, @"stopped note missing");
  STAssertEquals(retryDelayStartedNotificationCount_, 0, @"retry delay note unexpected");
  STAssertEquals(retryDelayStoppedNotificationCount_, 0, @"retry delay note unexpected");

  // save a copy of the retrieved object to compare with our cache responses
  // later
  GDataObject *objectCopy = [[fetchedObject_ copy] autorelease];


  //
  // test: download feed only, unmodified so fetching a cached copy
  //

  [self resetFetchResponse];

  ticket_ = (GDataServiceTicket *)
    [service_ fetchPublicFeedWithURL:feedURL
                           feedClass:kGDataUseRegisteredClass
                            delegate:self
                   didFinishSelector:@selector(ticket:finishedWithObject:error:)];

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
                 (NSInteger)kGDataHTTPFetcherStatusNotModified,
                 @"fetching cached copy of %@", feedURL);


  //
  // test: download feed only, caching turned off so we get an
  //       actual response again
  //

  [self resetFetchResponse];

  [service_ setShouldCacheDatedData:NO];

  ticket_ = (GDataServiceTicket *)
    [service_ fetchPublicFeedWithURL:feedURL
                           feedClass:kGDataUseRegisteredClass
                            delegate:self
                   didFinishSelector:@selector(ticket:finishedWithObject:error:)];
  [ticket_ retain];

  [self waitForFetch];

  // verify the object is unchanged from the original fetch
  STAssertEqualObjects(fetchedObject_, objectCopy,
                       @"fetching from cache for %@", feedURL);
  STAssertNil(fetcherError_, @"fetcherError_=%@", fetcherError_);

  // verify the underlying fetcher got a 200 (good) status
  STAssertEquals([[ticket_ objectFetcher] statusCode], (NSInteger)200,
                 @"fetching uncached copy of %@", feedURL);

  //
  // test: download feed only, no auth, forcing a structured xml error
  //
  [self resetFetchResponse];

  ticket_ = (GDataServiceTicket *)
    [service_ fetchPublicFeedWithURL:feedErrorURL
                           feedClass:kGDataUseRegisteredClass
                            delegate:self
                   didFinishSelector:@selector(ticket:finishedWithObject:error:)];
  [ticket_ retain];

  [self waitForFetch];

  STAssertNil(fetchedObject_, @"fetching %@", feedURL);
  STAssertEquals([fetcherError_ code], (NSInteger)499,
                 @"fetcherError_=%@", fetcherError_);

  // get the error group from the error's userInfo and test the main
  // error's fields
  GDataServerErrorGroup *errorGroup =
    [[fetcherError_ userInfo] objectForKey:kGDataStructuredErrorsKey];
  STAssertNotNil(errorGroup, @"lacks error group");

  GDataServerError *serverError = [errorGroup mainError];

  STAssertEqualObjects([serverError domain], kGDataErrorDomainCore, @"domain");
  STAssertEqualObjects([serverError code], @"code_499", @"code");
  STAssertTrue([[serverError internalReason] hasPrefix:@"forced status error"],
               @"internalReason: %@", [serverError internalReason]);
  STAssertEqualObjects([serverError extendedHelpURI], @"http://help.com",
                       @"help");
  STAssertEqualObjects([serverError sendReportURI], @"http://report.com",
                       @"sendReport");


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
    [service_ fetchPublicFeedWithURL:feedURL
                           feedClass:kGDataUseRegisteredClass
                            delegate:self
                   didFinishSelector:@selector(ticket:finishedWithObject:error:)];
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

  ticket_ = [service_ fetchFeedWithURL:authFeedURL
                             feedClass:kGDataUseRegisteredClass
                              delegate:self
                     didFinishSelector:@selector(ticket:finishedWithObject:error:)];
  [ticket_ retain];

  [ticket_ setUserData:customUserData];
  [ticket_ setProperty:customPropertyValue forKey:testPropertyKey];

  [self waitForFetch];

  STAssertEqualObjects([(GDataFeedSpreadsheet *)fetchedObject_ identifier],
                       sheetID, @"fetching %@", authFeedURL);
  STAssertNil(fetcherError_, @"fetcherError_=%@", fetcherError_);
  STAssertEqualObjects([ticket_ userData], customUserData, @"userdata error");
  STAssertEqualObjects([ticket_ propertyForKey:testPropertyKey],
                       customPropertyValue, @"custom property error");

  // check that the expected notifications happened for the authentication
  // fetch and the object fetch
  STAssertEquals(fetchStartedNotificationCount_, 2, @"start note missing");
  STAssertEquals(fetchStoppedNotificationCount_, 2, @"stopped note missing");
  STAssertEquals(retryDelayStartedNotificationCount_, 0, @"retry delay note unexpected");
  STAssertEquals(retryDelayStoppedNotificationCount_, 0, @"retry delay note unexpected");

  //
  // test: repeat last authenticated download so we're reusing the auth token
  //

  [self resetFetchResponse];

  ticket_ = [service_ fetchFeedWithURL:authFeedURL
                             feedClass:kGDataUseRegisteredClass
                              delegate:self
                     didFinishSelector:@selector(ticket:finishedWithObject:error:)];
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

  ticket_ = [service_ fetchFeedWithURL:authFeedURL
                             feedClass:kGDataUseRegisteredClass
                              delegate:self
                     didFinishSelector:@selector(ticket:finishedWithObject:error:)];
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

  ticket_ = [service_ fetchFeedWithURL:authFeedURL
                             feedClass:kGDataUseRegisteredClass
                              delegate:self
                     didFinishSelector:@selector(ticket:finishedWithObject:error:)];
  [ticket_ retain];

  [self waitForFetch];

  STAssertNil(fetchedObject_, @"fetchedObject_=%@", fetchedObject_);
  STAssertEquals([fetcherError_ code], (NSInteger)403,
                 @"fetcherError_=%@", fetcherError_);
  STAssertEqualObjects([ticket_ userData], defaultUserData, @"userdata error");
  STAssertEqualObjects([ticket_ propertyForKey:testPropertyKey],
                       defaultPropertyValue, @"default property error");


  //
  // test:  download feed only, unsuccessful auth - captcha required
  //
  [self resetFetchResponse];

  [service_ setUserCredentialsWithUsername:@"myaccount@mydomain.com"
                                  password:@"captcha"];

  ticket_ = [service_ fetchFeedWithURL:authFeedURL
                             feedClass:kGDataUseRegisteredClass
                              delegate:self
                     didFinishSelector:@selector(ticket:finishedWithObject:error:)];
  [ticket_ retain];

  [self waitForFetch];

  STAssertNil(fetchedObject_, @"fetchedObject_=%@", fetchedObject_);
  STAssertEquals([fetcherError_ code], (NSInteger)403,
                 @"fetcherError_=%@", fetcherError_);

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

  ticket_ = [service_ fetchFeedWithURL:authFeedURL
                             feedClass:kGDataUseRegisteredClass
                              delegate:self
                     didFinishSelector:@selector(ticket:finishedWithObject:error:)];
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

  ticket_ = [service_ fetchFeedWithURL:authFeedURL
                             feedClass:kGDataUseRegisteredClass
                              delegate:self
                     didFinishSelector:@selector(ticket:finishedWithObject:error:)];
  [ticket_ retain];

  [self waitForFetch];

  STAssertNil(fetchedObject_, @"fetchedObject_=%@", fetchedObject_);
  STAssertEquals([fetcherError_ code], (NSInteger)403,
                 @"fetcherError_=%@", fetcherError_);

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

  ticket_ = [service_ fetchEntryByInsertingEntry:[GDataEntrySpreadsheetCell entry]
                                      forFeedURL:authEntryURL
                                        delegate:self
                               didFinishSelector:@selector(ticket:finishedWithObject:error:)];
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

  ticket_ = [service_ fetchEntryByUpdatingEntry:[GDataEntrySpreadsheetCell entry]
                                    forEntryURL:authEntryURL
                                       delegate:self
                              didFinishSelector:@selector(ticket:finishedWithObject:error:)];
  [ticket_ retain];

  [self waitForFetch];

  STAssertEqualObjects([(GDataEntrySpreadsheetCell *)fetchedObject_ identifier],
                       entryID, @"fetching %@", authFeedURL);
  STAssertNil(fetcherError_, @"fetcherError_=%@", fetcherError_);
  STAssertEqualObjects([ticket_ userData], defaultUserData, @"userdata error");

  //
  // test:  update/download streamed entry data with progress monitoring
  //        and logging, successful auth, logging on
  //
  [self resetFetchResponse];

  [GDataHTTPFetcher setIsLoggingEnabled:YES];
  [GDataHTTPFetcher setLoggingDirectory:NSTemporaryDirectory()];

  // report the logging directory (the log file names depend on the process
  // launch time, but this at least lets us manually inspect the logs)
  NSLog(@"GDataServiceTest http logging set to %@",
        [GDataHTTPFetcher loggingDirectory]);

  GDataEntryPhoto *photoEntry = [GDataEntryPhoto photoEntry];
  NSImage *image = [NSImage imageNamed:@"NSApplicationIcon"];
  NSData *tiffData = [image TIFFRepresentation];
  STAssertTrue([tiffData length] > 0, @"failed to make tiff image");

  [photoEntry setPhotoData:tiffData];
  [photoEntry setPhotoMIMEType:@"image/tiff"];
  [photoEntry setUploadSlug:@"unit test photo.tif"];
  [photoEntry setTitleWithString:@"Unit Test Photo"];

  SEL progressSel = @selector(inputStream:hasDeliveredByteCount:ofTotalByteCount:);
  [service_ setServiceUploadProgressSelector:progressSel];

  // note that the authEntryURL still points to a spreadsheet entry, so
  // spreadsheet XML is what will be returned, but we don't really care

  ticket_ = [service_ fetchEntryByUpdatingEntry:photoEntry
                                    forEntryURL:authEntryURL
                                       delegate:self
                              didFinishSelector:@selector(ticket:finishedWithObject:error:)];
  [ticket_ retain];

  [self waitForFetch];

  STAssertEqualObjects([(GDataEntrySpreadsheetCell *)fetchedObject_ identifier],
                       entryID, @"fetching %@", authFeedURL);
  STAssertNil(fetcherError_, @"fetcherError_=%@", fetcherError_);
  STAssertEqualObjects([ticket_ userData], defaultUserData, @"userdata error");

  STAssertTrue(lastProgressDeliveredCount_ > 0, @"no byte delivery reported");
  STAssertEquals(lastProgressDeliveredCount_, lastProgressTotalCount_,
                 @"unexpected byte delivery count");

  [GDataHTTPFetcher setIsLoggingEnabled:NO];
  [GDataHTTPFetcher setLoggingDirectory:nil];

  [service_ setServiceUploadProgressSelector:nil];


  //
  // test:  delete entry with ETag, successful auth
  //
  [self resetFetchResponse];

  GDataEntrySpreadsheetCell *entryToDelete = [GDataEntrySpreadsheetCell entry];
  [entryToDelete addLink:[GDataLink linkWithRel:@"edit"
                                           type:nil
                                           href:[authFeedURL absoluteString]]];
  [entryToDelete setETag:@"A0MCQHs-fyp7ImA9WxVVF0Q."];

  ticket_ = [service_ deleteEntry:entryToDelete
                         delegate:self
                didFinishSelector:@selector(ticket:finishedWithObject:error:)];
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

  ticket_ = [service_ deleteResourceURL:authEntryURL
                                   ETag:nil
                               delegate:self
                      didFinishSelector:@selector(ticket:finishedWithObject:error:)];
  [ticket_ retain];

  [self waitForFetch];

  STAssertNil(fetchedObject_, @"deleting %@ returned \n%@", authEntryURL, fetchedObject_);
  STAssertNil(fetcherError_, @"fetcherError_=%@", fetcherError_);
  STAssertEqualObjects([ticket_ userData], defaultUserData, @"userdata error");

  //
  // test: fetch feed with authsub, successful
  //

  [self resetFetchResponse];

  [service_ setUserCredentialsWithUsername:nil
                                  password:nil];
  [service_ setAuthSubToken:@"GoodAuthSubToken"];

  ticket_ = [service_ fetchFeedWithURL:authSubFeedURL
                             feedClass:kGDataUseRegisteredClass
                              delegate:self
                     didFinishSelector:@selector(ticket:finishedWithObject:error:)];
  [ticket_ retain];

  [self waitForFetch];

  STAssertEqualObjects([(GDataFeedSpreadsheet *)fetchedObject_ identifier],
                       sheetID, @"fetching %@", authSubFeedURL);
  STAssertNil(fetcherError_, @"fetcherError_=%@", fetcherError_);

  //
  // test: fetch feed with authsub, bad token
  //

  [self resetFetchResponse];

  [service_ setAuthSubToken:@"bogus"];

  ticket_ = [service_ fetchFeedWithURL:authSubFeedURL
                             feedClass:kGDataUseRegisteredClass
                              delegate:self
                     didFinishSelector:@selector(ticket:finishedWithObject:error:)];
  [ticket_ retain];

  [self waitForFetch];

  STAssertNil(fetchedObject_, @"fetchedObject_=%@", fetchedObject_);
  STAssertEquals([fetcherError_ code], (NSInteger)401,
                 @"fetcherError_=%@", fetcherError_);
  STAssertEqualObjects([ticket_ userData], defaultUserData, @"userdata error");
  STAssertEqualObjects([ticket_ propertyForKey:testPropertyKey],
                       defaultPropertyValue, @"default property error");

}

// fetch callbacks

- (void)ticket:(GDataServiceTicket *)ticket finishedWithObject:(GDataObject *)object error:(NSError *)error {

  STAssertEquals(ticket, ticket_, @"Got unexpected ticket");

  if (error == nil) {
    fetchedObject_ = [object retain]; // save the fetched object, if any
  } else {
    fetcherError_ = [error retain]; // save the error
    STAssertNil(object, @"Unexpected object in callback");
  }
  ++gFetchCounter;
}

- (void)inputStream:(GDataProgressMonitorInputStream *)stream
hasDeliveredByteCount:(unsigned long long)numberOfBytesRead
     ofTotalByteCount:(unsigned long long)dataLength {

  lastProgressDeliveredCount_ = numberOfBytesRead;
  lastProgressTotalCount_ = dataLength;
}

#pragma mark Retry fetch tests

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
    [service_ fetchPublicFeedWithURL:authFeedStatusURL
                           feedClass:kGDataUseRegisteredClass
                            delegate:self
                   didFinishSelector:@selector(ticket:finishedWithObject:error:)];
  [ticket_ retain];

  [ticket_ setUserData:[NSNumber numberWithInt:1000]]; // lots of retries

  [self waitForFetch];

  STAssertNil(fetchedObject_, @"obtained object unexpectedly");
  STAssertEquals([fetcherError_ code], (NSInteger)503,
                 @"fetcherError_ should be 503, was %@", fetcherError_);
  STAssertEquals([[ticket_ objectFetcher] retryCount], (NSUInteger) 3,
               @"retry count should be 3, was %lu",
               (unsigned long) [[ticket_ objectFetcher] retryCount]);

  // check that the expected notifications happened for the object
  // fetches and the retries
  STAssertEquals(fetchStartedNotificationCount_, 4, @"start note missing");
  STAssertEquals(fetchStoppedNotificationCount_, 4, @"stopped note missing");
  STAssertEquals(retryDelayStartedNotificationCount_, 3, @"retry delay note missing");
  STAssertEquals(retryDelayStoppedNotificationCount_, 3, @"retry delay note missing");

  //
  // test:  retry twice, then give up
  //
  [self resetFetchResponse];

  [service_ setServiceMaxRetryInterval:10.]; // retry intervals of 1, 2, 4, 8
  [service_ setServiceRetrySelector:@selector(stopRetryTicket:willRetry:forError:)];

  ticket_ = (GDataServiceTicket *)
    [service_ fetchPublicFeedWithURL:authFeedStatusURL
                     feedClass:kGDataUseRegisteredClass
                      delegate:self
             didFinishSelector:@selector(ticket:finishedWithObject:error:)];
  [ticket_ retain];

  // set userData to the number of retries allowed
  [ticket_ setUserData:[NSNumber numberWithInt:2]];

  [self waitForFetch];

  STAssertNil(fetchedObject_, @"obtained object unexpectedly");
  STAssertEquals([fetcherError_ code], (NSInteger)503,
                 @"fetcherError_ should be 503, was %@", fetcherError_);
  STAssertEquals([[ticket_ objectFetcher] retryCount], (NSUInteger) 2,
                 @"retry count should be 2, was %lu",
                 (unsigned long) [[ticket_ objectFetcher] retryCount]);

  //
  // test:  retry, making the request succeed on the first retry
  // by fixing the URL
  //
  [self resetFetchResponse];

  [service_ setServiceMaxRetryInterval:100.];
  [service_ setServiceRetrySelector:@selector(fixRequestRetryTicket:willRetry:forError:)];

  ticket_ = (GDataServiceTicket *)
    [service_ fetchPublicFeedWithURL:authFeedStatusURL
                           feedClass:kGDataUseRegisteredClass
                            delegate:self
                 didFinishSelector:@selector(ticket:finishedWithObject:error:)];
  [ticket_ retain];

  [self waitForFetch];

  STAssertNotNil(fetchedObject_, @"should have obtained fetched object");
  STAssertNil(fetcherError_, @"fetcherError_=%@", fetcherError_);
  STAssertEquals([[ticket_ objectFetcher] retryCount], (NSUInteger) 1,
                 @"retry count should be 1, was %lu",
                 (unsigned long) [[ticket_ objectFetcher] retryCount]);

  //
  // test:  download feed only, no auth, surrogate feed class
  //
  [self resetFetchResponse];
}

-(BOOL)stopRetryTicket:(GDataServiceTicket *)ticket willRetry:(BOOL)suggestedWillRetry forError:(NSError *)error {

  GDataHTTPFetcher *fetcher = [ticket currentFetcher];
  [fetcher setMinRetryInterval:1.0]; // force exact starting interval of 1.0 sec

  NSInteger count = [fetcher retryCount];
  NSInteger allowedRetryCount = [[ticket userData] intValue];

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

#pragma mark Standalone auth tests

- (void)resetAuthResponse {
  [authToken_ release];
  authToken_ = nil;

  [authError_ release];
  authError_ = nil;
}

- (void)waitForAuth {

  // Give time for the auth to happen, but give up if
  // 10 seconds elapse with no response
  NSDate* giveUpDate = [NSDate dateWithTimeIntervalSinceNow:10.0];

  while ((!authToken_ && !authError_)
         && [giveUpDate timeIntervalSinceNow] > 0) {

    NSDate *stopDate = [NSDate dateWithTimeIntervalSinceNow:0.001];
    [[NSRunLoop currentRunLoop] runUntilDate:stopDate];
  }
}

- (void)testStandaloneServiceAuth {

  if (!isServerRunning_) return;

  // test successful auth
  [service_ setUserCredentialsWithUsername:@"myaccount@mydomain.com"
                                  password:@"mypassword"];
  [service_ authenticateWithDelegate:self
             didAuthenticateSelector:@selector(ticket:authenticatedWithError:)];
  [self waitForAuth];

  STAssertTrue([authToken_ length] > 0, @"auth token missing");
  STAssertNil(authError_, @"unexpected auth error: %@", authError_);

  [self resetAuthResponse];

  // test unsuccessful auth
  [service_ setUserCredentialsWithUsername:@"myaccount@mydomain.com"
                                  password:@"bad"];
  [service_ authenticateWithDelegate:self
             didAuthenticateSelector:@selector(ticket:authenticatedWithError:)];
  [self waitForAuth];

  STAssertNil(authToken_, @"unexpected auth token: %@", authToken_);
  STAssertNotNil(authError_, @"auth error missing");

  [self resetAuthResponse];
}

- (void)ticket:(GDataServiceTicket *)ticket
authenticatedWithError:(NSError *)error {
  authToken_ = [[[ticket service] authToken] retain];
  authError_ = [error retain];
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

#endif // !GDATA_SKIPSERVICETEST
