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
//  GDataDublinCore.m
//

//
// DublinCore elements - http://uk.dublincore.org/documents/dces/
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BOOKS_SERVICE

#define GDATADUBLINCORE_DEFINE_GLOBALS 1
#import "GDataDublinCore.h"

@implementation GDataDCCreator
+ (NSString *)extensionElementURI       { return kGDataNamespaceDublinCore; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDublinCorePrefix; }
+ (NSString *)extensionElementLocalName { return @"creator"; }
@end

@implementation GDataDCDate
+ (NSString *)extensionElementURI       { return kGDataNamespaceDublinCore; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDublinCorePrefix; }
+ (NSString *)extensionElementLocalName { return @"date"; }
@end

@implementation GDataDCDescription
+ (NSString *)extensionElementURI       { return kGDataNamespaceDublinCore; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDublinCorePrefix; }
+ (NSString *)extensionElementLocalName { return @"description"; }
@end

@implementation GDataDCFormat
+ (NSString *)extensionElementURI       { return kGDataNamespaceDublinCore; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDublinCorePrefix; }
+ (NSString *)extensionElementLocalName { return @"format"; }
@end

@implementation GDataDCIdentifier
+ (NSString *)extensionElementURI       { return kGDataNamespaceDublinCore; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDublinCorePrefix; }
+ (NSString *)extensionElementLocalName { return @"identifier"; }
@end

@implementation GDataDCLanguage
+ (NSString *)extensionElementURI       { return kGDataNamespaceDublinCore; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDublinCorePrefix; }
+ (NSString *)extensionElementLocalName { return @"language"; }
@end

@implementation GDataDCPublisher
+ (NSString *)extensionElementURI       { return kGDataNamespaceDublinCore; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDublinCorePrefix; }
+ (NSString *)extensionElementLocalName { return @"publisher"; }
@end

@implementation GDataDCSubject
+ (NSString *)extensionElementURI       { return kGDataNamespaceDublinCore; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDublinCorePrefix; }
+ (NSString *)extensionElementLocalName { return @"subject"; }
@end

@implementation GDataDCTitle
+ (NSString *)extensionElementURI       { return kGDataNamespaceDublinCore; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDublinCorePrefix; }
+ (NSString *)extensionElementLocalName { return @"title"; }
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BOOKS_SERVICE
