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

#define GDATAENTRYSITE_DEFINE_GLOBALS 1

#import "GDataEntrySite.h"
#import "GDataSiteVerificationMethod.h"
#import "GDataEntryLink.h"

@implementation GDataSiteCrawledDate
+ (NSString *)extensionElementURI       { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementLocalName { return @"crawled"; }
@end

@implementation GDataSiteVerified
+ (NSString *)extensionElementURI       { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementLocalName { return @"verified"; }
@end

@implementation GDataSiteIndexed
+ (NSString *)extensionElementURI       { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementLocalName { return @"indexed"; }
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
  
  [obj setNamespaces:[GDataEntrySite webmasterToolsNamespaces]];
  
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
   [GDataEntryLink class],
   nil];

  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataSiteVerificationMethod class]];  
}

- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  [self addToArray:items arrayCountIfNonEmpty:[self entryLinks] withName:@"entryLinks"];
  [self addToArray:items objectDescriptionIfNonNil:([self isIndexed] ? @"true" : @"false")
          withName:@"indexed"];
  [self addToArray:items objectDescriptionIfNonNil:[self crawledDate] withName:@"indexed"];
  [self addToArray:items objectDescriptionIfNonNil:([self isVerified] ? @"true" : @"false")
          withName:@"verified"];

  [self addToArray:items objectDescriptionIfNonNil:[self verificationMethods] withName:@"methods"];

  return items;
}

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

#pragma mark Convenience accessors

- (GDataSiteVerificationMethod *)verificationMethodInUse {
  
  NSArray *methods = [self verificationMethods];
  NSEnumerator *enumerator = [methods objectEnumerator];
  GDataSiteVerificationMethod *method;
  
  while ((method = [enumerator nextObject]) != nil) {
    if ([method isInUse]) {
      return method; 
    }
  }
  return nil;
}

@end

