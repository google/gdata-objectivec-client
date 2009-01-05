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
//  GDataObject.m
//

#define GDATAOBJECT_DEFINE_GLOBALS 1

#import "GDataObject.h"
#import "GDataDateTime.h"

// for automatic-determination of feed and entry class types
#import "GDataFeedBase.h"
#import "GDataEntryBase.h"
#import "GDataCategory.h"

// Creating a CFDictionary rather than an NSMutableDictionary here avoids
// problems with the underlying map global variable becoming invalid across
// unit tests when garbage collection is enabled
static inline NSMutableDictionary *GDataCreateStaticDictionary(void) {
  
  CFMutableDictionaryRef dict = CFDictionaryCreateMutable(kCFAllocatorDefault,  
          0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
  
  return (NSMutableDictionary *)dict;
}

// Elements may call -addExtensionDeclarationForParentClass:childClass: and
// addAttributeExtensionDeclarationForParentClass: to declare extensions to be
// parsed; the declaration applies in the element and all children of the element.
@interface GDataExtensionDeclaration : NSObject {
  Class parentClass_;
  Class childClass_;
  BOOL isAttribute_;
}
- (id)initWithParentClass:(Class)parentClass childClass:(Class)childClass isAttribute:(BOOL)attrFlag;
- (Class)parentClass;
- (Class)childClass;
- (BOOL)isAttribute;
@end

@interface GDataObject (PrivateMethods) 

// array of local attribute names to be automatically parsed and
// generated
- (void)setAttributeDeclarations:(NSArray *)decls;
- (NSArray *)attributeDeclarations;

- (void)parseAttributesForElement:(NSXMLElement *)element;
- (void)addAttributesToElement:(NSXMLElement *)element;

// routines for comparing attributes 
- (BOOL)hasAttributesEqualToAttributesOf:(GDataObject *)other;
- (NSArray *)attributesIgnoredForEquality;

// element string content
- (void)parseContentValueForElement:(NSXMLElement *)element;
- (void)addContentValueToElement:(NSXMLElement *)element;

- (BOOL)hasContentValueEqualToContentValueOf:(GDataObject *)other;

// XML values content (kept unparsed)
- (void)keepChildXMLElementsForElement:(NSXMLElement *)element;
- (void)addChildXMLElementsToElement:(NSXMLElement *)element;

- (BOOL)hasChildXMLElementsEqualToChildXMLElementsOf:(GDataObject *)other;

// dictionary of all extensions actually found in the XML element
- (void)setExtensions:(NSDictionary *)extensions;
- (NSDictionary *)extensions;

// array of extensions that may be found in this class and in 
// subclasses of this class
- (void)setExtensionDeclarations:(NSDictionary *)decls;
- (NSDictionary *)extensionDeclarations;

- (void)addExtensionDeclarationForParentClass:(Class)parentClass
                                   childClass:(Class)childClass
                                  isAttribute:(BOOL)isAttribute;

- (void)addUnknownChildNodesForElement:(NSXMLElement *)element;

- (void)parseExtensionsForElement:(NSXMLElement *)element;

- (void)handleParsedElement:(NSXMLNode *)element;
- (void)handleParsedElements:(NSArray *)array;

- (NSString *)qualifiedNameForExtensionClass:(Class)class;

- (NSDictionary *)dictionaryForElementNamespaces:(NSXMLElement *)element;

+ (Class)classForCategoryWithScheme:(NSString *)scheme
                               term:(NSString *)term
                            fromMap:(NSDictionary *)map;  
@end

@implementation GDataObject

// The qualified name map avoids the need to regenerate qualified
// element names (foo:bar) repeatedly
static NSMutableDictionary *gQualifiedNameMap = nil;

+ (void)load {
  // Initialize gQualifiedNameMap early so we can @synchronize on accesses
  // to it
  gQualifiedNameMap = GDataCreateStaticDictionary();
}

- (id)init {
  self = [super init];
  if (self) {
    [self addParseDeclarations];
  }
  return self;
}

// intended mainly for testing, initWithServiceVersion allows the service
// version to be set prior to declaring extensions; this is useful
// for overriding the default service version for the class when
// manually allocating a copy of the object
- (id)initWithServiceVersion:(NSString *)serviceVersion {
  [self setServiceVersion:serviceVersion];
  return [self init];
}

// this init routine is only used when passing in a top-level surrogates
// dictionary
- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent
          serviceVersion:(NSString *)serviceVersion
              surrogates:(NSDictionary *)surrogates
    shouldIgnoreUnknowns:(BOOL)shouldIgnoreUnknowns {
  
  [self setServiceVersion:serviceVersion];
  
  [self setSurrogates:surrogates];
  
  [self setShouldIgnoreUnknowns:shouldIgnoreUnknowns];

  return [self initWithXMLElement:element
                           parent:parent];
}

// subclasses will typically override initWithXMLElement:parent:
// and do their own parsing after this method returns
- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super init];
  if (self) {
    [self setParent:parent];

    if (parent != nil) {
      // top-level objects (feeds and entries) have nil parents, and
      // have their service version set previously in 
      // initWithXMLElement:parent:serviceVersion:surrogates:; child
      // objects have their service version set here
      [self setServiceVersion:[parent serviceVersion]];

      // feeds may specify that contained entries and their child elements
      // should ignore any unparsed XML
      [self setShouldIgnoreUnknowns:[parent shouldIgnoreUnknowns]];
    }

    [self setNamespaces:[self dictionaryForElementNamespaces:element]];
    [self addUnknownChildNodesForElement:element];
    [self addExtensionDeclarations];
    [self addParseDeclarations];
    [self parseExtensionsForElement:element];
    [self parseAttributesForElement:element];
    [self parseContentValueForElement:element];
    [self keepChildXMLElementsForElement:element];
    [self setElementName:[element name]];
    
    // We are done parsing extensions and no longer need the extension
    // declarations. (But we keep local attribute declarations since they're
    // used for determining the order of the attributes in the description
    // method.)
    [extensionDeclarations_ release];
    extensionDeclarations_ = nil;

#if GDATA_USES_LIBXML
    if (!shouldIgnoreUnknowns_) {
      // retain the element so that pointers to internal nodes remain valid
      [self setProperty:element forKey:kGDataXMLElementPropertyKey];
    }
#endif    
  }
  return self;
}

- (BOOL)isEqual:(GDataObject *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[self class]]) return NO;

  // We used to compare the local names of the objects with
  // NSXMLNode's localNameForName: on each object's elementName, but that
  // prevents us from comparing the contents of a manually-constructed object
  // (which lacks a specific local name) with one found in an actual XML feed.
  
#if GDATA_USES_LIBXML
  // libxml adds namespaces when copying elements, so we can't rely
  // on those when comparing nodes
  return AreEqualOrBothNil([self extensions], [other extensions])
    && [self hasAttributesEqualToAttributesOf:other]
    && [self hasContentValueEqualToContentValueOf:other]
    && [self hasChildXMLElementsEqualToChildXMLElementsOf:other];
#else
  return AreEqualOrBothNil([self extensions], [other extensions])
    && [self hasAttributesEqualToAttributesOf:other]
    && [self hasContentValueEqualToContentValueOf:other]
    && [self hasChildXMLElementsEqualToChildXMLElementsOf:other]
    && AreEqualOrBothNil([self namespaces], [other namespaces]);
#endif
  
  // What we're not comparing here:
  //   parent object pointers
  //   extension declarations
  //   unknown attributes & children
  //   local element names
  //   service version
  //   userData
}

// By definition, for two objects to potentially be considered equal, 
// they must have the same hash value.  The hash is mostly ignored, 
// but removeObjectsInArray: in Leopard does seem to check the hash, 
// and NSObject's default hash method just returns the instance pointer.  
// We'll define hash here for all of our GDataObjects.
- (NSUInteger)hash {
  return (NSUInteger) (void *) [GDataObject class];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataObject* newObject = [[[self class] allocWithZone:zone] init];
  [newObject setElementName:[self elementName]];
  [newObject setParent:nil];
  [newObject setServiceVersion:[self serviceVersion]];
  
  NSDictionary *namespaces = 
    [GDataUtilities mutableDictionaryWithCopiesOfObjectsInDictionary:[self namespaces]];
  [newObject setNamespaces:namespaces];

  NSDictionary *extensions = 
    [GDataUtilities mutableDictionaryWithCopiesOfArraysInDictionary:[self extensions]];
  [newObject setExtensions:extensions];
  
  NSDictionary *attributes = 
    [GDataUtilities mutableDictionaryWithCopiesOfObjectsInDictionary:[self attributes]];
  [newObject setAttributes:attributes];
  
  if (shouldParseContentValue_) {
    [newObject addContentValueDeclaration];
    [newObject setContentStringValue:[self contentStringValue]];
  }

  if (shouldKeepChildXMLElements_) {
    [newObject addChildXMLElementsDeclaration];

    NSArray *childElements = [self childXMLElements];
    NSArray *arr = [GDataUtilities arrayWithCopiesOfObjectsInArray:childElements];
    [newObject setChildXMLElements:arr];
  }
  
  // extension and attribute declarations are immutable, so don't need to be 
  // deep copied
  [newObject setExtensionDeclarations:[self extensionDeclarations]];
  [newObject setAttributeDeclarations:[self attributeDeclarations]];

  BOOL shouldIgnoreUnknowns = [self shouldIgnoreUnknowns];
  [newObject setShouldIgnoreUnknowns:shouldIgnoreUnknowns];

  if (!shouldIgnoreUnknowns) {
    NSArray *unknownChildren =
      [GDataUtilities mutableArrayWithCopiesOfObjectsInArray:[self unknownChildren]];
    [newObject setUnknownChildren:unknownChildren];

    NSArray *unknownAttributes =
      [GDataUtilities mutableArrayWithCopiesOfObjectsInArray:[self unknownAttributes]];
    [newObject setUnknownAttributes:unknownAttributes];
  }
  
  return newObject;
  
  // What we're not copying:
  //   parent object pointer
  //   surrogates
  //   userData
  //   userProperties
}

- (void)dealloc {
  [elementName_ release];
  [namespaces_ release];
  [extensionDeclarations_ release];
  [attributeDeclarations_ release];
  [extensions_ release];
  [attributes_ release];
  [contentValue_ release];
  [childXMLElements_ release];
  [unknownChildren_ release];
  [unknownAttributes_ release];
  [surrogates_ release];
  [serviceVersion_ release];
  [userData_ release];
  [userProperties_ release];
  [super dealloc]; 
}

// XMLElement must be implemented by subclasses
- (NSXMLElement *)XMLElement {
  // subclass should override if they have custom elements or attributes
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:nil];
  return element;
} 

- (NSXMLDocument *)XMLDocument {
  NSXMLElement *element = [self XMLElement];
  NSXMLDocument *doc = [[[NSXMLDocument alloc] initWithRootElement:(id)element] autorelease];
  [doc setVersion:@"1.0"];
  [doc setCharacterEncoding:@"UTF-8"];
  return doc;
}

- (BOOL)generateContentInputStream:(NSInputStream **)outInputStream
                            length:(unsigned long long *)outLength
                           headers:(NSDictionary **)outHeaders {
  // subclasses may return a data stream representing this object
  // for uploading
  return NO; 
}

#pragma mark -

- (void)setElementName:(NSString *)name {
  [elementName_ release];
  elementName_ = [name copy];
}

- (NSString *)elementName {
  return elementName_; 
}

- (void)setNamespaces:(NSDictionary *)dict {
  [namespaces_ release];
  namespaces_ = [dict mutableCopy];
}

- (void)addNamespaces:(NSDictionary *)dict {
  if (namespaces_ == nil) {
    namespaces_ = [[NSMutableDictionary alloc] init];
  }
  [namespaces_ addEntriesFromDictionary:dict];
}

- (NSDictionary *)namespaces {
  return namespaces_; 
}

- (NSDictionary *)completeNamespaces {
  // return a dictionary containing all namespaces
  // in this object and its parent objects
  NSDictionary *parentNamespaces = [parent_ completeNamespaces];
  NSDictionary *ownNamespaces = namespaces_;

  if (ownNamespaces == nil) return parentNamespaces;
  if (parentNamespaces == nil) return ownNamespaces;
 
  // combine them, replacing parent-defined prefixes with own ones
  NSMutableDictionary *mutable;
  
  mutable = [NSMutableDictionary dictionaryWithDictionary:parentNamespaces];
  [mutable addEntriesFromDictionary:ownNamespaces];
  return mutable;
}

- (void)pruneInheritedNamespaces {
  
  if (parent_ == nil || [namespaces_ count] == 0) return;
  
  // if a prefix is explicitly defined the same for the parent as it is locally,
  // remove it, since we can rely on the parent's definition
  NSMutableDictionary *prunedNamespaces
    = [NSMutableDictionary dictionaryWithDictionary:namespaces_];

  NSDictionary *parentNamespaces = [parent_ completeNamespaces];
  NSEnumerator *nsEnum = [namespaces_ keyEnumerator];
  NSString *prefix;
  
  while ((prefix = [nsEnum nextObject]) != nil) {
    
    NSString *ownURI = [namespaces_ objectForKey:prefix]; 
    NSString *parentURI = [parentNamespaces objectForKey:prefix]; 
    
    if (AreEqualOrBothNil(ownURI, parentURI)) {
      [prunedNamespaces removeObjectForKey:prefix];
    }
  }
  
  [self setNamespaces:prunedNamespaces];
}

- (void)setParent:(GDataObject *)obj {
  parent_ = obj; // parent_ is a weak (not retained) reference
}

- (GDataObject *)parent {
  return parent_; 
}

- (void)setAttributeDeclarations:(NSArray *)attrs {
  [attributeDeclarations_ release];
  attributeDeclarations_ = [attrs mutableCopy];
}

- (NSArray *)attributeDeclarations {
  return attributeDeclarations_; 
}

- (void)setAttributes:(NSDictionary *)dict {
  [attributes_ autorelease];
  attributes_ = [dict mutableCopy];
}

- (NSDictionary *)attributes {
  return attributes_;
}

- (void)setExtensions:(NSDictionary *)extensions {
  [extensions_ autorelease];
  extensions_ = [extensions mutableCopy];
}

- (NSDictionary *)extensions {
  return extensions_; 
}

- (void)setExtensionDeclarations:(NSDictionary *)decls {
  [extensionDeclarations_ autorelease];
  extensionDeclarations_ = [decls mutableCopy];
}

- (NSDictionary *)extensionDeclarations {
  return extensionDeclarations_; 
}

- (void)setUnknownChildren:(NSArray *)arr {
  [unknownChildren_ autorelease];
  unknownChildren_ = [arr mutableCopy];
}

- (NSArray *)unknownChildren {
  return unknownChildren_; 
}

- (void)setUnknownAttributes:(NSArray *)arr {
  [unknownAttributes_ autorelease];
  unknownAttributes_ = [arr mutableCopy];
}

- (NSArray *)unknownAttributes {
  return unknownAttributes_; 
}

- (void)setShouldIgnoreUnknowns:(BOOL)flag {
  shouldIgnoreUnknowns_ = flag;
}

- (BOOL)shouldIgnoreUnknowns {
  return shouldIgnoreUnknowns_; 
}

- (void)setSurrogates:(NSDictionary *)surrogates {
  [surrogates_ autorelease];
  surrogates_ = [surrogates retain];
}

- (NSDictionary *)surrogates {
  return surrogates_; 
}

+ (NSString *)defaultServiceVersion {
  return nil;
}

- (void)setServiceVersion:(NSString *)str {
  [serviceVersion_ autorelease];
  serviceVersion_ = [str copy];
}

- (NSString *)serviceVersion {
  if (serviceVersion_ != nil) {
    return serviceVersion_;
  }

  NSString *str = [[self class] defaultServiceVersion];
  return str;
}

- (BOOL)isServiceVersion1 {
  NSString *str = [self serviceVersion];
  BOOL isV1 = ([str intValue] <= 1);
  return isV1;
}

#pragma mark userData and properties

- (void)setUserData:(id)userData {
  [userData_ autorelease];
  userData_ = [userData retain];
}

- (id)userData {
  // be sure the returned pointer has the life of the autorelease pool,
  // in case self is released immediately
  return [[userData_ retain] autorelease];
}

- (void)setProperties:(NSDictionary *)dict {
  [userProperties_ autorelease];
  userProperties_ = [dict mutableCopy];
}

- (NSDictionary *)properties {
  // be sure the returned pointer has the life of the autorelease pool,
  // in case self is released immediately
  return [[userProperties_ retain] autorelease];
}

- (void)setProperty:(id)obj forKey:(NSString *)key {
  
  if (obj == nil) {
    // user passed in nil, so delete the property
    [userProperties_ removeObjectForKey:key];
  } else {
    // be sure the property dictionary exists
    if (userProperties_ == nil) {
      userProperties_ = [[NSMutableDictionary alloc] init];
    }
    [userProperties_ setObject:obj forKey:key];
  }
}

- (id)propertyForKey:(NSString *)key {
  id obj = [userProperties_ objectForKey:key];
  
  // be sure the returned pointer has the life of the autorelease pool,
  // in case self is released immediately
  return [[obj retain] autorelease];
}

#pragma mark XML generation helpers

- (NSString *)updatedVersionedNamespaceURIForPrefix:(NSString *)prefix 
                                                URI:(NSString *)uri {

  // If there are many more transforms like this needed for future version
  // changes, we can create a global registry of version-specific
  // namespace tuples, rather than rely on this narrow hack.
  
  if ([prefix isEqual:kGDataNamespaceAtomPubPrefix]) {
    
    if ([self isServiceVersion1]) {
      uri = kGDataNamespaceAtomPub1_0;
    } else {
      uri = kGDataNamespaceAtomPubStd;
    }
  }
  return uri;
}

- (void)addNamespacesToElement:(NSXMLElement *)element {

  // we keep namespaces in a dictionary with prefixes
  // as keys.  We'll step through our namespaces and convert them
  // to NSXML-stype namespaces.
  
  NSUInteger numberOfNamespaces = [namespaces_ count];
  if (numberOfNamespaces) {
    
    NSArray *namespaceNames = [namespaces_ allKeys];
    NSString *name;
    GDATA_FOREACH(name, namespaceNames) {
      NSString *uri = [namespaces_ objectForKey:name];
      
      uri = [self updatedVersionedNamespaceURIForPrefix:name
                                                    URI:uri];
      
      [element addNamespace:[NSXMLElement namespaceWithName:name
                                               stringValue:uri]];
    }
  }
}

- (void)addExtensionsToElement:(NSXMLElement *)element {
  // extensions are in a dictionary of arrays, keyed by the class
  // of each kind of element
  
  // note: this adds actual extensions, not declarations
  
  NSDictionary *extensions = [self extensions];
  NSArray *classKeys = [extensions allKeys];
  if (classKeys) {
    
    // step through each extension, by class, and add those
    // objects to the XML element
    Class oneClass;
    GDATA_FOREACH(oneClass, classKeys) {
      NSArray *objects = [self objectsForExtensionClass:oneClass];
      [self addToElement:element XMLElementsForArray:objects];
    }
  }
}

- (void)addUnknownChildNodesToElement:(NSXMLElement *)element {
  
  // we'll add every element and attribute as "unknown", then remove them
  // from this list as we parse them to create the GData object. Anything
  // left remaining in this list is considered unknown.
  
  if (shouldIgnoreUnknowns_) return;

  // we have to copy the children so they don't point at the previous parent
  // nodes
  NSXMLNode *child;
  GDATA_FOREACH(child, unknownChildren_) {
    [element addChild:[[child copy] autorelease]];
  }
  
  NSXMLNode *attr;
  GDATA_FOREACH(attr, unknownAttributes_) {

    GDATA_DEBUG_ASSERT([element attributeForName:[attr name]] == nil,
              @"adding duplicate of attribute %@ (perhaps an object parsed with"
              "attributeForName: instead of attributeForName:fromElement:)",
              attr);

    [element addAttribute:[[attr copy] autorelease]];
  }
}

// this method creates a basic XML element from this GData object.
//
// this is called by the XMLElement method of subclasses; they will add their
// own attributes and children to the element returned by this method
//
// extensions may pass nil for defaultName to use the name specified in their
// extensionElementLocalName and extensionElementPrefix

- (NSXMLElement *)XMLElementWithExtensionsAndDefaultName:(NSString *)defaultName {
  
#if 0
  // code sometimes useful for finding unparsed xml; this can be turned on
  // during testing
  if ([unknownAttributes_ count]) {
    NSLog(@"%@ %lX: unknown attributes %@\n%@\n", [self class], self, unknownAttributes_, self);
  }
  if ([unknownChildren_ count]) {
    NSLog(@"%@ %lX: unknown children %@\n%@\n", [self class], self, unknownChildren_, self);
  }
#endif
  
  // use the name from the XML
  NSString *elementName = [self elementName]; 
  if (!elementName) {
    
    // if no name from the XML, use the name our class's XML element
    // routine supplied as a default
    if (defaultName) {
      elementName = defaultName;
    } else {
      // if no default name from the class, and this class is an extension, 
      // use the extension's default element name
      if ([[self class] conformsToProtocol:@protocol(GDataExtension)]) {
        
        elementName = [self qualifiedNameForExtensionClass:[self class]];
      } else {
        // if not an extension, just use the class name
        elementName = NSStringFromClass([self class]); 

        GDATA_DEBUG_LOG(@"GDataObject generating XML element with unknown name for class %@",
              elementName);
      }
    }
  }
  
  NSXMLElement *element = [NSXMLNode elementWithName:elementName];
  [self addNamespacesToElement:element];
  [self addAttributesToElement:element];
  [self addContentValueToElement:element];
  [self addChildXMLElementsToElement:element];
  [self addExtensionsToElement:element];
  [self addUnknownChildNodesToElement:element];
  return element;
}

- (NSXMLNode *)addToElement:(NSXMLElement *)element
     attributeValueIfNonNil:(NSString *)val
                   withName:(NSString *)name {
  if (val) {
    NSString *filtered = [GDataUtilities stringWithControlsFilteredForString:val];

    NSXMLNode* attr = [NSXMLNode attributeWithName:name stringValue:filtered];
    [element addAttribute:attr];
    return attr;
  }
  return nil;
}

- (NSXMLNode *)addToElement:(NSXMLElement *)element
     attributeValueIfNonNil:(NSString *)val
          withQualifiedName:(NSString *)qName
                        URI:(NSString *)attributeURI {
  
  if (attributeURI == nil) {
    return [self addToElement:element
       attributeValueIfNonNil:val 
                     withName:qName];
  }
  
  if (val) {
    NSString *filtered = [GDataUtilities stringWithControlsFilteredForString:val];
    
    NSXMLNode *attr = [NSXMLNode attributeWithName:qName
                                               URI:attributeURI
                                       stringValue:filtered];
    if (attr != nil) {
      [element addAttribute:attr];
      return attr;
    }
  }
  return nil;
}

- (NSXMLNode *)addToElement:(NSXMLElement *)element
  attributeValueWithInteger:(int)val
                   withName:(NSString *)name {
  NSString* str = [NSString stringWithFormat:@"%d", val];
  NSXMLNode* attr = [NSXMLNode attributeWithName:name stringValue:str];
  [element addAttribute:attr];
  return attr;
}

// adding a child to an XML element
- (NSXMLNode *)addToElement:(NSXMLElement *)element
childWithStringValueIfNonEmpty:(NSString *)str
                   withName:(NSString *)name {
  if ([str length]) {
    NSXMLNode *child = [NSXMLElement elementWithName:name stringValue:str];
    [element addChild:child];
    return child;
  }
  return nil;
}

// adding a child containing a value= property
- (NSXMLNode *)addToElement:(NSXMLElement *)element
     childWithValuePropertyIfNonNil:(id)value
                   withName:(NSString *)name {
  
  if (value) {
    NSXMLElement *child = [NSXMLElement elementWithName:name];
    [self addToElement:child attributeValueIfNonNil:value withName:@"value"];
    
    [element addChild:child];
    return child;
  }
  return nil;
}

// call the XMLElement method of each GData object in the array 
- (void)addToElement:(NSXMLElement *)element
 XMLElementsForArray:(NSArray *)arrayOfGDataObjects {
  
  id item;
  GDATA_FOREACH(item, arrayOfGDataObjects) {
    
    if ([item isKindOfClass:[GDataAttribute class]]) {
      
      // attribute extensions are not GDataObjects and don't implement 
      // XMLElement; we just get the attribute value from them
      NSString *str = [item stringValue];
      NSString *qName = [self qualifiedNameForExtensionClass:[item class]];
      NSString *theURI = [[item class] extensionElementURI];
      
      [self addToElement:element 
  attributeValueIfNonNil:str
       withQualifiedName:qName
                     URI:theURI];
      
    } else {
      // element extension
      NSXMLElement *child = [item XMLElement];
      if (child) {
        [element addChild:child];
      }
    }
  }
}

#pragma mark description method helpers

- (void)addToArray:(NSMutableArray *)stringItems
objectDescriptionIfNonNil:(id)obj
          withName:(NSString *)name {

  if (obj) {
    if (name) {
      [stringItems addObject:[NSString stringWithFormat:@"%@:%@", name, obj]];
    } else {
      [stringItems addObject:[obj description]];
    }
  }
}

- (void)addToArray:(NSMutableArray *)stringItems
      integerValue:(NSInteger)val
          withName:(NSString *)name {
  [stringItems addObject:[NSString stringWithFormat:@"%@:%ld", name, (long)val]];
}

- (void)addToArray:(NSMutableArray *)stringItems
      arrayCountIfNonEmpty:(NSArray *)array
          withName:(NSString *)name {
  if ([array count] > 0) {
    [self addToArray:stringItems integerValue:[array count] withName:name];
  }
}

- (void)addToArray:(NSMutableArray *)stringItems
arrayDescriptionIfNonEmpty:(NSArray *)array
          withName:(NSString *)name {
  if ([array count] > 0) {
    [self addToArray:stringItems objectDescriptionIfNonNil:array withName:name];
  }
}

- (void)addAttributeDescriptionsToArray:(NSMutableArray *)stringItems {
  
  // add attribute descriptions in the order the attributes were declared
  NSString *name;
  GDATA_FOREACH(name, attributeDeclarations_) {
    
    NSString *value = [attributes_ valueForKey:name];
    [self addToArray:stringItems objectDescriptionIfNonNil:value withName:name];
  }  
}

- (void)addContentDescriptionToArray:(NSMutableArray *)stringItems
                            withName:(NSString *)name {
  if (shouldParseContentValue_) {
    NSString *value = [self contentStringValue];
    [self addToArray:stringItems objectDescriptionIfNonNil:value withName:name];
  }
}

- (void)addChildXMLElementsDescriptionToArray:(NSMutableArray *)stringItems {
  if (shouldKeepChildXMLElements_) {

    NSArray *childXMLElements = [self childXMLElements];
    if ([childXMLElements count] > 0) {

      NSArray *xmlStrings = [childXMLElements valueForKey:@"XMLString"];
      NSString *combinedStr = [xmlStrings componentsJoinedByString:@""];

      [self addToArray:stringItems objectDescriptionIfNonNil:combinedStr withName:@"XML"];
    }
  }
}

- (NSMutableArray *)itemsForDescription {
  
  NSMutableArray *items = [NSMutableArray array];
  [self addAttributeDescriptionsToArray:items];
  [self addContentDescriptionToArray:items withName:@"content"];
  [self addChildXMLElementsDescriptionToArray:items];
  return items;
}

- (NSString *)descriptionWithItems:(NSArray *)items {
  
  NSString *str;
  
  if ([items count] > 0) {
    str = [NSString stringWithFormat:@"%@ 0x%lX: {%@}",
      [self class], self, [items componentsJoinedByString:@" "]];
    
  } else {
    str = [NSString stringWithFormat:@"%@ 0x%lX", [self class], self];
  }
  return str;
}

- (NSString *)description {
  
  NSArray *items = [self itemsForDescription];
  NSString *str = [self descriptionWithItems:items];
  return str;
}


#pragma mark XML parsing helpers

- (NSDictionary *)dictionaryForElementNamespaces:(NSXMLElement *)element {
  
  NSMutableDictionary *dict = nil;
  
  // for each namespace node, add a dictionary entry with the namespace
  // name (prefix) as key and the URI as value
  //
  // note: the prefix may be an empty string
  
  NSArray *namespaceNodes = [element namespaces];

  NSUInteger numberOfNamespaces = [namespaceNodes count];
  
  if (numberOfNamespaces > 0) {
    
    dict = [NSMutableDictionary dictionary];
    
    for (unsigned int idx = 0; idx < numberOfNamespaces; idx++) {
      NSXMLNode *node = [namespaceNodes objectAtIndex:idx];
      [dict setObject:[node stringValue]
               forKey:[node name]];
    }
  }
  return dict;
}

// classOrSurrogateForClass searches this object instance and all parent 
// instances for a user surrogate for the supplied class, and returns 
// the surrogate, or else the supplied class if no surrogate is found for it
- (Class)classOrSurrogateForClass:(Class)standardClass {
  
  for (GDataObject *currentObject = self;
       currentObject != nil;
       currentObject = [currentObject parent]) {
    
    // look for an object with a surrogates dict containing the standardClass
    NSDictionary *currentSurrogates = [currentObject surrogates];
    
    Class surrogate = [currentSurrogates objectForKey:standardClass];
    if (surrogate) return surrogate;
  }
  return standardClass;
}

// The following routines which parse XML elements remove the parsed elements
// from the list of unknowns.

// objectForElementWithNameIfAny:objectClass:objectClass: creates
// a single GDataObject of the specified class for the first XML child element
// with the specified name. Returns nil if no child element is present
//
// If objectClass is nil, the class is looked up from the registrations
// of entry and feed classes.
- (id)objectForChildOfElement:(NSXMLElement *)parentElement
                qualifiedName:(NSString *)qualifiedName
                 namespaceURI:(NSString *)namespaceURI
                  objectClass:(Class)objectClass {
  id object = nil;
  NSXMLElement *element = [self childWithQualifiedName:qualifiedName
                                          namespaceURI:namespaceURI
                                           fromElement:parentElement];
  if (element) {
    
    if (objectClass == nil) {
      // if the object is a feed or an entry, we might be able to determine the
      // type from the XML
      objectClass = [GDataObject objectClassForXMLElement:element];
    }
    
    objectClass = [self classOrSurrogateForClass:objectClass];
    
    object = [[[objectClass alloc] initWithXMLElement:element
                                               parent:self] autorelease];
  }
  return object;
}


// get child elements from an element matching the given name and namespace
// (trying the namespace first, falling back on the fully-qualified name)
- (NSArray *)elementsForName:(NSString *)qualifiedName
                namespaceURI:(NSString *)namespaceURI
               parentElement:(NSXMLElement *)parentElement {

  NSArray *objElements = nil;
  
  if ([namespaceURI length] > 0) {
    
    NSString *localName = [NSXMLNode localNameForName:qualifiedName];
    
    objElements = [parentElement elementsForLocalName:localName
                                                  URI:namespaceURI];
  }

  // if we couldn't find the elements by name, fall back on the fully-qualified
  // name
  if ([objElements count] == 0) {
    
    objElements = [parentElement elementsForName:qualifiedName];
  }
  return objElements;
  
}

// return all child elements of an element which have the given namespace 
// prefix
- (NSMutableArray *)childrenOfElement:(NSXMLElement *)parentElement
                           withPrefix:(NSString *)prefix {
  NSArray *allChildren = [parentElement children];
  NSMutableArray *matchingChildren = [NSMutableArray array];
  NSXMLNode *childNode;
  GDATA_FOREACH(childNode, allChildren) {
    if ([childNode kind] == NSXMLElementKind 
        && [[childNode prefix] isEqual:prefix]) {
      
      [matchingChildren addObject:childNode];
    }
  }
  
  return matchingChildren;
}

// creates an array of GDataObjects of the specified class for each XML
// child element with the specified name
//
// If objectClass is nil, the class is looked up from the registrations
// of entry and feed classes.

- (NSMutableArray *)objectsForChildrenOfElement:(NSXMLElement *)parentElement
                                  qualifiedName:(NSString *)qualifiedName
                                   namespaceURI:(NSString *)namespaceURI
                                    objectClass:(Class)objectClass {
  NSMutableArray *objects = [NSMutableArray array];
  
  NSArray *objElements = nil;
  
  NSString *localName = [NSXMLNode localNameForName:qualifiedName];
  if (![localName isEqual:@"*"]) {
    
    // searching for an actual element name (not a wildcard)
    objElements = [self elementsForName:qualifiedName
                           namespaceURI:namespaceURI
                          parentElement:parentElement];
  }
  
  else {
    // we weren't given a local name, so get all objects for this namespace
    // URI's prefix
    NSString *prefixSought = [NSXMLNode prefixForName:qualifiedName];
    if ([prefixSought length] == 0) {
      prefixSought = [parentElement resolvePrefixForNamespaceURI:namespaceURI];
    }
    
    if (prefixSought) {
      objElements = [self childrenOfElement:parentElement
                                 withPrefix:prefixSought];
    }
  }
  
  // step through all child elements and create an appropriate GData object
  NSXMLElement *objElement;
  GDATA_FOREACH(objElement, objElements) {
    
    Class elementClass = objectClass;
    if (elementClass == nil) {
      // if the object is a feed or an entry, we might be able to determine the
      // type for this element from the XML
      elementClass = [GDataObject objectClassForXMLElement:objElement];
      
      // if a base feed class doesn't specify entry class, and the entry object
      // class can't be determined by examining its XML, fall back on 
      // instantiating the base entry class
      if (elementClass == nil 
        && [qualifiedName isEqual:@"entry"] 
        && [namespaceURI isEqual:kGDataNamespaceAtom]) {
        
        elementClass = [GDataEntryBase class];
      }
    }
    
    elementClass = [self classOrSurrogateForClass:elementClass];

    id obj = [[[elementClass alloc] initWithXMLElement:objElement
                                                parent:self] autorelease];
    if (obj) {
      [objects addObject:obj];
    }
  }
  
  // remove these elements from the unknown list
  [self handleParsedElements:objElements];
  return objects;
}


// childOfElement:withName returns the element with the name, or nil if there 
// are not exactly one of the element.  Pass "*" wildcards for name and URI
// to retrieve the child element if there is exactly one.
- (NSXMLElement *)childWithQualifiedName:(NSString *)qualifiedName
                            namespaceURI:(NSString *)namespaceURI
                             fromElement:(NSXMLElement *)parentElement {
  
  NSArray *elementArray;
  
  if ([qualifiedName isEqual:@"*"] && [namespaceURI isEqual:@"*"]) {
    // wilcards
    elementArray = [parentElement children]; 
  } else {
    // find the element by name and namespace URI
    elementArray = [self elementsForName:qualifiedName
                            namespaceURI:namespaceURI
                           parentElement:parentElement];
  }
  
  NSUInteger numberOfElements = [elementArray count];
  
  if (numberOfElements == 1) {
    NSXMLElement *element = [elementArray objectAtIndex:0];
    
    // remove this element from the unknown list
    [self handleParsedElement:element];
    
    return element;
  }
  
  // We might want to get rid of this assert if there turns out to be
  // legitimate reasons to call this where there are >1 elements available
  GDATA_ASSERT(numberOfElements == 0, @"childWithQualifiedName: could not handle "
               "multiple '%@' elements in list, use elementsForName:\n"
               "Found elements: %@\nURI: %@", qualifiedName, elementArray, 
               namespaceURI);
  return nil;
}

#pragma mark element parsing

- (void)handleParsedElement:(NSXMLNode *)element {
  if (element) {
    [unknownChildren_ removeObject:element];
  }
}

- (void)handleParsedElements:(NSArray *)array {
  if (array) {
    [unknownChildren_ removeObjectsInArray:array];
  }
}

- (NSString *)stringValueFromElement:(NSXMLElement *)element {
  // Originally, this was
  //    NSString *result = [element stringValue];
  // but that recursively descends children to build the string
  // so we'll just walk the remaining nodes and build the string ourselves
  
  if (element == nil) {
    return nil; 
  }
  
  NSMutableString *result = [NSMutableString string];

  // consider all text child nodes used to make this string value to now be known
  NSArray *children = [element children];
  NSXMLNode *childNode;

  GDATA_FOREACH(childNode, children) {
    if ([childNode kind] == NSXMLTextKind) {
      [result appendString:[childNode stringValue]];
      [self handleParsedElement:childNode];
    }
  }
  
  return result;
}

- (GDataDateTime *)dateTimeFromElement:(NSXMLElement *)element {
  NSString *str = [self stringValueFromElement:element];  
  if ([str length]) {
    return [GDataDateTime dateTimeWithRFC3339String:str];
  }
  return nil;
}


- (NSNumber *)intNumberValueFromElement:(NSXMLElement *)element {
  NSString *str = [self stringValueFromElement:element];
  if ([str length] > 0) {
    NSNumber *number = [NSNumber numberWithInt:[str intValue]];
    return number;
  }
  return nil;
}

- (NSNumber *)doubleNumberValueFromElement:(NSXMLElement *)element {
  NSString *str = [self stringValueFromElement:element];
  if ([str length] > 0) {
    NSNumber *number = [NSNumber numberWithDouble:[str doubleValue]];
    return number;
  }
  return nil;
}

#pragma mark attribute parsing

- (void)handleParsedAttribute:(NSXMLNode *)attribute {
  
  if (attribute) {
    [unknownAttributes_ removeObject:attribute];
  }
}

- (NSXMLNode *)attributeForName:(NSString *)attributeName 
                    fromElement:(NSXMLElement *)element {
  
  NSXMLNode* attribute = [element attributeForName:attributeName];
  
  [self handleParsedAttribute:attribute];
  
  return attribute;
}

- (NSXMLNode *)attributeForLocalName:(NSString *)localName
                                 URI:(NSString *)attributeURI
                         fromElement:(NSXMLElement *)element {
  
  NSXMLNode* attribute = [element attributeForLocalName:localName
                                                    URI:attributeURI];
  [self handleParsedAttribute:attribute];

  return attribute;
}

- (NSString *)stringForAttributeLocalName:(NSString *)localName
                                      URI:(NSString *)attributeURI
                              fromElement:(NSXMLElement *)element {
  
  NSXMLNode* attribute = [self attributeForLocalName:localName
                                                 URI:attributeURI
                                         fromElement:element];
  return [attribute stringValue];
}


- (NSString *)stringForAttributeName:(NSString *)attributeName
                         fromElement:(NSXMLElement *)element {
  NSXMLNode* attribute = [self attributeForName:attributeName
                                    fromElement:element];
  return [attribute stringValue];
}

- (GDataDateTime *)dateTimeForAttributeName:(NSString *)attributeName 
                                fromElement:(NSXMLElement *)element {
  
  NSXMLNode* attribute = [self attributeForName:attributeName
                                    fromElement:element];
    
  NSString* str = [attribute stringValue];
  if ([str length]) {
    return [GDataDateTime dateTimeWithRFC3339String:str];
  }
  return nil;
}

- (BOOL)boolForAttributeName:(NSString *)attributeName 
                 fromElement:(NSXMLElement *)element {
  NSXMLNode* attribute = [self attributeForName:attributeName
                                    fromElement:element];
  NSString* str = [attribute stringValue];
  BOOL isTrue = (str && [str caseInsensitiveCompare:@"true"] == NSOrderedSame);
  return isTrue;
}

- (NSNumber *)doubleNumberForAttributeName:(NSString *)attributeName 
                               fromElement:(NSXMLElement *)element {
  NSXMLNode* attribute = [self attributeForName:attributeName
                                    fromElement:element];
  NSString* str = [attribute stringValue];
  if (str) {
    NSNumber *number = [NSNumber numberWithDouble:[str doubleValue]]; 
    return number;
  }
  return nil;
}

- (NSNumber *)intNumberForAttributeName:(NSString *)attributeName 
                            fromElement:(NSXMLElement *)element {
  NSXMLNode* attribute = [self attributeForName:attributeName
                                    fromElement:element];
  NSString* str = [attribute stringValue];
  if (str) {
    NSNumber *number = [NSNumber numberWithInt:[str intValue]]; 
    return number;
  }
  return nil;
}


#pragma mark Extensions

- (void)addExtensionDeclarations {
  // overridden by subclasses which have extensions to add, like:
  // 
  //  [self addExtensionDeclarationForParentClass:[GDataLink class]
  //                                   childClass:[GDataWebContent class]];  
  // and
  //
  //  [self addAttributeExtensionDeclarationForParentClass:[GDataExtendedProperty class]
  //                                            childClass:[GDataExtPropValueAttribute class]];  

}

- (void)addParseDeclarations {
  
  // overridden by subclasses which have local attributes, like:
  // 
  //  [self addLocalAttributeDeclarations:[NSArray arrayWithObject:@"size"]];
  //
  //  Subclasses should add the attributes in the order they most usefully will
  //  appear in the object's -description output (or alternatively they may
  //  override -description).
  //
  // Note: this is only for namespace-less attributes or attributes with the
  // fixed xml: namespace, not for attributes that are qualified with variable
  // prefixes.  Those attributes should be parsed explicitly in 
  // initWithXMLElement: methods, and generated by XMLElement: methods.
}

// subclasses call these to declare possible extensions for themselves and their
// children.
- (void)addExtensionDeclarationForParentClass:(Class)parentClass
                                   childClass:(Class)childClass {
  // add an element extension
  [self addExtensionDeclarationForParentClass:parentClass
                                   childClass:childClass
                                  isAttribute:NO];
}

- (void)addExtensionDeclarationForParentClass:(Class)parentClass
                                 childClasses:(Class)firstChildClass, ... {
  
  // like the method above, but for a list of child classes
  id nextClass;
  va_list argumentList;
  
  if (firstChildClass != nil) {
    [self addExtensionDeclarationForParentClass:parentClass
                                     childClass:firstChildClass
                                    isAttribute:NO];
    
    va_start(argumentList, firstChildClass);
    while ((nextClass = va_arg(argumentList, Class)) != nil) {
      
      [self addExtensionDeclarationForParentClass:parentClass
                                       childClass:nextClass
                                      isAttribute:NO];
    }
    va_end(argumentList);
  }
}

- (void)addAttributeExtensionDeclarationForParentClass:(Class)parentClass
                                   childClass:(Class)childClass {
  // add an attribute extension
  [self addExtensionDeclarationForParentClass:parentClass
                                   childClass:childClass
                                  isAttribute:YES];
}

- (void)addExtensionDeclarationForParentClass:(Class)parentClass
                                   childClass:(Class)childClass
                                  isAttribute:(BOOL)isAttribute {

  if (extensionDeclarations_ == nil) {
    extensionDeclarations_ = [[NSMutableDictionary alloc] init]; 
  }
  
  NSMutableArray *array = [extensionDeclarations_ objectForKey:parentClass];
  if (array == nil) {
    array = [NSMutableArray array];
    [extensionDeclarations_ setObject:array forKey:parentClass];
  }
  
  GDATA_DEBUG_ASSERT([childClass conformsToProtocol:@protocol(GDataExtension)], 
                @"%@ does not conform to GDataExtension protocol", childClass);
  
  GDataExtensionDeclaration *decl = 
    [[[GDataExtensionDeclaration alloc] initWithParentClass:parentClass
                                                 childClass:childClass
                                                isAttribute:isAttribute] autorelease];

  [array addObject:decl];
}

- (void)removeExtensionDeclarationForParentClass:(Class)parentClass
                                      childClass:(Class)childClass {
  GDataExtensionDeclaration *decl = 
    [[[GDataExtensionDeclaration alloc] initWithParentClass:parentClass
                                                 childClass:childClass
                                                isAttribute:NO] autorelease];
  
  NSMutableArray *array = [extensionDeclarations_ objectForKey:parentClass];
  [array removeObject:decl];
}

- (void)removeAttributeExtensionDeclarationForParentClass:(Class)parentClass
                                               childClass:(Class)childClass {
  GDataExtensionDeclaration *decl = 
    [[[GDataExtensionDeclaration alloc] initWithParentClass:parentClass
                                                 childClass:childClass
                                                isAttribute:YES] autorelease];
  
  NSMutableArray *array = [extensionDeclarations_ objectForKey:parentClass];
  [array removeObject:decl];
}

// utility routine for getting declared extensions to the specified class
- (NSArray *)extensionDeclarationsForClass:(Class)parentClass {
  NSMutableArray *array = [extensionDeclarations_ objectForKey:parentClass];
  return array;
}

// objectsForExtensionClass: returns the array of all
// extension objects of the specified class, or nil
- (NSArray *)objectsForExtensionClass:(Class)theClass {
  return [extensions_ objectForKey:theClass];
}

// objectForExtensionClass: returns the first element of the array
// of extension objects of the specified class, or nil
- (id)objectForExtensionClass:(Class)theClass {
  NSArray *array = [extensions_ objectForKey:theClass];
  if ([array count] > 0) {    
    return [array objectAtIndex:0]; 
  }
  return nil;
}

// attributeValueForExtensionClass: returns the value of the first object of 
// the array of attribute extension objects of the specified class, or nil
- (NSString *)attributeValueForExtensionClass:(Class)theClass {
  GDataAttribute *attr = [self objectForExtensionClass:theClass];
  NSString *str = [attr stringValue];
  return str;
}

- (void)setAttributeValue:(NSString *)str forExtensionClass:(Class)theClass {
  GDataAttribute *obj = [theClass attributeWithValue:str];
  [self setObject:obj forExtensionClass:theClass];
}

// generate the qualified name for this extension's element
- (NSString *)qualifiedNameForExtensionClass:(Class)class {
  
  NSString *name;
  
  @synchronized(gQualifiedNameMap) {
    
    name = [gQualifiedNameMap objectForKey:class];
    if (name == nil) {
      
      NSString *extensionURI = [class extensionElementURI];
      
      if (extensionURI == nil || [extensionURI isEqual:kGDataNamespaceAtom]) {
        name = [class extensionElementLocalName];
      } else {
        name = [NSString stringWithFormat:@"%@:%@",
                [class extensionElementPrefix],
                [class extensionElementLocalName]];
      }
      
      [gQualifiedNameMap setObject:name forKey:class];
    }
  }
  return name;
}

// replace all actual extensions of the specified class
- (void)setObjects:(NSArray *)objects forExtensionClass:(Class)class {
  if (extensions_ == nil) {
    extensions_ = [[NSMutableDictionary alloc] init]; 
  }
  
  if (objects) {
    // be sure each object has an element name so we can generate XML for it
    for (unsigned int idx = 0; idx < [objects count]; idx++) {
      GDataObject *obj = [objects objectAtIndex:idx];
      if ([obj isKindOfClass:[GDataObject class]]
          && [[obj elementName] length] == 0) {

        NSString *name = [self qualifiedNameForExtensionClass:class];
        [obj setElementName:name]; 
      }
    }
    
    [extensions_ setObject:objects
                    forKey:class];  
  } else {
    [extensions_ removeObjectForKey:class]; 
  }
}

// replace all actual extensions of the specified class 
- (void)setObject:(id)object forExtensionClass:(Class)class {
  if (object) {
    [self setObjects:[NSMutableArray arrayWithObject:object]
   forExtensionClass:class];
  } else {
    [self setObjects:nil 
   forExtensionClass:class];
  }
}

// add an extension of the specified class
- (void)addObject:(id)object forExtensionClass:(Class)class {
  NSMutableArray *array = [extensions_ objectForKey:class];
  if (array) {
    [array addObject:object]; 
  } else {
    [self setObject:object forExtensionClass:class]; 
  }
}

// remove a known extension of the specified class
- (void)removeObject:(id)object forExtensionClass:(Class)class {
  NSMutableArray *array = [extensions_ objectForKey:class];
  [array removeObject:object]; 
}

// addUnknownChildNodesForElement: is called by initWithXMLElement.  It builds
// the initial list of unknown child elements; this list is whittled down by
// parseExtensionsForElement and objectForChildOfElement.
- (void)addUnknownChildNodesForElement:(NSXMLElement *)element {

  [unknownChildren_ release];
  unknownChildren_ = nil;

  [unknownAttributes_ release];
  unknownAttributes_ = nil;

  if (!shouldIgnoreUnknowns_) {

    NSArray *children = [element children];
    if (children != nil) {
      unknownChildren_ = [[NSMutableArray alloc] initWithArray:children];
    } else {
      unknownChildren_ = [[NSMutableArray alloc] init];
    }

    NSArray *attributes = [element attributes];
    if (attributes != nil) {
      unknownAttributes_ = [[NSMutableArray alloc] initWithArray:attributes];
    } else {
      unknownAttributes_ = [[NSMutableArray alloc] init];
    }
  }
}

// parseExtensionsForElement: is called by initWithXMLElement. It starts
// from the current object and works up the chain of parents, grabbing
// the declared extensions by each GDataObject in the ancestry and looking 
// at the current element to see if any of the declared extensions are present.

- (void)parseExtensionsForElement:(NSXMLElement *)element {
  Class classBeingParsed = [self class];
  
  // For performance, we'll avoid looking up extension elements whose
  // local names aren't present in the element.  We don't bother doing
  // this for attribute extensions since those are so rare (most attributes
  // are parsed just by local declaration in parseAttributesForElement:.)

#if GDATA_USES_LIBXML || MAC_OS_X_VERSION_MIN_REQUIRED >= 1050
  NSArray *childLocalNames = [element valueForKeyPath:@"children.localName"];

  // allow wildcard lookups
  childLocalNames = [childLocalNames arrayByAddingObject:@"*"];
#else
  // Unfortunately, [element valueForKeyPath:@"children.localName"]
  // causes an exception on 10.4/PPC, where children may not
  // be an NSArray but an NSXMLChildren object which doesn't properly
  // handle KVC array operators.
  NSArray *children = [element children];
  NSMutableArray *childLocalNames = [NSMutableArray arrayWithCapacity:[children count]];
  NSXMLNode *child;
  GDATA_FOREACH(child, children) {
    NSString *localName = [child localName];
    if ([localName length] > 0) {
      [childLocalNames addObject:localName];
    }
  }

  // allow wildcard lookups
  [childLocalNames addObject:@"*"];
#endif

  for (GDataObject * currentExtensionSupplier = self;
       currentExtensionSupplier != nil;
       currentExtensionSupplier = [currentExtensionSupplier parent]) {
    
    // find all extensions in this supplier with the current class as the parent
    NSArray *extnDecls = [currentExtensionSupplier extensionDeclarationsForClass:classBeingParsed];
    
    if (extnDecls) {
      GDataExtensionDeclaration *decl;
      GDATA_FOREACH(decl, extnDecls) {
        // if we've not already found this class when parsing at an earlier supplier
        Class extensionClass = [decl childClass];
        if ([extensions_ objectForKey:extensionClass] == nil) {
          
          // if this extension's local name really matches some child's local
          // name (or this is an attribute extension)

          NSString *declLocalName = [extensionClass extensionElementLocalName];
          if ([childLocalNames containsObject:declLocalName] 
              || [decl isAttribute]) {

            GDATA_DEBUG_ASSERT([extensionClass conformsToProtocol:@protocol(GDataExtension)], 
                      @"%@ does not conform to GDataExtension protocol", 
                      extensionClass);
            
            NSString *namespaceURI = [extensionClass extensionElementURI];
            NSString *qualifiedName = [self qualifiedNameForExtensionClass:extensionClass];
            
            NSArray *objects = nil;
            
            if ([decl isAttribute]) {
              // parse for an attribute extension
              NSString *str = [self stringForAttributeName:qualifiedName
                                               fromElement:element];
              if (str) {
                id attr = [[[extensionClass alloc] init] autorelease];
                [attr setStringValue:str];
                objects = [NSArray arrayWithObject:attr];
              }
              
            } else {
              // parse for an element extension
              objects = [self objectsForChildrenOfElement:element
                                            qualifiedName:qualifiedName
                                             namespaceURI:namespaceURI
                                              objectClass:extensionClass];
            }
            
            if ([objects count] > 0) {
              [self setObjects:objects forExtensionClass:extensionClass];
            }
          }
        }
      }
    }
  }
}

#pragma mark Local Attributes 

- (void)addLocalAttributeDeclarations:(NSArray *)attributeLocalNames {

  if (attributeDeclarations_ == nil) {

    // we'll use an array rather than a set because ordering in arrays
    // is deterministic
    attributeDeclarations_ = [[NSMutableArray alloc] init];
  }

#if DEBUG
  // check that no local attributes being declared have a prefix, except for
  // the hardcoded xml: prefix. Namespaced attributes must be parsed and
  // emitted manually, or be declared as GDataAttribute extensions;
  // they cannot be handled as local attributes, since this class makes no
  // attempt to keep track of namespace URIs for local attributes
  NSString *attr;
  GDATA_FOREACH(attr, attributeLocalNames) {
    GDATA_ASSERT([attr rangeOfString:@":"].location == NSNotFound
                 || [attr hasPrefix:@"xml:"],
                 @"invalid namespaced local attribute: %@", attr);
  }
#endif

  [attributeDeclarations_ addObjectsFromArray:attributeLocalNames];
}

// attribute value getters
- (NSString *)stringValueForAttribute:(NSString *)name {
  
  GDATA_DEBUG_ASSERT([attributeDeclarations_ containsObject:name],
            @"%@ getting undeclared attribute: %@", [self class], name);

  return [attributes_ valueForKey:name];
}

- (NSNumber *)intNumberForAttribute:(NSString *)name {
  
  NSString *str = [self stringValueForAttribute:name];
  if ([str length] > 0) {
    NSNumber *number = [NSNumber numberWithInt:[str intValue]];
    return number;
  }
  return nil;
}

- (NSNumber *)doubleNumberForAttribute:(NSString *)name {
  
  NSString *str = [self stringValueForAttribute:name];
  if ([str length] > 0) {
    NSNumber *number = [NSNumber numberWithDouble:[str doubleValue]];
    return number;
  }
  return nil;
}

- (NSNumber *)longLongNumberForAttribute:(NSString *)name {
  
  NSString *str = [self stringValueForAttribute:name];
  if (str) {
    // when we can assume 10.5 or later, change this to use
    // NSString's -longLongValue
    long long val;
    NSScanner *scanner = [NSScanner scannerWithString:str];
    
    if ([scanner scanLongLong:&val]) {
      NSNumber *number = [NSNumber numberWithLongLong:val];
      return number;
    }
  }
  return nil;
  
}

- (NSDecimalNumber *)decimalNumberForAttribute:(NSString *)name { 
  
  NSString *str = [self stringValueForAttribute:name];
  if ([str length] > 0) {
    
    // require periods as the separator
    //
    // Leopard requires that we use an NSLocale object instead of explicitly 
    // setting NSDecimalSeparator in a dictionary.
    
    NSLocale *usLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:str
                                    locale:(id)usLocale]; // cast for 10.4
    return number;
  }
  return nil;
}

- (GDataDateTime *)dateTimeForAttribute:(NSString *)name  {
  
  NSString *str = [self stringValueForAttribute:name];
  if ([str length] > 0) {
    GDataDateTime *dateTime = [GDataDateTime dateTimeWithRFC3339String:str];
    return dateTime;
  }
  return nil;
}

- (BOOL)boolValueForAttribute:(NSString *)name defaultValue:(BOOL)defaultVal {
  NSString *str = [self stringValueForAttribute:name];
  BOOL isTrue;
  
  if (defaultVal) {
    // default to true, so true if attribute is missing or is not "false"
    isTrue = (str == nil
              || [str caseInsensitiveCompare:@"false"] != NSOrderedSame);
  } else {
    // default to false, so true only if attribute is present and "true"
    isTrue = (str != nil 
              && [str caseInsensitiveCompare:@"true"] == NSOrderedSame);
  }
  return isTrue; 
}

// attribute value setters
- (void)setStringValue:(NSString *)str forAttribute:(NSString *)name {
  
  GDATA_DEBUG_ASSERT([attributeDeclarations_ containsObject:name],
            @"%@ setting undeclared attribute: %@", [self class], name);
  
  if (attributes_ == nil) {
    attributes_ = [[NSMutableDictionary alloc] init]; 
  }
  
  [attributes_ setValue:str forKey:name];
}

- (void)setBoolValue:(BOOL)boolValue defaultValue:(BOOL)defaultVal forAttribute:(NSString *)name {
  NSString *str;
  if (defaultVal) {
    // default to true, so include attribute only if false
    str = (boolValue ? nil : @"false");
  } else {
    // default to false, so include attribute only if true
    str = (boolValue ? @"true" : nil);
  }
  [self setStringValue:str forAttribute:name];
}

- (void)setDecimalNumberValue:(NSDecimalNumber *)num forAttribute:(NSString *)name {
  
  // for most NSNumbers, just calling -stringValue is fine, but for decimal
  // numbers we want to specify that a period be the separator
  // 
  // Leopard requires that we use an NSLocale object instead of explicitly 
  // setting NSDecimalSeparator in a dictionary.
  
  NSLocale *usLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
  
  NSString *str = [num descriptionWithLocale:(id)usLocale]; // cast for 10.4
  [self setStringValue:str forAttribute:name];
}

- (void)setDateTimeValue:(GDataDateTime *)cdate forAttribute:(NSString *)name {
  NSString *str = [cdate RFC3339String];
  [self setStringValue:str forAttribute:name];
}


// parseAttributesForElement: is called by initWithXMLElement. 
// It stores the value of all declared & present attributes in the dictionary
- (void)parseAttributesForElement:(NSXMLElement *)element {

  // for better performance, look up the values for declared attributes only
  // if they are really present in the node
  NSArray *attributes = [element attributes];
  NSXMLNode *attribute;

  GDATA_FOREACH(attribute, attributes) {
    
    NSString *attrName = [attribute name];
    if ([attributeDeclarations_ containsObject:attrName]) {
      
      NSString *str = [attribute stringValue];
      if (str != nil) {
        [self setStringValue:str forAttribute:attrName];
      }
      
      [self handleParsedAttribute:attribute];
    } 
  }
}

// XML generator for local attributes
- (void)addAttributesToElement:(NSXMLElement *)element {
  
  NSString *name;
  NSEnumerator *enumerator = [attributes_ keyEnumerator];
  while ((name = [enumerator nextObject]) != nil) {
    
    NSString *value = [attributes_ valueForKey:name];
    if (value != nil) {
      [self addToElement:element attributeValueIfNonNil:value withName:name];
    }
  }
}

// attribute comparison: subclasses may implement attributesIgnoredForEquality:
// to specify attributes not to be considered for equality comparison

- (BOOL)hasAttributesEqualToAttributesOf:(GDataObject *)other {
  
  NSArray *attributesToIgnore = [self attributesIgnoredForEquality];
  
  if (attributesToIgnore != nil) {
    
    // make a list of declared attributes minus the ones being excluded
    NSMutableArray *filteredAttrDecls 
      = [NSMutableArray arrayWithArray:attributeDeclarations_];
    
    [filteredAttrDecls removeObjectsInArray:attributesToIgnore];
    
    // compare values for all other declared attributes
    NSArray *selfValues = [[self attributes] objectsForKeys:filteredAttrDecls
                                             notFoundMarker:[NSNull null]];
    NSArray *otherValues = [[other attributes] objectsForKeys:filteredAttrDecls
                                               notFoundMarker:[NSNull null]];

    return AreEqualOrBothNil(selfValues, otherValues);
  } 
  
  return AreEqualOrBothNil([self attributes], [other attributes]);
}

- (NSArray *)attributesIgnoredForEquality {
  // subclasses may override this to specify attributes that should
  // not be considered when comparing objects for equality
  return nil; 
}
  
#pragma mark Content Value

- (void)addContentValueDeclaration {
  // derived classes should call this if they want the element's content
  // to be automatically parsed as a string
  shouldParseContentValue_ = YES;
}

- (void)setContentStringValue:(NSString *)str {
  
  GDATA_ASSERT(shouldParseContentValue_, @"%@ setting undeclared content value",
               [self class]);

  [contentValue_ autorelease];
  contentValue_ = [str copy];
}

- (NSString *)contentStringValue {
  
  GDATA_ASSERT(shouldParseContentValue_, @"%@ getting undeclared content value",
               [self class]);

  return contentValue_;
}

// parseContentForElement: is called by initWithXMLElement. 
// This stores the content value parsed from the element.
- (void)parseContentValueForElement:(NSXMLElement *)element {
  
  if (shouldParseContentValue_) {
    [self setContentStringValue:[self stringValueFromElement:element]];
  }
}

// XML generator for content
- (void)addContentValueToElement:(NSXMLElement *)element {
  
  if (shouldParseContentValue_) {
    NSString *str = [self contentStringValue];
    if ([str length] > 0) {
      [element addStringValue:str]; 
    }
  }
}

- (BOOL)hasContentValueEqualToContentValueOf:(GDataObject *)other {
  
  if (!shouldParseContentValue_) {
    // no content being stored
    return YES;
  }
  
  return AreEqualOrBothNil([self contentStringValue], [other contentStringValue]);
}

#pragma mark Child XML Elements

- (void)addChildXMLElementsDeclaration {
  // derived classes should call this if they want the element's unparsed
  // XML children to be accessible later
  shouldKeepChildXMLElements_ = YES;
}

- (NSArray *)childXMLElements {
  if ([childXMLElements_ count] == 0) {
    return nil;
  }
  return childXMLElements_;
}

- (void)setChildXMLElements:(NSArray *)array {
  GDATA_DEBUG_ASSERT(shouldKeepChildXMLElements_,
                     @"%@ setting undeclared XML values", [self class]);

  [childXMLElements_ release];
  childXMLElements_ = [array mutableCopy];
}

- (void)addChildXMLElement:(NSXMLNode *)node {
  GDATA_DEBUG_ASSERT(shouldKeepChildXMLElements_,
                     @"%@ adding undeclared XML values", [self class]);

  if (childXMLElements_ == nil) {
    childXMLElements_ = [[NSMutableArray alloc] init];
  }
  [childXMLElements_ addObject:node];
}

// keepChildXMLElementsForElement: is called by initWithXMLElement.
// This stores a copy of the element's child XMLElements.
- (void)keepChildXMLElementsForElement:(NSXMLElement *)element {

  if (shouldKeepChildXMLElements_) {

    NSArray *children = [element children];
    if (children != nil) {

      // save only top-level nodes that are elements
      NSXMLNode *childNode;

      GDATA_FOREACH(childNode, children) {
        if ([childNode kind] == NSXMLElementKind) {
          if (childXMLElements_ == nil) {
            childXMLElements_ = [[NSMutableArray alloc] init];
          }
          [childXMLElements_ addObject:[childNode copy]];

          [self handleParsedElement:childNode];
        }
      }
    }
  }
}

// XML generator for kept child XML elements
- (void)addChildXMLElementsToElement:(NSXMLElement *)element {

  if (shouldKeepChildXMLElements_) {

    NSArray *childXMLElements = [self childXMLElements];
    if (childXMLElements != nil) {

      NSXMLNode *child;
      GDATA_FOREACH(child, childXMLElements) {
        [element addChild:child];
      }
    }
  }
}

- (BOOL)hasChildXMLElementsEqualToChildXMLElementsOf:(GDataObject *)other {

  if (!shouldKeepChildXMLElements_) {
    // no values being stored
    return YES;
  }
  return AreEqualOrBothNil([self childXMLElements], [other childXMLElements]);
}

#pragma mark Dynamic GDataObject 

// Dynamic object generation is used when the class being created is nil.
//
// These maps are populated by +load routines in feeds and entries.
// They specify category elements which identify the class of feed or entry
// to be created for a blob of XML.

static NSMutableDictionary *gFeedClassCategoryMap = nil;
static NSMutableDictionary *gEntryClassCategoryMap = nil;

static NSString *const kCategoryTemplate = @"{\"%@\":\"%@\"}";


// registerClass:inMap:forCategoryWithScheme:term: does the work for
// registerFeedClass: and registerEntryClass: below
//
// This adds the class to the {"scheme":"term"} map, ensuring
// that it won't conflict with a previous class or category
// entry

+ (void)registerClass:(Class)theClass
                inMap:(NSMutableDictionary **)map
forCategoryWithScheme:(NSString *)scheme 
                 term:(NSString *)term {
  
  // there's no autorelease pool in place at +load time, so we'll create our own
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  if (*map == nil) {
    *map = GDataCreateStaticDictionary();
  }
  
  // ensure this is a unique registration
  GDATA_ASSERT(nil == [gFeedClassCategoryMap objectForKey:theClass],
               @"%@ already registered", theClass);
  Class prevClass = [self classForCategoryWithScheme:scheme 
                                                term:term
                                             fromMap:*map];
  GDATA_ASSERT(prevClass == nil, @"%@ registration conflicts with %@", 
               theClass, prevClass);
  
  // we have a map from the key "scheme:term" to the class
  //
  // generally, scheme will be nil or kGDataCategoryScheme, so we'll
  // use just the term as the key for those categories, avoiding
  // the need to format a string when looking up
  
  NSString *key;
  if (scheme == nil || [scheme isEqual:kGDataCategoryScheme]) {
    key = term;
  } else {
    key = [NSString stringWithFormat:kCategoryTemplate, 
           scheme, term ? term : @""];  
  }
  
  [*map setValue:theClass forKey:key];
  
  [pool release];
}

+ (void)registerFeedClass:(Class)theClass
    forCategoryWithScheme:(NSString *)scheme 
                term:(NSString *)term {
  [self registerClass:theClass
                inMap:&gFeedClassCategoryMap
forCategoryWithScheme:scheme
                 term:term];
}

+ (void)registerEntryClass:(Class)theClass
    forCategoryWithScheme:(NSString *)scheme 
                     term:(NSString *)term {
  [self registerClass:theClass
                inMap:&gEntryClassCategoryMap
forCategoryWithScheme:scheme
                 term:term];
}

// classForCategoryWithScheme does the work for feedClassForCategory
// and entryClassForCategory below.  This method searches the entry 
// or feed map for a class with a matching category.  
//
// If the registration of the class specified a value, then the corresponding
// parameter values |scheme| or |term| must match and not be nil.
+ (Class)classForCategoryWithScheme:(NSString *)scheme
                               term:(NSString *)term
                            fromMap:(NSDictionary *)map {
  
  // |scheme| and |term| are from the XML that we're using to look up
  // a registered class.  The parameters should be non-nil,
  // though the values stored in the map may have nil scheme or term.
  //
  // if the registered scheme was nil or kGDataCategoryScheme then the key
  // is just the term value.

  NSString *key = term;
  Class class = [map objectForKey:key];
  if (class) return class;
  
  key = [NSString stringWithFormat:kCategoryTemplate, scheme, term];
  class = [map objectForKey:key];
  if (class) return class;
  
  key = [NSString stringWithFormat:kCategoryTemplate, scheme, @""];
  class = [map objectForKey:key];
  if (class) return class;
  
  return nil;
}

+ (Class)feedClassForCategoryWithScheme:(NSString *)scheme
                                   term:(NSString *)term {
  return [self classForCategoryWithScheme:scheme
                                     term:term
                                  fromMap:gFeedClassCategoryMap];
}

+ (Class)entryClassForCategoryWithScheme:(NSString *)scheme
                                    term:(NSString *)term {
  return [self classForCategoryWithScheme:scheme
                                     term:term
                                  fromMap:gEntryClassCategoryMap];
}

// objectClassForXMLElement: returns a found registered feed
// or entry class for the XML according to its contained category
//
// If no registered class is found with a matching category,
// this returns GDataFeedBase for feed elements, GDataEntryBase
// for entry elements.
+ (Class)objectClassForXMLElement:(NSXMLElement *)element {
  
  Class result;
  NSString *elementName = [element localName];
  BOOL isFeed = [elementName isEqual:@"feed"];
  
  if (isFeed) {
    
    // default to returning a feed base class
    result = [GDataFeedBase class];
    
  } else if ([elementName isEqual:@"entry"]) {
    
    // default to returning an entry base class
    result = [GDataEntryBase class];

  } else {
    // we look only at feed and entry elements, and this is
    // some other kind of element
    return nil; 
  }
  
  // category elements look like <category scheme="blah" term="blahblah"/>
  // and there may be more than one
  //
  // ? For feed elements, if there's no category, should we look into
  // the entry elements for a category?  Some calendar feeds have
  // lacked feed-level categories.

  // step through the category elements, looking for one that matches
  // a registered feed or entry class
  
  NSArray *categories = [element elementsForLocalName:@"category"
                                                  URI:kGDataNamespaceAtom];
  if ([categories count] == 0) {
    NSString *atomPrefix = [element resolvePrefixForNamespaceURI:kGDataNamespaceAtom];
    if ([atomPrefix length] == 0) {
      categories = [element elementsForName:@"category"];
    }
  }

  NSXMLElement *categoryNode;
  GDATA_FOREACH(categoryNode, categories) {
    
    NSString *scheme = [[categoryNode attributeForName:@"scheme"] stringValue];
    NSString *term = [[categoryNode attributeForName:@"term"] stringValue];
    
    if (scheme || term) {

      // we have a scheme or a term, so look for a registered class
      Class foundClass = nil;
      if (isFeed) {
        foundClass = [GDataObject feedClassForCategoryWithScheme:scheme 
                                                        term:term];
      } else {
        foundClass = [GDataObject entryClassForCategoryWithScheme:scheme 
                                                         term:term];
      }
      if (foundClass) {
        result = foundClass;
        break;
      }
    }
  }
  
  return result;
}

@end

@implementation NSXMLElement (GDataObjectExtensions)

- (void)addStringValue:(NSString *)str {
  // NSXMLNode's setStringValue: wipes out other children, so we'll use this
  // instead
  
  // filter out non-whitespace control characters
  NSString *filtered = [GDataUtilities stringWithControlsFilteredForString:str];
    
  NSXMLNode *strNode = [NSXMLNode textWithStringValue:filtered];
  [self addChild:strNode];
}

+ (id)elementWithName:(NSString *)name attributeName:(NSString *)attrName attributeValue:(NSString *)attrValue {
  
  NSString *filtered = [GDataUtilities stringWithControlsFilteredForString:attrValue];
  
  NSXMLNode *attr = [NSXMLNode attributeWithName:attrName stringValue:filtered];
  NSXMLElement *element = [NSXMLNode elementWithName:name];
  [element addAttribute:attr];
  return element;  
}

@end

@implementation GDataExtensionDeclaration

- (id)initWithParentClass:(Class)parentClass 
               childClass:(Class)childClass
              isAttribute:(BOOL)isAttribute {
  self = [super init];
  if (self) {
    parentClass_ = parentClass; 
    childClass_ = childClass;
    isAttribute_ = isAttribute;
  }
  return self;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@: {%@ can contain %@}%@", 
    [self class], parentClass_, childClass_,
          isAttribute_ ? @" (attribute)" : @""];
}

- (Class)parentClass {
  return parentClass_;  
}

- (Class)childClass {
  return childClass_; 
}

- (BOOL)isAttribute {
  return isAttribute_; 
}

- (BOOL)isEqual:(GDataExtensionDeclaration *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataExtensionDeclaration class]]) return NO;
  
  return AreEqualOrBothNil([self parentClass], [other parentClass])
    && AreEqualOrBothNil([self childClass], [other childClass])
    && [self isAttribute] == [other isAttribute];
}  

- (NSUInteger)hash {
  return (NSUInteger) (void *) [GDataExtensionDeclaration class];
}

@end

@implementation GDataAttribute 

// This is the base class for attribute extensions.
//
// Functionally, this just stores a string value for the attribute.

+ (GDataAttribute *)attributeWithValue:(NSString *)str {
  return [[[self alloc] initWithValue:str] autorelease]; 
}

- (id)initWithValue:(NSString *)value {
  self = [super init];
  if (self) {
    [self setStringValue:value]; 
  }
  return self;
}

- (void)dealloc {
  [value_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataAttribute* newObj = [[[self class] allocWithZone:zone] init];
  [newObj setStringValue:[self stringValue]];
  return newObj;
}

- (NSString *)description {
  
  NSString *name;
  
  NSString *localName = [[self class] extensionElementLocalName];
  NSString *prefix = [[self class] extensionElementPrefix];
  if (prefix) {
    name = [NSString stringWithFormat:@"%@:%@", prefix, localName];
  } else {        
    name = localName;
  } 
  
  return [NSString stringWithFormat:@"%@ 0x%lX: {%@=%@}", 
          [self class], self, name, [self stringValue]];
}

- (BOOL)isEqual:(GDataAttribute *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataAttribute class]]) return NO;
  
  return AreEqualOrBothNil([self stringValue], [other stringValue]);
}  

- (NSUInteger)hash {
  return (NSUInteger) (void *) [GDataAttribute class];
}

- (void)setStringValue:(NSString *)str {
  [value_ autorelease];
  value_ = [str copy];
}

- (NSString *)stringValue {
  return value_; 
}

@end
