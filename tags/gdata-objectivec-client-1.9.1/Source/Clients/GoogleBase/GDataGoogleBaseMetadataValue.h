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
//  GDataGoogleBaseMetadataValue.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_GOOGLEBASE_SERVICE

#import "GDataObject.h"



// for values, like <gm:value count='87269'>products</gm:value>

@interface GDataGoogleBaseMetadataValue : GDataObject <NSCopying, GDataExtension> {
  NSString *contents_;
  NSNumber *count_;
}

+ (GDataGoogleBaseMetadataValue *)metadataValueWithContents:(NSString *)contents
                      count:(NSNumber *)count;

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent;

- (NSXMLElement *)XMLElement;

- (NSString *)contents;
- (void)setContents:(NSString *)str;

- (NSNumber *)count;
- (void)setCount:(NSNumber *)num;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_GOOGLEBASE_SERVICE
