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

#import <Cocoa/Cocoa.h>

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

// http://code.google.com/apis/calendar/reference.html#Elements  Says:
// "accessLevel must be one of the following:"
_EXTERN NSString* kGDataCalendarAccessNone _INITIALIZE_AS(@"none");
_EXTERN NSString* kGDataCalendarAccessRead _INITIALIZE_AS(@"read");
_EXTERN NSString* kGDataCalendarAccessFreeBusy _INITIALIZE_AS(@"freebusy");
_EXTERN NSString* kGDataCalendarAccessContributor _INITIALIZE_AS(@"contributor");
_EXTERN NSString* kGDataCalendarAccessOwner _INITIALIZE_AS(@"owner");

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

- (GDataValueConstruct *)timeZoneName;
- (void)setTimeZoneName:(GDataValueConstruct *)theString;

- (GDataValueConstruct *)overrideName;
- (void)setOverrideName:(GDataValueConstruct *)theString;

- (GDataValueConstruct *)accessLevel;
- (void)setAccessLevel:(GDataValueConstruct *)accessLevel;

- (NSArray *)whens;
- (void)setWhens:(NSArray *)array;
- (void)addWhen:(GDataWhen *)obj;

- (NSArray *)locations; // GDWhere objects
- (void)setLocations:(NSArray *)array;
- (void)addLocation:(GDataWhere *)obj;
@end
