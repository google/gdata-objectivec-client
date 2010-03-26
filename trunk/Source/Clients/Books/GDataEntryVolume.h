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
//  GDataEntryVolume.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BOOKS_SERVICE

#import "GDataEntryBase.h"
#import "GDataValueConstruct.h"
#import "GDataRating.h"
#import "GDataComment.h"
#import "GDataDublinCore.h"

@interface GDataVolumeViewability : GDataValueConstruct <GDataExtension>
@end

@interface GDataVolumeEmbeddability : GDataValueConstruct <GDataExtension>
@end

@interface GDataVolumeOpenAccess : GDataValueConstruct <GDataExtension>
@end

@interface GDataVolumeReview : GDataTextConstruct <GDataExtension>
@end

@interface GDataEntryVolume : GDataEntryBase

+ (GDataEntryVolume *)volumeEntry;

// extensions

- (GDataComment *)comment;
- (void)setComment:(GDataComment *)obj;

- (NSArray *)creators;
- (void)setCreators:(NSArray *)arr;
- (void)addCreator:(GDataDCCreator *)obj;

- (NSArray *)dates;
- (void)setDates:(NSArray *)arr;
- (void)addDate:(GDataDCDate *)obj;

- (NSArray *)volumeDescriptions; 
- (void)setVolumeDescriptions:(NSArray *)arr;
- (void)addVolumeDescriptions:(GDataDCFormat *)obj;

- (NSString *)embeddability;
- (void)setEmbeddability:(NSString *)str;

- (NSString *)openAccess;
- (void)setOpenAccess:(NSString *)str;

- (NSArray *)formats;
- (void)setFormats:(NSArray *)arr;
- (void)addFormat:(GDataDCFormat *)obj;

- (NSArray *)volumeIdentifiers;
- (void)setVolumeIdentifiers:(NSArray *)arr;
- (void)addVolumeIdentifier:(GDataDCIdentifier *)obj;

- (NSArray *)languages;
- (void)setLanguages:(NSArray *)arr;
- (void)addLanguage:(GDataDCLanguage *)obj;

- (NSArray *)publishers;
- (void)setPublishers:(NSArray *)arr;
- (void)addPublisher:(GDataDCPublisher *)obj;

- (GDataRating *)rating;
- (void)setRating:(GDataRating *)obj;

- (GDataVolumeReview *)review;
- (void)setReview:(GDataVolumeReview *)obj;

- (NSArray *)subjects;
- (void)setSubjects:(NSArray *)arr;
- (void)addSubject:(GDataDCSubject *)obj;

- (NSArray *)volumeTitles;
- (void)setVolumeTitles:(NSArray *)arr;
- (void)addVolumeTitle:(GDataDCTitle *)obj;

- (NSString *)viewability;
- (void)setViewability:(NSString *)str;

// convenience accessors
- (GDataLink *)thumbnailLink;
- (GDataLink *)previewLink;
- (GDataLink *)infoLink;
- (GDataLink *)annotationLink;
- (GDataLink *)EPubDownloadLink;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BOOKS_SERVICE
