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

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CODESEARCH_SERVICE

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

+ (NSString *)standardEntryKind {
  return kGDataCategoryCodeSearch;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  Class entryClass = [self class];

  // CodeSearchEntry extensions

  [self addExtensionDeclarationForParentClass:entryClass
                                 childClasses:
   [GDataCodeSearchPackage class],
   [GDataCodeSearchFile class],
   [GDataCodeSearchMatch class],
   nil];  
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  static struct GDataDescriptionRecord descRecs[] = {
    { @"file",    @"file.name",     kGDataDescValueLabeled },
    { @"package", @"package.name",  kGDataDescValueLabeled },
    { @"matches", @"matches",       kGDataDescArrayCount },
    { nil, nil, 0 }
  };
  
  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

+ (NSString *)defaultServiceVersion {
  return kGDataCodeSearchDefaultServiceVersion;
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

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CODESEARCH_SERVICE
