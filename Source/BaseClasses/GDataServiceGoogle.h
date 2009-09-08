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

_EXTERN NSString* const kGDataServiceErrorCaptchaRequired _INITIALIZE_AS(@"CaptchaRequired");

// The default user is the authenticated user
//
// In the projections of many feeds, the username can be replaced with "default"
// to indicate the feed should be for the authenticate user's account
_EXTERN NSString* const kGDataServiceDefaultUser _INITIALIZE_AS(@"default");

// The Auth token is stored in the response dict under this key.
_EXTERN NSString* const kGDataServiceAuthTokenKey _INITIALIZE_AS(@"Auth");

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
  NSString *authSubToken_;

  NSString *accountType_; // hosted or google

  NSString *signInDomain_;

  NSString *serviceID_; // typically supplied by the subclass overriding -serviceID

  BOOL shouldUseMethodOverrideHeader_;
}

// fetch a feed, authenticated
//
// when the class of the returned feed or entry is not specified, it
// must be inferable from the XML (by "kind" category elements present
// in the feed or entry)

- (GDataServiceTicket *)fetchFeedWithURL:(NSURL *)feedURL
                                delegate:(id)delegate
                       didFinishSelector:(SEL)finishedSelector;

- (GDataServiceTicket *)fetchFeedWithURL:(NSURL *)feedURL
                               feedClass:(Class)feedClass
                                delegate:(id)delegate
                       didFinishSelector:(SEL)finishedSelector;

// fetch a query, authenticated
- (GDataServiceTicket *)fetchFeedWithQuery:(GDataQuery *)query
                                  delegate:(id)delegate
                         didFinishSelector:(SEL)finishedSelector;

- (GDataServiceTicket *)fetchFeedWithQuery:(GDataQuery *)query
                                 feedClass:(Class)feedClass
                                  delegate:(id)delegate
                         didFinishSelector:(SEL)finishedSelector;

// fetch an entry, authenticated
- (GDataServiceTicket *)fetchEntryWithURL:(NSURL *)entryURL
                                 delegate:(id)delegate
                        didFinishSelector:(SEL)finishedSelector;

- (GDataServiceTicket *)fetchEntryWithURL:(NSURL *)entryURL
                               entryClass:(Class)entryClass
                                 delegate:(id)delegate
                        didFinishSelector:(SEL)finishedSelector;

// insert an entry, authenticated
- (GDataServiceTicket *)fetchEntryByInsertingEntry:(GDataEntryBase *)entryToInsert
                                        forFeedURL:(NSURL *)feedURL
                                          delegate:(id)delegate
                                 didFinishSelector:(SEL)finishedSelector;

// update an entry, authenticated
- (GDataServiceTicket *)fetchEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                         delegate:(id)delegate
                                didFinishSelector:(SEL)finishedSelector;

- (GDataServiceTicket *)fetchEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                      forEntryURL:(NSURL *)entryURL
                                         delegate:(id)delegate
                                didFinishSelector:(SEL)finishedSelector;

// delete an entry, authenticated
// (on success, callback will have nil object and error pointers)
- (GDataServiceTicket *)deleteEntry:(GDataEntryBase *)entryToDelete
                           delegate:(id)delegate
                  didFinishSelector:(SEL)finishedSelector;

- (GDataServiceTicket *)deleteResourceURL:(NSURL *)resourceEditURL
                                     ETag:(NSString *)etag
                                 delegate:(id)delegate
                        didFinishSelector:(SEL)finishedSelector;

// fetch a batch feed
- (GDataServiceTicket *)fetchFeedWithBatchFeed:(GDataFeedBase *)batchFeed
                               forBatchFeedURL:(NSURL *)feedURL
                                      delegate:(id)delegate
                             didFinishSelector:(SEL)finishedSelector;

// authenticate without fetching a feed or entry
//
// authSelector has a signature matching:
//   - (void)ticket:(GDataServiceTicket *)ticket authenticatedWithError:(NSError *)error;
//
// If authentication succeeds, the selector is invoked with a nil error,
// and the auth token is available as [[ticket service] authToken]
//
// The returned ticket may be ignored unless the caller wants to cancel it
- (GDataServiceTicket *)authenticateWithDelegate:(id)delegate
                         didAuthenticateSelector:(SEL)authSelector;

- (void)setCaptchaToken:(NSString *)captchaToken
          captchaAnswer:(NSString *)captchaAnswer;

- (NSString *)authToken;
- (void)setAuthToken:(NSString *)str;

- (NSString *)authSubToken;
- (void)setAuthSubToken:(NSString *)str;

// default account type is HOSTED_OR_GOOGLE
- (NSString *)accountType;
- (void)setAccountType:(NSString *)str;

// default sign-in domain is www.google.com
- (NSString *)signInDomain;
- (void)setSignInDomain:(NSString *)domain;

// when it's not possible to do http methods other than GET and POST,
// the X-HTTP-Method-Override header can be used in conjunction with POST
// for other commands.  Default for this is NO.
- (BOOL)shouldUseMethodOverrideHeader;
- (void)setShouldUseMethodOverrideHeader:(BOOL)flag;

+ (NSString *)serviceID; // implemented by subclasses, like @"cl" for calendar

- (void)setServiceID:(NSString *)str; // call only if not using a subclass
- (NSString *)serviceID;

// subclasses may specify what namespaces to attach to posted user entries
// when the entries lack explicit root-level namespaces
+ (NSDictionary *)standardServiceNamespaces;

@end
