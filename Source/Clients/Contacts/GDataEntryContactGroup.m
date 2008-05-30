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
//  GDataEntryContactGroup.m
//

#import "GDataEntryContactGroup.h"
#import "GDataEntryContact.h"      // for namespace

// system group identifier, like <gContact:systemGroup id="Contacts"/>
@implementation GDataContactSystemGroup
+ (NSString *)extensionElementURI       { return kGDataNamespaceContact; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceContactPrefix; }
+ (NSString *)extensionElementLocalName { return @"systemGroup"; }

- (NSString *)attributeName {
  return @"id";
}

- (NSString *)identifier {
  return [self stringValue];
}

- (void)setIdentifier:(NSString *)str {
  [self setStringValue:str]; 
}
@end


@implementation GDataEntryContactGroup

+ (GDataEntryContactGroup *)contactGroupEntryWithTitle:(NSString *)title {
  GDataEntryContactGroup *obj = [[[GDataEntryContactGroup alloc] init] autorelease];
  
  [obj setNamespaces:[GDataEntryContact contactNamespaces]];
  
  [obj setTitleWithString:title];
  return obj;
}

#pragma mark -

+ (void)load {
  [GDataObject registerEntryClass:[self class]
            forCategoryWithScheme:kGDataCategoryScheme 
                             term:kGDataCategoryContactGroup];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];
  
  // ContactEntry extensions
  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataExtendedProperty class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataContactSystemGroup class]];  
}

- (id)init {
  self = [super init];
  if (self) {
    GDataCategory *category = [GDataCategory categoryWithScheme:kGDataCategoryScheme
                                                           term:kGDataCategoryContactGroup];
    [self addCategory:category];
  }
  return self;
}

- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  
  NSString *systemGroupID = [[self systemGroup] identifier];
  
  [self addToArray:items objectDescriptionIfNonNil:systemGroupID withName:@"systemGroup"];
  [self addToArray:items arrayCountIfNonEmpty:[self extendedProperties] withName:@"extProps"];
  
  return items;
}

#pragma mark -

- (NSArray *)extendedProperties {
  return [self objectsForExtensionClass:[GDataExtendedProperty class]];
}

- (void)setExtendedProperties:(NSArray *)arr {
  [self setObjects:arr forExtensionClass:[GDataExtendedProperty class]];
}

- (void)addExtendedProperty:(GDataExtendedProperty *)obj {
  [self addObject:obj forExtensionClass:[GDataExtendedProperty class]];
}

- (GDataContactSystemGroup *)systemGroup {
  return [self objectForExtensionClass:[GDataContactSystemGroup class]];
}

- (void)setSystemGroup:(GDataContactSystemGroup *)obj {
  [self setObject:obj forExtensionClass:[GDataContactSystemGroup class]];
}

@end
