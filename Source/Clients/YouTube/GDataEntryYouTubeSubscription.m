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
//  GDataEntryYouTubeSubscription.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataEntryYouTubeSubscription.h"
#import "GDataYouTubeConstants.h"
#import "GDataYouTubeElements.h"

@implementation GDataEntryYouTubeSubscription

+ (GDataEntryYouTubeSubscription *)subscriptionEntry {
  
  GDataEntryYouTubeSubscription *entry = [self object];

  [entry setNamespaces:[GDataYouTubeConstants youTubeNamespaces]];
  
  return entry;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategoryYouTubeSubscription;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];
  
  // YouTube element extensions
  [self addExtensionDeclarationForParentClass:entryClass
                                 childClasses:
   [GDataYouTubeUsername class],
   [GDataYouTubeQueryString class],
   [GDataYouTubePlaylistTitle class],
   nil];
  
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"username",      @"username",           kGDataDescValueLabeled },
    { @"query",         @"youTubeQueryString", kGDataDescValueLabeled },
    { @"playlistID",    @"playlistID",         kGDataDescValueLabeled },
    { @"playlistTitle", @"playlistTitle",      kGDataDescValueLabeled },
    { nil, nil, (GDataDescRecTypes)0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

#pragma mark -

- (NSString *)subscriptionType {
  
  NSArray *subs;
  
  subs = [self categoriesWithScheme:kGDataSchemeYouTubeSubscription];
  
  if ([subs count] > 0) {
    GDataCategory *subscription = [subs objectAtIndex:0];
    NSString *term = [subscription term];
    return term;
  }
  return nil;
}

#pragma mark -

- (NSString *)username {
  GDataYouTubeUsername *obj = [self objectForExtensionClass:[GDataYouTubeUsername class]];
  return [obj stringValue];
}

- (void)setUsername:(NSString *)str {
  GDataYouTubeUsername *obj = [GDataYouTubeUsername valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeUsername class]];
}

- (NSString *)youTubeQueryString {
  GDataYouTubeQueryString *obj = [self objectForExtensionClass:[GDataYouTubeQueryString class]];
  return [obj stringValue];
}

- (void)setYouTubeQueryString:(NSString *)str {
  GDataYouTubeQueryString *obj = [GDataYouTubeQueryString valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeQueryString class]];
}

- (NSString *)playlistTitle {
  GDataYouTubePlaylistTitle *obj;

  obj = [self objectForExtensionClass:[GDataYouTubePlaylistTitle class]];
  return [obj stringValue];
}

- (void)setPlaylistTitle:(NSString *)str {
  GDataYouTubePlaylistTitle *obj;

  obj = [GDataYouTubePlaylistTitle valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubePlaylistTitle class]];
}


@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
