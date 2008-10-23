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
//  GDataEntryDocBase.m
//

#define GDATAENTRYDOCBASE_DEFINE_GLOBALS 1
#import "GDataEntryDocBase.h"
#import "GDataEntryACL.h"

@implementation GDataEntryDocBase

+ (NSDictionary *)baseDocumentNamespaces {
  
  NSMutableDictionary *namespaces;
  
  namespaces = [NSMutableDictionary dictionaryWithDictionary:
    [GDataEntryBase baseGDataNamespaces]];
  
  return namespaces;  
}

+ (id)documentEntry {
  
  GDataEntryDocBase *entry = [[[self alloc] init] autorelease];
  
  [entry setNamespaces:[self baseDocumentNamespaces]];
  
  return entry;
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  // ACL feed URL is in a gd:feedLink
  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataFeedLink class]];
}

#pragma mark -

- (BOOL)isStarred {
  BOOL isStarred = [GDataCategory categories:[self categories]
                   containsCategoryWithLabel:kGDataCategoryLabelStarred];
  return isStarred;
}

- (void)setIsStarred:(BOOL)isStarred {
  [self addCategory:[GDataCategory categoryWithLabel:kGDataCategoryLabelStarred]];  
}

#pragma mark -

- (NSArray *)parentLinks {

  NSArray *links = [self links];
  if (links == nil) return nil;

  NSArray *parentLinks = [GDataUtilities objectsFromArray:links
                                                withValue:kGDataCategoryDocParent
                                               forKeyPath:@"rel"];
  return parentLinks;
}

- (GDataFeedLink *)ACLFeedLink {

  // GDataEntryACL has an ACLLink method to get an entry's atom:link for
  // the ACL feed, but the docs feed puts the ACL link into a gd:feedLink
  // instead of into an atom:link

  NSArray *feedLinks = [self objectsForExtensionClass:[GDataFeedLink class]];
  GDataFeedLink *aclFeedLink;

  aclFeedLink = [GDataUtilities firstObjectFromArray:feedLinks
                                           withValue:kGDataLinkRelACL
                                          forKeyPath:@"rel"];
  return aclFeedLink;
}

@end
