/* Copyright (c) 2007-2008 Google Inc.
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

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE

#define GDATAREMINDER_DEFINE_GLOBALS 1
#import "GDataReminder.h"
#import "GDataDateTime.h"

static NSString* const kDaysAttr = @"days";
static NSString* const kHoursAttr = @"hours";
static NSString* const kMinutesAttr = @"minutes";
static NSString* const kMethodAttr = @"method";
static NSString* const kAbsoluteTimeAttr = @"absoluteTime";


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

- (void)addParseDeclarations {
  NSArray *attrs = [NSArray arrayWithObjects: 
                    kDaysAttr, kHoursAttr, kMinutesAttr, 
                    kAbsoluteTimeAttr, kMethodAttr, nil];
  
  [self addLocalAttributeDeclarations:attrs];
}

#pragma mark -

- (NSString *)days {
  return [self stringValueForAttribute:kDaysAttr];
}

- (void)setDays:(NSString *)str {
  [self setStringValue:str forAttribute:kDaysAttr];
}

- (NSString *)hours {
  return [self stringValueForAttribute:kHoursAttr];
}

- (void)setHours:(NSString *)str {
  [self setStringValue:str forAttribute:kHoursAttr];
}

- (NSString *)minutes {
  return [self stringValueForAttribute:kMinutesAttr];
}

- (void)setMinutes:(NSString *)str {
  [self setStringValue:str forAttribute:kMinutesAttr];
}

- (NSString *)method {
  return [self stringValueForAttribute:kMethodAttr];
}

- (void)setMethod:(NSString *)str {
  [self setStringValue:str forAttribute:kMethodAttr];
}

- (GDataDateTime *)absoluteTime {
  return [self dateTimeForAttribute:kAbsoluteTimeAttr];
}

- (void)setAbsoluteTime:(GDataDateTime *)cdate {
  [self setDateTimeValue:cdate forAttribute:kAbsoluteTimeAttr];
}
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE
