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
#define GDATAENTRYCALENDAR_DEFINE_GLOBALS 1
#import "GDataEntryCalendar.h"

// extensions

#import "GDataTextConstruct.h"
#import "GDataWhen.h"
#import "GDataWhere.h"
#import "GDataEntryCalendarEvent.h"

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
  return namespaces;
}

+ (GDataEntryCalendar *)calendarEntry {
  GDataEntryCalendar *entry = [[[GDataEntryCalendar alloc] init] autorelease];

  [entry setNamespaces:[GDataEntryCalendar calendarNamespaces]];
  return entry;
}

- (void)initExtensionDeclarations {
  
  [super initExtensionDeclarations];
  
  Class entryClass = [self class];
  
  
  // Calendar extensions
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataAccessLevelProperty class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataColorProperty class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataHiddenProperty class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataOverrideNameProperty class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataSelectedProperty class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataTimeZoneProperty class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataWhen class]];  // are whens really a property of calendars? Java has the extension but not the accessor
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataWhere class]];  
  
}

- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  [self addToArray:items objectDescriptionIfNonNil:[[self timeZoneName] stringValue] withName:@"timezone"];
  [self addToArray:items objectDescriptionIfNonNil:[[self overrideName] stringValue] withName:@"override"];
  [self addToArray:items objectDescriptionIfNonNil:[[self accessLevel] stringValue] withName:@"accessLevel"];
  
  if ([self isHidden]) {
    [items addObject:@"hidden:YES"];
  }
  
  if ([self isSelected]) {
    [items addObject:@"selected:YES"];
  }
  
  [self addToArray:items arrayCountIfNonEmpty:[self whens] withName:@"whens"];
  [self addToArray:items arrayCountIfNonEmpty:[self locations] withName:@"locations"];
  
  return items;
}

- (NSString *)description {
  return [super description];
}

#pragma mark Actual iVars

- (GDataColorProperty *)color {
  return (GDataColorProperty *) [self objectForExtensionClass:[GDataColorProperty class]];
}

- (void)setColor:(GDataColorProperty *)val {
  [self setObject:val forExtensionClass:[GDataColorProperty class]];
}

- (BOOL)isHidden {
  GDataBoolValueConstruct *obj = (GDataBoolValueConstruct *)
    [self objectForExtensionClass:[GDataHiddenProperty class]];
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
  GDataBoolValueConstruct *obj = (GDataBoolValueConstruct *)
    [self objectForExtensionClass:[GDataSelectedProperty class]];
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
  return (GDataAccessLevelProperty *) [self objectForExtensionClass:[GDataAccessLevelProperty class]];
}

- (void)setAccessLevel:(GDataAccessLevelProperty *)val {
  [self setObject:val forExtensionClass:[GDataAccessLevelProperty class]];
}

- (GDataTimeZoneProperty *)timeZoneName {
  return (GDataTimeZoneProperty *) [self objectForExtensionClass:[GDataTimeZoneProperty class]];
}

- (void)setTimeZoneName:(GDataTimeZoneProperty *)val {
  [self setObject:val forExtensionClass:[GDataTimeZoneProperty class]];
}

- (GDataOverrideNameProperty *)overrideName {
  return (GDataOverrideNameProperty *) [self objectForExtensionClass:[GDataOverrideNameProperty class]];
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
