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
//  GDataWebContent.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE

#import "GDataObject.h"
#import "GDataExtendedProperty.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAWEBCONTENT_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN GDATA_EXTERN
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataLinkRelWebContent _INITIALIZE_AS(@"http://schemas.google.com/gCal/2005/webContent");


// Calendar Web Content element, inside a <link>, as in
//
// <gCal:webContent url="http://www.google.com/logos/july4th06.gif" 
//                  width="276" height="120" >
//      <gCal:webContentGadgetPref name="color" value="green" />
//      <gCal:webContentGadgetPref name="military_time" value="false" />
// </gCal:webContent>
//
// http://code.google.com/apis/gdata/calendar.html#gCalwebContent

@interface GDataWebContentGadgetPref : GDataExtendedProperty
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataWebContent : GDataObject <GDataExtension>

+ (GDataWebContent *)webContentWithURL:(NSString *)urlString
                                 width:(int)width
                                height:(int)height;

- (NSNumber *)height;
- (void)setHeight:(NSNumber *)num;

- (NSNumber *)width;
- (void)setWidth:(NSNumber *)num;

- (NSString *)URLString;
- (void)setURLString:(NSString *)str;

- (NSString *)display;
- (void)setDisplay:(NSString *)str;

- (NSArray *)gadgetPreferences;
- (void)setGadgetPreferences:(NSArray *)array;
- (void)addGadgetPreference:(GDataWebContentGadgetPref *)obj;

// returning a dictionary of prefs simplifies key-value coding access
- (NSDictionary *)gadgetPreferenceDictionary;
  
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE
