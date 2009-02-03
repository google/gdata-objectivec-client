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
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataNamespaceGCal _INITIALIZE_AS(@"http://schemas.google.com/gCal/2005");
_EXTERN NSString* const kGDataNamespaceGCalPrefix _INITIALIZE_AS(@"gCal");


// CalendarEventEntry extensions
@interface GDataPrivateCopyProperty : GDataBoolValueConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataQuickAddProperty : GDataBoolValueConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataSendEventNotifications : GDataBoolValueConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataResourceProperty : GDataBoolValueConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataSyncEventProperty : GDataBoolValueConstruct <GDataExtension>
// sync scenario, where iCal UID and sequence number are honored during
// insert and update
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataSequenceProperty : GDataValueConstruct <GDataExtension>
// GData schema extension describing sequence number of an event.
// The sequence number is a non-negative integer and is described in
// section 4.8.7.4 of RFC 2445.
// Currently this is only a read-only entry.
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataICalUIDProperty : GDataValueConstruct <GDataExtension>
// GData schema extension describing the UID in the ical export of the event.
// The value can be an arbitrary string and is described in section 4.8.4.7
// of RFC 2445. This value is different from the value of the event ID.
// Currently a read-only entry.
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

// CalendarEventEntry categories for extensions
@interface GDataWho (GDataCalendarEntryEventExtensions)
- (NSArray *)resourceProperties;
- (void)setResourceProperties:(NSArray *)arr;
- (void)addResourceProperty:(GDataResourceProperty *)obj;
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

// for sync events, the iCal UID and sequence number need to be honored
- (BOOL)isSyncEvent;
- (void)setIsSyncEvent:(BOOL)flag;  

- (NSString *)iCalUID;
- (void)setICalUID:(NSString *)str;

- (NSNumber *)sequenceNumber; // int
- (void)setSequenceNumber:(NSNumber *)num;

- (NSArray *)extendedProperties;
- (void)setExtendedProperties:(NSArray *)arr;
- (void)addExtendedProperty:(GDataExtendedProperty *)obj;

- (GDataLink *)webContentLink;
- (GDataWebContent *)webContent;
@end
