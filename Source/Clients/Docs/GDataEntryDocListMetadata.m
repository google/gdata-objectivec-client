/* Copyright (c) 2010 Google Inc.
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
//  GDataEntryDocListMetadata.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE

#import "GDataEntryDocListMetadata.h"

@interface GDataQuotaBytesUsedInTrash : GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataQuotaBytesUsedInTrash
+ (NSString *)extensionElementURI       { return kGDataNamespaceDocuments; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDocumentsPrefix; }
+ (NSString *)extensionElementLocalName { return @"quotaBytesUsedInTrash"; }
@end

@implementation GDataEntryDocListMetadata : GDataEntryBase

+ (NSString *)standardEntryKind {
  return kGDataCategoryDocListMetadata;
}

+ (NSString *)coreProtocolVersionForServiceVersion:(NSString *)serviceVersion {
  return [GDataDocConstants coreProtocolVersionForServiceVersion:serviceVersion];
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                 childClasses:
   [GDataDocExportFormat class],
   [GDataDocFeature class],
   [GDataDocImportFormat class],
   [GDataDocMaxUploadSize class],
   [GDataQuotaBytesTotal class],
   [GDataQuotaBytesUsed class],
   [GDataQuotaBytesUsedInTrash class],
   [GDataDocLargestChangestamp class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"quotaTotal",         @"quotaBytesTotal",       kGDataDescValueLabeled },
    { @"quotaUsed",          @"quotaBytesUsed",        kGDataDescValueLabeled },
    { @"quotaInTrash",       @"quotaBytesUsedInTrash", kGDataDescValueLabeled },
    { @"features",           @"features",              kGDataDescArrayDescs   },
    { @"uploadSize",         @"maxUploadSizes",        kGDataDescValueLabeled },
    { @"export",             @"exportFormats",         kGDataDescArrayDescs   },
    { @"import",             @"importFormats",         kGDataDescArrayDescs   },
    { @"largestChangestamp", @"largestChangestamp",    kGDataDescValueLabeled },
    { nil, nil, (GDataDescRecTypes)0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

+ (NSString *)defaultServiceVersion {
  return kGDataDocsDefaultServiceVersion;
}

#pragma mark -

// extensions
- (NSArray *)exportFormats {
  NSArray *array = [self objectsForExtensionClass:[GDataDocExportFormat class]];
  return array;
}

- (void)setExportFormats:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataDocExportFormat class]];
}

- (NSArray *)features {
  NSArray *array = [self objectsForExtensionClass:[GDataDocFeature class]];
  return array;
}

- (void)setFeatures:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataDocFeature class]];
}

- (NSArray *)importFormats {
  NSArray *array = [self objectsForExtensionClass:[GDataDocImportFormat class]];
  return array;
}

- (void)setImportFormats:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataDocImportFormat class]];
}

- (NSArray *)maxUploadSizes {
  NSArray *array = [self objectsForExtensionClass:[GDataDocMaxUploadSize class]];
  return array;
}

- (void)setMaxUploadSizes:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataDocMaxUploadSize class]];
}

- (NSNumber *)quotaBytesTotal { // long long
  GDataQuotaBytesTotal *obj;

  obj = [self objectForExtensionClass:[GDataQuotaBytesTotal class]];
  return [obj longLongNumberValue];
}

- (void)setQuotaBytesTotal:(NSNumber *)num {
  GDataQuotaBytesTotal *obj = [GDataQuotaBytesTotal valueWithNumber:num];
  [self setObject:obj forExtensionClass:[GDataQuotaBytesTotal class]];
}

- (NSNumber *)quotaBytesUsed { // long long
  GDataQuotaBytesUsed *obj;

  obj = [self objectForExtensionClass:[GDataQuotaBytesUsed class]];
  return [obj longLongNumberValue];
}

- (void)setQuotaBytesUsed:(NSNumber *)num {
  GDataQuotaBytesUsed *obj = [GDataQuotaBytesUsed valueWithNumber:num];
  [self setObject:obj forExtensionClass:[GDataQuotaBytesUsed class]];
}

- (NSNumber *)quotaBytesUsedInTrash { // long long
  GDataQuotaBytesUsedInTrash *obj;

  obj = [self objectForExtensionClass:[GDataQuotaBytesUsedInTrash class]];
  return [obj longLongNumberValue];
}

- (void)setQuotaBytesUsedInTrash:(NSNumber *)num {
  GDataQuotaBytesUsedInTrash *obj = [GDataQuotaBytesUsedInTrash valueWithNumber:num];
  [self setObject:obj forExtensionClass:[GDataQuotaBytesUsedInTrash class]];
}

- (NSNumber *)largestChangestamp {
  GDataDocLargestChangestamp *obj;
  obj = [self objectForExtensionClass:[GDataDocLargestChangestamp class]];
  return [obj longLongNumberValue];
}

- (void)setLargestChangestamp:(NSNumber *)num {
  GDataDocLargestChangestamp *obj;
  obj = [GDataDocLargestChangestamp valueWithNumber:num];
  [self setObject:obj forExtensionClass:[GDataDocLargestChangestamp class]];
}

#pragma mark -

- (GDataDocMaxUploadSize *)maxUploadSizeForKind:(NSString *)uploadKind {
  GDataDocMaxUploadSize *obj;

  obj = [GDataUtilities firstObjectFromArray:[self maxUploadSizes]
                                   withValue:uploadKind
                                  forKeyPath:@"uploadKind"];
  return obj;
}

- (GDataDocFeature *)featureForName:(NSString *)name {
  GDataDocFeature *obj = [GDataUtilities firstObjectFromArray:[self features]
                                                    withValue:name
                                                   forKeyPath:@"featureName"];
  return obj;
}
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE
