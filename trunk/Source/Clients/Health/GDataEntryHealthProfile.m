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
//  GDataEntryHealthProfile.m
//

#define GDATAENTRYHEALTHPROFILE_DEFINE_GLOBALS 1
#import "GDataEntryHealthProfile.h"

#import "GDataHealthElements.h"

@implementation GDataEntryHealthProfile

+ (NSDictionary *)healthNamespaces {
  NSMutableDictionary *namespaces;

  namespaces = [NSMutableDictionary dictionaryWithObject:kGDataNamespaceCCR
                                                  forKey:kGDataNamespaceCCRPrefix];

  [namespaces addEntriesFromDictionary:[GDataEntryBase baseGDataNamespaces]];

  return namespaces;
}

+ (id)profileEntry {

  GDataEntryHealthProfile *obj = [[[self alloc] init] autorelease];

  [obj setNamespaces:[self healthNamespaces]];

  return obj;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategoryH9Profile;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                 childClasses:
   [GDataContinuityOfCareRecord class],
   [GDataProfileMetaData class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"CCR",             @"continuityOfCareRecord", kGDataDescLabelIfNonNil },
    { @"profileMetaData", @"profileMetaData",        kGDataDescLabelIfNonNil },
    { nil, nil, 0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

+ (NSString *)defaultServiceVersion {
  return kGDataHealthDefaultServiceVersion;
}

#pragma mark -

- (GDataContinuityOfCareRecord *)continuityOfCareRecord {
  return [self objectForExtensionClass:[GDataContinuityOfCareRecord class]];
}

- (void)setContinuityOfCareRecord:(GDataContinuityOfCareRecord *)obj {
  [self setObject:obj forExtensionClass:[GDataContinuityOfCareRecord class]];
}

- (GDataProfileMetaData *)profileMetaData {
  return [self objectForExtensionClass:[GDataProfileMetaData class]];
}

- (void)setProfileMetaData:(GDataProfileMetaData *)obj {
  [self setObject:obj forExtensionClass:[GDataProfileMetaData class]];
}

// convenience accessor method
- (GDataLink *)completeLink {
  return [self linkWithRelAttributeValue:kGDataHealthRelComplete];
}

@end
