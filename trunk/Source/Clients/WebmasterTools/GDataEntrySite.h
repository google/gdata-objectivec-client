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
//  GDataEntrySite.h
//

#import "GDataEntryBase.h"


// We define constant symbols in the main entry class for the client service

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAENTRYSITE_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* kGDataNamespaceWebmasterTools       _INITIALIZE_AS(@"http://schemas.google.com/webmasters/tools/2007");
_EXTERN NSString* kGDataNamespaceWebmasterToolsPrefix _INITIALIZE_AS(@"wt");

_EXTERN NSString* kGDataCategorySiteInfo       _INITIALIZE_AS(@"http://schemas.google.com/webmasters/tools/2007#site-info");
_EXTERN NSString* kGDataCategorySitemapsFeed   _INITIALIZE_AS(@"http://schemas.google.com/webmasters/tools/2007#sitemaps-feed");
_EXTERN NSString* kGDataCategorySitemapRegular _INITIALIZE_AS(@"http://schemas.google.com/webmasters/tools/2007#sitemap-regular");
_EXTERN NSString* kGDataCategorySitemapMobile  _INITIALIZE_AS(@"http://schemas.google.com/webmasters/tools/2007#sitemap-mobile");
_EXTERN NSString* kGDataCategorySitemapNews    _INITIALIZE_AS(@"http://schemas.google.com/webmasters/tools/2007#sitemap-news");

_EXTERN NSString* kGDataSiteVerificationRel    _INITIALIZE_AS(@"http://schemas.google.com/webmasters/tools/2007#verification");
_EXTERN NSString* kGDataSiteSitemapsRel        _INITIALIZE_AS(@"http://schemas.google.com/webmasters/tools/2007#sitemaps");

@interface GDataSiteCrawledDate : GDataValueElementConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataSiteVerified : GDataValueElementConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataSiteIndexed : GDataValueElementConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@class GDataSiteVerificationMethod;
@class GDataEntryLink;

@interface GDataEntrySite : GDataEntryBase

+ (NSDictionary *)webmasterToolsNamespaces;

+ (GDataEntrySite *)siteEntry;

// extensions
- (BOOL)isIndexed;
- (void)setIsIndexed:(BOOL)flag;

- (GDataDateTime *)crawledDate;
- (void)setCrawledDate:(GDataDateTime *)dateTime;

- (BOOL)isVerified;
- (void)setIsVerified:(BOOL)flag;

- (NSArray *)verificationMethods;
- (void)setVerificationMethods:(NSArray *)array;
- (void)addVerificationMethod:(GDataSiteVerificationMethod *)obj;

- (NSArray *)entryLinks;
- (void)setEntryLinks:(NSArray *)arr;
- (void)addEntryLink:(GDataEntryLink *)obj;

// convenience accessors

- (GDataSiteVerificationMethod *)verificationMethodInUse;

- (GDataEntryLink *)verificationEntryLink;
- (GDataEntryLink *)sitemapsEntryLink;
@end
