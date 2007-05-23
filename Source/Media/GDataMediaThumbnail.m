/* Copyright (c) 2007 Google Inc.
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
//  GDataMediaThumbnail.m
//

#import "GDataMediaThumbnail.h"
#import "GDataMediaGroup.h"

@implementation GDataMediaThumbnail
// media:thumbnail element
//
//   <media:thumbnail url="http://www.foo.com/keyframe.jpg" 
//                    width="75" height="50" time="12:05:01.123" />
//
// http://search.yahoo.com/mrss


+ (NSString *)extensionElementURI       { return kGDataNamespaceMedia; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceMediaPrefix; }
+ (NSString *)extensionElementLocalName { return @"thumbnail"; }

+ (GDataMediaThumbnail *)mediaContentWithURL:(NSString *)urlString {
  
  GDataMediaThumbnail *obj = [[[GDataMediaThumbnail alloc] init] autorelease];
  [obj setURLString:urlString];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setURLString:[self stringForAttributeName:@"url"
                                        fromElement:element]];
    [self setHeight:[self intNumberForAttributeName:@"height"
                                        fromElement:element]];
    [self setWidth:[self intNumberForAttributeName:@"width"
                                       fromElement:element]];
    NSString *timeStr = [self stringForAttributeName:@"time"
                                         fromElement:element];
    if ([timeStr length] > 0) {
      GDataNormalPlayTime *time = [GDataNormalPlayTime normalPlayTimeWithString:timeStr];
      if (time) {
        [self setTime:time];
      }
    }
  }
  return self;
}

- (void)dealloc {
  [urlString_ release];
  [height_ release];
  [width_ release];
  [time_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataMediaThumbnail* newObj = [super copyWithZone:zone];
  [newObj setURLString:urlString_];
  [newObj setHeight:height_];
  [newObj setWidth:width_];
  [newObj setTime:time_];
  return newObj; 
}

- (BOOL)isEqual:(GDataMediaThumbnail *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataMediaThumbnail class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self URLString], [other URLString])
    && AreEqualOrBothNil([self height], [other height])
    && AreEqualOrBothNil([self width], [other width])
    && AreEqualOrBothNil([self time], [other time]);
}

- (NSString *)description {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:urlString_ withName:@"URL"];
  [self addToArray:items objectDescriptionIfNonNil:height_ withName:@"height"];
  [self addToArray:items objectDescriptionIfNonNil:width_ withName:@"width"];
  [self addToArray:items objectDescriptionIfNonNil:time_ withName:@"time"];
  
  return [NSString stringWithFormat:@"%@ 0x%lX: {%@}",
    [self class], self, [items componentsJoinedByString:@" "]];
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"media:thumbnail"];
  
  [self addToElement:element attributeValueIfNonNil:[self URLString] withName:@"url"];
  [self addToElement:element attributeValueIfNonNil:[[self height] stringValue] withName:@"height"];
  [self addToElement:element attributeValueIfNonNil:[[self width] stringValue] withName:@"width"];
  
  if ([self time]) {
    NSString *timeStr = [[self time] HHMMSSString];
    [self addToElement:element attributeValueIfNonNil:timeStr withName:@"time"];
  }
  return element;
}

#pragma mark -

- (NSString *)URLString {
  return urlString_; 
}
- (void)setURLString:(NSString *)str {
  [urlString_ autorelease];
  urlString_ = [str copy];
}

- (NSNumber *)height {
  return height_; 
}
- (void)setHeight:(NSNumber *)num {
  [height_ autorelease];
  height_ = [num retain];
}

- (NSNumber *)width {
  return width_; 
}
- (void)setWidth:(NSNumber *)num {
  [width_ autorelease];
  width_ = [num retain];
}

- (GDataNormalPlayTime *)time {
  return time_;
}
- (void)setTime:(GDataNormalPlayTime *)time {
  [time_ autorelease];
  time_ = [time copy];
}

@end


