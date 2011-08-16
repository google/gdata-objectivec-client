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
//  GDataQueryYouTube.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#define GDATAQUERYYOUTUBE_DEFINE_GLOBALS 1
#import "GDataQueryYouTube.h"

#import "GDataServiceGoogleYouTube.h"

static NSString *const kTimeParamName = @"time";
static NSString *const kFormatParamName = @"format";
static NSString *const kCaptionTrackFormatParamName = @"fmt";
static NSString *const kSafeSearchParamName = @"safeSearch";
static NSString *const kRestrictionParamName = @"restriction";
static NSString *const kLanguageRestrictionParamName = @"lr";
static NSString *const kLocationParamName = @"location";
static NSString *const kLocationRadiusParamName = @"location-radius";
static NSString *const kCaptionParamName = @"caption";
static NSString *const k3DParamName = @"3d";
static NSString *const kInlineParamName = @"inline";
static NSString *const kUploaderParamName = @"uploader";

@implementation GDataQueryYouTube

+ (GDataQueryYouTube *)youTubeQueryWithFeedURL:(NSURL *)feedURL {
  return [self queryWithFeedURL:feedURL];   
}


- (void)setVideoQuery:(NSString *)str {
  // The vq query parameter has been replaced with
  // "q" (kFullTextQueryStringParamName) for v2
  [self setFullTextQueryString:str];
}

- (NSString *)videoQuery {
  return [self fullTextQueryString];
}

- (void)setFormat:(NSString *)str {
  [self addCustomParameterWithName:kFormatParamName
                             value:str];
}

- (NSString *)format {
  return [self valueForParameterWithName:kFormatParamName];
}

- (void)setCaptionTrackFormat:(NSString *)str {
  [self addCustomParameterWithName:kCaptionTrackFormatParamName
                             value:str];
}

- (NSString *)captionTrackFormat {
  return [self valueForParameterWithName:kCaptionTrackFormatParamName];
}

- (void)setTimePeriod:(NSString *)str {
  [self addCustomParameterWithName:kTimeParamName
                             value:str];
}

- (NSString *)timePeriod {
  return [self valueForParameterWithName:kTimeParamName];
}

- (void)setRestriction:(NSString *)str {
  [self addCustomParameterWithName:kRestrictionParamName
                             value:str];
}

- (NSString *)restriction {
  return [self valueForParameterWithName:kRestrictionParamName];
}

- (void)setLanguageRestriction:(NSString *)str {
  [self addCustomParameterWithName:kLanguageRestrictionParamName
                             value:str];
}

- (NSString *)languageRestriction {
  return [self valueForParameterWithName:kLanguageRestrictionParamName];
}

- (void)setLocation:(NSString *)str {
  [self addCustomParameterWithName:kLocationParamName
                             value:str];
}

- (NSString *)location {
  return [self valueForParameterWithName:kLocationParamName];
}

- (void)setLocationRadius:(NSString *)str {
  [self addCustomParameterWithName:kLocationRadiusParamName
                             value:str];
}

- (NSString *)locationRadius {
  return [self valueForParameterWithName:kLocationRadiusParamName];
}

- (void)setHasCaptions:(BOOL)flag {
  [self addCustomParameterWithName:kCaptionParamName
                         boolValue:flag
                      defaultValue:NO];
}

- (BOOL)hasCaptions {
  return [self boolValueForParameterWithName:kCaptionParamName
                                defaultValue:NO];
}

- (void)setShouldRequire3D:(BOOL)flag {
  [self addCustomParameterWithName:k3DParamName
                         boolValue:flag
                      defaultValue:NO];
}

- (BOOL)shouldRequire3D {
  return [self boolValueForParameterWithName:k3DParamName
                                defaultValue:NO];
}

- (void)setShouldInline:(BOOL)flag {
  [self addCustomParameterWithName:kInlineParamName
                         boolValue:flag
                      defaultValue:NO];
}

- (BOOL)shouldInline {
  return [self boolValueForParameterWithName:kInlineParamName
                                defaultValue:NO];
}

- (void)setUploader:(NSString *)str {
  [self addCustomParameterWithName:kUploaderParamName
                             value:str];
}

- (NSString *)uploader {
  return [self valueForParameterWithName:kUploaderParamName];
}

- (void)setSafeSearch:(NSString *)str {
  [self addCustomParameterWithName:kSafeSearchParamName
                             value:str];
}

- (NSString *)safeSearch {
  return [self valueForParameterWithName:kSafeSearchParamName];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
