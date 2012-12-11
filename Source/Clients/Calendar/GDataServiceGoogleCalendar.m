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
//  GDataServiceGoogleCalendar.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE

#define GDATASERVICEGOOGLECALENDAR_DEFINE_GLOBALS 1
#import "GDataServiceGoogleCalendar.h"

#import "GDataEntryCalendar.h"


@implementation GDataServiceGoogleCalendar

+ (NSURL *)calendarFeedURLForUsername:(NSString *)username {

  // the calendar feed is the base feed plus the username
  NSString *usernameEscaped = [GDataUtilities stringByURLEncodingForURI:username];

  NSString *rootURLString = [self serviceRootURLString];

  NSString *feedURLString = [rootURLString stringByAppendingString:usernameEscaped];

  NSURL *url = [NSURL URLWithString:feedURLString];
  return url;
}

+ (NSURL *)settingsFeedURLForUsername:(NSString *)username {

  NSString *usernameEscaped = [GDataUtilities stringByURLEncodingForURI:username];

  NSString *rootURLString = [self serviceRootURLString];

  NSString *const templateStr = @"%@%@/settings";

  NSString *feedURLString = [NSString stringWithFormat:templateStr,
                             rootURLString, usernameEscaped];

  NSURL *url = [NSURL URLWithString:feedURLString];
  return url;
}

+ (NSURL *)freeBusyURLForUsername:(NSString *)username {

  NSString *usernameEscaped = [GDataUtilities stringByURLEncodingForURI:username];

  NSString *rootURLString = [self serviceRootURLString];

  NSString *const templateStr = @"%@default/freebusy/busy-times/%@";

  NSString *feedURLString = [NSString stringWithFormat:templateStr,
                             rootURLString, usernameEscaped];

  NSURL *url = [NSURL URLWithString:feedURLString];
  return url;
}

+ (NSURL *)freeBusyURLForGroup:(NSString *)groupname {

  NSString *nameEscaped = [GDataUtilities stringByURLEncodingForURI:groupname];

  NSString *rootURLString = [self serviceRootURLString];

  NSString *const templateStr = @"%@default/freebusy/group/%@/busy-times";

  NSString *feedURLString = [NSString stringWithFormat:templateStr,
                             rootURLString, nameEscaped];

  NSURL *url = [NSURL URLWithString:feedURLString];
  return url;
}

- (GDataServiceTicket *)fetchCalendarFeedForUsername:(NSString *)username
                                            delegate:(id)delegate
                                   didFinishSelector:(SEL)finishedSelector {
  NSURL *url = [[self class] calendarFeedURLForUsername:username];

  return [self fetchFeedWithURL:url
                       delegate:delegate
              didFinishSelector:finishedSelector];
}

#pragma mark -

+ (NSString *)serviceID {
  return @"cl";
}

+ (NSString *)serviceRootURLString {
  return @"https://www.google.com/calendar/feeds/"; 
}

+ (NSString *)authorizationScope {
  // avoid Calendar's "Unknown authorization header" error by specifying a
  // non-https scope
  return @"http://www.google.com/calendar/feeds/"; 
}

+ (NSString *)defaultServiceVersion {
  return kGDataCalendarDefaultServiceVersion;
}

+ (NSDictionary *)standardServiceNamespaces {
  return [GDataEntryCalendar calendarNamespaces];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE
