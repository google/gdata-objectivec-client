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
//  GDataEntryTaskList.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_TRANSLATION_SERVICE

#import "GDataTranslationElements.h"
#import "GDataTranslationConstants.h"

@implementation GDataTranslationSourceLanguage
+ (NSString *)extensionElementURI       { return kGDataNamespaceTranslation; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceTranslationPrefix; }
+ (NSString *)extensionElementLocalName { return @"sourceLanguage"; }
@end

@implementation GDataTranslationTargetLanguage
+ (NSString *)extensionElementURI       { return kGDataNamespaceTranslation; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceTranslationPrefix; }
+ (NSString *)extensionElementLocalName { return @"targetLanguage"; }
@end

@implementation GDataTranslationPercentComplete
+ (NSString *)extensionElementURI       { return kGDataNamespaceTranslation; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceTranslationPrefix; }
+ (NSString *)extensionElementLocalName { return @"percentComplete"; }
@end

@implementation GDataTranslationNumberOfSourceWords
+ (NSString *)extensionElementURI       { return kGDataNamespaceTranslation; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceTranslationPrefix; }
+ (NSString *)extensionElementLocalName { return @"numberOfSourceWords"; }
@end

@implementation GDataTranslationScope
+ (NSString *)extensionElementURI       { return kGDataNamespaceTranslation; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceTranslationPrefix; }
+ (NSString *)extensionElementLocalName { return @"scope"; }
@end

@implementation GDataTranslationGlossary
+ (NSString *)extensionElementURI       { return kGDataNamespaceTranslation; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceTranslationPrefix; }
+ (NSString *)extensionElementLocalName { return @"glossary"; }

+ (GDataTranslationGlossary *)glossaryWithLink:(GDataLink *)translationLink {
  GDataTranslationGlossary *obj = [[[self alloc] init] autorelease];
  [obj addLink:translationLink];
  return obj;
}
@end

@implementation GDataTranslationMemory
+ (NSString *)extensionElementURI       { return kGDataNamespaceTranslation; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceTranslationPrefix; }
+ (NSString *)extensionElementLocalName { return @"translationMemory"; }

+ (GDataTranslationMemory *)memoryWithLink:(GDataLink *)translationLink {
  GDataTranslationMemory *obj = [[[self alloc] init] autorelease];
  [obj addLink:translationLink];
  return obj;
}
@end

#pragma mark -

@implementation GDataTranslationLinks

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataLink class]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"links", @"links", kGDataDescArrayDescs },
    { nil, nil, 0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

- (NSArray *)links {
  NSArray *array = [self objectsForExtensionClass:[GDataLink class]];
  return array;
}

- (void)setLinks:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataLink class]];
}

- (void)addLink:(GDataLink *)obj {
  [self addObject:obj forExtensionClass:[GDataLink class]];
}

- (void)removeLink:(GDataLink *)obj {
  [self removeObject:obj forExtensionClass:[GDataLink class]];
}

// convenience accessors
- (NSArray *)hrefs {
  NSArray *hrefs = [[self links] valueForKey:@"href"];
  return hrefs;
}

@end // GDataTranslationGlossary

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_TRANSLATION_SERVICE
