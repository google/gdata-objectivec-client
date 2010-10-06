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
//  GDataServiceGoogleTranslation.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_TRANSLATION_SERVICE

#import "GDataServiceGoogleTranslation.h"
#import "GDataTranslationConstants.h"

@implementation GDataServiceGoogleTranslation

+ (NSURL *)translationFeedURLForEntryType:(NSString *)entryType {

  NSString *rootURLStr = [self serviceRootURLString];
  NSString *template = @"%@%@";

  NSString *urlStr = [NSString stringWithFormat:template,
                      rootURLStr, entryType];
  return [NSURL URLWithString:urlStr];
}

+ (NSURL *)documentFeedURL {
  return [self translationFeedURLForEntryType:@"documents"];
}

+ (NSURL *)memoryFeedURL {
  return [self translationFeedURLForEntryType:@"tm"];
}

+ (NSURL *)glossaryFeedURL {
  return [self translationFeedURLForEntryType:@"glossary"];
}

#pragma mark -

+ (NSString *)serviceID {
  return @"gtrans";
}

+ (NSString *)serviceRootURLString {
  return @"https://translate.google.com/toolkit/feeds/";
}

+ (NSString *)defaultServiceVersion {
  return kGDataTranslationDefaultServiceVersion;
}

+ (NSDictionary *)standardServiceNamespaces {
  return [GDataTranslationConstants translationNamespaces];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_TRANSLATION_SERVICE
