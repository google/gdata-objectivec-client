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
//  GDataEntryDocBase.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE

#import "GDataEntryDocBase.h"
#import "GDataDocElements.h"

@interface GDataLastViewed : GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataLastViewed
+ (NSString *)extensionElementURI       { return kGDataNamespaceGData; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementLocalName { return @"lastViewed"; }
@end

@interface GDataSharedWithMe : GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataSharedWithMe
+ (NSString *)extensionElementURI       { return kGDataNamespaceDocuments; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDocumentsPrefix; }
+ (NSString *)extensionElementLocalName { return @"sharedWithMeDate"; }
@end

@interface GDataLastModifiedByMe : GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataLastModifiedByMe
+ (NSString *)extensionElementURI       { return kGDataNamespaceDocuments; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDocumentsPrefix; }
+ (NSString *)extensionElementLocalName { return @"modifiedByMeDate"; }
@end

@interface GDataWritersCanInvite : GDataBoolValueConstruct <GDataExtension>
@end

@implementation GDataWritersCanInvite
+ (NSString *)extensionElementURI       { return kGDataNamespaceDocuments; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDocumentsPrefix; }
+ (NSString *)extensionElementLocalName { return @"writersCanInvite"; }
@end

@interface GDataDocDescription : GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataDocDescription
+ (NSString *)extensionElementURI       { return kGDataNamespaceDocuments; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDocumentsPrefix; }
+ (NSString *)extensionElementLocalName { return @"description"; }
@end

@interface GDataDocMD5Checksum : GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataDocMD5Checksum
+ (NSString *)extensionElementURI       { return kGDataNamespaceDocuments; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDocumentsPrefix; }
+ (NSString *)extensionElementLocalName { return @"md5Checksum"; }
@end

@interface GDataDocChangestamp : GDataValueConstruct <GDataExtension>
@end

@implementation GDataDocChangestamp
+ (NSString *)extensionElementURI       { return kGDataNamespaceDocuments; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDocumentsPrefix; }
+ (NSString *)extensionElementLocalName { return @"changestamp"; }
@end

@interface GDataDocRemoved : GDataImplicitValueConstruct <GDataExtension>
@end

@implementation GDataDocRemoved
+ (NSString *)extensionElementURI       { return kGDataNamespaceDocuments; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDocumentsPrefix; }
+ (NSString *)extensionElementLocalName { return @"removed"; }
@end

@interface GDataDocFilename : GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataDocFilename
+ (NSString *)extensionElementURI       { return kGDataNamespaceDocuments; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDocumentsPrefix; }
+ (NSString *)extensionElementLocalName { return @"filename"; }
@end

@interface GDataDocSuggestedFilename : GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataDocSuggestedFilename
+ (NSString *)extensionElementURI       { return kGDataNamespaceDocuments; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDocumentsPrefix; }
+ (NSString *)extensionElementLocalName { return @"suggestedFilename"; }
@end

@interface GDataDocLastCommented : GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataDocLastCommented
+ (NSString *)extensionElementURI       { return kGDataNamespaceDocuments; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDocumentsPrefix; }
+ (NSString *)extensionElementLocalName { return @"lastCommented"; }
@end

@implementation GDataEntryDocBase

+ (NSString *)coreProtocolVersionForServiceVersion:(NSString *)serviceVersion {
  return [GDataDocConstants coreProtocolVersionForServiceVersion:serviceVersion];
}

+ (id)documentEntry {

  GDataEntryDocBase *entry = [self object];

  [entry setNamespaces:[GDataDocConstants baseDocumentNamespaces]];

  return entry;
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  // ACL feed URL is in a gd:feedLink
  [self addExtensionDeclarationForParentClass:[self class]
                                 childClasses:
   [GDataFeedLink class],
   [GDataLastViewed class],
   [GDataSharedWithMe class],
   [GDataLastModifiedByMe class],
   [GDataWritersCanInvite class],
   [GDataLastModifiedBy class],
   [GDataQuotaBytesUsed class],
   [GDataDocDescription class],
   [GDataDocMD5Checksum class],
   [GDataDocChangestamp class],
   [GDataDocFilename class],
   [GDataDocSuggestedFilename class],
   [GDataDocLastCommented class],
   [GDataDocRemoved class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"lastViewed",        @"lastViewed",          kGDataDescValueLabeled },
    { @"sharedWithMe",      @"sharedWithMe",        kGDataDescValueLabeled },
    { @"lastModifiedByMe",  @"lastModifiedByMe",    kGDataDescValueLabeled },
    { @"writersCanInvite",  @"writersCanInvite",    kGDataDescValueLabeled },
    { @"lastModifiedBy",    @"lastModifiedBy",      kGDataDescValueLabeled },
    { @"quotaUsed",         @"quotaBytesUsed",      kGDataDescValueLabeled },
    { @"desc",              @"documentDescription", kGDataDescValueLabeled },
    { @"md5",               @"MD5Checksum",         kGDataDescValueLabeled },
    { @"changestamp",       @"changestamp",         kGDataDescValueLabeled },
    { @"filename",          @"filename",            kGDataDescValueLabeled },
    { @"suggestedFilename", @"suggestedFilename",   kGDataDescValueLabeled },
    { @"lastCommented",     @"lastCommented",       kGDataDescValueLabeled },
    { @"removed",           @"removed",             kGDataDescBooleanPresent },
    { nil, nil, (GDataDescRecTypes)0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

#pragma mark -

- (GDataDateTime *)lastViewed {
  GDataLastViewed *obj = [self objectForExtensionClass:[GDataLastViewed class]];
  return [obj dateTimeValue];
}

- (void)setLastViewed:(GDataDateTime *)dateTime {
  GDataLastViewed *obj = [GDataLastViewed valueWithDateTime:dateTime];
  [self setObject:obj forExtensionClass:[GDataLastViewed class]];
}

- (GDataDateTime *)sharedWithMe {
  GDataSharedWithMe *obj =
      [self objectForExtensionClass:[GDataSharedWithMe class]];
  return [obj dateTimeValue];
}

- (void)setSharedWithMe:(GDataDateTime *)dateTime {
  GDataSharedWithMe *obj = [GDataSharedWithMe valueWithDateTime:dateTime];
  [self setObject:obj forExtensionClass:[GDataSharedWithMe class]];
}

- (GDataDateTime *)lastModifiedByMe {
  GDataLastModifiedByMe *obj =
      [self objectForExtensionClass:[GDataLastModifiedByMe class]];
  return [obj dateTimeValue];
}

- (void)setLastModifiedByMe:(GDataDateTime *)dateTime {
  GDataLastModifiedByMe *obj = [GDataLastModifiedByMe valueWithDateTime:dateTime];
  [self setObject:obj forExtensionClass:[GDataLastModifiedByMe class]];
}

- (NSNumber *)writersCanInvite { // bool
  GDataWritersCanInvite *obj = [self objectForExtensionClass:[GDataWritersCanInvite class]];
  return [obj boolNumberValue];
}

- (void)setWritersCanInvite:(NSNumber *)num {
  GDataWritersCanInvite *obj = [GDataWritersCanInvite valueWithNumber:num];
  [self setObject:obj forExtensionClass:[GDataWritersCanInvite class]];
}

- (GDataPerson *)lastModifiedBy {
  GDataLastModifiedBy *obj = [self objectForExtensionClass:[GDataLastModifiedBy class]];
  return obj;
}

- (void)setLastModifiedBy:(GDataPerson *)obj {
  [self setObject:obj forExtensionClass:[GDataLastModifiedBy class]];
}

- (NSNumber *)quotaBytesUsed { // long long
  GDataQuotaBytesUsed *obj = [self objectForExtensionClass:[GDataQuotaBytesUsed class]];
  return [obj longLongNumberValue];
}

- (void)setQuotaBytesUsed:(NSNumber *)num {
  GDataQuotaBytesUsed *obj = [GDataQuotaBytesUsed valueWithNumber:num];
  [self setObject:obj forExtensionClass:[GDataQuotaBytesUsed class]];
}

- (NSString *)documentDescription {
  GDataDocDescription *obj;
  obj = [self objectForExtensionClass:[GDataDocDescription class]];
  return [obj stringValue];
}

- (void)setDocumentDescription:(NSString *)str {
  GDataDocDescription *obj = [GDataDocDescription valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataDocDescription class]];
}

- (NSString *)MD5Checksum {
  GDataDocMD5Checksum *obj;
  obj = [self objectForExtensionClass:[GDataDocMD5Checksum class]];
  return [obj stringValue];
}

- (void)setMD5Checksum:(NSString *)str {
  GDataDocMD5Checksum *obj = [GDataDocMD5Checksum valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataDocMD5Checksum class]];
}

- (NSString *)filename {
  GDataDocFilename *obj;
  obj = [self objectForExtensionClass:[GDataDocFilename class]];
  return [obj stringValue];
}

- (void)setFilename:(NSString *)str {
  GDataDocFilename *obj = [GDataDocFilename valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataDocFilename class]];
}

- (NSString *)suggestedFilename {
  GDataDocSuggestedFilename *obj;
  obj = [self objectForExtensionClass:[GDataDocSuggestedFilename class]];
  return [obj stringValue];
}

- (void)setSuggestedFilename:(NSString *)str {
  GDataDocSuggestedFilename *obj = [GDataDocSuggestedFilename valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataDocSuggestedFilename class]];
}

- (GDataDateTime *)lastCommented {
  GDataDocLastCommented *obj;
  obj = [self objectForExtensionClass:[GDataDocLastCommented class]];
  return [obj dateTimeValue];
}

- (void)setLastCommented:(GDataDateTime *)dateTime {
  GDataDocLastCommented *obj = [GDataDocLastCommented valueWithDateTime:dateTime];
  [self setObject:obj forExtensionClass:[GDataDocLastCommented class]];
}

- (NSNumber *)changestamp {
  GDataDocChangestamp *obj;
  obj = [self objectForExtensionClass:[GDataDocChangestamp class]];
  return [obj longLongNumberValue];
}

- (void)setChangestamp:(NSNumber *)num {
  GDataDocChangestamp *obj = [GDataDocChangestamp valueWithNumber:num];
  [self setObject:obj forExtensionClass:[GDataDocChangestamp class]];
}

- (BOOL)isRemoved {
  GDataDocRemoved *obj = [self objectForExtensionClass:[GDataDocRemoved class]];
  return (obj != nil);
}

- (void)setIsRemoved:(BOOL)flag {
  GDataDocRemoved *private = flag ? [GDataDocRemoved implicitValue] : nil;
  [self setObject:private forExtensionClass:[GDataDocRemoved class]];
}

#pragma mark -

- (BOOL)isStarred {
  BOOL flag = [GDataCategory categories:[self categories]
              containsCategoryWithLabel:kGDataCategoryLabelStarred];
  return flag;
}

- (void)setIsStarred:(BOOL)flag {
  GDataCategory *cat = [GDataCategory categoryWithLabel:kGDataCategoryLabelStarred];
  if (flag) {
    [self addCategory:cat];
  } else {
    [self removeCategory:cat];
  }
}

- (BOOL)isHidden {
  BOOL flag = [GDataCategory categories:[self categories]
              containsCategoryWithLabel:kGDataCategoryLabelHidden];
  return flag;
}

- (void)setIsHidden:(BOOL)flag {
  GDataCategory *cat = [GDataCategory categoryWithLabel:kGDataCategoryLabelHidden];
  if (flag) {
    [self addCategory:cat];
  } else {
    [self removeCategory:cat];
  }
}

- (BOOL)isViewed {
  BOOL flag = [GDataCategory categories:[self categories]
              containsCategoryWithLabel:kGDataCategoryLabelViewed];
  return flag;
}

- (void)setIsViewed:(BOOL)flag {
  GDataCategory *cat = [GDataCategory categoryWithLabel:kGDataCategoryLabelViewed];
  if (flag) {
    [self addCategory:cat];
  } else {
    [self removeCategory:cat];
  }
}

- (BOOL)isShared {
  BOOL flag = [GDataCategory categories:[self categories]
              containsCategoryWithLabel:kGDataCategoryLabelShared];
  return flag;
}

- (void)setIsShared:(BOOL)flag {
  GDataCategory *cat = [GDataCategory categoryWithLabel:kGDataCategoryLabelShared];
  if (flag) {
    [self addCategory:cat];
  } else {
    [self removeCategory:cat];
  }
}

#pragma mark -

- (NSArray *)parentLinks {
  return [self linksWithRelAttributeValue:kGDataCategoryDocParent];
}

- (GDataLink *)thumbnailLink {
  return [self linkWithRelAttributeValue:kGDataDocsThumbnailRel];
}

- (GDataLink *)alternateSelfLink {
  return [self linkWithRelAttributeValue:kGDataDocsAlternateSelfRel];
}


- (GDataFeedLink *)feedLinkForRel:(NSString *)rel {

  NSArray *feedLinks = [self objectsForExtensionClass:[GDataFeedLink class]];
  GDataFeedLink *resultFeedLink;

  resultFeedLink = [GDataUtilities firstObjectFromArray:feedLinks
                                           withValue:rel
                                          forKeyPath:@"rel"];
  return resultFeedLink;
}

- (GDataFeedLink *)ACLFeedLink {

  // GDataEntryACL has an ACLLink method to get an entry's atom:link for
  // the ACL feed, but the docs feed puts the ACL link into a gd:feedLink
  // instead of into an atom:link

  // same as kGDataLinkRelACL but avoids the dependence on GDataEntryACL.h
  NSString* const kACLRel = @"http://schemas.google.com/acl/2007#accessControlList";

  GDataFeedLink *feedLink = [self feedLinkForRel:kACLRel];
  return feedLink;
}


- (GDataFeedLink *)revisionFeedLink {
  GDataFeedLink *feedLink = [self feedLinkForRel:kGDataDocsRevisionsRel];
  return feedLink;
}

+ (NSString *)defaultServiceVersion {
  return kGDataDocsDefaultServiceVersion;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE
