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

_EXTERN NSString* const kGDataPhoneNumberMobile  _INITIALIZE_AS(@"http://schemas.google.com/g/2005#mobile");
_EXTERN NSString* const kGDataPhoneNumberHome  _INITIALIZE_AS(@"http://schemas.google.com/g/2005#home");
_EXTERN NSString* const kGDataPhoneNumberWork  _INITIALIZE_AS(@"http://schemas.google.com/g/2005#work");
_EXTERN NSString* const kGDataPhoneNumberFax  _INITIALIZE_AS(@"http://schemas.google.com/g/2005#fax");
_EXTERN NSString* const kGDataPhoneNumberHomeFax  _INITIALIZE_AS(@"http://schemas.google.com/g/2005#home_fax");
_EXTERN NSString* const kGDataPhoneNumberWorkFax  _INITIALIZE_AS(@"http://schemas.google.com/g/2005#work_fax");
_EXTERN NSString* const kGDataPhoneNumberPager  _INITIALIZE_AS(@"http://schemas.google.com/g/2005#pager");
_EXTERN NSString* const kGDataPhoneNumberOther  _INITIALIZE_AS(@"http://schemas.google.com/g/2005#other");

// phone number, as in 
//  <gd:phoneNumber rel="http://schemas.google.com/g/2005#work" >
//    (425) 555-8080 ext. 52585
//  </gd:phoneNumber>
//
// http://code.google.com/apis/gdata/common-elements.html#gdPhoneNumber

@interface GDataPhoneNumber : GDataObject <GDataExtension> {
}

+ (GDataPhoneNumber *)phoneNumberWithString:(NSString *)str;

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
