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
//  GDataFeedTranslationDocument.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_TRANSLATION_SERVICE

#import "GDataFeedTranslationDocument.h"
#import "GDataEntryTranslationDocument.h"
#import "GDataTranslationConstants.h"

@implementation GDataFeedTranslationDocument

+ (GDataFeedTranslationDocument *)translationDocumentFeed {

  GDataFeedTranslationDocument *feed = [[[self alloc] init] autorelease];

  [feed setNamespaces:[GDataTranslationConstants translationNamespaces]];

  return feed;
}

- (Class)classForEntries {
  return [GDataEntryTranslationDocument class];
}

+ (NSString *)defaultServiceVersion {
  return kGDataTranslationDefaultServiceVersion;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_TRANSLATION_SERVICE
