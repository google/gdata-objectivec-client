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
//  GDataFeedYouTubeSubscription.m
//

#import "GDataFeedYouTubeSubscription.h"
#import "GDataEntryYouTubeVideo.h"

@implementation GDataFeedYouTubeSubscription

+ (GDataFeedYouTubeSubscription *)subscriptionFeed {
  
  GDataFeedYouTubeSubscription *feed = [[[self alloc] init] autorelease];
  
  [feed setNamespaces:[GDataEntryYouTubeVideo youTubeNamespaces]];
  
  return feed;
}

+ (void)load {
  [GDataObject registerFeedClass:[self class]
           forCategoryWithScheme:nil 
                            term:kGDataCategoryYouTubeSubscription];
}


- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  // no additional extensions needed for this feed
}

- (id)init {
  self = [super init];
  if (self) {
    [self addCategory:[GDataCategory categoryWithScheme:kGDataCategoryScheme
                                                   term:kGDataCategoryYouTubeSubscription]];
  }
  return self;
}


- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  return items;
}

- (Class)classForEntries {
  return kUseRegisteredEntryClass;
}

@end
