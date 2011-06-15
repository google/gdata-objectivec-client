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
//  GDataEntryYouTubeCaptionTrack.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataEntryYouTubeCaptionTrack.h"
#import "GDataYouTubeConstants.h"
#import "GDataYouTubeElements.h"

@implementation GDataEntryYouTubeCaptionTrack

+ (GDataEntryYouTubeCaptionTrack *)captionTrackEntry {

  GDataEntryYouTubeCaptionTrack *entry = [self object];

  [entry setNamespaces:[GDataYouTubeConstants youTubeNamespaces]];

  return entry;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategoryYouTubeCaptionTrack;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataYouTubeDerived class]];

  // the publication state element is an extension to the Atom publishing
  // control element
  [self addExtensionDeclarationForParentClass:[GDataAtomPubControl class]
                                   childClass:[GDataYouTubePublicationState class]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"state", @"publicationState", kGDataDescValueLabeled },
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

- (GDataYouTubePublicationState *)publicationState {
  // publication state is an extension to the entry's atomPubControl
  GDataAtomPubControl *atomPubControl = [self atomPubControl];
  return [atomPubControl objectForExtensionClass:[GDataYouTubePublicationState class]];
}

- (void)setGDataYouTubePublicationState:(GDataYouTubePublicationState *)obj {

  GDataAtomPubControl *atomPubControl = [self atomPubControl];

  if (obj != nil && atomPubControl == nil) {
    // to set the publication state, we need to make an atomPubControl element
    atomPubControl = [GDataAtomPubControl atomPubControl];
  }

  [atomPubControl setObject:obj
          forExtensionClass:[GDataYouTubePublicationState class]];
}

- (NSString *)derived {
  GDataYouTubeDerived *obj = [self objectForExtensionClass:[GDataYouTubeDerived class]];
  return [obj stringValue];
}

- (void)setDerived:(NSString *)str {
  GDataYouTubeDerived *obj = [GDataYouTubeDerived valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeDerived class]];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
