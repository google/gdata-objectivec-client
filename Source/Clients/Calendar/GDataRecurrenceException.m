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
//  GDataRecurrenceException.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE

#import "GDataRecurrenceException.h"

#import "GDataOriginalEvent.h"
#import "GDataEntryLink.h"

@implementation GDataRecurrenceException
// a gd:recurrenceException link, possibly containing an entryLink or 
// an originalEvent
//<gd:recurrenceException specialized="true">
//  <gd:entryLink>
//     <entry>
//   ...
// http://code.google.com/apis/gdata/common-elements.html#gdRecurrenceException

+ (NSString *)extensionElementURI       { return kGDataNamespaceGData; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementLocalName { return @"recurrenceException"; }

+ (GDataRecurrenceException *)recurrenceExceptionWithEntryLink:(GDataEntryLink *)entryLink
                                                 originalEvent:(GDataOriginalEvent *)originalEvent
                                                 isSpecialized:(BOOL)isSpecialized {
  GDataRecurrenceException *obj = [self object];
  [obj setEntryLink:entryLink];
  [obj setOriginalEvent:originalEvent];
  [obj setIsSpecialized:isSpecialized];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setIsSpecialized:[self boolForAttributeName:@"specialized"
                                          fromElement:element]];
    [self setEntryLink:[self objectForChildOfElement:element
                                       qualifiedName:@"gd:entryLink"
                                        namespaceURI:kGDataNamespaceGData
                                         objectClass:[GDataEntryLink class]]];
    [self setOriginalEvent:[self objectForChildOfElement:element
                                           qualifiedName:@"gd:originalEvent"
                                            namespaceURI:kGDataNamespaceGData
                                             objectClass:[GDataOriginalEvent class]]];
  }
  return self;
}

- (void)dealloc {
  [entryLink_ release];
  [originalEvent_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataRecurrenceException* newRecurrence = [super copyWithZone:zone];
  [newRecurrence setIsSpecialized:[self isSpecialized]];
  [newRecurrence setEntryLink:[[[self entryLink] copyWithZone:zone] autorelease]];
  [newRecurrence setOriginalEvent:[[[self originalEvent] copyWithZone:zone] autorelease]];
  return newRecurrence;
}

- (BOOL)isEqual:(GDataRecurrenceException *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataRecurrenceException class]]) return NO;
  
  return [super isEqual:other]
    && AreBoolsEqual([self isSpecialized], [other isSpecialized])
    && AreEqualOrBothNil([self entryLink], [other entryLink])
    && AreEqualOrBothNil([self originalEvent], [other originalEvent]);
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  if ([self isSpecialized]) {
    [self addToArray:items objectDescriptionIfNonNil:@"true" withName:@"specialized"];
  }
  [self addToArray:items objectDescriptionIfNonNil:entryLink_ withName:@"entryLink"];
  [self addToArray:items objectDescriptionIfNonNil:originalEvent_ withName:@"originalEvent"];
  
  return items;
}
#endif

- (NSXMLElement *)XMLElement {

  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"gd:recurrenceException"];
  
  if ([self isSpecialized]) {
    [self addToElement:element attributeValueIfNonNil:@"true" withName:@"specialized"];
  }  
  
  if ([self entryLink]) {
    [element addChild:[[self entryLink] XMLElement]];
  }
  
  if ([self originalEvent]) {
    [element addChild:[[self originalEvent] XMLElement]];
  }
  
  return element;
}

- (BOOL)isSpecialized {
  return isSpecialized_; 
}

- (void)setIsSpecialized:(BOOL)isSpecialized {
  isSpecialized_ = isSpecialized; 
}

- (GDataEntryLink *)entryLink {
  return entryLink_; 
}

- (void)setEntryLink:(GDataEntryLink *)entryLink {
  [entryLink_ autorelease];
  entryLink_ = [entryLink retain];
}

- (GDataOriginalEvent *)originalEvent {
  return originalEvent_; 
}

- (void)setOriginalEvent:(GDataOriginalEvent *)originalEvent {
  [originalEvent_ autorelease]; 
  originalEvent_ = [originalEvent retain];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE
