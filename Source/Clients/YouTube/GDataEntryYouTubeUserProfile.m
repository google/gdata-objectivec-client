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
//  GDataEntryYouTubeUserProfile.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataEntryYouTubeUserProfile.h"
#import "GDataYouTubeConstants.h"
#import "GDataYouTubeElements.h"

@implementation GDataEntryYouTubeUserProfile

+ (GDataEntryYouTubeUserProfile *)userProfileEntry {
  
  GDataEntryYouTubeUserProfile *entry = [[[self alloc] init] autorelease];

  [entry setNamespaces:[GDataYouTubeConstants youTubeNamespaces]];
  
  return entry;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategoryYouTubeUserProfile;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  [self addExtensionDeclarationForParentClass:[self class]
                                   childClasses:
     [GDataFeedLink class],
     
     // YouTube element extensions
     [GDataYouTubeAge class], [GDataYouTubeBooks class], 
     [GDataYouTubeCompany class], [GDataYouTubeAboutMe class], 
     [GDataYouTubeGender class], [GDataYouTubeHobbies class], 
     [GDataYouTubeHometown class], [GDataYouTubeLocation class], 
     [GDataYouTubeMovies class], [GDataYouTubeMusic class], 
     [GDataYouTubeOccupation class], [GDataYouTubeRelationship class], 
     [GDataYouTubeSchool class], [GDataYouTubeUsername class],
     [GDataYouTubeFirstName class],  [GDataYouTubeLastName class], 
     [GDataYouTubeStatistics class], 
     
     // media extensions
     [GDataMediaThumbnail class], nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  static struct GDataDescriptionRecord descRecs[] = {
    { @"statistics",   @"statistics",          kGDataDescValueLabeled },
    { @"age",          @"age",                 kGDataDescValueLabeled },
    { @"thumbnail",    @"thumbnail",           kGDataDescValueLabeled },
    { @"company",      @"company",             kGDataDescValueLabeled },
    { @"gender",       @"gender",              kGDataDescValueLabeled },
    { @"hobbies",      @"hobbies",             kGDataDescValueLabeled },
    { @"hometown",     @"hometown",            kGDataDescValueLabeled },
    { @"location",     @"location",            kGDataDescValueLabeled },
    { @"movies",       @"movies",              kGDataDescValueLabeled },
    { @"music",        @"music",               kGDataDescValueLabeled },
    { @"occupation",   @"occupation",          kGDataDescValueLabeled },
    { @"relationship", @"relationship",        kGDataDescValueLabeled },
    { @"school",       @"school",              kGDataDescValueLabeled },
    { @"username",     @"username",            kGDataDescValueLabeled },
    { @"firstName",    @"firstName",           kGDataDescValueLabeled },
    { @"lastName",     @"lastName",            kGDataDescValueLabeled },
    { @"summary",      @"summary.stringValue", kGDataDescValueLabeled },
    { @"feedLinks",    @"feedLinks",           kGDataDescArrayCount },
    { nil, nil, 0 }
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
  
  NSArray *channelCats;
  
  channelCats = [self categoriesWithScheme:kGDataSchemeYouTubeChannel];
  
  if ([channelCats count] > 0) {
    GDataCategory *category = [channelCats objectAtIndex:0];
    NSString *term = [category term];
    return term;
  }
  return nil;
}

#pragma mark -

- (GDataYouTubeStatistics *)statistics {
  return [self objectForExtensionClass:[GDataYouTubeStatistics class]];
}

- (void)setStatistics:(GDataYouTubeStatistics *)obj {
  [self setObject:obj forExtensionClass:[GDataYouTubeStatistics class]];
}

- (NSString *)aboutMe {
  GDATA_DEBUG_ASSERT_MIN_SERVICE_V2();
  
  GDataYouTubeAboutMe *obj = [self objectForExtensionClass:[GDataYouTubeAboutMe class]];
  return [obj stringValue];
}

- (void)setAboutMe:(NSString *)str {
  GDATA_DEBUG_ASSERT_MIN_SERVICE_V2();

  GDataYouTubeAboutMe *obj = [GDataYouTubeAboutMe valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeAboutMe class]];
}

- (NSString *)books {
  GDataYouTubeBooks *obj = [self objectForExtensionClass:[GDataYouTubeBooks class]];
  return [obj stringValue];
}

- (void)setBooks:(NSString *)str {
  GDataYouTubeBooks *obj = [GDataYouTubeBooks valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeBooks class]];
}

- (NSNumber *)age {
  GDataYouTubeAge *obj = [self objectForExtensionClass:[GDataYouTubeAge class]];
  return [obj intNumberValue];
}

- (void)setAge:(NSNumber *)num {
  GDataYouTubeAge *obj = [GDataYouTubeAge valueWithNumber:num];
  [self setObject:obj forExtensionClass:[GDataYouTubeAge class]];
}

- (GDataMediaThumbnail *)thumbnail {
  GDataMediaThumbnail *obj = [self objectForExtensionClass:[GDataMediaThumbnail class]];
  return obj;
}

- (void)setThumbnail:(GDataMediaThumbnail *)obj {
  [self setObject:obj forExtensionClass:[GDataMediaThumbnail class]];
}

- (NSString *)company {
  GDataYouTubeCompany *obj = [self objectForExtensionClass:[GDataYouTubeCompany class]];
  return [obj stringValue];
}

- (void)setCompany:(NSString *)str {
  GDataYouTubeCompany *obj = [GDataYouTubeCompany valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeCompany class]];
}

- (NSString *)gender {
  GDataYouTubeGender *obj = [self objectForExtensionClass:[GDataYouTubeGender class]];
  return [obj stringValue];
}

- (void)setGender:(NSString *)str {
  GDataYouTubeGender *obj = [GDataYouTubeGender valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeGender class]];
}

- (NSString *)hobbies {
  GDataYouTubeHobbies *obj = [self objectForExtensionClass:[GDataYouTubeHobbies class]];
  return [obj stringValue];
}

- (void)setHobbies:(NSString *)str {
  GDataYouTubeHobbies *obj = [GDataYouTubeHobbies valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeHobbies class]];
}

- (NSString *)hometown {
  GDataYouTubeHometown *obj = [self objectForExtensionClass:[GDataYouTubeHometown class]];
  return [obj stringValue];
}

- (void)setHometown:(NSString *)str {
  GDataYouTubeHometown *obj = [GDataYouTubeHometown valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeHometown class]];
}

- (NSString *)location {
  GDataYouTubeLocation *obj = [self objectForExtensionClass:[GDataYouTubeLocation class]];
  return [obj stringValue];
}

- (void)setLocation:(NSString *)str {
  GDataYouTubeLocation *obj = [GDataYouTubeLocation valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeLocation class]];
}

- (NSString *)movies {
  GDataYouTubeMovies *obj = [self objectForExtensionClass:[GDataYouTubeMovies class]];
  return [obj stringValue];
}

- (void)setMovies:(NSString *)str {
  GDataYouTubeMovies *obj = [GDataYouTubeMovies valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeMovies class]];
}

- (NSString *)music {
  GDataYouTubeMusic *obj = [self objectForExtensionClass:[GDataYouTubeMusic class]];
  return [obj stringValue];
}

- (void)setMusic:(NSString *)str {
  GDataYouTubeMusic *obj = [GDataYouTubeMusic valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeMusic class]];
}

- (NSString *)occupation {
  GDataYouTubeOccupation *obj = [self objectForExtensionClass:[GDataYouTubeOccupation class]];
  return [obj stringValue];
}

- (void)setOccupation:(NSString *)str {
  GDataYouTubeOccupation *obj = [GDataYouTubeOccupation valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeOccupation class]];
}

- (NSString *)relationship {
  GDataYouTubeRelationship *obj = [self objectForExtensionClass:[GDataYouTubeRelationship class]];
  return [obj stringValue];
}

- (void)setRelationship:(NSString *)str {
  GDataYouTubeRelationship *obj = [GDataYouTubeRelationship valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeRelationship class]];
}

- (NSString *)school {
  GDataYouTubeSchool *obj = [self objectForExtensionClass:[GDataYouTubeSchool class]];
  return [obj stringValue];
}

- (void)setSchool:(NSString *)str {
  GDataYouTubeSchool *obj = [GDataYouTubeSchool valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeSchool class]];
}

- (NSString *)username {
  GDataYouTubeUsername *obj = [self objectForExtensionClass:[GDataYouTubeUsername class]];
  return [obj stringValue];
}

- (void)setUsername:(NSString *)str {
  GDataYouTubeUsername *obj = [GDataYouTubeUsername valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeUsername class]];
}

- (NSString *)firstName {
  GDataYouTubeFirstName *obj = [self objectForExtensionClass:[GDataYouTubeFirstName class]];
  return [obj stringValue];
}

- (void)setFirstName:(NSString *)str {
  GDataYouTubeFirstName *obj = [GDataYouTubeFirstName valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeFirstName class]];
}

- (NSString *)lastName {
  GDataYouTubeLastName *obj = [self objectForExtensionClass:[GDataYouTubeLastName class]];
  return [obj stringValue];
}

- (void)setLastName:(NSString *)str {
  GDataYouTubeLastName *obj = [GDataYouTubeLastName valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeLastName class]];
}

- (NSArray *)feedLinks {
  return [self objectsForExtensionClass:[GDataFeedLink class]]; 
}

#pragma mark Convenience accessors

- (GDataLink *)videoLogLink {
  return [self linkWithRelAttributeValue:kGDataLinkYouTubeVlog];
}

- (GDataLink *)featuredVideoLink {
  return [self linkWithRelAttributeValue:kGDataLinkYouTubeFeatured];
}

- (GDataFeedLink *)feedLinkForRel:(NSString *)rel {
  return [GDataUtilities firstObjectFromArray:[self feedLinks]
                                    withValue:rel
                                   forKeyPath:@"rel"];
}

- (GDataFeedLink *)favoritesFeedLink {
  return [self feedLinkForRel:kGDataLinkYouTubeFavorites];
}

- (GDataFeedLink *)contactsFeedLink {
  return [self feedLinkForRel:kGDataLinkYouTubeContacts];
}

- (GDataFeedLink *)inboxFeedLink {
  return [self feedLinkForRel:kGDataLinkYouTubeInbox];
}

- (GDataFeedLink *)playlistsFeedLink {
  return [self feedLinkForRel:kGDataLinkYouTubePlaylists];
}

- (GDataFeedLink *)subscriptionsFeedLink {
  return [self feedLinkForRel:kGDataLinkYouTubeSubscriptions];
}

- (GDataFeedLink *)uploadsFeedLink {
  return [self feedLinkForRel:kGDataLinkYouTubeUploads];
}

- (GDataFeedLink *)recentSubscriptionVideosFeedLink {
  return [self feedLinkForRel:kGDataLinkYouTubeNewSubscriptionVideos];
}

- (GDataFeedLink *)friendsActivityFeedLink {
  return [self feedLinkForRel:kGDataLinkYouTubeFriendsActivity];
}

- (GDataFeedLink *)recentActivityFeedLink {
  return [self feedLinkForRel:kGDataLinkYouTubeRecentActivity];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
