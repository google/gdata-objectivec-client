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
//  GDataIM.h
//

#import <Cocoa/Cocoa.h>

#import "GDataObject.h"

// IM element, as in
//   <gd:im protocol="sip" address="foo@bar.example.com"/ label="Fred">
//
// http://code.google.com/apis/gdata/common-elements.html#gdIm

@interface GDataIM : GDataObject <NSCopying, GDataExtension> {
  NSString *label_;
  NSString *address_;
  NSString *protocol_;
}
+ (GDataIM *)IMWithProtocol:(NSString *)protocol
                      label:(NSString *)label
                    address:(NSString *)address;

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent;
- (NSXMLElement *)XMLElement;

- (NSString *)address;
- (void)setAddress:(NSString *)str;
- (NSString *)label;
- (void)setLabel:(NSString *)str;
- (NSString *)protocol;
- (void)setProtocol:(NSString *)str;

@end
