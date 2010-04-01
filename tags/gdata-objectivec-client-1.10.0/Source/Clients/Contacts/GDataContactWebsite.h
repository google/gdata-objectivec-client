/* Copyright (c) 2009 Google Inc.
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
//  GDataContactWebsite.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CONTACTS_SERVICE

#import "GDataObject.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATACONTACTWEBSITE_DEFINE_GLOBALS
#define _EXTERN
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

// rel values
_EXTERN NSString* kGDataContactWebsiteBlog     _INITIALIZE_AS(@"blog");
_EXTERN NSString* kGDataContactWebsiteFTP      _INITIALIZE_AS(@"ftp");
_EXTERN NSString* kGDataContactWebsiteHome     _INITIALIZE_AS(@"home");
_EXTERN NSString* kGDataContactWebsiteHomePage _INITIALIZE_AS(@"home-page");
_EXTERN NSString* kGDataContactWebsiteWork     _INITIALIZE_AS(@"work");
_EXTERN NSString* kGDataContactWebsiteOther    _INITIALIZE_AS(@"other");

@interface GDataContactWebsite : GDataObject <GDataExtension>

+ (id)websiteWithRel:(NSString *)rel
               label:(NSString *)label
                href:(NSString *)href;

- (NSString *)label;
- (void)setLabel:(NSString *)str;

- (NSString *)rel;
- (void)setRel:(NSString *)str;

- (NSString *)href;
- (void)setHref:(NSString *)str;

- (BOOL)isPrimary;
- (void)setIsPrimary:(BOOL)flag;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CONTACTS_SERVICE
