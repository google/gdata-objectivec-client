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

#import "GDataQueryCalendar.h"

// query params per
//   http://code.google.com/apis/calendar/reference.html#Parameters

NSString *const kMinimumStartTimeParamName  = @"start-min";
NSString *const kMaximumStartTimeParamName  = @"start-max";
NSString *const kRecurrenceExpansionStartTimeParamName  = @"recurrence-expansion-start";
NSString *const kRecurrenceExpansionEndTimeParamName  = @"recurrence-expansion-end";
NSString *const kFutureEventsParamName  = @"futureevents";
NSString *const kSingleEventsParamName = @"singleevents";
NSString *const kCurrentTimeZoneParamName = @"ctz";

@implementation GDataQueryCalendar

+ (GDataQueryCalendar *)calendarQueryWithFeedURL:(NSURL *)feedURL {
  return [[[self alloc] initWithFeedURL:feedURL] autorelease];   
}

- (GDataDateTime *)minimumStartTime {
  NSString *str = [[self customParameters] objectForKey:kMinimumStartTimeParamName];
  if (str) {
    return [GDataDateTime dateTimeWithRFC3339String:str];
  }
  return nil;
}

- (void)setMinimumStartTime:(GDataDateTime *)dateTime {
  [self addCustomParameterWithName:kMinimumStartTimeParamName
                             value:[dateTime RFC3339String]];
}

- (GDataDateTime *)maximumStartTime {
  NSString *str = [[self customParameters] objectForKey:kMaximumStartTimeParamName];
  if (str) {
    return [GDataDateTime dateTimeWithRFC3339String:str];
  }
  return nil;
}

- (void)setMaximumStartTime:(GDataDateTime *)dateTime {
  [self addCustomParameterWithName:kMaximumStartTimeParamName
                             value:[dateTime RFC3339String]];
}

- (GDataDateTime *)recurrenceExpansionStartTime {
  NSString *str = [[self customParameters] objectForKey:kRecurrenceExpansionStartTimeParamName];
  if (str) {
    return [GDataDateTime dateTimeWithRFC3339String:str];
  }
  return nil;
}

- (void)setRecurrenceExpansionStartTime:(GDataDateTime *)dateTime {
  [self addCustomParameterWithName:kRecurrenceExpansionStartTimeParamName
                             value:[dateTime RFC3339String]];
}

- (GDataDateTime *)recurrenceExpansionEndTime {
  NSString *str = [[self customParameters] objectForKey:kRecurrenceExpansionEndTimeParamName];
  if (str) {
    return [GDataDateTime dateTimeWithRFC3339String:str];
  }
  return nil;
}

- (void)setRecurrenceExpansionEndTime:(GDataDateTime *)dateTime {
  [self addCustomParameterWithName:kRecurrenceExpansionEndTimeParamName
                             value:[dateTime RFC3339String]];
}

- (BOOL)shouldQueryAllFutureEvents {
  NSString *val = [[self customParameters] objectForKey:kFutureEventsParamName];
  return (val != nil) && 
    ([val caseInsensitiveCompare:@"true"] == NSOrderedSame);
}

- (void)setShouldQueryAllFutureEvents:(BOOL)flag {
  NSString *value = (flag ? @"true" : nil);
  [self addCustomParameterWithName:kFutureEventsParamName
                             value:value]; // nil value removes the parameter
}

- (BOOL)shouldExpandRecurrentEvents {
  NSString *val = [[self customParameters] objectForKey:kSingleEventsParamName];
  return (val != nil) && 
    ([val caseInsensitiveCompare:@"true"] == NSOrderedSame);
}

- (void)setShouldExpandRecurrentEvents:(BOOL)flag {
  NSString *value = (flag ? @"true" : nil);
  [self addCustomParameterWithName:kSingleEventsParamName
                             value:value]; // nil value removes the parameter
}

- (NSString *)currentTimeZoneName {
  NSString *str = [[self customParameters] objectForKey:kCurrentTimeZoneParamName];
  return str;
}

- (void)setCurrentTimeZoneName:(NSString *)str {
  
  // replace underscores with spaces in the param value
  NSMutableString *mutable = [NSMutableString stringWithString:str];
  
  [mutable replaceOccurrencesOfString:@" "
                           withString:@"_"
                              options:0
                                range:NSMakeRange(0, [str length])];
  
  [self addCustomParameterWithName:kCurrentTimeZoneParamName
                             value:mutable];
}

@end
