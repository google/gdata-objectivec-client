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
//  GDataEntryHealthRegister.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_HEALTH_SERVICE
#import "GDataEntryHealthRegister.h"

#import "GDataHealthElements.h"
#import "GDataHealthConstants.h"

@implementation GDataEntryHealthRegister

+ (id)registerEntry {

  GDataEntryHealthRegister *obj = [[[self alloc] init] autorelease];

  [obj setNamespaces:[GDataHealthConstants healthNamespaces]];

  return obj;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategoryH9Register;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataContinuityOfCareRecord class]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"CCR", @"continuityOfCareRecord", kGDataDescLabelIfNonNil },
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

#pragma mark -

// convenience accessor method
- (GDataLink *)completeLink {
  return [self linkWithRelAttributeValue:kGDataHealthRelComplete];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_HEALTH_SERVICE
