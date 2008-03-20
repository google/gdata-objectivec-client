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
//  GDataEntryPhotoBase.h
//

#import "GDataEntryBase.h"

#import "GDataPhotoElements.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAPHOTOBASE_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* kGDataNamespacePhotos       _INITIALIZE_AS(@"http://schemas.google.com/photos/2007");
_EXTERN NSString* kGDataNamespacePhotosPrefix _INITIALIZE_AS(@"gphoto");

_EXTERN NSString* kGDataNamespacePhotosEXIF       _INITIALIZE_AS(@"http://schemas.google.com/photos/exif/2007");
_EXTERN NSString* kGDataNamespacePhotosEXIFPrefix _INITIALIZE_AS(@"exif");

_EXTERN NSString* kGDataCategoryPhotosPhoto    _INITIALIZE_AS(@"http://schemas.google.com/photos/2007#photo");
_EXTERN NSString* kGDataCategoryPhotosAlbum    _INITIALIZE_AS(@"http://schemas.google.com/photos/2007#album");
_EXTERN NSString* kGDataCategoryPhotosUser     _INITIALIZE_AS(@"http://schemas.google.com/photos/2007#user");
_EXTERN NSString* kGDataCategoryPhotosTag      _INITIALIZE_AS(@"http://schemas.google.com/photos/2007#tag");
_EXTERN NSString* kGDataCategoryPhotosComment  _INITIALIZE_AS(@"http://schemas.google.com/photos/2007#comment");

@interface GDataEntryPhotoBase : GDataEntryBase {
}

+ (NSDictionary *)photoNamespaces;

- (NSString *)GPhotoID; // <gphoto:id>
- (void)setGPhotoID:(NSString *)str;

// like in the Java library, we'll rename summary as description
- (GDataTextConstruct *)photoDescription;
- (void)setPhotoDescription:(GDataTextConstruct *)obj;
- (void)setPhotoDescriptionWithString:(NSString *)str;
@end
