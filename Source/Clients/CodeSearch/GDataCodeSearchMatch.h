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
//  GDataCodeSearchMatch.h
//

#import "GDataObject.h"
#import "GDataTextConstruct.h"

// For code search source matches, like
//
//  <gcs:match lineNumber="23" type="text/html">
//    found &lt;b&gt; query &lt;/b&gt;
//  </gcs:match>
//
// See http://code.google.com/apis/codesearch/reference.html

@interface GDataCodeSearchMatch : GDataTextConstruct <NSCopying, GDataExtension> {
  NSString *lineNumberString_;
}

+ (id)matchWithStringValue:(NSString *)valueStr
                      type:(NSString *)type
          lineNumberString:(NSString *)lineNumberStr;

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent;

- (NSXMLElement *)XMLElement;

- (NSString *)lineNumberString;
- (void)setLineNumberString:(NSString *)str;
@end
