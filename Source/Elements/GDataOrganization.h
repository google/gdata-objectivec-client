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
//  GDataOrganization.h
//

#import "GDataObject.h"
#import "GDataValueConstruct.h"

// organization, as in 
//  <gd:organization primary="true" rel="http://schemas.google.com/g/2005#work">
//    <gd:orgTitle>Prezident</gd:orgTitle>
//    <gd:orgName>Acme Corp</gd:orgName>
//  </gd:organization>

@interface GDataOrgTitle : GDataValueElementConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataOrgName : GDataValueElementConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end


@interface GDataOrganization : GDataObject <NSCopying, GDataExtension> {
  NSString *rel_;
  NSString *label_;
  BOOL isPrimary_;
}

+ (GDataOrganization *)organizationWithName:(NSString *)str;

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent;

- (NSXMLElement *)XMLElement;

- (NSString *)rel;
- (void)setRel:(NSString *)str;

- (NSString *)label;
- (void)setLabel:(NSString *)str;

- (BOOL)isPrimary;
- (void)setIsPrimary:(BOOL)flag;

- (NSString *)orgTitle;
- (void)setOrgTitle:(NSString *)str;

- (NSString *)orgName;
- (void)setOrgName:(NSString *)str;

@end
