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
//  // optional fetch history, for persisting modified-dates and local cookie
//  // storage
//  [myFetcher setFetchHistory:myFetchHistory];
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
//  The block callback version looks like:
//
//  [myFetcher beginFetchWithCompletionHandler:^(NSData *retrievedData, NSError *error) {
//    if (error != nil) {
//      // status code or network error
//    } else {
//      // succeeded
//    }
//  }];

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
// - (void)myFetcher:(GDataHTTPFetcher *)fetcher failedWithStatus:(NSInteger)status data:(NSData *)data {
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

#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4) || defined(GDATA_TARGET_NAMESPACE)
  // we need NSInteger for the 10.4 SDK, or we're using target namespace macros
  #import "GDataDefines.h"
#else
  #if TARGET_OS_IPHONE
    #ifndef GDATA_FOUNDATION_ONLY
      #define GDATA_FOUNDATION_ONLY 1
    #endif
    #ifndef GDATA_IPHONE
      #define GDATA_IPHONE 1
    #endif
  #endif
#endif


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
//
// fetch started and stopped, and fetch retry delay started and stopped
_EXTERN NSString* const kGDataHTTPFetcherStartedNotification           _INITIALIZE_AS(@"kGDataHTTPFetcherStartedNotification");
_EXTERN NSString* const kGDataHTTPFetcherStoppedNotification           _INITIALIZE_AS(@"kGDataHTTPFetcherStoppedNotification");
_EXTERN NSString* const kGDataHTTPFetcherRetryDelayStartedNotification _INITIALIZE_AS(@"kGDataHTTPFetcherRetryDelayStartedNotification");
_EXTERN NSString* const kGDataHTTPFetcherRetryDelayStoppedNotification _INITIALIZE_AS(@"kGDataHTTPFetcherRetryDelayStoppedNotification");

// callback constants
_EXTERN NSString* const kGDataHTTPFetcherErrorDomain       _INITIALIZE_AS(@"com.google.GDataHTTPFetcher");
_EXTERN NSString* const kGDataHTTPFetcherStatusDomain      _INITIALIZE_AS(@"com.google.HTTPStatus");
_EXTERN NSString* const kGDataHTTPFetcherErrorChallengeKey _INITIALIZE_AS(@"challenge");
_EXTERN NSString* const kGDataHTTPFetcherStatusDataKey     _INITIALIZE_AS(@"data");                        // data returned with a kGDataHTTPFetcherStatusDomain error


enum {
  kGDataHTTPFetcherErrorDownloadFailed = -1,
  kGDataHTTPFetcherErrorAuthenticationChallengeFailed = -2,
  kGDataHTTPFetcherErrorChunkUploadFailed = -3,
  kGDataHTTPFetcherErrorFileHandleException = -4,

  kGDataHTTPFetcherStatusNotModified = 304
};

// cookie storage methods
enum {
  kGDataHTTPFetcherCookieStorageMethodStatic = 0,
  kGDataHTTPFetcherCookieStorageMethodFetchHistory = 1,
  kGDataHTTPFetcherCookieStorageMethodSystemDefault = 2,
  kGDataHTTPFetcherCookieStorageMethodNone = 3
};

// default data cache size for when we're caching responses to handle "not
// modified" errors for the client
#if GDATA_IPHONE
// iPhone: up to 1MB memory
_EXTERN const NSUInteger kGDataDefaultDatedDataCacheMemoryCapacity _INITIALIZE_AS(1*1024*1024);
#else
// Mac OS X: up to 15MB memory
_EXTERN const NSUInteger kGDataDefaultDatedDataCacheMemoryCapacity _INITIALIZE_AS(15*1024*1024);
#endif


void AssertSelectorNilOrImplementedWithArguments(id obj, SEL sel, ...);

@class GDataURLCache;
@class GDataCookieStorage;

//
// Users of the GDataHTTPFetcher class may optionally create and set a fetch
// history object.  The fetch history provides "memory" between subsequent
// fetches, including:
//
// - For fetch responses with "last-modified" headers, the fetch history
//   remembers the response headers. Future fetcher requests to the same URL
//   will be given an "If-modified-since" header, telling the server to return
//   a 304 Not Modified status if the response is unchanged, reducing the
//   server load and network traffic.
//
// - Optionally, the fetch history can cache the dated data that was returned
//   in the responses that contained "Last-modified" headers. If a later fetch
//   results in a 304 status, the fetcher will return the cached dated data
//   to the client along with a 200 status, hiding the 304.
//
// - The fetch history can track cookies.
//

@interface GDataHTTPFetchHistory : NSObject {
  GDataURLCache *datedDataCache_;
  BOOL shouldCacheDatedData_;      // if NO, then only headers are cached
  GDataCookieStorage *cookieStorage_;
}

- (id)initWithMemoryCapacity:(NSUInteger)totalBytes
        shouldCacheDatedData:(BOOL)shouldCacheDatedData;

- (void)clearDatedDataCache;
- (void)clearHistory;

- (BOOL)shouldCacheDatedData;
- (void)setShouldCacheDatedData:(BOOL)flag;

- (GDataCookieStorage *)cookieStorage;
- (void)setCookieStorage:(GDataCookieStorage *)obj;

// the default dated data cache capacity is kGDataDefaultDatedDataCacheMemoryCapacity
- (NSUInteger)memoryCapacity;
- (void)setMemoryCapacity:(NSUInteger)totalBytes;

@end


// async retrieval of an http get or post
@interface GDataHTTPFetcher : NSObject {
  NSMutableURLRequest *request_;
  NSURLConnection *connection_;
  NSMutableData *downloadedData_;
  NSFileHandle *downloadFileHandle_;
  NSURLCredential *credential_;     // username & password
  NSURLCredential *proxyCredential_; // credential supplied to proxy servers
  NSData *postData_;
  NSInputStream *postStream_;
  NSMutableData *loggedStreamData_;
  NSURLResponse *response_;         // set in connection:didReceiveResponse:
  id delegate_;                     // retained during an open connection
  SEL finishedSEL_;                 // should by implemented by delegate
  SEL statusFailedSEL_;             // implemented by delegate if it needs separate network error callbacks
  SEL networkFailedSEL_;            // should be implemented by delegate
  SEL sentDataSEL_;                 // optional, set with setSentDataSelector
  SEL receivedDataSEL_;             // optional, set with setReceivedDataSelector
#if NS_BLOCKS_AVAILABLE
  void (^completionBlock_)(NSData *, NSError *);
  void (^receivedDataBlock_)(NSData *);
  void (^sentDataBlock_)(NSInteger, NSInteger, NSInteger);
  BOOL (^retryBlock_)(BOOL, NSError *);
#elif !__LP64__
  // placeholders: for 32-bit builds, keep the size of the object's ivar section
  // the same with and without blocks
  id completionPlaceholder_;
  id receivedDataPlaceholder_;
  id retryPlaceholder_;
#endif
  BOOL hasConnectionEnded_;          // set if the connection need not be cancelled
  BOOL isCancellingChallenge_;      // set only when cancelling an auth challenge
  BOOL isStopNotificationNeeded_;   // set when start notification has been sent
  id userData_;                     // retained, if set by caller
  NSMutableDictionary *properties_; // more data retained for caller
  NSArray *runLoopModes_;           // optional, for 10.5 and later
  GDataHTTPFetchHistory *fetchHistory_; // if supplied by the caller, used for Last-Modified-Since checks and cookies
  NSInteger cookieStorageMethod_;   // constant from above
  GDataCookieStorage *cookieStorage_;

  BOOL isRetryEnabled_;             // user wants auto-retry
  SEL retrySEL_;                    // optional; set with setRetrySelector
  NSTimer *retryTimer_;
  NSUInteger retryCount_;
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

// the default cookie storage method is kGDataHTTPFetcherCookieStorageMethodStatic
// without a fetch history set, and kGDataHTTPFetcherCookieStorageMethodFetchHistory
// with a fetch history set
- (NSInteger)cookieStorageMethod;
- (void)setCookieStorageMethod:(NSInteger)method;

// the delegate is retained during the connection
- (id)delegate;
- (void)setDelegate:(id)theDelegate;

// the delegate's optional sentData selector has a signature like:
//  - (void)myFetcher:(GDataHTTPFetcher *)fetcher
//              didSendBytes:(NSInteger)bytesSent
//            totalBytesSent:(NSInteger)totalBytesSent
//  totalBytesExpectedToSend:(NSInteger)totalBytesExpectedToSend;
//
// +doesSupportSentDataCallback indicates if this delegate method is supported
+ (BOOL)doesSupportSentDataCallback;
- (SEL)sentDataSelector;
- (void)setSentDataSelector:(SEL)theSelector;

// the delegate's optional receivedData selector has a signature like:
//  - (void)myFetcher:(GDataHTTPFetcher *)fetcher receivedData:(NSData *)dataReceivedSoFar;
//
// the received data argument will be nil when downloading to a file handle
- (SEL)receivedDataSelector;
- (void)setReceivedDataSelector:(SEL)theSelector;

#if NS_BLOCKS_AVAILABLE
- (void)setSentDataBlock:(void (^)(NSInteger bytesSent, NSInteger totalBytesSent, NSInteger bytesExpectedToSend))block;
- (void)setReceivedDataBlock:(void (^)(NSData *dataReceivedSoFar))block;
#endif

// retrying; see comments at the top of the file.  Calling
// setIsRetryEnabled(YES) resets the min and max retry intervals.
- (BOOL)isRetryEnabled;
- (void)setIsRetryEnabled:(BOOL)flag;

// retry selector or block is optional for retries.
//
// If present, it should have the signature:
//   -(BOOL)fetcher:(GDataHTTPFetcher *)fetcher willRetry:(BOOL)suggestedWillRetry forError:(NSError *)error
// and return YES to cause a retry.  See comments at the top of this file.
- (SEL)retrySelector;
- (void)setRetrySelector:(SEL)theSel;

#if NS_BLOCKS_AVAILABLE
- (void)setRetryBlock:(BOOL (^)(BOOL suggestedWillRetry, NSError *error))block;
#endif

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
- (NSUInteger)retryCount;

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

#if NS_BLOCKS_AVAILABLE
- (BOOL)beginFetchWithCompletionHandler:(void (^)(NSData *data, NSError *error))handler;
#endif


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
//   - (void)fetcher:(GDataHTTPFetcher *)fetcher failedWithStatus:(NSInteger)status data:(NSData *)data
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

// If downloadFileHandle is set, data received is immediately appended to
// the file handle rather than being accumulated in the downloadedData
//
// The file handle supplied must allow writing and support seekToFileOffset:,
// and must be set before downloading begins.
- (NSFileHandle *)downloadFileHandle;
- (void)setDownloadFileHandle:(NSFileHandle *)fileHandle;

// the response, once it's been received
- (NSURLResponse *)response;
- (void)setResponse:(NSURLResponse *)response;

// buffer of currently-downloaded data
- (NSData *)downloadedData;

// if the caller supplies a mutable dictionary, it's used for Last-Modified-Since
//  checks and for cookie storage
//  side effect: setFetchHistory implicitly calls setCookieStorageMethod:
- (GDataHTTPFetchHistory *)fetchHistory;
- (void)setFetchHistory:(GDataHTTPFetchHistory *)fetchHistory;

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

- (void)addPropertiesFromDictionary:(NSDictionary *)dict;

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

#if STRIP_GDATA_FETCH_LOGGING
// if logging is stripped, provide a stub for the main method
// for controlling logging
+ (void)setIsLoggingEnabled:(BOOL)flag;
#endif // STRIP_GDATA_FETCH_LOGGING

@end

@interface GDataCookieStorage : NSObject {
  // The cookie storage object manages an array holding cookies, but the array
  // is allocated externally (it may be in a fetcher object or the static
  // fetcher cookie array.)  See the fetcher's setCookieStorageMethod:
  // for allocation of this object and assignment of its cookies array.
  NSMutableArray *cookies_;
}

// add all NSHTTPCookies in the supplied array to the storage array,
// replacing cookies in the storage array as appropriate
// Side effect: removes expired cookies from the storage array
- (void)setCookies:(NSArray *)newCookies;

// retrieve all cookies appropriate for the given URL, considering
// domain, path, cookie name, expiration, security setting.
// Side effect: removes expired cookies from the storage array
- (NSArray *)cookiesForURL:(NSURL *)theURL;

// return a cookie with the same name, domain, and path as the
// given cookie, or else return nil if none found
//
// Both the cookie being tested and all stored cookies should
// be valid (non-nil name, domains, paths)
- (NSHTTPCookie *)cookieMatchingCookie:(NSHTTPCookie *)cookie;

// remove any expired cookies, excluding cookies with nil expirations
- (void)removeExpiredCookies;

- (void)removeAllCookies;

@end
