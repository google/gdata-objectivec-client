/* Copyright (c) 2011 Google Inc.
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
//  GDataFeedDocChange.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE

#import "GDataFeedDocChange.h"
#import "GDataEntryDocChange.h"
#import "GDataDocElements.h"

@implementation GDataFeedDocChange

+ (NSString *)coreProtocolVersionForServiceVersion:(NSString *)serviceVersion {
  return [GDataDocConstants coreProtocolVersionForServiceVersion:serviceVersion];
}

+ (NSString *)standardFeedKind {
  return kGDataCategoryDocChange;
}

+ (void)load {
  [self registerFeedClass];
}

- (void)addExtensionDeclarations {
  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataDocLargestChangestamp class]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"largestChangestamp", @"largestChangestamp", kGDataDescValueLabeled },
    { nil, nil, (GDataDescRecTypes)0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

+ (NSString *)defaultServiceVersion {
  return kGDataDocsDefaultServiceVersion;
}

- (Class)classForEntries {
  return kUseRegisteredEntryClass;
}

// A changefeed is a list of Documents that have changed
// therefore we return a DocBase as a default class for this feed.
+ (Class)defaultClassForEntries {
  return [GDataEntryDocBase class];
}

#pragma mark -

- (NSNumber *)largestChangestamp {
  GDataDocLargestChangestamp *obj;
  obj = [self objectForExtensionClass:[GDataDocLargestChangestamp class]];
  return [obj longLongNumberValue];
}

- (void)setLargestChangestamp:(NSNumber *)num {
  GDataDocLargestChangestamp *obj;
  obj = [GDataDocLargestChangestamp valueWithNumber:num];
  [self setObject:obj forExtensionClass:[GDataDocLargestChangestamp class]];
}

#pragma mark -

- (NSNumber *)lastEntryChangestamp {
  GDataEntryDocBase *lastEntry = [[self entries] lastObject];
  NSNumber *result = [lastEntry changestamp];
  return result;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE
