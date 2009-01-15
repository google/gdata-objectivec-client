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
//  GDataAtomServiceDocument.m
//

// app:service, an Atom service document,
// per http://tools.ietf.org/html/rfc5023#section-8.3.1

#import "GDataAtomServiceDocument.h"
#import "GDataAtomWorkspace.h"

@implementation GDataAtomServiceDocument1_0

+ (Class)workspaceClass {
  return [GDataAtomWorkspace1_0 class];
}

+ (NSString *)defaultServiceVersion {
  return @"1.0";
}

@end

@implementation GDataAtomServiceDocument

+ (Class)workspaceClass {
  return [GDataAtomWorkspace class];
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  Class workspaceClass = [[self class] workspaceClass];

  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:workspaceClass];
}

- (NSMutableArray *)itemsForDescription {

  NSMutableArray *items = [super itemsForDescription];

  [self addToArray:items arrayDescriptionIfNonEmpty:[self workspaces] withName:@"workspaces"];

  return items;
}

#pragma mark -

- (NSArray *)workspaces {
  Class workspaceClass = [[self class] workspaceClass];

  NSArray *array = [self objectsForExtensionClass:workspaceClass];
  return array;
}

- (void)setWorkspaces:(NSArray *)array {
  Class workspaceClass = [[self class] workspaceClass];

  [self setObjects:array forExtensionClass:workspaceClass];
}

+ (NSString *)defaultServiceVersion {
  return @"2.0";
}

@end
