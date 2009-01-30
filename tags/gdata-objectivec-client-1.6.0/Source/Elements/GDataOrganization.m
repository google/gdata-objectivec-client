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
//  GDataOrganization.m
//

#import "GDataOrganization.h"

static NSString* const kRelAttr = @"rel";
static NSString* const kLabelAttr = @"label";
static NSString* const kPrimaryAttr = @"primary";

@implementation GDataOrgTitle 
+ (NSString *)extensionElementPrefix { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementURI    { return kGDataNamespaceGData; }
+ (NSString *)extensionElementLocalName { return @"orgTitle"; }
@end

@implementation GDataOrgName 
+ (NSString *)extensionElementPrefix { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementURI    { return kGDataNamespaceGData; }
+ (NSString *)extensionElementLocalName { return @"orgName"; }
@end

@implementation GDataOrganization
// organization, as in 
//  <gd:organization primary="true" rel="http://schemas.google.com/g/2005#work">
//    <gd:orgName>Acme Corp</gd:orgName>
//    <gd:orgTitle>Prezident</gd:orgTitle>
//  </gd:organization>

+ (NSString *)extensionElementURI       { return kGDataNamespaceGData; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementLocalName { return @"organization"; }

+ (GDataOrganization *)organizationWithName:(NSString *)str {
  GDataOrganization *obj = [[[GDataOrganization alloc] init] autorelease];
  [obj setOrgName:str];
  return obj;
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];

  Class elementClass = [self class];
  
  [self addExtensionDeclarationForParentClass:elementClass
                                   childClass:[GDataOrgTitle class]];  
  [self addExtensionDeclarationForParentClass:elementClass
                                   childClass:[GDataOrgName class]];  
  
}

- (void)addParseDeclarations {
  NSArray *attrs = [NSArray arrayWithObjects: 
                    kLabelAttr, kRelAttr, kPrimaryAttr, nil];
  
  [self addLocalAttributeDeclarations:attrs];
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [super itemsForDescription];
  
  // add extensions
  [self addToArray:items objectDescriptionIfNonNil:[self orgTitle] withName:@"title"];
  [self addToArray:items objectDescriptionIfNonNil:[self orgName] withName:@"name"];
    
  return items;
}

#pragma mark -

- (NSString *)rel {
  return [self stringValueForAttribute:kRelAttr]; 
}

- (void)setRel:(NSString *)str {
  [self setStringValue:str forAttribute:kRelAttr];
}

- (NSString *)label {
  return [self stringValueForAttribute:kLabelAttr]; 
}

- (void)setLabel:(NSString *)str {
  [self setStringValue:str forAttribute:kLabelAttr];
}

- (BOOL)isPrimary {
  return [self boolValueForAttribute:kPrimaryAttr defaultValue:NO]; 
}

- (void)setIsPrimary:(BOOL)flag {
  [self setBoolValue:flag defaultValue:NO forAttribute:kPrimaryAttr];
}

- (NSString *)orgName {
  GDataOrgName *obj = [self objectForExtensionClass:[GDataOrgName class]];
  return [obj stringValue];
}

- (void)setOrgName:(NSString *)str {
  
  GDataOrgName *obj = [GDataOrgName valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataOrgName class]]; 
}

- (NSString *)orgTitle {
  GDataOrgTitle *obj = [self objectForExtensionClass:[GDataOrgTitle class]];
  return [obj stringValue];
}

- (void)setOrgTitle:(NSString *)str {
  
  GDataOrgTitle *obj = [GDataOrgTitle valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataOrgTitle class]]; 
}

@end
