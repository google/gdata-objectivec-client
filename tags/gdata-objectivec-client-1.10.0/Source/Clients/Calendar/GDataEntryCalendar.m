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
//  GDataEntryCalendar.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE

#define GDATAENTRYCALENDAR_DEFINE_GLOBALS 1
#import "GDataEntryCalendar.h"

// extensions

#import "GDataTextConstruct.h"
#import "GDataWhen.h"
#import "GDataWhere.h"
#import "GDataEntryCalendarEvent.h"
#import "GDataGeo.h"

// CalendarEntry extensions
@implementation GDataHiddenProperty 
+ (NSString *)extensionElementURI       { return kGDataNamespaceGCal; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGCalPrefix; }
+ (NSString *)extensionElementLocalName { return @"hidden"; }
@end

@implementation GDataAccessLevelProperty 
+ (NSString *)extensionElementURI       { return kGDataNamespaceGCal; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGCalPrefix; }
+ (NSString *)extensionElementLocalName { return @"accesslevel"; }
@end

@implementation GDataSelectedProperty 
+ (NSString *)extensionElementURI       { return kGDataNamespaceGCal; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGCalPrefix; }
+ (NSString *)extensionElementLocalName { return @"selected"; }
@end

@implementation GDataOverrideNameProperty 
+ (NSString *)extensionElementURI       { return kGDataNamespaceGCal; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGCalPrefix; }
+ (NSString *)extensionElementLocalName { return @"overridename"; }
@end

@implementation GDataTimesCleanedProperty
+ (NSString *)extensionElementURI       { return kGDataNamespaceGCal; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGCalPrefix; }
+ (NSString *)extensionElementLocalName { return @"timesCleaned"; }
@end

@implementation GDataTimeZoneProperty
+ (NSString *)extensionElementURI       { return kGDataNamespaceGCal; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGCalPrefix; }
+ (NSString *)extensionElementLocalName { return @"timezone"; }
@end

@implementation GDataColorProperty
+ (NSString *)extensionElementURI       { return kGDataNamespaceGCal; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGCalPrefix; }
+ (NSString *)extensionElementLocalName { return @"color"; }
@end

@implementation GDataEntryCalendar

+ (NSDictionary *)calendarNamespaces {
  NSMutableDictionary *namespaces = [NSMutableDictionary dictionaryWithDictionary:
    [GDataEntryBase baseGDataNamespaces]];

  [namespaces setObject:kGDataNamespaceGCal forKey:kGDataNamespaceGCalPrefix];
  
  [namespaces addEntriesFromDictionary:[GDataGeo geoNamespaces]]; // geo, georss, gml

  return namespaces;
}

+ (GDataEntryCalendar *)calendarEntry {
  GDataEntryCalendar *entry = [[[GDataEntryCalendar alloc] init] autorelease];

  [entry setNamespaces:[GDataEntryCalendar calendarNamespaces]];
  return entry;
}

#pragma mark -

+ (NSString *)standardKindAttributeValue {
  return @"calendar#calendar";
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];
  
  
  // Calendar extensions
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClasses:
   [GDataAccessLevelProperty class],
   [GDataColorProperty class],
   [GDataHiddenProperty class],
   [GDataOverrideNameProperty class],
   [GDataSelectedProperty class],
   [GDataTimeZoneProperty class],
   [GDataTimesCleanedProperty class],
   [GDataWhen class],  // are whens really a property of calendars? Java has the extension but not the accessor
   [GDataWhere class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"timezone",     @"timeZoneName.stringValue",  kGDataDescValueLabeled },
    { @"timesCleaned", @"timesCleaned.stringValue",  kGDataDescValueLabeled },
    { @"override",     @"overrideName.stringValue",  kGDataDescValueLabeled },
    { @"accessLevel",  @"accessLevel.stringValue",   kGDataDescValueLabeled },
    { @"hidden",       @"isHidden",                  kGDataDescBooleanPresent },
    { @"selected",     @"isSelected",                kGDataDescBooleanPresent },
    { @"whens",        @"whens",                     kGDataDescArrayCount },
    { @"hidden",       @"locations",                 kGDataDescArrayCount },
    { nil, nil, 0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

- (NSString *)description {
  return [super description];
}

+ (NSString *)defaultServiceVersion {
  return kGDataCalendarDefaultServiceVersion;
}

#pragma mark Actual iVars

- (GDataColorProperty *)color {
  return [self objectForExtensionClass:[GDataColorProperty class]];
}

- (void)setColor:(GDataColorProperty *)val {
  [self setObject:val forExtensionClass:[GDataColorProperty class]];
}

- (BOOL)isHidden {
  GDataBoolValueConstruct *obj = [self objectForExtensionClass:[GDataHiddenProperty class]];
  return [obj boolValue];
}

- (void)setIsHidden:(BOOL)flag {
  GDataBoolValueConstruct *obj;
  if (flag) {
    obj = [GDataHiddenProperty boolValueWithBool:YES];
  } else {
    obj = nil; // removes the extension
  }
  [self setObject:obj forExtensionClass:[GDataHiddenProperty class]];
}

- (BOOL)isSelected {
  GDataBoolValueConstruct *obj = [self objectForExtensionClass:[GDataSelectedProperty class]];
  return [obj boolValue];
}

- (void)setIsSelected:(BOOL)flag {
  GDataBoolValueConstruct *obj;
  if (flag) {
    obj = [GDataSelectedProperty boolValueWithBool:YES];
  } else {
    obj = nil; // removes the extension
  }
  [self setObject:obj forExtensionClass:[GDataSelectedProperty class]];
}

- (GDataAccessLevelProperty *)accessLevel {
  return [self objectForExtensionClass:[GDataAccessLevelProperty class]];
}

- (void)setAccessLevel:(GDataAccessLevelProperty *)val {
  [self setObject:val forExtensionClass:[GDataAccessLevelProperty class]];
}

- (GDataTimeZoneProperty *)timeZoneName {
  return [self objectForExtensionClass:[GDataTimeZoneProperty class]];
}

- (void)setTimeZoneName:(GDataTimeZoneProperty *)val {
  [self setObject:val forExtensionClass:[GDataTimeZoneProperty class]];
}

- (NSNumber *)timesCleaned { // int
  GDataTimesCleanedProperty *obj;

  obj = [self objectForExtensionClass:[GDataTimesCleanedProperty class]];
  return [obj intNumberValue];
}

- (void)setTimesCleaned:(NSNumber *)num {
  GDataTimesCleanedProperty *obj;

  obj = [GDataTimesCleanedProperty valueWithNumber:num];
  [self setObject:obj forExtensionClass:[GDataTimesCleanedProperty class]];
}

- (GDataOverrideNameProperty *)overrideName {
  return [self objectForExtensionClass:[GDataOverrideNameProperty class]];
}

- (void)setOverrideName:(GDataOverrideNameProperty *)val {
  [self setObject:val forExtensionClass:[GDataOverrideNameProperty class]];
}

- (NSArray *)whens {
  return [self objectsForExtensionClass:[GDataWhen class]];
}

- (void)setWhens:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataWhen class]];
}

- (void)addWhen:(GDataWhen *)obj {
  [self addObject:obj forExtensionClass:[obj class]]; 
}

- (NSArray *)locations {
  return [self objectsForExtensionClass:[GDataWhere class]];
}

- (void)setLocations:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataWhere class]];
}

- (void)addLocation:(GDataWhere *)obj {
  [self addObject:obj forExtensionClass:[obj class]]; 
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE
