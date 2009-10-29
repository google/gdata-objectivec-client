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

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_HEALTH_SERVICE

#import "GDataEntryHealthProfile.h"

#import "GDataHealthConstants.h"
#import "GDataHealthElements.h"

@implementation GDataEntryHealthProfile

+ (id)profileEntry {

  GDataEntryHealthProfile *obj = [[[self alloc] init] autorelease];

  [obj setNamespaces:[GDataHealthConstants healthNamespaces]];

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

// convenience accessor methods

- (GDataLink *)completeLink {
  return [self linkWithRelAttributeValue:kGDataHealthRelComplete];
}

- (GDataLink *)nextLink {
  return [self linkWithRelAttributeValue:@"next"];
}

- (GDataCategory *)healthItemCategory {
  NSArray *categories = [self categories];
  GDataCategory *category = [GDataUtilities firstObjectFromArray:categories
                                                       withValue:kGDataHealthSchemeItem
                                                      forKeyPath:@"scheme"];
  return category;
}

- (GDataCategory *)CCRCategory {
  NSArray *categories = [self categories];
  GDataCategory *category = [GDataUtilities firstObjectFromArray:categories
                                                       withValue:kGDataHealthSchemeCCR
                                                      forKeyPath:@"scheme"];
  if (category == nil) {
    // CCR categories may be missing a scheme element, since CCR is implicit
    category = [GDataUtilities firstObjectFromArray:categories
                                          withValue:nil
                                         forKeyPath:@"scheme"];
  }

  return category;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_HEALTH_SERVICE
