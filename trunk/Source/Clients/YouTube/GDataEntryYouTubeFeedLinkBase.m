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

#import "GDataEntryYouTubeFeedLinkBase.h"
#import "GDataEntryYouTubeVideo.h"

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

   // elements present in GData v1 only
   [GDataFeedLink class],
   [GDataYouTubeDescription class],

   // media extensions
   [GDataMediaThumbnail class],
   nil];
}

- (NSMutableArray *)itemsForDescription {

  NSMutableArray *items = [super itemsForDescription];

  [self addToArray:items objectDescriptionIfNonNil:[self thumbnail] withName:@"thumbnail"];
  [self addToArray:items objectDescriptionIfNonNil:[self countHint] withName:@"countHint"];

  // elements present in GData v1 only
  if ([self isServiceVersion1]) {
    [self addToArray:items objectDescriptionIfNonNil:[self feedLink] withName:@"feedLink"];
    [self addToArray:items objectDescriptionIfNonNil:[self youTubeDescription] withName:@"description"];
  }

  return items;
}

+ (NSString *)defaultServiceVersion {
  return kGDataYouTubeDefaultServiceVersion;
}

#pragma mark -

- (GDataMediaThumbnail *)thumbnail {
  GDataMediaThumbnail *obj = [self objectForExtensionClass:[GDataMediaThumbnail class]];
  return obj;
}

- (void)setThumbnail:(GDataMediaThumbnail *)obj {
  [self setObject:obj forExtensionClass:[GDataMediaThumbnail class]];
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

// elements present in GData v1 only
- (GDataFeedLink *)feedLink {
  GDATA_DEBUG_ASSERT_MAX_SERVICE_V1();
  
  return [self objectForExtensionClass:[GDataFeedLink class]]; 
}

- (void)setFeedLink:(GDataFeedLink *)feedLink {
  GDATA_DEBUG_ASSERT_MAX_SERVICE_V1();
  
  [self setObject:feedLink forExtensionClass:[GDataFeedLink class]]; 
}

- (NSString *)youTubeDescription {
  GDATA_DEBUG_ASSERT_MAX_SERVICE_V1();
  
  GDataYouTubeDescription *obj = [self objectForExtensionClass:[GDataYouTubeDescription class]];
  return [obj stringValue];
}

- (void)setYouTubeDescription:(NSString *)str {
  GDATA_DEBUG_ASSERT_MAX_SERVICE_V1();
  
  GDataYouTubeDescription *obj = [GDataYouTubeDescription valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeDescription class]];
}


@end
