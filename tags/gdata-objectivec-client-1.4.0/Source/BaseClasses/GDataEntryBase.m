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

@implementation GDataEntryBase

+ (NSDictionary *)baseGDataNamespaces {
  NSDictionary *namespaces = [NSDictionary dictionaryWithObjectsAndKeys:
    kGDataNamespaceAtom, @"",
    kGDataNamespaceAtomPub, kGDataNamespaceAtomPubPrefix,
    kGDataNamespaceGData, kGDataNamespaceGDataPrefix, 
    nil];
  return namespaces;
}

+ (GDataEntryBase *)entry {
  GDataEntryBase *entry = [[[GDataEntryBase alloc] init] autorelease];
  
  [entry setNamespaces:[GDataEntryBase baseGDataNamespaces]];
  return entry;
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];
  
  // deletion marking support
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataDeleted class]];

  // atom publishing control support
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataAtomPubControl class]];  
  
  // batch support
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataBatchOperation class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataBatchID class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataBatchStatus class]];  
  [self addExtensionDeclarationForParentClass:entryClass
                                   childClass:[GDataBatchInterrupted class]];  
}


- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    NSXMLElement *idElement = [self childWithQualifiedName:@"id"
                                              namespaceURI:kGDataNamespaceAtom
                                               fromElement:element];
    NSString *str = [self stringValueFromElement:idElement];
    [self setIdentifier:str];
    
    NSXMLElement *pubElement = [self childWithQualifiedName:@"published"
                                            namespaceURI:kGDataNamespaceAtom
                                             fromElement:element];
    GDataDateTime *dateTime = [self dateTimeFromElement:pubElement];
    [self setPublishedDate:dateTime];
    
    NSXMLElement *updElement = [self childWithQualifiedName:@"updated"
                                               namespaceURI:kGDataNamespaceAtom
                                                fromElement:element];
    dateTime = [self dateTimeFromElement:updElement];
    [self setUpdatedDate:dateTime];
    
    NSXMLElement *editedElement = [self childWithQualifiedName:@"app:edited"
                                                  namespaceURI:kGDataNamespaceAtomPub
                                                   fromElement:element];
    dateTime = [self dateTimeFromElement:editedElement];
    [self setEditedDate:dateTime];
    
    [self setTitle:[self objectForChildOfElement:element
                                   qualifiedName:@"title"
                                    namespaceURI:kGDataNamespaceAtom
                                     objectClass:[GDataTextConstruct class]]];
    
    [self setSummary:[self objectForChildOfElement:element
                                     qualifiedName:@"summary"
                                      namespaceURI:kGDataNamespaceAtom
                                       objectClass:[GDataTextConstruct class]]];
    
    [self setContent:[self objectForChildOfElement:element
                                     qualifiedName:@"content"
                                      namespaceURI:kGDataNamespaceAtom
                                       objectClass:[GDataEntryContent class]]];
    
    [self setRightsString:[self objectForChildOfElement:element
                                          qualifiedName:@"rights"
                                           namespaceURI:kGDataNamespaceAtom
                                            objectClass:[GDataTextConstruct class]]];
    
    [self setLinks:[self objectsForChildrenOfElement:element
                                       qualifiedName:@"link"
                                        namespaceURI:kGDataNamespaceAtom
                                         objectClass:[GDataLink class]]];
    
    [self setAuthors:[self objectsForChildrenOfElement:element
                                         qualifiedName:@"author"
                                          namespaceURI:kGDataNamespaceAtom
                                           objectClass:[GDataPerson class]]];
    
    [self setCategories:[self objectsForChildrenOfElement:element
                                            qualifiedName:@"category"
                                             namespaceURI:kGDataNamespaceAtom
                                              objectClass:[GDataCategory class]]];
  }
  return self;
}

- (void)dealloc {
  [idString_ release];
  [versionIDString_ release];
  
  [publishedDate_ release];
  [updatedDate_ release];
  [editedDate_ release];
  
  [title_ release];
  [summary_ release];
  [content_ release];
  [rightsString_ release];
  
  [links_ release];
  [authors_ release];
  [categories_ release];
  
  [uploadData_ release];
  [uploadMIMEType_ release];
  [uploadSlug_ release];
  
  [super dealloc];
}

- (BOOL)isEqual:(GDataEntryBase *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataEntryBase class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self identifier], [other identifier])
    && AreEqualOrBothNil([self versionIDString], [other versionIDString])
    && AreEqualOrBothNil([self publishedDate], [other publishedDate])
    && AreEqualOrBothNil([self updatedDate], [other updatedDate])
    && AreEqualOrBothNil([self editedDate], [other editedDate])
    && AreEqualOrBothNil([self title], [other title])
    && AreEqualOrBothNil([self summary], [other summary])
    && AreEqualOrBothNil([self content], [other content])
    && AreEqualOrBothNil([self rightsString], [other rightsString])
    && AreEqualOrBothNil([self authors], [other authors])
    && AreEqualOrBothNil([self categories], [other categories])
    && AreEqualOrBothNil([self uploadData], [other uploadData])
    && AreEqualOrBothNil([self uploadMIMEType], [other uploadMIMEType])
    && AreEqualOrBothNil([self uploadSlug], [other uploadSlug]);
}

- (id)copyWithZone:(NSZone *)zone {
  GDataEntryBase* newEntry = [super copyWithZone:zone];
    
  [newEntry setCanEdit:[self canEdit]];
  [newEntry setIdentifier:[self identifier]];
  [newEntry setVersionIDString:[self versionIDString]];
  [newEntry setPublishedDate:[self publishedDate]];
  [newEntry setUpdatedDate:[self updatedDate]];
  [newEntry setEditedDate:[self editedDate]];
  [newEntry setTitle:[self title]];
  [newEntry setSummary:[self summary]];
  [newEntry setContent:[self content]];
  [newEntry setRightsString:[self rightsString]];
  [newEntry setLinks:[GDataUtilities arrayWithCopiesOfObjectsInArray:[self links]]];
  [newEntry setAuthors:[GDataUtilities arrayWithCopiesOfObjectsInArray:[self authors]]];
  [newEntry setCategories:[GDataUtilities arrayWithCopiesOfObjectsInArray:[self categories]]];
  [newEntry setUploadData:[self uploadData]];
  [newEntry setUploadMIMEType:[self uploadMIMEType]];
  [newEntry setUploadSlug:[self uploadSlug]];
  
  return newEntry;
}

- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:[title_ stringValue] withName:@"title"];
  [self addToArray:items objectDescriptionIfNonNil:[summary_ stringValue] withName:@"summary"];
  [self addToArray:items objectDescriptionIfNonNil:[content_ stringValue] withName:@"content"];

  [self addToArray:items arrayCountIfNonEmpty:authors_ withName:@"authors"];
  [self addToArray:items arrayCountIfNonEmpty:categories_ withName:@"categories"];
  
  if ([links_ count]) {
    NSArray *linkNames = [GDataLink linkNamesFromLinks:links_];
    NSString *linksStr = [linkNames componentsJoinedByString:@","];
    [self addToArray:items objectDescriptionIfNonNil:linksStr withName:@"links"];
  }

  [self addToArray:items objectDescriptionIfNonNil:[editedDate_ RFC3339String] withName:@"edited"];

  [self addToArray:items objectDescriptionIfNonNil:idString_ withName:@"id"];
  
  [self addToArray:items objectDescriptionIfNonNil:[self atomPubControl] withName:@"app:control"];

  [self addToArray:items objectDescriptionIfNonNil:uploadMIMEType_ withName:@"MIMEType"];
  [self addToArray:items objectDescriptionIfNonNil:uploadSlug_ withName:@"slug"];
  if (uploadData_) {
    NSString *str = [NSString stringWithFormat:@"%u_bytes", [uploadData_ length]];
    [self addToArray:items objectDescriptionIfNonNil:str withName:@"UploadData"];
  }
  
  if ([self isDeleted]) {
    [self addToArray:items objectDescriptionIfNonNil:@"YES" withName:@"deleted"]; 
  }

  return items;
}

- (NSXMLElement *)XMLElement {
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"entry"];

  if ([[self identifier] length]) {
    [element addChild:[NSXMLElement elementWithName:@"id"
                                        stringValue:[self identifier]]];
  }  
  if ([self title]) {
    [element addChild:[[self title] XMLElement]];
  }
  if ([self summary]) {
    [element addChild:[[self summary] XMLElement]];
  }
  if ([self content]) {
    [element addChild:[[self content] XMLElement]];
  }
  if ([self rightsString]) {
    [element addChild:[[self rightsString] XMLElement]];
  }
  if ([self publishedDate]) {
    [element addChild:[NSXMLNode elementWithName:@"published"
                                     stringValue:[[self publishedDate] RFC3339String]]];
  }
  if ([self updatedDate]) {
    [element addChild:[NSXMLNode elementWithName:@"updated"
                                     stringValue:[[self updatedDate] RFC3339String]]];
  }
  if ([self editedDate]) {
    NSXMLElement *editedElement = [NSXMLNode elementWithName:@"edited" 
                                                         URI:kGDataNamespaceAtomPub];
    [editedElement addStringValue:[[self editedDate] RFC3339String]];

    [element addChild:editedElement];
  }
  [self addToElement:element XMLElementsForArray:[self links]];
  [self addToElement:element XMLElementsForArray:[self authors]];
  [self addToElement:element XMLElementsForArray:[self categories]];
  
  return element;
}

#pragma mark -

- (BOOL)generateContentInputStream:(NSInputStream **)outInputStream
                            length:(unsigned long long *)outLength
                           headers:(NSDictionary **)outHeaders {
  
  // check if a subclass is providing data
  NSData *uploadData = [self uploadData];
  NSString *uploadMIMEType = [self uploadMIMEType];
  
  if ([uploadData length] == 0 || [uploadMIMEType length] == 0) {
    // if there's no upload data, just fall back on GDataObject's
    // XML stream generation
    return [super generateContentInputStream:outInputStream
                                      length:outLength
                                     headers:outHeaders];
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
  NSString *slug = [self uploadSlug];
  
  *outHeaders = [NSDictionary dictionaryWithObjectsAndKeys:
    streamType, @"Content-Type",
    @"1.0", @"MIME-Version", 
    slug, @"Slug", // slug may be nil
    nil];
  
  return YES;
}

#pragma mark -

- (BOOL)canEdit {
  return canEdit_;
}

- (void)setCanEdit:(BOOL)flag {
  canEdit_ = flag;
}

- (NSString *)identifier {
  return idString_; 
}
- (void)setIdentifier:(NSString *)theIdString {
  [idString_ autorelease];
  idString_ = [theIdString copy];
}

- (NSString *)versionIDString {
  return versionIDString_; 
}

- (void)setVersionIDString:(NSString *)theVersionIDString {
  [versionIDString_ autorelease];
  versionIDString_ = [theVersionIDString copy];
}

- (GDataDateTime *)publishedDate {
  return publishedDate_; 
}

- (void)setPublishedDate:(GDataDateTime *)thePublishedDate {
  [publishedDate_ autorelease];
  publishedDate_ = [thePublishedDate copy];
}

- (GDataDateTime *)updatedDate {
  return updatedDate_; 
}

- (void)setUpdatedDate:(GDataDateTime *)theUpdatedDate {
  [updatedDate_ autorelease];
  updatedDate_ = [theUpdatedDate copy];
}

- (GDataDateTime *)editedDate {
  return editedDate_; 
}

- (void)setEditedDate:(GDataDateTime *)theEditedDate {
  [editedDate_ autorelease];
  editedDate_ = [theEditedDate copy];
}

- (GDataTextConstruct *)title {
  return title_; 
}

- (void)setTitle:(GDataTextConstruct *)theTitle {
  [title_ autorelease];
  title_ = [theTitle copy];

  [title_ setElementName:@"title"];
}

- (void)setTitleWithString:(NSString *)str {
  [self setTitle:[GDataTextConstruct textConstructWithString:str]]; 
}

- (GDataTextConstruct *)summary {
  return summary_; 
}

- (void)setSummary:(GDataTextConstruct *)theSummary {
  [summary_ autorelease];
  summary_ = [theSummary copy];

  [summary_ setElementName:@"summary"];
}

- (void)setSummaryWithString:(NSString *)str {
  [self setSummary:[GDataTextConstruct textConstructWithString:str]];  
}

- (GDataEntryContent *)content {
  return content_; 
}

- (void)setContent:(GDataEntryContent *)theContent {
  [content_ autorelease];
  content_ = [theContent copy];

  [content_ setElementName:@"content"];
}

- (void)setContentWithString:(NSString *)str {
  [self setContent:[GDataEntryContent textConstructWithString:str]];  
}

- (GDataTextConstruct *)rightsString {
  return rightsString_; 
}

- (void)setRightsString:(GDataTextConstruct *)theRightsString {
  [rightsString_ autorelease];
  rightsString_ = [theRightsString copy];
  
  [rightsString_ setElementName:@"rights"];
}

- (void)setRightsStringWithString:(NSString *)str {
  [self setRightsString:[GDataTextConstruct textConstructWithString:str]]; 
}

- (NSArray *)links {
  return links_;
}

- (void)setLinks:(NSArray *)links {
  [links_ autorelease];
  links_ = [links mutableCopy];
}

- (void)addLink:(GDataLink *)link {
  if (!links_) {
    links_ = [[NSMutableArray alloc] init];
  }
  [links_ addObject:link]; 
}

- (NSArray *)authors {
  return authors_;
}

- (void)setAuthors:(NSArray *)authors {
  [authors_ autorelease];
  authors_ = [authors mutableCopy];
  
  [authors_ makeObjectsPerformSelector:@selector(setElementName:)
                            withObject:@"author"];
}

- (void)addAuthor:(GDataPerson *)authorElement {
  [authorElement setElementName:@"author"];
  if (!authors_) {
    authors_ = [[NSMutableArray alloc] init]; 
  }
  [authors_ addObject:authorElement]; 
}

- (NSArray *)categories {
  return categories_;
}

- (void)setCategories:(NSArray *)categories {
  [categories_ autorelease];
  categories_ = [categories mutableCopy];
}

- (void)addCategory:(GDataCategory *)obj {
  if (!categories_) {
    categories_ = [[NSMutableArray alloc] init]; 
  }
  
  if (![categories_ containsObject:obj]) {
    [categories_ addObject:obj];
  }
}

- (void)removeCategory:(GDataCategory *)category {
  [categories_ removeObject:category];
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
  uploadSlug_ = [str copy];
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
  return (GDataAtomPubControl *) [self objectForExtensionClass:[GDataAtomPubControl class]];
}

- (void)setAtomPubControl:(GDataAtomPubControl *)obj {
  [self setObject:obj forExtensionClass:[GDataAtomPubControl class]];
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

@end



