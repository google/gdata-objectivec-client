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
//  GDataEntryTranslationDocument.h
//

//
// For access to ACLs, use the ACLLink category on the entry
// from GDataEntryACL.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_TRANSLATION_SERVICE

#import "GDataEntryBase.h"
#import "GDataTranslationElements.h"
#import "GDataTranslationDocumentSource.h"

@interface GDataEntryTranslationDocument : GDataEntryBase

+ (GDataEntryTranslationDocument *)documentWithTitle:(NSString *)title
                                      sourceLanguage:(NSString *)sourceLanguage
                                      targetLanguage:(NSString *)targetLanguage;

// extensions

- (GDataTranslationDocumentSource *)documentSource;
- (void)setDocumentSource:(GDataTranslationDocumentSource *)obj;

- (GDataTranslationGlossary *)glossary;
- (void)setGlossary:(GDataTranslationGlossary *)obj;

- (GDataPerson *)lastModifiedBy;
- (void)setLastModifiedBy:(GDataPerson *)obj;

- (NSNumber *)numberOfSourceWords; // int
- (void)setNumberOfSourceWords:(NSNumber *)num;

- (NSNumber *)percentComplete; // int
- (void)setPercentComplete:(NSNumber *)num;

- (NSString *)sourceLanguage;
- (void)setSourceLanguage:(NSString *)str;

- (NSString *)targetLanguage;
- (void)setTargetLanguage:(NSString *)str;

- (GDataTranslationMemory *)translationMemory;
- (void)setTranslationMemory:(GDataTranslationMemory *)obj;

// convenience accessors

- (BOOL)isHidden;
- (void)setIsHidden:(BOOL)flag;

- (BOOL)hasCompletedTranslation;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_TRANSLATION_SERVICE
