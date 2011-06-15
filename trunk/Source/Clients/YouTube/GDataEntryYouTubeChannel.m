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
//  GDataEntryYouTubeChannel.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataEntryYouTubeChannel.h"
#import "GDataYouTubeConstants.h"
#import "GDataYouTubeElements.h"

@implementation GDataEntryYouTubeChannel

+ (GDataEntryYouTubeChannel *)channelEntry {

  GDataEntryYouTubeChannel *entry = [self object];

  [entry setNamespaces:[GDataYouTubeConstants youTubeNamespaces]];

  return entry;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategoryYouTubeChannel;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  Class entryClass = [self class];

  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataFeedLink class]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  static struct GDataDescriptionRecord descRecs[] = {
    { @"feedLinks", @"feedLinks", kGDataDescArrayCount },
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

- (NSString *)channelType {

  NSArray *subs;

  subs = [self categoriesWithScheme:kGDataSchemeYouTubeChannelType];

  if ([subs count] > 0) {
    GDataCategory *channel = [subs objectAtIndex:0];
    NSString *term = [channel term];
    return term;
  }
  return nil;
}

#pragma mark -

- (NSArray *)feedLinks {
  return [self objectsForExtensionClass:[GDataFeedLink class]]; 
}

#pragma mark Convenience accessors

- (GDataFeedLink *)feedLinkForRel:(NSString *)rel {
  return [GDataUtilities firstObjectFromArray:[self feedLinks]
                                    withValue:rel
                                   forKeyPath:@"rel"];
}

- (GDataFeedLink *)uploadsFeedLink {
  return [self feedLinkForRel:kGDataLinkYouTubeUploads];
}

- (GDataFeedLink *)featuredFeedLink {
  return [self feedLinkForRel:kGDataLinkYouTubeFeatured];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
