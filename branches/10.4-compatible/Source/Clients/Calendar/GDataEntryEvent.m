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
//  GDataEntryEvent.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE

#define GDATAENTRYEVENT_DEFINE_GLOBALS 1
#import "GDataEntryEvent.h"

#import "GDataTextConstruct.h"

// extensions

// EventEntry extensions

// These extensions are just subclasses of GDataValueConstruct.
// We're creating them as unique subclasses so they can exist
// separately in the extensions list, which stores found extensions
// by class.

@implementation GDataEventStatus
+ (NSString *)extensionElementURI       { return kGDataNamespaceGData; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementLocalName { return @"eventStatus"; }
@end

@implementation GDataVisibility
+ (NSString *)extensionElementURI       { return kGDataNamespaceGData; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementLocalName { return @"visibility"; }
@end

@implementation GDataTransparency
+ (NSString *)extensionElementURI       { return kGDataNamespaceGData; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementLocalName { return @"transparency"; }
@end

// We're defining Reminders as extensions to When elements.
// This category on When elements will simpify access to those
// reminders that are found inside When elements.

@implementation GDataWhen (GDataCalendarEntryEventExtensions)
- (NSArray *)reminders {
  return [self objectsForExtensionClass:[GDataReminder class]];
}

- (void)setReminders:(NSArray *)arr {
  [self setObjects:arr forExtensionClass:[GDataReminder class]];
}

- (void)addReminder:(GDataReminder *)obj {
  [self addObject:obj forExtensionClass:[GDataReminder class]];
}
@end

@implementation GDataEntryEvent

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];
  
  // EventEntry extensions
  [self addExtensionDeclarationForParentClass:entryClass
                                 childClasses:
   [GDataRecurrenceException class], [GDataReminder class],
   [GDataRecurrence class], [GDataWhere class],
   [GDataEventStatus class], [GDataVisibility class],
   [GDataTransparency class], [GDataWho class],
   [GDataWhen class], [GDataOriginalEvent class],
   [GDataComment class], nil];  
  
  // a reminder may be at the event entry level (declared above) for
  // recurrence events, or inside a GDataWhen for single events
  [self addExtensionDeclarationForParentClass:[GDataWhen class]
                                   childClass:[GDataReminder class]];  
}

- (NSString *)suffixAfterPoundSign:(NSString *)str {
  if (str != nil) {
    NSRange range = [str rangeOfString:@"#" options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
      return [str substringFromIndex:(1 + range.location)];
    }
  }
  return nil;
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  NSString *visibility = [self suffixAfterPoundSign:[[self visibility] stringValue]];
  NSString *transparency = [self suffixAfterPoundSign:[[self transparency] stringValue]];
  NSString *eventStatus = [self suffixAfterPoundSign:[[self eventStatus] stringValue]];

  NSArray *times = [self times];
  NSUInteger numberOfTimes = [times count];
  NSString *timesStr;
  if (numberOfTimes == 1) {
    GDataWhen *when = [times objectAtIndex:0];
    timesStr = [NSString stringWithFormat:@"(%@..%@)",
                [[when startTime] stringValue], [[when endTime] stringValue]];
  } else {
    // just show the number of times, pretty rare
    timesStr = [NSString stringWithFormat:@"%lu", (unsigned long) numberOfTimes];
  }

  struct GDataDescriptionRecord descRecs[] = {
    { @"recurrence",     @"recurrence.stringValue", kGDataDescValueLabeled },
    { @"visibility",     visibility,                kGDataDescValueIsKeyPath },
    { @"transparency",   transparency,              kGDataDescValueIsKeyPath },
    { @"eventStatus",    eventStatus,               kGDataDescValueIsKeyPath },
    { @"times",          timesStr,                  kGDataDescValueIsKeyPath },
    { @"recExc",         @"recurrenceExceptions",   kGDataDescArrayCount },
    { @"reminders",      @"reminders",              kGDataDescArrayCount },
    { @"comment",        @"comment",                kGDataDescLabelIfNonNil },
    { nil, nil, (GDataDescRecTypes)0 }
  };
  
  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

#pragma mark Actual iVars

- (GDataEventStatus *)eventStatus {
  return (GDataEventStatus *) [self objectForExtensionClass:[GDataEventStatus class]];
}

- (void)setEventStatus:(GDataEventStatus *)val {
  [self setObject:val forExtensionClass:[GDataEventStatus class]];
}

- (GDataTransparency *)transparency {
  return (GDataTransparency *) [self objectForExtensionClass:[GDataTransparency class]];
}

- (void)setTransparency:(GDataTransparency *)val {
  [self setObject:val forExtensionClass:[GDataTransparency class]];
}

- (GDataVisibility *)visibility {
  return (GDataVisibility *) [self objectForExtensionClass:[GDataVisibility class]];
}

- (void)setVisibility:(GDataVisibility *)val {
  [self setObject:val forExtensionClass:[GDataVisibility class]];
}

- (GDataRecurrence *)recurrence {
  return (GDataRecurrence *) [self objectForExtensionClass:[GDataRecurrence class]];
}

- (void)setRecurrence:(GDataRecurrence *)obj {
  BOOL hadRecurrence = ([self recurrence] != nil);
  BOOL willHaveRecurrence = (obj != nil);
  
  if (hadRecurrence && !willHaveRecurrence) {
    [self setNonRecurrenceReminders:[self recurrenceReminders]];
    [self setRecurrenceReminders:nil];
  } else if (!hadRecurrence && willHaveRecurrence) {
    [self setRecurrenceReminders:[self nonRecurrenceReminders]];
    [self setNonRecurrenceReminders:nil];
  }
  
  [self setObject:obj forExtensionClass:[GDataRecurrence class]];
}

- (NSArray *)recurrenceExceptions {
  return [self objectsForExtensionClass:[GDataRecurrenceException class]];
}

- (void)setRecurrenceExceptions:(NSArray *)arr {
  [self setObjects:arr forExtensionClass:[GDataRecurrenceException class]];
}

- (void)addRecurrenceException:(GDataRecurrenceException *)obj {
  [self addObject:obj forExtensionClass:[obj class]];
}

- (GDataOriginalEvent *)originalEvent {
  return (GDataOriginalEvent *) [self objectForExtensionClass:[GDataOriginalEvent class]];
}

- (void)setOriginalEvent:(GDataOriginalEvent *)obj {
  [self setObject:obj forExtensionClass:[GDataOriginalEvent class]];
}

- (GDataComment *)comment {
  return (GDataComment *) [self objectForExtensionClass:[GDataComment class]];
}

- (void)setComment:(GDataComment *)obj {
  [self setObject:obj forExtensionClass:[GDataComment class]];
}

- (NSArray *)recurrenceReminders {
    return [self objectsForExtensionClass:[GDataReminder class]];
}

- (void)setRecurrenceReminders:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataReminder class]];
}

- (void)addRecurrenceReminder:(GDataReminder *)obj {
  [self addObject:obj forExtensionClass:[GDataReminder class]];
}

- (NSArray *)nonRecurrenceReminders {
  NSArray *whens = [self times];
  if ([whens count] > 0) {
    GDataWhen *when = [whens objectAtIndex:0];
    NSArray *reminders = [when objectsForExtensionClass:[GDataReminder class]];
    return reminders;
  }
  return nil;
}

- (void)setNonRecurrenceReminders:(NSArray *)array {
  NSArray *whens = [self times];
  if ([whens count] > 0) {
    GDataWhen *when = [whens objectAtIndex:0];
    [when setReminders:array];
  }
}

- (void)addNonRecurrenceReminder:(GDataReminder *)obj {
  NSArray *whens = [self times];
  if ([whens count] > 0) {
    GDataWhen *when = [whens objectAtIndex:0];
    [when addReminder:obj];
  } 
}

- (NSArray *)reminders {
  if ([self recurrence] != nil) {
    return [self recurrenceReminders];
  } else {
    return [self nonRecurrenceReminders];
  }
  return nil;
}

- (void)setReminders:(NSArray *)array {
  if ([self recurrence] != nil) {
    [self setRecurrenceReminders:array];
  } else {
    [self setNonRecurrenceReminders:array];
  }
}

- (void)addReminder:(GDataReminder *)obj {
  if ([self recurrence] != nil) {
    [self addRecurrenceReminder:obj];
  } else {
    [self addNonRecurrenceReminder:obj];
  }
}

- (NSArray *)times {
  return [self objectsForExtensionClass:[GDataWhen class]];
}

- (void)setTimes:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataWhen class]];
}

- (void)addTime:(GDataWhen *)obj {
  [self addObject:obj forExtensionClass:[obj class]];
}

- (NSArray *)participants {
  return [self objectsForExtensionClass:[GDataWho class]];
}

- (void)setParticipants:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataWho class]];
}

- (void)addParticipant:(GDataWho *)obj {
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
