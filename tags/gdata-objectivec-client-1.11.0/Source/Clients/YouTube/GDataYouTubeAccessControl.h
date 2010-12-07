/* Copyright (c) 2010 Google Inc.
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
//  GDataYouTubeAccessControl.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataObject.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAYOUTUBEACCESSCONTROL_DEFINE_GLOBALS
#define _EXTERN
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

// actions
_EXTERN NSString* const kGDataYouTubeAccessControlRate         _INITIALIZE_AS(@"rate");
_EXTERN NSString* const kGDataYouTubeAccessControlComment      _INITIALIZE_AS(@"comment");
_EXTERN NSString* const kGDataYouTubeAccessControlCommentVote  _INITIALIZE_AS(@"commentVote");
_EXTERN NSString* const kGDataYouTubeAccessControlVideoRespond _INITIALIZE_AS(@"videoRespond");
_EXTERN NSString* const kGDataYouTubeAccessControlEmbed        _INITIALIZE_AS(@"embed");
_EXTERN NSString* const kGDataYouTubeAccessControlSyndicate    _INITIALIZE_AS(@"syndicate");

// permissions
_EXTERN NSString* const kGDataYouTubeAccessControlPermissionAllowed   _INITIALIZE_AS(@"allowed");
_EXTERN NSString* const kGDataYouTubeAccessControlPermissionDenied    _INITIALIZE_AS(@"denied");
_EXTERN NSString* const kGDataYouTubeAccessControlPermissionModerated _INITIALIZE_AS(@"moderated");


// access control element, such as
//  <yt:accessControl action='comment' permission='allowed' type='group'>
//    friends
//  </yt:accessControl>

@interface GDataYouTubeAccessControl : GDataObject <GDataExtension>

+ (GDataYouTubeAccessControl *)accessControlWithAction:(NSString *)action
                                            permission:(NSString *)permission;

- (NSString *)action;
- (void)setAction:(NSString *)str;

- (NSString *)permission;
- (void)setPermission:(NSString *)str;

- (NSString *)type;
- (void)setType:(NSString *)str;

- (NSString *)value;
- (void)setValue:(NSString *)str;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
