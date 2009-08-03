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
//  GDataEntrySite.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE

#import "GDataEntrySite.h"
#import "GDataWebmasterToolsConstants.h"

@interface GDataSiteCrawledDate : GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataSiteCrawledDate
+ (NSString *)extensionElementURI       { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementLocalName { return @"crawled"; }
@end

@interface GDataSiteVerified : GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataSiteVerified
+ (NSString *)extensionElementURI       { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementLocalName { return @"verified"; }
@end

@interface GDataSiteIndexed : GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataSiteIndexed
+ (NSString *)extensionElementURI       { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementLocalName { return @"indexed"; }
@end

@interface GDataSiteGeoLocation : GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataSiteGeoLocation
+ (NSString *)extensionElementURI       { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementLocalName { return @"geolocation"; }
@end

@interface GDataSiteCrawlRate : GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataSiteCrawlRate
+ (NSString *)extensionElementURI       { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementLocalName { return @"crawl-rate"; }
@end

@interface GDataSitePreferredDomain : GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataSitePreferredDomain
+ (NSString *)extensionElementURI       { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementLocalName { return @"preferred-domain"; }
@end

@interface GDataSiteEnhancedImageSearch : GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataSiteEnhancedImageSearch
+ (NSString *)extensionElementURI       { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementLocalName { return @"enhanced-image-search"; }
@end


@implementation GDataEntrySite

+ (NSDictionary *)webmasterToolsNamespaces {

  NSMutableDictionary *namespaces;

  namespaces = [NSMutableDictionary dictionaryWithObject:kGDataNamespaceWebmasterTools
                                                  forKey:kGDataNamespaceWebmasterToolsPrefix];

  [namespaces addEntriesFromDictionary:[GDataEntryBase baseGDataNamespaces]];

  return namespaces;
}

+ (GDataEntrySite *)siteEntry {

  GDataEntrySite *obj;
  obj = [[[GDataEntrySite alloc] init] autorelease];

  [obj setNamespaces:[GDataWebmasterToolsConstants webmasterToolsNamespaces]];

  return obj;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategorySiteInfo;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  Class entryClass = [self class];

  [self addExtensionDeclarationForParentClass:entryClass
                                 childClasses:
   [GDataSiteCrawledDate class],
   [GDataSiteVerified class],
   [GDataSiteIndexed class],
   [GDataSiteGeoLocation class],
   [GDataSiteCrawlRate class],
   [GDataSitePreferredDomain class],
   [GDataSiteEnhancedImageSearch class],
   [GDataEntryLink class],
   [GDataSiteVerificationMethod class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"entryLinks",          @"entryLinks",             kGDataDescArrayCount     },
    { @"indexed",             @"isIndexed",              kGDataDescBooleanLabeled },
    { @"crawled",             @"crawledDate",            kGDataDescValueLabeled   },
    { @"geolocation",         @"geoLocation",            kGDataDescValueLabeled   },
    { @"crawlRate",           @"crawlRate",              kGDataDescValueLabeled   },
    { @"preferredDomain",     @"preferredDomain",        kGDataDescValueLabeled   },
    { @"verified",            @"isVerified",             kGDataDescBooleanLabeled },
    { @"enhancedImageSearch", @"hasEnhancedImageSearch", kGDataDescBooleanLabeled },
    { @"methods",             @"verificationMethods",    kGDataDescArrayDescs     },
    { nil, nil, 0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

+ (NSString *)defaultServiceVersion {
  return kGDataWebmasterToolsDefaultServiceVersion;
}

#pragma mark -

- (BOOL)isIndexed {
  id obj = [self objectForExtensionClass:[GDataSiteIndexed class]];
  return [obj boolValue];
}

- (void)setIsIndexed:(BOOL)flag {
  GDataSiteIndexed *obj = [GDataSiteIndexed valueWithBool:flag];
  [self setObject:obj forExtensionClass:[GDataSiteIndexed class]];
}

- (GDataDateTime *)crawledDate {
  id obj = [self objectForExtensionClass:[GDataSiteCrawledDate class]];
  return [obj dateTimeValue];
}

- (void)setCrawledDate:(GDataDateTime *)dateTime {
  GDataSiteCrawledDate *obj = [GDataSiteCrawledDate valueWithDateTime:dateTime];
  [self setObject:obj forExtensionClass:[GDataSiteCrawledDate class]];
}

- (BOOL)isVerified {
  id obj = [self objectForExtensionClass:[GDataSiteVerified class]];
  return [obj boolValue];
}

- (void)setIsVerified:(BOOL)flag {
  GDataSiteVerified *obj = [GDataSiteVerified valueWithBool:flag];
  [self setObject:obj forExtensionClass:[GDataSiteVerified class]];
}

- (NSString *)geoLocation {
  GDataSiteGeoLocation *obj;

  obj = [self objectForExtensionClass:[GDataSiteGeoLocation class]];
  return [obj stringValue];
}

- (void)setGeoLocation:(NSString *)str {
  GDataSiteGeoLocation *obj;

  obj = [GDataSiteGeoLocation valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataSiteGeoLocation class]];
}

- (NSString *)crawlRate {
  GDataSiteCrawlRate *obj;

  obj = [self objectForExtensionClass:[GDataSiteCrawlRate class]];
  return [obj stringValue];
}

- (void)setCrawlRate:(NSString *)str {
  GDataSiteCrawlRate *obj = [GDataSiteCrawlRate valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataSiteCrawlRate class]];
}

- (NSString *)preferredDomain {
  GDataSitePreferredDomain *obj;

  obj = [self objectForExtensionClass:[GDataSitePreferredDomain class]];
  return [obj stringValue];
}

- (void)setPreferredDomain:(NSString *)str {
  GDataSitePreferredDomain *obj;

  obj = [GDataSitePreferredDomain valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataSitePreferredDomain class]];
}

- (BOOL)hasEnhancedImageSearch {
  id obj = [self objectForExtensionClass:[GDataSiteEnhancedImageSearch class]];
  return [obj boolValue];
}

- (void)setHasEnhancedImageSearch:(BOOL)flag {
  GDataSiteEnhancedImageSearch *obj;

  obj = [GDataSiteEnhancedImageSearch valueWithBool:flag];
  [self setObject:obj forExtensionClass:[GDataSiteEnhancedImageSearch class]];
}

- (NSArray *)verificationMethods {
  return [self objectsForExtensionClass:[GDataSiteVerificationMethod class]];
}

- (void)setVerificationMethods:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataSiteVerificationMethod class]];
}

- (void)addVerificationMethod:(GDataSiteVerificationMethod *)obj {
  [self addObject:obj forExtensionClass:[GDataSiteVerificationMethod class]];
}

- (NSArray *)entryLinks {
  return [self objectsForExtensionClass:[GDataEntryLink class]];
}

- (void)setEntryLinks:(NSArray *)arr {
  [self setObjects:arr forExtensionClass:[GDataEntryLink class]];
}

- (void)addEntryLink:(GDataEntryLink *)obj {
  [self addObject:obj forExtensionClass:[GDataEntryLink class]];
}

#pragma mark Convenience accessors

- (GDataEntryLink *)verificationEntryLink {

  GDataEntryLink *obj = [GDataUtilities firstObjectFromArray:[self entryLinks]
                                                   withValue:kGDataSiteVerificationRel
                                                  forKeyPath:@"rel"];
  return obj;
}

- (GDataEntryLink *)sitemapsEntryLink {
  GDataEntryLink *obj = [GDataUtilities firstObjectFromArray:[self entryLinks]
                                                   withValue:kGDataSiteSitemapsRel
                                                  forKeyPath:@"rel"];
  return obj;
}

- (GDataSiteVerificationMethod *)verificationMethodInUse {

  GDataSiteVerificationMethod *method;
  method = [GDataUtilities firstObjectFromArray:[self verificationMethods]
                                      withValue:[NSNumber numberWithBool:YES]
                                     forKeyPath:@"isInUse"];
  return method;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE
