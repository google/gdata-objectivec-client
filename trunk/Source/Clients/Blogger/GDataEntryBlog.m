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
//  GDataEntryBlog.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BLOGGER_SERVICE

#import "GDataEntryBlog.h"
#import "GDataBloggerConstants.h"

@implementation GDataEntryBlog

+ (GDataEntryBlog *)blogEntry {

  GDataEntryBlog *obj = [self object];

  [obj setNamespaces:[GDataBloggerConstants bloggerNamespaces]];

  return obj;
}

#pragma mark -

//+ (NSString *)standardEntryKind {
//  return kGDataCategoryBlogger;
//}
//
//+ (void)load {
//  [self registerEntryClass];
//}

+ (NSString *)defaultServiceVersion {
  return kGDataBloggerDefaultServiceVersion;
}

#pragma mark -

- (GDataLink *)repliesLink {
  return [self linkWithRelAttributeValue:kGDataLinkBloggerReplies];
}

- (GDataLink *)settingsLink {
  return [self linkWithRelAttributeValue:kGDataLinkBloggerSettings];
}

- (GDataLink *)templateLink {
  return [self linkWithRelAttributeValue:kGDataLinkBloggerTemplate];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BLOGGER_SERVICE
