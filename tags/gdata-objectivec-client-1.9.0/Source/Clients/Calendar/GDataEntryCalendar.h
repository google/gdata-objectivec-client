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
//  GDataEntryCalendar.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE

#import "GDataEntryBase.h"
#import "GDataLink.h"
#import "GDataValueConstruct.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAENTRYCALENDAR_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataCalendarDefaultServiceVersion _INITIALIZE_AS(@"2.1");

_EXTERN NSString* const kGDataExtendedPropertyRealmCalendar _INITIALIZE_AS(@"http://schemas.google.com/gCal/2005#calendar");


// http://code.google.com/apis/calendar/reference.html#Elements  Says:
// "accessLevel must be one of the following:"
_EXTERN NSString* const kGDataCalendarAccessNone        _INITIALIZE_AS(@"none");
_EXTERN NSString* const kGDataCalendarAccessRead        _INITIALIZE_AS(@"read");
_EXTERN NSString* const kGDataCalendarAccessFreeBusy    _INITIALIZE_AS(@"freebusy");
_EXTERN NSString* const kGDataCalendarAccessRespond     _INITIALIZE_AS(@"respond");
_EXTERN NSString* const kGDataCalendarAccessOverride    _INITIALIZE_AS(@"override");
_EXTERN NSString* const kGDataCalendarAccessEditor      _INITIALIZE_AS(@"editor");
_EXTERN NSString* const kGDataCalendarAccessOwner       _INITIALIZE_AS(@"owner");
_EXTERN NSString* const kGDataCalendarAccessRoot        _INITIALIZE_AS(@"root");

// GDataACLRole values
_EXTERN NSString* const kGDataRoleCalendarNone        _INITIALIZE_AS(@"none"); // no prefix
_EXTERN NSString* const kGDataRoleCalendarRead        _INITIALIZE_AS(@"http://schemas.google.com/gCal/2005#read");
_EXTERN NSString* const kGDataRoleCalendarFreeBusy    _INITIALIZE_AS(@"http://schemas.google.com/gCal/2005#freebusy");
_EXTERN NSString* const kGDataRoleCalendarRespond     _INITIALIZE_AS(@"http://schemas.google.com/gCal/2005#respond");
_EXTERN NSString* const kGDataRoleCalendarOverride    _INITIALIZE_AS(@"http://schemas.google.com/gCal/2005#override");
_EXTERN NSString* const kGDataRoleCalendarContributor _INITIALIZE_AS(@"http://schemas.google.com/gCal/2005#contributor");
_EXTERN NSString* const kGDataRoleCalendarEditor      _INITIALIZE_AS(@"http://schemas.google.com/gCal/2005#editor");
_EXTERN NSString* const kGDataRoleCalendarOwner       _INITIALIZE_AS(@"http://schemas.google.com/gCal/2005#owner");
_EXTERN NSString* const kGDataRoleCalendarRoot        _INITIALIZE_AS(@"http://schemas.google.com/gCal/2005#root");

@class GDataWhen;
@class GDataWhere;

// CalendarEntry extensions
@interface GDataHiddenProperty : GDataBoolValueConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataSelectedProperty : GDataBoolValueConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataTimesCleanedProperty : GDataValueConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataTimeZoneProperty : GDataValueConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataOverrideNameProperty : GDataValueConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataAccessLevelProperty : GDataValueConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataColorProperty : GDataValueConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataEntryCalendar : GDataEntryBase {
}

+ (NSDictionary *)calendarNamespaces;

+ (GDataEntryCalendar *)calendarEntry;

- (GDataColorProperty *)color;
- (void)setColor:(GDataColorProperty *)val;

- (BOOL)isHidden;
- (void)setIsHidden:(BOOL)flag;

- (BOOL)isSelected;
- (void)setIsSelected:(BOOL)flag;

- (GDataTimeZoneProperty *)timeZoneName;
- (void)setTimeZoneName:(GDataTimeZoneProperty *)theString;

- (NSNumber *)timesCleaned; // int
- (void)setTimesCleaned:(NSNumber *)num;

- (GDataOverrideNameProperty *)overrideName;
- (void)setOverrideName:(GDataOverrideNameProperty *)theString;

- (GDataAccessLevelProperty *)accessLevel;
- (void)setAccessLevel:(GDataAccessLevelProperty *)accessLevel;

- (NSArray *)whens;
- (void)setWhens:(NSArray *)array;
- (void)addWhen:(GDataWhen *)obj;

- (NSArray *)locations; // GDWhere objects
- (void)setLocations:(NSArray *)array;
- (void)addLocation:(GDataWhere *)obj;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE
