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
//  GDataEntryDocRevision.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE

#import "GDataEntryBase.h"

@interface GDataDocPublish : GDataValueConstruct <GDataExtension>
@end

@interface GDataDocPublishAuto : GDataValueConstruct <GDataExtension>
@end

@interface GDataDocPublishOutsideDomain : GDataValueConstruct <GDataExtension>
@end

@interface GDataEntryDocRevision : GDataEntryBase

+ (id)revisionEntry;

- (NSNumber *)publish; // BOOL
- (void)setPublish:(NSNumber *)num;

- (NSNumber *)publishAuto; // BOOL
- (void)setPublishAuto:(NSNumber *)num;

- (NSNumber *)publishOutsideDomain; // BOOL
- (void)setPublishOutsideDomain:(NSNumber *)num;

// convenience accessors
- (GDataPerson *)modifyingUser;
- (void)setModifyingUser:(GDataPerson *)obj;

- (GDataLink *)publishedLink;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE
