/* Copyright (c) 2008 Google Inc.
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
//  GDataServiceGoogleContact.h
//

#import "GDataServiceGoogle.h"
#import "GDataEntryContact.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATASERVICEGOOGLECONTACT_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

// GDataXML contacts for the authenticated user
//
// Full feeds include all extendedProperties, which must be preserved
// when updating entries; thin feeds include no extendedProperties.
//
// For a feed that includes only extendedProperties with a specific
// property name, use contactFeedURLForPropertyName:
// or contactGroupFeedURLForPropertyName:
//
// Google Contacts limits contacts to one extended property per property
// name.  Requesting a feed for a specific property name avoids the need
// to preserve other applications' property names when updating entries.

// AllContacts includes actual and suggested contacts
// Groups is for group feeds
_EXTERN NSString* const kGDataGoogleContactAllContactsFeedName _INITIALIZE_AS(@"contacts");
_EXTERN NSString* const kGDataGoogleContactGroupsFeedName      _INITIALIZE_AS(@"groups");

// Projections - full (include all extended properties) or thin (exclude
//               extended properties)
_EXTERN NSString* const kGDataGoogleContactFullProjection _INITIALIZE_AS(@"full");
_EXTERN NSString* const kGDataGoogleContactThinProjection _INITIALIZE_AS(@"thin");

_EXTERN NSString* kGDataGoogleContactDefaultThinFeed _INITIALIZE_AS(@"http://www.google.com/m8/feeds/contacts/default/thin");
_EXTERN NSString* kGDataGoogleContactDefaultFullFeed _INITIALIZE_AS(@"http://www.google.com/m8/feeds/contacts/default/full");

_EXTERN NSString* kGDataGoogleContactGroupDefaultThinFeed _INITIALIZE_AS(@"http://www.google.com/m8/feeds/groups/default/thin");
_EXTERN NSString* kGDataGoogleContactGroupDefaultFullFeed _INITIALIZE_AS(@"http://www.google.com/m8/feeds/groups/default/full");

@class GDataQueryContact;

// These routines are all simple wrappers around GDataServiceGoogle methods.

@interface GDataServiceGoogleContact : GDataServiceGoogle 

+ (NSURL *)contactURLForFeedName:(NSString *)feedName
                          userID:(NSString *)userID
                      projection:(NSString *)projection;

// convenience URL generators for contacts feed
//
// Use kGDataServiceDefaultUser as the username to specify the authenticated
// user

+ (NSURL *)contactFeedURLForUserID:(NSString *)userID;
+ (NSURL *)groupFeedURLForUserID:(NSString *)userID;

+ (NSURL *)contactFeedURLForUserID:(NSString *)userID
                        projection:(NSString *)projection;

+ (NSURL *)contactFeedURLForPropertyName:(NSString *)property;
+ (NSURL *)contactGroupFeedURLForPropertyName:(NSString *)property;

- (GDataServiceTicket *)fetchContactFeedForUsername:(NSString *)username
                                           delegate:(id)delegate
                                  didFinishSelector:(SEL)finishedSelector
                                    didFailSelector:(SEL)failedSelector;

- (GDataServiceTicket *)fetchContactFeedWithURL:(NSURL *)feedURL
                                       delegate:(id)delegate
                              didFinishSelector:(SEL)finishedSelector
                                didFailSelector:(SEL)failedSelector;


- (GDataServiceTicket *)fetchContactEntryWithURL:(NSURL *)entryURL
                                        delegate:(id)delegate
                               didFinishSelector:(SEL)finishedSelector
                                 didFailSelector:(SEL)failedSelector;

// entry may be GDataContactEntry or GDataContactGroupEntry
- (GDataServiceTicket *)fetchContactEntryByInsertingEntry:(id)entryToInsert
                                               forFeedURL:(NSURL *)contactFeedURL
                                                 delegate:(id)delegate
                                        didFinishSelector:(SEL)finishedSelector
                                          didFailSelector:(SEL)failedSelector;

- (GDataServiceTicket *)fetchContactEntryByUpdatingEntry:(id)entryToUpdate
                                             forEntryURL:(NSURL *)contactEntryEditURL
                                                delegate:(id)delegate
                                       didFinishSelector:(SEL)finishedSelector
                                         didFailSelector:(SEL)failedSelector;

- (GDataServiceTicket *)fetchContactQuery:(GDataQueryContact *)query
                                 delegate:(id)delegate
                        didFinishSelector:(SEL)finishedSelector
                          didFailSelector:(SEL)failedSelector;

- (GDataServiceTicket *)deleteContactEntry:(id)entryToDelete
                                  delegate:(id)delegate
                         didFinishSelector:(SEL)finishedSelector
                           didFailSelector:(SEL)failedSelector;

- (GDataServiceTicket *)deleteContactResourceURL:(NSURL *)resourceEditURL
                                            ETag:(NSString *)etag
                                        delegate:(id)delegate
                               didFinishSelector:(SEL)finishedSelector
                                 didFailSelector:(SEL)failedSelector;

- (GDataServiceTicket *)fetchContactBatchFeedWithBatchFeed:(GDataFeedBase *)batchFeed
                                           forBatchFeedURL:(NSURL *)feedURL
                                                  delegate:(id)delegate
                                         didFinishSelector:(SEL)finishedSelector
                                           didFailSelector:(SEL)failedSelector;
+ (NSString *)serviceRootURLString;

@end
