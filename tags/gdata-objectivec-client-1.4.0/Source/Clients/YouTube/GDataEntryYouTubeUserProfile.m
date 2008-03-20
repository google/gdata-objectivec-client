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

#import "GDataEntryYouTubeUserProfile.h"
#import "GDataEntryYouTubeVideo.h"
#import "GDataYouTubeElements.h"

@implementation GDataEntryYouTubeUserProfile

+ (GDataEntryYouTubeUserProfile *)userProfileEntry {
  
  GDataEntryYouTubeUserProfile *entry = [[[self alloc] init] autorelease];

  [entry setNamespaces:[GDataEntryYouTubeVideo youTubeNamespaces]];
  
  return entry;
}

#pragma mark -

+ (void)load {
  [GDataObject registerEntryClass:[self class]
            forCategoryWithScheme:nil 
                             term:kGDataCategoryYouTubeUserProfile];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];

  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataFeedLink class]];
  
  // YouTube element extensions
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataYouTubeAge class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataYouTubeBooks class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataYouTubeCompany class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataYouTubeDescription class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataYouTubeGender class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataYouTubeHobbies class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataYouTubeHometown class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataYouTubeLocation class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataYouTubeMovies class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataYouTubeMusic class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataYouTubeOccupation class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataYouTubeRelationship class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataYouTubeSchool class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataYouTubeUsername class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataYouTubeFirstName class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataYouTubeLastName class]];

  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataYouTubeStatistics class]];

  // media extensions
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataMediaThumbnail class]];
}

- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];

  NSString *selNames[] = {
    @"statistics", @"age", @"thumbnail", @"company", @"gender", @"hobbies", 
    @"hometown", @"location", @"movies", @"music", @"occupation",
    @"relationship", @"school", @"username", @"firstName", @"lastName",
    @"youTubeDescription", nil
  };
  
  for (int idx = 0; selNames[idx] != nil; idx++) {
    
    NSString *name = selNames[idx];
    SEL sel = NSSelectorFromString(name);
    id val = [self performSelector:sel];
    
    [self addToArray:items objectDescriptionIfNonNil:val withName:name]; 
  }
  [self addToArray:items arrayCountIfNonEmpty:[self feedLinks] withName:@"feedLinks"];

  return items;
}

- (id)init {
  self = [super init];
  if (self) {
    [self addCategory:[GDataCategory categoryWithScheme:kGDataCategoryScheme
                                                   term:kGDataCategoryYouTubeUserProfile]];
  }
  return self;
}

#pragma mark -

- (NSString *)channelType {
  
  NSArray *categories = [self categories];
  NSArray *channelCats = [categories categoriesWithScheme:kGDataSchemeYouTubeChannel];
  
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

- (NSString *)youTubeDescription {
  GDataYouTubeDescription *obj = [self objectForExtensionClass:[GDataYouTubeDescription class]];
  return [obj stringValue];
}

- (void)setYouTubeDescription:(NSString *)str {
  GDataYouTubeDescription *obj = [GDataYouTubeDescription valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeDescription class]];
}

- (NSArray *)feedLinks {
  return [self objectsForExtensionClass:[GDataFeedLink class]]; 
}

@end

@implementation NSArray (GDataYouTubeUserProfileAdditions)

- (GDataLink *)videoLogLink {
  return [self linkWithRelAttributeValue:kGDataLinkYouTubeVlog];  
}

- (GDataFeedLink *)favoritesFeedLink {
  return [self feedLinkWithRel:kGDataLinkYouTubeFavorites];
}

- (GDataFeedLink *)contactsFeedLink {
  return [self feedLinkWithRel:kGDataLinkYouTubeContacts];
}

- (GDataFeedLink *)inboxFeedLink {
  return [self feedLinkWithRel:kGDataLinkYouTubeInbox];
}

- (GDataFeedLink *)playlistsFeedLink {
  return [self feedLinkWithRel:kGDataLinkYouTubePlaylists];
}

- (GDataFeedLink *)subscriptionsFeedLink {
  return [self feedLinkWithRel:kGDataLinkYouTubeSubscriptions];
}

- (GDataFeedLink *)uploadsFeedLink {
  return [self feedLinkWithRel:kGDataLinkYouTubeUploads];
}

@end
