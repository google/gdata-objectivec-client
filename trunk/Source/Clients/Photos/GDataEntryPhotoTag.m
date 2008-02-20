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
//  GDataEntryPhotoTag.m
//

#import "GDataEntryPhotoTag.h"
#import "GDataPhotoElements.h"

// extensions



@implementation GDataEntryPhotoTag

+ (GDataEntryPhotoTag *)tagEntryWithString:(NSString *)tagStr {
  
  GDataEntryPhotoTag *entry = [[[GDataEntryPhotoTag alloc] init] autorelease];

  [entry setNamespaces:[GDataEntryPhotoTag photoNamespaces]];
  
  [entry setTitle:[GDataTextConstruct textConstructWithString:tagStr]];
  
  return entry;
}

#pragma mark -

+ (void)load {
  [GDataObject registerEntryClass:[self class]
            forCategoryWithScheme:nil 
                             term:kGDataCategoryPhotosTag];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  // common photo extensions
  Class entryClass = [self class];
  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataPhotoWeight class]];
}

- (id)init {
  self = [super init];
  if (self) {
    [self addCategory:[GDataCategory categoryWithScheme:kGDataCategoryScheme
                                                   term:kGDataCategoryPhotosTag]];
  }
  return self;
}

- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  [self addToArray:items objectDescriptionIfNonNil:[self weight] withName:@"weight"];
  
  return items;
}

#pragma mark -

- (NSNumber *)weight {
  // int
  GDataPhotoWeight *obj = [self objectForExtensionClass:[GDataPhotoWeight class]];
  return [obj intNumberValue];
}

- (void)setWeight:(NSNumber *)num {
  GDataPhotoWeight *obj = [GDataPhotoWeight valueWithNumber:num];
  [self setObject:obj forExtensionClass:[obj class]];  
}

@end
