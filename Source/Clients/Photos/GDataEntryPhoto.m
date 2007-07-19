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
//  GDataEntryPhoto.m
//

#import "GDataEntryPhoto.h"
#import "GDataPhotoElements.h"
#import "GDataMIMEDocument.h"

@implementation GDataEntryPhoto

+ (GDataEntryPhoto *)photoEntry {
  
  GDataEntryPhoto *entry = [[[GDataEntryPhoto alloc] init] autorelease];

  [entry setNamespaces:[GDataEntryPhoto photoNamespaces]];
  
  return entry;
}

#pragma mark -

+ (void)load {
  [GDataObject registerEntryClass:[self class]
            forCategoryWithScheme:nil 
                             term:kGDataCategoryPhotosPhoto];
}

- (void)initExtensionDeclarations {
  
  [super initExtensionDeclarations];
  
  Class entryClass = [self class];
  
  // Photo extensions
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataPhotoVersion class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataPhotoPosition class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataPhotoWidth class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataPhotoHeight class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataPhotoRotation class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataPhotoSize class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataPhotoAlbumID class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataPhotoTimestamp class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataPhotoCommentCount class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataPhotoCommentingEnabled class]];
  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataPhotoClient class]];
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataPhotoChecksum class]];
  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataMediaGroup class]];

  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataEXIFTags class]];

  [GDataGeo addGeoExtensionDeclarationsToObject:self
                                 forParentClass:entryClass];
}

- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [super itemsForDescription];
  [self addToArray:items objectDescriptionIfNonNil:[self albumID] withName:@"albumID"];
  [self addToArray:items objectDescriptionIfNonNil:[self checksum] withName:@"checksum"];
  [self addToArray:items objectDescriptionIfNonNil:[self client] withName:@"client"];
  [self addToArray:items objectDescriptionIfNonNil:[self commentCount] withName:@"commentCount"];
  [self addToArray:items objectDescriptionIfNonNil:[self commentsEnabled] withName:@"commentsEnabled"];
  [self addToArray:items objectDescriptionIfNonNil:[self height] withName:@"height"];
  [self addToArray:items objectDescriptionIfNonNil:[self width] withName:@"width"];
  [self addToArray:items objectDescriptionIfNonNil:[self position] withName:@"position"];
  [self addToArray:items objectDescriptionIfNonNil:[self rotation] withName:@"rotation"];
  [self addToArray:items objectDescriptionIfNonNil:[self size] withName:@"size"];
  [self addToArray:items objectDescriptionIfNonNil:[self timestamp] withName:@"timestamp"];
  [self addToArray:items objectDescriptionIfNonNil:[self version] withName:@"version"];

  [self addToArray:items objectDescriptionIfNonNil:[self mediaGroup] withName:@"mediaGroup"];
  [self addToArray:items objectDescriptionIfNonNil:[self EXIFTags] withName:@"exifTags"];
  [self addToArray:items objectDescriptionIfNonNil:[self geoLocation] withName:@"geoLocation"];
  
  return items;
}

- (id)init {
  self = [super init];
  if (self) {
    [self addCategory:[GDataCategory categoryWithScheme:kGDataCategoryScheme
                                                   term:kGDataCategoryPhotosPhoto]];
  }
  return self;
}

- (void)dealloc {
  [photoUploadData_ release];
  [photoMIMEType_ release];
  [super dealloc];
}

#pragma mark -

// binary photo uploading

- (void)setPhotoData:(NSData *)data {
  [photoUploadData_ autorelease];
  photoUploadData_ = [data retain];  
}

- (NSData *)photoData {
  return photoUploadData_; 
}

- (void)setPhotoMIMEType:(NSString *)str {
  [photoMIMEType_ autorelease];
  photoMIMEType_ = [str copy];
}

- (NSString *)photoMIMEType {
  return photoMIMEType_;
}

- (BOOL)generateContentInputStream:(NSInputStream **)outInputStream
                            length:(unsigned long long *)outLength
                           headers:(NSDictionary **)outHeaders {
  
  if ([[self photoData] length] == 0) {
    // if there's no photo data, just fall back on GDataObject's
    // XML stream generation
    return [super generateContentInputStream:outInputStream
                                      length:outLength
                                     headers:outHeaders];
  }
  
  // make a MIME document with an XML part and a binary part
  NSDictionary* xmlHeader;
  xmlHeader = [NSDictionary dictionaryWithObject:@"application/atom+xml"
                                          forKey:@"Content-Type"];
  NSString *xmlString = [[self XMLElement] XMLString];
  NSData *xmlBody = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
  
  
  NSString *photoContentType = photoMIMEType_ ? photoMIMEType_ : @"image/jpeg";
  NSDictionary *binHeader = [NSDictionary dictionaryWithObject:photoContentType
                                                        forKey:@"Content-Type"];
  NSData *binBody = [self photoData];
  
  GDataMIMEDocument* doc = [GDataMIMEDocument MIMEDocument];
  
  [doc addPartWithHeaders:xmlHeader body:xmlBody];
  
  if ([binBody length] > 0) {
    [doc addPartWithHeaders:binHeader body:binBody];
  }
  
  // generate the input stream, and make a header which includes the
  // boundary used between parts of the mime document
  NSString *partBoundary = nil; // typically this will be END_OF_PART
  
  [doc generateInputStream:outInputStream
                    length:outLength
                  boundary:&partBoundary];

  NSString *streamTypeTemplate = @"multipart/related; boundary=\"%@\"";
  NSString *streamType = [NSString stringWithFormat:streamTypeTemplate,
    partBoundary];

  *outHeaders = [NSDictionary dictionaryWithObjectsAndKeys:
    streamType, @"Content-Type",
    @"1.0", @"MIME-Version", 
    nil];
  
  return YES;
}

#pragma mark -

- (NSString *)albumID {
  GDataPhotoAlbumID *obj = [self objectForExtensionClass:[GDataPhotoAlbumID class]];
  return [obj stringValue];
}

- (void)setAlbumID:(NSString *)str {
  GDataObject *obj = [GDataPhotoAlbumID valueWithString:str];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (NSString *)checksum {
  GDataPhotoChecksum *obj = [self objectForExtensionClass:[GDataPhotoChecksum class]];
  return [obj stringValue];
}

- (void)setChecksum:(NSString *)str {
  GDataObject *obj = [GDataPhotoChecksum valueWithString:str];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (NSString *)client {
  GDataPhotoClient *obj = [self objectForExtensionClass:[GDataPhotoClient class]];
  return [obj stringValue];
}

- (void)setClient:(NSString *)str {
  GDataObject *obj = [GDataPhotoClient valueWithString:str];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (NSNumber *)commentCount {
  // int
  GDataPhotoCommentCount *obj = [self objectForExtensionClass:[GDataPhotoCommentCount class]];
  return [obj intNumberValue];
}

- (void)setCommentCount:(NSNumber *)num {
  GDataObject *obj = [GDataPhotoCommentCount valueWithNumber:num];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (NSNumber *)commentsEnabled {
  // BOOL
  GDataPhotoCommentingEnabled *obj = [self objectForExtensionClass:[GDataPhotoCommentingEnabled class]];
  return [obj boolNumberValue];
}

- (void)setCommentsEnabled:(NSNumber *)num {
  GDataObject *obj = [GDataPhotoCommentingEnabled valueWithBool:[num boolValue]];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (NSNumber *)height {
  // long long
  GDataPhotoHeight *obj = [self objectForExtensionClass:[GDataPhotoHeight class]];
  return [obj longLongNumberValue];
}

- (void)setHeight:(NSNumber *)num {
  GDataObject *obj = [GDataPhotoHeight valueWithNumber:num];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (NSNumber *)position {
  // double
  GDataPhotoPosition *obj = [self objectForExtensionClass:[GDataPhotoPosition class]];
  return [obj doubleNumberValue];
}

- (void)setPosition:(NSNumber *)num {
  GDataObject *obj = [GDataPhotoPosition valueWithNumber:num];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (NSNumber *)rotation {
  // int
  GDataPhotoRotation *obj = [self objectForExtensionClass:[GDataPhotoRotation class]];
  return [obj intNumberValue];
}

- (void)setRotation:(NSNumber *)num {
  GDataObject *obj = [GDataPhotoRotation valueWithNumber:num];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (NSNumber *)size {
  // long long
  GDataPhotoSize *obj = [self objectForExtensionClass:[GDataPhotoSize class]];
  return [obj longLongNumberValue];
}

- (void)setSize:(NSNumber *)num {
  GDataObject *obj = [GDataPhotoSize valueWithNumber:num];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (GDataPhotoTimestamp *)timestamp {
  GDataPhotoTimestamp *obj = [self objectForExtensionClass:[GDataPhotoTimestamp class]];
  return obj ;
}

- (void)setTimestamp:(GDataPhotoTimestamp *)obj {
  [self setObject:obj forExtensionClass:[GDataPhotoTimestamp class]];  
}

- (NSString *)version {
  GDataPhotoVersion *obj = [self objectForExtensionClass:[GDataPhotoVersion class]];
  return [obj stringValue];
}

- (void)setVersion:(NSString *)str {
  GDataObject *obj = [GDataPhotoVersion valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataPhotoVersion class]];  
}

- (NSNumber *)width {
  // long long
  GDataPhotoWidth *obj = [self objectForExtensionClass:[GDataPhotoWidth class]];
  return [obj longLongNumberValue];
}

- (void)setWidth:(NSNumber *)num {
  GDataObject *obj = [GDataPhotoWidth valueWithNumber:num];
  [self setObject:obj forExtensionClass:[obj class]];  
}

- (GDataMediaGroup *)mediaGroup {
  return (GDataMediaGroup *) [self objectForExtensionClass:[GDataMediaGroup class]];
}

- (void)setMediaGroup:(GDataMediaGroup *)obj {
  [self setObject:obj forExtensionClass:[GDataMediaGroup class]];
}

#pragma mark -

- (GDataGeo *)geoLocation {
  return [GDataGeo geoLocationForObject:self];
}

- (void)setGeoLocation:(GDataGeo *)geo {
  [GDataGeo setGeoLocation:geo forObject:self];
}

// EXIF tag support
- (GDataEXIFTags *)EXIFTags {
  return (GDataEXIFTags *) [self objectForExtensionClass:[GDataEXIFTags class]];
}

- (void)setEXIFTags:(GDataEXIFTags *)tags {
  [self setObject:tags forExtensionClass:[GDataEXIFTags class]];   
}

@end
