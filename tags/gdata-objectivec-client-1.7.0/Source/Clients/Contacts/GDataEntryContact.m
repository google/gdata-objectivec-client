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
//  GDataEntryContact.m
//

#define GDATAENTRYCONTACT_DEFINE_GLOBALS 1
#import "GDataEntryContact.h"


@implementation GDataEntryContact

+ (NSDictionary *)contactNamespaces {
  NSMutableDictionary *namespaces;
  
  namespaces = [NSMutableDictionary dictionaryWithObject:kGDataNamespaceContact
                                                  forKey:kGDataNamespaceContactPrefix];
  
  [namespaces addEntriesFromDictionary:[GDataEntryBase baseGDataNamespaces]];
  
  return namespaces;
}

+ (GDataEntryContact *)contactEntryWithTitle:(NSString *)title {
  GDataEntryContact *obj = [[[GDataEntryContact alloc] init] autorelease];
  
  [obj setNamespaces:[GDataEntryContact contactNamespaces]];
  
  [obj setTitleWithString:title];
  return obj;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategoryContact;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];

  // ContactEntry extensions

  Class entryClass = [self class];
  [self addExtensionDeclarationForParentClass:entryClass
                                 childClasses:
   [GDataOrganization class],
   [GDataEmail class],
   [GDataIM class],
   [GDataPhoneNumber class],
   [GDataPostalAddress class],
   [GDataGroupMembershipInfo class],
   [GDataExtendedProperty class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  
  static struct GDataDescriptionRecord descRecs[] = {
    { @"organizations", @"organizations",        kGDataDescArrayDescs },
    { @"email",         @"emailAddresses",       kGDataDescArrayDescs },
    { @"phone",         @"phoneNumbers",         kGDataDescArrayDescs },
    { @"IM",            @"IMAddresses",          kGDataDescArrayDescs },
    { @"postal",        @"postalAddresses",      kGDataDescArrayDescs },
    { @"group",         @"groupMembershipInfos", kGDataDescArrayDescs },
    { @"extProps",      @"extendedProperties",   kGDataDescArrayDescs },
    { nil, nil, 0 }
  };
  
  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

+ (NSString *)defaultServiceVersion {
  return kGDataContactDefaultServiceVersion;
}

#pragma mark -

// The Focus UI does not happily handle empty strings, so we'll force those
// to be nil
- (void)setTitle:(GDataTextConstruct *)theTitle {
  if ([[theTitle stringValue] length] == 0) {
    theTitle = nil; 
  }
  [super setTitle:theTitle];
}

- (void)setTitleWithString:(NSString *)str {
  if ([str length] == 0) {
    [self setTitle:nil]; 
  } else {
    [super setTitleWithString:str]; 
  }
}

#pragma mark -

// routines to do the work for finding or setting the primary elements
// of the different extension classes

- (GDataObject *)primaryObjectForExtensionClass:(Class)class {
  
  NSArray *extns = [self objectsForExtensionClass:class];
  
  GDataObject *obj;
  GDATA_FOREACH(obj, extns) {
    if ([(id)obj isPrimary]) return obj;
  }
  return nil;
}

- (void)setPrimaryObject:(GDataObject *)newPrimaryObj
       forExtensionClass:(Class)class {
  NSArray *extns =  [self objectsForExtensionClass:class];
  BOOL foundIt = NO;

  GDataObject *obj;
  GDATA_FOREACH(obj, extns) {

    BOOL isPrimary = [newPrimaryObj isEqual:obj];
    [(id)obj setIsPrimary:isPrimary];
    
    if (isPrimary) foundIt = YES;
  }
  
  // if the object isn't already in the list, add it
  if (!foundIt && newPrimaryObj != nil) {
    [(id)newPrimaryObj setIsPrimary:YES];
    [self addObject:newPrimaryObj forExtensionClass:class];
  }
}

#pragma mark -

- (NSArray *)organizations {
  return [self objectsForExtensionClass:[GDataOrganization class]];
}

- (void)setOrganizations:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataOrganization class]];
}

- (void)addOrganization:(GDataOrganization *)obj {
  [self addObject:obj forExtensionClass:[GDataOrganization class]];
}

- (void)removeOrganization:(GDataOrganization *)obj {
  [self removeObject:obj forExtensionClass:[GDataOrganization class]];
}

- (GDataOrganization *)primaryOrganization {
  id obj = [self primaryObjectForExtensionClass:[GDataOrganization class]];
  return obj;
}

- (void)setPrimaryOrganization:(GDataOrganization *)obj {
  [self setPrimaryObject:obj forExtensionClass:[GDataOrganization class]];
}


- (NSArray *)emailAddresses {
  return [self objectsForExtensionClass:[GDataEmail class]];
}

- (void)setEmailAddresses:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataEmail class]];
}

- (void)addEmailAddress:(GDataEmail *)obj {
  [self addObject:obj forExtensionClass:[GDataEmail class]];
}

- (void)removeEmailAddress:(GDataEmail *)obj {
  [self removeObject:obj forExtensionClass:[GDataEmail class]];
}

- (GDataEmail *)primaryEmailAddress {
  id obj = [self primaryObjectForExtensionClass:[GDataEmail class]];
  return obj;
}

- (void)setPrimaryEmailAddress:(GDataEmail *)obj {
  [self setPrimaryObject:obj forExtensionClass:[GDataEmail class]];
}


- (NSArray *)IMAddresses {
  return [self objectsForExtensionClass:[GDataIM class]];
}

- (void)setIMAddresses:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataIM class]];
}

- (GDataIM *)primaryIMAddress {
  id obj = [self primaryObjectForExtensionClass:[GDataIM class]];
  return obj;
}

- (void)setPrimaryIMAddress:(GDataIM *)obj {
  [self setPrimaryObject:obj forExtensionClass:[GDataIM class]];
}

- (void)addIMAddress:(GDataIM *)obj {
  [self addObject:obj forExtensionClass:[GDataIM class]];
}

- (void)removeIMAddress:(GDataIM *)obj {
  [self removeObject:obj forExtensionClass:[GDataIM class]];
}


- (NSArray *)phoneNumbers {
  return [self objectsForExtensionClass:[GDataPhoneNumber class]];
}

- (void)setPhoneNumbers:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataPhoneNumber class]];
}

- (void)addPhoneNumber:(GDataPhoneNumber *)obj {
  [self addObject:obj forExtensionClass:[GDataPhoneNumber class]];
}

- (void)removePhoneNumber:(GDataPhoneNumber *)obj {
  [self removeObject:obj forExtensionClass:[GDataPhoneNumber class]];
}

- (GDataPhoneNumber *)primaryPhoneNumber {
  id obj = [self primaryObjectForExtensionClass:[GDataPhoneNumber class]];
  return obj;
}

- (void)setPrimaryPhoneNumber:(GDataPhoneNumber *)obj {
  [self setPrimaryObject:obj forExtensionClass:[GDataPhoneNumber class]];
}


- (NSArray *)postalAddresses {
  return [self objectsForExtensionClass:[GDataPostalAddress class]];
}

- (void)setPostalAddresses:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataPostalAddress class]];
}

- (void)addPostalAddress:(GDataPostalAddress *)obj {
  [self addObject:obj forExtensionClass:[GDataPostalAddress class]];
}

- (void)removePostalAddress:(GDataPostalAddress *)obj {
  [self removeObject:obj forExtensionClass:[GDataPostalAddress class]];
}

- (GDataPostalAddress *)primaryPostalAddress {
  id obj = [self primaryObjectForExtensionClass:[GDataPostalAddress class]];
  return obj;
}

- (void)setPrimaryPostalAddress:(GDataPostalAddress *)obj {
  [self setPrimaryObject:obj forExtensionClass:[GDataPostalAddress class]];
}


- (NSArray *)groupMembershipInfos {
  return [self objectsForExtensionClass:[GDataGroupMembershipInfo class]];
}

- (void)setGroupMembershipInfos:(NSArray *)arr {
  [self setObjects:arr forExtensionClass:[GDataGroupMembershipInfo class]];
}

- (void)addGroupMembershipInfo:(GDataGroupMembershipInfo *)obj {
  [self addObject:obj forExtensionClass:[GDataGroupMembershipInfo class]];
}

- (void)removeGroupMembershipInfo:(GDataGroupMembershipInfo *)obj {
  [self removeObject:obj forExtensionClass:[GDataGroupMembershipInfo class]];
}

- (NSArray *)extendedProperties {
  return [self objectsForExtensionClass:[GDataExtendedProperty class]];
}

- (void)setExtendedProperties:(NSArray *)arr {
  [self setObjects:arr forExtensionClass:[GDataExtendedProperty class]];
}

- (void)addExtendedProperty:(GDataExtendedProperty *)obj {
  [self addObject:obj forExtensionClass:[GDataExtendedProperty class]];
}

- (void)removeExtendedProperty:(GDataExtendedProperty *)obj {
  [self removeObject:obj forExtensionClass:[GDataExtendedProperty class]];
}

- (GDataExtendedProperty *)extendedPropertyForName:(NSString *)str {
  
  GDataExtendedProperty *extProp = nil;
  
  NSArray *array = [self extendedProperties];
  if (array != nil) {
    extProp = [GDataUtilities firstObjectFromArray:array
                                         withValue:str
                                        forKeyPath:@"name"];
  }
  return extProp;
}

#pragma mark -

- (GDataLink *)photoLink {
  return [self linkWithRelAttributeValue:kGDataContactPhotoRel]; 
}

- (GDataLink *)editPhotoLink {
  GDATA_DEBUG_ASSERT_MAX_SERVICE_V1();
  
  return [self linkWithRelAttributeValue:kGDataContactEditPhotoRel]; 
}

- (GDataGroupMembershipInfo *)groupMembershipInfoWithHref:(NSString *)href {
  GDataGroupMembershipInfo *groupInfo;
  
  groupInfo = [GDataUtilities firstObjectFromArray:[self groupMembershipInfos]
                                         withValue:href
                                        forKeyPath:@"href"];
  return groupInfo;
}
@end

