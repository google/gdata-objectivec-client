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
//  GDataComment.m
//

#import "GDataComment.h"

#import "GDataFeedLink.h"

@implementation GDataComment
// a commments entry, as in
// <gd:comments>
//    <gd:feedLink href="http://www.google.com/calendar/feeds/t..."/>
// </gd:comments>
//
// http://code.google.com/apis/gdata/common-elements.html#gdComments

+ (NSString *)extensionElementURI       { return kGDataNamespaceGData; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementLocalName { return @"comments"; }

+ (GDataComment *)commentWithFeedLink:(GDataFeedLink *)feedLink {
  GDataComment *obj = [[[GDataComment alloc] init] autorelease];
  [obj setFeedLink:feedLink];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setRel:[self stringForAttributeName:@"rel" 
                                  fromElement:element]];
    [self setFeedLink:[self objectForChildOfElement:element
                                      qualifiedName:@"gd:feedLink"
                                       namespaceURI:kGDataNamespaceGData
                                        objectClass:[GDataFeedLink class]]];
  }
  return self;
}

- (void)dealloc {
  [rel_ release];
  [feedLink_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataComment* newComment = [super copyWithZone:zone];
  [newComment setFeedLink:feedLink_];
  [newComment setRel:rel_];
  return newComment;
}

- (BOOL)isEqual:(GDataComment *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataComment class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self rel], [other rel])
    && AreEqualOrBothNil([self feedLink], [other feedLink]);
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:rel_ withName:@"rel"];
  [self addToArray:items objectDescriptionIfNonNil:feedLink_ withName:@"feedLink"];
  
  return items;
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"gd:comments"];

  [self addToElement:element attributeValueIfNonNil:[self rel] withName:@"rel"];

  if (feedLink_) {
    [element addChild:[feedLink_ XMLElement]];
  }
  return element;
}

- (NSString *)rel {
  return rel_;
}

- (void)setRel:(NSString *)str {
  [rel_ autorelease];
  rel_ = [str copy];
}

- (GDataFeedLink *)feedLink {
  return feedLink_;
}

- (void)setFeedLink:(GDataFeedLink *)newLink {
  [feedLink_ autorelease];
  feedLink_ = [newLink retain];
}
@end
