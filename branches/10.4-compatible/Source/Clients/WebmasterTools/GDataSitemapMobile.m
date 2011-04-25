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
//  GDataSitemapMobile.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE

#import "GDataSitemapMobile.h"

#import "GDataWebmasterToolsConstants.h"

// Mobile elements, like
//
//       <wt:sitemap-mobile>
//           <wt:markup-language>HTML</wt:markup-language>
//           <wt:markup-language>WAP</wt:markup-language>
//       </wt:sitemap-mobile>
//
// http://code.google.com/apis/webmastertools/docs/reference.html

@implementation GDataSitemapMarkupLanguage
+ (NSString *)extensionElementURI       { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementLocalName { return @"markup-language"; }
@end

@implementation GDataSitemapMobile

+ (NSString *)extensionElementPrefix { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementURI { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementLocalName { return @"sitemap-mobile"; }

+ (id)sitemapMobile {
  
  GDataSitemapMobile *obj;
  obj = [[[GDataSitemapMobile alloc] init] autorelease];
  return obj;
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataSitemapMarkupLanguage class]];  
}

#pragma mark -

- (NSArray *)markupLanguages {
  return [self objectsForExtensionClass:[GDataSitemapMarkupLanguage class]];  
}

- (void)setMarkupLanguages:(NSArray *)arr {
  [self setObjects:arr forExtensionClass:[GDataSitemapMarkupLanguage class]];
}

- (void)addMarkupLanguage:(GDataSitemapMarkupLanguage *)obj {
  [self addObject:obj forExtensionClass:[GDataSitemapMarkupLanguage class]]; 
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE
