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

NSString *const kMinimumStartTimeParamName  = @"start-min";
NSString *const kMaximumStartTimeParamName  = @"start-max";

@implementation GDataQueryCalendar


+ (GDataQueryCalendar *)calendarQueryWithFeedURL:(NSURL *)feedURL {
  return [[[[self class] alloc] initWithFeedURL:feedURL] autorelease];   
}

- (GDataDateTime *)minimumStartTime {
  NSString *str =  [[self customParameters] objectForKey:kMinimumStartTimeParamName];
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
  NSString *str =  [[self customParameters] objectForKey:kMaximumStartTimeParamName];
  if (str) {
    return [GDataDateTime dateTimeWithRFC3339String:str];
  }
  return nil;
}

- (void)setMaximumStartTime:(GDataDateTime *)dateTime {
  [self addCustomParameterWithName:kMaximumStartTimeParamName
                             value:[dateTime RFC3339String]];
}

@end
