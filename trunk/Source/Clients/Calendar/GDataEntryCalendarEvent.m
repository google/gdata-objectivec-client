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
//  GDataEntryCalendarEvent.m
//

#define GDATACALENDAREVENT_DEFINE_GLOBALS 1

#import "GDataWebContent.h"
#import "GDataEntryCalendarEvent.h"
#import "GDataEntryCalendar.h"
#import "GDataExtendedProperty.h"
#import "GDataCategory.h"

// extensions

// CalendarEventEntry extensions
@implementation GDataSendEventNotifications 
+ (NSString *)extensionElementURI       { return kGDataNamespaceGCal; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGCalPrefix; }
+ (NSString *)extensionElementLocalName { return @"sendEventNotifications"; }
@end

@implementation GDataPrivateCopyProperty 
+ (NSString *)extensionElementURI       { return kGDataNamespaceGCal; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGCalPrefix; }
+ (NSString *)extensionElementLocalName { return @"privateCopy"; }
@end

@implementation GDataQuickAddProperty
+ (NSString *)extensionElementURI       { return kGDataNamespaceGCal; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGCalPrefix; }
+ (NSString *)extensionElementLocalName { return @"quickadd"; }
@end

@implementation GDataResourceProperty
+ (NSString *)extensionElementURI       { return kGDataNamespaceGCal; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGCalPrefix; }
+ (NSString *)extensionElementLocalName { return @"resource"; }
@end

@implementation GDataSyncEventProperty 
+ (NSString *)extensionElementURI       { return kGDataNamespaceGCal; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGCalPrefix; }
+ (NSString *)extensionElementLocalName { return @"syncEvent"; }
@end

@implementation GDataSequenceProperty 
+ (NSString *)extensionElementURI       { return kGDataNamespaceGCal; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGCalPrefix; }
+ (NSString *)extensionElementLocalName { return @"sequence"; }
@end

@implementation GDataICalUIDProperty 
+ (NSString *)extensionElementURI       { return kGDataNamespaceGCal; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGCalPrefix; }
+ (NSString *)extensionElementLocalName { return @"uid"; }
@end

@implementation GDataGuestsCanModifyProperty
+ (NSString *)extensionElementURI       { return kGDataNamespaceGCal; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGCalPrefix; }
+ (NSString *)extensionElementLocalName { return @"guestsCanModify"; }
@end

@implementation GDataGuestsCanInviteOthersProperty
+ (NSString *)extensionElementURI       { return kGDataNamespaceGCal; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGCalPrefix; }
+ (NSString *)extensionElementLocalName { return @"guestsCanInviteOthers"; }
@end

@implementation GDataGuestsCanSeeGuestsProperty
+ (NSString *)extensionElementURI       { return kGDataNamespaceGCal; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGCalPrefix; }
+ (NSString *)extensionElementLocalName { return @"guestsCanSeeGuests"; }
@end

@implementation GDataAnyoneCanAddSelfProperty
+ (NSString *)extensionElementURI       { return kGDataNamespaceGCal; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGCalPrefix; }
+ (NSString *)extensionElementLocalName { return @"anyoneCanAddSelf"; }
@end

// CalendarEventEntry categories for extensions
@implementation GDataWho (GDataCalendarEntryEventExtensions)
- (NSArray *)resourceProperties {
  return [self objectsForExtensionClass:[GDataResourceProperty class]];
}

- (void)setResourceProperties:(NSArray *)arr {
  [self setObjects:arr forExtensionClass:[GDataResourceProperty class]];
}

- (void)addResourceProperty:(GDataResourceProperty *)obj {
  [self addObject:obj forExtensionClass:[GDataResourceProperty class]];
}
@end

@implementation GDataLink (GDataCalendarEntryEventExtensions)
- (NSArray *)webContents {
  return [self objectsForExtensionClass:[GDataWebContent class]];
}

- (void)setWebContents:(NSArray *)arr {
  [self setObjects:arr forExtensionClass:[GDataWebContent class]];
}

- (void)addWebContent:(GDataWebContent *)obj {
  [self addObject:obj forExtensionClass:[GDataWebContent class]];
}
@end

@implementation GDataEntryCalendarEvent

+ (NSDictionary *)calendarEventNamespaces {
  
  NSMutableDictionary *namespaces = [NSMutableDictionary dictionaryWithDictionary:
    [GDataEntryBase baseGDataNamespaces]];
  
  [namespaces setObject:kGDataNamespaceGCal forKey:kGDataNamespaceGCalPrefix];
  return namespaces;
}

+ (GDataEntryCalendarEvent *)calendarEvent {
  GDataEntryCalendarEvent *entry = [[[GDataEntryCalendarEvent alloc] init] autorelease];
  
  [entry setNamespaces:[GDataEntryCalendar calendarNamespaces]];
  return entry;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategoryEvent;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  Class entryClass = [self class];

  // CalendarEventEntry extensions
  [self addExtensionDeclarationForParentClass:entryClass
                                 childClasses:
   [GDataSendEventNotifications class],
   [GDataPrivateCopyProperty class],
   [GDataQuickAddProperty class],
   [GDataExtendedProperty class],
   [GDataSyncEventProperty class],
   [GDataSequenceProperty class],
   [GDataICalUIDProperty class],
   [GDataGuestsCanModifyProperty class],
   [GDataGuestsCanInviteOthersProperty class],
   [GDataGuestsCanSeeGuestsProperty class],
   [GDataAnyoneCanAddSelfProperty class],
   nil];
  
  [self addExtensionDeclarationForParentClass:[GDataWho class]
                                   childClass:[GDataResourceProperty class]];
  [self addExtensionDeclarationForParentClass:[GDataLink class]
                                   childClass:[GDataWebContent class]];

  [GDataGeo addGeoExtensionDeclarationsToObject:self
                                 forParentClass:entryClass];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  static struct GDataDescriptionRecord descRecs[] = {
    { @"sendEventNotifications", @"shouldSendEventNotifications", kGDataDescBooleanPresent },
    { @"privateCopy",            @"isPrivateCopy",                kGDataDescBooleanPresent },
    { @"quickAdd",               @"isQuickAdd",                   kGDataDescBooleanPresent },
    { @"syncEvent",              @"isSyncEvent",                  kGDataDescBooleanPresent },
    { @"iCalUID",                @"iCalUID",                      kGDataDescValueLabeled   },
    { @"sequenceNumber",         @"sequenceNumber",               kGDataDescValueLabeled   },
    { @"webContent",             @"webContent.URLString",         kGDataDescValueLabeled   },
    { @"guestsCanModify",        @"canGuestsModify",              kGDataDescBooleanPresent },
    { @"guestsCanInvite",        @"canGuestsInviteOthers",        kGDataDescBooleanPresent },
    { @"guestsCanSeeGuests",     @"canGuestsSeeGuests",           kGDataDescBooleanPresent },
    { @"anyoneCanAddSelf",       @"canAnyoneAddSelf",             kGDataDescBooleanPresent },
    { @"geo",                    @"geoLocation.coordinateString", kGDataDescValueLabeled   },
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

#pragma mark Actual iVars
- (BOOL)shouldSendEventNotifications {
  GDataBoolValueConstruct *obj = (GDataBoolValueConstruct *)
    [self objectForExtensionClass:[GDataSendEventNotifications class]];
  return [obj boolValue];
}

// it is ambiguous whether this defaults to TRUE or FALSE, so just always
// create the extension, to be sure.
- (void)setShouldSendEventNotifications:(BOOL)flag {
  GDataBoolValueConstruct *obj = [GDataSendEventNotifications boolValueWithBool:flag]; 
  [self setObject:obj forExtensionClass:[GDataSendEventNotifications class]];
}

- (BOOL)isPrivateCopy {
  GDataBoolValueConstruct *obj =
    [self objectForExtensionClass:[GDataPrivateCopyProperty class]];
  return [obj boolValue];
}

- (void)setIsPrivateCopy:(BOOL)flag {
  GDataBoolValueConstruct *obj;
  if (flag) {
    obj = [GDataPrivateCopyProperty boolValueWithBool:YES];
  } else {
    obj = nil; // removes the extension
  }
  [self setObject:obj forExtensionClass:[GDataPrivateCopyProperty class]];
}

- (BOOL)isQuickAdd {
  GDataBoolValueConstruct *obj =
    [self objectForExtensionClass:[GDataQuickAddProperty class]];
  return [obj boolValue];
}

- (void)setIsQuickAdd:(BOOL)flag {
  GDataBoolValueConstruct *obj;
  if (flag) {
    obj = [GDataQuickAddProperty boolValueWithBool:YES];
  } else {
    obj = nil; // removes the extension
  }
  [self setObject:obj forExtensionClass:[GDataQuickAddProperty class]];
}

- (BOOL)isSyncEvent {
  GDataBoolValueConstruct *obj = [self objectForExtensionClass:[GDataSyncEventProperty class]];
  return [obj boolValue];
}

- (void)setIsSyncEvent:(BOOL)flag {
  GDataBoolValueConstruct *obj;
  if (flag) {
    obj = [GDataSyncEventProperty boolValueWithBool:YES];
  } else {
    obj = nil; // removes the extension
  }
  [self setObject:obj forExtensionClass:[GDataSyncEventProperty class]];
}

- (NSString *)iCalUID {
  GDataICalUIDProperty *obj = [self objectForExtensionClass:[GDataICalUIDProperty class]];
  return [obj stringValue];
}

- (void)setICalUID:(NSString *)str {
  GDataICalUIDProperty *obj;
  if ([str length] > 0) {
    obj = [GDataICalUIDProperty valueWithString:str];
  } else {
    obj = nil; 
  }
  [self setObject:obj forExtensionClass:[GDataICalUIDProperty class]];
}

- (BOOL)canGuestsModify { // default NO
  GDataBoolValueConstruct *obj;

  obj = [self objectForExtensionClass:[GDataGuestsCanModifyProperty class]];
  return [obj boolValue];
}

- (void)setCanGuestsModify:(BOOL)flag {
  GDataBoolValueConstruct *obj;
  if (flag) {
    obj = [GDataGuestsCanModifyProperty boolValueWithBool:YES];
  } else {
    obj = nil; // removes the extension
  }
  [self setObject:obj forExtensionClass:[GDataGuestsCanModifyProperty class]];
}

- (BOOL)canGuestsInviteOthers { // default YES
  GDataBoolValueConstruct *obj;

  obj = [self objectForExtensionClass:[GDataGuestsCanInviteOthersProperty class]];
  if (obj) return [obj boolValue];

  return YES;
}

- (void)setCanGuestsInviteOthers:(BOOL)flag {
  GDataBoolValueConstruct *obj;
  if (flag) {
    obj = nil; // removes the extension
  } else {
    obj = [GDataGuestsCanInviteOthersProperty boolValueWithBool:NO];
  }
  [self setObject:obj forExtensionClass:[GDataGuestsCanInviteOthersProperty class]];
}

- (BOOL)canGuestsSeeGuests { // default YES
  GDataBoolValueConstruct *obj;

  obj = [self objectForExtensionClass:[GDataGuestsCanSeeGuestsProperty class]];
  if (obj) return [obj boolValue];

  return YES;
}

- (void)setCanGuestsSeeGuests:(BOOL)flag {
  GDataBoolValueConstruct *obj;
  if (flag) {
    obj = nil; // removes the extension
  } else {
    obj = [GDataGuestsCanSeeGuestsProperty boolValueWithBool:NO];
  }
  [self setObject:obj forExtensionClass:[GDataGuestsCanSeeGuestsProperty class]];
}

- (BOOL)canAnyoneAddSelf { // default NO
  GDataBoolValueConstruct *obj;

  obj = [self objectForExtensionClass:[GDataAnyoneCanAddSelfProperty class]];
  return [obj boolValue];
}

- (void)setCanAnyoneAddSelf:(BOOL)flag {
  GDataBoolValueConstruct *obj;
  if (flag) {
    obj = [GDataAnyoneCanAddSelfProperty boolValueWithBool:YES];
  } else {
    obj = nil; // removes the extension
  }
  [self setObject:obj forExtensionClass:[GDataAnyoneCanAddSelfProperty class]];
}

- (GDataGeo *)geoLocation {
  return [GDataGeo geoLocationForObject:self];
}

- (void)setGeoLocation:(GDataGeo *)geo {
  [GDataGeo setGeoLocation:geo forObject:self];
}

- (NSNumber *)sequenceNumber {
  GDataSequenceProperty *obj = [self objectForExtensionClass:[GDataSequenceProperty class]];
  return [obj intNumberValue];
}

- (void)setSequenceNumber:(NSNumber *)num {
  GDataSequenceProperty *obj;
  if (num != nil) {
    obj = [GDataSequenceProperty valueWithNumber:num];
  } else {
    obj = nil; 
  }
  [self setObject:obj forExtensionClass:[GDataSequenceProperty class]];
}

- (NSArray *)extendedProperties {
  return [self objectsForExtensionClass:[GDataExtendedProperty class]];
}

- (void)setExtendedProperties:(NSArray *)arr {
  [self setObjects:arr forExtensionClass:[GDataExtendedProperty class]];
}

- (void)addExtendedProperty:(GDataExtendedProperty *)obj {
  [self addObject:obj forExtensionClass:[GDataExtendedProperty class]];
}

- (GDataLink *)webContentLink {
  NSArray *links = [self links];

  GDataLink *webContentLink;
  webContentLink = [GDataLink linkWithRelAttributeValue:kGDataLinkRelWebContent
                                              fromLinks:links];

  return webContentLink;
}

- (GDataWebContent *)webContent {
  GDataLink *dataLink = [self webContentLink];
  GDataWebContent *content = (GDataWebContent *) [dataLink objectForExtensionClass:[GDataWebContent class]];
  return content;
}

// to set web content, create a GDataLink and call addWebContent on it
@end
