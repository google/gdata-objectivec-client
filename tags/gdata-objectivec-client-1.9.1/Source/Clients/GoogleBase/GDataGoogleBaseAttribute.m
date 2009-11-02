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
//  GDataGoogleBaseAttribute.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_GOOGLEBASE_SERVICE

#import "GDataGoogleBaseAttribute.h"
#import "GDataEntryGoogleBase.h"
#import "GDataGoogleBaseMetadataValue.h"

@implementation GDataGoogleBaseAttribute 

// arbitrary Google Base attribute, like
// <g:condition type='text'>new  <g:my_subattribute>89</g:my_subattribute> </g:condition>

// this object may be an extension, so declare its extension characteristics

+ (NSString *)extensionElementPrefix { return kGDataNamespaceGoogleBasePrefix; }
+ (NSString *)extensionElementURI { return kGDataNamespaceGoogleBase; }
+ (NSString *)extensionElementLocalName { 
  // wildcard * matches all elements with the proper namespace URI
  return @"*"; 
}

+ (GDataGoogleBaseAttribute *)attributeWithName:(NSString *)name
                                           type:(NSString *)type
                                      textValue:(NSString *)textValue {
  
  GDataGoogleBaseAttribute *obj = [[[GDataGoogleBaseAttribute alloc] init] autorelease];
  [obj setName:name];
  [obj setType:type];
  [obj setTextValue:textValue];
  return obj;
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  // GDataGoogleBaseAttributes may contain other attributes
  [self addExtensionDeclarationForParentClass:[GDataGoogleBaseAttribute class]
                                   childClass:[GDataGoogleBaseAttribute class]];  
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    
    type_ = [[self stringForAttributeName:@"type" fromElement:element] copy];
    
    NSString *accessStr = [self stringForAttributeName:@"access" 
                                           fromElement:element];
    if (accessStr) {
      isPrivate_ = ([accessStr caseInsensitiveCompare:@"private"] == NSOrderedSame);
    }
    
    NSString *elementName = [element localName];
    NSString *attrName = [GDataGoogleBaseAttribute attributeNameFromElementLocalName:elementName];
    attributeName_ = [attrName copy];
    
    textValue_ = [[self stringValueFromElement:element] copy];
  }
  return self;
}

- (void)dealloc {
  [attributeName_ release];
  [type_ release];
  [textValue_ release];
  [super dealloc];
}

#pragma mark -

// swap " " and "_" to convert between element and attribute names
+ (NSString *)attributeNameFromElementLocalName:(NSString *)elementLocalName {
  
  NSMutableString *attrName = [NSMutableString stringWithString:elementLocalName];
  [attrName replaceOccurrencesOfString:@"_"
                            withString:@" "
                               options:0
                                 range:NSMakeRange(0, [elementLocalName length])];
  return attrName;
  
}

+ (NSString *)elementLocalNameFromAttributeName:(NSString *)attributeName {
  
  NSMutableString *elementName = [NSMutableString stringWithString:attributeName];
  [elementName replaceOccurrencesOfString:@" "
                               withString:@"_"
                                  options:0
                                    range:NSMakeRange(0, [attributeName length])];
  return elementName;
  
}

#pragma mark -

- (NSString *)name {
  return attributeName_;
}

- (void)setName:(NSString *)str {
  [attributeName_ autorelease];
  attributeName_ = [str copy];

  // update the element name to match the attribute name, like "g:foo_bar"
  if ([str length] > 0) {
    NSString *localName = [[self class] elementLocalNameFromAttributeName:str];
    NSString *elementName = [NSString stringWithFormat:@"%@:%@",
                             kGDataNamespaceGoogleBasePrefix, localName];
    [self setElementName:elementName];
  }
}

- (NSString *)textValue {
  return textValue_;
}

- (void)setTextValue:(NSString *)str {
  [textValue_ autorelease];
  textValue_ = [str copy];
}

- (NSString *)type {
  return type_;
}

- (void)setType:(NSString *)str {
  [type_ autorelease];
  type_ = [str copy];
}

- (BOOL)isPrivate {
  return isPrivate_;
}

- (void)setIsPrivate:(BOOL)flag {
  isPrivate_ = flag;
}


- (id)copyWithZone:(NSZone *)zone {
  GDataGoogleBaseAttribute* newObj = [super copyWithZone:zone];
  
  [newObj setName:[self name]];
  [newObj setType:[self type]];
  [newObj setTextValue:[self textValue]];
  [newObj setIsPrivate:[self isPrivate]];
  
  return newObj;
}

- (BOOL)isEqual:(GDataGoogleBaseAttribute *)other {
  
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataGoogleBaseAttribute class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self name], [other name])
    && AreEqualOrBothNil([self type], [other type])
    && AreEqualOrBothNil([self textValue], [other textValue])
    && ([self isPrivate] == [other isPrivate]);
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:attributeName_ withName:@"name"];
  [self addToArray:items objectDescriptionIfNonNil:type_ withName:@"type"];
  [self addToArray:items objectDescriptionIfNonNil:textValue_ withName:@"textValue"];
  
  if (isPrivate_) {
    [self addToArray:items objectDescriptionIfNonNil:@"private" withName:@"access"];
  }
  
  if ([[self subAttributes] count]) {
    [self addToArray:items objectDescriptionIfNonNil:[self subAttributes] withName:@"subAttributes"]; 
  }
  
  return items;
}
#endif

- (NSXMLElement *)XMLElement {

  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:[self elementName]];
   
  [self addToElement:element attributeValueIfNonNil:[self type] withName:@"type"];
  
  if (isPrivate_) {
    [self addToElement:element attributeValueIfNonNil:@"private" withName:@"access"];
  }
  
  if (textValue_) {
    [element addStringValue:textValue_];
  }
  
  return element;
}

#pragma mark SubAttribute extension accessors

- (void)setSubAttributes:(NSArray *)subAttributes {
  [self setObjects:subAttributes forExtensionClass:[GDataGoogleBaseAttribute class]];
}

- (void)addSubAttribute:(GDataGoogleBaseAttribute *)subAttribute {
  [self addObject:subAttribute forExtensionClass:[GDataGoogleBaseAttribute class]];
}

- (NSArray *)subAttributes {
  return [self objectsForExtensionClass:[GDataGoogleBaseAttribute class]];
}

# pragma mark Type Conversions

- (GDataDateTime *)dateTime {
  
  NSString *textValue = [self textValue];
  if (textValue) {
    GDataDateTime *dateTime = [GDataDateTime dateTimeWithRFC3339String:textValue];
    return dateTime;
  }
  return nil;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_GOOGLEBASE_SERVICE
