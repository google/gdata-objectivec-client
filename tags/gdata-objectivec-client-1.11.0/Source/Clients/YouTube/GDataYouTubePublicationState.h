/* Copyright (c) 2008 Google Inc.
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
//  GDataYouTubePublicationState.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataObject.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAYOUTUBEPUBLICATIONSTATE_DEFINE_GLOBALS
#define _EXTERN
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataYouTubePubStateIncomplete _INITIALIZE_AS(@"incomplete");
_EXTERN NSString* const kGDataYouTubePubStateProcessing _INITIALIZE_AS(@"processing");
_EXTERN NSString* const kGDataYouTubePubStateRejected   _INITIALIZE_AS(@"rejected");
_EXTERN NSString* const kGDataYouTubePubStateFailed     _INITIALIZE_AS(@"failed");
_EXTERN NSString* const kGDataYouTubePubStateDeleted    _INITIALIZE_AS(@"deleted");
_EXTERN NSString* const kGDataYouTubePubStateRestricted _INITIALIZE_AS(@"restricted");


// yt:state is an extension to GDataAtomPubControl for YouTube video entries, 
// as in 
//
//  <app:control>
//    <yt:state name="rejected" reasonCode="32" helpUrl="http://www.youtube.com/">
//          incorrect format</yt:state>
//  </app:control>

@interface GDataYouTubePublicationState : GDataObject <GDataExtension>

- (NSString *)state;
- (void)setState:(NSString *)str;

- (NSString *)reasonCode;
- (void)setReasonCode:(NSString *)str;

- (NSString *)helpURLString;
- (void)setHelpURLString:(NSString *)str;

- (NSString *)errorDescription;
- (void)setErrorDescription:(NSString *)str;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
