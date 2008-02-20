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
//  GDataFeedLink.m
//


#import "GDataFeedLink.h"
#import "GDataFeedBase.h"

@implementation GDataFeedLink
// a link to a feed, like
// <gd:feedLink href="http://example.com/Jo/posts/MyFirstPost/comments" countHint="10">
//
// http://code.google.com/apis/gdata/common-elements.html#gdFeedLink

+ (NSString *)extensionElementURI       { return kGDataNamespaceGData; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementLocalName { return @"feedLink"; }

+ (GDataFeedLink *)feedLinkWithHref:(NSString *)href
                         isReadOnly:(BOOL)isReadOnly {
  GDataFeedLink* feedLink = [[[GDataFeedLink alloc] init] autorelease];
  [feedLink setHref:href];
  [feedLink setIsReadOnly:isReadOnly];
  return feedLink;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setHref:[self stringForAttributeName:@"href"
                                   fromElement:element]];
    [self setRel:[self stringForAttributeName:@"rel"
                                  fromElement:element]];
    [self setIsReadOnly:(nil != [self stringForAttributeName:@"readOnly"
                                                 fromElement:element])]; 
    
    [self setCountHint:[self intNumberForAttributeName:@"countHint"
                                           fromElement:element]];
    
    [self setFeed:[self objectForChildOfElement:element
                                  qualifiedName:@"feed"
                                   namespaceURI:kGDataNamespaceAtom
                                    objectClass:nil]];
  }
  return self;
}

- (void)dealloc {
  [href_ release];
  [countHint_ release];
  [rel_ release];
  [feed_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataFeedLink* newLink = [super copyWithZone:zone];
  [newLink setHref:href_];
  [newLink setIsReadOnly:isReadOnly_];
  [newLink setCountHint:countHint_];
  [newLink setRel:rel_];
  [newLink setFeed:feed_];
  return newLink;
}

- (BOOL)isEqual:(GDataFeedLink *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataFeedLink class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self href], [other href])
    && AreBoolsEqual([self isReadOnly], [other isReadOnly])
    && AreEqualOrBothNil([self countHint], [other countHint])
    && AreEqualOrBothNil([self rel], [other rel])
    && AreEqualOrBothNil([self feed], [other feed]);
}

- (NSArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:href_ withName:@"href"];
  
  NSString *roString = (isReadOnly_ ? @"true" : nil);
  [self addToArray:items objectDescriptionIfNonNil:roString withName:@"readOnly"];

  [self addToArray:items objectDescriptionIfNonNil:[countHint_ stringValue] withName:@"countHint"];
  [self addToArray:items objectDescriptionIfNonNil:feed_ withName:@"feed"];
  [self addToArray:items objectDescriptionIfNonNil:rel_ withName:@"rel"];

  return items;
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"gd:feedLink"];
  
  [self addToElement:element attributeValueIfNonNil:[self href] withName:@"href"];

  [self addToElement:element attributeValueIfNonNil:[self rel] withName:@"rel"];

  NSString *roString = (isReadOnly_ ? @"true" : nil);
  [self addToElement:element attributeValueIfNonNil:roString  withName:@"readOnly"];

  if ([self countHint]) {
    [self addToElement:element attributeValueIfNonNil:[countHint_ stringValue] withName:@"countHint"];
  }

  if ([self feed]) {
    [element addChild:[[self feed] XMLElement]];
  }
  return element;
}

- (NSString *)href {
  return href_; 
}

- (void)setHref:(NSString *)str {
  [href_ autorelease];
  href_ = [str copy];
}

- (BOOL)isReadOnly {
  return isReadOnly_; 
}

- (void)setIsReadOnly:(BOOL)isReadOnly {
  isReadOnly_ = isReadOnly;
}

- (NSNumber *)countHint {
  return countHint_; 
}

-(void)setCountHint:(NSNumber *)val {
  [countHint_ autorelease];
  countHint_ = [val retain]; 
}

- (NSString *)rel {
  return rel_; 
}

- (void)setRel:(NSString *)str {
  [rel_ autorelease];
  rel_ = [str copy];
}

- (GDataFeedBase *)feed {
  return feed_; 
}

- (void)setFeed:(GDataFeedBase *)feed {
  [feed_ autorelease];
  feed_ = [feed retain];
}

// convenience method

- (NSURL *)URL {
  if ([href_ length] > 0) {
    return [NSURL URLWithString:href_]; 
  }
  return nil;
}

@end

@implementation NSArray (GDataFeedLinkArray)
- (GDataFeedLink *)feedLinkWithRel:(NSString *)rel {
  
  NSEnumerator *enumerator = [self objectEnumerator]; 
  GDataFeedLink *feedLink;
  
  while ((feedLink = [enumerator nextObject]) != nil) {
    
    NSString *thisRel = [feedLink rel];
    
    if (AreEqualOrBothNil(rel, thisRel)) {
      return feedLink;
    }
  }
  return nil;  
}
@end

