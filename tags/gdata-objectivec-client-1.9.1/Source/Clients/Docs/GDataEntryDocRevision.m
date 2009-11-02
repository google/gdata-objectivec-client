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
//  GDataEntryDocRevision.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE

#import "GDataEntryDocRevision.h"
#import "GDataDocConstants.h"

@implementation GDataEntryDocRevision

+ (NSString *)coreProtocolVersionForServiceVersion:(NSString *)serviceVersion {
  return [GDataDocConstants coreProtocolVersionForServiceVersion:serviceVersion];
}

+ (NSString *)standardEntryKind {
  return kGDataCategoryDocRevision;
}

+ (void)load {
  [self registerEntryClass];
}

+ (id)revisionEntry {
  GDataEntryDocRevision *obj = [[[self alloc] init] autorelease];

  [obj setNamespaces:[GDataDocConstants baseDocumentNamespaces]];

  return obj;

}

#pragma mark -

- (GDataPerson *)modifyingUser {
  NSArray *authors = [self authors];
  if ([authors count] > 0) {
    GDataPerson *obj = [authors objectAtIndex:0];
    return obj;
  }
  return nil;
}

- (void)setModifyingUser:(GDataPerson *)obj {
  NSArray *authors;
  if (obj != nil) {
    authors = [NSArray arrayWithObject:obj];
  } else {
    authors = nil;
  }
  [self setAuthors:authors];
}

- (GDataLink *)publishedLink {
  return [self linkWithRelAttributeValue:kGDataDocsPublishedRel];
}

+ (NSString *)defaultServiceVersion {
  return kGDataDocsDefaultServiceVersion;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE
