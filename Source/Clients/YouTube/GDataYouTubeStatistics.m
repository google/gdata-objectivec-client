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
//  GDataYouTubeStatistics.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataYouTubeStatistics.h"
#import "GDataYouTubeConstants.h"

static NSString* const kViewCountAttr = @"viewCount";
static NSString* const kVideoWatchCountAttr = @"videoWatchCount";
static NSString* const kSubscriberCountAttr = @"subscriberCount";
static NSString* const kFavoriteCountAttr = @"favoriteCount";
static NSString* const kLastWebAccessAttr = @"lastWebAccess";
static NSString* const kTotalUploadViewsAttr = @"totalUploadViews";

@implementation GDataYouTubeStatistics 
// <yt:statistics viewCount="2" 
//                videoWatchCount="77" 
//                lastWebAccess="2008-01-26T10:32:41.000-08:00"/>

+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"statistics"; }

+ (GDataYouTubeStatistics *)youTubeStatistics {
  GDataYouTubeStatistics *obj = [self object];
  return obj;
}

- (void)addParseDeclarations {
  
  NSArray *attrs = [NSArray arrayWithObjects: 
                    kViewCountAttr, kVideoWatchCountAttr,
                    kSubscriberCountAttr, kFavoriteCountAttr,
                    kLastWebAccessAttr, kTotalUploadViewsAttr, nil];
  
  [self addLocalAttributeDeclarations:attrs];
}

- (void)addAttributesToElement:(NSXMLElement *)element {
  
  // this overrides the base class's method
  //
  // as in the java, skip adding attributes that are zero
  
  NSString *name;
  NSDictionary *attributes = [self attributes];
  NSEnumerator *enumerator = [attributes keyEnumerator];
  while ((name = [enumerator nextObject]) != nil) {
    
    NSString *value = [attributes valueForKey:name];
    
    // add it if it's not "0"
    if (![value isEqual:@"0"]) {
      
      [self addToElement:element attributeValueIfNonNil:value withName:name];
    }
  }
}

#pragma mark -

- (NSNumber *)viewCount {
  return [self longLongNumberForAttribute:kViewCountAttr];
}

- (void)setViewCount:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kViewCountAttr];
}

- (NSNumber *)videoWatchCount {
  return [self longLongNumberForAttribute:kVideoWatchCountAttr];
}

- (void)setVideoWatchCount:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kVideoWatchCountAttr];
}

- (NSNumber *)subscriberCount {
  return [self longLongNumberForAttribute:kSubscriberCountAttr];
}

- (void)setSubscriberCount:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kSubscriberCountAttr];
}

- (NSNumber *)favoriteCount {
  return [self longLongNumberForAttribute:kFavoriteCountAttr];
}

- (void)setFavoriteCount:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kFavoriteCountAttr];
}

- (GDataDateTime *)lastWebAccess {
  return [self dateTimeForAttribute:kLastWebAccessAttr]; 
}

- (void)setLastWebAccess:(GDataDateTime *)dateTime {
  [self setDateTimeValue:dateTime forAttribute:kLastWebAccessAttr];
}

- (NSNumber *)totalUploadViews {
  return [self longLongNumberForAttribute:kTotalUploadViewsAttr];
}

- (void)setTotalUploadViews:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kTotalUploadViewsAttr];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
