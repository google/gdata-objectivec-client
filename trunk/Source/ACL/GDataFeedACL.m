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
//  GDataFeedACL.m
//


#import "GDataFeedACL.h"

#import "GDataEntryACL.h"

@implementation GDataFeedACL

+ (GDataFeedACL *)ACLFeed {
  GDataFeedACL *feed = [[[GDataFeedACL alloc] init] autorelease];
  
  [feed setNamespaces:[GDataEntryACL ACLNamespaces]];
  
  return feed;
}

+ (GDataFeedACL *)ACLFeedWithXMLData:(NSData *)data {
  return [[[self alloc] initWithData:data] autorelease];
}

+ (void)load {
  [GDataObject registerFeedClass:[self class]
           forCategoryWithScheme:kGDataCategoryScheme
                            term:kGDataCategoryACL];
}

- (id)init {
  self = [super init];
  if (self) {
      [self addCategory:[GDataCategory categoryWithScheme:kGDataCategoryScheme
                                                     term:kGDataCategoryACL]];
  }
  return self;
}

- (Class)classForEntries {
  return [GDataEntryACL class];
}

@end
