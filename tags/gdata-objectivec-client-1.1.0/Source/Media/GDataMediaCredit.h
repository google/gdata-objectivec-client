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
//  GDataMediaCredit.h
//

#import <Cocoa/Cocoa.h>

#import "GDataObject.h"

// like <media:credit role="producer" scheme="urn:ebu">entity name</media:credit>
// http://search.yahoo.com/mrss

@interface GDataMediaCredit : GDataObject <NSCopying, GDataExtension> {
  NSString *role_;
  NSString *scheme_;
  NSString *content_;
}

+ (GDataMediaCredit *)mediaCreditWithString:(NSString *)str;

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent;

- (NSXMLElement *)XMLElement;

- (NSString *)role;
- (void)setRole:(NSString *)str;

- (NSString *)scheme;
- (void)setScheme:(NSString *)str;

- (NSString *)stringValue;
- (void)setStringValue:(NSString *)str;

@end
