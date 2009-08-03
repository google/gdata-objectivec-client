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
//  GDataFeedSite.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE

#import "GDataFeedSitemap.h"
#import "GDataWebmasterToolsConstants.h"

#import "GDataSitemapMobile.h"
#import "GDataSitemapNews.h"

@implementation GDataFeedSitemap

+ (GDataFeedSitemap *)sitemapFeed {
  
  GDataFeedSitemap *feed = [[[self alloc] init] autorelease];
  
  [feed setNamespaces:[GDataWebmasterToolsConstants webmasterToolsNamespaces]];
  
  return feed;
}

+ (NSString *)standardFeedKind {
  return kGDataCategorySitemapsFeed;
}

+ (void)load {
  [self registerFeedClass];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class feedClass = [self class];
  
  [self addExtensionDeclarationForParentClass:feedClass
                                 childClasses:
   [GDataSitemapMobile class],
   [GDataSitemapNews class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  [self addToArray:items objectDescriptionIfNonNil:[self sitemapMobile] withName:@"mobile"];
  [self addToArray:items objectDescriptionIfNonNil:[self sitemapNews] withName:@"news"];
  
  return items;
}
#endif

- (Class)classForEntries {
  return kUseRegisteredEntryClass;
}

+ (NSString *)defaultServiceVersion {
  return kGDataWebmasterToolsDefaultServiceVersion;
}

#pragma mark -

- (GDataSitemapMobile *)sitemapMobile {
  return [self objectForExtensionClass:[GDataSitemapMobile class]];  
}

- (void)setSitemapMobile:(GDataSitemapMobile *)obj {
  [self setObject:obj forExtensionClass:[GDataSitemapMobile class]];
}

- (GDataSitemapNews *)sitemapNews {
  return [self objectForExtensionClass:[GDataSitemapNews class]];  
}

- (void)setSitemapNews:(GDataSitemapNews *)obj {
  [self setObject:obj forExtensionClass:[GDataSitemapNews class]];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE
