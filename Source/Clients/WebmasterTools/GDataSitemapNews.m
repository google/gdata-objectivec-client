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
//  GDataSitemapNews.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE

#import "GDataSitemapNews.h"

#import "GDataWebmasterToolsConstants.h"
#import "GDataEntrySitemap.h" // for GDataSitemapPublicationLabel

// News elements, like
//
//      <wt:sitemap-news>
//        <wt:publication-label>Value1</wt:publication-label>
//        <wt:publication-label>Value2</wt:publication-label>
//        <wt:publication-label>Value3</wt:publication-label>
//      </wt:sitemap-news>
//
// http://code.google.com/apis/webmastertools/docs/reference.html

@implementation GDataSitemapPublicationLabel
+ (NSString *)extensionElementPrefix { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementURI { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementLocalName { return @"publication-label"; }
@end

@implementation GDataSitemapNews

+ (NSString *)extensionElementPrefix { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementURI { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementLocalName { return @"sitemap-news"; }

+ (id)sitemapNews {
  
  GDataSitemapNews *obj;
  obj = [self object];
  return obj;
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataSitemapPublicationLabel class]];  
}

#pragma mark -

- (NSArray *)publicationLabels {
  return [self objectsForExtensionClass:[GDataSitemapPublicationLabel class]];  
}

- (void)setPublicationLabels:(NSArray *)arr {
  [self setObjects:arr forExtensionClass:[GDataSitemapPublicationLabel class]];
}

- (void)addPublicationLabel:(GDataSitemapPublicationLabel *)obj {
  [self addObject:obj forExtensionClass:[GDataSitemapPublicationLabel class]]; 
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE
