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
//  GDataFeedBase.m
//

#import "GDataFeedBase.h"

@interface GDataFeedBase (PrivateMethods)
- (void)setupFromXMLElement:(NSXMLElement *)root;
@end

@implementation GDataFeedBase

- (void)initExtensionDeclarations {
  
  [super initExtensionDeclarations];
  
  Class feedClass = [self class];
  
  // atom publishing control support
  [self addExtensionDeclarationForParentClass:feedClass
                                   childClass:[GDataAtomPubControl class]];  
  
  // batch support
  [self addExtensionDeclarationForParentClass:feedClass
                                   childClass:[GDataBatchOperation class]];  
}

+ (id)feedWithXMLData:(NSData *)data {
  return [[[[self class] alloc] initWithData:data] autorelease];
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  
  // entry point for creation of feeds inside elements
  self = [super initWithXMLElement:element
                            parent:nil];
  if (self) {
    [self setupFromXMLElement:element];
  }
  return self;
}

- (id)initWithData:(NSData *)data {

  // entry point for creation of feeds from file or network data
  NSError *error = nil;
  NSXMLDocument *xmlDocument = [[[NSXMLDocument alloc] initWithData:data
                                                            options:0
                                                              error:&error] autorelease];
  if (xmlDocument) {
    
    NSXMLElement* root = [xmlDocument rootElement];
    self = [super initWithXMLElement:root
                              parent:nil];
    if (self) {
      [self setupFromXMLElement:root];
    } 
    return self;
    
  } else {
    // could not parse XML into a document
    [self release]; 
    return nil;
  }
}

- (void)setupFromXMLElement:(NSXMLElement *)root {
  
  [self setGenerator:[self objectForChildOfElement:root
                                     qualifiedName:@"generator"
                                      namespaceURI:kGDataNamespaceAtom
                                       objectClass:[GDataGenerator class]]];
  
  NSXMLElement *updElement = [self childWithQualifiedName:@"updated"
                                             namespaceURI:kGDataNamespaceAtom
                                              fromElement:root];
  [self setUpdatedDate:[self dateTimeFromElement:updElement]];
    
  [self setTitle:[self objectForChildOfElement:root
                                 qualifiedName:@"title"
                                  namespaceURI:kGDataNamespaceAtom
                                   objectClass:[GDataTextConstruct class]]];
  
  [self setSubtitle:[self objectForChildOfElement:root
                                    qualifiedName:@"subtitle"
                                     namespaceURI:kGDataNamespaceAtom
                                      objectClass:[GDataTextConstruct class]]];
  
  [self setIdentifier:[[self childWithQualifiedName:@"id" 
                                       namespaceURI:kGDataNamespaceAtom
                                        fromElement:root] stringValue]]; 
  
  [self setLinks:[self objectsForChildrenOfElement:root
                                     qualifiedName:@"link"
                                      namespaceURI:kGDataNamespaceAtom
                                       objectClass:[GDataLink class]]];
  
  [self setAuthors:[self objectsForChildrenOfElement:root
                                       qualifiedName:@"author"
                                        namespaceURI:kGDataNamespaceAtom
                                         objectClass:[GDataPerson class]]];  
  
  [self setContributors:[self objectsForChildrenOfElement:root
                                            qualifiedName:@"contributor"
                                             namespaceURI:kGDataNamespaceAtom
                                              objectClass:[GDataPerson class]]];  
  
  [self setCategories:[self objectsForChildrenOfElement:root
                                          qualifiedName:@"category"
                                           namespaceURI:kGDataNamespaceAtom
                                            objectClass:[GDataCategory class]]];
  
  [self setRights:[self objectForChildOfElement:root
                                  qualifiedName:@"rights"
                                   namespaceURI:kGDataNamespaceAtom
                                    objectClass:[GDataTextConstruct class]]];
  
  [self setIcon:[[self childWithQualifiedName:@"icon" 
                                 namespaceURI:kGDataNamespaceAtom
                                  fromElement:root] stringValue]]; 

  [self setLogo:[[self childWithQualifiedName:@"logo" 
                                 namespaceURI:kGDataNamespaceAtom
                                  fromElement:root] stringValue]]; 
  
  NSXMLElement *totElement = [self childWithQualifiedName:@"openSearch:totalResults"
                                             namespaceURI:kGDataNamespaceOpenSearch
                                              fromElement:root];
  NSNumber *total = [self intNumberValueFromElement:totElement];
  [self setTotalResults:total];

  NSXMLElement *startElement = [self childWithQualifiedName:@"openSearch:startIndex"
                                               namespaceURI:kGDataNamespaceOpenSearch
                                                fromElement:root];
  NSNumber *startIndex = [self intNumberValueFromElement:startElement];
  [self setStartIndex:startIndex];
  
  NSXMLElement *itemsElement = [self childWithQualifiedName:@"openSearch:itemsPerPage"
                                               namespaceURI:kGDataNamespaceOpenSearch
                                                fromElement:root];
  NSNumber *itemsPerPage = [self intNumberValueFromElement:itemsElement];
  [self setItemsPerPage:itemsPerPage];
  
  // call subclasses to set up their feed ivars
  [self initFeedWithXMLElement:root];
  
  // allocate individual entries
  Class entryClass = [self classForEntries];
  
#if DEBUG
  NSAssert1([[root localName] isEqual:@"feed"], 
            @"initing a feed from a non-feed element (%@)", [root name]);
#endif
  
  // create entries of the proper class from each "entry" element
  NSArray *entries = [self objectsForChildrenOfElement:root
                                         qualifiedName:@"entry"
                                          namespaceURI:kGDataNamespaceAtom
                                           objectClass:entryClass];
  [self setEntries:entries];
}


- (void)dealloc {
  
  [generator_ release];

  [idString_ release];
  [title_ release];
  [subtitle_ release];
  [rights_ release];
  [icon_ release];
  [logo_ release];
  
  [links_ release];
  [authors_ release];
  [contributors_ release];
  
  [updatedDate_ release];
  
  [totalResults_ release];
  [startIndex_ release];
  [itemsPerPage_ release];
  
  [entries_ release];

  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataFeedBase* newFeed = [super copyWithZone:zone];
  
  [newFeed setGenerator:[self generator]];
  
  [newFeed setIdentifier:[self identifier]];
  [newFeed setTitle:[self title]];
  [newFeed setSubtitle:[self subtitle]];
  [newFeed setRights:[self rights]];
  [newFeed setIcon:[self icon]];
  [newFeed setLogo:[self logo]];
  
  [newFeed setLinks:[self links]];
  [newFeed setAuthors:[self authors]];
  [newFeed setContributors:[self contributors]];
  [newFeed setCategories:[self categories]];
  [newFeed setUpdatedDate:[self updatedDate]];
  
  [newFeed setTotalResults:[self totalResults]];
  [newFeed setStartIndex:[self startIndex]];
  [newFeed setItemsPerPage:[self itemsPerPage]];
  
  [newFeed setEntriesWithEntries:[self entries]];
  
  return newFeed;
}


- (BOOL)isEqual:(GDataFeedBase *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataFeedBase class]]) return NO;

  return [super isEqual:other]
    && AreEqualOrBothNil([self identifier], [other identifier])
    && AreEqualOrBothNil([self title], [other title])
    && AreEqualOrBothNil([self subtitle], [other subtitle])
    && AreEqualOrBothNil([self updatedDate], [other updatedDate])
    && AreEqualOrBothNil([self rights], [other rights])
    && AreEqualOrBothNil([self icon], [other icon])
    && AreEqualOrBothNil([self logo], [other logo])
    && AreEqualOrBothNil([self links], [other links])
    && AreEqualOrBothNil([self authors], [other authors])
    && AreEqualOrBothNil([self contributors], [other contributors])
    && AreEqualOrBothNil([self categories], [other categories])
    && AreEqualOrBothNil([self updatedDate], [other updatedDate])
    && AreEqualOrBothNil([self totalResults], [other totalResults])
    && AreEqualOrBothNil([self startIndex], [other startIndex])
    && AreEqualOrBothNil([self itemsPerPage], [other itemsPerPage])
    && AreEqualOrBothNil([self entries], [other entries]);
  // excluding generator
}

- (NSMutableArray *)itemsForDescription { // subclasses may implement this

  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items integerValue:[entries_ count] withName:@"entries"];
  
  [self addToArray:items objectDescriptionIfNonNil:[title_ stringValue] withName:@"title"];
  [self addToArray:items objectDescriptionIfNonNil:[subtitle_ stringValue] withName:@"subtitle"];
  [self addToArray:items objectDescriptionIfNonNil:[rights_ stringValue] withName:@"rights"];
  [self addToArray:items objectDescriptionIfNonNil:[updatedDate_ stringValue] withName:@"updated"];
  
  [self addToArray:items arrayCountIfNonEmpty:authors_ withName:@"authors"];
  [self addToArray:items arrayCountIfNonEmpty:contributors_ withName:@"contributors"];
  [self addToArray:items arrayCountIfNonEmpty:categories_ withName:@"categories"];
  
  if ([links_ count]) {
    NSArray *linkNames = [GDataLink linkNamesFromLinks:links_];
    NSString *linksStr = [linkNames componentsJoinedByString:@","];
    [self addToArray:items objectDescriptionIfNonNil:linksStr withName:@"links"];
  }  
  
  // these are present but not very useful most of the time...
  // [self addToArray:items objectDescriptionIfNonNil:totalResults_ withName:@"totalResults"];
  // [self addToArray:items objectDescriptionIfNonNil:startIndex_ withName:@"startIndex"];
  // [self addToArray:items objectDescriptionIfNonNil:itemsPerPage_ withName:@"itemsPerPage"];

  [self addToArray:items objectDescriptionIfNonNil:idString_ withName:@"id"];
  
  return items;
}

- (NSString *)description {
  NSArray *items = [self itemsForDescription];
  
  return [NSString stringWithFormat:@"%@ 0x%lX: {%@}",
    [self class], self, [items componentsJoinedByString:@" "]];
}

- (NSXMLElement *)XMLElement {

  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"feed"];
  
  [self addToElement:element childWithStringValueIfNonEmpty:[self identifier] withName:@"id"];
  
  if ([self generator]) {
    [element addChild:[[self generator] XMLElement]]; 
  } 
  
  if ([self title]) {
    [element addChild:[[self title] XMLElement]];
  }
  if ([self subtitle]) {
    [element addChild:[[self subtitle] XMLElement]];
  }
  if ([self rights]) {
    [element addChild:[[self rights] XMLElement]];
  }
  
  [self addToElement:element childWithStringValueIfNonEmpty:[self icon] withName:@"icon"];
  [self addToElement:element childWithStringValueIfNonEmpty:[self logo] withName:@"logo"];
  
  [self addToElement:element XMLElementsForArray:[self links]];
  [self addToElement:element XMLElementsForArray:[self authors]];
  [self addToElement:element XMLElementsForArray:[self contributors]];
  [self addToElement:element XMLElementsForArray:[self categories]];
  
  if ([self updatedDate]) {
    NSString *updatedDateStr = [[self updatedDate] RFC3339String];

    [self addToElement:element childWithStringValueIfNonEmpty:updatedDateStr withName:@"updated"];
  }
  
  NSString *totalResults = [[self totalResults] stringValue];
  NSString *startIndex = [[self startIndex] stringValue];
  NSString *itemsPerPage = [[self itemsPerPage] stringValue];
  
  [self addToElement:element childWithStringValueIfNonEmpty:totalResults withName:@"openSearch:totalResults"];
  [self addToElement:element childWithStringValueIfNonEmpty:startIndex withName:@"openSearch:startIndex"];
  [self addToElement:element childWithStringValueIfNonEmpty:itemsPerPage withName:@"openSearch:itemsPerPage"];
  
  [self addToElement:element XMLElementsForArray:[self entries]];

  return element;
}


#pragma mark -

- (void)initFeedWithXMLElement:(NSXMLElement *)element {
 // subclasses override this to set up their feed ivars from the XML 
}

// subclass should override this
- (Class)classForEntries {
  
  return [GDataEntryBase class]; 
}

- (BOOL)canPost {
  return ([[self links] postLink] != nil);  
}

#pragma mark Getters and Setters

- (NSString *)identifier {
  return idString_; 
}

- (void)setIdentifier:(NSString *)theString {
  [idString_ autorelease];
  idString_ = [theString retain];
}

- (GDataGenerator *)generator {
  return generator_; 
}

- (void)setGenerator:(GDataGenerator *)gen {
  [generator_ autorelease];
  generator_ = [gen copy];
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

- (GDataTextConstruct *)subtitle {
  return subtitle_; 
}

- (void)setSubtitle:(GDataTextConstruct *)theSubtitle {
  [subtitle_ autorelease];
  subtitle_ = [theSubtitle copy];

  [subtitle_ setElementName:@"subtitle"];
}

- (void)setSubtitleWithString:(NSString *)str {
  [self setSubtitle:[GDataTextConstruct textConstructWithString:str]]; 
}

- (GDataTextConstruct *)rights {
  return rights_; 
}

- (void)setRights:(GDataTextConstruct *)theRights {
  [rights_ autorelease];
  rights_ = [theRights copy];
  
  [rights_ setElementName:@"rights"];
}

- (void)setRightsWithString:(NSString *)str {
  [self setRights:[GDataTextConstruct textConstructWithString:str]]; 
}

- (NSString *)icon {
  return icon_; 
}

- (void)setIcon:(NSString *)theString {
  [icon_ autorelease];
  icon_ = [theString retain];
}

- (NSString *)logo {
  return logo_; 
}

- (void)setLogo:(NSString *)theString {
  [logo_ autorelease];
  logo_ = [theString retain];
}

- (NSArray *)links {
  return links_;
}

- (void)setLinks:(NSArray *)links {
  [links_ autorelease];
  links_ = [links mutableCopy];
}

- (void)addLink:(GDataLink *)obj {
  if (!links_) {
    links_ = [[NSMutableArray alloc] init]; 
  }
  [links_ addObject:obj];
}

- (NSArray *)authors {
  return authors_;
}

- (void)setAuthors:(NSArray *)authors {
  [authors_ autorelease];
  authors_ = [authors mutableCopy];
}

- (void)addAuthor:(GDataPerson *)obj {
  if (!authors_) {
    authors_ = [[NSMutableArray alloc] init]; 
  }
  [obj setElementName:@"author"];
  [authors_ addObject:obj];
}

- (NSArray *)contributors {
  return contributors_;
}

- (void)setContributors:(NSArray *)array {
  [contributors_ autorelease];
  contributors_ = [array mutableCopy];
}

- (void)addContributor:(GDataPerson *)obj {
  if (!contributors_) {
    contributors_ = [[NSMutableArray alloc] init]; 
  }
  [obj setElementName:@"contributor"];
  [contributors_ addObject:obj];
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

- (GDataDateTime *)updatedDate {
  return updatedDate_; 
}

- (void)setUpdatedDate:(GDataDateTime *)theDate {
  [updatedDate_ autorelease];
  updatedDate_ = [theDate retain];
}

- (NSNumber *)totalResults {
  return totalResults_; 
}

- (void)setTotalResults:(NSNumber *)num {
  [totalResults_ autorelease]; 
  totalResults_ = [num retain];
}

- (NSNumber *)startIndex {
  return startIndex_; 
}

- (void)setStartIndex:(NSNumber *)num {
  [startIndex_ autorelease]; 
  startIndex_ = [num retain];
}

- (NSNumber *)itemsPerPage {
  return itemsPerPage_; 
}

- (void)setItemsPerPage:(NSNumber *)num {
  [itemsPerPage_ autorelease]; 
  itemsPerPage_ = [num retain];
}

- (NSArray *)entries {
  return entries_; 
}

// setEntries: and addEntry: expect the entries to have parents that are
// nil or this feed instance; setEntriesWithEntries: and addEntryWithEntry:
// make copies of the supplied entries

- (void)setEntries:(NSArray *)entries {
  
  [entries_ autorelease];
  entries_ = [entries mutableCopy];
  
  // step through the entries, ensure that none have other parents,
  // make each have this feed as parent
  NSEnumerator *enumerator = [entries_ objectEnumerator];
  GDataObject* entry;
  
  while ((entry = [enumerator nextObject]) != nil) {
    GDataObject *oldParent = [entry parent];
    NSAssert(oldParent == self || oldParent == nil,
              @"Trying to replace existing feed parent; use setEntriesWithEntries: instead");
    [entry setParent:self];
  }
}

- (void)addEntry:(GDataEntryBase *)obj {
    
  if (!entries_) {
    entries_ = [[NSMutableArray alloc] init]; 
  }
  
  // ensure the entry doesn't have another parent
  GDataObject *oldParent = [obj parent];
  NSAssert(oldParent == self || oldParent == nil, 
           @"Trying to replace existing feed parent; use addEntryWithEntry: instead");  

  [obj setParent:self];
  [entries_ addObject:obj];
}

- (void)setEntriesWithEntries:(NSArray *)entries {
  
  // make an array containing copies of the entries with this feed
  // as the parent of each entry copy
  [entries_ autorelease];
  entries_ = [[NSMutableArray alloc] init];

  NSEnumerator *enumerator = [entries objectEnumerator];
  GDataObject* entry;
  
  while ((entry = [enumerator nextObject]) != nil) {
    GDataEntryBase *entryCopy = [[entry copy] autorelease]; // clears parent in copy
    [entryCopy setParent:self];
    [entries_ addObject:entryCopy];
  }
}

- (void)addEntryWithEntry:(GDataEntryBase *)obj {

  GDataEntryBase *entryCopy = [[obj copy] autorelease]; // clears parent in copy
  [self addEntry:entryCopy];
}

// extensions for Atom publishing control

- (GDataAtomPubControl *)atomPubControl {
  return [self objectForExtensionClass:[GDataAtomPubControl class]];
}

- (void)setAtomPubControl:(GDataAtomPubControl *)obj {
  [self setObject:obj forExtensionClass:[GDataAtomPubControl class]];
}

// extensions for batch support

- (GDataBatchOperation *)batchOperation {
  return [self objectForExtensionClass:[GDataBatchOperation class]];
}

- (void)setBatchOperation:(GDataBatchOperation *)obj {
  [self setObject:obj forExtensionClass:[GDataBatchOperation class]];
}

@end


