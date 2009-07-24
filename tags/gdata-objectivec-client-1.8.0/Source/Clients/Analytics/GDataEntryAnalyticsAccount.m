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
//  GDataEntryAnalyticsAccount.m
//


#import "GDataEntryAnalyticsAccount.h"
#import "GDataAnalyticsConstants.h"
#import "GDataAnalyticsElements.h"

@implementation GDataEntryAnalyticsAccount

+ (GDataEntryAnalyticsAccount *)accountEntry {

  GDataEntryAnalyticsAccount *obj;
  obj = [[[self alloc] init] autorelease];

  [obj setNamespaces:[GDataAnalyticsConstants analyticsNamespaces]];

  return obj;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategoryAnalyticsAccount;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {
  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                 childClasses:
   [GDataAnalyticsProperty class],
   [GDataAnalyticsTableID class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  NSString *propsDescValue = nil;
  NSMutableArray *propsDisplayArray = nil;
  GDataAnalyticsProperty *prop;

  // display properties as "(name=value, name2=value2)"

  GDATA_FOREACH(prop, [self properties]) {
    NSString *propDisplay = [NSString stringWithFormat:@"%@=%@",
                             [prop name], [prop stringValue]];
    if (propsDisplayArray == nil) {
      propsDisplayArray = [NSMutableArray array];
    }
    [propsDisplayArray addObject:propDisplay];
  }

  if (propsDisplayArray) {
    propsDescValue = [NSString stringWithFormat:@"(%@)",
                      [propsDisplayArray componentsJoinedByString:@", "]];
  }

  struct GDataDescriptionRecord descRecs[] = {
    { @"tableID",    @"tableID",     kGDataDescValueLabeled   },
    { @"properties", propsDescValue, kGDataDescValueIsKeyPath },
    { nil, nil, 0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

+ (NSString *)defaultServiceVersion {
  return kGDataAnalyticsDefaultServiceVersion;
}

#pragma mark -

- (NSString *)tableID {
  GDataAnalyticsTableID *obj;

  obj = [self objectForExtensionClass:[GDataAnalyticsTableID class]];
  return [obj stringValue];
}

- (void)setTableID:(NSString *)str {
  GDataAnalyticsTableID *obj = [GDataAnalyticsTableID valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataAnalyticsTableID class]];
}


- (NSArray *)properties {
  return [self objectsForExtensionClass:[GDataAnalyticsProperty class]];
}

- (void)setProperties:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataAnalyticsProperty class]];
}

- (void)addProperty:(GDataAnalyticsProperty *)obj {
  [self addObject:obj forExtensionClass:[GDataAnalyticsProperty class]];
}

@end
