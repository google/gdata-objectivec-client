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
//  GDataEntryMessage.m
//

#define GDATAENTRYMESSAGE_DEFINE_GLOBALS 1
#import "GDataEntryMessage.h"

@implementation GDataEntryMessage

+ (GDataEntryMessage *)message {
  GDataEntryMessage *entry = [[[GDataEntryMessage alloc] init] autorelease];
  
  [entry setNamespaces:[GDataEntryBase baseGDataNamespaces]];

  return entry;
}

#pragma mark -

+ (void)load {
  [GDataObject registerEntryClass:[self class]
            forCategoryWithScheme:kGDataCategoryScheme 
                             term:kGDataMessage];
}


- (void)initExtensionDeclarations {
  
  [super initExtensionDeclarations];
  
  Class entryClass = [self class];
  
  // EntryMessage extensions
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataWhen class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataRating class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataGeoPt class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataWho class]];  
  
}

- (id)init {
  self = [super init];
  if (self) {
    // use the standard message category
    GDataCategory *category = [GDataCategory categoryWithScheme:kGDataCategoryScheme
                                                           term:kGDataMessage];
    [self addCategory:category];
  }
  return self;
}


- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  [self addToArray:items objectDescriptionIfNonNil:[self rating] withName:@"rating"];
  [self addToArray:items objectDescriptionIfNonNil:[self time] withName:@"time"];
  [self addToArray:items objectDescriptionIfNonNil:[self geoPt] withName:@"geoPt"];
  
  NSArray *participants = participants;
  if ([participants count] == 1) {
    [self addToArray:items objectDescriptionIfNonNil:[participants objectAtIndex:0] withName:@"participants"];
  } else {
    [self addToArray:items arrayCountIfNonEmpty:participants withName:@"participants"];
  }
  
  return items;
}

#pragma mark -

- (GDataRating *)rating {
  return (GDataRating *) [self objectForExtensionClass:[GDataRating class]];
}

- (void)setRating:(GDataRating *)obj {
  [self setObject:obj forExtensionClass:[GDataRating class]]; 
}

- (GDataWhen *)time {
  return (GDataWhen *) [self objectForExtensionClass:[GDataWhen class]];
}

- (void)setTime:(GDataWhen *)obj {
  [self setObject:obj forExtensionClass:[GDataWhen class]]; 
}

- (GDataGeoPt *)geoPt {
  return (GDataGeoPt *) [self objectForExtensionClass:[GDataGeoPt class]];
}

- (void)setGeoPt:(GDataGeoPt *)obj {
  [self setObject:obj forExtensionClass:[GDataGeoPt class]]; 
}

- (NSArray *)participants {
  return [self objectsForExtensionClass:[GDataWho class]];
}

- (void)setParticipants:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataWho class]]; 
}

- (void)addParticipant:(GDataWho *)obj {
  [self addObject:obj forExtensionClass:[GDataWho class]]; 
}

@end
