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
//  GDataEntrySitemap.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE

#import "GDataEntrySitemap.h"
#import "GDataWebmasterToolsConstants.h"

@implementation GDataSitemapStatus
+ (NSString *)extensionElementURI       { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementLocalName { return @"sitemap-status"; }
@end

@implementation GDataSitemapLastDownloaded
+ (NSString *)extensionElementURI       { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementLocalName { return @"sitemap-last-downloaded"; }
@end

@implementation GDataSitemapURLCount
+ (NSString *)extensionElementURI       { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementLocalName { return @"sitemap-url-count"; }
@end

@implementation GDataSitemapType
+ (NSString *)extensionElementURI       { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementLocalName { return @"sitemap-type"; }
@end

@implementation GDataSitemapMobileMarkupLanguage
+ (NSString *)extensionElementURI       { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementLocalName { return @"sitemap-mobile-markup-language"; }
@end

@implementation GDataSitemapNewsPublicationLabel
+ (NSString *)extensionElementPrefix { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementURI { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementLocalName { return @"sitemap-news-publication-label"; }
@end

@implementation GDataEntrySitemapBase

+ (id)sitemapEntry {
  
  GDataEntrySitemapBase *obj;
  obj = [[[self alloc] init] autorelease];
  
  [obj setNamespaces:[GDataWebmasterToolsConstants webmasterToolsNamespaces]];
  
  return obj;
}

#pragma mark -


- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];
  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataSitemapStatus class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataSitemapLastDownloaded class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataSitemapURLCount class]];  
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  [self addToArray:items objectDescriptionIfNonNil:[self sitemapStatus] withName:@"status"];
  [self addToArray:items objectDescriptionIfNonNil:[self lastDownloadDate] withName:@"lastDownload"];
  [self addToArray:items objectDescriptionIfNonNil:[self sitemapURLCount] withName:@"URLCount"];

  return items;
}
#endif

+ (NSString *)defaultServiceVersion {
  return kGDataWebmasterToolsDefaultServiceVersion;
}

#pragma mark -

- (NSString *)sitemapStatus {
  GDataSitemapStatus *obj;
  
  obj = [self objectForExtensionClass:[GDataSitemapStatus class]];
  return [obj stringValue];
}

- (void)setSitemapStatus:(NSString *)str {
  GDataSitemapStatus *obj = [GDataSitemapStatus valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataSitemapStatus class]]; 
}

- (GDataDateTime *)lastDownloadDate {
  GDataSitemapLastDownloaded *obj;
  
  obj = [self objectForExtensionClass:[GDataSitemapLastDownloaded class]]; 
  return [obj dateTimeValue]; 
}

- (void)setLastDownloadDate:(GDataDateTime *)dateTime {
  GDataSitemapLastDownloaded *obj;
  
  obj = [GDataSitemapLastDownloaded valueWithDateTime:dateTime];
  [self setObject:obj forExtensionClass:[GDataSitemapLastDownloaded class]];
}

- (NSNumber *)sitemapURLCount {
  GDataSitemapURLCount *obj;
  
  obj = [self objectForExtensionClass:[GDataSitemapURLCount class]];
  return [obj intNumberValue];
}

- (void)setSitemapURLCount:(NSNumber *)num {
  GDataSitemapURLCount *obj = nil;
  
  if (num != nil) {
    obj = [GDataSitemapURLCount valueWithNumber:num];
  }
  [self setObject:obj forExtensionClass:[GDataSitemapURLCount class]];
}

@end

@implementation GDataEntrySitemapRegular

+ (NSString *)standardEntryKind {
  return kGDataCategorySitemapRegular;
}

+ (void)load {
  [self registerEntryClass];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  [self addToArray:items objectDescriptionIfNonNil:[self sitemapType] withName:@"sitemapType"];
  
  return items;
}
#endif

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataSitemapType class]];  
}

#pragma mark -

- (NSString *)sitemapType {
  GDataSitemapType *obj;
  
  obj = [self objectForExtensionClass:[GDataSitemapType class]];
  return [obj stringValue];
}

- (void)setSitemapType:(NSString *)str {
  GDataSitemapType *obj = nil;
  
  if (str != nil) {
    obj = [GDataSitemapType valueWithString:str];
  }
  [self setObject:obj forExtensionClass:[GDataSitemapType class]]; 
}

@end

@implementation GDataEntrySitemapMobile

+ (NSString *)standardEntryKind {
  return kGDataCategorySitemapMobile;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataSitemapMobileMarkupLanguage class]];  
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  [self addToArray:items objectDescriptionIfNonNil:[self markupLanguage] withName:@"markupLang"];

  return items;
}
#endif

#pragma mark -

- (NSString *)markupLanguage {
  GDataSitemapMobileMarkupLanguage *obj;
  
  obj = [self objectForExtensionClass:[GDataSitemapMobileMarkupLanguage class]];
  return [obj stringValue];
}

- (void)setMarkupLanguage:(NSString *)str {
  GDataSitemapMobileMarkupLanguage *obj = nil;
  
  if (str != nil) {
    obj = [GDataSitemapMobileMarkupLanguage valueWithString:str];
  }
  [self setObject:obj forExtensionClass:[GDataSitemapMobileMarkupLanguage class]]; 
}

@end

@implementation GDataEntrySitemapNews

+ (NSString *)standardEntryKind {
  return kGDataCategorySitemapNews;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataSitemapNewsPublicationLabel class]];  
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  [self addToArray:items objectDescriptionIfNonNil:[self publicationLabel] withName:@"pubLabel"];
  
  return items;
}
#endif

#pragma mark -

- (NSString *)publicationLabel {
  GDataSitemapNewsPublicationLabel *obj;
  
  obj = [self objectForExtensionClass:[GDataSitemapNewsPublicationLabel class]];
  return [obj stringValue];
}

- (void)setPublicationLabel:(NSString *)str {
  GDataSitemapNewsPublicationLabel *obj = nil;
  
  if (str != nil) {
    obj = [GDataSitemapNewsPublicationLabel valueWithString:str];
  }
  [self setObject:obj forExtensionClass:[GDataSitemapNewsPublicationLabel class]]; 
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE
