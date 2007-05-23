/* Copyright (c) 2007 Google Inc.
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
//  GDataFeedPhotoBase.m
//

#import "GDataFeedPhotoAlbum.h"
#import "GDataEntryPhotoBase.h"


@implementation GDataFeedPhotoAlbum

+ (GDataFeedPhotoAlbum *)albumFeed {
  
  GDataFeedPhotoAlbum *entry = [[[GDataFeedPhotoAlbum alloc] init] autorelease];
  
  [entry setNamespaces:[GDataEntryPhotoBase photoNamespaces]];
  
  return entry;
}

+ (void)load {
  [GDataObject registerFeedClass:[self class]
           forCategoryWithScheme:nil 
                            term:kGDataCategoryPhotosAlbum];
}

- (void)initExtensionDeclarations {
  
  [super initExtensionDeclarations];
  
  // common photo extensions
  Class feedClass = [self class];
  
  [self addExtensionDeclarationForParentClass:feedClass
                                   childClass:[GDataPhotoAccess class]];
  [self addExtensionDeclarationForParentClass:feedClass
                                   childClass:[GDataPhotoBytesUsed class]];
  [self addExtensionDeclarationForParentClass:feedClass
                                   childClass:[GDataPhotoCommentCount class]];
  [self addExtensionDeclarationForParentClass:feedClass
                                   childClass:[GDataPhotoCommentingEnabled class]];
  [self addExtensionDeclarationForParentClass:feedClass
                                   childClass:[GDataPhotoTimestamp class]];
  [self addExtensionDeclarationForParentClass:feedClass
                                   childClass:[GDataPhotoNumberUsed class]];
  [self addExtensionDeclarationForParentClass:feedClass
                                   childClass:[GDataPhotoNumberLeft class]];
  [self addExtensionDeclarationForParentClass:feedClass
                                   childClass:[GDataPhotoBytesUsed class]];
  [self addExtensionDeclarationForParentClass:feedClass
                                   childClass:[GDataPhotoUser class]];
  [self addExtensionDeclarationForParentClass:feedClass
                                   childClass:[GDataPhotoNickname class]];
  [self addExtensionDeclarationForParentClass:feedClass
                                   childClass:[GDataPhotoName class]];
  [self addExtensionDeclarationForParentClass:feedClass
                                   childClass:[GDataPhotoLocation class]];
  [self addExtensionDeclarationForParentClass:feedClass
                                   childClass:[GDataMediaGroup class]];

  [GDataGeo addGeoExtensionDeclarationsToObject:self
                                 forParentClass:feedClass];
}

- (id)init {
  self = [super init];
  if (self) {
    [self addCategory:[GDataCategory categoryWithScheme:kGDataCategoryScheme
                                                   term:kGDataCategoryPhotosAlbum]];
  }
  return self;
}

- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  [self addToArray:items objectDescriptionIfNonNil:[self access] withName:@"access"];
  [self addToArray:items objectDescriptionIfNonNil:[self bytesUsed] withName:@"bytesUsed"];
  [self addToArray:items objectDescriptionIfNonNil:[self commentCount] withName:@"commentCount"];
  [self addToArray:items objectDescriptionIfNonNil:[self commentsEnabled] withName:@"commentsEnabled"];
  [self addToArray:items objectDescriptionIfNonNil:[self timestamp] withName:@"date"];
  [self addToArray:items objectDescriptionIfNonNil:[self location] withName:@"location"];
  [self addToArray:items objectDescriptionIfNonNil:[self name] withName:@"name"];
  [self addToArray:items objectDescriptionIfNonNil:[self nickname] withName:@"nickname"];
  [self addToArray:items objectDescriptionIfNonNil:[self photosLeft] withName:@"photosLeft"];
  [self addToArray:items objectDescriptionIfNonNil:[self photosUsed] withName:@"photosUsed"];
  [self addToArray:items objectDescriptionIfNonNil:[self username] withName:@"username"];
  [self addToArray:items objectDescriptionIfNonNil:[self geoLocation] withName:@"geoLocation"];
  [self addToArray:items objectDescriptionIfNonNil:[self mediaGroup] withName:@"mediaGroup"];
  return items;
}

#pragma mark -

- (NSString *)access {
  GDataPhotoAccess *obj = [self objectForExtensionClass:[GDataPhotoAccess class]];
  return [obj stringValue];
}

- (void)setAccess:(NSString *)str {
  GDataPhotoAccess *obj = [GDataPhotoAccess valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataPhotoAccess class]];  
}

- (NSNumber *)bytesUsed {
  // long long
  GDataPhotoBytesUsed *obj = [self objectForExtensionClass:[GDataPhotoBytesUsed class]];
  return [obj longLongNumberValue];
}

- (void)setBytesUsed:(NSNumber *)num {
  GDataPhotoBytesUsed *obj = [GDataPhotoBytesUsed valueWithNumber:num];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (NSNumber *)commentCount {
  // int
  GDataPhotoCommentCount *obj = [self objectForExtensionClass:[GDataPhotoCommentCount class]];
  return [obj intNumberValue];
}

- (void)setCommentCount:(NSNumber *)num {
  GDataPhotoCommentCount *obj = [GDataPhotoCommentCount valueWithNumber:num];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (NSNumber *)commentsEnabled {
  // BOOL
  GDataPhotoCommentingEnabled *obj = [self objectForExtensionClass:[GDataPhotoCommentingEnabled class]];
  return [obj boolNumberValue];
}

- (void)setCommentsEnabled:(NSNumber *)num {
  GDataPhotoCommentingEnabled *obj = [GDataPhotoCommentingEnabled valueWithBool:[num boolValue]];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (GDataPhotoTimestamp *)timestamp {
  return [self objectForExtensionClass:[GDataPhotoTimestamp class]];
}

- (void)setTimestamp:(GDataPhotoTimestamp *)obj {
  [self setObject:obj forExtensionClass:[GDataPhotoTimestamp class]];
}

- (NSString *)location {
  GDataPhotoLocation *obj = [self objectForExtensionClass:[GDataPhotoLocation class]];
  return [obj stringValue];
}

- (void)setLocation:(NSString *)str {
  GDataPhotoLocation *obj = [GDataPhotoLocation valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataPhotoLocation class]];  
}

- (NSString *)name {
  GDataPhotoName *obj = [self objectForExtensionClass:[GDataPhotoName class]];
  return [obj stringValue];
}

- (void)setName:(NSString *)str {
  GDataPhotoName *obj = [GDataPhotoName valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataPhotoName class]];  
}

- (NSString *)nickname {
  GDataPhotoNickname *obj = [self objectForExtensionClass:[GDataPhotoNickname class]];
  return [obj stringValue];
}

- (void)setNickname:(NSString *)str {
  GDataPhotoNickname *obj = [GDataPhotoNickname valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataPhotoNickname class]];  
}

- (NSNumber *)photosLeft {
  // int
  GDataPhotoNumberLeft *obj = [self objectForExtensionClass:[GDataPhotoNumberLeft class]];
  return [obj intNumberValue];
}

- (void)setPhotosLeft:(NSNumber *)num {
  GDataPhotoNumberLeft *obj = [GDataPhotoNumberLeft valueWithNumber:num];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (NSNumber *)photosUsed {
  // int
  GDataPhotoNumberUsed *obj = [self objectForExtensionClass:[GDataPhotoNumberUsed class]];
  return [obj intNumberValue];
}

- (void)setPhotosUsed:(NSNumber *)num {
  GDataPhotoNumberUsed *obj = [GDataPhotoNumberUsed valueWithNumber:num];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (NSString *)username {
  GDataPhotoUser *obj = [self objectForExtensionClass:[GDataPhotoUser class]];
  return [obj stringValue];
}

- (void)setUsername:(NSString *)str {
  GDataPhotoUser *obj = [GDataPhotoUser valueWithString:str];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (GDataGeo *)geoLocation {
  return [GDataGeo geoLocationForObject:self];
}

- (void)setGeoLocation:(GDataGeo *)geo {
  [GDataGeo setGeoLocation:geo forObject:self];
}

- (GDataMediaGroup *)mediaGroup {
  return (GDataMediaGroup *) [self objectForExtensionClass:[GDataMediaGroup class]];
}

- (void)setMediaGroup:(GDataMediaGroup *)obj {
  [self setObject:obj forExtensionClass:[GDataMediaGroup class]];
}

@end
