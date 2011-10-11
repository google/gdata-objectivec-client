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
//  GDataEntryYouTubeFeedLinkBase.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataEntryYouTubeFeedLinkBase.h"
#import "GDataYouTubeConstants.h"

// this is the superclass for GDataEntryYouTubeSubscription and
// GDataEntryYouTubePlaylistLink

@implementation GDataEntryYouTubeFeedLinkBase

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];

  // YouTube element extensions
  [self addExtensionDeclarationForParentClass:entryClass
                                 childClasses:
   [GDataYouTubePrivate class],
   [GDataYouTubeCountHint class],
   [GDataYouTubePlaylistID class],

   // elements present in GData v1 only
   [GDataFeedLink class],

   // media extensions
   [GDataMediaGroup class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"mediaGroup", @"mediaGroup", kGDataDescValueLabeled },
    { @"countHint",  @"countHint",  kGDataDescValueLabeled },
    { nil, nil, (GDataDescRecTypes)0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

+ (NSString *)defaultServiceVersion {
  return kGDataYouTubeDefaultServiceVersion;
}

#pragma mark -

- (GDataMediaGroup *)mediaGroup {
  GDataMediaGroup *obj = [self objectForExtensionClass:[GDataMediaGroup class]];
  return obj;
}

- (void)setMediaGroup:(GDataMediaGroup *)obj {
  [self setObject:obj forExtensionClass:[GDataMediaGroup class]];
}

- (NSString *)countHint {
  GDATA_DEBUG_ASSERT_MIN_SERVICE_V2();

  GDataYouTubeCountHint *obj = [self objectForExtensionClass:[GDataYouTubeCountHint class]];
  return [obj stringValue];
}

- (void)setCountHint:(NSString *)str {
  GDATA_DEBUG_ASSERT_MIN_SERVICE_V2();

  GDataYouTubeCountHint *obj = [GDataYouTubeCountHint valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeCountHint class]];
}

- (NSString *)playlistID {
  GDataYouTubePlaylistID *obj = [self objectForExtensionClass:[GDataYouTubePlaylistID class]];
  return [obj stringValue];
}

- (void)setPlaylistID:(NSString *)str {
  GDataYouTubePlaylistID *obj = [GDataYouTubePlaylistID valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubePlaylistID class]];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
