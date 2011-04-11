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
//  GDataEntryCalendarEvent.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE

#import "GDataEntryEvent.h"
#import "GDataWho.h"
#import "GDataLink.h"
#import "GDataExtendedProperty.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATACALENDAREVENT_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN GDATA_EXTERN
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataNamespaceGCal       _INITIALIZE_AS(@"http://schemas.google.com/gCal/2005");
_EXTERN NSString* const kGDataNamespaceGCalPrefix _INITIALIZE_AS(@"gCal");

_EXTERN NSString* const kGDataCategoryCalendar         _INITIALIZE_AS(@"http://schemas.google.com/gCal/2005#calendarmeta");
_EXTERN NSString* const kGDataCategoryCalendarSettings _INITIALIZE_AS(@"http://schemas.google.com/gCal/2005#settings");

// CalendarEventEntry extensions
@interface GDataResourceProperty : GDataBoolValueConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

// CalendarEventEntry categories for extensions
@interface GDataWho (GDataCalendarEntryEventExtensions)
- (NSArray *)resourceProperties;
- (void)setResourceProperties:(NSArray *)arr;
- (void)addResourceProperty:(GDataResourceProperty *)obj;

- (NSNumber *)numberOfAdditionalGuests; // int
- (void)setNumberOfAdditionalGuests:(NSNumber *)num;
@end

@class GDataWebContent;
@interface GDataLink (GDataCalendarEntryEventExtensions)
- (NSArray *)webContents;
- (void)setWebContents:(NSArray *)arr;  
- (void)addWebContent:(GDataWebContent *)obj;
@end


@interface GDataEntryCalendarEvent : GDataEntryEvent

+ (NSDictionary *)calendarEventNamespaces;

+ (GDataEntryCalendarEvent *)calendarEvent;

- (BOOL)shouldSendEventNotifications;
- (void)setShouldSendEventNotifications:(BOOL)flag;

- (BOOL)isPrivateCopy;
- (void)setIsPrivateCopy:(BOOL)flag;

- (BOOL)isQuickAdd;
- (void)setIsQuickAdd:(BOOL)flag;

- (NSString *)suppressReplyNotificationTypes;
- (void)setSuppressReplyNotificationTypes:(NSString *)str;

// for sync events, the iCal UID and sequence number need to be honored
- (BOOL)isSyncEvent;
- (void)setIsSyncEvent:(BOOL)flag;  

- (NSString *)iCalUID;
- (void)setICalUID:(NSString *)str;

- (BOOL)canGuestsModify; // default NO
- (void)setCanGuestsModify:(BOOL)flag;

- (BOOL)canGuestsInviteOthers; // default YES
- (void)setCanGuestsInviteOthers:(BOOL)flag;

- (BOOL)canGuestsSeeGuests; // default YES
- (void)setCanGuestsSeeGuests:(BOOL)flag;

- (BOOL)canAnyoneAddSelf; // default NO
- (void)setCanAnyoneAddSelf:(BOOL)flag;

- (NSNumber *)sequenceNumber; // int
- (void)setSequenceNumber:(NSNumber *)num;

- (NSArray *)extendedProperties;
- (void)setExtendedProperties:(NSArray *)arr;
- (void)addExtendedProperty:(GDataExtendedProperty *)obj;

- (GDataLink *)webContentLink;
- (GDataWebContent *)webContent;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE
