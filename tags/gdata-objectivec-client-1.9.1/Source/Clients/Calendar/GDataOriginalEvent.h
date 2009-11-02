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
//  GDataOriginalEvent.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE

#import <Foundation/Foundation.h>

#import "GDataObject.h"

@class GDataWhen;

// original event element, as in
// <gd:originalEvent id="i8fl1nrv2bl57c1qgr3f0onmgg"
//         href="http://www.google.com/calendar/feeds/userID/private-magicCookie/full/eventID">
//         <gd:when startTime="2006-03-17T22:00:00.000Z"/>
// </gd:originalEvent>
//
// http://code.google.com/apis/gdata/common-elements.html#gdOriginalEvent

@interface GDataOriginalEvent : GDataObject <GDataExtension> {
}
+ (GDataOriginalEvent *)originalEventWithID:(NSString *)originalID
                                       href:(NSString *)feedHref
                          originalStartTime:(GDataWhen *)startTime;

- (NSString *)href;
- (void)setHref:(NSString *)str;

- (NSString *)originalID;
- (void)setOriginalID:(NSString *)str;

- (GDataWhen *)originalStartTime;
- (void)setOriginalStartTime:(GDataWhen *)startTime;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE
