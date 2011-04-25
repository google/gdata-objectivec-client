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
//  GDataCodeSearchPackage.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CODESEARCH_SERVICE

#import "GDataObject.h"

// For code search packages, like
//
//  <gcs:package name="http://www.w3.org/Library/Distribution/w3c-libwww-5.4.0.zip"
//    uri="http://www.w3.org/Library/Distribution/w3c-libwww-5.4.0.zip"/>
//
// See http://code.google.com/apis/codesearch/reference.html

@interface GDataCodeSearchPackage : GDataObject <NSCopying, GDataExtension> {
  NSString *name_;
  NSString *uri_;
}

+ (id)packageWithName:(NSString *)name
                  URI:(NSString *)uri;

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent;

- (NSXMLElement *)XMLElement;

- (NSString *)name;
- (void)setName:(NSString *)str;

- (NSString *)URI;
- (void)setURI:(NSString *)str;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CODESEARCH_SERVICE
