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
//  GDataObject.h
//

// This is the base class for most objects in the Objective-C GData implementation.
// Objects should derive from GDataObject in order to support XML parsing and
// generation, and to support the extension model.

// Subclasses will typically implement:
//
// - (void)addExtensionDeclarations;  -- declaring extensions
// - (id)initWithXMLElement:(NSXMLElement *)element
//                   parent:(GDataObject *)parent;  -- parsing
// - (NSXMLElement *)XMLElement;  -- XML generation
//
// Subclasses should implement other typical NSObject methods, too:
//
// - (NSString *)description;
// - (id)copyWithZone:(NSZone *)zone; (be sure to call superclass)
// - (BOOL)isEqual:(GDataObject *)other; (be sure to call superclass)
// - (void)dealloc;
//
// Subclasses which may be used as extensions should implement the
// simple GDataExtension protocol.
//

//
// Parsing and XML generation
//
// Parsing is done in the subclass's -initWithXMLElement:parent: method.
//
// For each parsed GData XML element, GDataObject maintains lists of
// un-parsed attributes and children (unknownChildren_ and unknownAttributes_)
// as raw NSXMLNodes.  Subclasses MUST use the methods in this class's
// "parsing helpers" (below) to extract properties and elements during parsing;
// this ensures that the lists of unknown properties and children are
// accurate.  DO NOT parse using NSXMLElement methods.
//
// XML generation is done in the subclass's -XMLElement method.
// That method will call XMLElementWithExtensionsAndDefaultName to get
// a "starter" NSXMLElement, already decorated with extensions, to which
// the subclass can add its unique children and attributes, if any.
//
//
// 
// The extension model
//
// Extensions enable elements to contain children about which the element
// may know no details.
//
// Typically, entries add extensions to themselves. For example, a Calendar
// entry declares it may contain a color:
//
//  [self addExtensionDeclarationForParentClass:[GDataEntryCalendar class]
//                                   childClass:[GDataColorProperty class]];
//
// This lets the base class handle much of the work of managing the child
// element.  The Calendar entry can still provide accessor methods to get
// to the extension by calling into the base class, as in
//
//  - (GDataColorProperty *)color {
//    return (GDataColorProperty *) 
//               [self objectForExtensionClass:[GDataColorProperty class]];
//  }
//
//  - (void)setColor:(GDataColorProperty *)val {
//    [self setObject:val forExtensionClass:[GDataColorProperty class]];
//  }
//
// The real purpose of extensions is to allow elements to contain children
// they may not know about.  For example, a CalendarEventEntry declares
// that GDataLinks contained within the calendar event entry may contain
// GDataWebContent elements:
//
//  [self addExtensionDeclarationForParentClass:[GDataLink class]
//                                   childClass:[GDataWebContent class]];  
//
// The CalendarEvent has extended GDataLinks without GDataLinks knowing or
// caring.  Because GDataLink derives from GDataObject, the GDataLink
// object will automatically parse and maintain and copy and compare
// the GDataWebContents contained within.
//


#import <Foundation/Foundation.h>

#import "GDataDefines.h"
#import "GDataUtilities.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAOBJECT_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* kGDataNamespaceAtom _INITIALIZE_AS(@"http://www.w3.org/2005/Atom");
_EXTERN NSString* kGDataNamespaceAtomPrefix _INITIALIZE_AS(@"atom");

_EXTERN NSString* kGDataNamespaceAtomPub _INITIALIZE_AS(@"http://purl.org/atom/app#");
_EXTERN NSString* kGDataNamespaceAtomPubPrefix _INITIALIZE_AS(@"app");

_EXTERN NSString* kGDataNamespaceOpenSearch _INITIALIZE_AS(@"http://a9.com/-/spec/opensearchrss/1.0/");
_EXTERN NSString* kGDataNamespaceOpenSearchPrefix _INITIALIZE_AS(@"openSearch");

_EXTERN NSString* kGDataNamespaceXHTML _INITIALIZE_AS(@"http://www.w3.org/1999/xhtml");
_EXTERN NSString* kGDataNamespaceXHTMLPrefix _INITIALIZE_AS(@"xh");

_EXTERN NSString* kGDataNamespaceGData _INITIALIZE_AS(@"http://schemas.google.com/g/2005");
_EXTERN NSString* kGDataNamespaceGDataPrefix _INITIALIZE_AS(@"gd");

_EXTERN NSString* kGDataNamespaceBatch _INITIALIZE_AS(@"http://schemas.google.com/gdata/batch");
_EXTERN NSString* kGDataNamespaceBatchPrefix _INITIALIZE_AS(@"batch");

// helper function for subclasses implementing isEqual:
BOOL AreEqualOrBothNil(id obj1, id obj2);
BOOL AreBoolsEqual(BOOL b1, BOOL b2);

@class GDataDateTime;
@class GDataCategory;

@protocol GDataExtension
+ (NSString *)extensionElementURI;
+ (NSString *)extensionElementPrefix;
+ (NSString *)extensionElementLocalName;
@end

@interface GDataObject : NSObject {
  
  @private
  
  // element name from original XML, used for later XML generation
  NSString *elementName_; 
  
  GDataObject *parent_;  // WEAK, parent in tree of GData objects
  
  // GDataObjects keep namespaces as {key:prefix value:URI} dictionary entries
  NSMutableDictionary *namespaces_; 

  // list of potential GDataExtensionDeclarations for this element and its children
  NSMutableArray *extensionDeclarations_; 
  
  // arrays of actual extension elements found for this element, keyed by extension class
  NSMutableDictionary *extensions_;  
  
  // arrays of XMLNodes of attributes and child elements not yet parsed
  NSMutableArray *unknownChildren_;    
  NSMutableArray *unknownAttributes_;  
  
  // mapping of standard classes to user's surrogate subclasses, used when
  // creating objects from XML
  NSDictionary *surrogates_;
  
  // anything defined by the client; retained but not used internally; not 
  // copied by copyWithZone:
  id userData_; 
  NSMutableDictionary *userProperties_;
}

- (id)copyWithZone:(NSZone *)zone;

// this init method should  be used only when creating the base of a tree
// containing surrogates (the surrogate map is a dictionary of
// standard GDataObject classes to replacement subclasses); this method
// calls through to [self initWithXMLElement:parent:]
- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent
              surrogates:(NSDictionary *)surrogates;
  
- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent; // subclasses must override
- (NSXMLElement *)XMLElement; // subclasses must override

- (NSXMLDocument *)XMLDocument; // returns this XMLElement wrapped in an NSXMLDocument

- (BOOL)generateContentInputStream:(NSInputStream **)outInputStream
                            length:(unsigned long long *)outLength
                           headers:(NSDictionary **)outHeaders;

- (void)addExtensionDeclarations; // subclasses may override this to declare extensions

// setters/getters

// namespaces here are a dictionary mapping prefix to URI; they are not
// NSXML namespace objects
- (void)setNamespaces:(NSDictionary *)namespaces;
- (void)addNamespaces:(NSDictionary *)namespaces;
- (NSDictionary *)namespaces;

// name from original XML; this will be used during XML generation
- (void)setElementName:(NSString *)elementName;
- (NSString *)elementName;

// parent in object tree (weak reference)
- (void)setParent:(GDataObject *)obj;
- (GDataObject *)parent;

// surrogate lists for when alloc'ing classes from XML
- (void)setSurrogates:(NSDictionary *)surrogates;
- (NSDictionary *)surrogates;

// userData is available for client use; retained by GDataObject, but not 
// copied by the copyWithZone
- (void)setUserData:(id)obj; 
- (id)userData;

// properties are supported for client convenience, but are not copied by
// copyWithZone.  Properties keys beginning with _ are reserved by the library.
- (void)setProperties:(NSDictionary *)dict;
- (NSDictionary *)properties;

- (void)setProperty:(id)obj forKey:(NSString *)key; // pass nil obj to remove property
- (id)propertyForKey:(NSString *)key;

// XMLNode children not parsed; primarily for internal use by the framework
- (void)setUnknownChildren:(NSArray *)arr;
- (NSArray *)unknownChildren;

// XMLNode attributes not parsed; primarily for internal use by the framework
- (void)setUnknownAttributes:(NSArray *)arr;
- (NSArray *)unknownAttributes;

  
//
// Extensions
//

// declaring a potential extension; applies to this object and its children
- (void)addExtensionDeclarationForParentClass:(Class)parentClass
                                   childClass:(Class)childClass;
- (void)removeExtensionDeclarationForParentClass:(Class)parentClass
                                      childClass:(Class)childClass;

// accessing actual extensions in this object
- (NSArray *)objectsForExtensionClass:(Class)theClass;
- (id)objectForExtensionClass:(Class)theClass;

// replacing or adding actual extensions in this object
- (void)setObjects:(NSArray *)objects forExtensionClass:(Class)theClass;
- (void)setObject:(GDataObject *)object forExtensionClass:(Class)theClass; // removes all previous objects for this class
- (void)addObject:(GDataObject *)object forExtensionClass:(Class)theClass;
- (void)removeObject:(GDataObject *)object forExtensionClass:(Class)theClass;

//
// Dynamic GDataObject generation
//
// Feeds and entries can register themselves in their + (void)load
// methods.  When XML is being parsed, if a matching category
// is found, the proper class is instantiated.
//
// The scheme or term in a category may be nil (during
// registration and lookup) to match any values.

// class registration methods
+ (void)registerFeedClass:(Class)theClass
    forCategoryWithScheme:(NSString *)scheme 
                     term:(NSString *)term;

+ (void)registerEntryClass:(Class)theClass
     forCategoryWithScheme:(NSString *)scheme 
                      term:(NSString *)term;

// class lookup methods
+ (Class)feedClassForCategoryWithScheme:(NSString *)scheme 
                                   term:(NSString *)term;
+ (Class)entryClassForCategoryWithScheme:(NSString *)scheme 
                                    term:(NSString *)term;

// objectClassForXMLElement: returns a found registered feed
// or entry class for the XML according to its contained category
//
// If no registered class is found with a matching category,
// this returns GDataFeedBase for feed elements, GDataEntryBase
// for entry elements.
//
// If the element is not a <feed> or <entry> then nil is returned
+ (Class)objectClassForXMLElement:(NSXMLElement *)element;
  
//
// XML parsing helpers (used in initWithXMLElement:parent:)
//
// Use these parsing helpers, since they remove the parsed items from the 
// "unknown children" list for this object.
//

// this creates a single object of the specified class for the first XML child
// element with the specified name. Returns nil if no child element is present.
- (id)objectForChildOfElement:(NSXMLElement *)parentElement
                qualifiedName:(NSString *)qualifiedName
                 namespaceURI:(NSString *)namespaceURI
                  objectClass:(Class)objectClass;
  
// this creates an array of objects of the specified class for each XML child 
// element with the specified name
- (NSMutableArray *)objectsForChildrenOfElement:(NSXMLElement *)parentElement
                                  qualifiedName:(NSString *)qualifiedName
                                   namespaceURI:(NSString *)namespaceURI
                                    objectClass:(Class)objectClass;

// childOfElement:withName returns the element with the name, or nil of there 
// are not exactly one of the element
- (NSXMLElement *)childWithQualifiedName:(NSString *)localName
                            namespaceURI:(NSString *)namespaceURI
                             fromElement:(NSXMLElement *)parentElement;

// searches up the parent tree to find a surrogate for the standard class; 
// if there is  no surrogate, returns the standard class itself
- (Class)classOrSurrogateForClass:(Class)standardClass;

// element parsing

// this method avoids the "recursive descent" behavior of NSXMLElement's 
// stringValue; the element parameter may be nil
- (NSString *)stringValueFromElement:(NSXMLElement *)element;

- (GDataDateTime *)dateTimeFromElement:(NSXMLElement *)element;

- (NSNumber *)intNumberValueFromElement:(NSXMLElement *)element;

- (NSNumber *)doubleNumberValueFromElement:(NSXMLElement *)element;

// attribute parsing
- (NSString *)stringForAttributeName:(NSString *)attributeName
                         fromElement:(NSXMLElement *)element;

- (NSString *)stringForAttributeLocalName:(NSString *)localName
                                      URI:(NSString *)attributeURI
                              fromElement:(NSXMLElement *)element;  

- (GDataDateTime *)dateTimeForAttributeName:(NSString *)attributeName 
                                fromElement:(NSXMLElement *)element;

- (NSXMLNode *)attributeForName:(NSString *)attributeName 
                    fromElement:(NSXMLElement *)element;

- (BOOL)boolForAttributeName:(NSString *)attributeName 
                 fromElement:(NSXMLElement *)element;

- (NSNumber *)doubleNumberForAttributeName:(NSString *)attributeName 
                               fromElement:(NSXMLElement *)element;

- (NSNumber *)intNumberForAttributeName:(NSString *)attributeName 
                            fromElement:(NSXMLElement *)element;

- (NSNumber *)intNumberForAttributeLocalName:(NSString *)localName
                                         URI:(NSString *)attributeURI
                                 fromElement:(NSXMLElement *)element;

- (NSDecimalNumber *)decimalNumberForAttributeName:(NSString *)attributeName 
                                       fromElement:(NSXMLElement *)element;

- (NSNumber *)longLongNumberForAttributeName:(NSString *)attributeName 
                                 fromElement:(NSXMLElement *)element;

- (NSNumber *)boolNumberForAttributeName:(NSString *)attributeName 
                             fromElement:(NSXMLElement *)element;

//
// XML generation helpers
//

// subclasses start their -XMLElement method by calling this
- (NSXMLElement *)XMLElementWithExtensionsAndDefaultName:(NSString *)defaultName;

// adding attributes
- (NSXMLNode *)addToElement:(NSXMLElement *)element
     attributeValueIfNonNil:(NSString *)val
                   withName:(NSString *)name;

- (NSXMLNode *)addToElement:(NSXMLElement *)element
     attributeValueIfNonNil:(NSString *)val
              withLocalName:(NSString *)localName
                        URI:(NSString *)attributeURI;

- (NSXMLNode *)addToElement:(NSXMLElement *)element
  attributeValueWithInteger:(int)val
                   withName:(NSString *)name;

// adding child elements
- (NSXMLNode *)addToElement:(NSXMLElement *)element
childWithStringValueIfNonEmpty:(NSString *)str
                   withName:(NSString *)name;

- (NSXMLNode *)addToElement:(NSXMLElement *)element
     childWithValuePropertyIfNonNil:(id)value
                   withName:(NSString *)name;

- (void)addToElement:(NSXMLElement *)element
 XMLElementsForArray:(NSArray *)arrayOfGDataObjects;

//
// decription method helpers
//

- (void)addToArray:(NSMutableArray *)stringItems
objectDescriptionIfNonNil:(id)obj
          withName:(NSString *)name;

- (void)addToArray:(NSMutableArray *)stringItems
      integerValue:(int)val
          withName:(NSString *)name;  

- (void)addToArray:(NSMutableArray *)stringItems
arrayCountIfNonEmpty:(NSArray *)array
          withName:(NSString *)name;  


// optional methods for overriding
//
// subclasses may implement -itemsForDescription and add to or
// replace the superclass's array of items
- (NSMutableArray *)itemsForDescription;
- (NSString *)descriptionWithItems:(NSArray *)items;
- (NSString *)description;
@end

@interface NSXMLElement (GDataObjectExtensions)

// XML generation helpers

// NSXMLNode's setStringValue: wipes out other children, so we'll use this
// instead
- (void)addStringValue:(NSString *)str;

// creating objects from child elements
+ (id)elementWithName:(NSString *)name attributeName:(NSString *)attrName attributeValue:(NSString *)attrValue;
@end

@interface NSArray (GDataObjectExtensions)
// utility to get from an array all objects having a known value (or nil)
// at a keyPath 
- (NSArray *)objectsWithValue:(id)desiredValue
                   forKeyPath:(NSString *)keyPath;
@end
