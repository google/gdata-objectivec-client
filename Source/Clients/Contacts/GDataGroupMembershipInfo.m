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
//  GDataGroupMembershipInfo.m
//

#import "GDataGroupMembershipInfo.h" 
#import "GDataEntryContact.h"         // for namespace

@implementation GDataGroupMembershipInfo 
//
// group membership info 
//
// <gContact:groupMembershipInfo href="http://..." deleted="false" />
//

+ (NSString *)extensionElementURI       { return kGDataNamespaceContact; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceContactPrefix; }
+ (NSString *)extensionElementLocalName { return @"groupMembershipInfo"; }

+ (GDataGroupMembershipInfo *)groupMembershipInfoWithHref:(NSString *)str {
  
  GDataGroupMembershipInfo *obj = [[[GDataGroupMembershipInfo alloc] init] autorelease];
  [obj setHref:str];
  return obj;
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setHref:[self stringForAttributeName:@"href"
                                   fromElement:element]];
    [self setIsDeleted:[self boolForAttributeName:@"deleted"
                                      fromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [href_ release];
  [super dealloc];
}


- (BOOL)isEqual:(GDataGroupMembershipInfo *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataGroupMembershipInfo class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self href], [other href])
    && AreBoolsEqual([self isDeleted], [other isDeleted]);
}

- (id)copyWithZone:(NSZone *)zone {
  GDataGroupMembershipInfo* newObj = [super copyWithZone:zone];
  [newObj setHref:[self href]];
  [newObj setIsDeleted:[self isDeleted]];
  return newObj;
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:[self href] withName:@"href"];
  
  if ([self isDeleted]) [items addObject:@"deleted"];
  
  return items;
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:nil];

  [self addToElement:element attributeValueIfNonNil:[self href] withName:@"href"];
  if ([self isDeleted]) {
    [self addToElement:element attributeValueIfNonNil:@"true" withName:@"deleted"];
  }

  return element;
}

#pragma mark -

- (NSString *)href {
  return href_; 
}

- (void)setHref:(NSString *)str {
  [href_ autorelease];
  href_ = [str copy];
}

- (BOOL)isDeleted {
  return isDeleted_; 
}

- (void)setIsDeleted:(BOOL)flag {
  isDeleted_ = flag;
}

@end
