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
//  GDataEntryEvent.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE

#import "GDataEntryBase.h"
#import "GDataLink.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAENTRYEVENT_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataCategoryEvent _INITIALIZE_AS(@"http://schemas.google.com/g/2005#event");

_EXTERN NSString* const kGDataEventStatusConfirmed _INITIALIZE_AS(@"http://schemas.google.com/g/2005#event.confirmed");
_EXTERN NSString* const kGDataEventStatusTentative _INITIALIZE_AS(@"http://schemas.google.com/g/2005#event.tentative");
_EXTERN NSString* const kGDataEventStatusCanceled _INITIALIZE_AS(@"http://schemas.google.com/g/2005#event.canceled");

_EXTERN NSString* const kGDataEventTransparencyTransparent _INITIALIZE_AS(@"http://schemas.google.com/g/2005#event.transparent");
_EXTERN NSString* const kGDataEventTransparencyOpaque _INITIALIZE_AS(@"http://schemas.google.com/g/2005#event.opaque");

_EXTERN NSString* const kGDataEventVisibilityDefault _INITIALIZE_AS(@"http://schemas.google.com/g/2005#event.default");
_EXTERN NSString* const kGDataEventVisibilityPublic _INITIALIZE_AS(@"http://schemas.google.com/g/2005#event.public");
_EXTERN NSString* const kGDataEventVisibilityPrivate _INITIALIZE_AS(@"http://schemas.google.com/g/2005#event.private");
_EXTERN NSString* const kGDataEventVisibilityConfidential _INITIALIZE_AS(@"http://schemas.google.com/g/2005#event.confidental");


#import "GDataValueConstruct.h"
#import "GDataWhen.h"

#import "GDataReminder.h"
#import "GDataRecurrence.h"
#import "GDataRecurrenceException.h"
#import "GDataOriginalEvent.h"
#import "GDataComment.h"
#import "GDataWhere.h"
#import "GDataWho.h"

// EventEntry extensions

// These extensions are just subclasses of GDataValueConstruct.
// We're creating them as unique subclasses so they can exist
// separately in the extensions list, which stores found extensions
// by class.

@interface GDataEventStatus : GDataValueConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataVisibility : GDataValueConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataTransparency : GDataValueConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

// EventEntry categories for extensions

// We're defining Reminders as extensions to When elements.
// This category on When elements will simpify access to those
// reminders that are found inside When elements.

@interface GDataWhen (GDataCalendarEntryEventExtensions)
- (NSArray *)reminders;
- (void)setReminders:(NSArray *)arr;
- (void)addReminder:(GDataReminder *)obj;
@end

@interface GDataEntryEvent : GDataEntryBase {
}

// a side-effect of calling setRecurrence is to switch reminder elements
// between recurrence (in the event) and non-recurrence (in the first 
// event time)
- (GDataRecurrence *)recurrence;
- (void)setRecurrence:(GDataRecurrence *)obj;

- (NSArray *)recurrenceExceptions;
- (void)setRecurrenceExceptions:(NSArray *)arr;
- (void)addRecurrenceException:(GDataRecurrenceException *)obj;

- (GDataOriginalEvent *)originalEvent;
- (void)setOriginalEvent:(GDataOriginalEvent *)event;

- (GDataComment *)comment;
- (void)setComment:(GDataComment *)event;

// these reminder methods will call the recurrence or non-recurrence
// methods depending on the presence of a recurrence element
- (NSArray *)reminders;
- (void)setReminders:(NSArray *)array;
- (void)addReminder:(GDataReminder *)obj;

- (NSArray *)recurrenceReminders;
- (void)setRecurrenceReminders:(NSArray *)array;
- (void)addRecurrenceReminder:(GDataReminder *)obj;

- (NSArray *)nonRecurrenceReminders;
- (void)setNonRecurrenceReminders:(NSArray *)array;
- (void)addNonRecurrenceReminder:(GDataReminder *)obj;

- (GDataEventStatus *)eventStatus;
- (void)setEventStatus:(GDataEventStatus *)eventStatus;

- (GDataTransparency *)transparency;
- (void)setTransparency:(GDataTransparency *)str;

- (GDataVisibility *)visibility;
- (void)setVisibility:(GDataVisibility *)str;

- (NSArray *)times;
- (void)setTimes:(NSArray *)array;
- (void)addTime:(GDataWhen *)obj;

- (NSArray *)participants;
- (void)setParticipants:(NSArray *)array;
- (void)addParticipant:(GDataWho *)obj;

- (NSArray *)locations;
- (void)setLocations:(NSArray *)array;
- (void)addLocation:(GDataWhere *)obj;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE
