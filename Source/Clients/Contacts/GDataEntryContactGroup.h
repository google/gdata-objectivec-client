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
//  GDataEntryContactGroup.h
//

#import "GDataEntryBase.h"
#import "GDataExtendedProperty.h"


// system group identifier, like <gContact:systemGroup id="Contacts"/>
@interface GDataContactSystemGroup : GDataValueConstruct <GDataExtension>
- (NSString *)attributeName; // returns "id"

- (NSString *)identifier;
- (void)setIdentifier:(NSString *)str;
@end

@interface GDataEntryContactGroup : GDataEntryBase

+ (GDataEntryContactGroup *)contactGroupEntryWithTitle:(NSString *)title;

- (GDataContactSystemGroup *)systemGroup;
- (void)setSystemGroup:(GDataContactSystemGroup *)obj;

- (NSArray *)extendedProperties;
- (void)setExtendedProperties:(NSArray *)arr;
- (void)addExtendedProperty:(GDataExtendedProperty *)obj;

// note: support for gd:deleted is in GDataEntryBase

@end
