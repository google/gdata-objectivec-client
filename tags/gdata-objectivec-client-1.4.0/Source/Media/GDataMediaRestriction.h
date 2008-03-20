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
//  GDataMediaRestriction.h

#import "GDataObject.h"

// like <media:restriction relationship="allow" type="country">au us</media:restriction>
//
// http://search.yahoo.com/mrss

@interface GDataMediaRestriction : GDataObject <NSCopying, GDataExtension> {
  NSString *relationship_;
  NSString *type_;
  NSString *content_;
}

+ (GDataMediaRestriction *)mediaRestrictionWithString:(NSString *)str
                                         relationship:(NSString *)rel
                                                 type:(NSString *)type;
  
- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent;

- (NSXMLElement *)XMLElement;

- (NSString *)relationship;
- (void)setRelationship:(NSString *)str;

- (NSString *)type;
- (void)setType:(NSString *)str;

- (NSString *)stringValue;
- (void)setStringValue:(NSString *)str;

@end
