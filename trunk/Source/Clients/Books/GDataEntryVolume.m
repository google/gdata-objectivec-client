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
//  GDataEntryVolume.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BOOKS_SERVICE

#import "GDataEntryVolume.h"
#import "GDataBookConstants.h"
#import "GDataComment.h"
#import "GDataRating.h"

@interface GDataVolumeViewability : GDataValueConstruct <GDataExtension>
@end

@interface GDataVolumeEmbeddability : GDataValueConstruct <GDataExtension>
@end

@interface GDataVolumeOpenAccess : GDataValueConstruct <GDataExtension>
@end

@interface GDataVolumeContentVersion : GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataVolumeViewability
+ (NSString *)extensionElementURI       { return kGDataNamespaceBooks; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceBooksPrefix; }
+ (NSString *)extensionElementLocalName { return @"viewability"; }
@end

@implementation GDataVolumeEmbeddability
+ (NSString *)extensionElementURI       { return kGDataNamespaceBooks; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceBooksPrefix; }
+ (NSString *)extensionElementLocalName { return @"embeddability"; }
@end

@implementation GDataVolumeOpenAccess
+ (NSString *)extensionElementURI       { return kGDataNamespaceBooks; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceBooksPrefix; }
+ (NSString *)extensionElementLocalName { return @"openAccess"; }
@end

@implementation GDataVolumeContentVersion
+ (NSString *)extensionElementURI       { return kGDataNamespaceBooks; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceBooksPrefix; }
+ (NSString *)extensionElementLocalName { return @"contentVersion"; }
@end

@implementation GDataVolumeReview
+ (NSString *)extensionElementURI       { return kGDataNamespaceBooks; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceBooksPrefix; }
+ (NSString *)extensionElementLocalName { return @"review"; }
@end

@implementation GDataEntryVolume

+ (GDataEntryVolume *)volumeEntry {
  
  GDataEntryVolume *obj;
  obj = [self object];
  
  [obj setNamespaces:[GDataBookConstants booksNamespaces]];
  
  return obj;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategoryBooksVolume;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];

  Class entryClass = [self class];

  [self addExtensionDeclarationForParentClass:entryClass
                                 childClasses:

   [GDataRating class],

   // local extensions
   [GDataVolumeViewability class], [GDataVolumeEmbeddability class],
   [GDataVolumeReview class], [GDataVolumeOpenAccess class],
   [GDataVolumeReadingPosition class], [GDataVolumeContentVersion class],

   // DublinCore extensions
   [GDataDCCreator class], [GDataDCDate class], [GDataDCDescription class],
   [GDataDCFormat class], [GDataDCIdentifier class], [GDataDCLanguage class],
   [GDataDCPublisher class], [GDataDCSubject class], [GDataDCTitle class],
   nil];

}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"comment",       @"comment",            kGDataDescValueLabeled },
    { @"creators",      @"creators",           kGDataDescValueLabeled },
    { @"dates",         @"dates",              kGDataDescValueLabeled },
    { @"descriptions",  @"volumeDescriptions", kGDataDescValueLabeled },
    { @"embeddability", @"embeddability",      kGDataDescValueLabeled },
    { @"openAccess",    @"openAccess",         kGDataDescValueLabeled },
    { @"formats",       @"formats",            kGDataDescValueLabeled },
    { @"identifiers",   @"volumeIdentifiers",  kGDataDescValueLabeled },
    { @"languages",     @"languages",          kGDataDescValueLabeled },
    { @"publishers",    @"publishers",         kGDataDescValueLabeled },
    { @"rating",        @"rating",             kGDataDescValueLabeled },
    { @"review",        @"review",             kGDataDescValueLabeled },
    { @"position",      @"readingPosition",    kGDataDescValueLabeled },
    { @"version",       @"contentVersion",     kGDataDescValueLabeled },
    { @"subjects",      @"subjects",           kGDataDescValueLabeled },
    { @"titles",        @"volumeTitles",       kGDataDescValueLabeled },
    { @"viewability",   @"viewability",        kGDataDescValueLabeled },
    { nil, nil, (GDataDescRecTypes)0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

+ (NSString *)defaultServiceVersion {
  return kGDataBooksDefaultServiceVersion;
}

#pragma mark -

- (GDataComment *)comment {
  return [self objectForExtensionClass:[GDataComment class]]; 
}

- (void)setComment:(GDataComment *)obj {
  [self setObject:obj forExtensionClass:[GDataComment class]];
}

- (NSArray *)creators {
  return [self objectsForExtensionClass:[GDataDCCreator class]];
}

- (void)setCreators:(NSArray *)arr {
  [self setObjects:arr forExtensionClass:[GDataDCCreator class]]; 
}

- (void)addCreator:(GDataDCCreator *)obj {
  [self addObject:obj forExtensionClass:[GDataDCCreator class]]; 
}

- (NSArray *)dates {
  return [self objectsForExtensionClass:[GDataDCDate class]];
}

- (void)setDates:(NSArray *)arr {
  [self setObjects:arr forExtensionClass:[GDataDCDate class]]; 
}

- (void)addDate:(GDataDCDate *)obj {
  [self addObject:obj forExtensionClass:[GDataDCDate class]]; 
}

- (NSArray *)volumeDescriptions {
  return [self objectsForExtensionClass:[GDataDCDescription class]];
}

- (void)setVolumeDescriptions:(NSArray *)arr {
  [self setObjects:arr forExtensionClass:[GDataDCDescription class]]; 
}

- (void)addVolumeDescriptions:(GDataDCFormat *)obj {
  [self addObject:obj forExtensionClass:[GDataDCDescription class]];   
}

- (NSString *)embeddability {
  GDataVolumeEmbeddability* obj = [self objectForExtensionClass:[GDataVolumeEmbeddability class]];
  return [obj stringValue];
}

- (void)setEmbeddability:(NSString *)str {
  GDataVolumeEmbeddability *obj = [GDataVolumeEmbeddability valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataVolumeEmbeddability class]];
}

- (NSString *)openAccess {
  GDataVolumeOpenAccess* obj = [self objectForExtensionClass:[GDataVolumeOpenAccess class]];
  return [obj stringValue];
}

- (void)setOpenAccess:(NSString *)str {
  GDataVolumeOpenAccess *obj = [GDataVolumeOpenAccess valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataVolumeOpenAccess class]];
}

- (NSArray *)formats {
  return [self objectsForExtensionClass:[GDataDCFormat class]];
}

- (void)setFormats:(NSArray *)arr {
  [self setObjects:arr forExtensionClass:[GDataDCFormat class]]; 
}

- (void)addFormat:(GDataDCFormat *)obj {
  [self addObject:obj forExtensionClass:[GDataDCFormat class]]; 
}

- (NSArray *)volumeIdentifiers {
  return [self objectsForExtensionClass:[GDataDCIdentifier class]];
}

- (void)setVolumeIdentifiers:(NSArray *)arr {
  [self setObjects:arr forExtensionClass:[GDataDCIdentifier class]]; 
}

- (void)addVolumeIdentifier:(GDataDCIdentifier *)obj {
  [self addObject:obj forExtensionClass:[GDataDCIdentifier class]];   
}

- (NSArray *)languages {
  return [self objectsForExtensionClass:[GDataDCLanguage class]];
}

- (void)setLanguages:(NSArray *)arr {
  [self setObjects:arr forExtensionClass:[GDataDCLanguage class]]; 
}

- (void)addLanguage:(GDataDCLanguage *)obj {
  [self addObject:obj forExtensionClass:[GDataDCLanguage class]]; 
}

- (NSArray *)prices {
  return [self objectsForExtensionClass:[GDataVolumePrice class]];
}

- (void)setPrices:(NSArray *)arr {
  [self setObjects:arr forExtensionClass:[GDataVolumePrice class]];
}

- (void)addPrice:(GDataVolumePrice *)obj {
  [self addObject:obj forExtensionClass:[GDataVolumePrice class]];
}

- (NSArray *)publishers {
  return [self objectsForExtensionClass:[GDataDCPublisher class]];
}

- (void)setPublishers:(NSArray *)arr {
  [self setObjects:arr forExtensionClass:[GDataDCPublisher class]]; 
}

- (void)addPublisher:(GDataDCPublisher *)obj {
  [self addObject:obj forExtensionClass:[GDataDCPublisher class]]; 
}

- (GDataRating *)rating {
  return [self objectForExtensionClass:[GDataRating class]];
}

- (void)setRating:(GDataRating *)obj {
  [self setObject:obj forExtensionClass:[GDataRating class]]; 
}

- (GDataVolumeReview *)review {
  return [self objectForExtensionClass:[GDataVolumeReview class]];  
}

- (void)setReview:(GDataVolumeReview *)obj {
  [self setObject:obj forExtensionClass:[GDataVolumeReview class]]; 
}

- (GDataVolumeReadingPosition *)readingPosition {
  return [self objectForExtensionClass:[GDataVolumeReadingPosition class]];
}

- (void)setReadingPosition:(GDataVolumeReadingPosition *)obj {
  [self setObject:obj forExtensionClass:[GDataVolumeReadingPosition class]];
}

- (NSString *)contentVersion {
  GDataVolumeContentVersion* obj;

  obj = [self objectForExtensionClass:[GDataVolumeContentVersion class]];
  return [obj stringValue];
}

- (void)setContentVersion:(NSString *)str {
  GDataVolumeContentVersion *obj;

  obj = [GDataVolumeContentVersion valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataVolumeContentVersion class]];
}

- (NSArray *)subjects {
  return [self objectsForExtensionClass:[GDataDCSubject class]];
}

- (void)setSubjects:(NSArray *)arr {
  [self setObjects:arr forExtensionClass:[GDataDCSubject class]]; 
}

- (void)addSubject:(GDataDCSubject *)obj {
  [self addObject:obj forExtensionClass:[GDataDCSubject class]]; 
}

- (NSArray *)volumeTitles {
  return [self objectsForExtensionClass:[GDataDCTitle class]];
}

- (void)setVolumeTitles:(NSArray *)arr {
  [self setObjects:arr forExtensionClass:[GDataDCTitle class]]; 
}

- (void)addVolumeTitle:(GDataDCTitle *)obj {
  [self addObject:obj forExtensionClass:[GDataDCTitle class]];   
}

- (NSString *)viewability {
  GDataVolumeViewability* obj = [self objectForExtensionClass:[GDataVolumeViewability class]];
  return [obj stringValue];
}

- (void)setViewability:(NSString *)str {
  GDataVolumeViewability *obj = [GDataVolumeViewability valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataVolumeViewability class]];
}

// convenience accessors

- (GDataLink *)infoLink {
  return [self linkWithRelAttributeValue:kGDataBooksInfoRel]; 
}

- (GDataLink *)previewLink {
  return [self linkWithRelAttributeValue:kGDataBooksPreviewRel]; 
}

- (GDataLink *)thumbnailLink {
  return [self linkWithRelAttributeValue:kGDataBooksThumbnailRel]; 
}

- (GDataLink *)annotationLink {
  return [self linkWithRelAttributeValue:kGDataBooksAnnotationRel]; 
}

- (GDataLink *)buyLink {
  return [self linkWithRelAttributeValue:kGDataBooksBuyLinkRel];
}

- (GDataLink *)EPubDownloadLink {
  return [self linkWithRelAttributeValue:kGDataBooksEPubDownloadRel];
}

- (GDataLink *)EPubTokenLink {
  return [self linkWithRelAttributeValue:kGDataBooksEPubToken];
}

- (GDataVolumePrice *)priceForType:(NSString *)type {
  GDataVolumePrice *obj = [GDataUtilities firstObjectFromArray:[self prices]
                                                     withValue:type
                                                    forKeyPath:@"type"];
  return obj;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BOOKS_SERVICE
