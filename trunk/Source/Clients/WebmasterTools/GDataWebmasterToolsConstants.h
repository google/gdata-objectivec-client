/* Copyright (c) 2009 Google Inc.
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
//  GDataWebmasterToolsConstants.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE

#import <Foundation/Foundation.h>

#import "GDataDefines.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAWEBMASTERTOOLS_DEFINE_GLOBALS
#define _EXTERN
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN GDATA_EXTERN
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataWebmasterToolsServiceV2 _INITIALIZE_AS(@"2.0");
_EXTERN NSString* const kGDataWebmasterToolsDefaultServiceVersion _INITIALIZE_AS(@"2.0");

_EXTERN NSString* const kGDataNamespaceWebmasterTools       _INITIALIZE_AS(@"http://schemas.google.com/webmasters/tools/2007");
_EXTERN NSString* const kGDataNamespaceWebmasterToolsPrefix _INITIALIZE_AS(@"wt");

_EXTERN NSString* const kGDataCategorySiteInfo         _INITIALIZE_AS(@"http://schemas.google.com/webmasters/tools/2007#site-info");
_EXTERN NSString* const kGDataCategorySitesFeed        _INITIALIZE_AS(@"http://schemas.google.com/webmasters/tools/2007#sites-feed");
_EXTERN NSString* const kGDataCategorySitemapsFeed     _INITIALIZE_AS(@"http://schemas.google.com/webmasters/tools/2007#sitemaps-feed");
_EXTERN NSString* const kGDataCategorySitemapRegular   _INITIALIZE_AS(@"http://schemas.google.com/webmasters/tools/2007#sitemap-regular");
_EXTERN NSString* const kGDataCategorySitemapMobile    _INITIALIZE_AS(@"http://schemas.google.com/webmasters/tools/2007#sitemap-mobile");
_EXTERN NSString* const kGDataCategorySitemapNews      _INITIALIZE_AS(@"http://schemas.google.com/webmasters/tools/2007#sitemap-news");
_EXTERN NSString* const kGDataCategorySiteMessage      _INITIALIZE_AS(@"http://schemas.google.com/webmasters/tools/2007#message");
_EXTERN NSString* const kGDataCategorySiteMessagesFeed _INITIALIZE_AS(@"http://schemas.google.com/webmasters/tools/2007#messages-feed");
_EXTERN NSString* const kGDataCategorySiteKeyword      _INITIALIZE_AS(@"http://schemas.google.com/webmasters/tools/2007#keyword_entry");
_EXTERN NSString* const kGDataCategorySiteCrawlIssue   _INITIALIZE_AS(@"http://schemas.google.com/webmasters/tools/2007#crawl_issue_entry");

_EXTERN NSString* const kGDataSiteVerificationRel    _INITIALIZE_AS(@"http://schemas.google.com/webmasters/tools/2007#verification");
_EXTERN NSString* const kGDataSiteSitemapsRel        _INITIALIZE_AS(@"http://schemas.google.com/webmasters/tools/2007#sitemaps");

_EXTERN NSString* const kGDataSiteCrawlRateSlowest                  _INITIALIZE_AS(@"slowest");
_EXTERN NSString* const kGDataSiteCrawlRateSlower                   _INITIALIZE_AS(@"slowest");
_EXTERN NSString* const kGDataSiteCrawlRateNormal                   _INITIALIZE_AS(@"normal");
_EXTERN NSString* const kGDataSiteCrawlRateFaster                   _INITIALIZE_AS(@"faster");
_EXTERN NSString* const kGDataSiteCrawlRateFastest                  _INITIALIZE_AS(@"fastest");

_EXTERN NSString* const kGDataSiteCrawlPreferredDomainNone          _INITIALIZE_AS(@"none");
_EXTERN NSString* const kGDataSiteCrawlPreferredDomainWWW           _INITIALIZE_AS(@"preferwww");
_EXTERN NSString* const kGDataSiteCrawlPreferredDomainNoWWW         _INITIALIZE_AS(@"prefernowww");

_EXTERN NSString* const kGDataSiteKeywordInternal                   _INITIALIZE_AS(@"internal");
_EXTERN NSString* const kGDataSiteKeywordExternal                   _INITIALIZE_AS(@"external");

_EXTERN NSString* const kGDataSiteCrawlTypeMobileCHTML              _INITIALIZE_AS(@"mobile-cHTML-crawl");
_EXTERN NSString* const kGDataSiteCrawlTypeMobileXHTMLWML           _INITIALIZE_AS(@"mobile-XHTML-WML-crawl");
_EXTERN NSString* const kGDataSiteCrawlTypeNews                     _INITIALIZE_AS(@"news-crawl");
_EXTERN NSString* const kGDataSiteCrawlTypeWeb                      _INITIALIZE_AS(@"web-crawl");

_EXTERN NSString* const kGDataSiteCrawlIssueTypeHTTPError           _INITIALIZE_AS(@"http-error");
_EXTERN NSString* const kGDataSiteCrawlIssueTypeInSitemap           _INITIALIZE_AS(@"in-sitemap");
_EXTERN NSString* const kGDataSiteCrawlIssueTypeNewsError           _INITIALIZE_AS(@"news-error");
_EXTERN NSString* const kGDataSiteCrawlIssueTypeNotFollowed         _INITIALIZE_AS(@"not-followed");
_EXTERN NSString* const kGDataSiteCrawlIssueTypeNotFound            _INITIALIZE_AS(@"not-found");
_EXTERN NSString* const kGDataSiteCrawlIssueTypeRestrictedRobotsTxt _INITIALIZE_AS(@"restricted-robots-txt");
_EXTERN NSString* const kGDataSiteCrawlIssueTypeTimedOut            _INITIALIZE_AS(@"timed-out");
_EXTERN NSString* const kGDataSiteCrawlIssueTypeUnreachable         _INITIALIZE_AS(@"unreachable");

@interface GDataWebmasterToolsConstants : NSObject
+ (NSDictionary *)webmasterToolsNamespaces;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE
