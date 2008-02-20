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
//  GDataMediaPlayer.m
//


#import "GDataMediaPlayer.h"
#import "GDataMediaGroup.h"

@implementation GDataMediaPlayer
// like  <media:player url="http://www.foo.com/player?id=1111" height="200" width="400" />
//
// http://search.yahoo.com/mrss

+ (NSString *)extensionElementURI       { return kGDataNamespaceMedia; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceMediaPrefix; }
+ (NSString *)extensionElementLocalName { return @"player"; }

+ (GDataMediaPlayer *)mediaPlayerWithURLString:(NSString *)str {
  GDataMediaPlayer* obj = [[[GDataMediaPlayer alloc] init] autorelease];
  [obj setURLString:str];
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
  }
  return self;
}

- (void)dealloc {
  [urlString_ release];
  [height_ release];
  [width_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataMediaPlayer* newObj = [super copyWithZone:zone];
  [newObj setURLString:urlString_];
  [newObj setHeight:height_];
  [newObj setWidth:width_];
  return newObj;
}

- (BOOL)isEqual:(GDataMediaPlayer *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataMediaPlayer class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self URLString], [other URLString])
    && AreEqualOrBothNil([self height], [other height])
    && AreEqualOrBothNil([self width], [other width]);
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:urlString_ withName:@"URL"];
  [self addToArray:items objectDescriptionIfNonNil:height_ withName:@"height"];
  [self addToArray:items objectDescriptionIfNonNil:width_ withName:@"width"];
  
  return items;
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:nil];
  
  [self addToElement:element attributeValueIfNonNil:[self URLString] withName:@"url"];
  [self addToElement:element attributeValueIfNonNil:[[self height] stringValue] withName:@"height"];
  [self addToElement:element attributeValueIfNonNil:[[self width] stringValue] withName:@"width"];
  
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


@end


