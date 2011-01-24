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
//  GDataSiteVerificationMethod.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE

#import "GDataObject.h"


#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATASITEVERIFICATIONMETHOD_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN GDATA_EXTERN
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataSiteVerificationMethodMetatag _INITIALIZE_AS(@"metatag");
_EXTERN NSString* const kGDataSiteVerificationMethodHTMLPage _INITIALIZE_AS(@"htmlpage");

// Verification method elements, like
//
//  <wt:verification-method type="metatag" in-use="false">
//    <meta name="verify-v1" content="a2Ai" />
//  </wt:verification-method>
//
// and
//
//  <wt:verification-method type="htmlpage" in-use="true">456456-google.html
//                 </wt:verification-method>
//
//
// http://code.google.com/apis/webmastertools/docs/reference.html

@interface GDataSiteVerificationMethod : GDataObject <GDataExtension>
+ (id)verificationMethodWithType:(NSString *)type
                           value:(NSString *)value
                         isInUse:(BOOL)isInUse;

- (NSString *)type;
- (void)setType:(NSString *)str;

- (BOOL)isInUse;
- (void)setIsInUse:(BOOL)flag;

// value as a string, for htmlpage methods
- (NSString *)value;
- (void)setValue:(NSString *)value;

// value as an array of NSXMLElements, for metatag methods
- (NSArray *)XMLValues;
- (void)setXMLValues:(NSArray *)values;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE
