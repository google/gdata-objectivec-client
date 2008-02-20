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
//  GDataEntryCodeSearch.m
//

#define GDATAENTRYCODESEARCH_DEFINE_GLOBALS 1
#import "GDataEntryCodeSearch.h"


// extensions

// CodeSearchEntry extensions

@implementation GDataEntryCodeSearch

+ (NSDictionary *)codeSearchNamespaces {
  NSMutableDictionary *namespaces;
  namespaces = [NSMutableDictionary dictionaryWithObject:kGDataNamespaceCodeSearch
                                                  forKey:kGDataNamespaceCodeSearchPrefix];
  
  [namespaces addEntriesFromDictionary:[GDataEntryBase baseGDataNamespaces]];
  
  return namespaces;
}

+ (GDataEntryCodeSearch *)codeSearchEntryWithFile:(GDataCodeSearchFile *)file
                                          package:(GDataCodeSearchPackage *)package {
  GDataEntryCodeSearch *obj = [[[GDataEntryCodeSearch alloc] init] autorelease];
  [obj setFile:file];
  [obj setPackage:package];
  return obj;
}

#pragma mark -

+ (void)load {
  [GDataObject registerEntryClass:[self class]
            forCategoryWithScheme:kGDataCategoryScheme 
                             term:kGDataCategoryCodeSearch];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];
  
  // CodeSearchEntry extensions
  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataCodeSearchPackage class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataCodeSearchFile class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataCodeSearchMatch class]];  
}

- (id)init {
  self = [super init];
  if (self) {
    // since we're creating this without XML, be sure it has a category
    GDataCategory *category = [GDataCategory categoryWithScheme:kGDataCategoryScheme
                                                           term:kGDataCategoryCodeSearch];
    [self addCategory:category];
  }
  return self;
}

- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];

  [self addToArray:items objectDescriptionIfNonNil:[[self file] name] withName:@"file"];
  [self addToArray:items objectDescriptionIfNonNil:[[self package] name] withName:@"package"];
  [self addToArray:items arrayCountIfNonEmpty:[self matches] withName:@"matches"];
  
  return items;
}


#pragma mark -

- (GDataCodeSearchFile *)file {
  return [self objectForExtensionClass:[GDataCodeSearchFile class]];  
}

- (void)setFile:(GDataCodeSearchFile *)file {
  [self setObject:file forExtensionClass:[GDataCodeSearchFile class]];
}

- (GDataCodeSearchPackage *)package {
  return [self objectForExtensionClass:[GDataCodeSearchPackage class]];  
}

- (void)setPackage:(GDataCodeSearchPackage *)package {
  [self setObject:package forExtensionClass:[GDataCodeSearchPackage class]];
}

- (NSArray *)matches {
  return [self objectsForExtensionClass:[GDataCodeSearchMatch class]];
}

- (void)setMatches:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataCodeSearchMatch class]];
}

- (void)addMatch:(GDataCodeSearchMatch *)obj {
  [self addObject:obj forExtensionClass:[GDataCodeSearchMatch class]];
}

@end
