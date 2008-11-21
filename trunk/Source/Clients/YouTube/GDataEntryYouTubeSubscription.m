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
//  GDataEntryYouTubeSubscription.m
//

#import "GDataEntryYouTubeSubscription.h"
#import "GDataEntryYouTubeVideo.h"
#import "GDataYouTubeElements.h"

@implementation GDataEntryYouTubeSubscription

+ (GDataEntryYouTubeSubscription *)subscriptionEntry {
  
  GDataEntryYouTubeSubscription *entry = [[[self alloc] init] autorelease];

  [entry setNamespaces:[GDataEntryYouTubeVideo youTubeNamespaces]];
  
  return entry;
}

#pragma mark -

+ (void)load {
  [GDataObject registerEntryClass:[self class]
            forCategoryWithScheme:nil 
                             term:kGDataCategoryYouTubeSubscription];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];
  
  // YouTube element extensions
  [self addExtensionDeclarationForParentClass:entryClass
                                 childClasses:
   [GDataYouTubeUsername class],
   [GDataYouTubeQueryString class],
   [GDataYouTubePlaylistID class],
   [GDataYouTubePlaylistTitle class],
   nil];
  
}

- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  [self addToArray:items objectDescriptionIfNonNil:[self username] withName:@"username"];
  [self addToArray:items objectDescriptionIfNonNil:[self youTubeQueryString] withName:@"query"];
  [self addToArray:items objectDescriptionIfNonNil:[self playlistID] withName:@"playlistID"];
  [self addToArray:items objectDescriptionIfNonNil:[self playlistTitle] withName:@"playlistTitle"];

  return items;
}

- (id)init {
  self = [super init];
  if (self) {
    [self addCategory:[GDataCategory categoryWithScheme:kGDataCategoryScheme
                                                   term:kGDataCategoryYouTubeSubscription]];
  }
  return self;
}

#pragma mark -

- (NSString *)subscriptionType {
  
  NSArray *subs;
  
  subs = [self categoriesWithScheme:kGDataSchemeYouTubeSubscription];
  
  if ([subs count] > 0) {
    GDataCategory *subscription = [subs objectAtIndex:0];
    NSString *term = [subscription term];
    return term;
  }
  return nil;
}

#pragma mark -

- (NSString *)username {
  GDataYouTubeUsername *obj = [self objectForExtensionClass:[GDataYouTubeUsername class]];
  return [obj stringValue];
}

- (void)setUsername:(NSString *)str {
  GDataYouTubeUsername *obj = [GDataYouTubeUsername valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeUsername class]];
}

- (NSString *)youTubeQueryString {
  GDataYouTubeQueryString *obj = [self objectForExtensionClass:[GDataYouTubeQueryString class]];
  return [obj stringValue];
}

- (void)setYouTubeQueryString:(NSString *)str {
  GDataYouTubeQueryString *obj = [GDataYouTubeQueryString valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeQueryString class]];
}

- (NSString *)playlistID {
  GDataYouTubePlaylistID *obj = [self objectForExtensionClass:[GDataYouTubePlaylistID class]];
  return [obj stringValue];
}

- (void)setPlaylistID:(NSString *)str {
  GDataYouTubePlaylistID *obj = [GDataYouTubePlaylistID valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubePlaylistID class]];
}

- (NSString *)playlistTitle {
  GDataYouTubePlaylistTitle *obj;

  obj = [self objectForExtensionClass:[GDataYouTubePlaylistTitle class]];
  return [obj stringValue];
}

- (void)setPlaylistTitle:(NSString *)str {
  GDataYouTubePlaylistTitle *obj;

  obj = [GDataYouTubePlaylistTitle valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubePlaylistTitle class]];
}


@end
