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
//  GDataVolumePrice.m
//

// book price extension, like
//  <gbs:price type="RetailPrice">
//    <gd:money amount="15.00" currencyCode="USD" />
//    <gbs:promotion value="print-digital-bundle" />
//  </gbs:price>

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BOOKS_SERVICE

#import "GDataVolumePrice.h"
#import "GDataValueConstruct.h"
#import "GDataBookConstants.h"

@interface GDataVolumePromotion : GDataValueConstruct <GDataExtension>
@end

@implementation GDataVolumePromotion
+ (NSString *)extensionElementURI       { return kGDataNamespaceBooks; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceBooksPrefix; }
+ (NSString *)extensionElementLocalName { return @"promotion"; }
@end


static NSString* const kTypeAttr = @"type";

@implementation GDataVolumePrice

+ (NSString *)extensionElementURI       { return kGDataNamespaceBooks; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceBooksPrefix; }
+ (NSString *)extensionElementLocalName { return @"price"; }

+ (GDataVolumePrice *)volumePriceWithType:(NSString *)type
                                    money:(GDataMoney *)money {
  GDataVolumePrice *obj = [self object];
  [obj setType:type];
  [obj setMoney:money];
  return obj;
}

- (void)addParseDeclarations {
  NSArray *attrs = [NSArray arrayWithObject:kTypeAttr];
  [self addLocalAttributeDeclarations:attrs];
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                 childClasses:
   [GDataMoney class],
   [GDataVolumePromotion class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"money",     @"money",                 kGDataDescValueLabeled },
    { @"promotion", @"promotion.stringValue", kGDataDescValueLabeled },
    { nil, nil, (GDataDescRecTypes)0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

#pragma mark -

//
// attributes
//

- (NSString *)type {
  return [self stringValueForAttribute:kTypeAttr];
}

- (void)setType:(NSString *)str {
  [self setStringValue:str forAttribute:kTypeAttr];
}

//
// extensions
//

- (GDataMoney *)money {
  return [self objectForExtensionClass:[GDataMoney class]];
}

- (void)setMoney:(GDataMoney *)obj {
  [self setObject:obj forExtensionClass:[GDataMoney class]];
}

- (NSString *)promotion {
  GDataVolumePromotion *obj;

  obj = [self objectForExtensionClass:[GDataVolumePromotion class]];
  return [obj stringValue];
}

- (void)setPromotion:(NSString *)str {
  GDataVolumePromotion *obj = [GDataVolumePromotion valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataVolumePromotion class]];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BOOKS_SERVICE
