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
//  GDataEntrySiteCrawlIssue.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE

#import "GDataEntrySiteCrawlIssue.h"
#import "GDataWebmasterToolsConstants.h"

// private extensions

@interface GDataSiteCrawlType : GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataSiteCrawlType
+ (NSString *)extensionElementURI       { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementLocalName { return @"crawl-type"; }
@end

@interface GDataSiteCrawlIssueDateDetected : GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataSiteCrawlIssueDateDetected
+ (NSString *)extensionElementURI       { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementLocalName { return @"date-detected"; }
@end

@interface GDataSiteCrawlIssueDetail : GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataSiteCrawlIssueDetail
+ (NSString *)extensionElementURI       { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementLocalName { return @"detail"; }
@end

@interface GDataSiteCrawlIssueType : GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataSiteCrawlIssueType
+ (NSString *)extensionElementURI       { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementLocalName { return @"issue-type"; }
@end

@interface GDataSiteCrawlIssueLinkedFrom : GDataValueElementConstruct <GDataExtension>
@end

@interface GDataSiteCrawlIssueURL: GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataSiteCrawlIssueURL
+ (NSString *)extensionElementURI       { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementLocalName { return @"url"; }
@end

@implementation GDataSiteCrawlIssueLinkedFrom
+ (NSString *)extensionElementURI       { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementLocalName { return @"linked-from"; }
@end

@implementation GDataEntrySiteCrawlIssue

+ (id)crawlIssueEntry {
  GDataEntrySiteCrawlIssue *obj = [[[self alloc] init] autorelease];

  [obj setNamespaces:[GDataWebmasterToolsConstants webmasterToolsNamespaces]];

  return obj;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategorySiteCrawlIssue;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  Class entryClass = [self class];

  [self addExtensionDeclarationForParentClass:entryClass
                                 childClasses:
   [GDataSiteCrawlType class],
   [GDataSiteCrawlIssueDateDetected class],
   [GDataSiteCrawlIssueDetail class],
   [GDataSiteCrawlIssueType class],
   [GDataSiteCrawlIssueLinkedFrom class],
   [GDataSiteCrawlIssueURL class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"crawlType",  @"crawlType",                 kGDataDescValueLabeled },
    { @"date",       @"detectedDate.stringValue",  kGDataDescValueLabeled },
    { @"issueType",  @"issueType",                 kGDataDescValueLabeled },
    { @"URL",        @"issueURLString",            kGDataDescValueLabeled },
    { @"linkedFrom", @"issueLinkedFromURLStrings", kGDataDescArrayDescs   },
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

- (NSString *)crawlType {
  GDataSiteCrawlType *obj;

  obj = [self objectForExtensionClass:[GDataSiteCrawlType class]];
  return [obj stringValue];
}

- (void)setCrawlType:(NSString *)str {
  GDataSiteCrawlType *obj = [GDataSiteCrawlType valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataSiteCrawlType class]];
}

- (GDataDateTime *)detectedDate {
  GDataSiteCrawlIssueDateDetected *obj;

  obj = [self objectForExtensionClass:[GDataSiteCrawlIssueDateDetected class]];
  return [obj dateTimeValue];
}

- (void)setDetectedDate:(GDataDateTime *)dateTime {
  GDataSiteCrawlIssueDateDetected *obj;

  obj = [GDataSiteCrawlIssueDateDetected valueWithDateTime:dateTime];
  [self setObject:obj forExtensionClass:[GDataSiteCrawlIssueDateDetected class]];
}

- (NSString *)detail {
  GDataSiteCrawlIssueDetail *obj;

  obj = [self objectForExtensionClass:[GDataSiteCrawlIssueDetail class]];
  return [obj stringValue];
}

- (void)setDetail:(NSString *)str {
  GDataSiteCrawlIssueDetail *obj;

  obj = [GDataSiteCrawlIssueDetail valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataSiteCrawlIssueDetail class]];
}

- (NSString *)issueType {
  GDataSiteCrawlIssueType *obj;

  obj = [self objectForExtensionClass:[GDataSiteCrawlIssueType class]];
  return [obj stringValue];
}

- (void)setIssueType:(NSString *)str {
  GDataSiteCrawlIssueType *obj = [GDataSiteCrawlIssueType valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataSiteCrawlIssueType class]];
}

- (NSString *)issueURLString {
  GDataSiteCrawlIssueURL *obj;

  obj = [self objectForExtensionClass:[GDataSiteCrawlIssueURL class]];
  return [obj stringValue];
}

- (void)setIssueURLString:(NSString *)str {
  GDataSiteCrawlIssueURL *obj = [GDataSiteCrawlIssueURL valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataSiteCrawlIssueURL class]];
}

- (NSArray *)issueLinkedFromURLStrings {
  // retrurns an array of URL strings
  NSArray *array;

  array = [self objectsForExtensionClass:[GDataSiteCrawlIssueLinkedFrom class]];
  if ([array count] > 0) {

    // return the URL strings, not the extension objects
    return [array valueForKeyPath:@"stringValue"];
  }
  return nil;
}

- (void)setIssueLinkedFromURLStrings:(NSArray *)array {

  // remove any current URLs
  [self setObject:nil forExtensionClass:[GDataSiteCrawlIssueLinkedFrom class]];

  NSString *str;
  GDATA_FOREACH(str, array) {
    [self addIssueLinkedFromURLString:str];
  }
}

- (void)addIssueLinkedFromURLString:(NSString *)str {
  GDataSiteCrawlIssueLinkedFrom *obj;

  obj = [GDataSiteCrawlIssueLinkedFrom valueWithString:str];
  [self addObject:obj forExtensionClass:[GDataSiteCrawlIssueLinkedFrom class]];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE
