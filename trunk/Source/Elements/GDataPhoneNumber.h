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
//  GDataPhoneNumber.h
//

#import "GDataObject.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAPHONENUMBER_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

// Note: kGDataContactMobile, kGDataContactHome, and kGDataContactWork are
// equivalent to kGDataPhoneNumberMobile, kGDataPhoneNumberHome, kGDataPhoneNumberWork

_EXTERN NSString* kGDataPhoneNumberMobile  _INITIALIZE_AS(@"http://schemas.google.com/g/2005#mobile");
_EXTERN NSString* kGDataPhoneNumberHome  _INITIALIZE_AS(@"http://schemas.google.com/g/2005#home");
_EXTERN NSString* kGDataPhoneNumberWork  _INITIALIZE_AS(@"http://schemas.google.com/g/2005#work");
_EXTERN NSString* kGDataPhoneNumberInternalExtensions  _INITIALIZE_AS(@"http://schemas.google.com/g/2005#internal-extension");
_EXTERN NSString* kGDataPhoneNumberFax  _INITIALIZE_AS(@"http://schemas.google.com/g/2005#fax");
_EXTERN NSString* kGDataPhoneNumberHomeFax  _INITIALIZE_AS(@"http://schemas.google.com/g/2005#home_fax");
_EXTERN NSString* kGDataPhoneNumberWorkFax  _INITIALIZE_AS(@"http://schemas.google.com/g/2005#work_fax");
_EXTERN NSString* kGDataPhoneNumberPager  _INITIALIZE_AS(@"http://schemas.google.com/g/2005#pager");
_EXTERN NSString* kGDataPhoneNumberCar  _INITIALIZE_AS(@"http://schemas.google.com/g/2005#car");
_EXTERN NSString* kGDataPhoneNumberSatellite  _INITIALIZE_AS(@"http://schemas.google.com/g/2005#satellite");
_EXTERN NSString* kGDataPhoneNumberOther  _INITIALIZE_AS(@"http://schemas.google.com/g/2005#other");

// phone number, as in 
//  <gd:phoneNumber rel="http://schemas.google.com/g/2005#work" uri="tel:+1-425-555-8080;ext=52585">
//    (425) 555-8080 ext. 52585
//  </gd:phoneNumber>
//
// http://code.google.com/apis/gdata/common-elements.html#gdPhoneNumber

@interface GDataPhoneNumber : GDataObject <NSCopying, GDataExtension> {
  NSString *rel_;
  NSString *label_;
  NSString *uri_;
  NSString *phoneNumber_;
  BOOL isPrimary_;
}

+ (GDataPhoneNumber *)phoneNumberWithString:(NSString *)str;

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent;

- (NSXMLElement *)XMLElement;

- (NSString *)rel;
- (void)setRel:(NSString *)str;
- (NSString *)label;
- (void)setLabel:(NSString *)str;
- (NSString *)URI;
- (void)setURI:(NSString *)str;
- (NSString *)stringValue;
- (void)setStringValue:(NSString *)str;
- (BOOL)isPrimary;
- (void)setIsPrimary:(BOOL)flag;
@end
