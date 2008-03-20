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

#import "GDataYouTubeStatistics.h"
#import "GDataEntryYouTubeVideo.h"

@implementation GDataYouTubeStatistics 
// <yt:statistics viewCount="2" 
//                videoWatchCount="77" 
//                lastWebAccess="2008-01-26T10:32:41.000-08:00"/>

+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"statistics"; }

+ (GDataYouTubeStatistics *)youTubeStatistics {
  GDataYouTubeStatistics *obj = [[[self alloc] init] autorelease];
  return obj;
}


- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setViewCount:[self longLongNumberForAttributeName:@"viewCount" 
                                                fromElement:element]];
    [self setVideoWatchCount:[self longLongNumberForAttributeName:@"videoWatchCount" 
                                                      fromElement:element]];
    [self setSubscriberCount:[self longLongNumberForAttributeName:@"subscriberCount" 
                                                      fromElement:element]];
    
    [self setLastWebAccess:[self dateTimeForAttributeName:@"lastWebAccess"
                                              fromElement:element]];
  }
  return self;
}

- (void)dealloc {
  
  [viewCount_ release];
  [videoWatchCount_ release];
  [subscriberCount_ release];
  [lastWebAccess_ release];
  
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataYouTubeStatistics* newObj = [super copyWithZone:zone];
  [newObj setViewCount:[self viewCount]];
  [newObj setVideoWatchCount:[self videoWatchCount]];
  [newObj setSubscriberCount:[self subscriberCount]];
  [newObj setLastWebAccess:[[[self lastWebAccess] copyWithZone:zone] autorelease]];
  return newObj;
}

- (BOOL)isEqual:(GDataYouTubeStatistics *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataYouTubeStatistics class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self viewCount], [other viewCount])
    && AreEqualOrBothNil([self videoWatchCount], [other videoWatchCount])
    && AreEqualOrBothNil([self subscriberCount], [other subscriberCount])
    && AreEqualOrBothNil([self lastWebAccess], [other lastWebAccess]);
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:[self viewCount] withName:@"viewCount"];
  [self addToArray:items objectDescriptionIfNonNil:[self videoWatchCount] withName:@"videoWatchCount"];
  [self addToArray:items objectDescriptionIfNonNil:[self subscriberCount] withName:@"subscribers"];
  [self addToArray:items objectDescriptionIfNonNil:[self lastWebAccess] withName:@"lastWebAccess"];
  
  return items;
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:nil];
  
  // as in the Java, we add these attributes only if they're non-zero
  NSNumber *viewCount = [self viewCount];
  if ([viewCount longLongValue] > 0) {
    [self addToElement:element attributeValueIfNonNil:[viewCount stringValue] withName:@"viewCount"];
  }
  
  NSNumber *videoWatchCount = [self videoWatchCount];
  if ([videoWatchCount longLongValue] > 0) {
    [self addToElement:element attributeValueIfNonNil:[videoWatchCount stringValue] withName:@"videoWatchCount"];
  }
  
  NSNumber *subscriberCount = [self subscriberCount];
  if ([subscriberCount longLongValue] > 0) {
    [self addToElement:element attributeValueIfNonNil:[subscriberCount stringValue] withName:@"subscriberCount"];
  }
  
  [self addToElement:element attributeValueIfNonNil:[[self lastWebAccess] RFC3339String] withName:@"lastWebAccess"];
  
  return element;
}

#pragma mark -

- (NSNumber *)viewCount {
  return viewCount_; 
}

- (void)setViewCount:(NSNumber *)num {
  [viewCount_ autorelease];
  viewCount_ = [num copy];
}

- (NSNumber *)videoWatchCount {
  return videoWatchCount_; 
}

- (void)setVideoWatchCount:(NSNumber *)num {
  [videoWatchCount_ autorelease];
  videoWatchCount_ = [num copy];
}

- (NSNumber *)subscriberCount {
  return subscriberCount_; 
}

- (void)setSubscriberCount:(NSNumber *)num {
  [subscriberCount_ autorelease];
  subscriberCount_ = [num copy];
}

- (GDataDateTime *)lastWebAccess {
  return lastWebAccess_; 
}

- (void)setLastWebAccess:(GDataDateTime *)dateTime {
  [lastWebAccess_ autorelease];
  lastWebAccess_ = [dateTime copy];
}

@end

