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
//  GDataSitemapMobile.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE

#import "GDataObject.h"
#import "GDataValueConstruct.h"

// Mobile elements, like
//
//       <wt:sitemap-mobile>
//           <wt:markup-language>HTML</wt:markup-language>
//           <wt:markup-language>WAP</wt:markup-language>
//       </wt:sitemap-mobile>
//
// http://code.google.com/apis/webmastertools/docs/reference.html

@interface GDataSitemapMarkupLanguage : GDataValueElementConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataSitemapMobile : GDataObject <GDataExtension>
+ (id)sitemapMobile;

- (NSArray *)markupLanguages;
- (void)setMarkupLanguages:(NSArray *)arr;
- (void)addMarkupLanguage:(GDataSitemapMarkupLanguage *)obj;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE
