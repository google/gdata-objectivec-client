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
//  GDataFeedSpreadsheet.m
//

#import "GDataEntrySpreadsheet.h"
#import "GDataFeedSpreadsheet.h"
#import "GDataCategory.h"

@implementation GDataFeedSpreadsheet

+ (void)load {
 [GDataObject registerFeedClass:[self class]
          forCategoryWithScheme:nil 
                           term:kGDataCategorySpreadsheet];
}

+ (GDataFeedSpreadsheet *)spreadsheetFeedWithXMLData:(NSData *)data {
  return [[[[self class] alloc] initWithData:data] autorelease];
}

+ (GDataFeedSpreadsheet *)spreadsheetFeed {
  GDataFeedSpreadsheet *feed = [[[[self class] alloc] init] autorelease];
  [feed setNamespaces:[GDataEntrySpreadsheet spreadsheetNamespaces]];
  return feed;
}

- (id)init {
  self = [super init];
  if (self) {
    [self addCategory:[GDataCategory categoryWithScheme:kGDataCategorySchemeSpreadsheet
                                                   term:kGDataCategorySpreadsheet]];
  }
  return self;
}

- (Class)classForEntries {
  return [GDataEntrySpreadsheet class];
}

@end
