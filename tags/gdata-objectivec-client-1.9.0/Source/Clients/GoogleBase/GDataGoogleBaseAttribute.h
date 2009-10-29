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
//  GDataGoogleBaseAttribute.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_GOOGLEBASE_SERVICE

#import "GDataObject.h"

// arbitrary Google Base attribute, like
//  <g:condition type='text'> new <g:my_subattribute>89</g:my_subattribute> </g:condition>

// sub-attributes are implemented by declaring an extension allowing this class
// to be a child of itself (see -addExtensionDeclarations)

@interface GDataGoogleBaseAttribute : GDataObject <NSCopying, GDataExtension> {
  NSString *attributeName_;
  NSString *type_;
  NSString *textValue_;
  BOOL isPrivate_;
}

+ (GDataGoogleBaseAttribute *)attributeWithName:(NSString *)name
                                           type:(NSString *)type
                                      textValue:(NSString *)textValue;

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent;

- (NSXMLElement *)XMLElement;

- (NSString *)name;
- (void)setName:(NSString *)str;

- (NSString *)textValue;
- (void)setTextValue:(NSString *)str;

- (NSString *)type;
- (void)setType:(NSString *)type;

- (BOOL)isPrivate;
- (void)setIsPrivate:(BOOL)flag;


- (void)setSubAttributes:(NSArray *)subAttributes;
- (void)addSubAttribute:(GDataGoogleBaseAttribute *)subAttributes;
- (NSArray *)subAttributes;

// type conversions

// return the textValue time string as a GData object
- (GDataDateTime *)dateTime;

// attribute names have spaces; element names have underscores
+ (NSString *)attributeNameFromElementLocalName:(NSString *)elementLocalName;
+ (NSString *)elementLocalNameFromAttributeName:(NSString *)attributeName;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_GOOGLEBASE_SERVICE
