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
// GDataEntryBase.h
//
// This is the base class for all standard GData feed entries.
//

#import "GDataDateTime.h"
#import "GDataTextConstruct.h"
#import "GDataEntryContent.h"
#import "GDataPerson.h"
#import "GDataCategory.h"
#import "GDataDeleted.h"
#import "GDataBatchOperation.h"
#import "GDataBatchID.h"
#import "GDataBatchStatus.h"
#import "GDataBatchInterrupted.h"
#import "GDataAtomPubControl.h"
#import "GDataDateTime.h"
#import "GDataLink.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAENTRYBASE_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* kGDataCategoryScheme _INITIALIZE_AS(@"http://schemas.google.com/g/2005#kind");

@interface GDataEntryBase : GDataObject <NSCopying> {

  BOOL canEdit_;
  NSString *idString_;
  NSString *versionIDString_;
  NSString *etag_;
  
  GDataDateTime *publishedDate_;
  GDataDateTime *updatedDate_;
  GDataDateTime *editedDate_;
  
  GDataTextConstruct *title_;
  GDataTextConstruct *summary_;
  GDataEntryContent *content_;
  GDataTextConstruct *rightsString_;
  
  NSMutableArray *links_; // GDataLink objects
  NSMutableArray *authors_; // GDataPerson objects
  NSMutableArray *categories_; // GDataCategory objects

  NSData *uploadData_;
  NSString *uploadMIMEType_;
  NSString *uploadSlug_; // for http slug (filename) header when uploading
}

+ (NSDictionary *)baseGDataNamespaces;

+ (GDataEntryBase *)entry;

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent;

- (NSMutableArray *)itemsForDescription; // subclasses may implement this

// basic entry fields
- (BOOL)canEdit;
- (void)setCanEdit:(BOOL)flag;

- (NSString *)identifier;
- (void)setIdentifier:(NSString *)theIdString;

- (NSString *)versionIDString;
- (void)setVersionIDString:(NSString *)theVersionIDString;

- (GDataDateTime *)publishedDate;
- (void)setPublishedDate:(GDataDateTime *)thePublishedDate;

- (GDataDateTime *)updatedDate;
- (void)setUpdatedDate:(GDataDateTime *)theUpdatedDate;

- (GDataDateTime *)editedDate;
- (void)setEditedDate:(GDataDateTime *)theEditedDate;

- (NSString *)ETag;
- (void)setETag:(NSString *)str;

- (GDataTextConstruct *)title;
- (void)setTitle:(GDataTextConstruct *)theTitle;
- (void)setTitleWithString:(NSString *)str;

- (GDataTextConstruct *)summary;
- (void)setSummary:(GDataTextConstruct *)theSummary;
- (void)setSummaryWithString:(NSString *)str;

- (GDataEntryContent *)content;
- (void)setContent:(GDataEntryContent *)theContent;
- (void)setContentWithString:(NSString *)str;

- (GDataTextConstruct *)rightsString;
- (void)setRightsString:(GDataTextConstruct *)theRightsString;
- (void)setRightsStringWithString:(NSString *)str;

- (NSArray *)links;
- (void)setLinks:(NSArray *)links;
- (void)addLink:(GDataLink *)link;

- (NSArray *)authors;
- (void)setAuthors:(NSArray *)authors;
- (void)addAuthor:(GDataPerson *)authorElement;

- (NSArray *)categories;
- (void)setCategories:(NSArray *)categories;
- (void)addCategory:(GDataCategory *)category;
- (void)removeCategory:(GDataCategory *)category;

// Multipart MIME Upload
- (NSData *)uploadData;
- (void)setUploadData:(NSData *)data;

- (NSString *)uploadMIMEType;
- (void)setUploadMIMEType:(NSString *)str;

- (NSString *)uploadSlug; // for http slug (filename) header when uploading
- (void)setUploadSlug:(NSString *)str;

+ (NSString *)MIMETypeForFileAtPath:(NSString *)path
                    defaultMIMEType:(NSString *)defaultType;

// extension for entries which may include deleted elements
- (BOOL)isDeleted;
- (void)setIsDeleted:(BOOL)isDeleted;

// extensions for Atom publishing control
- (GDataAtomPubControl *)atomPubControl;
- (void)setAtomPubControl:(GDataAtomPubControl *)obj;

// batch support
+ (NSDictionary *)batchNamespaces;

- (GDataBatchOperation *)batchOperation;
- (void)setBatchOperation:(GDataBatchOperation *)obj;
  
// the batch ID is an arbitrary string defined by clients, and present in the
// batch response feed to let the client match each entry's response to
// the entry
- (GDataBatchID *)batchID;
- (void)setBatchID:(GDataBatchID *)obj; 
- (void)setBatchIDWithString:(NSString *)str;

- (GDataBatchStatus *)batchStatus;
- (void)setBatchStatus:(GDataBatchStatus *)obj;

- (GDataBatchInterrupted *)batchInterrupted;
- (void)setBatchInterrupted:(GDataBatchInterrupted *)obj;

@end

