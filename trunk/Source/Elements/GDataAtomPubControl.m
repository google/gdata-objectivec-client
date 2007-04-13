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
//  GDataAtomPubControl.m
//

#import "GDataAtomPubControl.h"

@implementation GDataAtomPubControl

// For app:control, like:
//   <app:control><app:draft>yes</app:draft></app:control>

+ (NSString *)extensionElementURI       { return kGDataNamespaceAtomPub; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAtomPubPrefix; }
+ (NSString *)extensionElementLocalName { return @"control"; }


+ (GDataAtomPubControl *)atomPubControlWithIsDraft:(BOOL)isDraft {
  GDataAtomPubControl *obj = [[[GDataAtomPubControl alloc] init] autorelease];
  [obj setIsDraft:isDraft];
  return obj;
}

- (id)init {
  self = [super init];
  if (self) {
  }
  return self;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    // get the <app:draft>yes</app:draft> from inside the <app:control>
    NSXMLElement *draftElement = [self childWithQualifiedName:@"app:draft"
                                                 namespaceURI:kGDataNamespaceAtomPub
                                                  fromElement:element];
    if (draftElement) {
      NSString *draftStr = [self stringValueFromElement:draftElement];
      BOOL isDraft = (NSOrderedSame == [draftStr caseInsensitiveCompare:@"yes"]);
      [self setIsDraft:isDraft];
    }
  }
  return self;
}

- (id)copyWithZone:(NSZone *)zone {
  GDataAtomPubControl* newObj = [super copyWithZone:zone];
  [newObj setIsDraft:isDraft_];
  return newObj;
}

- (BOOL)isEqual:(GDataAtomPubControl *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataAtomPubControl class]]) return NO;
  
  return [super isEqual:other]
    && ([self isDraft] == [other isDraft]);
}

- (NSString *)description {
  NSMutableArray *items = [NSMutableArray array];
  
  NSString *str = ([self isDraft] ? @"yes" : @"no");
  [self addToArray:items objectDescriptionIfNonNil:str 
          withName:@"isDraft"];
  
  return [NSString stringWithFormat:@"%@ 0x%lX: {%@}",
    [self class], self, [items componentsJoinedByString:@" "]];
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"app:control"];

  if ([self isDraft]) {
    [self addToElement:element
 childWithStringValueIfNonEmpty:@"yes"
              withName:@"app:draft"];
  }
  
  return element;
}

- (BOOL)isDraft {
  return isDraft_;
}

- (void)setIsDraft:(BOOL)isDraft {
  isDraft_ = isDraft;
}

@end

