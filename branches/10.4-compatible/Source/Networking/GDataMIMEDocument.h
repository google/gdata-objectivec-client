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


// This is a simple class to create a MIME document.  To use, allocate
// a new GDataMIMEDocument and start adding parts as necessary.  When you are
// done adding parts, call generateInputStream to get an NSInputStream
// containing the contents of your MIME document.
//
// A good reference for MIME is http://en.wikipedia.org/wiki/MIME

#import <Foundation/Foundation.h>

#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4) || defined(GDATA_TARGET_NAMESPACE)
  // we need NSInteger for the 10.4 SDK, or we're using target namespace macros
  #import "GDataDefines.h"
#endif

@interface GDataMIMEDocument : NSObject {
  NSMutableArray* parts_;         // Contains an ordered set of MimeParts
  unsigned long long length_;     // Length in bytes of the document.
  u_int32_t randomSeed_;          // for testing
}

+ (GDataMIMEDocument *)MIMEDocument;

// Adds a new part to this mime document with the given headers and body.  The
// headers keys and values should be NSStrings
- (void)addPartWithHeaders:(NSDictionary *)headers
                      body:(NSData *)body;

// An inputstream that can be used to efficiently read the contents of the
// mime document.
- (void)generateInputStream:(NSInputStream **)outStream
                     length:(unsigned long long*)outLength
                   boundary:(NSString **)outBoundary;

// ------ UNIT TESTING ONLY BELOW ------

// For unittesting only, seeds the random number generator
- (void)seedRandomWith:(unsigned int)seed;

@end
