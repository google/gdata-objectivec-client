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
//  GDataEntryTranslationMemory.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_TRANSLATION_SERVICE

#import "GDataEntryTranslationMemory.h"
#import "GDataTranslationConstants.h"
#import "GDataDocumentElements.h"

@implementation GDataEntryTranslationMemory

+ (GDataEntryTranslationMemory *)documentWithTitle:(NSString *)title
                                             scope:(NSString *)scope {

  GDataEntryTranslationMemory *obj = [[[self alloc] init] autorelease];

  [obj setTitleWithString:title];
  [obj setScope:scope];

  [obj setNamespaces:[GDataTranslationConstants translationNamespaces]];

  return obj;
}

#pragma mark -

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  Class entryClass = [self class];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataTranslationScope class]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"scope", @"scope", kGDataDescValueLabeled },
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

- (NSString *)scope {
  GDataTranslationScope *obj;

  obj = [self objectForExtensionClass:[GDataTranslationScope class]];
  return [obj stringValue];
}

- (void)setScope:(NSString *)str {
  GDataTranslationScope *obj;

  obj = [GDataTranslationScope valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataTranslationScope class]];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_TRANSLATION_SERVICE
