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

#import <Cocoa/Cocoa.h>

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

#import "GDataDateTime.h"
#import "GDataTextConstruct.h"
#import "GDataPerson.h"
#import "GDataCategory.h"
#import "GDataBatchOperation.h"
#import "GDataBatchID.h"
#import "GDataBatchStatus.h"
#import "GDataBatchInterrupted.h"
#import "GDataAtomPubControl.h"


@interface GDataEntryBase : GDataObject <NSCopying> {

  BOOL canEdit_;
  NSString *idString_;
  NSString *versionIDString_;
  GDataDateTime *publishedDate_;
  GDataDateTime *updatedDate_;
  GDataTextConstruct *title_;
  GDataTextConstruct *summary_;
  GDataTextConstruct *content_;
  GDataTextConstruct *rightsString_;
  NSMutableArray *links_; // GDataLink objects
  NSMutableArray *authors_; // GDataPerson objects
  NSMutableArray *categories_; // GDataCategory objects
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

- (GDataTextConstruct *)title;
- (void)setTitle:(GDataTextConstruct *)theTitle;

- (GDataTextConstruct *)summary;
- (void)setSummary:(GDataTextConstruct *)theSummary;

- (GDataTextConstruct *)content;
- (void)setContent:(GDataTextConstruct *)theContent;

- (GDataTextConstruct *)rightsString;
- (void)setRightsString:(GDataTextConstruct *)theRightsString;

- (NSArray *)links;
- (void)setLinks:(NSArray *)links;
- (void)addLink:(GDataLink *)link;

- (NSArray *)authors;
- (void)setAuthors:(NSArray *)authors;
- (void)addAuthor:(GDataPerson *)authorElement;

- (NSArray *)categories;
- (void)setCategories:(NSArray *)categories;
- (void)addCategory:(GDataCategory *)category;

// extensions for Atom publishing control
- (GDataAtomPubControl *)atomPubControl;
- (void)setAtomPubControl:(GDataAtomPubControl *)obj;

// Batch support

+ (NSDictionary *)batchNamespaces;

- (GDataBatchOperation *)batchOperation;
- (void)setBatchOperation:(GDataBatchOperation *)obj;
  
- (GDataBatchID *)batchID;
- (void)setBatchID:(GDataBatchID *)obj; // defined by clients, and present in the batch response feed

- (GDataBatchStatus *)batchStatus;
- (void)setBatchStatus:(GDataBatchStatus *)obj;

- (GDataBatchInterrupted *)batchInterrupted;
- (void)setBatchInterrupted:(GDataBatchInterrupted *)obj;

@end

