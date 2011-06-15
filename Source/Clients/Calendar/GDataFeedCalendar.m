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
//  GDataFeedCalendar.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE

#import "GDataEntryCalendar.h"
#import "GDataEntryCalendarEvent.h"
#import "GDataFeedCalendar.h"
#import "GDataCategory.h"

@implementation GDataFeedCalendar

+ (GDataFeedCalendar *)calendarFeedWithXMLData:(NSData *)data {
  return [self feedWithXMLData:data];
}

+ (GDataFeedCalendar *)calendarFeed {
  GDataFeedCalendar *feed = [self object];
  [feed setNamespaces:[GDataEntryCalendar calendarNamespaces]];
  return feed;
}

#pragma mark -

+ (NSString *)standardKindAttributeValue {
  return @"calendar#calendarFeed";
}

+ (void)load {
  [self registerFeedClass];
}

- (Class)classForEntries {
  return [GDataEntryCalendar class];
}

+ (NSString *)defaultServiceVersion {
  return kGDataCalendarDefaultServiceVersion;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE
