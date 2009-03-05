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
// GDataDefines.h
//

// Ensure Apple's conditionals we depend on are defined.
#import <TargetConditionals.h>

//
// The developer may choose to define these in the project:
//
//   #define GDATA_TARGET_NAMESPACE Xxx  // preface all GData class names with Xxx (recommended for building plug-ins)
//   #define GDATA_FOUNDATION_ONLY 1     // builds without AppKit or Carbon (default for iPhone builds)
//   #define GDATA_SIMPLE_DESCRIPTIONS 1 // remove elaborate -description methods, reducing code size (default for iPhone release builds)
//   #define STRIP_GDATA_FETCH_LOGGING 1 // omit http logging code (default for iPhone release builds)
//
// Mac developers may find GDATA_SIMPLE_DESCRIPTIONS and STRIP_GDATA_FETCH_LOGGING useful for
// reducing code size.
//

// Define later OS versions when building on earlier versions
#ifndef MAC_OS_X_VERSION_10_5
  #define MAC_OS_X_VERSION_10_5 1050
#endif
#ifndef MAC_OS_X_VERSION_10_6
  #define MAC_OS_X_VERSION_10_6 1060
#endif


#ifdef GDATA_TARGET_NAMESPACE
// prefix all GData class names with GDATA_TARGET_NAMESPACE for this target
  #import "GDataTargetNamespace.h"
#endif

#if TARGET_OS_IPHONE // iPhone SDK

  #define GDATA_IPHONE 1

#endif

#if GDATA_IPHONE

  #define GDATA_FOUNDATION_ONLY 1

  #define GDATA_USES_LIBXML 1

  #import "GDataXMLNode.h"

  #define NSXMLDocument                  GDataXMLDocument
  #define NSXMLElement                   GDataXMLElement
  #define NSXMLNode                      GDataXMLNode
  #define NSXMLNodeKind                  GDataXMLNodeKind
  #define NSXMLInvalidKind               GDataXMLInvalidKind
  #define NSXMLDocumentKind              GDataXMLDocumentKind
  #define NSXMLElementKind               GDataXMLElementKind
  #define NSXMLAttributeKind             GDataXMLAttributeKind
  #define NSXMLNamespaceKind             GDataXMLNamespaceKind
  #define NSXMLProcessingInstructionKind GDataXMLDocumentKind
  #define NSXMLCommentKind               GDataXMLCommentKind
  #define NSXMLTextKind                  GDataXMLTextKind
  #define NSXMLDTDKind                   GDataXMLDTDKind
  #define NSXMLEntityDeclarationKind     GDataXMLEntityDeclarationKind
  #define NSXMLAttributeDeclarationKind  GDataXMLAttributeDeclarationKind
  #define NSXMLElementDeclarationKind    GDataXMLElementDeclarationKind
  #define NSXMLNotationDeclarationKind   GDataXMLNotationDeclarationKind

  // properties used for retaining the XML tree in the classes that use them
  #define kGDataXMLDocumentPropertyKey @"_XMLDocument"
  #define kGDataXMLElementPropertyKey  @"_XMLElement"
#endif

//
// GDATA_ASSERT is like NSAssert, but takes a variable number of arguments:
//
//     GDATA_ASSERT(condition, @"Problem in argument %@", argStr);
//
// GDATA_DEBUG_ASSERT is similar, but compiles in only for debug builds
//

#ifndef GDATA_ASSERT
  // we directly invoke the NSAssert handler so we can pass on the varargs
  #if !defined(NS_BLOCK_ASSERTIONS)
    #define GDATA_ASSERT(condition, ...)                                       \
      do {                                                                     \
        if (!(condition)) {                                                    \
          [[NSAssertionHandler currentHandler]                                 \
              handleFailureInFunction:[NSString stringWithUTF8String:__PRETTY_FUNCTION__] \
                                 file:[NSString stringWithUTF8String:__FILE__] \
                           lineNumber:__LINE__                                 \
                          description:__VA_ARGS__];                            \
        }                                                                      \
      } while(0)
  #else
    #define GDATA_ASSERT(condition, ...) do { } while (0)
  #endif // !defined(NS_BLOCK_ASSERTIONS)
#endif // GDATA_ASSERT

#ifndef GDATA_DEBUG_ASSERT
  #if DEBUG
    #define GDATA_DEBUG_ASSERT(condition, ...) GDATA_ASSERT(condition, __VA_ARGS__)
  #else
    #define GDATA_DEBUG_ASSERT(condition, ...) do { } while (0)
  #endif
#endif

#ifndef GDATA_DEBUG_LOG
  #if DEBUG
    #define GDATA_DEBUG_LOG(...) NSLog(__VA_ARGS__)
  #else
    #define GDATA_DEBUG_LOG(...) do { } while (0)
  #endif
#endif


//
// macro to allow fast enumeration when building for 10.5 or later, and
// reliance on NSEnumerator for 10.4
//
#ifndef GDATA_FOREACH
  #if TARGET_OS_IPHONE || (MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_5)
    #define GDATA_FOREACH(element, collection) \
      for (element in collection)
    #define GDATA_FOREACH_KEY(key, dict) \
      for (key in dict)
  #else
    #define GDATA_FOREACH(element, collection) \
      for (NSEnumerator* _ ## element ## _enum = [collection objectEnumerator]; \
          (element = [_ ## element ## _enum nextObject]) != nil; )
    #define GDATA_FOREACH_KEY(key, dict) \
      for (NSEnumerator* _ ## key ## _enum = [dict keyEnumerator]; \
          (key = [_ ## key ## _enum nextObject]) != nil; )
  #endif
#endif


//
// To reduce code size on iPhone release builds, we compile out the helpful
// description methods for GData objects
//
#ifndef GDATA_SIMPLE_DESCRIPTIONS
  #if GDATA_IPHONE && !DEBUG
    #define GDATA_SIMPLE_DESCRIPTIONS 1
  #else
    #define GDATA_SIMPLE_DESCRIPTIONS 0
  #endif
#endif

#ifndef STRIP_GDATA_FETCH_LOGGING
  #if GDATA_IPHONE && !DEBUG
    #define STRIP_GDATA_FETCH_LOGGING 1
  #else
    #define STRIP_GDATA_FETCH_LOGGING 0
  #endif
#endif


// To simplify support for 64bit (and Leopard in general), we provide the type
// defines for non Leopard SDKs
#if MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4
  // NSInteger/NSUInteger and Max/Mins
  #ifndef NSINTEGER_DEFINED
    #if __LP64__ || NS_BUILD_32_LIKE_64
      typedef long NSInteger;
      typedef unsigned long NSUInteger;
    #else
      typedef int NSInteger;
      typedef unsigned int NSUInteger;
    #endif
    #define NSIntegerMax    LONG_MAX
    #define NSIntegerMin    LONG_MIN
    #define NSUIntegerMax   ULONG_MAX
    #define NSINTEGER_DEFINED 1
  #endif  // NSINTEGER_DEFINED
#endif  // MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4
