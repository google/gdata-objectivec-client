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
//  GDataCodeSearchMatch.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CODESEARCH_SERVICE

#import "GDataCodeSearchMatch.h"
#import "GDataEntryCodeSearch.h"

static NSString* const kLineNumberAttr = @"lineNumber";

@implementation GDataCodeSearchMatch 

// For code search source matches, like
//
//  <gcs:match lineNumber="23" type="text/html">
//    found &lt;b&gt; query &lt;/b&gt;
//  </gcs:match>
//
// See http://code.google.com/apis/codesearch/reference.html

+ (NSString *)extensionElementURI       { return kGDataNamespaceCodeSearch; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceCodeSearchPrefix; }
+ (NSString *)extensionElementLocalName { return @"match"; }

+ (id)matchWithStringValue:(NSString *)valueStr
                      type:(NSString *)type
          lineNumberString:(NSString *)lineNumberStr {

  GDataCodeSearchMatch *obj = [[[GDataCodeSearchMatch alloc] init] autorelease];
  [obj setStringValue:valueStr];
  [obj setType:type];
  [obj setLineNumberString:lineNumberStr];
  return obj;
}

- (void)addParseDeclarations {
  
  // we're a subclass of GDataTextConstruct, so add its attributes and
  // content value also
  [super addParseDeclarations];
  
  NSArray *attrs = [NSArray arrayWithObject:kLineNumberAttr];
  [self addLocalAttributeDeclarations:attrs];  
}

- (NSString *)lineNumberString {
  return [self stringValueForAttribute:kLineNumberAttr];
}

- (void)setLineNumberString:(NSString *)str {
  [self setStringValue:str forAttribute:kLineNumberAttr];
}
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CODESEARCH_SERVICE
