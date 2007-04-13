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
//  GDataServiceBase.h
//

#import <Cocoa/Cocoa.h>

#import "GDataHTTPFetcher.h"
#import "GDataEntryBase.h"
#import "GDataFeedBase.h"
#import "GDataQuery.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATASERVICEBASE_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN Class kGDataUseRegisteredClass _INITIALIZE_AS(nil);

_EXTERN NSString* kGDataServiceErrorDomain _INITIALIZE_AS(@"com.google.GDataServiceDomain");

enum {
 kGDataCouldNotConstructObjectError = -100 
};

@class GDataServiceBase;

@interface GDataServiceTicketBase : NSObject {
  GDataServiceBase *service_;
  id userData_;
  GDataHTTPFetcher *objectFetcher_;
  BOOL hasCalledCallback_;
}

+ (GDataServiceTicketBase *)ticketForService:(GDataServiceBase *)service;

- (id)initWithService:(GDataServiceBase *)service;

// if cancelTicket is called, the fetch is stopped if it is in progress,
// the callbacks will not be called, and the ticket will no longer be useful
// (though the client must still release the ticket if it retained the ticket)
- (void)cancelTicket;

- (GDataServiceBase *)service;

- (id)userData;
- (void)setUserData:(id)obj;

- (GDataHTTPFetcher *)objectFetcher;
- (void)setObjectFetcher:(GDataHTTPFetcher *)fetcher;

- (BOOL)hasCalledCallback;
- (void)setHasCalledCallback:(BOOL)flag;

- (int)statusCode;  // server status from object fetch
@end

@interface GDataServiceBase : NSObject {
  NSString *userAgent_;
  NSMutableDictionary *fetchHistory_;
  
  NSString *username_;
  NSMutableData *password_;
  
  NSString *serviceUserData_; // initial value for userData in future tickets
  
  BOOL shouldCacheDatedData_;
}

- (NSString *)userAgent;
- (void)setUserAgent:(NSString *)userAgent;

// in request, pass nil (for default GET method), POST, PUT, DELETE (though
// PUT and DELETE may be blocked by firewalls.)
- (NSMutableURLRequest *)requestForURL:(NSURL *)url httpMethod:(NSString *)httpMethod;

// finishedSelector has signature like:
//   serviceTicket:(GDataServiceTicketBase *)ticket finishedWithObject:(GDataObject *)object;
// failedSelector has signature like:
//   serviceTicket:(GDataServiceTicketBase *)ticket failedWithError:(NSError *)error

- (GDataServiceTicketBase *)fetchFeedWithURL:(NSURL *)feedURL
                                   feedClass:(Class)feedClass
                                    delegate:(id)delegate
                           didFinishSelector:(SEL)finishedSelector
                             didFailSelector:(SEL)failedSelector;

- (GDataServiceTicketBase *)fetchEntryWithURL:(NSURL *)entryURL
                                   entryClass:(Class)entryClass
                                     delegate:(id)delegate
                            didFinishSelector:(SEL)finishedSelector
                              didFailSelector:(SEL)failedSelector;

- (GDataServiceTicketBase *)fetchEntryByInsertingEntry:(GDataEntryBase *)entryToInsert
                                            forFeedURL:(NSURL *)feedURL
                                              delegate:(id)delegate
                                     didFinishSelector:(SEL)finishedSelector
                                       didFailSelector:(SEL)failedSelector;

- (GDataServiceTicketBase *)fetchEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                          forEntryURL:(NSURL *)entryURL
                                             delegate:(id)delegate
                                    didFinishSelector:(SEL)finishedSelector
                                      didFailSelector:(SEL)failedSelector;

- (GDataServiceTicketBase *)deleteResourceURL:(NSURL *)resourceEditURL
                                     delegate:(id)delegate
                            didFinishSelector:(SEL)finishedSelector // object parameter will be nil
                              didFailSelector:(SEL)failedSelector;

- (GDataServiceTicketBase *)fetchQuery:(GDataQuery *)query
                             feedClass:(Class)feedClass
                              delegate:(id)delegate
                     didFinishSelector:(SEL)finishedSelector
                       didFailSelector:(SEL)failedSelector;

- (GDataServiceTicketBase *)fetchFeedWithBatchFeed:(GDataFeedBase *)batchFeed
                                        forFeedURL:(NSURL *)feedURL
                                          delegate:(id)delegate
                                 didFinishSelector:(SEL)finishedSelector
                                   didFailSelector:(SEL)failedSelector;

  // Turn on data caching to receive a copy of previously-retrieved objects.
// Otherwise, fetches may return status 304 (No Change) rather than actual data
- (void)setShouldCacheDatedData:(BOOL)flag;
- (BOOL)shouldCacheDatedData;  

// The service userData becomes the initial value for each future ticket's
// userData.
//
// Since the network transactions may begin before the client has been 
// returned the ticket by the fetch call, it's preferable to call 
// setServiceUserData before the ticket is created rather than call the
// ticket's setUserData:.  Either way, the ticket's userData:
// method will return the value.
- (void)setServiceUserData:(id)userData;
- (id)serviceUserData;

// credentials
- (void)setUserCredentialsWithUsername:(NSString *)username
                              password:(NSString *)password;
- (NSString *)username;
- (NSString *)password;

// internal utilities
- (NSString *)stringByURLEncoding:(NSString *)param;

- (void)addAuthenticationToFetcher:(GDataHTTPFetcher *)fetcher;

- (void)objectFetcher:(GDataHTTPFetcher *)fetcher failedWithStatus:(int)status data:(NSData *)data;

- (NSString *)defaultApplicationIdentifier;

@end

