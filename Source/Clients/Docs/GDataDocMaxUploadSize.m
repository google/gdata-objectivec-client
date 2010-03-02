/* Copyright (c) 2010 Google Inc.
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
//  GDataDocMaxUploadSize.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE

#import "GDataDocMaxUploadSize.h"
#import "GDataDocConstants.h"

static NSString *const kKindAttr = @"kind";

@implementation GDataDocMaxUploadSize
// an upload size, such as
//
//  <docs:maxUploadSize kind="spreadsheet">3124125</docs:maxUploadSize>

+ (NSString *)extensionElementURI       { return kGDataNamespaceDocuments; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDocumentsPrefix; }
+ (NSString *)extensionElementLocalName { return @"maxUploadSize"; }

- (void)addParseDeclarations {
  [super addParseDeclarations];

  NSArray *attrs = [NSArray arrayWithObject:kKindAttr];
  [self addLocalAttributeDeclarations:attrs];
}

#pragma mark -

- (NSString *)uploadKind {
  return [self stringValueForAttribute:kKindAttr];
}

- (void)setUploadKind:(NSString *)str {
  [self setStringValue:str forAttribute:kKindAttr];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE
