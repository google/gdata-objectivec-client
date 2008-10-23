/* Copyright (c) 2008 Google Inc.
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
//  GDataFeedContactGroup.m
//


#import "GDataFeedContactGroup.h"
#import "GDataEntryContact.h"
#import "GDataEntryContactGroup.h"
#import "GDataCategory.h"

@implementation GDataFeedContactGroup

+ (void)load {
  [GDataObject registerFeedClass:[self class]
            forCategoryWithScheme:kGDataCategoryScheme
                             term:kGDataCategoryContactGroup];
}

+ (GDataFeedContactGroup *)contactGroupFeed {
  GDataFeedContactGroup *obj = [[[[self class] alloc] init] autorelease];

  [obj setNamespaces:[GDataEntryContact contactNamespaces]];

  return obj;
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations]; 
}

- (id)init {
  self = [super init];
  if (self) {
      [self addCategory:[GDataCategory categoryWithScheme:kGDataCategoryScheme
                                                     term:kGDataCategoryContactGroup]];
  }
  return self;
}

- (Class)classForEntries {
  return [GDataEntryContactGroup class];
}

@end
