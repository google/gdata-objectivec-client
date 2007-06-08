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

// Elements may call -addExtensionDeclarationForParentClass:childClass: to
// declare extensions to be parsed; the declaration applies in
// the element and all children of the element.
@interface GDataExtensionDeclaration : NSObject {
  Class parentClass_;
  Class childClass_;
}
- (id)initWithParentClass:(Class)parentClass childClass:(Class)childClass;
- (Class)parentClass;
- (Class)childClass;
@end

@interface GDataObject (PrivateMethods) 

// all extensions actually found in the XML element
- (void)setExtensions:(NSDictionary *)extensions;
- (NSDictionary *)extensions;

// array of extensions that may be found in this class and in 
// subclasses of this class
- (void)setExtensionDeclarations:(NSArray *)decls;
- (NSArray *)extensionDeclarations;

- (void)initUnknownChildNodesForElement:(NSXMLElement *)element;

- (void)parseExtensionsForElement:(NSXMLElement *)element;

- (NSString *)qualifiedNameForExtensionClass:(Class)class;

- (NSDictionary *)dictionaryForElementNamespaces:(NSXMLElement *)element;

+ (Class)classForCategoryWithScheme:(NSString *)scheme
                               term:(NSString *)term
                            fromMap:(NSDictionary *)map;  
@end

@implementation GDataObject

- (id)init {
  self = [super init];
  if (self) {
    [self initExtensionDeclarations];
  }
  return self;
}

// subclasses will typically override initWithXMLElement:parent:
// and do their own parsing after this method returns
- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super init];
  if (self) {
    [self setParent:parent];
    [self setNamespaces:[self dictionaryForElementNamespaces:element]];
    [self initUnknownChildNodesForElement:element];
    [self initExtensionDeclarations];
    [self parseExtensionsForElement:element];
    [self setElementName:[element name]];
  }
  return self;
}

- (BOOL)isEqual:(GDataObject *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataObject class]]) return NO;

  NSString *localName = [NSXMLNode localNameForName:[self elementName]];
  NSString *otherLocalName = [NSXMLNode localNameForName:[other elementName]];
  
  return AreEqualOrBothNil(localName, otherLocalName) 
    && AreEqualOrBothNil([self extensions], [other extensions])
    && AreEqualOrBothNil([self namespaces], [other namespaces]);
  
  // What we're not comparing here:
  //   parent object pointers
  //   extension declarations
  //   unknown attributes & children
  //   userData
}

- (id)copyWithZone:(NSZone *)zone {
  GDataObject* newObject = [[[self class] allocWithZone:zone] init];
  [newObject setElementName:elementName_];
  [newObject setParent:nil];
  [newObject setNamespaces:namespaces_];

  [newObject setExtensions:extensions_];
  [newObject setExtensionDeclarations:extensionDeclarations_];
  [newObject setUnknownChildren:unknownChildren_];
  [newObject setUnknownAttributes:unknownAttributes_];
  return newObject;
  
  // What we're not copying:
  //   userData
  //   parent object pointers
}

- (void)dealloc {
  [elementName_ release];
  [namespaces_ release];
  [extensionDeclarations_ release];
  [extensions_ release];
  [unknownChildren_ release];
  [unknownAttributes_ release];
  [userData_ release];
  [super dealloc]; 
}

// XMLElement must be implemented by subclasses
- (NSXMLElement *)XMLElement {
  // subclass must implement, starting with 
  // calling [super XMLElementWithExtensionsAndDefaultName:]
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}  

- (NSXMLDocument *)XMLDocument {
  NSXMLElement *element = [self XMLElement];
  NSXMLDocument *doc = [[[NSXMLDocument alloc] initWithRootElement:element] autorelease];
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

- (void)setParent:(GDataObject *)obj {
  parent_ = obj; // parent_ is a weak (not retained) reference
}

- (GDataObject *)parent {
  return parent_; 
}

- (void)setExtensions:(NSDictionary *)extensions {
  [extensions_ autorelease];
  extensions_ = [extensions mutableCopy];
}

- (NSDictionary *)extensions {
  return extensions_; 
}

- (void)setExtensionDeclarations:(NSArray *)decls {
  [extensionDeclarations_ autorelease];
  extensionDeclarations_ = [decls mutableCopy];
}

- (NSArray *)extensionDeclarations {
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

- (void)setUserData:(id)userData {
  [userData_ autorelease];
  userData_ = [userData retain];
}

- (id)userData {
  // be sure the returned pointer has the life of the autorelease pool,
  // in case self is released immediately
  return [[userData_ retain] autorelease];
}

#pragma mark XML generation helpers

- (void)addNamespacesToElement:(NSXMLElement *)element {

  // we keep namespaces in a dictionary with prefixes
  // as keys.  We'll step through our namespaces and convert them
  // to NSXML-stype namespaces.
  
  unsigned int numberOfNamespaces = [namespaces_ count];
  if (numberOfNamespaces) {
    
    NSArray *namespaceNames = [namespaces_ allKeys];
    for (unsigned int idx = 0; idx < numberOfNamespaces; idx++) {
      NSString *name = [namespaceNames objectAtIndex:idx];
      NSString *uri = [namespaces_ objectForKey:name];
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
    for (int idx = 0; idx < [classKeys count]; idx++) {
      
      Class oneClass = [classKeys objectAtIndex:idx];
      
      NSArray *objects = [self objectsForExtensionClass:oneClass];
      
      [self addToElement:element XMLElementsForArray:objects];
    }
  }
}

- (void)addUnknownChildNodesToElement:(NSXMLElement *)element {
  
  // we'll add every element and attribute as "unknown", then remove them
  // from this list as we parse them to create the GData object. Anything
  // left remaining in this list is considered unknown.
  
  // we have to copy the children so they don't point at the previous parent
  // nodes
  for (int idx = 0; idx < [unknownChildren_ count]; idx++) {
    NSXMLNode *child = [unknownChildren_ objectAtIndex:idx];
    [element addChild:[[child copy] autorelease]];
  }
  
  for (int idx = 0; idx < [unknownAttributes_ count]; idx++) {
    NSXMLNode *attr = [unknownAttributes_ objectAtIndex:idx];
    NSAssert1([element attributeForName:[attr name]] == nil,
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
- (NSXMLElement *)XMLElementWithExtensionsAndDefaultName:(NSString *)defaultName {
  
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
#if DEBUG
        NSLog(@"GDataObject generating XML element with unknown name for class %@",
              elementName);
#endif
      }
    }
  }
  
  NSXMLElement *element = [NSXMLNode elementWithName:elementName];
  [self addNamespacesToElement:element];
  [self addExtensionsToElement:element];
  [self addUnknownChildNodesToElement:element];
  return element;
}

- (NSXMLNode *)addToElement:(NSXMLElement *)element
     attributeValueIfNonNil:(NSString *)val
                   withName:(NSString *)name {
  if (val) {
    NSXMLNode* attr = [NSXMLNode attributeWithName:name stringValue:val];
    [element addAttribute:attr];
    return attr;
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
  
  NSEnumerator *enumerator = [arrayOfGDataObjects objectEnumerator];
  GDataObject* item;
  while ((item = [enumerator nextObject]) != nil) {
    NSXMLElement *child = [item XMLElement];
    if (child) {
      [element addChild:child];
    }
  }
}

#pragma mark description method helpers

- (void)addToArray:(NSMutableArray *)stringItems
objectDescriptionIfNonNil:(id)obj
          withName:(NSString *)name {

  if (obj) {
    [stringItems addObject:[NSString stringWithFormat:@"%@:%@", name, obj]];
  }
}

- (void)addToArray:(NSMutableArray *)stringItems
      integerValue:(int)val
          withName:(NSString *)name {
  [stringItems addObject:[NSString stringWithFormat:@"%@:%d", name, val]];
}

- (void)addToArray:(NSMutableArray *)stringItems
      arrayCountIfNonEmpty:(NSArray *)array
          withName:(NSString *)name {
  if ([array count]) {
    [self addToArray:stringItems integerValue:[array count] withName:name];
  }
}


#pragma mark XML parsing helpers

- (NSDictionary *)dictionaryForElementNamespaces:(NSXMLElement *)element {
  
  NSMutableDictionary *dict = nil;
  
  // for each namespace node, add a dictionary entry with the namespace
  // name (prefix) as key and the URI as value
  //
  // note: the prefix may be an empty string
  
  NSArray *namespaceNodes = [element namespaces];
  unsigned int numberOfNamespaces = [namespaceNodes count];
  
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
  
    for (int idx = 0; idx < [allChildren count]; idx++) {
    
    NSXMLNode *childNode = [allChildren objectAtIndex:idx];
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
  
  // step through all chid elements and create an appropriate GData object
  NSEnumerator *objEnumerator = [objElements objectEnumerator];
  NSXMLElement *objElement;
  
  while ((objElement = [objEnumerator nextObject]) != nil) {
    
    if (objectClass == nil) {
      // if the object is a feed or an entry, we might be able to determine the
      // type from the XML
      objectClass = [GDataObject objectClassForXMLElement:objElement];
    }
    
    id obj = [[[objectClass alloc] initWithXMLElement:objElement
                                               parent:self] autorelease];
    if (obj) {
      [objects addObject:obj];
    }
  }
  
  // remove these elements from the unknown list
  [unknownChildren_ removeObjectsInArray:objElements];
  return objects;
}


// childOfElement:withName returns the element with the name, or nil if there 
// are not exactly one of the element
- (NSXMLElement *)childWithQualifiedName:(NSString *)qualifiedName
                            namespaceURI:(NSString *)namespaceURI
                             fromElement:(NSXMLElement *)parentElement {
  
  NSArray *elementArray = [self elementsForName:qualifiedName
                                   namespaceURI:namespaceURI
                                  parentElement:parentElement];
  
  unsigned int numberOfElements = [elementArray count];
  
  if (numberOfElements == 1) {
    NSXMLElement *element = [elementArray objectAtIndex:0];
    
    // remove this element from the unknown list
    [unknownChildren_ removeObject:element];
    
    return element;
  }
  
  // We might want to get rid of this assert if there turns out to be
  // leg reasons to call this where there are >1 elements available
  NSAssert1(numberOfElements == 0, @"childWithName: could not handle multiple '%@'"
            " elements in list, use elementsForName:", qualifiedName);
  return nil;
}

#pragma mark element parsing

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
  for (int idx = 0; idx < [children count]; idx++) {
    NSXMLNode *childNode = [children objectAtIndex:idx];
    
    if ([childNode kind] == NSXMLTextKind) {
      [result appendString:[childNode stringValue]];
      [unknownChildren_ removeObject:childNode];
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

- (NSXMLNode *)attributeForName:(NSString *)attributeName 
                    fromElement:(NSXMLElement *)element {
  
  NSXMLNode* attribute = [element attributeForName:attributeName];
  
  if (attribute) {
    [unknownAttributes_ removeObject:attribute];
  }
  return attribute;
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

- (NSDecimalNumber *)decimalNumberForAttributeName:(NSString *)attributeName 
                                       fromElement:(NSXMLElement *)element {
  NSXMLNode* attribute = [self attributeForName:attributeName
                                    fromElement:element];
  NSString* str = [attribute stringValue];
  if (str) {
    // require periods as the separator
    NSDictionary *locale = [NSDictionary dictionaryWithObject:@"."
                                                       forKey:NSDecimalSeparator];
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:str
                                                                locale:locale];
    return number;
  }
  return nil;
}

- (NSNumber *)longLongNumberForAttributeName:(NSString *)attributeName 
                                 fromElement:(NSXMLElement *)element {
  NSXMLNode* attribute = [self attributeForName:attributeName
                                    fromElement:element];
  NSString* str = [attribute stringValue];
  if (str) {
    long long val;
    NSScanner *scanner = [NSScanner scannerWithString:str];
    
    if ([scanner scanLongLong:&val]) {
      NSNumber *number = [NSNumber numberWithLongLong:val]; 
      return number;
    }
  }
  return nil;
}

- (NSNumber *)boolNumberForAttributeName:(NSString *)attributeName 
                             fromElement:(NSXMLElement *)element {
  NSXMLNode* attribute = [self attributeForName:attributeName
                                    fromElement:element];
  NSString* str = [attribute stringValue];
  if (str) {
    BOOL flag = (str && [str caseInsensitiveCompare:@"true"] == NSOrderedSame);
    NSNumber *number = [NSNumber numberWithBool:flag]; 
    return number;
  }
  return nil;  
}


#pragma mark Extensions

- (void)initExtensionDeclarations {
  // overridden by subclasses which have extensions to add, like:
  // 
  //  [self addExtensionDeclarationForParentClass:[GDataLink class]
  //                                   childClass:[GDataWebContent class]];  

}

// subclasses call this to declare possible extensions for themselves and their
// children.
- (void)addExtensionDeclarationForParentClass:(Class)parentClass
                                   childClass:(Class)childClass {
  if (extensionDeclarations_ == nil) {
    extensionDeclarations_ = [[NSMutableArray alloc] init]; 
  }
  
  NSAssert1([childClass conformsToProtocol:@protocol(GDataExtension)], 
                @"%@ does not conform to GDataExtension protocol", childClass);
  
  GDataExtensionDeclaration *decl = 
    [[[GDataExtensionDeclaration alloc] initWithParentClass:parentClass
                                                 childClass:childClass] autorelease];
  
  [extensionDeclarations_ addObject:decl];
}

// utility routine for getting declared extensions to the specified class
- (NSArray *)extensionDeclarationsForClass:(Class)parentClass {
  unsigned int numberOfDecls = [extensionDeclarations_ count];
  if (numberOfDecls == 0) return nil;
  
  NSMutableArray *decls = [NSMutableArray array];
  
  for (int idx = 0; idx < [extensionDeclarations_ count]; idx++) {
    GDataExtensionDeclaration *decl = [extensionDeclarations_ objectAtIndex:idx];
    if ([decl parentClass] == parentClass) {
      [decls addObject:decl];
    }
  }
  return decls;
}

// objectsForExtensionClass: returns the array of all
// extension objects of the specified class, or nil
- (NSArray *)objectsForExtensionClass:(Class)class {
  return [extensions_ objectForKey:class];
}

// objectForExtensionClass: returns the first element of the array
// of extension objects of the specified class, or nil
- (id)objectForExtensionClass:(Class)class {
  NSArray *array = [extensions_ objectForKey:class];
  if ([array count] > 0) {    
    return [array objectAtIndex:0]; 
  }
  return nil;
}

// generate the qualified name for this extension's element
- (NSString *)qualifiedNameForExtensionClass:(Class)class {
  NSString *name;
  
  if ([[class extensionElementURI] isEqual:kGDataNamespaceAtom]) {
    name = [class extensionElementLocalName];
  } else {
    name = [NSString stringWithFormat:@"%@:%@",
      [class extensionElementPrefix],
      [class extensionElementLocalName]];
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
      if ([[obj elementName] length] == 0) {

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
- (void)setObject:(GDataObject *)object forExtensionClass:(Class)class {
  if (object) {
    [self setObjects:[NSMutableArray arrayWithObject:object]
   forExtensionClass:class];
  } else {
    [self setObjects:nil 
   forExtensionClass:class];
  }
}

// add an extension of the specified class
- (void)addObject:(GDataObject *)object forExtensionClass:(Class)class {
  NSMutableArray *array = [extensions_ objectForKey:class];
  if (array) {
    [array addObject:object]; 
  } else {
    [self setObject:object forExtensionClass:class]; 
  }
}

// remove a known extension of the specified class
- (void)removeObject:(GDataObject *)object forExtensionClass:(Class)class {
  NSMutableArray *array = [extensions_ objectForKey:class];
  if ([array containsObject:object]) {
    [array removeObject:object]; 
  } 
}

// initUnknownChildNodesForElement: is called by initWithXMLElement.  It builds
// the initial list of unknown child elements; this list is whittled down by
// parseExtensionsForElement and objectForChildOfElement.
- (void)initUnknownChildNodesForElement:(NSXMLElement *)element {
  
  [unknownChildren_ release];
  unknownChildren_ = [[NSMutableArray alloc] init];
  if ([element childCount]) {
    [unknownChildren_ addObjectsFromArray:[element children]];
  }
  
  [unknownAttributes_ release];
  unknownAttributes_ = [[NSMutableArray alloc] init];
  if ([[element attributes] count]) {
    [unknownAttributes_ addObjectsFromArray:[element attributes]];
  }
}

// parseExtensionsForElement: is called by initWithXMLElement. It starts
// from the current object and works up the chain of parents, grabbing
// the declared extensions by each GDataObject in the ancestry and looking 
// at the current element to see if any of the declared extensions are present.

- (void)parseExtensionsForElement:(NSXMLElement *)element {
  GDataObject *currentExtensionSupplier = self;
  Class classBeingParsed = [self class];
  
  for (currentExtensionSupplier = self;
       currentExtensionSupplier != nil;
       currentExtensionSupplier = [currentExtensionSupplier parent]) {
    
    // find all extensions in this supplier with the current class as the parent
    NSArray *extnDecls = [currentExtensionSupplier extensionDeclarationsForClass:classBeingParsed];
    
    if (extnDecls) {
      for (int idx = 0; idx < [extnDecls count]; idx++) {
        
        GDataExtensionDeclaration *decl = [extnDecls objectAtIndex:idx];
        Class extensionClass = [decl childClass];

        if ([extensions_ objectForKey:extensionClass] == nil) {
        
          NSAssert1([extensionClass conformsToProtocol:@protocol(GDataExtension)], 
                    @"%@ does not conform to GDataExtension protocol", 
                    extensionClass);
          
          NSString *namespaceURI = [extensionClass extensionElementURI];
          NSString *qualifiedName = [self qualifiedNameForExtensionClass:extensionClass];
          
          NSArray *objects = [self objectsForChildrenOfElement:element
                                                 qualifiedName:qualifiedName
                                                  namespaceURI:namespaceURI
                                                   objectClass:extensionClass];

          if ([objects count]) {
            [self setObjects:objects forExtensionClass:extensionClass];
          }
        }
      }
    }
  }
}

#pragma mark Dynamic GDataObject 

static NSMutableDictionary *gFeedClassCategoryMap = nil;
static NSMutableDictionary *gEntryClassCategoryMap = nil;

// registerClass:inMap:forCategoryWithScheme:term: does the work for
// registerFeedClass: and registerEntryClass: below
//
// This adds the class to the class:category map, ensuring
// that it won't conflict with a previous class or category
// entry

+ (void)registerClass:(Class)theClass
                inMap:(NSMutableDictionary **)map
forCategoryWithScheme:(NSString *)scheme 
                 term:(NSString *)term {
  
  // there's no autorelease pool in place at +load time, so we'll create our own
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  if (!*map) {
    *map = [[NSMutableDictionary alloc] init]; 
  }
  
  // ensure this is a unique registration
  NSAssert1(nil == [gFeedClassCategoryMap objectForKey:theClass],
            @"%@ already registered", theClass);
  Class prevClass = [self classForCategoryWithScheme:scheme 
                                                term:term
                                             fromMap:*map];
  NSAssert2(prevClass == nil, @"%@ registration conflicts with %@", 
            theClass, prevClass);
  
  GDataCategory *category = [GDataCategory categoryWithScheme:scheme
                                                         term:term];
  [*map setObject:category forKey:theClass];
  
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
// or feed map for a class with a matching category.  scheme and term
// can be nil as wildcards.
+ (Class)classForCategoryWithScheme:(NSString *)scheme
                               term:(NSString *)term
                            fromMap:(NSDictionary *)map {
  
  
  NSEnumerator *classEnumerator = [map keyEnumerator];
  Class foundClass;
  while ((foundClass = [classEnumerator nextObject]) != nil) {

    GDataCategory *foundCategory = [map objectForKey:foundClass];
    
    NSString *foundScheme = [foundCategory scheme];
    NSString *foundTerm = [foundCategory term];
    
    if ((!foundScheme || !scheme || [foundScheme isEqual:scheme])
        && (!foundTerm || !term || [foundTerm isEqual:term])) {
      
      return foundClass;
    }
  }
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
  
  
  // use an XPath query to find the category elements  
  //
  // the category element may need the proper atom namespace prefix
  // (is there a way to avoid having to know the prefix with
  // NSXMLNode's nodesForXPath:?)
  //
  // category elements look like <category scheme="blah" term="blahblah"/>
  // and there may be more than one
  //
  // ? For feed elements, if there's no category, should we look into
  // the entry elements for a category?  Some calendar feeds have
  // lacked feed-level categories.
  
  NSString *categoryTermPathTemplate = @"./%@category";
  
  NSString *atomPrefix = [element resolvePrefixForNamespaceURI:kGDataNamespaceAtom];
  if ([atomPrefix length] > 0) {
    atomPrefix = [atomPrefix stringByAppendingString:@":"]; 
  }
  NSString *categoryPath = [NSString stringWithFormat:categoryTermPathTemplate, 
    atomPrefix];
  
  // nodesForXPath: throws exceptions for parsing errors
  @try {
    NSError *error = nil;
    NSArray *nodes = [element nodesForXPath:categoryPath error:&error];
    if ([nodes count] > 0 ) {
      
      // step through the category elements, looking for one that matches
      // a registered feed or entry class
      
      for (int idx = 0; idx < [nodes count]; idx++) {
        NSString *scheme = nil;
        NSString *term = nil;
        
        NSXMLNode *categoryNode = [nodes objectAtIndex:idx];
        
        // now we have a category element; use XPath to find the scheme and
        // term attributes
        NSArray *schemeNodes = [categoryNode nodesForXPath:@"./@scheme" 
                                                     error:&error];
        if ([schemeNodes count]) {
          scheme = [[schemeNodes objectAtIndex:0] stringValue];
        }
        
        NSArray *termNodes = [categoryNode nodesForXPath:@"./@term" 
                                                   error:&error];
        if ([termNodes count]) {
          term = [[termNodes objectAtIndex:0] stringValue];
        }
        
        if (scheme || term) {
          // we have a scheme or a term, so look for a registered class
          if (isFeed) {
            result = [GDataObject feedClassForCategoryWithScheme:scheme 
                                                            term:term];
            break;
          } else {
            result = [GDataObject entryClassForCategoryWithScheme:scheme 
                                                             term:term];
            break;
          }
          
        }
      }
    }
  }
  @catch (NSException * e) {
  }
  
  return result;
}

@end

@implementation NSXMLElement (GDataObjectExtensions)

- (void)addStringValue:(NSString *)str {
  // NSXMLNode's setStringValue: wipes out other children, so we'll use this
  // instead
  NSXMLNode *strNode = [NSXMLNode textWithStringValue:str];
  [self addChild:strNode];
}

+ (id)elementWithName:(NSString *)name attributeName:(NSString *)attrName attributeValue:(NSString *)attrValue {
  NSXMLNode *attr = [NSXMLNode attributeWithName:attrName stringValue:attrValue];
  NSXMLElement *element = [NSXMLNode elementWithName:name];
  [element addAttribute:attr];
  return element;  
}

@end

@implementation NSArray (GDataObjectExtensions)
// utility to get from an array all objects having a known value (or nil)
// at a keyPath 
- (NSArray *)objectsWithValue:(id)desiredValue
                   forKeyPath:(NSString *)keyPath {
  
  // step through all entries, get the value from 
  // the key path, and see if it's equal to the 
  // desired value
  NSMutableArray *results = [NSMutableArray array];
  NSEnumerator *enumerator = [self objectEnumerator];
  id obj;
  
  while ((obj = [enumerator nextObject]) != nil) {
    id val = [obj valueForKeyPath:keyPath];
    if (AreEqualOrBothNil(val, desiredValue)) {
      [results addObject:obj];
    }
  }
  return results;
}
@end

@implementation GDataExtensionDeclaration

- (id)initWithParentClass:(Class)parentClass 
               childClass:(Class)childClass {
  self = [super init];
  if (self) {
    parentClass_ = parentClass; 
    childClass_ = childClass;
  }
  return self;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@: {%@ can contain %@}", 
    [self class], parentClass_, childClass_];

}

- (Class)parentClass {
  return parentClass_;  
}

- (Class)childClass {
  return childClass_; 
}

@end

// isEqual: has the fatal flaw that it doesn't deal well with the received
// being nil. We'll use this utility instead.
BOOL AreEqualOrBothNil(id obj1, id obj2) {
  if (obj1 == obj2) {
    return YES;
  }
  if (obj1 && obj2) {
    BOOL areEqual = [obj1 isEqual:obj2];
    
    // the next line is useful when XML regeneration fails in unit tests
    //if (!areEqual) NSLog(@">>>\n%@\n  !=\n%@", obj1, obj2);  
      
    return areEqual; 
  }
  return NO;
}

