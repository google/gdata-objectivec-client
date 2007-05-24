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

@implementation GDataEntryBase

+ (NSDictionary *)baseGDataNamespaces {
  NSDictionary *namespaces = [NSDictionary dictionaryWithObjectsAndKeys:
    kGDataNamespaceAtom, @"",
    kGDataNamespaceGData, kGDataNamespaceGDataPrefix, nil];
  return namespaces;
}

+ (GDataEntryBase *)entry {
  GDataEntryBase *entry = [[[GDataEntryBase alloc] init] autorelease];
  
  [entry setNamespaces:[GDataEntryBase baseGDataNamespaces]];
  return entry;
}

- (void)initExtensionDeclarations {
  
  [super initExtensionDeclarations];
  
  Class entryClass = [self class];

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
  [title_ release];
  [summary_ release];
  [content_ release];
  [rightsString_ release];
  [links_ release];
  [authors_ release];
  [categories_ release];
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
    && AreEqualOrBothNil([self title], [other title])
    && AreEqualOrBothNil([self summary], [other summary])
    && AreEqualOrBothNil([self content], [other content])
    && AreEqualOrBothNil([self rightsString], [other rightsString])
    && AreEqualOrBothNil([self authors], [other authors])
    && AreEqualOrBothNil([self categories], [other categories]);
}

- (id)copyWithZone:(NSZone *)zone {
  GDataEntryBase* newEntry = [super copyWithZone:zone];
    
  [newEntry setCanEdit:[self canEdit]];
  [newEntry setIdentifier:[self identifier]];
  [newEntry setVersionIDString:[self versionIDString]];
  [newEntry setPublishedDate:[self publishedDate]];
  [newEntry setUpdatedDate:[self updatedDate]];
  [newEntry setTitle:[self title]];
  [newEntry setSummary:[self summary]];
  [newEntry setContent:[self content]];
  [newEntry setRightsString:[self rightsString]];
  [newEntry setLinks:[self links]];
  [newEntry setAuthors:[self authors]];
  [newEntry setCategories:[self categories]];
  
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

  [self addToArray:items objectDescriptionIfNonNil:idString_ withName:@"id"];

  return items;
}

- (NSString *)description {
  
  NSArray *items = [self itemsForDescription];
  
  return [NSString stringWithFormat:@"%@ 0x%lX: {%@}",
    [self class], self, [items componentsJoinedByString:@" "]];
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
  [self addToElement:element XMLElementsForArray:links_];
  [self addToElement:element XMLElementsForArray:authors_];
  [self addToElement:element XMLElementsForArray:[self categories]];
  
  return element;
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

- (GDataTextConstruct *)title {
  return title_; 
}

- (void)setTitle:(GDataTextConstruct *)theTitle {
  [title_ autorelease];
  title_ = [theTitle copy];

  [title_ setElementName:@"title"];
}

- (GDataTextConstruct *)summary {
  return summary_; 
}

- (void)setSummary:(GDataTextConstruct *)theSummary {
  [summary_ autorelease];
  summary_ = [theSummary copy];

  [summary_ setElementName:@"summary"];
}

- (GDataEntryContent *)content {
  return content_; 
}

- (void)setContent:(GDataEntryContent *)theContent {
  [content_ autorelease];
  content_ = [theContent copy];

  [content_ setElementName:@"content"];
}

- (GDataTextConstruct *)rightsString {
  return rightsString_; 
}

- (void)setRightsString:(GDataTextConstruct *)theRightsString {
  [rightsString_ autorelease];
  rightsString_ = [theRightsString copy];
  
  [rightsString_ setElementName:@"rights"];
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



