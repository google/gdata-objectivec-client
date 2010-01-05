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
//  GDataFeedAnalyticsAccount.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE

#import "GDataFeedAnalyticsAccount.h"
#import "GDataEntryAnalyticsAccount.h"
#import "GDataAnalyticsConstants.h"

@implementation GDataFeedAnalyticsAccount

+ (GDataFeedAnalyticsAccount *)accountFeed {

  GDataFeedAnalyticsAccount *feed = [[[self alloc] init] autorelease];

  [feed setNamespaces:[GDataAnalyticsConstants analyticsNamespaces]];

  return feed;
}

+ (NSString *)standardKindAttributeValue {
  return @"analytics#accounts";
}

+ (void)load {
  [self registerFeedClass];
}

- (Class)classForEntries {
  return [GDataEntryAnalyticsAccount class];
}

- (void)addExtensionDeclarations {
  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataAnalyticsSegment class]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  struct GDataDescriptionRecord descRecs[] = {
    { @"segments", @"segments", kGDataDescArrayDescs },
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

- (NSArray *)segments {
  return [self objectsForExtensionClass:[GDataAnalyticsSegment class]];
}

- (void)setSegments:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataAnalyticsSegment class]];
}

- (void)addSegment:(GDataAnalyticsSegment *)obj {
  [self addObject:obj forExtensionClass:[GDataAnalyticsSegment class]];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ANALYTICS_SERVICE
