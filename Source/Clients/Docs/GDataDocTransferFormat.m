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
//  GDataDocTransferFormat.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE

#import "GDataDocTransferFormat.h"
#import "GDataDocConstants.h"
#import "GDataValueConstruct.h"

@implementation GDataDocImportFormat
+ (NSString *)extensionElementURI       { return kGDataNamespaceDocuments; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDocumentsPrefix; }
+ (NSString *)extensionElementLocalName { return @"importFormat"; }
@end

@implementation GDataDocExportFormat
+ (NSString *)extensionElementURI       { return kGDataNamespaceDocuments; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceDocumentsPrefix; }
+ (NSString *)extensionElementLocalName { return @"exportFormat"; }
@end

static NSString* const kSourceAttr = @"source";
static NSString* const kTargetAttr = @"target";

@implementation GDataDocTransferFormat

- (void)addParseDeclarations {
  NSArray *attrs = [NSArray arrayWithObjects:
                    kSourceAttr, kTargetAttr, nil];

  [self addLocalAttributeDeclarations:attrs];
}

#pragma mark -

- (NSString *)source {
  return [self stringValueForAttribute:kSourceAttr];
}

- (void)setSource:(NSString *)str {
  [self setStringValue:str forAttribute:kSourceAttr];
}

- (NSString *)target {
  return [self stringValueForAttribute:kTargetAttr];
}

- (void)setTarget:(NSString *)str {
  [self setStringValue:str forAttribute:kTargetAttr];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE
