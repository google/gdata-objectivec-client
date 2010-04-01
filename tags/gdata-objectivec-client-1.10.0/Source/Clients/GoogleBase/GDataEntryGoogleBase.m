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
//  GDataEntryGoogleBase.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_GOOGLEBASE_SERVICE

#define GDATAENTRYGOOGLEBASE_DEFINE_GLOBALS 1
#import "GDataEntryGoogleBase.h"

#import "GDataGoogleBaseAttribute.h"
#import "GDataGoogleBaseMetadataValue.h"
#import "GDataGoogleBaseMetadataAttribute.h"
#import "GDataGoogleBaseMetadataAttributeList.h"
#import "GDataGoogleBaseMetadataItemType.h"

// GoogleBaseEntry extensions

@implementation GDataEntryGoogleBase

+ (NSDictionary *)googleBaseNamespaces {
  NSMutableDictionary *namespaces = [NSMutableDictionary dictionaryWithObjectsAndKeys:
    kGDataNamespaceGoogleBase, kGDataNamespaceGoogleBasePrefix,
    kGDataNamespaceGoogleBaseMetadata, kGDataNamespaceGoogleBaseMetadataPrefix, 
    nil];
  
  [namespaces addEntriesFromDictionary:[GDataEntryBase baseGDataNamespaces]];
  
  return namespaces;
}

+ (GDataEntryGoogleBase *)googleBaseEntryForCategoryTerm:(NSString *)term {
  GDataEntryGoogleBase* entry = [[[GDataEntryGoogleBase alloc] init] autorelease];
  
  [entry setNamespaces:[GDataEntryGoogleBase googleBaseNamespaces]];
  
  if (term) {
    GDataCategory *category = [GDataCategory categoryWithScheme:kGDataCategoryGoogleBaseItemTypesScheme
                                                           term:term];
    [entry addCategory:category];
  }
  return entry;
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class entryClass = [self class];
  
  // GoogleBaseEntry extensions
  
  [self addExtensionDeclarationForParentClass:entryClass
                                 childClasses:
   [GDataGoogleBaseAttribute class],
   [GDataGoogleBaseMetadataAttribute class],
   [GDataGoogleBaseMetadataAttributeList class],
   [GDataGoogleBaseMetadataItemType class],
   nil];
}


#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  static struct GDataDescriptionRecord descRecs[] = {
    { @"title",                 @"title.stringValue",     kGDataDescValueLabeled },
    { @"content",               @"content.stringValue",   kGDataDescValueLabeled },
    { @"attributes",            @"entryAttributes",       kGDataDescArrayDescs },
    { @"itemType",              @"metadataItemType",      kGDataDescValueLabeled },
    { @"metadataAttributes",    @"metadataAttributes",    kGDataDescArrayDescs },
    { @"metadataAttributeList", @"metadataAttributeList", kGDataDescValueLabeled },
    { nil, nil, 0 }
  };
  
  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

+ (NSString *)defaultServiceVersion {
  return kGDataGoogleBaseDefaultServiceVersion;
}

#pragma mark -

// attributes

- (NSArray *)entryAttributes {
  NSArray *attributes = [self objectsForExtensionClass:[GDataGoogleBaseAttribute class]];
  return attributes;
}

- (void)setEntryAttributes:(NSArray *)attrs {
  [self setObjects:attrs forExtensionClass:[GDataGoogleBaseAttribute class]]; 
}

- (void)addEntryAttribute:(GDataGoogleBaseAttribute *)attr {
  [self addObject:attr forExtensionClass:[GDataGoogleBaseAttribute class]]; 
}

// metadata attributes

- (NSArray *)metadataAttributes {
  NSArray *metadataAttributes = [self objectsForExtensionClass:[GDataGoogleBaseMetadataAttribute class]];
  return metadataAttributes;
}

- (void)setMetadataAttributes:(NSArray *)attrs {
  [self setObjects:attrs forExtensionClass:[GDataGoogleBaseMetadataAttribute class]]; 
}

- (void)addMetadataAttribute:(GDataGoogleBaseMetadataAttribute *)attr {
  [self addObject:attr forExtensionClass:[GDataGoogleBaseMetadataAttribute class]]; 
}

// metadata attribute list (contains metadata attributes)

- (GDataGoogleBaseMetadataAttributeList *)metadataAttributeList {
  GDataObject *attrs = [self objectForExtensionClass:[GDataGoogleBaseMetadataAttributeList class]];
  return (GDataGoogleBaseMetadataAttributeList *) attrs;
}

- (void)setMetadataAttributeList:(GDataGoogleBaseMetadataAttributeList *)attrs {
  [self setObject:attrs forExtensionClass:[GDataGoogleBaseMetadataAttributeList class]]; 
}

// metadata item type

- (NSString *)metadataItemType {
  GDataObject *obj = [self objectForExtensionClass:[GDataGoogleBaseMetadataItemType class]];
  if (obj) {
    return [(GDataGoogleBaseMetadataItemType *)obj value];
  }
  return nil;
}

- (void)setMetadataItemType:(NSString *)str {
  
  GDataGoogleBaseMetadataItemType *itemType = nil;
  if (str) {
    itemType = [GDataGoogleBaseMetadataItemType metadataItemTypeWithValue:str]; 
  }
  [self setObject:itemType forExtensionClass:[GDataGoogleBaseMetadataItemType class]]; 
}

#pragma mark -

// attribute accessor utilities

- (BOOL)isAttributeType:(NSString *)testType
            supertypeOf:(NSString *)subtype {
  
  if (!testType || !subtype) return NO;
  
  if ([testType isEqual:subtype]) return YES;
  
  // we'll keep a static dictionary mapping types (keys) to their supertypes (values)
  static NSDictionary *superTypeDict = nil;
  if (!superTypeDict) {
    
    superTypeDict = [[NSDictionary alloc] initWithObjectsAndKeys:
      
      kGDataGoogleBaseAttributeTypeNumber, kGDataGoogleBaseAttributeTypeInt,
      kGDataGoogleBaseAttributeTypeNumber, kGDataGoogleBaseAttributeTypeFloat,
      
      kGDataGoogleBaseAttributeTypeNumberUnit, kGDataGoogleBaseAttributeTypeIntUnit,
      kGDataGoogleBaseAttributeTypeNumberUnit, kGDataGoogleBaseAttributeTypeFloatUnit,
      
      kGDataGoogleBaseAttributeTypeDateTimeRange, kGDataGoogleBaseAttributeTypeDate,
      kGDataGoogleBaseAttributeTypeDate,          kGDataGoogleBaseAttributeTypeDateTime,
      
      nil];
  }

  NSString *subtypesSuperType = [superTypeDict objectForKey:subtype];
  if (subtypesSuperType) {
    return [self isAttributeType:testType supertypeOf:subtypesSuperType];
  }
  
  return NO;
}

// Return all attributes by name in a dictionary so they can be
// accessed with key-value coding.  All attributes are returned in
// arrays; dictionary keys for the attributes are the XML element names.
//
// Element names are free of spaces, so more likely to be KVC-happy
// than actual attribute names.
- (NSDictionary *)attributeDictionary {
  NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
  
  NSArray *allAttributes = [self entryAttributes];
  NSEnumerator *allAttributesEnum = [allAttributes objectEnumerator];
  GDataGoogleBaseAttribute *attr;
  while ((attr = [allAttributesEnum nextObject]) != nil) {
    NSString *attrKey = [GDataGoogleBaseAttribute elementLocalNameFromAttributeName:[attr name]];
    
    NSMutableArray *previousArray = [dictionary objectForKey:attrKey];
    if (previousArray == nil) {
      // first time we're adding an attribute with this name
      [dictionary setObject:[NSMutableArray arrayWithObject:attr]
                    forKey:attrKey]; 
    } else {
      // second and later adds with this name
      [previousArray addObject:attr];
    }
  }
  return dictionary;
}


// Name and/or type may be nil to match any attributes.
// Type can be equal to or a subtype of the found attribute.
- (NSArray *)attributesWithName:(NSString *)name
                           type:(NSString *)type {
  
  NSArray *allAttributes = [self entryAttributes];
  NSEnumerator *allAttributesEnum = [allAttributes objectEnumerator];
  NSMutableArray *matchingAttributes = [NSMutableArray array];
  GDataGoogleBaseAttribute *attr;
  while ((attr = [allAttributesEnum nextObject]) != nil) {
    NSString *attrName = [attr name];
    NSString *attrType = [attr type];
    if (name == nil || (attrName != nil && [name isEqual:attrName])) {
      
      if (type == nil || (attrType != nil
                          &&  [self isAttributeType:type supertypeOf:attrType])) {
        [matchingAttributes addObject:attr];
      }
    }
  }
  return matchingAttributes;
}

- (GDataGoogleBaseAttribute *)attributeWithName:(NSString *)name
                                           type:(NSString *)type {

  // if there is exactly one match, return the match; otherwise,
  // return nil
  NSArray *matchingAttributes = [self attributesWithName:name
                                                    type:type];
  if ([matchingAttributes count] == 1) {
    return [matchingAttributes objectAtIndex:0]; 
  }
  return nil;
}

- (void)removeAttributesWithName:(NSString *)name
                            type:(NSString *)type {
  
  NSArray *matchingAttributes = [self attributesWithName:name
                                                    type:type];
  
  NSMutableArray *allAttributes = [NSMutableArray arrayWithArray:[self entryAttributes]];

  [allAttributes removeObjectsInArray:matchingAttributes];
  
  [self setEntryAttributes:allAttributes];
}

- (void)setAttributeWithName:(NSString *)name
                        type:(NSString *)type
                   textValue:(NSString *)value {
  
  [self removeAttributesWithName:name type:type]; 
  
  if (value) {
    [self addEntryAttribute:[GDataGoogleBaseAttribute attributeWithName:name
                                                                   type:type
                                                              textValue:value]];
  }
}

- (NSArray *)stringValuesForAttributes:(NSArray *)attributes {
  
  // make an array of the strings from the attributes
  NSMutableArray *strings = [NSMutableArray array];
  NSEnumerator *attrEnum = [attributes objectEnumerator];
  GDataGoogleBaseAttribute *attr;
  while ((attr = [attrEnum nextObject]) != nil) {
    NSString *str = [attr textValue];
    if (str) {
      [strings addObject:str];
    }
  }
  return strings;
  
}

#pragma mark Convenience accessors for individual attributes

// labels

- (NSArray *)labels {
  NSArray *labelAttrs = [self attributesWithName:@"label" 
                                            type:kGDataGoogleBaseAttributeTypeText];
  NSArray *labelStrings = [self stringValuesForAttributes:labelAttrs];

  return labelStrings;
}

- (void)addLabel:(NSString *)str {
  [self addEntryAttribute:[GDataGoogleBaseAttribute attributeWithName:@"label"
                                                                 type:kGDataGoogleBaseAttributeTypeText
                                                            textValue:str]];  
}

// item type

- (NSString *)itemType {
  return [[self attributeWithName:@"item type" 
                             type:kGDataGoogleBaseAttributeTypeText] textValue];
}

- (void)setItemType:(NSString *)str {
  
  [self setAttributeWithName:@"item type"
                        type:kGDataGoogleBaseAttributeTypeText
                   textValue:str];  
}

// expiration date

- (GDataDateTime *)expirationDate {
  return [[self attributeWithName:@"expiration date" 
                             type:kGDataGoogleBaseAttributeTypeDateTime] dateTime];
}

- (void)setExpirationDate:(GDataDateTime *)dateTime {
  [self setAttributeWithName:@"expiration date"
                             type:kGDataGoogleBaseAttributeTypeDateTime
                   textValue:[dateTime RFC3339String]];
}

// image link

- (NSArray *)imageLinks {
  
  NSArray *attrs = [self attributesWithName:@"image link" 
                                       type:kGDataGoogleBaseAttributeTypeURL];
  NSArray *strings = [self stringValuesForAttributes:attrs];
  
  return strings;
}

- (NSString *)imageLink {
  return [[self imageLinks] objectAtIndex:0];
}

- (void)addImageLink:(NSString *)str {
  [self addEntryAttribute:[GDataGoogleBaseAttribute attributeWithName:@"image link"
                                                                 type:kGDataGoogleBaseAttributeTypeURL
                                                            textValue:str]];    
}

// payment method

- (NSArray *)paymentMethods {
  NSArray *attrs = [self attributesWithName:@"payment accepted" 
                                       type:kGDataGoogleBaseAttributeTypeText];
  NSArray *strings = [self stringValuesForAttributes:attrs];
  
  return strings;  
}

- (void)addPaymentMethod:(NSString *)str {

  NSArray *existingMethods = [self paymentMethods];

  if (![existingMethods containsObject:str]) {
    [self addEntryAttribute:[GDataGoogleBaseAttribute attributeWithName:@"payment accepted"
                                                                   type:kGDataGoogleBaseAttributeTypeText
                                                              textValue:str]];      
  }
}

// price

- (NSString *)price {
  return [[self attributeWithName:@"price" 
                             type:kGDataGoogleBaseAttributeTypeFloatUnit] textValue];
}

- (void)setPrice:(NSString*)str {
  [self setAttributeWithName:@"price"
                        type:kGDataGoogleBaseAttributeTypeFloatUnit
                   textValue:str];  
}

// location

- (NSString *)location {
  return [[self attributeWithName:@"location"
                             type:kGDataGoogleBaseAttributeTypeLocation] textValue];
}

- (void)setLocation:(NSString *)str {
  [self setAttributeWithName:@"location"
                        type:kGDataGoogleBaseAttributeTypeLocation
                   textValue:str];  
}

// price type

- (NSString *)priceType {
  return [[self attributeWithName:@"price type" 
                             type:kGDataGoogleBaseAttributeTypeText] textValue];
}

- (void)setPriceType:(NSString *)str {
  [self setAttributeWithName:@"price type"
                        type:kGDataGoogleBaseAttributeTypeText
                   textValue:str];  
}

// quantity

- (NSNumber *)quantity {
  NSString *str = [[self attributeWithName:@"quantity" 
                                      type:kGDataGoogleBaseAttributeTypeInt] textValue];
  if (str) {
    int result = 0;
    NSScanner *scanner = [NSScanner scannerWithString:str];
    if ([scanner scanInt:&result]) {
      return [NSNumber numberWithInt:result]; 
    }
  }
  return nil;
}

- (void)setQuantity:(NSNumber *)num {
  [self setAttributeWithName:@"quantity"
                        type:kGDataGoogleBaseAttributeTypeInt
                   textValue:[num stringValue]];  
}

// price units

- (NSString *)priceUnits {
  return [[self attributeWithName:@"price units" 
                             type:kGDataGoogleBaseAttributeTypeText] textValue];
}

- (void)setPriceUnits:(NSString *)str {
  [self setAttributeWithName:@"price units"
                        type:kGDataGoogleBaseAttributeTypeText
                   textValue:str];  
}

// shipping

- (NSArray *)shippings {

  NSArray *attrs = [self attributesWithName:@"shipping"
                                       type:kGDataGoogleBaseAttributeTypeShipping];
  
  NSArray *strings = [self stringValuesForAttributes:attrs];

  return strings;
}

- (void)addShipping:(NSString *)str {
  NSArray *existingShippings = [self shippings];
  
  if (![existingShippings containsObject:str]) {
    
    [self setAttributeWithName:@"shipping"
                          type:kGDataGoogleBaseAttributeTypeShipping
                     textValue:str];  
  }
}

// tax percent

- (NSNumber *)taxPercent {
  NSString *str = [[self attributeWithName:@"tax percent" 
                                      type:kGDataGoogleBaseAttributeTypeFloat] textValue];
  if (str) {
    float value = 0.0f;
    NSScanner *scanner = [NSScanner scannerWithString:str];
    if ([scanner scanFloat:&value]) {
      return [NSNumber numberWithFloat:value]; 
    }
  }
  return nil;
}

- (void)setTaxPercent:(NSNumber *)num {
  if (num) {
    [self setAttributeWithName:@"tax percent"
                          type:kGDataGoogleBaseAttributeTypeFloat
                     textValue:[num stringValue]];  
  } else {
    [self removeAttributesWithName:@"tax percent" 
                              type:kGDataGoogleBaseAttributeTypeFloat]; 
  }
}

// tax region

- (NSString *)taxRegion {
  return [[self attributeWithName:@"tax region" 
                             type:kGDataGoogleBaseAttributeTypeText] textValue];
}

- (void)setTaxRegion:(NSString *)str {
  [self setAttributeWithName:@"tax region"
                        type:kGDataGoogleBaseAttributeTypeText
                   textValue:str];  
}

// delivery radius

- (NSString *)deliveryRadius {
  return [[self attributeWithName:@"delivery radius" 
                             type:kGDataGoogleBaseAttributeTypeFloatUnit] textValue];
}

- (void)setDeliveryRadius:(NSString*)str {
  [self setAttributeWithName:@"delivery radius"
                        type:kGDataGoogleBaseAttributeTypeFloatUnit
                   textValue:str];  
}

// should pick up

- (NSNumber *)shouldPickUp {
  NSString *str = [[self attributeWithName:@"pickup" 
                                      type:kGDataGoogleBaseAttributeTypeBoolean] textValue];
  if (str) {
    if ([str caseInsensitiveCompare:@"true"] == NSOrderedSame) {
      return [NSNumber numberWithBool:YES];
    } else {
      return [NSNumber numberWithBool:NO];
    }
  }
  return nil;
}

- (void)setShouldPickUp:(NSNumber *)flag {
  if (flag) {
    NSString *textValue = ([flag boolValue] ? @"true" : @"false");
    [self setAttributeWithName:@"pickup"
                          type:kGDataGoogleBaseAttributeTypeBoolean
                     textValue:textValue];  
  } else {
    [self removeAttributesWithName:@"pickup" 
                              type:kGDataGoogleBaseAttributeTypeBoolean];
  }
}

// delivery notes

- (NSString *)deliveryNotes {
  return [[self attributeWithName:@"delivery notes" 
                             type:kGDataGoogleBaseAttributeTypeText] textValue];
}

- (void)setDeliveryNotes:(NSString *)str {
  [self setAttributeWithName:@"delivery notes"
                        type:kGDataGoogleBaseAttributeTypeText
                   textValue:str];  
}

// payment notes

- (NSString *)paymentNotes {
  return [[self attributeWithName:@"payment notes" 
                             type:kGDataGoogleBaseAttributeTypeText] textValue];
}

- (void)setPaymentNotes:(NSString *)str {
  [self setAttributeWithName:@"payment notes"
                        type:kGDataGoogleBaseAttributeTypeText
                   textValue:str];  
}

// customer ID - integer

- (NSNumber *)customerID {
  
  NSString *str = [[self attributeWithName:@"customer id" 
                                      type:kGDataGoogleBaseAttributeTypeInt] textValue];
  if (str) {
    int value = 0;
    NSScanner *scanner = [NSScanner scannerWithString:str];
    if ([scanner scanInt:&value]) {
      return [NSNumber numberWithInt:value]; 
    }
  }
  return nil;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_GOOGLEBASE_SERVICE
