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
//  GDataEntryLink.m
//

#import "GDataEntryLink.h"

#import "GDataEntryBase.h"

@implementation GDataEntryLink
// used instead GDataWhere, a link to an entry, like
// <gd:entryLink href="http://gmail.com/jo/contacts/Jo">

+ (GDataEntryLink *)entryLinkWithHref:(NSString *)href
                           isReadOnly:(BOOL)isReadOnly {
  GDataEntryLink* entryLink = [[[GDataEntryLink alloc] init] autorelease];
  [entryLink setHref:href];
  [entryLink setIsReadOnly:isReadOnly];
  return entryLink;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setHref:[self stringForAttributeName:@"href" 
                                   fromElement:element]];
    [self setIsReadOnly:(nil != [self stringForAttributeName:@"readOnly"
                                                 fromElement:element])];
    [self setEntry:[self objectForChildOfElement:element
                                   qualifiedName:@"entry"
                                    namespaceURI:kGDataNamespaceAtom
                                     objectClass:nil]];
  }
  return self;
}

- (void)dealloc {
  [href_ release];
  [entry_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataEntryLink* newLink = [super copyWithZone:zone];
  [newLink setHref:href_];
  [newLink setIsReadOnly:isReadOnly_];
  [newLink setEntry:entry_];
  return newLink;
}

- (BOOL)isEqual:(GDataEntryLink *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataEntryLink class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self href], [other href])
    && (![self isReadOnly] == ![other isReadOnly])  // !'s to avoid bool-compare errors
    && (AreEqualOrBothNil([self entry], [other entry]));
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:href_ withName:@"href"];
  
  NSString *roString = (isReadOnly_ ? @"true" : nil);
  [self addToArray:items objectDescriptionIfNonNil:roString withName:@"readOnly"];
    
  [self addToArray:items objectDescriptionIfNonNil:entry_ withName:@"entry"];

  return items;
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"gd:entryLink"];
  
  [self addToElement:element attributeValueIfNonNil:[self href] withName:@"href"];

  NSString *roString = (isReadOnly_ ? @"true" : nil);
  [self addToElement:element attributeValueIfNonNil:roString  withName:@"readOnly"];
  
  if ([self entry]) {
    [element addChild:[entry_ XMLElement]];
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

- (GDataEntryBase *)entry {
  return entry_;  
}

- (void)setEntry:(GDataEntryBase *)entry {
  [entry_ autorelease];
  entry_ = [entry retain];
}

@end

