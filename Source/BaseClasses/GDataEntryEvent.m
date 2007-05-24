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

- (void)addReminders:(GDataReminder *)obj {
  [self addObject:obj forExtensionClass:[GDataReminder class]];
}
@end

@implementation GDataEntryEvent

- (void)initExtensionDeclarations {
  
  [super initExtensionDeclarations];
  
  Class entryClass = [self class];
  
  // EventEntry extensions
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataRecurrenceException class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataReminder class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataRecurrence class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataWhere class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataEventStatus class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataVisibility class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataTransparency class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataWho class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataWhen class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataOriginalEvent class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataComment class]];  
  
  // a reminder may be at the event entry level (declared above) for
  // recurrence events, or inside a GDataWhen for single events
  [self addExtensionDeclarationForParentClass:[GDataWhen class]
                                   childClass:[GDataReminder class]];  
}

- (NSString *)suffixAfterPoundSign:(NSString *)str {
  NSRange range = [str rangeOfString:@"#" options:NSBackwardsSearch];
  if (range.location != NSNotFound) {
    return [str substringFromIndex:(1 + range.location)];
  }
  return nil;
}

- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  [self addToArray:items objectDescriptionIfNonNil:[[self recurrence] stringValue] withName:@"recurrence"];
  
  if ([self visibility]) {
    NSString *visibility = [self suffixAfterPoundSign:[[self visibility] stringValue]];
    [self addToArray:items objectDescriptionIfNonNil:visibility withName:@"visibility"];
  }

  if ([self transparency]) {
    NSString *transparency = [self suffixAfterPoundSign:[[self transparency] stringValue]];
    [self addToArray:items objectDescriptionIfNonNil:transparency withName:@"transparency"];
  }

  if ([self eventStatus]) {
    NSString *eventStatus = [self suffixAfterPoundSign:[[self eventStatus] stringValue]];
    [self addToArray:items objectDescriptionIfNonNil:eventStatus withName:@"eventStatus"];
  }
    
  [self addToArray:items arrayCountIfNonEmpty:[self times] withName:@"times"];
  [self addToArray:items arrayCountIfNonEmpty:[self recurrenceExceptions] withName:@"recurrenceExceptions"];
  [self addToArray:items arrayCountIfNonEmpty:[self reminders] withName:@"reminders"];
  

  if ([self comment]) {
    [items addObject:@"hasComment"];
  }
  
  return items;
}

- (NSString *)description {
  return [super description];
}

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

- (NSArray *)reminders {
  if ([self recurrence] != nil) {
    // for recurrence events, reminders are at the top level
    return [self objectsForExtensionClass:[GDataReminder class]];
  } else {
    // for regular events, reminders are inside the When objects
    NSArray *whens = [self times];
    if ([whens count] > 0) {
      GDataWhen *when = [whens objectAtIndex:0];
      NSArray *reminders = [when objectsForExtensionClass:[GDataReminder class]];
      return reminders;
    }
  }
  return nil;
}

- (void)setReminders:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataReminder class]];
}

- (void)addReminder:(GDataReminder *)obj {
  [self addObject:obj forExtensionClass:[obj class]];
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
