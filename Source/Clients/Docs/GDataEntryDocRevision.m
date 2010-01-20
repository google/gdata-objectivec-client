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
//  GDataEntryDocRevision.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE

#import "GDataEntryDocRevision.h"
#import "GDataDocConstants.h"

@implementation GDataDocPublish
+ (NSString *)extensionElementURI       { return kGDataNamespaceDocuments; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDocumentsPrefix; }
+ (NSString *)extensionElementLocalName { return @"publish"; }
@end

@implementation GDataDocPublishAuto
+ (NSString *)extensionElementURI       { return kGDataNamespaceDocuments; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDocumentsPrefix; }
+ (NSString *)extensionElementLocalName { return @"publishAuto"; }
@end

@implementation GDataDocPublishOutsideDomain
+ (NSString *)extensionElementURI       { return kGDataNamespaceDocuments; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDocumentsPrefix; }
+ (NSString *)extensionElementLocalName { return @"publishOutsideDomain"; }
@end

@implementation GDataEntryDocRevision

+ (NSString *)coreProtocolVersionForServiceVersion:(NSString *)serviceVersion {
  return [GDataDocConstants coreProtocolVersionForServiceVersion:serviceVersion];
}

+ (NSString *)standardEntryKind {
  return kGDataCategoryDocRevision;
}

+ (void)load {
  [self registerEntryClass];
}

+ (id)revisionEntry {
  GDataEntryDocRevision *obj = [[[self alloc] init] autorelease];

  [obj setNamespaces:[GDataDocConstants baseDocumentNamespaces]];

  return obj;
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                 childClasses:
   [GDataDocPublish class],
   [GDataDocPublishAuto class],
   [GDataDocPublishOutsideDomain class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"publish",              @"publish",              kGDataDescBooleanPresent },
    { @"publishAuto",          @"publishAuto",          kGDataDescBooleanPresent },
    { @"publishOutsideDomain", @"publishOutsideDomain", kGDataDescBooleanPresent },
    { nil, nil, 0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

#pragma mark -

- (NSNumber *)publish { // BOOL
  GDataDocPublish *obj = [self objectForExtensionClass:[GDataDocPublish class]];
  return [obj boolNumberValue];
}

- (void)setPublish:(NSNumber *)num {
  GDataDocPublish *obj = [GDataDocPublish valueWithBool:[num boolValue]];
  [self setObject:obj forExtensionClass:[GDataDocPublish class]];
}

- (NSNumber *)publishAuto { // BOOL
  GDataDocPublishAuto *obj = [self objectForExtensionClass:[GDataDocPublishAuto class]];
  return [obj boolNumberValue];
}

- (void)setPublishAuto:(NSNumber *)num {
  GDataDocPublishAuto *obj = [GDataDocPublishAuto valueWithBool:[num boolValue]];
  [self setObject:obj forExtensionClass:[GDataDocPublishAuto class]];
}

- (NSNumber *)publishOutsideDomain { // BOOL
  GDataDocPublishOutsideDomain *obj;

  obj = [self objectForExtensionClass:[GDataDocPublishOutsideDomain class]];
  return [obj boolNumberValue];
}

- (void)setPublishOutsideDomain:(NSNumber *)num {
  GDataDocPublishOutsideDomain *obj;

  obj = [GDataDocPublishOutsideDomain valueWithBool:[num boolValue]];
  [self setObject:obj forExtensionClass:[GDataDocPublishOutsideDomain class]];
}

#pragma mark -

- (GDataPerson *)modifyingUser {
  NSArray *authors = [self authors];
  if ([authors count] > 0) {
    GDataPerson *obj = [authors objectAtIndex:0];
    return obj;
  }
  return nil;
}

- (void)setModifyingUser:(GDataPerson *)obj {
  NSArray *authors;
  if (obj != nil) {
    authors = [NSArray arrayWithObject:obj];
  } else {
    authors = nil;
  }
  [self setAuthors:authors];
}

- (GDataLink *)publishedLink {
  return [self linkWithRelAttributeValue:kGDataDocsPublishedRel];
}

+ (NSString *)defaultServiceVersion {
  return kGDataDocsDefaultServiceVersion;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE
