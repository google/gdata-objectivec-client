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
//  GDataEntrySiteCrawlIssue.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE

#import "GDataEntryBase.h"


@interface GDataEntrySiteCrawlIssue : GDataEntryBase

+ (id)crawlIssueEntry;

// extensions
- (NSString *)crawlType;
- (void)setCrawlType:(NSString *)str;

- (GDataDateTime *)detectedDate;
- (void)setDetectedDate:(GDataDateTime *)dateTime;

- (NSString *)detail;
- (void)setDetail:(NSString *)str;

- (NSString *)issueType;
- (void)setIssueType:(NSString *)str;

- (NSString *)issueURLString;
- (void)setIssueURLString:(NSString *)str;

- (NSArray *)issueLinkedFromURLStrings;
- (void)setIssueLinkedFromURLStrings:(NSArray *)array;
- (void)addIssueLinkedFromURLString:(NSString *)str;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE
