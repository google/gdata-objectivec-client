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
//  GDataEntryPhotoUser.m
//

#import "GDataEntryPhotoUser.h"
#import "GDataPhotoElements.h"

// extensions



@implementation GDataEntryPhotoUser

+ (GDataEntryPhotoUser *)userEntry {
  
  GDataEntryPhotoUser *entry = [[[GDataEntryPhotoUser alloc] init] autorelease];

  [entry setNamespaces:[GDataEntryPhotoUser photoNamespaces]];
  
  return entry;
}

#pragma mark -

+ (void)load {
  [GDataObject registerEntryClass:[self class]
            forCategoryWithScheme:nil 
                             term:kGDataCategoryPhotosUser];
}

- (void)initExtensionDeclarations {
  
  [super initExtensionDeclarations];
  
  // common photo extensions
  Class entryClass = [self class];
  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataPhotoMaxPhotosPerAlbum class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataPhotoNickname class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataPhotoQuotaLimit class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataPhotoQuotaUsed class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataPhotoThumbnail class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataPhotoUser class]];
}

- (id)init {
  self = [super init];
  if (self) {
    [self addCategory:[GDataCategory categoryWithScheme:kGDataCategoryScheme
                                                   term:kGDataCategoryPhotosUser]];
  }
  return self;
}

- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  [self addToArray:items objectDescriptionIfNonNil:[self maxPhotosPerAlbum] withName:@"maxPhotosPerAlbum"];
  [self addToArray:items objectDescriptionIfNonNil:[self nickname] withName:@"nickname"];
  [self addToArray:items objectDescriptionIfNonNil:[self quotaLimit] withName:@"quotaLimit"];
  [self addToArray:items objectDescriptionIfNonNil:[self quotaUsed] withName:@"quotaUsed"];
  [self addToArray:items objectDescriptionIfNonNil:[self thumbnail] withName:@"thumbnail"];
  [self addToArray:items objectDescriptionIfNonNil:[self username] withName:@"username"];
  
  return items;
}

#pragma mark -

- (NSNumber *)maxPhotosPerAlbum { // long long
  GDataPhotoMaxPhotosPerAlbum *obj = [self objectForExtensionClass:[GDataPhotoMaxPhotosPerAlbum class]];
  return [obj longLongNumberValue];
}

- (void)setMaxPhotosPerAlbum:(NSNumber *)num {
  GDataPhotoMaxPhotosPerAlbum *obj = [GDataPhotoMaxPhotosPerAlbum valueWithNumber:num];
  [self setObject:obj forExtensionClass:[GDataPhotoMaxPhotosPerAlbum class]];  
}

- (NSString *)nickname {
  GDataPhotoNickname *obj = [self objectForExtensionClass:[GDataPhotoNickname class]];
  return [obj stringValue];
}

- (void)setNickname:(NSString *)str {
  GDataPhotoNickname *obj = [GDataPhotoNickname valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataPhotoNickname class]];  
}

- (NSString *)thumbnail {
  GDataPhotoThumbnail *obj = [self objectForExtensionClass:[GDataPhotoThumbnail class]];
  return [obj stringValue];
}

- (void)setThumbnail:(NSString *)str {
  GDataPhotoThumbnail *obj = [GDataPhotoThumbnail valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataPhotoThumbnail class]];  
}

- (NSNumber *)quotaLimit { // long long
  GDataPhotoQuotaLimit *obj = [self objectForExtensionClass:[GDataPhotoQuotaLimit class]];
  return [obj longLongNumberValue];
}

- (void)setQuotaLimit:(NSNumber *)num {
  GDataPhotoQuotaLimit *obj = [GDataPhotoQuotaLimit valueWithNumber:num];
  [self setObject:obj forExtensionClass:[GDataPhotoQuotaLimit class]];  
}

- (NSNumber *)quotaUsed { // long long
  GDataPhotoQuotaUsed *obj = [self objectForExtensionClass:[GDataPhotoQuotaUsed class]];
  return [obj longLongNumberValue];
}

- (void)setQuotaUsed:(NSNumber *)num {
  GDataPhotoQuotaUsed *obj = [GDataPhotoQuotaUsed valueWithNumber:num];
  [self setObject:obj forExtensionClass:[GDataPhotoQuotaUsed class]];  
}

- (NSString *)username {
  GDataPhotoUser *obj = [self objectForExtensionClass:[GDataPhotoUser class]];
  return [obj stringValue];
}

- (void)setUsername:(NSString *)str {
  GDataPhotoUser *obj = [GDataPhotoUser valueWithString:str];
  [self setObject:obj forExtensionClass:[obj class]];  
}


@end
