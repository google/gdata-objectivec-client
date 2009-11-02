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
//  GDataEntryBlogComment.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BLOGGER_SERVICE

#import "GDataEntryBlogComment.h"
#import "GDataBloggerConstants.h"

@implementation GDataEntryBlogComment

+ (GDataEntryBlogComment *)commentEntry {

  GDataEntryBlogComment *obj = [[[self alloc] init] autorelease];

  [obj setNamespaces:[GDataBloggerConstants bloggerNamespaces]];

  return obj;
}

#pragma mark -

//+ (NSString *)standardEntryKind {
//  return kGDataCategoryBloggerComment;
//}
//
//+ (void)load {
//  [self registerEntryClass];
//}

- (void)addExtensionDeclarations {
  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataInReplyTo class]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {


  struct GDataDescriptionRecord descRecs[] = {
    { @"inReplyTo", @"inReplyTo", kGDataDescValueLabeled   },
    { nil, nil, 0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

+ (NSString *)defaultServiceVersion {
  return kGDataBloggerDefaultServiceVersion;
}

#pragma mark -

- (GDataInReplyTo *)inReplyTo {
  GDataInReplyTo *obj = [self objectForExtensionClass:[GDataInReplyTo class]];
  return obj;
}

- (void)setInReplyTo:(GDataInReplyTo *)obj {
  [self setObject:obj forExtensionClass:[GDataInReplyTo class]];
}

#pragma mark -

- (GDataLink *)repliesLink {
  return [self linkWithRelAttributeValue:kGDataLinkBloggerReplies];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BLOGGER_SERVICE
