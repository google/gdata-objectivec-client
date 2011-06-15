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
//  GDataYouTubeAccessControl.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

// access control element, such as
//  <yt:accessControl action='comment' permission='allowed' type='group'>
//    friends
//  </yt:accessControl>

#define GDATAYOUTUBEACCESSCONTROL_DEFINE_GLOBALS 1
#import "GDataYouTubeAccessControl.h"

#import "GDataYouTubeConstants.h"

static NSString *const kActionAttr     = @"action";
static NSString *const kPermissionAttr = @"permission";
static NSString *const kTypeAttr       = @"type";

@implementation GDataYouTubeAccessControl

+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"accessControl"; }

+ (GDataYouTubeAccessControl *)accessControlWithAction:(NSString *)action
                                            permission:(NSString *)permission {
  GDataYouTubeAccessControl *obj = [self object];
  [obj setAction:action];
  [obj setPermission:permission];
  return obj;
}

- (void)addParseDeclarations {

  NSArray *attrs = [NSArray arrayWithObjects:
                    kActionAttr, kPermissionAttr, kTypeAttr, nil];

  [self addLocalAttributeDeclarations:attrs];

  [self addContentValueDeclaration];
}

#pragma mark -

- (NSString *)action {
  return [self stringValueForAttribute:kActionAttr];
}

- (void)setAction:(NSString *)str {
  [self setStringValue:str forAttribute:kActionAttr];
}

- (NSString *)permission {
  return [self stringValueForAttribute:kPermissionAttr];
}

- (void)setPermission:(NSString *)str {
  [self setStringValue:str forAttribute:kPermissionAttr];
}

- (NSString *)type {
  return [self stringValueForAttribute:kTypeAttr];
}

- (void)setType:(NSString *)str {
  [self setStringValue:str forAttribute:kTypeAttr];
}

- (NSString *)value {
  return [self contentStringValue];
}

- (void)setValue:(NSString *)str {
  [self setContentStringValue:str];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
