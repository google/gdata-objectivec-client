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
#import "GDataDublinCore.h"
#import "GDataRating.h"
#import "GDataComment.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAENTRYVOLUME_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataBooksDefaultServiceVersion _INITIALIZE_AS(@"1.0");

_EXTERN NSString* const kGDataNamespaceBooks       _INITIALIZE_AS(@"http://schemas.google.com/books/2008");
_EXTERN NSString* const kGDataNamespaceBooksPrefix _INITIALIZE_AS(@"gbs");

_EXTERN NSString* const kGDataCategoryBooksVolume       _INITIALIZE_AS(@"http://schemas.google.com/books/2008#volume");
_EXTERN NSString* const kGDataCategoryBooksCollection   _INITIALIZE_AS(@"http://schemas.google.com/books/2008#collection");

_EXTERN NSString* const kGDataBooksViewAllPages _INITIALIZE_AS(@"http://schemas.google.com/books/2008#view_all_pages");
_EXTERN NSString* const kGDataBooksViewNoPages  _INITIALIZE_AS(@"http://schemas.google.com/books/2008#view_no_pages");
_EXTERN NSString* const kGDataBooksViewPartial  _INITIALIZE_AS(@"http://schemas.google.com/books/2008#view_partial");
_EXTERN NSString* const kGDataBooksViewUnknown  _INITIALIZE_AS(@"http://schemas.google.com/books/2008#view_unknown");

_EXTERN NSString* const kGDataBooksEmbeddable     _INITIALIZE_AS(@"http://schemas.google.com/books/2008#embeddable");
_EXTERN NSString* const kGDataBooksNotEmbeddable  _INITIALIZE_AS(@"http://schemas.google.com/books/2008#not_embeddable");

_EXTERN NSString* const kGDataBooksEnabled   _INITIALIZE_AS(@"http://schemas.google.com/books/2008#enabled");
_EXTERN NSString* const kGDataBooksDisabled  _INITIALIZE_AS(@"http://schemas.google.com/books/2008#disabled");

_EXTERN NSString* const kGDataBooksInfoRel         _INITIALIZE_AS(@"http://schemas.google.com/books/2008/info");
_EXTERN NSString* const kGDataBooksPreviewRel      _INITIALIZE_AS(@"http://schemas.google.com/books/2008/preview");
_EXTERN NSString* const kGDataBooksThumbnailRel    _INITIALIZE_AS(@"http://schemas.google.com/books/2008/thumbnail");
_EXTERN NSString* const kGDataBooksAnnotationRel   _INITIALIZE_AS(@"http://schemas.google.com/books/2008/annotation");
_EXTERN NSString* const kGDataBooksEPubDownloadRel _INITIALIZE_AS(@"http://schemas.google.com/books/2008/epubdownload");

_EXTERN NSString* const kGDataBooksLabelsScheme    _INITIALIZE_AS(@"http://schemas.google.com/books/2008/labels");


@interface GDataVolumeViewability : GDataValueConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataVolumeEmbeddability : GDataValueConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataVolumeOpenAccess : GDataValueConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataVolumeReview : GDataTextConstruct <GDataExtension>
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataEntryVolume : GDataEntryBase

+ (NSDictionary *)booksNamespaces;

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

- (NSString*)openAccess;
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
