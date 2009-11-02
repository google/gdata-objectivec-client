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
//  GDataBloggerConstants.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BLOGGER_SERVICE

#import <Foundation/Foundation.h>

#import "GDataDefines.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATABLOGGERCONSTANTS_DEFINE_GLOBALS
#define _EXTERN
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataBloggerDefaultServiceVersion _INITIALIZE_AS(@"2.0");

_EXTERN NSString* const kGDataNamespaceBlogger       _INITIALIZE_AS(@"http://schemas.google.com/blogger/2008");

_EXTERN NSString* const kGDataCategoryBloggerPost    _INITIALIZE_AS(@"http://schemas.google.com/blogger/2008/kind#post");
_EXTERN NSString* const kGDataCategoryBloggerComment _INITIALIZE_AS(@"http://schemas.google.com/blogger/2008/kind#comment");

_EXTERN NSString* const kGDataLinkBloggerReplies     _INITIALIZE_AS(@"replies");
_EXTERN NSString* const kGDataLinkBloggerEnclosure   _INITIALIZE_AS(@"enclosure");
_EXTERN NSString* const kGDataLinkBloggerSettings    _INITIALIZE_AS(@"http://schemas.google.com/blogger/2008#settings");
_EXTERN NSString* const kGDataLinkBloggerTemplate    _INITIALIZE_AS(@"http://schemas.google.com/blogger/2008#template");

@interface GDataBloggerConstants : NSObject
+ (NSDictionary *)bloggerNamespaces;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BLOGGER_SERVICE
