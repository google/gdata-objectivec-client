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
//  GDataDublinCore.h
//

//
// DublinCore elements - http://uk.dublincore.org/documents/dces/
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BOOKS_SERVICE

#import "GDataValueConstruct.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATADUBLINCORE_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN GDATA_EXTERN
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataNamespaceDublinCore       _INITIALIZE_AS(@"http://purl.org/dc/terms");
_EXTERN NSString* const kGDataNamespaceDublinCorePrefix _INITIALIZE_AS(@"dc");

@interface GDataDCCreator : GDataValueElementConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataDCDate : GDataValueElementConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataDCDescription : GDataValueElementConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataDCFormat : GDataValueElementConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataDCIdentifier : GDataValueElementConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataDCLanguage : GDataValueElementConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataDCPublisher : GDataValueElementConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataDCSubject : GDataValueElementConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataDCTitle : GDataValueElementConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BOOKS_SERVICE
