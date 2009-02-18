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
//  GDataEntryContact.h
//

#import "GDataEntryBase.h"
#import "GDataOrganization.h"
#import "GDataEmail.h"
#import "GDataIM.h"
#import "GDataPhoneNumber.h"
#import "GDataPostalAddress.h"
#import "GDataCategory.h"
#import "GDataExtendedProperty.h"
#import "GDataGroupMembershipInfo.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAENTRYCONTACT_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataContactDefaultServiceVersion _INITIALIZE_AS(@"2.0");

_EXTERN NSString* const kGDataNamespaceContact _INITIALIZE_AS(@"http://schemas.google.com/contact/2008");
_EXTERN NSString* const kGDataNamespaceContactPrefix _INITIALIZE_AS(@"gContact");

_EXTERN NSString* const kGDataCategoryContact      _INITIALIZE_AS(@"http://schemas.google.com/contact/2008#contact");
_EXTERN NSString* const kGDataCategoryContactGroup _INITIALIZE_AS(@"http://schemas.google.com/contact/2008#group");

// rel values
_EXTERN NSString* const kGDataContactHome    _INITIALIZE_AS(@"http://schemas.google.com/g/2005#home");
_EXTERN NSString* const kGDataContactWork    _INITIALIZE_AS(@"http://schemas.google.com/g/2005#work");
_EXTERN NSString* const kGDataContactOther   _INITIALIZE_AS(@"http://schemas.google.com/g/2005#other");

// link rel values
_EXTERN NSString* const kGDataContactPhotoRel     _INITIALIZE_AS(@"http://schemas.google.com/contacts/2008/rel#photo");
_EXTERN NSString* const kGDataContactEditPhotoRel _INITIALIZE_AS(@"http://schemas.google.com/contacts/2008/rel#edit-photo");

@interface GDataEntryContact : GDataEntryBase {
}

+ (NSDictionary *)contactNamespaces;

+ (GDataEntryContact *)contactEntryWithTitle:(NSString *)title;

// each type of contact data includes convenience methods for getting or
// setting a primary element. 

- (NSArray *)organizations;
- (void)setOrganizations:(NSArray *)array;
- (void)addOrganization:(GDataOrganization *)obj;
- (void)removeOrganization:(GDataOrganization *)obj;

- (GDataOrganization *)primaryOrganization;
- (void)setPrimaryOrganization:(GDataOrganization *)obj;

- (NSArray *)emailAddresses;
- (void)setEmailAddresses:(NSArray *)array;
- (void)addEmailAddress:(GDataEmail *)obj;
- (void)removeEmailAddress:(GDataEmail *)obj;

- (GDataEmail *)primaryEmailAddress;
- (void)setPrimaryEmailAddress:(GDataEmail *)obj;

- (NSArray *)IMAddresses;
- (void)setIMAddresses:(NSArray *)array;
- (void)addIMAddress:(GDataIM *)obj;
- (void)removeIMAddress:(GDataIM *)obj;

- (GDataIM *)primaryIMAddress;
- (void)setPrimaryIMAddress:(GDataIM *)obj;

- (NSArray *)phoneNumbers;
- (void)setPhoneNumbers:(NSArray *)array;
- (void)addPhoneNumber:(GDataPhoneNumber *)obj;
- (void)removePhoneNumber:(GDataPhoneNumber *)obj;

- (GDataPhoneNumber *)primaryPhoneNumber;
- (void)setPrimaryPhoneNumber:(GDataPhoneNumber *)obj;

- (NSArray *)postalAddresses;
- (void)setPostalAddresses:(NSArray *)array;
- (void)addPostalAddress:(GDataPostalAddress *)obj;
- (void)removePostalAddress:(GDataPostalAddress *)obj;

- (GDataPostalAddress *)primaryPostalAddress;
- (void)setPrimaryPostalAddress:(GDataPostalAddress *)obj;

- (NSArray *)groupMembershipInfos;
- (void)setGroupMembershipInfos:(NSArray *)arr;
- (void)addGroupMembershipInfo:(GDataGroupMembershipInfo *)obj;
- (void)removeGroupMembershipInfo:(GDataGroupMembershipInfo *)obj;

- (NSArray *)extendedProperties;
- (void)setExtendedProperties:(NSArray *)arr;
- (void)addExtendedProperty:(GDataExtendedProperty *)obj;
- (void)removeExtendedProperty:(GDataExtendedProperty *)obj;

// convenience accessors
- (GDataExtendedProperty *)extendedPropertyForName:(NSString *)name;

- (GDataLink *)photoLink;
- (GDataLink *)editPhotoLink;

- (GDataGroupMembershipInfo *)groupMembershipInfoWithHref:(NSString *)href;

@end
