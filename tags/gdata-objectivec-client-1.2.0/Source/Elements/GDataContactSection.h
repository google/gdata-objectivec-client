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
//  GDataContactSection.h
//

#import <Cocoa/Cocoa.h>

#import "GDataObject.h"

@class GDataIM;
@class GDataEmail;
@class GDataPhoneNumber;
@class GDataPostalAddress;
@class GDataGeoPt;

// for contact info
//
//  <gd:contactSection label="Work">
//    <gd:email address="jo@example.com"/>
//    <gd:phoneNumber rel="http://schemas.google.com/g/2005#work">(650) 555-1212</gd:phoneNumber>
//    <gd:phoneNumber rel="http://schemas.google.com/g/2005#pager">(650) 555-1214</gd:phoneNumber>
//    <gd:postalAddress>
//      1600 Amphitheatre Pkwy
//      Mountain View, CA 94043
//    </gd:postalAddress>
//    <gd:geoPt lat="37.423269" lon="-122.082667"/>
//  </gd:contactSection>

@interface GDataContactSection : GDataObject <NSCopying, GDataExtension> {
  NSString *label_;
  NSMutableArray *emails_;
  NSMutableArray *geoPts_;
  NSMutableArray *ims_;
  NSMutableArray *phoneNumbers_;
  NSMutableArray *postalAddresses_;
}

+ (GDataContactSection *)contactSection;

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent;

- (NSXMLElement *)XMLElement;

- (NSString *)label;
- (void)setLabel:(NSString *)str;

- (NSArray *)emails;
- (void)setEmails:(NSArray *)array;
- (void)addEmail:(GDataEmail *)obj;

- (NSArray *)geoPts;
- (void)setGeoPts:(NSArray *)array;
- (void)addGeoPts:(GDataGeoPt *)obj;

- (NSArray *)IMs;
- (void)setIMs:(NSArray *)array;
- (void)addIM:(GDataIM *)obj;

- (NSArray *)phoneNumbers;
- (void)setPhoneNumbers:(NSArray *)array;
- (void)addPhoneNumber:(GDataPhoneNumber *)obj;

- (NSArray *)postalAddresses;
- (void)setPostalAddresses:(NSArray *)array;
- (void)addPostalAddress:(GDataPostalAddress *)obj;

@end
