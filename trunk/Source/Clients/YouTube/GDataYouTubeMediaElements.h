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
//  GDataYouTubeMediaElements.h
//


#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GYOUTUBMEDIAEELEMENTS_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN int kGDataYouTubeMediaContentFormatRTSPStream _INITIALIZE_AS(1);
_EXTERN int kGDataYouTubeMediaContentFormatHTTPURL _INITIALIZE_AS(5);

#import "GDataObject.h"
#import "GDataMediaContent.h"
#import "GDataMediaGroup.h"
#import "GDataYouTubeElements.h"

// media content with YouTube's addition of an integer format attribute, 
// like yt:format="1"
@interface GDataMediaContent (YouTubeExtensions)
- (NSNumber *)youTubeFormatNumber;
- (void)setYouTubeFormatNumber:(NSNumber *)num;
@end

// a media group that uses the YouTube media content elements instead
// of the generic media content elements
@interface GDataYouTubeMediaGroup : GDataMediaGroup
- (NSNumber *)duration; // int, in seconds
- (void)setDuration:(NSNumber *)num;

- (BOOL)isPrivate;
- (void)setIsPrivate:(BOOL)flag;
@end
