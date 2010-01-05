/* Copyright (c) 2009 Google Inc.
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
//  GDataTranslationDocumentSource.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_TRANSLATION_SERVICE

#import "GDataTranslationDocumentSource.h"
#import "GDataTranslationConstants.h"

static NSString* const kTypeAttr = @"type";
static NSString* const kURLAttr = @"url";

@implementation GDataTranslationDocumentSource

+ (NSString *)extensionElementURI       { return kGDataNamespaceTranslation; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceTranslationPrefix; }
+ (NSString *)extensionElementLocalName { return @"documentSource"; }

+ (GDataTranslationDocumentSource *)documentSourceWithType:(NSString *)type
                                                 URLString:(NSString *)urlString {

  GDataTranslationDocumentSource *obj = [[[self alloc] init] autorelease];
  [obj setType:type];
  [obj setURLString:urlString];
  return obj;
}

- (void)addParseDeclarations {
  NSArray *attrs = [NSArray arrayWithObjects:
                    kTypeAttr, kURLAttr, nil];

  [self addLocalAttributeDeclarations:attrs];
}

#pragma mark -

- (NSString *)type {
  return [self stringValueForAttribute:kTypeAttr];
}

- (void)setType:(NSString *)str {
  [self setStringValue:str forAttribute:kTypeAttr];
}

- (NSString *)URLString {
  return [self stringValueForAttribute:kURLAttr];
}

- (void)setURLString:(NSString *)str {
  [self setStringValue:str forAttribute:kURLAttr];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_TRANSLATION_SERVICE
