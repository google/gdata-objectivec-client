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

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE

//
//  GDataDocFeature.m
//

#import "GDataDocFeature.h"
#import "GDataDocConstants.h"

static NSString *const kLangAttr = @"xml:lang";

@interface GDataDocFeatureName : GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataDocFeatureName
+ (NSString *)extensionElementURI       { return kGDataNamespaceDocuments; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDocumentsPrefix; }
+ (NSString *)extensionElementLocalName { return @"featureName"; }
@end

@interface GDataDocFeatureRate : GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataDocFeatureRate
+ (NSString *)extensionElementURI       { return kGDataNamespaceDocuments; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDocumentsPrefix; }
+ (NSString *)extensionElementLocalName { return @"featureRate"; }
@end

@implementation GDataDocFeature
// a docs feature, such as
//
//  <docs:feature>
//    <docs:featureName>ocr</docs:featureName>
//    <docs:featureRate>rate</docs:featureRate>
//  </docs:feature>

+ (NSString *)extensionElementURI       { return kGDataNamespaceDocuments; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDocumentsPrefix; }
+ (NSString *)extensionElementLocalName { return @"feature"; }

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                 childClasses:
   [GDataDocFeatureName class],
   [GDataDocFeatureRate class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  static struct GDataDescriptionRecord descRecs[] = {
    { @"name", @"featureName",  kGDataDescValueLabeled },
    { @"rate", @"featureRate",  kGDataDescValueLabeled },
    { nil, nil, (GDataDescRecTypes)0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

- (NSString *)featureName {
  GDataDocFeatureName *obj = [self objectForExtensionClass:[GDataDocFeatureName class]];
  return [obj stringValue];
}

- (void)setFeatureName:(NSString *)str {
  GDataDocFeatureName *obj = [GDataDocFeatureName valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataDocFeatureName class]];
}

- (NSString *)featureRate {
  GDataDocFeatureRate *obj = [self objectForExtensionClass:[GDataDocFeatureRate class]];
  return [obj stringValue];
}

- (void)setFeatureRate:(NSString *)str {
  GDataDocFeatureRate *obj = [GDataDocFeatureRate valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataDocFeatureRate class]];
}
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE
