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
                                   childClass:[GDataYouTubeUsername class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataYouTubeQueryString class]];

}

- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
//  [self addToArray:items objectDescriptionIfNonNil:[self rating] withName:@"rating"];

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
  
  NSArray *categories = [self categories];
  
  NSArray *subs = [categories categoriesWithScheme:kGDataSchemeYouTubeSubscription];
  
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

@end
