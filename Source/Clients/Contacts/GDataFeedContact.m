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
//  GDataFeedContact.m
//


#import "GDataFeedContact.h"

#import "GDataEntryContact.h"
#import "GDataWhere.h"
#import "GDataCategory.h"

@implementation GDataFeedContact

+ (GDataFeedContact *)contactFeed {
  GDataFeedContact *obj = [[[[self class] alloc] init] autorelease];

  [obj setNamespaces:[GDataEntryContact contactNamespaces]];

  return obj;
}

+ (GDataFeedContact *)contactFeedWithXMLData:(NSData *)data {
  return [[[[self class] alloc] initWithData:data] autorelease];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class feedClass = [self class];
  [self addExtensionDeclarationForParentClass:feedClass
                                   childClass:[GDataWhere class]];  
}

- (id)init {
  self = [super init];
  if (self) {
      [self addCategory:[GDataCategory categoryWithScheme:kGDataCategoryScheme
                                                     term:kGDataCategoryContact]];
  }
  return self;
}

- (Class)classForEntries {
  return [GDataEntryContact class];
}

#pragma mark -

@end
