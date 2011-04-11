/* Copyright (c) 2007-2008 Google Inc.
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

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CODESEARCH_SERVICE

#import "GDataObject.h"
#import "GDataTextConstruct.h"

// For code search source matches, like
//
//  <gcs:match lineNumber="23" type="text/html">
//    found &lt;b&gt; query &lt;/b&gt;
//  </gcs:match>
//
// See http://code.google.com/apis/codesearch/reference.html

@interface GDataCodeSearchMatch : GDataTextConstruct <GDataExtension> {
}

+ (id)matchWithStringValue:(NSString *)valueStr
                      type:(NSString *)type
          lineNumberString:(NSString *)lineNumberStr;

- (NSString *)lineNumberString;
- (void)setLineNumberString:(NSString *)str;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CODESEARCH_SERVICE
