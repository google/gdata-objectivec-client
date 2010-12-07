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
//  GDataEntrySitemap.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE

#import "GDataEntryBase.h"

@interface GDataSitemapStatus : GDataValueElementConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataSitemapLastDownloaded : GDataValueElementConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataSitemapURLCount : GDataValueElementConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataSitemapType : GDataValueElementConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataSitemapMobileMarkupLanguage : GDataValueElementConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataSitemapNewsPublicationLabel : GDataValueElementConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataEntrySitemapBase : GDataEntryBase {
}

+ (id)sitemapEntry;

// extensions
- (NSString *)sitemapStatus;
- (void)setSitemapStatus:(NSString *)str;

- (GDataDateTime *)lastDownloadDate;
- (void)setLastDownloadDate:(GDataDateTime *)dateTime;

- (NSNumber *)sitemapURLCount;
- (void)setSitemapURLCount:(NSNumber *)num;

@end

@interface GDataEntrySitemapRegular : GDataEntrySitemapBase
- (NSString *)sitemapType;
- (void)setSitemapType:(NSString *)str;
@end

@interface GDataEntrySitemapMobile : GDataEntrySitemapBase
- (NSString *)markupLanguage;
- (void)setMarkupLanguage:(NSString *)str;
@end

@interface GDataEntrySitemapNews : GDataEntrySitemapBase
- (NSString *)publicationLabel;
- (void)setPublicationLabel:(NSString *)str;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE
