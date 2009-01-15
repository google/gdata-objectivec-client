/* Copyright (c) 2009 Google Inc.
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
//  GDataAtomWorkspace.m
//

#import "GDataAtomWorkspace.h"
#import "GDataAtomCollection.h"
#import "GDataBaseElements.h"

static NSString *const kTitleAttr = @"title";

@implementation GDataAtomWorkspace1_0
+ (NSString *)extensionElementURI       { return kGDataNamespaceAtomPub1_0; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAtomPubPrefix; }
+ (NSString *)extensionElementLocalName { return @"workspace"; }

+ (Class)collectionClass {
  return  [GDataAtomCollection1_0 class];
}

- (void)addParseDeclarations {
  // version 1 has a title attribute rather than storing the title in a child
  // element
  NSArray *attrs = [NSArray arrayWithObject:kTitleAttr];

  [self addLocalAttributeDeclarations:attrs];
}

- (GDataTextConstruct *)title {
  // v1 keeps the title in an attribute
  NSString *str = [self stringValueForAttribute:kTitleAttr];
  GDataTextConstruct *obj = [GDataTextConstruct textConstructWithString:str];
  return obj;
}

- (void)setTitle:(GDataTextConstruct *)obj {

  [self setStringValue:[obj stringValue] forAttribute:kTitleAttr];
}

@end

@implementation GDataAtomWorkspace

+ (NSString *)extensionElementURI       { return kGDataNamespaceAtomPubStd; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAtomPubPrefix; }
+ (NSString *)extensionElementLocalName { return @"workspace"; }

+ (Class)collectionClass {
  return [GDataAtomCollection class];
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  Class collectionClass = [[self class] collectionClass];

  [self addExtensionDeclarationForParentClass:[self class]
                                 childClasses:
   collectionClass,
   [GDataAtomTitle class],
   nil];
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [super itemsForDescription];

  [self addToArray:items objectDescriptionIfNonNil:[[self title] stringValue] withName:@"title"];
  [self addToArray:items arrayDescriptionIfNonEmpty:[self collections] withName:@"collections"];

  return items;
}

#pragma mark -

- (GDataTextConstruct *)title {
  return [self objectForExtensionClass:[GDataAtomTitle class]];
}

- (void)setTitle:(GDataTextConstruct *)obj {
  [self setObject:obj forExtensionClass:[GDataAtomTitle class]];
}

- (NSArray *)collections {
  Class collectionClass = [[self class] collectionClass];

  NSArray *array = [self objectsForExtensionClass:collectionClass];
  return array;
}

- (void)setCollections:(NSArray *)array {
  Class collectionClass = [[self class] collectionClass];

  [self setObjects:array forExtensionClass:collectionClass];
}

@end
