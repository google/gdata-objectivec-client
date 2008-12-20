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

#import "GDataEntryCalendar.h"
#import "GDataEntryCalendarEvent.h"
#import "GDataFeedCalendarEvent.h"

@class GDataTimeZoneProperty;

@class GDataEntryCalendarEvent;

@implementation GDataFeedCalendarEvent

+ (GDataFeedCalendarEvent *)calendarEventFeedWithXMLData:(NSData *)data {
  return [[[self alloc] initWithData:data] autorelease];
}

+ (GDataFeedCalendarEvent *)calendarEventFeed {
  GDataFeedCalendarEvent *feed = [[[self alloc] init] autorelease];
  [feed setNamespaces:[GDataEntryCalendar calendarNamespaces]];
  return feed;
}

#pragma mark -

+ (void)load {
  [GDataObject registerFeedClass:[self class]
           forCategoryWithScheme:kGDataCategoryScheme 
                            term:kGDataCategoryEvent];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class feedClass = [self class];
  [self addExtensionDeclarationForParentClass:feedClass
                                   childClass:[GDataTimeZoneProperty class]];  
}

- (Class)classForEntries {
  return [GDataEntryCalendarEvent class];
}

+ (NSString *)defaultServiceVersion {
  return kGDataCalendarDefaultServiceVersion;
}

#pragma mark -

- (GDataTimeZoneProperty *)timeZoneName {
  return (GDataTimeZoneProperty *) [self objectForExtensionClass:[GDataTimeZoneProperty class]];
}

- (void)setTimeZoneName:(GDataTimeZoneProperty *)val {
 [self setObject:val forExtensionClass:[GDataTimeZoneProperty class]];
}
@end
