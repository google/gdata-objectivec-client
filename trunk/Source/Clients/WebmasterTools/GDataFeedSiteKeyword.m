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
//  GDataFeedSiteKeyword.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE

#import "GDataFeedSiteKeyword.h"
#import "GDataWebmasterToolsConstants.h"

@implementation GDataFeedSiteKeyword

+ (GDataFeedSiteKeyword *)siteKeywordFeed {

  GDataFeedSiteKeyword *feed = [[[self alloc] init] autorelease];

  [feed setNamespaces:[GDataWebmasterToolsConstants webmasterToolsNamespaces]];

  return feed;
}

+ (NSString *)standardFeedKind {
  return kGDataCategorySiteKeyword;
}

+ (void)load {
  [self registerFeedClass];
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataSiteKeyword class]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"keywords", @"keywords", kGDataDescArrayDescs },
    { nil, nil, 0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

+ (NSString *)defaultServiceVersion {
  return kGDataWebmasterToolsDefaultServiceVersion;
}

#pragma mark -

- (NSArray *)keywords {
  return [self objectsForExtensionClass:[GDataSiteKeyword class]];
}

- (void)setKeywords:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataSiteKeyword class]];
}

- (void)addKeyword:(GDataSiteKeyword *)obj {
  [self addObject:obj forExtensionClass:[GDataSiteKeyword class]];
}

// convenience accessor
- (NSArray *)keywordsWithSource:(NSString *)source {
  NSArray *array = [GDataUtilities objectsFromArray:[self keywords]
                                          withValue:source
                                         forKeyPath:@"source"];
  return array;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE
