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
//  GDataEntryTranslationDocument.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_TRANSLATION_SERVICE

#import "GDataEntryTranslationDocument.h"
#import "GDataTranslationConstants.h"
#import "GDataTranslationDocumentSource.h"
#import "GDataDocumentElements.h"


@implementation GDataEntryTranslationDocument

+ (GDataEntryTranslationDocument *)documentWithTitle:(NSString *)title
                                      sourceLanguage:(NSString *)sourceLanguage
                                      targetLanguage:(NSString *)targetLanguage {

  GDataEntryTranslationDocument *obj = [[[self alloc] init] autorelease];

  [obj setTitleWithString:title];
  [obj setSourceLanguage:sourceLanguage];
  [obj setTargetLanguage:targetLanguage];

  [obj setNamespaces:[GDataTranslationConstants translationNamespaces]];

  return obj;
}

#pragma mark -

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  Class entryClass = [self class];
  [self addExtensionDeclarationForParentClass:entryClass
                                 childClasses:
   // gtt extensions
   [GDataTranslationDocumentSource class],
   [GDataTranslationGlossary class],
   [GDataLastModifiedBy class],
   [GDataTranslationNumberOfSourceWords class],
   [GDataTranslationPercentComplete class],
   [GDataTranslationSourceLanguage class],
   [GDataTranslationTargetLanguage class],
   [GDataTranslationMemory class],

   // gd extensions
   [GDataLastModifiedBy class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"sourceLang",      @"sourceLanguage",          kGDataDescValueLabeled },
    { @"targetLang",      @"targetLanguage",          kGDataDescValueLabeled },
    { @"sourceWords",     @"numberOfSourceWords",     kGDataDescValueLabeled },
    { @"pctComplete",     @"percentComplete",         kGDataDescValueLabeled },
    { @"docSource",       @"documentSource",          kGDataDescValueLabeled },
    { @"lastModifiedBy",  @"lastModifiedBy",          kGDataDescValueLabeled },
    { @"glossary",        @"glossary.links",          kGDataDescArrayCount   },
    { @"memory",          @"translationMemory.links", kGDataDescArrayCount   },
    { nil, nil, 0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

+ (NSString *)defaultServiceVersion {
  return kGDataTranslationDefaultServiceVersion;
}

#pragma mark -

- (GDataTranslationDocumentSource *)documentSource {
  GDataTranslationDocumentSource *obj;

  obj = [self objectForExtensionClass:[GDataTranslationDocumentSource class]];
  return obj;
}

- (void)setDocumentSource:(GDataTranslationDocumentSource *)obj {
  [self setObject:obj forExtensionClass:[GDataTranslationDocumentSource class]];
}

- (GDataTranslationGlossary *)glossary {
  GDataTranslationGlossary *obj;

  obj = [self objectForExtensionClass:[GDataTranslationGlossary class]];
  return obj;
}

- (void)setGlossary:(GDataTranslationGlossary *)obj {
  [self setObject:obj forExtensionClass:[GDataTranslationGlossary class]];
}

- (GDataPerson *)lastModifiedBy {
  GDataLastModifiedBy *obj;

  obj = [self objectForExtensionClass:[GDataLastModifiedBy class]];
  return obj;
}

- (void)setLastModifiedBy:(GDataPerson *)obj {
  [self setObject:obj forExtensionClass:[GDataLastModifiedBy class]];
}

- (NSNumber *)numberOfSourceWords { // int
  GDataTranslationNumberOfSourceWords *obj;

  obj = [self objectForExtensionClass:[GDataTranslationNumberOfSourceWords class]];
  return [obj intNumberValue];
}

- (void)setNumberOfSourceWords:(NSNumber *)num {
  GDataTranslationNumberOfSourceWords *obj;

  obj = [GDataTranslationNumberOfSourceWords valueWithNumber:num];
  [self setObject:obj forExtensionClass:[GDataTranslationNumberOfSourceWords class]];
}

- (NSNumber *)percentComplete { // int
  GDataTranslationPercentComplete *obj;

  obj = [self objectForExtensionClass:[GDataTranslationPercentComplete class]];
  return [obj intNumberValue];
}

- (void)setPercentComplete:(NSNumber *)num {
  GDataTranslationPercentComplete *obj;

  obj = [GDataTranslationPercentComplete valueWithNumber:num];
  [self setObject:obj forExtensionClass:[GDataTranslationPercentComplete class]];
}

- (NSString *)sourceLanguage {
  GDataTranslationSourceLanguage *obj;

  obj = [self objectForExtensionClass:[GDataTranslationSourceLanguage class]];
  return [obj stringValue];
}

- (void)setSourceLanguage:(NSString *)str {
  GDataTranslationSourceLanguage *obj;

  obj = [GDataTranslationSourceLanguage valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataTranslationSourceLanguage class]];
}

- (NSString *)targetLanguage {
  GDataTranslationTargetLanguage *obj;

  obj = [self objectForExtensionClass:[GDataTranslationTargetLanguage class]];
  return [obj stringValue];
}

- (void)setTargetLanguage:(NSString *)str {
  GDataTranslationTargetLanguage *obj;

  obj = [GDataTranslationTargetLanguage valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataTranslationTargetLanguage class]];
}

- (GDataTranslationMemory *)translationMemory {
  GDataTranslationMemory *obj;

  obj = [self objectForExtensionClass:[GDataTranslationMemory class]];
  return obj;
}

- (void)setTranslationMemory:(GDataTranslationMemory *)obj {
  [self setObject:obj forExtensionClass:[GDataTranslationMemory class]];
}

#pragma mark -

// convenience accessors

- (BOOL)isHidden {
  // GTT uses a different scheme/term for hidden labels than does Google Docs,
  // so we cannot rely on GDataCategory's categories:containsCategoryWithLabel:
  // (bug 2323473)
  //
  // instead, we'll search specifically for GTT's hidden category
  // by scheme and label strings

  BOOL flag = [GDataCategory categories:[self categories]
             containsCategoryWithScheme:kGDataCategoryTranslationLabels
                                   term:nil
                                  label:kGDataCategoryLabelHidden];
  return flag;
}

- (void)setIsHidden:(BOOL)flag {
  GDataCategory *cat;

  cat = [GDataCategory categoryWithScheme:kGDataCategoryTranslationLabels
                                     term:kGDataCategoryTranslationHidden];
  [cat setLabel:kGDataCategoryLabelHidden];

  if (flag) {
    [self addCategory:cat];
  } else {
    [self removeCategory:cat];
  }
}

- (BOOL)hasCompletedTranslation {
  // when doc translation has been completed, the entry will have a category
  // indicating the completed state
  BOOL flag = [GDataCategory categories:[self categories]
             containsCategoryWithScheme:kGDataCategoryTranslationState
                                   term:kGDataCategoryTranslationCompleted
                                  label:nil];
  return flag;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_TRANSLATION_SERVICE
