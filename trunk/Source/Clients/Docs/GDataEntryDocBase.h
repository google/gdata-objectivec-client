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
//  GDataEntryDocBase.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE

#import "GDataEntryBase.h"
#import "GDataFeedLink.h"
#import "GDataDocConstants.h"

@interface GDataEntryDocBase : GDataEntryBase

+ (id)documentEntry;

// extensions
- (GDataDateTime *)lastViewed;
- (void)setLastViewed:(GDataDateTime *)dateTime;

- (NSNumber *)writersCanInvite; // bool
- (void)setWritersCanInvite:(NSNumber *)num;

- (GDataPerson *)lastModifiedBy;
- (void)setLastModifiedBy:(GDataPerson *)obj;

- (NSNumber *)quotaBytesUsed; // long long
- (void)setQuotaBytesUsed:(NSNumber *)num;

// categories
- (BOOL)isStarred;
- (void)setIsStarred:(BOOL)flag;

- (BOOL)isHidden;
- (void)setIsHidden:(BOOL)flag;

// convenience accessors
- (NSArray *)parentLinks;

- (GDataFeedLink *)ACLFeedLink;
- (GDataFeedLink *)revisionFeedLink;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE
