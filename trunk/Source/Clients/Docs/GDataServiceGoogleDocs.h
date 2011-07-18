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
//  GDataServiceGoogleDocs.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE

#import "GDataServiceGoogle.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATASERVICEDOCS_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN GDATA_EXTERN
#define _INITIALIZE_AS(x)
#endif

@class GDataQueryDocs;

// constants for DocList v3 URLs
//
// use kGDataServiceDefaultUser for the currently-authenticated user
//
_EXTERN NSString* const kGDataGoogleDocsVisibilityPrivate      _INITIALIZE_AS(@"private");

_EXTERN NSString* const kGDataGoogleDocsProjectionFull         _INITIALIZE_AS(@"full");
_EXTERN NSString* const kGDataGoogleDocsProjectionExpandACL    _INITIALIZE_AS(@"expandAcl");

_EXTERN NSString* const kGDataGoogleDocsFeedTypeFolderContents _INITIALIZE_AS(@"contents");
_EXTERN NSString* const kGDataGoogleDocsFeedTypeACL            _INITIALIZE_AS(@"acl");
_EXTERN NSString* const kGDataGoogleDocsFeedTypeRevisions      _INITIALIZE_AS(@"revisions");

// DocList feed URLs for versions 1-2 (deprecated)
//  _EXTERN NSString* const kGDataGoogleDocsDefaultPrivateFullFeed _INITIALIZE_AS(@"http://docs.google.com/feeds/documents/private/full");
//  _EXTERN NSString* const kGDataGoogleDocsDefaultACLExpandedFeed _INITIALIZE_AS(@"http://docs.google.com/feeds/documents/private/expandAcl");

@interface GDataServiceGoogleDocs : GDataServiceGoogle 

//
// utilities for making feed URLs
//

+ (NSURL *)docsFeedURL;

+ (NSURL *)folderContentsFeedURLForFolderID:(NSString *)resourceID;

+ (NSURL *)docsURLForUserID:(NSString *)userID
                 visibility:(NSString *)visibility
                 projection:(NSString *)projection
                 resourceID:(NSString *)resourceID
                   feedType:(NSString *)feedType
                 revisionID:(NSString *)revisionID;

+ (NSURL *)docsUploadURL;

+ (NSURL *)metadataEntryURLForUserID:(NSString *)userID;

+ (NSURL *)changesFeedURLForUserID:(NSString *)userID;

+ (NSString *)serviceRootURLString;

// clients may use these fetch methods of GDataServiceGoogle
//
//  - (GDataServiceTicket *)fetchFeedWithURL:(NSURL *)feedURL delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//  - (GDataServiceTicket *)fetchFeedWithQuery:(GDataQuery *)query delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//  - (GDataServiceTicket *)fetchEntryWithURL:(NSURL *)entryURL delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//  - (GDataServiceTicket *)fetchEntryByInsertingEntry:(GDataEntryBase *)entryToInsert forFeedURL:(NSURL *)feedURL delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//  - (GDataServiceTicket *)fetchEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//  - (GDataServiceTicket *)deleteEntry:(GDataEntryBase *)entryToDelete delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//  - (GDataServiceTicket *)deleteResourceURL:(NSURL *)resourceEditURL ETag:(NSString *)etag delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//  - (GDataServiceTicket *)fetchFeedWithBatchFeed:(GDataFeedBase *)batchFeed forBatchFeedURL:(NSURL *)feedURL delegate:(id)delegate didFinishSelector:(SEL)finishedSelector;
//
// finishedSelector has a signature like this for feed fetches:
// - (void)serviceTicket:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedBase *)feed error:(NSError *)error;
//
// or this for entry fetches:
// - (void)serviceTicket:(GDataServiceTicket *)ticket finishedWithEntry:(GDataEntryBase *)entry error:(NSError *)error;
//
// The class of the returned feed or entry is determined by the URL fetched.

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE
