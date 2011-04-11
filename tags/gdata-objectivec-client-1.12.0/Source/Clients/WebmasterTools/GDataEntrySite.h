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

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE

//
//  GDataEntrySite.h
//

#import "GDataEntryBase.h"
#import "GDataSiteVerificationMethod.h"
#import "GDataEntryLink.h"

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

- (NSString *)geoLocation;
- (void)setGeoLocation:(NSString *)str;

- (NSString *)crawlRate;
- (void)setCrawlRate:(NSString *)str;

- (NSString *)preferredDomain;
- (void)setPreferredDomain:(NSString *)str;

- (BOOL)hasEnhancedImageSearch;
- (void)setHasEnhancedImageSearch:(BOOL)flag;

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

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE
