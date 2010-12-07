/* Copyright (c) 2009 Google Inc.
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
//  GDataEntryCalendarSettings.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE

#import "GDataEntryCalendarSettings.h"
#import "GDataEntryCalendar.h"
#import "GDataEntryCalendarEvent.h"

// extensions
#import "GDataCalendarSettingsProperty.h"

@implementation GDataEntryCalendarSettings

+ (NSString *)standardKindAttributeValue {
  return @"calendar#settings";
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataCalendarSettingsProperty class]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"name",  @"settingsProperty.name",  kGDataDescValueLabeled },
    { @"value", @"settingsProperty.value", kGDataDescValueLabeled },
    { nil, nil, 0 }
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

- (GDataCalendarSettingsProperty *)settingsProperty {
  return [self objectForExtensionClass:[GDataCalendarSettingsProperty class]];
}

- (void)setSettingsProperty:(GDataCalendarSettingsProperty *)obj {
  [self setObject:obj forExtensionClass:[GDataCalendarSettingsProperty class]];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE
