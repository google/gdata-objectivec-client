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
//  GDataHTTPFetcher.h
//

// This is essentially a wrapper around NSURLConnection for POSTs and GETs.
// If setPostData: is called, then POST is assumed.
//
// When would you use this instead of NSURLConnection?
//
// - When you just want the result from a GET or POST
// - When you want the "standard" behavior for connections (redirection handling
//   an so on)
// - When you want to avoid cookie collisions with Safari and other applications
// - When you want to provide if-modified-since headers
// - When you need to set a credential for the http
// - When you want to avoid changing WebKit's cookies
//
// This is assumed to be a one-shot fetch request; don't reuse the object
// for a second fetch.
//
// The fetcher may be created auto-released, in which case it will release
// itself after the fetch completion callback.  The fetcher
// is implicitly retained as long as a connection is pending.
//
// But if you may need to cancel the fetcher, allocate it with initWithRequest:
// and have the delegate release the fetcher in the callbacks.
//
// Sample usage:
//
//  NSURLRequest *request = [NSURLRequest requestWithURL:myURL];
//  GDataHTTPFetcher* myFetcher = [GDataHTTPFetcher httpFetcherWithRequest:request];
//
//  // optional post data
//  [myFetcher setPostData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
//
//  // optional dictionary, for persisting modified-dates and local cookie storage
//  [myFetcher setFetchHistory:myMutableDictionary];
//
//  [myFetcher beginFetchWithDelegate:self
//                  didFinishSelector:@selector(myFetcher:finishedWithData:)
//                    didFailSelector:@selector(myFetcher:failedWithError:)];
//
//  Upon fetch completion, the callback selectors are invoked; they should have
//  these signatures (you can use any callback method names you want so long as
//  the signatures match these):
//
//  - (void)myFetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)retrievedData;
//  - (void)myFetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error;
//
// NOTE:  Fetches may retrieve data from the server even though the server
//        returned an error.  The failure selector is called when the server
//        status is >= 300, with an NSError having domain
//        kGDataHTTPFetcherStatusDomain and code set to the server status.
//
//        Status codes are at <http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html>
//
//
// Proxies:
//
// Proxy handling is invisible so long as the system has a valid credential in
// the keychain, which is normally true (else most NSURL-based apps would have
// difficulty.)  But when there is a proxy authetication error, the the fetcher
// will call the failedWithError: method with the NSURLChallenge in the error's
// userInfo. The error method can get the challenge info like this:
//
//  NSURLAuthenticationChallenge *challenge
//     = [[error userInfo] objectForKey:kGDataHTTPFetcherErrorChallengeKey];
//  BOOL isProxyChallenge = [[challenge protectionSpace] isProxy];
//
// If a proxy error occurs, you can ask the user for the proxy username/password
// and call fetcher's setProxyCredential: to provide those for the
// next attempt to fetch.
//
//
// Cookies:
//
// There are three supported mechanisms for remembering cookies between fetches.
//
// By default, GDataHTTPFetcher uses a mutable array held statically to track
// cookies for all instantiated fetchers. This avoids server cookies being set
// by servers for the application from interfering with Safari cookie settings,
// and vice versa.  The fetcher cookies are lost when the application quits.
//
// To rely instead on WebKit's global NSHTTPCookieStorage, call
// setCookieStorageMethod: with kGDataHTTPFetcherCookieStorageMethodSystemDefault.
//
// If you provide a fetch history dictionary (such as for periodic checks,
// described below) then the cookie storage mechanism is set to use the fetch
// history rather than the static storage.
//
//
// Fetching for periodic checks:
//
// The fetcher object can track "Last-modified" dates on returned data and
// provide an "If-modified-since" header. This allows the server to save
// bandwidth by providing a "Nothing changed" status message instead of response
// data.
//
// To get this behavior, provide a persistent mutable dictionary to
// setFetchHistory:, and look for the failedWithStatus: callback with code 304
// (kGDataHTTPFetcherStatusNotModified) like this:
//
// - (void)myFetcher:(GDataHTTPFetcher *)fetcher failedWithStatus:(int)status data:(NSData *)data {
//    if (status == kGDataHTTPFetcherStatusNotModified) {
//      // |data| is empty; use the data from the previous finishedWithData: for this URL
//    } else {
//      // handle other server status code
//    }
// }
//
// The fetchHistory mutable dictionary should be maintained by the client between
// fetches and given to each fetcher intended to have the If-modified-since header
// or the same cookie storage.
//
//
// Monitoring received data
//
// The optional received data selector can be set with setReceivedDataSelector:
// and should have the signature
//
//  - (void)myFetcher:(GDataHTTPFetcher *)fetcher receivedData:(NSData *)dataReceivedSoFar;
//
// The bytes received so far are [dataReceivedSoFar length]. This number may go
// down if a redirect causes the download to begin again from a new server.
//
// If supplied by the server, the anticipated total download size is available as
//    [[myFetcher response] expectedContentLength] (may be -1 for unknown
//    download sizes.)
//
//
// Automatic retrying of fetches
//
// The fetcher can optionally create a timer and reattempt certain kinds of
// fetch failures (status codes 408, request timeout; 503, service unavailable;
// 504, gateway timeout; networking errors NSURLErrorTimedOut and
// NSURLErrorNetworkConnectionLost.)  The user may set a retry selector to
// customize the type of errors which will be retried.
//
// Retries are done in an exponential-backoff fashion (that is, after 1 second,
// 2, 4, 8, and so on.)
//
// Enabling automatic retries looks like this:
//  [myFetcher setIsRetryEnabled:YES];
//
// With retries enabled, the success or failure callbacks are called only
// when no more retries will be attempted. Calling the fetcher's stopFetching
// method will terminate the retry timer, without the finished or failure
// selectors being invoked.
//
// Optionally, the client may set the maximum retry interval:
//  [myFetcher setMaxRetryInterval:60.]; // in seconds; default is 600 seconds
//
// Also optionally, the client may provide a callback selector to determine
// if a status code or other error should be retried.
//  [myFetcher setRetrySelector:@selector(myFetcher:willRetry:forError:)];
//
// If set, the retry selector should have the signature:
//   -(BOOL)fetcher:(GDataHTTPFetcher *)fetcher willRetry:(BOOL)suggestedWillRetry forError:(NSError *)error
// and return YES to set the retry timer or NO to fail without additional
// fetch attempts.
//
// The retry method may return the |suggestedWillRetry| argument to get the
// default retry behavior.  Server status codes are present in the
// error argument, and have the domain kGDataHTTPFetcherStatusDomain. The
// user's method may look something like this:
//
//  -(BOOL)myFetcher:(GDataHTTPFetcher *)fetcher willRetry:(BOOL)suggestedWillRetry forError:(NSError *)error {
//
//    // perhaps examine [error domain] and [error code], or [fetcher retryCount]
//    //
//    // return YES to start the retry timer, NO to proceed to the failure
//    // callback, or |suggestedWillRetry| to get default behavior for the
//    // current error domain and code values.
//    return suggestedWillRetry;
//  }



#pragma once

#import <Foundation/Foundation.h>

#import "GDataDefines.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAHTTPFETCHER_DEFINE_GLOBALS
#define _EXTERN
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

// notifications
_EXTERN NSString* const kGDataHTTPFetcherErrorDomain _INITIALIZE_AS(@"com.google.GDataHTTPFetcher");
_EXTERN NSString* const kGDataHTTPFetcherStatusDomain _INITIALIZE_AS(@"com.google.HTTPStatus");
_EXTERN NSString* const kGDataHTTPFetcherErrorChallengeKey _INITIALIZE_AS(@"challenge");
_EXTERN NSString* const kGDataHTTPFetcherStatusDataKey _INITIALIZE_AS(@"data"); // data returned with a kGDataHTTPFetcherStatusDomain error


// fetch history mutable dictionary keys
_EXTERN NSString* const kGDataHTTPFetcherHistoryLastModifiedKey _INITIALIZE_AS(@"FetchHistoryLastModified");
_EXTERN NSString* const kGDataHTTPFetcherHistoryDatedDataKey _INITIALIZE_AS(@"FetchHistoryDatedDataCache");
_EXTERN NSString* const kGDataHTTPFetcherHistoryCookiesKey _INITIALIZE_AS(@"FetchHistoryCookies");

enum {
  kGDataHTTPFetcherErrorDownloadFailed = -1,
  kGDataHTTPFetcherErrorAuthenticationChallengeFailed = -2,

  kGDataHTTPFetcherStatusNotModified = 304
};

enum {
  kGDataHTTPFetcherCookieStorageMethodStatic = 0,
  kGDataHTTPFetcherCookieStorageMethodFetchHistory = 1,
  kGDataHTTPFetcherCookieStorageMethodSystemDefault = 2
};

void AssertSelectorNilOrImplementedWithArguments(id obj, SEL sel, ...);

// async retrieval of an http get or post
@interface GDataHTTPFetcher : NSObject {
  NSMutableURLRequest *request_;
  NSURLConnection *connection_;    // while connection_ is non-nil, delegate_ is retained
  NSMutableData *downloadedData_;
  NSURLCredential *credential_;     // username & password
  NSURLCredential *proxyCredential_; // credential supplied to proxy servers
  NSData *postData_;
  NSInputStream *postStream_;
  NSMutableData *loggedStreamData_;
  NSURLResponse *response_;         // set in connection:didReceiveResponse:
  id delegate_;                     // WEAK (though retained during an open connection)
  SEL finishedSEL_;                 // should by implemented by delegate
  SEL statusFailedSEL_;             // implemented by delegate if it needs separate network error callbacks
  SEL networkFailedSEL_;            // should be implemented by delegate
  SEL receivedDataSEL_;             // optional, set with setReceivedDataSelector
  id userData_;                     // retained, if set by caller
  NSMutableDictionary *properties_; // more data retained for caller
  NSArray *runLoopModes_;           // optional, for 10.5 and later
  NSMutableDictionary *fetchHistory_; // if supplied by the caller, used for Last-Modified-Since checks and cookies
  BOOL shouldCacheDatedData_;       // if true, remembers and returns data marked with a last-modified date
  int cookieStorageMethod_;         // constant from above

  BOOL isRetryEnabled_;             // user wants auto-retry
  SEL retrySEL_;                    // optional; set with setRetrySelector
  NSTimer *retryTimer_;
  unsigned int retryCount_;
  NSTimeInterval maxRetryInterval_; // default 600 seconds
  NSTimeInterval minRetryInterval_; // random between 1 and 2 seconds
  NSTimeInterval retryFactor_;      // default interval multiplier is 2
  NSTimeInterval lastRetryInterval_;
}

// create a fetcher
//
// httpFetcherWithRequest will return an autoreleased fetcher, but if
// the connection is successfully created, the connection should retain the
// fetcher for the life of the connection as well. So the caller doesn't have
// to retain the fetcher explicitly unless they want to be able to cancel it.
+ (GDataHTTPFetcher *)httpFetcherWithRequest:(NSURLRequest *)request;

// designated initializer
- (id)initWithRequest:(NSURLRequest *)request;

- (NSMutableURLRequest *)request;
- (void)setRequest:(NSURLRequest *)theRequest;

// setting the credential is optional; it is used if the connection receives
// an authentication challenge
- (NSURLCredential *)credential;
- (void)setCredential:(NSURLCredential *)theCredential;

// setting the proxy credential is optional; it is used if the connection
// receives an authentication challenge from a proxy
- (NSURLCredential *)proxyCredential;
- (void)setProxyCredential:(NSURLCredential *)theCredential;


// if post data or stream is not set, then a GET retrieval method is assumed
- (NSData *)postData;
- (void)setPostData:(NSData *)theData;

// beware: In 10.4, NSInputStream fails to copy or retain
// the data it was initialized with, contrary to docs
- (NSInputStream *)postStream;
- (void)setPostStream:(NSInputStream *)theStream;

- (int)cookieStorageMethod;
- (void)setCookieStorageMethod:(int)method;

// returns cookies from the currently appropriate cookie storage
- (NSArray *)cookiesForURL:(NSURL *)theURL;

// the delegate is not retained except during the connection
- (id)delegate;
- (void)setDelegate:(id)theDelegate;

// the delegate's optional receivedData selector has a signature like:
//  - (void)myFetcher:(GDataHTTPFetcher *)fetcher receivedData:(NSData *)dataReceivedSoFar;
- (SEL)receivedDataSelector;
- (void)setReceivedDataSelector:(SEL)theSelector;


// retrying; see comments at the top of the file.  Calling
// setIsRetryEnabled(YES) resets the min and max retry intervals.
- (BOOL)isRetryEnabled;
- (void)setIsRetryEnabled:(BOOL)flag;

// retry selector is optional for retries.
//
// If present, it should have the signature:
//   -(BOOL)fetcher:(GDataHTTPFetcher *)fetcher willRetry:(BOOL)suggestedWillRetry forError:(NSError *)error
// and return YES to cause a retry.  See comments at the top of this file.
- (SEL)retrySelector;
- (void)setRetrySelector:(SEL)theSel;

// retry intervals must be strictly less than maxRetryInterval, else
// they will be limited to maxRetryInterval and no further retries will
// be attempted.  Setting maxRetryInterval to 0.0 will reset it to the
// default value, 600 seconds.
- (NSTimeInterval)maxRetryInterval;
- (void)setMaxRetryInterval:(NSTimeInterval)secs;

// Starting retry interval.  Setting minRetryInterval to 0.0 will reset it
// to a random value between 1.0 and 2.0 seconds.  Clients should normally not
// call this except for unit testing.
- (NSTimeInterval)minRetryInterval;
- (void)setMinRetryInterval:(NSTimeInterval)secs;

// Multiplier used to increase the interval between retries, typically 2.0.
// Clients should not need to call this.
- (double)retryFactor;
- (void)setRetryFactor:(double)multiplier;

// number of retries attempted
- (unsigned int)retryCount;

// interval delay to precede next retry
- (NSTimeInterval)nextRetryInterval;

// Begin fetching the request (simplified interface)
//
// The delegate can optionally implement the finished and failure selectors
// or pass nil for them.
//
// Returns YES if the fetch is initiated.  The delegate is retained between
// the beginFetch call until after the finish/fail callbacks.
//
// The failure selector is called for server statuses 300 or higher, with the
// status stored as the error object's code.
//
// finishedSEL has a signature like:
//   - (void)fetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data
// failedSEL has a signature like:
//   - (void)fetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error
//

- (BOOL)beginFetchWithDelegate:(id)delegate
             didFinishSelector:(SEL)finishedSEL
               didFailSelector:(SEL)failedSEL;


// Begin fetching the request (original interface)
//
// The delegate can optionally implement the finished, status failure, and
// network failure selectors, or pass nill for them.
//
// Returns YES if the fetch is initiated.  The delegate is retained between
// the beginFetch call until after the finish/fail callbacks.
//
// The failure selector is called if the server returns status >= 300
//
// finishedSEL has a signature like:
//   - (void)fetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data
// statusFailedSEL has a signature like:
//   - (void)fetcher:(GDataHTTPFetcher *)fetcher failedWithStatus:(int)status data:(NSData *)data
// failedSEL has a signature like:
//   - (void)fetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error
//

- (BOOL)beginFetchWithDelegate:(id)delegate
             didFinishSelector:(SEL)finishedSEL
     didFailWithStatusSelector:(SEL)statusFailedSEL
      didFailWithErrorSelector:(SEL)networkFailedSEL;

// Returns YES if this is in the process of fetching a URL
- (BOOL)isFetching;

// Cancel the fetch of the request that's currently in progress
- (void)stopFetching;

// return the status code from the server response
- (NSInteger)statusCode;

// return the http headers from the response
- (NSDictionary *)responseHeaders;

// the response, once it's been received
- (NSURLResponse *)response;
- (void)setResponse:(NSURLResponse *)response;

// if the caller supplies a mutable dictionary, it's used for Last-Modified-Since
//  checks and for cookie storage
//  side effect: setFetchHistory implicitly calls setCookieStorageMethod:
- (NSMutableDictionary *)fetchHistory;
- (void)setFetchHistory:(NSMutableDictionary *)fetchHistory;

// for fetched data with a last-modified date, cache the data
// in the fetch history and return cached data instead of a 304 error
// Set this to NO if you want to handle status 304 (Not changed) rather than be
// delivered cached data from previous fetches. Default is NO.
// When a cache result is returned, the didFinish selector is called
// with the data, but [fetcher status] still returns 304.

- (BOOL)shouldCacheDatedData;
- (void)setShouldCacheDatedData:(BOOL)flag;

// delete last-modified dates and cached data from the fetch history
- (void)clearDatedDataHistory;

// userData is retained for the convenience of the caller
- (id)userData;
- (void)setUserData:(id)theObj;

// properties are retained for the convenience of the caller
- (void)setProperties:(NSDictionary *)dict;
- (NSDictionary *)properties;

- (void)setProperty:(id)obj forKey:(NSString *)key; // pass nil obj to remove property
- (id)propertyForKey:(NSString *)key;

// using the fetcher while a modal dialog is displayed requires setting the
// run-loop modes to include NSModalPanelRunLoopMode
//
// setting run loop modes does nothing if they are not supported,
// such as on 10.4
- (NSArray *)runLoopModes;
- (void)setRunLoopModes:(NSArray *)modes;

+ (BOOL)doesSupportRunLoopModes;
+ (NSArray *)defaultRunLoopModes;
+ (void)setDefaultRunLoopModes:(NSArray *)modes;

// users who wish to replace GDataHTTPFetcher's use of NSURLConnection
// can do so globally here.  The replacement should be a subclass of
// NSURLConnection.
+ (Class)connectionClass;
+ (void)setConnectionClass:(Class)theClass;

@end
