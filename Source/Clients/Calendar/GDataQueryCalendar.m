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
//  GDataQueryCalendar.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE

#import "GDataQueryCalendar.h"

// query params per
//   http://code.google.com/apis/calendar/reference.html#Parameters

static NSString *const kMinimumStartTimeParamName  = @"start-min";
static NSString *const kMaximumStartTimeParamName  = @"start-max";
static NSString *const kRecurrenceExpansionStartTimeParamName  = @"recurrence-expansion-start";
static NSString *const kRecurrenceExpansionEndTimeParamName  = @"recurrence-expansion-end";
static NSString *const kFutureEventsParamName  = @"futureevents";
static NSString *const kSingleEventsParamName = @"singleevents";
static NSString *const kCurrentTimeZoneParamName = @"ctz";
static NSString *const kShowInlineCommentsParamName = @"showinlinecomments";
static NSString *const kShowHiddenParamName = @"showhidden";
static NSString *const kMaxAttendeesParamName = @"max-attendees";

@implementation GDataQueryCalendar

+ (GDataQueryCalendar *)calendarQueryWithFeedURL:(NSURL *)feedURL {
  return [self queryWithFeedURL:feedURL];   
}

- (GDataDateTime *)minimumStartTime {
  GDataDateTime *dateTime;

  dateTime = [self dateTimeForParameterWithName:kMinimumStartTimeParamName];
  return dateTime;
}

- (void)setMinimumStartTime:(GDataDateTime *)dateTime {
  [self addCustomParameterWithName:kMinimumStartTimeParamName
                          dateTime:dateTime];
}

- (GDataDateTime *)maximumStartTime {
  GDataDateTime *dateTime;

  dateTime = [self dateTimeForParameterWithName:kMaximumStartTimeParamName];
  return dateTime;
}

- (void)setMaximumStartTime:(GDataDateTime *)dateTime {
  [self addCustomParameterWithName:kMaximumStartTimeParamName
                          dateTime:dateTime];
}

- (GDataDateTime *)recurrenceExpansionStartTime {
  GDataDateTime *dateTime;

  dateTime = [self dateTimeForParameterWithName:kRecurrenceExpansionStartTimeParamName];
  return dateTime;
}

- (void)setRecurrenceExpansionStartTime:(GDataDateTime *)dateTime {
  [self addCustomParameterWithName:kRecurrenceExpansionStartTimeParamName
                             dateTime:dateTime];
}

- (GDataDateTime *)recurrenceExpansionEndTime {
  GDataDateTime *dateTime;

  dateTime = [self dateTimeForParameterWithName:kRecurrenceExpansionEndTimeParamName];
  return dateTime;
}

- (void)setRecurrenceExpansionEndTime:(GDataDateTime *)dateTime {
  [self addCustomParameterWithName:kRecurrenceExpansionEndTimeParamName
                          dateTime:dateTime];
}

- (BOOL)shouldQueryAllFutureEvents {
  return [self boolValueForParameterWithName:kFutureEventsParamName
                                defaultValue:NO];
}

- (void)setShouldQueryAllFutureEvents:(BOOL)flag {
  [self addCustomParameterWithName:kFutureEventsParamName
                         boolValue:flag
                      defaultValue:NO];
}

- (BOOL)shouldExpandRecurrentEvents {
  return [self boolValueForParameterWithName:kSingleEventsParamName
                                defaultValue:NO];
}

- (void)setShouldExpandRecurrentEvents:(BOOL)flag {
  [self addCustomParameterWithName:kSingleEventsParamName
                         boolValue:flag
                      defaultValue:NO];
}

- (BOOL)shouldShowInlineComments {
  return [self boolValueForParameterWithName:kShowInlineCommentsParamName
                                defaultValue:YES];
}

- (void)setShouldShowInlineComments:(BOOL)flag {
  [self addCustomParameterWithName:kShowInlineCommentsParamName
                         boolValue:flag
                      defaultValue:YES];
}

- (BOOL)shouldShowHiddenEvents {
  return [self boolValueForParameterWithName:kShowHiddenParamName
                                defaultValue:NO];
}

- (void)setShouldShowHiddenEvents:(BOOL)flag {
  [self addCustomParameterWithName:kShowHiddenParamName
                         boolValue:flag
                      defaultValue:NO];
}

- (NSString *)currentTimeZoneName {
  NSString *str = [self valueForParameterWithName:kCurrentTimeZoneParamName];
  return str;
}

- (void)setCurrentTimeZoneName:(NSString *)str {
  
  // replace underscores with spaces in the param value
  NSMutableString *mutableStr = [NSMutableString stringWithString:str];
  
  [mutableStr replaceOccurrencesOfString:@" "
                              withString:@"_"
                                 options:0
                                   range:NSMakeRange(0, [str length])];

  [self addCustomParameterWithName:kCurrentTimeZoneParamName
                             value:mutableStr];
}

- (NSInteger)maximumAttendees {
  return [self intValueForParameterWithName:kMaxAttendeesParamName
                      missingParameterValue:-1];
}

- (void)setMaximumAttendees:(NSInteger)val {
  [self addCustomParameterWithName:kMaxAttendeesParamName
                          intValue:val
                    removeForValue:-1];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE
