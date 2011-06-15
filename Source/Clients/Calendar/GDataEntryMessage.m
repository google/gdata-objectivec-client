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

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE

#define GDATAENTRYMESSAGE_DEFINE_GLOBALS 1
#import "GDataEntryMessage.h"

@implementation GDataEntryMessage

+ (GDataEntryMessage *)message {
  GDataEntryMessage *entry = [self object];
  
  [entry setNamespaces:[GDataEntryBase baseGDataNamespaces]];

  return entry;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataMessage;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];
  
  // EntryMessage extensions
  [self addExtensionDeclarationForParentClass:entryClass
                                 childClasses:
   [GDataWhen class],
   [GDataRating class],
   [GDataGeoPt class],
   [GDataWho class],
   nil];  
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"rating",       @"rating",       kGDataDescValueLabeled },
    { @"time",         @"time",         kGDataDescValueLabeled },
    { @"geoPt",        @"geoPt",        kGDataDescValueLabeled },
    { @"participants", @"participants", kGDataDescArrayCount },
    { nil, nil, (GDataDescRecTypes)0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

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

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE
