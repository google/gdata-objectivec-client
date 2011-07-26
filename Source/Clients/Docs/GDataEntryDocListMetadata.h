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
//  GDataEntryDocListMetadata.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE

#import "GDataEntryBase.h"
#import "GDataDocConstants.h"
#import "GDataDocElements.h"
#import "GDataDocFeature.h"
#import "GDataDocMaxUploadSize.h"
#import "GDataDocTransferFormat.h" // importFormat/exportFormat

@interface GDataEntryDocListMetadata : GDataEntryBase

// extensions

- (NSArray *)exportFormats; // array of GDataDocExportFormat
- (void)setExportFormats:(NSArray *)array;

- (NSArray *)features; // array of GDataDocFeature
- (void)setFeatures:(NSArray *)array;

- (NSArray *)importFormats; // array of GDataDocImportFormat
- (void)setImportFormats:(NSArray *)array;

- (NSArray *)maxUploadSizes; // array of GDataDocMaxUploadSize
- (void)setMaxUploadSizes:(NSArray *)array;

- (NSNumber *)quotaBytesTotal; // long long
- (void)setQuotaBytesTotal:(NSNumber *)num;

- (NSNumber *)quotaBytesUsed; // long long
- (void)setQuotaBytesUsed:(NSNumber *)num;

- (NSNumber *)quotaBytesUsedInTrash; // long long
- (void)setQuotaBytesUsedInTrash:(NSNumber *)num;

- (NSNumber *)largestChangestamp; // long long
- (void)setLargestChangestamp:(NSNumber *)num;

// convenience accessors
- (GDataDocMaxUploadSize *)maxUploadSizeForKind:(NSString *)uploadKind;
- (GDataDocFeature *)featureForName:(NSString *)name;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE
