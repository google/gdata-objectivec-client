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
//  GDataExtendedProperty.h
//

#import "GDataObject.h"


// an element with a name="" and a value="" attribute, as in
//  <gd:extendedProperty name='X-MOZ-ALARM-LAST-ACK' value='2006-10-03T19:01:14Z'/>
//
// or an arbitrary XML blob, as in 
//  <gd:extendedProperty name='com.myCompany.myProperties'> <myXMLBlob /> </gd:extendedProperty>
//
// Servers may impose additional restrictions on names or on the size
// or composition of the values.

@interface GDataExtendedProperty : GDataObject <NSCopying, GDataExtension> {
  NSString *value_;
  NSString *name_;
}

+ (id)propertyWithName:(NSString *)name
                 value:(NSString *)value;

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent;

- (NSXMLElement *)XMLElement;

- (NSString *)value;
- (void)setValue:(NSString *)str;

- (NSString *)name;
- (void)setName:(NSString *)str;

- (NSArray *)XMLValues;
- (void)setXMLValues:(NSArray *)arr;
- (void)addXMLValue:(NSXMLNode *)node;
@end

