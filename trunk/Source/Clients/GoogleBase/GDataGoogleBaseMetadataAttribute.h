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
//  GDataGoogleBaseMetadataAttribute.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_GOOGLEBASE_SERVICE

#import "GDataObject.h"

#import "GDataGoogleBaseMetadataValue.h"

// for gm:attribute, like 
//  <gm:attribute name='item type' type='text' count='116353'>
//    <gm:value count='87269'>products</gm:value>
//    <gm:value count='2401'>produkte</gm:value>
//  </gm:attribute>
@interface GDataGoogleBaseMetadataAttribute : GDataObject <NSCopying, GDataExtension> {
  NSString *type_;
  NSString *name_;
  NSNumber *count_;
}

+ (GDataGoogleBaseMetadataAttribute *)metadataAttributeWithType:(NSString *)type
                      name:(NSString *)name
                      count:(NSNumber *)count;

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent;

- (NSXMLElement *)XMLElement;

- (NSString *)type;
- (void)setType:(NSString *)str;

- (NSString *)name;
- (void)setName:(NSString *)str;

- (NSNumber *)count;
- (void)setCount:(NSNumber *)num;

- (NSArray *)values;
- (void)setValues:(NSArray *)values;
- (void)addValue:(GDataGoogleBaseMetadataValue *)value;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_GOOGLEBASE_SERVICE
