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
//  GDataOriginalEvent.m
//

#import "GDataOriginalEvent.h"
#import "GDataWhen.h"

@implementation GDataOriginalEvent
// original event element, as in
// <gd:originalEvent id="i8fl1nrv2bl57c1qgr3f0onmgg"
//         href="http://www.google.com/calendar/feeds/userID/private-magicCookie/full/eventID">
//         <gd:when startTime="2006-03-17T22:00:00.000Z"/>
// </gd:originalEvent>
//
// http://code.google.com/apis/gdata/common-elements.html#gdOriginalEvent

+ (NSString *)extensionElementURI       { return kGDataNamespaceGData; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementLocalName { return @"originalEvent"; }

+ (GDataOriginalEvent *)originalEventWithID:(NSString *)originalID
                                       href:(NSString *)feedHref
                          originalStartTime:(GDataWhen *)startTime {
  
  GDataOriginalEvent *obj = [[[GDataOriginalEvent alloc] init] autorelease];
  [obj setHref:feedHref];
  [obj setOriginalID:originalID];
  [obj setOriginalStartTime:startTime];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setHref:[self stringForAttributeName:@"href"
                                   fromElement:element]];
    [self setOriginalID:[self stringForAttributeName:@"id"
                                         fromElement:element]];
    
    [self setOriginalStartTime:[self objectForChildOfElement:element
                                               qualifiedName:@"gd:when"
                                                namespaceURI:kGDataNamespaceGData
                                                 objectClass:[GDataWhen class]]];
  }
  return self;
}

- (void)dealloc {
  [href_ release];
  [originalID_ release];
  [originalStartTime_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataOriginalEvent* newEvent = [super copyWithZone:zone];
  [newEvent setHref:href_];
  [newEvent setOriginalID:originalID_];
  [newEvent setOriginalStartTime:originalStartTime_];
  return newEvent;
}

- (BOOL)isEqual:(GDataOriginalEvent *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataOriginalEvent class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self href], [other href])
    && AreEqualOrBothNil([self originalID], [other originalID])
    && AreEqualOrBothNil([self originalStartTime], [other originalStartTime]);
}

- (NSString *)description {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:href_      withName:@"href"];
  [self addToArray:items objectDescriptionIfNonNil:originalID_  withName:@"id"];
  [self addToArray:items objectDescriptionIfNonNil:originalStartTime_ withName:@"startTime"];
  
  return [NSString stringWithFormat:@"%@ 0x%lX: {%@}",
    [self class], self, [items componentsJoinedByString:@" "]];
}

- (NSXMLElement *)XMLElement {

  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"gd:originalEvent"];
  
  [self addToElement:element attributeValueIfNonNil:[self href] withName:@"href"];
  [self addToElement:element attributeValueIfNonNil:[self originalID] withName:@"id"];
  
  if (originalStartTime_) {
    NSXMLNode *startTimeElement = [originalStartTime_ XMLElement];
    [element addChild:startTimeElement];
  }
    
  return element;
}


- (NSString *)href {
  return href_; 
}
- (void)setHref:(NSString *)str {
  [href_ autorelease];
  href_ = [str copy];
}

- (NSString *)originalID {
  return originalID_;
}

- (void)setOriginalID:(NSString *)str {
  [originalID_ autorelease]; 
  originalID_ = [str copy];
}

- (GDataWhen *)originalStartTime {
  return originalStartTime_; 
}

- (void)setOriginalStartTime:(GDataWhen *)startTime {
  [originalStartTime_ autorelease];  
  originalStartTime_ = [startTime retain];
}
@end
