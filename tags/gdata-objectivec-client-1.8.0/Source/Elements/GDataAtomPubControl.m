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
#import "GDataValueConstruct.h"

// app:draft, like
//   <app:draft>yes<app:draft>

// In version 1 of GData, a pre-standard URI was used for app elements
@interface GDataAtomPubDraft : GDataValueElementConstruct <GDataExtension>
@end

@interface GDataAtomPubDraft1_0 : GDataAtomPubDraft <GDataExtension>
@end

@implementation GDataAtomPubDraft
+ (NSString *)extensionElementURI       { return kGDataNamespaceAtomPubStd; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAtomPubPrefix; }
+ (NSString *)extensionElementLocalName { return @"draft"; }
@end

@implementation GDataAtomPubDraft1_0
+ (NSString *)extensionElementURI       { return kGDataNamespaceAtomPub1_0; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAtomPubPrefix; }
+ (NSString *)extensionElementLocalName { return [super extensionElementLocalName]; }
@end


@implementation GDataAtomPubControl1_0
+ (NSString *)extensionElementURI       { return kGDataNamespaceAtomPub1_0; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAtomPubPrefix; }
+ (NSString *)extensionElementLocalName { return [super extensionElementLocalName]; }
@end

@implementation GDataAtomPubControl

// For app:control, like:
//   <app:control><app:draft>yes</app:draft></app:control>

+ (NSString *)extensionElementURI       { return kGDataNamespaceAtomPubStd; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAtomPubPrefix; }
+ (NSString *)extensionElementLocalName { return @"control"; }

+ (GDataAtomPubControl *)atomPubControl {
  GDataAtomPubControl *obj = [[[self alloc] init] autorelease];

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

- (Class)draftExtensionClass {
  if ([self isKindOfClass:[GDataAtomPubControl1_0 class]]) {
    return [GDataAtomPubDraft1_0 class];
  } else {
    return [GDataAtomPubDraft class];
  }
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[self draftExtensionClass]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];

  NSString *str = ([self isDraft] ? @"yes" : @"no");
  [self addToArray:items objectDescriptionIfNonNil:str
          withName:@"isDraft"];

  return items;
}
#endif

- (BOOL)isDraft {
  GDataValueElementConstruct *obj;

  obj = [self objectForExtensionClass:[self draftExtensionClass]];

  NSString *str = [obj stringValue];
  BOOL isDraft = (str != nil
                  && [str caseInsensitiveCompare:@"yes"] == NSOrderedSame);
  return isDraft;
}

- (void)setIsDraft:(BOOL)isDraft {

  Class draftClass = [self draftExtensionClass];

  id obj = nil;
  if (isDraft) {
    obj = [draftClass valueWithString:@"yes"];
  }

  [self setObject:obj forExtensionClass:draftClass];
}

#pragma mark -

+ (Class)atomPubControlClassForObject:(GDataObject *)obj {
  // version 1 of GData used a preliminary namespace URI for the atom pub
  // element; the standard version of the class uses the proper URI
  if ([obj isCoreProtocolVersion1]) {
    return [GDataAtomPubControl1_0 class];
  } else {
    return [GDataAtomPubControl class];
  }
}

@end


