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

@implementation GDataAtomPubControl1_0
+ (NSString *)extensionElementURI       { return kGDataNamespaceAtomPub1_0; }
+ (NSString *)extensionElementPrefix    { return [super extensionElementPrefix]; }
+ (NSString *)extensionElementLocalName { return [super extensionElementLocalName]; }
@end

@implementation GDataAtomPubControl

// For app:control, like:
//   <app:control><app:draft>yes</app:draft></app:control>

+ (NSString *)extensionElementURI       { return kGDataNamespaceAtomPubStd; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAtomPubPrefix; }
+ (NSString *)extensionElementLocalName { return @"control"; }

+ (GDataAtomPubControl *)atomPubControl {
  GDataAtomPubControl *obj = [[[GDataAtomPubControl alloc] init] autorelease];
  
  // add the "app" namespace
  NSString *nsURI = [[self class] extensionElementURI];
  NSDictionary *namespace = [NSDictionary dictionaryWithObject:nsURI 
                                                        forKey:kGDataNamespaceAtomPubPrefix];
  [obj setNamespaces:namespace];

  return obj;
}

+ (GDataAtomPubControl *)atomPubControlWithIsDraft:(BOOL)isDraft {
  GDataAtomPubControl *obj = [self atomPubControl];
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
    NSString *namespaceURI = [[self class] extensionElementURI];
    
    NSXMLElement *draftElement = [self childWithQualifiedName:@"app:draft"
                                                 namespaceURI:namespaceURI
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
  [newObj setIsDraft:[self isDraft]];
  return newObj;
}

- (BOOL)isEqual:(GDataAtomPubControl *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataAtomPubControl class]]) return NO;
  
  return [super isEqual:other]
    && ([self isDraft] == [other isDraft]);
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  NSString *str = ([self isDraft] ? @"yes" : @"no");
  [self addToArray:items objectDescriptionIfNonNil:str 
          withName:@"isDraft"];
  
  return items;
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:nil];

  if ([self isDraft]) {
    
    NSString *name = [NSString stringWithFormat:@"%@:draft", 
      kGDataNamespaceAtomPubPrefix];
      
    [self addToElement:element
 childWithStringValueIfNonEmpty:@"yes"
              withName:name];
  }
  
  return element;
}

- (BOOL)isDraft {
  return isDraft_;
}

- (void)setIsDraft:(BOOL)isDraft {
  isDraft_ = isDraft;
}

#pragma mark -

+ (Class)atomPubControlClassForObject:(GDataObject *)obj {
  // version 1 of GData used a preliminary namespace URI for the atom pub 
  // element; the standard version of the class uses the proper URI
  if ([obj isServiceVersion1]) {
    return [GDataAtomPubControl1_0 class];
  } else {
    return [GDataAtomPubControl class];
  }
}

@end

