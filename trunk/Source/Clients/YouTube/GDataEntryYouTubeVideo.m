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

#define GDATAENTRYYOUTUBEVIDEO_DEFINE_GLOBALS 1
#import "GDataEntryYouTubeVideo.h"
#import "GDataYouTubeElements.h"

@implementation GDataEntryYouTubeVideo

+ (NSDictionary *)youTubeNamespaces {
  
  NSMutableDictionary *namespaces = [NSMutableDictionary dictionaryWithDictionary:
    [GDataEntryBase baseGDataNamespaces]];
  
  [namespaces setObject:kGDataNamespaceYouTube 
                 forKey:kGDataNamespaceYouTubePrefix]; // "yt"

  [namespaces setObject:kGDataNamespaceMedia
                 forKey:kGDataNamespaceMediaPrefix]; // "media"
  
  [namespaces addEntriesFromDictionary:[GDataGeo geoNamespaces]]; // geo, georss, gml

  return namespaces;  
}

+ (GDataEntryYouTubeVideo *)videoEntry {
  
  GDataEntryYouTubeVideo *entry = [[[self alloc] init] autorelease];

  [entry setNamespaces:[GDataEntryYouTubeVideo youTubeNamespaces]];
  
  return entry;
}

#pragma mark -

+ (void)load {
  [GDataObject registerEntryClass:[self class]
            forCategoryWithScheme:nil 
                             term:kGDataCategoryYouTubeVideo];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];

  [self addExtensionDeclarationForParentClass:entryClass
                                 childClasses:
   [GDataComment class],
   [GDataRating class],
   
   // YouTube element extensions
   [GDataYouTubeStatistics class],
   [GDataYouTubeNonEmbeddable class],
   [GDataYouTubeLocation class],
   [GDataYouTubeRecordedDate class],
   
   [GDataYouTubeRacy class], // racy is deprecated for GData v2
   
   // YouTubeMediaGroup encapsulates YouTubeMediaContent
   [GDataYouTubeMediaGroup class],
   nil];
  
  // Geo
  [GDataGeo addGeoExtensionDeclarationsToObject:self
                                 forParentClass:entryClass];  
  
  // the publication state element is an extension to the Atom publishing
  // control element
  Class appClass = [GDataAtomPubControl atomPubControlClassForObject:self];
  [self addExtensionDeclarationForParentClass:appClass
                                   childClass:[GDataYouTubePublicationState class]];

  // the token element is an extension to the edit-media GDataLink
  [self addExtensionDeclarationForParentClass:[GDataLink class]
                                   childClass:[GDataYouTubeToken class]];
}

- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  [self addToArray:items objectDescriptionIfNonNil:[self publicationState] withName:@"state"];
  
  [self addToArray:items objectDescriptionIfNonNil:[self rating] withName:@"rating"];
  [self addToArray:items objectDescriptionIfNonNil:[self comment] withName:@"comment"];
  [self addToArray:items objectDescriptionIfNonNil:[self statistics] withName:@"stats"];

  [self addToArray:items objectDescriptionIfNonNil:[self mediaGroup] withName:@"mediaGroup"];
  [self addToArray:items objectDescriptionIfNonNil:[self geoLocation] withName:@"geoLocation"];

  if ([self isServiceVersion1] && [self isRacy]) [items addObject:@"racy"];
  if (![self isEmbeddable]) [items addObject:@"notEmbeddable"];

  return items;
}

- (id)init {
  self = [super init];
  if (self) {
    NSString *categoryTerm = [[self class] videoEntryCategoryTerm];
    
    [self addCategory:[GDataCategory categoryWithScheme:kGDataCategoryScheme
                                                   term:categoryTerm]];
  }
  return self;
}

// subclasses implement this to declare the proper category term for their
// entries
+ (NSString *)videoEntryCategoryTerm {
  return kGDataCategoryYouTubeVideo;
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

  obj = [GDataYouTubeRecordedDate valueWithDateTime:dateTime];
  [self setObject:obj forExtensionClass:[GDataYouTubeRecordedDate class]];
}

- (BOOL)isRacy {
#if DEBUG
  NSAssert([self isServiceVersion1], @"deprecated");
#endif

  GDataYouTubeRacy *obj = [self objectForExtensionClass:[GDataYouTubeRacy class]];
  return (obj != nil);
}

- (void)setIsRacy:(BOOL)flag {
#if DEBUG
  NSAssert([self isServiceVersion1], @"deprecated");
#endif
  
  if (flag) {
    GDataYouTubeRacy *racy = [GDataYouTubeRacy implicitValue];
    [self setObject:racy forExtensionClass:[GDataYouTubeRacy class]];
  } else {
    [self setObject:nil forExtensionClass:[GDataYouTubeRacy class]];
  }
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

- (GDataRating *)rating {
  return [self objectForExtensionClass:[GDataRating class]];
}

- (void)setRating:(GDataRating *)obj {
  [self setObject:obj forExtensionClass:[GDataRating class]]; 
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

@end

@implementation GDataLink (GDataYouTubeVideoEntryAdditions)
- (GDataYouTubeToken *)youTubeToken {
  return [self objectForExtensionClass:[GDataYouTubeToken class]];
}

- (void)setYouTubeToken:(GDataYouTubeToken *)obj {
  [self setObject:obj forExtensionClass:[GDataYouTubeToken class]];
}
@end
