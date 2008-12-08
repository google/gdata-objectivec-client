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
// GDataEntryBase.m
//

#define GDATAENTRYBASE_DEFINE_GLOBALS 1

#import "GDataEntryBase.h"
#import "GDataMIMEDocument.h"
#import "GDataBaseElements.h"

@implementation GDataEntryBase

+ (NSDictionary *)baseGDataNamespaces {
  NSDictionary *namespaces = [NSDictionary dictionaryWithObjectsAndKeys:
    kGDataNamespaceAtom, @"",
    kGDataNamespaceGData, kGDataNamespaceGDataPrefix, 
    kGDataNamespaceAtomPubStd, kGDataNamespaceAtomPubPrefix, 
    nil];
  return namespaces;
}

+ (GDataEntryBase *)entry {
  GDataEntryBase *entry = [[[GDataEntryBase alloc] init] autorelease];
  
  [entry setNamespaces:[GDataEntryBase baseGDataNamespaces]];
  return entry;
}

- (Class)atomPubEditedObjectClass {
  // version 1 of GData used a preliminary namespace URI
  if ([self isServiceVersion1]) {
    return [GDataAtomPubEditedDate1_0 class];
  } else {
    return [GDataAtomPubEditedDateStd class];
  }
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];
  
  [self addExtensionDeclarationForParentClass:entryClass
                                 childClasses:
   // Atom extensions
   [GDataAtomID class], 
   [GDataAtomPublishedDate class],
   [GDataAtomUpdatedDate class], 
   [GDataAtomTitle class], 
   [GDataAtomSummary class],
   [GDataAtomContent class], 
   [GDataAtomRights class],
   [GDataLink class],
   [GDataAtomAuthor class],
   [GDataCategory class],
   
   // deletion marking support
   [GDataDeleted class],
   
   // atom publishing control support
   [GDataAtomPubControl atomPubControlClassForObject:self],
   [self atomPubEditedObjectClass],
   
   // batch support
   [GDataBatchOperation class], [GDataBatchID class],
   [GDataBatchStatus class], [GDataBatchInterrupted class],
   nil];

  [self addAttributeExtensionDeclarationForParentClass:entryClass
                                            childClass:[GDataETagAttribute class]];
}

- (void)dealloc {
  [uploadData_ release];
  [uploadMIMEType_ release];
  [uploadSlug_ release];
  
  [super dealloc];
}

- (BOOL)isEqual:(GDataEntryBase *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataEntryBase class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self uploadData], [other uploadData])
    && AreEqualOrBothNil([self uploadMIMEType], [other uploadMIMEType])
    && AreEqualOrBothNil([self uploadSlug], [other uploadSlug])
    && AreBoolsEqual([self shouldUploadDataOnly], [other shouldUploadDataOnly]);
}

- (id)copyWithZone:(NSZone *)zone {
  GDataEntryBase* newEntry = [super copyWithZone:zone];
    
  [newEntry setUploadData:[self uploadData]];
  [newEntry setUploadMIMEType:[self uploadMIMEType]];
  [newEntry setUploadSlug:[self uploadSlug]];
  [newEntry setShouldUploadDataOnly:[self shouldUploadDataOnly]];
  
  return newEntry;
}

- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:[self serviceVersion] withName:@"v"];
  
  [self addToArray:items objectDescriptionIfNonNil:[[self title] stringValue] withName:@"title"];
  [self addToArray:items objectDescriptionIfNonNil:[[self summary] stringValue] withName:@"summary"];
  [self addToArray:items objectDescriptionIfNonNil:[[self content] stringValue] withName:@"content"];

  [self addToArray:items objectDescriptionIfNonNil:[self ETag] withName:@"etag"];

  [self addToArray:items arrayCountIfNonEmpty:[self authors] withName:@"authors"];
  [self addToArray:items arrayCountIfNonEmpty:[self categories] withName:@"categories"];
  
  if ([[self links] count]) {
    NSArray *linkNames = [GDataLink linkNamesFromLinks:[self links]];
    NSString *linksStr = [linkNames componentsJoinedByString:@","];
    [self addToArray:items objectDescriptionIfNonNil:linksStr withName:@"links"];
  }

  [self addToArray:items objectDescriptionIfNonNil:[[self editedDate] RFC3339String] withName:@"edited"];

  [self addToArray:items objectDescriptionIfNonNil:[self identifier] withName:@"id"];
  
  [self addToArray:items objectDescriptionIfNonNil:[self atomPubControl] withName:@"app:control"];

  [self addToArray:items objectDescriptionIfNonNil:[[self batchOperation] type] withName:@"batchOp"];
  [self addToArray:items objectDescriptionIfNonNil:[[self batchID] stringValue] withName:@"batchID"];
  [self addToArray:items objectDescriptionIfNonNil:[[self batchStatus] code] withName:@"batchStatus"];
  [self addToArray:items objectDescriptionIfNonNil:[self batchInterrupted] withName:@"batchInterrupted"];

  [self addToArray:items objectDescriptionIfNonNil:[self uploadMIMEType] withName:@"MIMEType"];
  [self addToArray:items objectDescriptionIfNonNil:[self uploadSlug] withName:@"slug"];
  if ([self shouldUploadDataOnly]) {
    [self addToArray:items objectDescriptionIfNonNil:@"YES" withName:@"uploadDataOnly"];
  }
  if ([self uploadData]) {
    NSString *str = [NSString stringWithFormat:@"%u_bytes", [[self uploadData] length]];
    [self addToArray:items objectDescriptionIfNonNil:str withName:@"UploadData"];
  }
  
  if ([self isDeleted]) {
    [self addToArray:items objectDescriptionIfNonNil:@"YES" withName:@"deleted"]; 
  }

  return items;
}

#pragma mark -

- (BOOL)generateContentInputStream:(NSInputStream **)outInputStream
                            length:(unsigned long long *)outLength
                           headers:(NSDictionary **)outHeaders {
  
  // check if a subclass is providing data
  NSData *uploadData = [self uploadData];
  NSString *uploadMIMEType = [self uploadMIMEType];
  NSString *slug = [self uploadSlug];
  
  if ([uploadData length] == 0 || [uploadMIMEType length] == 0) {
    
#if DEBUG
    NSAssert(![self shouldUploadDataOnly], @"missing data");
#endif
    
    // if there's no upload data, just fall back on GDataObject's
    // XML stream generation
    return [super generateContentInputStream:outInputStream
                                      length:outLength
                                     headers:outHeaders];
  }
  
  if ([self shouldUploadDataOnly]) {
    // we're not uploading the XML, so we don't need a multipart MIME document
    *outInputStream = [NSInputStream inputStreamWithData:uploadData];
    *outLength = [uploadData length];
    *outHeaders = [NSDictionary dictionaryWithObjectsAndKeys:
                   uploadMIMEType, @"Content-Type",
                   @"1.0", @"MIME-Version",
                   slug, @"Slug", // slug may be nil
                   nil];
    return YES;
  }
  
  // make a MIME document with an XML part and a binary part
  NSDictionary* xmlHeader = [NSDictionary dictionaryWithObjectsAndKeys:
    @"application/atom+xml; charset=UTF-8", @"Content-Type", nil];
  
  NSString *xmlString = [[self XMLElement] XMLString];
  NSData *xmlBody = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
  
  NSDictionary *binHeader = [NSDictionary dictionaryWithObjectsAndKeys:
    uploadMIMEType, @"Content-Type",
    @"binary", @"Content-Transfer-Encoding", nil];
  
  GDataMIMEDocument* doc = [GDataMIMEDocument MIMEDocument];
  
  [doc addPartWithHeaders:xmlHeader body:xmlBody];
  [doc addPartWithHeaders:binHeader body:uploadData];
  
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
    slug, @"Slug", // slug may be nil
    nil];
  
  return YES;
}

#pragma mark -

- (NSString *)ETag {
  NSString *str = [self attributeValueForExtensionClass:[GDataETagAttribute class]];
  return str;
}

- (void)setETag:(NSString *)str {
  [self setAttributeValue:str forExtensionClass:[GDataETagAttribute class]];
}

- (NSString *)identifier {
  GDataAtomID *obj = [self objectForExtensionClass:[GDataAtomID class]];
  return [obj stringValue];
}

- (void)setIdentifier:(NSString *)str {
  GDataAtomID *obj = [GDataAtomID valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataAtomID class]];
}

- (GDataDateTime *)publishedDate {
  GDataAtomPublishedDate *obj;
  
  obj = [self objectForExtensionClass:[GDataAtomPublishedDate class]];
  return [obj dateTimeValue];
}

- (void)setPublishedDate:(GDataDateTime *)dateTime {
  GDataAtomPublishedDate *obj;
  
  obj = [GDataAtomPublishedDate valueWithDateTime:dateTime];
  [self setObject:obj forExtensionClass:[GDataAtomPublishedDate class]];
}

- (GDataDateTime *)updatedDate {
  GDataAtomUpdatedDate *obj;
  
  obj = [self objectForExtensionClass:[GDataAtomUpdatedDate class]];
  return [obj dateTimeValue];
}

- (void)setUpdatedDate:(GDataDateTime *)dateTime {
  GDataAtomUpdatedDate *obj;
  
  obj = [GDataAtomUpdatedDate valueWithDateTime:dateTime];
  [self setObject:obj forExtensionClass:[GDataAtomUpdatedDate class]];
}

- (GDataDateTime *)editedDate {
  GDataValueElementConstruct *obj;

  obj = [self objectForExtensionClass:[self atomPubEditedObjectClass]];
  return [obj dateTimeValue];
}

- (void)setEditedDate:(GDataDateTime *)dateTime {
  Class class = [self atomPubEditedObjectClass];

  GDataValueElementConstruct *obj = [class valueWithDateTime:dateTime];
  [self setObject:obj forExtensionClass:[self atomPubEditedObjectClass]];
}

- (GDataTextConstruct *)title {
  GDataAtomTitle *obj = [self objectForExtensionClass:[GDataAtomTitle class]];
  return obj;
}

- (void)setTitle:(GDataTextConstruct *)obj {
  [self setObject:obj forExtensionClass:[GDataAtomTitle class]];
}

- (void)setTitleWithString:(NSString *)str {
  GDataAtomTitle *obj = [GDataAtomTitle textConstructWithString:str];
  [self setObject:obj forExtensionClass:[GDataAtomTitle class]];
}

- (GDataTextConstruct *)summary {
  GDataAtomSummary *obj = [self objectForExtensionClass:[GDataAtomSummary class]];
  return obj;
}

- (void)setSummary:(GDataTextConstruct *)obj {
  [self setObject:obj forExtensionClass:[GDataAtomSummary class]];
}

- (void)setSummaryWithString:(NSString *)str {
  GDataAtomSummary *obj = [GDataAtomSummary textConstructWithString:str];
  [self setObject:obj forExtensionClass:[GDataAtomSummary class]];
}

- (GDataEntryContent *)content {
  GDataAtomContent *obj;
  
  obj = [self objectForExtensionClass:[GDataAtomContent class]];
  return obj;
}

- (void)setContent:(GDataEntryContent *)obj {
  [self setObject:obj forExtensionClass:[GDataAtomContent class]];
}

- (void)setContentWithString:(NSString *)str {
  GDataAtomContent *obj = [GDataAtomContent contentWithString:str];
  [self setObject:obj forExtensionClass:[GDataAtomContent class]];
}

- (GDataTextConstruct *)rightsString {
  GDataTextConstruct *obj;
  
  obj = [self objectForExtensionClass:[GDataAtomRights class]];
  return obj;
}

- (void)setRightsString:(GDataTextConstruct *)obj {
  [self setObject:obj forExtensionClass:[GDataAtomRights class]];
}

- (void)setRightsStringWithString:(NSString *)str {
  GDataAtomRights *obj;
  
  obj = [GDataAtomRights textConstructWithString:str];
  [self setObject:obj forExtensionClass:[GDataAtomRights class]];
}

- (NSArray *)links {
  NSArray *array = [self objectsForExtensionClass:[GDataLink class]];
  return array;
}

- (void)setLinks:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataLink class]];
}

- (void)addLink:(GDataLink *)obj {
  [self addObject:obj forExtensionClass:[GDataLink class]];
}

- (NSArray *)authors {
  NSArray *array = [self objectsForExtensionClass:[GDataAtomAuthor class]];
  return array;
}

- (void)setAuthors:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataAtomAuthor class]];
}

- (void)addAuthor:(GDataPerson *)obj {
  [self addObject:obj forExtensionClass:[GDataAtomAuthor class]];
}

- (NSArray *)categories {
  NSArray *array = [self objectsForExtensionClass:[GDataCategory class]];
  return array;
}

- (void)setCategories:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataCategory class]];
}

- (void)addCategory:(GDataCategory *)obj {
  [self addObject:obj forExtensionClass:[GDataCategory class]];
}

- (void)removeCategory:(GDataCategory *)obj {
  [self removeObject:obj forExtensionClass:[GDataCategory class]];
}

// Multipart MIME Uploading

- (NSData *)uploadData {
  return uploadData_;
}

- (void)setUploadData:(NSData *)data {
  [uploadData_ autorelease];
  uploadData_ = [data retain];
}

- (NSString *)uploadMIMEType {
  return uploadMIMEType_;
}

- (void)setUploadMIMEType:(NSString *)str {
  [uploadMIMEType_ autorelease];
  uploadMIMEType_ = [str copy];
}

- (NSString *)uploadSlug {
  return uploadSlug_;
}

- (void)setUploadSlug:(NSString *)str {
  [uploadSlug_ autorelease];
  
  // encode per http://bitworking.org/projects/atom/rfc5023.html#rfc.section.9.7
  NSString *encoded = [GDataUtilities stringByPercentEncodingUTF8ForString:str];
  uploadSlug_ = [encoded copy];
}

- (BOOL)shouldUploadDataOnly {
  return shouldUploadDataOnly_;
}

- (void)setShouldUploadDataOnly:(BOOL)flag {
  shouldUploadDataOnly_ = flag;
}

// utility routine to convert a file path to the file's MIME type using
// Mac OS X's UTI database
+ (NSString *)MIMETypeForFileAtPath:(NSString *)path
                    defaultMIMEType:(NSString *)defaultType {

#ifndef GDATA_FOUNDATION_ONLY
  
  NSString *result = defaultType;
  
  // convert the path to an FSRef
  FSRef fileFSRef;
  Boolean isDirectory;
  OSStatus err = FSPathMakeRef((UInt8 *) [path fileSystemRepresentation], 
                               &fileFSRef, &isDirectory);
  if (err == noErr) {
    
    // get the UTI (content type) for the FSRef    
    CFStringRef fileUTI;
    err = LSCopyItemAttribute(&fileFSRef, kLSRolesAll, kLSItemContentType, 
                              (CFTypeRef *)&fileUTI);
    if (err == noErr) {
      
      // get the MIME type for the UTI
      CFStringRef mimeTypeTag;
      mimeTypeTag = UTTypeCopyPreferredTagWithClass(fileUTI, 
                                                    kUTTagClassMIMEType);
      if (mimeTypeTag) {
        
        // convert the CFStringRef to an autoreleased NSString (ObjC 2.0-safe)
        result = [NSString stringWithString:(NSString *)mimeTypeTag]; 
        CFRelease(mimeTypeTag);
      }
      CFRelease(fileUTI);
    }
  }
  return result;
  
#else // !GDATA_FOUNDATION_ONLY
  
  return defaultType;
  
#endif
}

// extension for deletion marking
- (BOOL)isDeleted {
  GDataDeleted *deleted = [self objectForExtensionClass:[GDataDeleted class]];
  return (deleted != nil);
}

- (void)setIsDeleted:(BOOL)isDeleted {
  if (isDeleted) {
    // set the extension
    [self setObject:[GDataDeleted deleted] forExtensionClass:[GDataDeleted class]]; 
  } else {
    // remove the extension
    [self setObject:nil forExtensionClass:[GDataDeleted class]]; 
  }
}

// extensions for Atom publishing control

- (GDataAtomPubControl *)atomPubControl {
  Class class = [GDataAtomPubControl atomPubControlClassForObject:self];

  return [self objectForExtensionClass:class];
}

- (void)setAtomPubControl:(GDataAtomPubControl *)obj {
  Class class = [GDataAtomPubControl atomPubControlClassForObject:self];

  [self setObject:obj forExtensionClass:class];
}

// extensions for batch support

- (GDataBatchOperation *)batchOperation {
  return (GDataBatchOperation *) [self objectForExtensionClass:[GDataBatchOperation class]];
}

- (void)setBatchOperation:(GDataBatchOperation *)obj {
  [self setObject:obj forExtensionClass:[GDataBatchOperation class]];
}

- (GDataBatchID *)batchID {
  return (GDataBatchID *) [self objectForExtensionClass:[GDataBatchID class]];
}

- (void)setBatchID:(GDataBatchID *)obj {
  [self setObject:obj forExtensionClass:[GDataBatchID class]];
}

- (void)setBatchIDWithString:(NSString *)str {
  GDataBatchID *obj = [GDataBatchID batchIDWithString:str];
  [self setBatchID:obj];
}

- (GDataBatchStatus *)batchStatus {
  return (GDataBatchStatus *) [self objectForExtensionClass:[GDataBatchStatus class]];
}

- (void)setBatchStatus:(GDataBatchStatus *)obj {
  [self setObject:obj forExtensionClass:[GDataBatchStatus class]];
}

- (GDataBatchInterrupted *)batchInterrupted {
  return (GDataBatchInterrupted *) [self objectForExtensionClass:[GDataBatchInterrupted class]];
}

- (void)setBatchInterrupted:(GDataBatchInterrupted *)obj {
  [self setObject:obj forExtensionClass:[GDataBatchInterrupted class]];
}

+ (NSDictionary *)batchNamespaces {
  NSDictionary *namespaces = [NSDictionary dictionaryWithObjectsAndKeys:
    kGDataNamespaceBatch, kGDataNamespaceBatchPrefix, nil];
  return namespaces;
}

#pragma mark -

- (NSArray *)categoriesWithScheme:(NSString *)scheme {
  NSArray *array = [GDataCategory categoriesWithScheme:scheme
                                        fromCategories:[self categories]];
  return array;
}

- (GDataCategory *)kindCategory {
  GDataCategory *cat = [GDataUtilities firstObjectFromArray:[self categories]
                                                  withValue:kGDataCategoryScheme
                                                 forKeyPath:@"scheme"];
  return cat;
}

- (NSArray *)linksWithRelAttributeValue:(NSString *)relValue {

  NSArray *array = [GDataUtilities objectsFromArray:[self links]
                                          withValue:relValue
                                         forKeyPath:@"rel"];
  return array;
}

- (GDataLink *)linkWithRelAttributeValue:(NSString *)rel {

  return [GDataLink linkWithRelAttributeValue:rel
                                    fromLinks:[self links]];
}

- (GDataLink *)feedLink {
  return [self linkWithRelAttributeValue:kGDataLinkRelFeed]; 
}

- (GDataLink *)editLink {
  return [self linkWithRelAttributeValue:@"edit"]; 
}

- (GDataLink *)editMediaLink {
  return [self linkWithRelAttributeValue:@"edit-media"]; 
}

- (GDataLink *)alternateLink {
  return [self linkWithRelAttributeValue:@"alternate"]; 
}

- (GDataLink *)relatedLink {
  return [self linkWithRelAttributeValue:@"related"]; 
}

- (GDataLink *)postLink {
  return [GDataLink linkWithRelAttributeValue:kGDataLinkRelPost
                                    fromLinks:[self links]]; 
}

- (GDataLink *)selfLink {
  return [self linkWithRelAttributeValue:@"self"]; 
}

- (GDataLink *)HTMLLink {
  return [GDataLink linkWithRel:@"alternate"
                           type:@"text/html"
                      fromLinks:[self links]]; 
}

- (BOOL)canEdit {
  return ([self editLink] != nil);  
}
@end
