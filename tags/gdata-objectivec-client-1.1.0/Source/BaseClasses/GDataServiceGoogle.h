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
//  GDataServiceGoogle.h
//

#import <Cocoa/Cocoa.h>

#import "GDataServiceBase.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATASERVICEGOOGLE_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* kGDataServiceErrorCaptchaRequired _INITIALIZE_AS(@"CaptchaRequired");

enum {
  kGDataBadAuthentication = 403
};

@interface NSDictionary (GDataServiceGoogleAdditions) 
// category to get auth info from the callback error's userInfo
- (NSString *)authenticationError;  
- (NSString *)captchaToken;  
- (NSURL *)captchaURL;
@end

@class GDataServiceGoogle;

// GDataServiceTicket is the version of a ticket that supports
// Google authentication
@interface GDataServiceTicket : GDataServiceTicketBase {
  GDataHTTPFetcher *authFetcher_; 
}

+ (GDataServiceTicket *)authTicketForService:(GDataServiceGoogle *)service;

- (void)cancelTicket; // stops fetches in progress

- (GDataHTTPFetcher *)authFetcher;
- (void)setAuthFetcher:(GDataHTTPFetcher *)fetcher;
@end

// GDataServiceGoogle is the version of the service class that supports
// Google authentication.
@interface GDataServiceGoogle : GDataServiceBase {
  
  NSString *captchaToken_;
  NSString *captchaAnswer_;
  
  NSString *authToken_;
  
  NSString *signInDomain_;
  
  NSString *serviceID_; // typically supplied by the subclass overriding -serviceID
  
  BOOL shouldUseMethodOverrideHeader_;
}

- (GDataServiceTicket *)fetchAuthenticatedFeedWithURL:(NSURL *)feedURL
                                            feedClass:(Class)feedClass
                                             delegate:(id)delegate
                                    didFinishSelector:(SEL)finishedSelector
                                      didFailSelector:(SEL)failedSelector;

- (GDataServiceTicket *)fetchAuthenticatedEntryWithURL:(NSURL *)entryURL
                                            entryClass:(Class)entryClass
                                              delegate:(id)delegate
                                     didFinishSelector:(SEL)finishedSelector
                                       didFailSelector:(SEL)failedSelector;

- (GDataServiceTicket *)fetchAuthenticatedEntryByInsertingEntry:(GDataEntryBase *)entryToInsert
                                                     forFeedURL:(NSURL *)feedURL
                                                       delegate:(id)delegate
                                              didFinishSelector:(SEL)finishedSelector
                                                didFailSelector:(SEL)failedSelector;

- (GDataServiceTicket *)fetchAuthenticatedEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                                   forEntryURL:(NSURL *)entryURL
                                                      delegate:(id)delegate
                                             didFinishSelector:(SEL)finishedSelector
                                               didFailSelector:(SEL)failedSelector;

- (GDataServiceTicket *)deleteAuthenticatedResourceURL:(NSURL *)resourceEditURL
                                              delegate:(id)delegate
                                     didFinishSelector:(SEL)finishedSelector
                                       didFailSelector:(SEL)failedSelector;

- (GDataServiceTicket *)fetchAuthenticatedFeedWithQuery:(GDataQuery *)query
                                              feedClass:(Class)feedClass
                                               delegate:(id)delegate
                                      didFinishSelector:(SEL)finishedSelector
                                        didFailSelector:(SEL)failedSelector;  

- (GDataServiceTicket *)fetchAuthenticatedFeedWithBatchFeed:(GDataFeedBase *)batchFeed
                                            forBatchFeedURL:(NSURL *)feedURL
                                                   delegate:(id)delegate
                                          didFinishSelector:(SEL)finishedSelector
                                            didFailSelector:(SEL)failedSelector;

- (void)setCaptchaToken:(NSString *)captchaToken
          captchaAnswer:(NSString *)captchaAnswer;

// default sign-in domain is www.google.com
- (NSString *)signInDomain;
- (void)setSignInDomain:(NSString *)domain;

// when it's not possible to do http methods other than GET and POST,
// the X-HTTP-Method-Override header can be used in conjunction with POST
// for other commands.  Default for this is NO.
- (BOOL)shouldUseMethodOverrideHeader;
- (void)setShouldUseMethodOverrideHeader:(BOOL)flag;

- (void)setServiceID:(NSString *)str; // call only if not using a subclass
- (NSString *)serviceID; // implemented by subclass, like @"cl" for calendar

  // internal utilities
+ (NSDictionary *)dictionaryWithResponseString:(NSString *)responseString;

@end
