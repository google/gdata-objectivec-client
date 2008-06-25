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

#define GDATAQUERYYOUTUBE_DEFINE_GLOBALS 1
#import "GDataQueryYouTube.h"

#import "GDataServiceGoogleYouTube.h"

static NSString *const kVideoQueryParamName = @"vq";
static NSString *const kTimeParamName = @"time";
static NSString *const kFormatParamName = @"format";
static NSString *const kRacyParamName = @"racy";
static NSString *const kRestrictionParamName = @"restriction";
static NSString *const kLanguageRestrictionParamName = @"lr";
static NSString *const kLocationParamName = @"location";

@implementation GDataQueryYouTube

+ (GDataQueryYouTube *)youTubeQueryWithFeedURL:(NSURL *)feedURL {
  return [[[self alloc] initWithFeedURL:feedURL] autorelease];   
}


- (void)setVideoQuery:(NSString *)str {
  [self addCustomParameterWithName:kVideoQueryParamName
                             value:str];
}

- (NSString *)videoQuery {
  return [[self customParameters] objectForKey:kVideoQueryParamName];
}

- (void)setFormat:(NSString *)str {
  [self addCustomParameterWithName:kFormatParamName
                             value:str];
}

- (NSString *)format {
  return [[self customParameters] objectForKey:kFormatParamName];
}

- (void)setTimePeriod:(NSString *)str {
  [self addCustomParameterWithName:kTimeParamName
                             value:str];
}

- (NSString *)timePeriod {
  return [[self customParameters] objectForKey:kTimeParamName];
}

- (void)setRestriction:(NSString *)str {
  [self addCustomParameterWithName:kRestrictionParamName
                             value:str];
}

- (NSString *)restriction {
  return [[self customParameters] objectForKey:kRestrictionParamName];
}

- (void)setLanguageRestriction:(NSString *)str {
  [self addCustomParameterWithName:kLanguageRestrictionParamName
                             value:str];
}

- (NSString *)languageRestriction {
  return [[self customParameters] objectForKey:kLanguageRestrictionParamName];
}

- (void)setLocation:(NSString *)str {
  [self addCustomParameterWithName:kLocationParamName
                             value:str];
}

- (NSString *)location {
  return [[self customParameters] objectForKey:kLocationParamName];
}

- (void)setAllowRacy:(BOOL)flag {
  
  // adding nil removes the custom parameter
  [self addCustomParameterWithName:kRacyParamName
                             value:(flag ? @"include" : nil)];
}

- (BOOL)allowRacy {
  NSString *str = [[self customParameters] objectForKey:kRacyParamName];
  return ([str caseInsensitiveCompare:@"include"] == NSOrderedSame);
}

@end
