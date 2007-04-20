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
//  GDataWebContent.m
//

#import "GDataWebContent.h"
#import "GDataEntryCalendarEvent.h"

@implementation GDataWebContent 
// Calendar Web Content element, inside a <link>, as in
//
// <gCal:webContent url="http://www.google.com/logos/july4th06.gif" width="276" height="120" />
//
// view-source:http://code.google.com/apis/gdata/calendar.html#gCalwebContent

+ (GDataWebContent *)webContentWithURL:(NSString *)urlString
                                 width:(int)width
                                height:(int)height {
  GDataWebContent *obj = [[[GDataWebContent alloc] init] autorelease];
  [obj setURLString:urlString];
  [obj setWidth:[NSNumber numberWithInt:width]];
  [obj setHeight:[NSNumber numberWithInt:height]];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setHeight:[self intNumberForAttributeName:@"height" 
                                        fromElement:element]];
    [self setWidth:[self intNumberForAttributeName:@"width" 
                                       fromElement:element]];
    [self setURLString:[self stringForAttributeName:@"url" 
                                        fromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [height_ release];
  [width_ release];
  [url_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataWebContent* newObj = [super copyWithZone:zone];
  [newObj setHeight:height_];
  [newObj setWidth:width_];
  [newObj setURLString:url_];
  return newObj;
}

- (BOOL)isEqual:(GDataWebContent *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataWebContent class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self height], [other height])
    && AreEqualOrBothNil([self width], [other width])
    && AreEqualOrBothNil([self URLString], [other URLString]);
}

- (NSString *)description {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:height_ withName:@"height"];
  [self addToArray:items objectDescriptionIfNonNil:width_ withName:@"width"];
  [self addToArray:items objectDescriptionIfNonNil:url_ withName:@"URL"];
  
  return [NSString stringWithFormat:@"%@ 0x%lX: {%@}",
    [self class], self, [items componentsJoinedByString:@" "]];
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"gCal:webContent"];
  
  [self addToElement:element attributeValueIfNonNil:[[self height] stringValue] withName:@"height"];
  [self addToElement:element attributeValueIfNonNil:[[self width] stringValue] withName:@"width"];
  [self addToElement:element attributeValueIfNonNil:[self URLString] withName:@"url"];
  
  return element;
}

+ (NSString *)extensionElementURI       { return kGDataNamespaceGCal; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGCalPrefix; }
+ (NSString *)extensionElementLocalName { return @"webContent"; }

- (NSNumber *)height {
  return height_; 
}

- (void)setHeight:(NSNumber *)num {
  [height_ autorelease];
  height_ = [num copy];
}

- (NSNumber *)width {
  return width_; 
}

- (void)setWidth:(NSNumber *)num {
  [width_ autorelease];
  width_ = [num copy];
}

- (NSString *)URLString {
  return url_; 
}

- (void)setURLString:(NSString *)str {
  [url_ autorelease];
  url_ = [str copy];
}
@end

