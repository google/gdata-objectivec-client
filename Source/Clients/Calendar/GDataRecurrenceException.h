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
//  GDataRecurrenceException.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE

#import "GDataObject.h"

// a gd:recurrenceException link, possibly containing an entryLink or 
// an originalEvent
//<gd:recurrenceException specialized="true">
//  <gd:entryLink>
//     <entry>
//   ...
// http://code.google.com/apis/gdata/common-elements.html#gdRecurrenceException
//
// As of this writing, Feb 2007, <gd:recurrenceException> elements are in
// the Google Calendar /composite/ feed, but are not in the /full/ feed.
// The full feed just puts an <gd:originalEvent> directly in an <entry>.

@class GDataEntryLink;
@class GDataOriginalEvent;

@interface GDataRecurrenceException : GDataObject <NSCopying, GDataExtension> {
  BOOL isSpecialized_;
  GDataEntryLink *entryLink_;
  GDataOriginalEvent *originalEvent_;
}
+ (GDataRecurrenceException *)recurrenceExceptionWithEntryLink:(GDataEntryLink *)entryLink
                                                 originalEvent:(GDataOriginalEvent *)originalEvent
                                                 isSpecialized:(BOOL)isSpecialized;  
- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent;
- (NSXMLElement *)XMLElement;

- (BOOL)isSpecialized;
- (void)setIsSpecialized:(BOOL)isSpecialized;
- (GDataEntryLink *)entryLink;
- (void)setEntryLink:(GDataEntryLink *)entryLink;
- (GDataOriginalEvent *)originalEvent;
- (void)setOriginalEvent:(GDataOriginalEvent *)originalEvent;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE
