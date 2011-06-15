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
//  GDataEntryYouTubeVideo.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataEntryYouTubeVideo.h"
#import "GDataYouTubeConstants.h"
#import "GDataYouTubeElements.h"

@implementation GDataEntryYouTubeVideo

+ (GDataEntryYouTubeVideo *)videoEntry {
  
  GDataEntryYouTubeVideo *entry = [self object];

  [entry setNamespaces:[GDataYouTubeConstants youTubeNamespaces]];
  
  return entry;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategoryYouTubeVideo;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];

  [self addExtensionDeclarationForParentClass:entryClass
                                 childClasses:
   [GDataComment class],
   [GDataYouTubeRating class],
   
   // YouTube element extensions
   [GDataYouTubeStatistics class],
   [GDataYouTubeNonEmbeddable class],
   [GDataYouTubeLocation class],
   [GDataYouTubeRecordedDate class],
   [GDataYouTubeAccessControl class],
   
   // YouTubeMediaGroup encapsulates YouTubeMediaContent
   [GDataYouTubeMediaGroup class],
   nil];
  
  // Geo
  [GDataGeo addGeoExtensionDeclarationsToObject:self
                                 forParentClass:entryClass];  
  
  // the publication state element is an extension to the Atom publishing
  // control element
  Class atomPubControlClass = [GDataAtomPubControl class];
  [self addExtensionDeclarationForParentClass:atomPubControlClass
                                 childClasses:
   [GDataYouTubePublicationState class],
   [GDataYouTubeIncomplete class],
   nil];

  // the token element is an extension to the edit-media GDataLink
  [self addExtensionDeclarationForParentClass:[GDataLink class]
                                   childClass:[GDataYouTubeToken class]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  // report notEmbeddable since it's the unusual case
  NSString *nonEmbeddableValue = [self isEmbeddable] ? nil : @"YES";

  GDataYouTubeRating *rating = [self rating];
  NSString *ratingStr = nil;
  if (rating) {
    ratingStr = [NSString stringWithFormat:@"+%@/-%@",
                 [rating numberOfLikes], [rating numberOfDislikes]];
  }

  struct GDataDescriptionRecord descRecs[] = {
    { @"state",             @"publicationState",   kGDataDescValueLabeled   },
    { @"rating",            ratingStr,             kGDataDescValueIsKeyPath },
    { @"comment",           @"comment",            kGDataDescValueLabeled   },
    { @"stats",             @"statistics",         kGDataDescValueLabeled   },
    { @"mediaGroup",        @"mediaGroup",         kGDataDescValueLabeled   },
    { @"geoLocation",       @"geoLocation",        kGDataDescValueLabeled   },
    { @"notEmbeddable",     nonEmbeddableValue,    kGDataDescValueIsKeyPath },
    { @"pubState",          @"publicationState",   kGDataDescValueLabeled   },
    { @"recorded",          @"recordedDate",       kGDataDescValueLabeled   },
    { @"incomplete",        @"isIncomplete",       kGDataDescBooleanPresent },
    { @"accessControls",    @"accessControls",     kGDataDescArrayDescs     },
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

- (GDataYouTubeStatistics *)statistics {
  return [self objectForExtensionClass:[GDataYouTubeStatistics class]];
}

- (void)setStatistics:(GDataYouTubeStatistics *)obj {
  [self setObject:obj forExtensionClass:[GDataYouTubeStatistics class]];
}

- (GDataComment *)comment {
  return [self objectForExtensionClass:[GDataComment class]];
}

- (void)setComment:(GDataComment *)obj {
  [self setObject:obj forExtensionClass:[GDataComment class]];
}

- (NSString *)location {
  GDataYouTubeLocation *obj;

  obj = [self objectForExtensionClass:[GDataYouTubeLocation class]];
  return [obj stringValue];
}

- (void)setLocation:(NSString *)str {
  GDataYouTubeLocation *obj = [GDataYouTubeLocation valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeLocation class]];
}

- (GDataDateTime *)recordedDate {
  GDataYouTubeRecordedDate *obj;

  obj = [self objectForExtensionClass:[GDataYouTubeRecordedDate class]];
  return [obj dateTimeValue];
}

- (void)setRecordedDate:(GDataDateTime *)dateTime {
  GDataYouTubeRecordedDate *obj;

  // recordedDate is date only, no time
  [dateTime setHasTime:NO];

  obj = [GDataYouTubeRecordedDate valueWithDateTime:dateTime];
  [self setObject:obj forExtensionClass:[GDataYouTubeRecordedDate class]];
}

- (NSArray *)accessControls {
  return [self objectsForExtensionClass:[GDataYouTubeAccessControl class]];
}

- (void)setAccessControls:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataYouTubeAccessControl class]];
}

- (void)addAccessControl:(GDataYouTubeAccessControl *)obj {
  [self addObject:obj forExtensionClass:[GDataYouTubeAccessControl class]];
}

- (BOOL)isEmbeddable {
  // note that the element is actually "non-embeddable", so we reverse the
  // sense
  GDataYouTubeNonEmbeddable *obj = [self objectForExtensionClass:[GDataYouTubeNonEmbeddable class]];
  return (obj == nil);
}

- (void)setIsEmbeddable:(BOOL)flag {
  if (!flag) {
    GDataYouTubeNonEmbeddable *nonEmbed = [GDataYouTubeNonEmbeddable implicitValue];
    [self setObject:nonEmbed forExtensionClass:[GDataYouTubeNonEmbeddable class]];
  } else {
    [self setObject:nil forExtensionClass:[GDataYouTubeNonEmbeddable class]];
  }
}

- (GDataYouTubeRating *)rating {
  return [self objectForExtensionClass:[GDataYouTubeRating class]];
}

- (void)setRating:(GDataYouTubeRating *)obj {
  [self setObject:obj forExtensionClass:[GDataYouTubeRating class]];
}

- (GDataYouTubeMediaGroup *)mediaGroup {
  return [self objectForExtensionClass:[GDataYouTubeMediaGroup class]];
}

- (void)setMediaGroup:(GDataYouTubeMediaGroup *)obj {
  [self setObject:obj forExtensionClass:[GDataYouTubeMediaGroup class]];
}

- (GDataYouTubePublicationState *)publicationState {
  // publication state is an extension to the entry's atomPubControl
  GDataAtomPubControl *atomPubControl = [self atomPubControl];
  return [atomPubControl objectForExtensionClass:[GDataYouTubePublicationState class]];
}

- (void)setGDataYouTubePublicationState:(GDataYouTubePublicationState *)obj {
  
  GDataAtomPubControl *atomPubControl = [self atomPubControl];
  
  if (obj != nil && atomPubControl == nil) {
    // to add the publication state, we need to make an atomPubControl element
    atomPubControl = [GDataAtomPubControl atomPubControl]; 
  }
  
  [atomPubControl setObject:obj forExtensionClass:[GDataYouTubePublicationState class]];
}

- (BOOL)isIncomplete {
  // incomplete is an extension to the entry's atomPubControl
  GDataAtomPubControl *atomPubControl = [self atomPubControl];

  GDataYouTubeIncomplete *obj;
  obj = [atomPubControl objectForExtensionClass:[GDataYouTubeIncomplete class]];
  return (obj != nil);
}

- (void)setIsIncomplete:(BOOL)flag {

  GDataAtomPubControl *atomPubControl = [self atomPubControl];
  GDataYouTubeIncomplete *obj = nil;

  if (flag) {
    obj = [GDataYouTubeIncomplete implicitValue];

    if (atomPubControl == nil) {
      // to add the incomplete, we need to make an atomPubControl element
      atomPubControl = [GDataAtomPubControl atomPubControl];
    }
  }

  [atomPubControl setObject:obj
          forExtensionClass:[GDataYouTubeIncomplete class]];
}

#pragma mark -

- (GDataGeo *)geoLocation {
  return [GDataGeo geoLocationForObject:self];
}

- (void)setGeoLocation:(GDataGeo *)geo {
  [GDataGeo setGeoLocation:geo forObject:self];
}

#pragma mark -

- (GDataLink *)videoResponsesLink {
  return [self linkWithRelAttributeValue:kGDataLinkYouTubeResponses]; 
}

- (GDataLink *)ratingsLink {
  return [self linkWithRelAttributeValue:kGDataLinkYouTubeRatings]; 
}

- (GDataLink *)complaintsLink {
  return [self linkWithRelAttributeValue:kGDataLinkYouTubeComplaints]; 
}

- (GDataLink *)captionTracksLink {
  return [self linkWithRelAttributeValue:kGDataLinkYouTubeCaptionTracks];
}

@end

@implementation GDataLink (GDataYouTubeVideoEntryAdditions)
- (GDataYouTubeToken *)youTubeToken {
  return [self objectForExtensionClass:[GDataYouTubeToken class]];
}

- (void)setYouTubeToken:(GDataYouTubeToken *)obj {
  [self setObject:obj forExtensionClass:[GDataYouTubeToken class]];
}
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
