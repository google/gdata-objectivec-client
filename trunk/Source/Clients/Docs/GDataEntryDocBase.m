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

#pragma mark -

- (BOOL)isStarred {
  BOOL isStarred = [GDataCategory categories:[self categories]
                   containsCategoryWithLabel:kGDataCategoryLabelStarred];
  return isStarred;
}

- (void)setIsStarred:(BOOL)isStarred {
  [self addCategory:[GDataCategory categoryWithLabel:kGDataCategoryLabelStarred]];  
}

@end
