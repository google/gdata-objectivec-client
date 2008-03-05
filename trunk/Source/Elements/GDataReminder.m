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
//  GDataReminder.m
//

#define GDATAREMINDER_DEFINE_GLOBALS 1
#import "GDataReminder.h"
#import "GDataDateTime.h"

@implementation GDataReminder
// reminder, as in 
//   <gd:reminder absoluteTime="2005-06-06T16:55:00-08:00"/>
//
// http://code.google.com/apis/gdata/common-elements.html#gdReminder

+ (NSString *)extensionElementURI       { return kGDataNamespaceGData; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementLocalName { return @"reminder"; }

+ (GDataReminder *)reminder {
  return [[[GDataReminder alloc] init] autorelease];
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setDays:[self stringForAttributeName:@"days"
                                   fromElement:element]];
    [self setHours:[self stringForAttributeName:@"hours"
                                    fromElement:element]];
    [self setMinutes:[self stringForAttributeName:@"minutes"
                                      fromElement:element]];
    [self setMethod:[self stringForAttributeName:@"method"
                                      fromElement:element]];
    
    NSString *str = [self stringForAttributeName:@"absoluteTime"
                                     fromElement:element];
    if (str) {
      GDataDateTime *ctime = [GDataDateTime dateTimeWithRFC3339String:str];
      [self setAbsoluteTime:ctime];
    }
  }
  return self;
}

- (void)dealloc {
  [absoluteTime_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataReminder* newReminder = [super copyWithZone:zone];
  [newReminder setDays:[self days]];
  [newReminder setHours:[self hours]];
  [newReminder setMinutes:[self minutes]];
  [newReminder setMethod:[self method]];
  [newReminder setAbsoluteTime:[[[self absoluteTime] copyWithZone:zone] autorelease]];
  return newReminder;
}

- (BOOL)isEqual:(GDataReminder *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataReminder class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self days], [other days])
    && AreEqualOrBothNil([self hours], [other hours])
    && AreEqualOrBothNil([self minutes], [other minutes])
    && AreEqualOrBothNil([self method], [other method])
    && AreEqualOrBothNil([self absoluteTime], [other absoluteTime]);
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  if (days_)         [self addToArray:items objectDescriptionIfNonNil:days_    withName:@"days"];
  else if (hours_)   [self addToArray:items objectDescriptionIfNonNil:hours_   withName:@"hours"];
  else if (minutes_) [self addToArray:items objectDescriptionIfNonNil:minutes_ withName:@"minutes"];
  else [self addToArray:items objectDescriptionIfNonNil:absoluteTime_ withName:@"absolute"];
  
  [self addToArray:items objectDescriptionIfNonNil:method_ withName:@"method"];

  return items;
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"gd:reminder"];
  
  [self addToElement:element attributeValueIfNonNil:[self days] withName:@"days"];
  [self addToElement:element attributeValueIfNonNil:[self hours] withName:@"hours"];
  [self addToElement:element attributeValueIfNonNil:[self minutes] withName:@"minutes"];
  [self addToElement:element attributeValueIfNonNil:[self method] withName:@"method"];

  [self addToElement:element attributeValueIfNonNil:[[self absoluteTime] RFC3339String] withName:@"absoluteTime"];
    
  return element;
}


- (NSString *)days {
  return days_; 
}
- (void)setDays:(NSString *)str {
  [days_ autorelease];
  days_ = [str copy]; 
}
- (NSString *)hours {
  return hours_; 
}
- (void)setHours:(NSString *)str {
  [hours_ autorelease];
  hours_ = [str copy];
}
- (NSString *)minutes {
  return minutes_; 
}
- (void)setMinutes:(NSString *)str {
  [minutes_ autorelease];
  minutes_ = [str copy]; 
}
- (NSString *)method {
  return method_; 
}
- (void)setMethod:(NSString *)str {
  [method_ autorelease];
  method_ = [str copy]; 
}
- (GDataDateTime *)absoluteTime {
  return absoluteTime_; 
}
- (void)setAbsoluteTime:(GDataDateTime *)cdate {
  [absoluteTime_ autorelease];
  absoluteTime_ = [cdate retain];
}
@end


