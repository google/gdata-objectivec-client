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

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE

//
//  GDataDocMaxUploadSize.h
//

#import "GDataObject.h"
#import "GDataValueConstruct.h"

// an upload size, such as
//
//  <docs:maxUploadSize kind="spreadsheet">3124125</docs:maxUploadSize>

@interface GDataDocMaxUploadSize : GDataValueElementConstruct <GDataExtension>
// For the value, use
//
// - (NSNumber *)longLongNumberValue;
// - (long long)longLongValue;
// - (void)setLongLongValue:(long long)val;

- (NSString *)uploadKind;
- (void)setUploadKind:(NSString *)str;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE
