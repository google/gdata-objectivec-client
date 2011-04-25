/* Copyright (c) 2011 Google Inc.
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
//  GDataEntryFreeBusy.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE

#import "GDataEntryFreeBusy.h"

@implementation GDataCalendarWhen
- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataWhen class]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"when", @"when", kGDataDescValueLabeled },
    { nil, nil, (GDataDescRecTypes)0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

#pragma mark -

- (GDataWhen *)when {
  return [self objectForExtensionClass:[GDataWhen class]];
}

- (void)setWhen:(GDataWhen *)obj {
  [self setObject:obj forExtensionClass:[GDataWhen class]];
}

@end

@implementation GDataCalendarTimeRange
+ (NSString *)extensionElementURI       { return kGDataNamespaceGCal; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGCalPrefix; }
+ (NSString *)extensionElementLocalName { return @"timeRange"; }
@end

@implementation GDataCalendarBusy
+ (NSString *)extensionElementURI       { return kGDataNamespaceGCal; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGCalPrefix; }
+ (NSString *)extensionElementLocalName { return @"busy"; }
@end

@implementation GDataEntryFreeBusy

+ (NSString *)standardKindAttributeValue {
  return @"calendar#freebusy";
}

+ (void)load {
  [self registerEntryClass];
}

@end

@implementation GDataEntryGroupFreeBusy

+ (NSString *)standardKindAttributeValue {
  return @"calendar#groupFreebusy";
}

+ (void)load {
  [self registerEntryClass];
}

@end

@implementation GDataEntryFreeBusyBase

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                 childClasses:
   [GDataCalendarTimeRange class],
   [GDataCalendarBusy class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"timeRange", @"timeRange", kGDataDescValueLabeled },
    { @"busies",    @"busies",    kGDataDescArrayDescs },
    { nil, nil, (GDataDescRecTypes)0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

+ (NSString *)defaultServiceVersion {
  return kGDataCalendarDefaultServiceVersion;
}

#pragma mark -

- (GDataCalendarTimeRange *)timeRange {
  return [self objectForExtensionClass:[GDataCalendarTimeRange class]];
}

- (void)setTimeRange:(GDataCalendarTimeRange *)obj {
  [self setObject:obj forExtensionClass:[GDataCalendarTimeRange class]];
}

- (NSArray *)busies {
  return [self objectsForExtensionClass:[GDataCalendarBusy class]];
}

- (void)setBusies:(NSArray *)arr {
  [self setObjects:arr forExtensionClass:[GDataCalendarBusy class]];
}

- (void)addBusy:(GDataCalendarBusy *)obj {
  [self addObject:obj forExtensionClass:[GDataCalendarBusy class]];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE
