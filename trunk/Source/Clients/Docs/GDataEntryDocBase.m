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
#import "GDataDocumentElements.h"

@interface GDataLastViewed : GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataLastViewed
+ (NSString *)extensionElementURI       { return kGDataNamespaceGData; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementLocalName { return @"lastViewed"; }
@end

@interface GDataWritersCanInvite : GDataBoolValueConstruct <GDataExtension>
@end

@implementation GDataWritersCanInvite
+ (NSString *)extensionElementURI       { return kGDataNamespaceDocuments; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDocumentsPrefix; }
+ (NSString *)extensionElementLocalName { return @"writersCanInvite"; }
@end


@implementation GDataEntryDocBase

+ (NSString *)coreProtocolVersionForServiceVersion:(NSString *)serviceVersion {
  return [GDataDocConstants coreProtocolVersionForServiceVersion:serviceVersion];
}

+ (id)documentEntry {

  GDataEntryDocBase *entry = [[[self alloc] init] autorelease];

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
   [GDataWritersCanInvite class],
   [GDataLastModifiedBy class],
   [GDataQuotaBytesUsed class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"lastViewed",       @"lastViewed",       kGDataDescValueLabeled },
    { @"writersCanInvite", @"writersCanInvite", kGDataDescValueLabeled },
    { @"lastModifiedBy",   @"lastModifiedBy",   kGDataDescValueLabeled },
    { @"quotaUsed",        @"quotaBytesUsed",   kGDataDescValueLabeled },
    { nil, nil, 0 }
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

#pragma mark -

- (NSArray *)parentLinks {

  NSArray *links = [self links];
  if (links == nil) return nil;

  NSArray *parentLinks = [GDataUtilities objectsFromArray:links
                                                withValue:kGDataCategoryDocParent
                                               forKeyPath:@"rel"];
  return parentLinks;
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
