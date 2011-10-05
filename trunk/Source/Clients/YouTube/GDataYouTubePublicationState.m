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
//  GDataYouTubePublicationState.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

// yt:state is an extension to GDataAtomPubControl for YouTube video entries, 
// as in 
//
//  <app:control>
//    <yt:state name="rejected" reasonCode="32" helpUrl="http://www.youtube.com/">
//          incorrect format</yt:state>
//  </app:control>


#define GDATAYOUTUBEPUBLICATIONSTATE_DEFINE_GLOBALS 1
#import "GDataYouTubePublicationState.h"

#import "GDataYouTubeConstants.h"

static NSString *const kNameAttr = @"name";
static NSString *const kReasonCodeAttr = @"reasonCode";
static NSString *const kHelpURLAttr = @"helpUrl";

@implementation GDataYouTubePublicationState 

+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"state"; }

- (void)addParseDeclarations {
  
  NSArray *attrs = [NSArray arrayWithObjects:
                    kNameAttr, kReasonCodeAttr, kHelpURLAttr, nil];
  
  [self addLocalAttributeDeclarations:attrs]; 

  [self addContentValueDeclaration];
}

#pragma mark -

- (NSString *)name {
  return [self stringValueForAttribute:kNameAttr];
}

- (void)setName:(NSString *)str {
  [self setStringValue:str forAttribute:kNameAttr];
}

- (NSString *)reasonCode {
  return [self stringValueForAttribute:kReasonCodeAttr];
}

- (void)setReasonCode:(NSString *)str {
  [self setStringValue:str forAttribute:kReasonCodeAttr];
}

- (NSString *)helpURLString {
  return [self stringValueForAttribute:kHelpURLAttr];
}

- (void)setHelpURLString:(NSString *)str {
  [self setStringValue:str forAttribute:kHelpURLAttr];
}

- (NSString *)errorDescription {
  return [self contentStringValue]; 
}

- (void)setErrorDescription:(NSString *)str {
  [self setContentStringValue:str];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
