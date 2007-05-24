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
//  [myFetcher setPostData:[postString dataUsingEncoding:NSUTF8StringEncoding]]; // for POSTs
//
//  [myFetcher setCredential:[NSURLCredential authCredentialWithUsername:@"foo" 
//                                                               password:@"bar"]]; // optional http credential
//
//  [myFetcher setFetchHistory:myMutableDictionary]; // optional, for persisting modified-dates
//
//  [myFetcher beginFetchWithDelegate:self
//                  didFinishSelector:@selector(myFetcher:finishedWithData:)
//          didFailWithStatusSelector:@selector(myFetcher:failedWithStatus:data:)
//           didFailWithErrorSelector:@selector(myFetcher:failedWithError:)];
//
//  Upon fetch completion, the callback selectors are invoked; they should have
//  these signatures (you can use any callback method names you want so long as
//  the signatures match these):
//
//  - (void)myFetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)retrievedData;
//  - (void)myFetcher:(GDataHTTPFetcher *)fetcher failedWithStatus:(int)status data:(NSData *)data;
//  - (void)myFetcher:(GDataHTTPFetcher *)fetcher failedWithNetworkError:(NSError *)error;
//
// NOTE:  Fetches may retrieve data from the server even though the server 
//        returned an error.  The failWithStatus selector is called when the server
//        status is >= 300 (along with any server-supplied data, usually
//        some html explaining the error), but if the failWithStatus selector is nil,
//        then the didFinish selector is called with the server-supplied data.
//        Status codes are at <http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html>
//
// 
// Proxies:
//
// Proxy handling is invisible so long as the system has a valid credential
// in the keychain, which is normally true (else most NSURL-based apps would
// have difficulty.)  But when there is a proxy authetication error, the 
// the fetcher will call the failedWithNetworkError: method with the
// NSURLChallenge in the error's userInfo. The error method can get the 
// challenge info like this:
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
// By default, GDataHTTPFetcher uses a mutable array held statically to
// track cookies for all instantiated fetchers. This avoids server cookies being
// set by servers for the application from interfering with Safari cookie
// settings, and vice versa.  The fetcher cookies are lost when the application quits.
//
// To rely instead on WebKit's global NSHTTPCookieStorage, call 
// setCookieStorageMethod: with kGDataHTTPFetcherCookieStorageMethodSystemDefault.
//
// If you use provide a fetch history (such as for periodic checks, described
// below) then the cookie storage mechanism is set to use the fetch
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
// To get this behavior, provide a persistent mutable dictionary to setFetchHistory:, 
// and look for the failedWithStatus: callback with code 304
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
// The optional received data selector should have the signature
//
//  - (void)myFetcher:(GDataHTTPFetcher *)fetcher receivedData:(NSData *)dataReceivedSoFar;
//
// The bytes received so far are [dataReceivedSoFar length]. This number may go down
//    if a redirect causes the download to begin again from a new server.
// If supplied by the server, the anticipated total download size is available as
//    [[myFetcher response] expectedContentLength] (may be -1 for unknown 
//    download sizes.)


#pragma once

#import <Cocoa/Cocoa.h>

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
_EXTERN NSString* kGDataHTTPFetcherErrorDomain _INITIALIZE_AS(@"com.google.GDataHTTPFetcher");
_EXTERN NSString* kGDataHTTPFetcherErrorChallengeKey _INITIALIZE_AS(@"challenge");


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

/// async retrieval of an http get or post
@interface GDataHTTPFetcher : NSObject {
  NSMutableURLRequest *request_;
  NSURLConnection *connection_;    // while connection_ is non-nil, delegate_ is retained
  NSMutableData *downloadedData_;
  NSURLCredential *credential_;     // username & password
  NSURLCredential *proxyCredential_; // credential supplied to proxy servers
  NSData *postData_;
  NSInputStream *postStream_;
  NSURLResponse *response_;         // set in connection:didReceiveResponse:
  id delegate_;                     // WEAK (though retained during an open connection)
  SEL finishedSEL_;                 // should by implemented by delegate
  SEL statusFailedSEL_;             // should by implemented by delegate
  SEL networkFailedSEL_;            // should be implemented by delegate
  SEL receivedDataSEL_;             // optional, set with setReceivedDataSelector
  id userData_;                     // retained, if set by caller
  NSMutableDictionary *fetchHistory_; // if supplied by the caller, used for Last-Modified-Since checks and cookies
  BOOL shouldCacheDatedData_;       // if true, remembers and returns data marked with a last-modified date
  int cookieStorageMethod_;         // constant from above
}

/// create a fetcher
//
/// httpFetcherWithRequest will return an autoreleased fetcher, but if
/// the connection is successfully created, the connection should retain the
/// fetcher for the life of the connection as well. So the caller doesn't have
/// to retain the fetcher explicitly unless they want to be able to cancel it.
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

/// Begin fetching the request.  
//
/// |delegate| can optionally implement the 
/// three selectors |finishedSEL|, |statusFailedSEL| and |networkFailedSEL| 
/// or pass nil for them.  
/// Returns YES if the fetch is initiated.  Delegate is retained between
/// the beginFetch call until after the finish/fail callbacks.
/// |statusFailedSEL| is called if the server returns status >= 300
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

/// Cancel the fetch of the request that's currently in progress
- (void)stopFetching;

/// return the status code from the server response
- (int)statusCode;

/// the response, once it's been received
- (NSURLResponse *)response;
- (void)setResponse:(NSURLResponse *)response;

/// if the caller supplies a mutable dictionary, it's used for Last-Modified-Since
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

/// userData is retained for the convenience of the caller
- (id)userData;
- (void)setUserData:(id)theObj;

@end
