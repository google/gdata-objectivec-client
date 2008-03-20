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
//  GDataQueryCalendar.h
//

// Calendar-specific query params, per 
//   http://code.google.com/apis/calendar/reference.html#Parameters

#import "GDataQuery.h"

@interface GDataQueryCalendar : GDataQuery 

+ (GDataQueryCalendar *)calendarQueryWithFeedURL:(NSURL *)feedURL;

- (GDataDateTime *)minimumStartTime;
- (void)setMinimumStartTime:(GDataDateTime *)dateTime;

- (GDataDateTime *)maximumStartTime;
- (void)setMaximumStartTime:(GDataDateTime *)dateTime;

- (GDataDateTime *)recurrenceExpansionStartTime;
- (void)setRecurrenceExpansionStartTime:(GDataDateTime *)dateTime;

- (GDataDateTime *)recurrenceExpansionEndTime;
- (void)setRecurrenceExpansionEndTime:(GDataDateTime *)dateTime;

// querying all future events overrides any parameters for
// start-min, start-max, and recurrence expansion start and end times
- (BOOL)shouldQueryAllFutureEvents;
- (void)setShouldQueryAllFutureEvents:(BOOL)dateTime;

- (BOOL)shouldExpandRecurrentEvents;
- (void)setShouldExpandRecurrentEvents:(BOOL)dateTime;

- (NSString *)currentTimeZoneName;
- (void)setCurrentTimeZoneName:(NSString *)str;
  
@end

