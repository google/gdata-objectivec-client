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
//  GDataEntryGoogleBase.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_GOOGLEBASE_SERVICE

#import "GDataEntryBase.h"
#import "GDataLink.h"

#import "GDataGoogleBaseAttribute.h"
#import "GDataGoogleBaseMetadataAttribute.h"
#import "GDataGoogleBaseMetadataAttributeList.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAENTRYGOOGLEBASE_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataGoogleBaseDefaultServiceVersion _INITIALIZE_AS(@"2.0");

_EXTERN NSString* const kGDataNamespaceGoogleBase _INITIALIZE_AS(@"http://base.google.com/ns/1.0");
_EXTERN NSString* const kGDataNamespaceGoogleBasePrefix _INITIALIZE_AS(@"g");
_EXTERN NSString* const kGDataNamespaceGoogleBaseMetadata _INITIALIZE_AS(@"http://base.google.com/ns-metadata/1.0");
_EXTERN NSString* const kGDataNamespaceGoogleBaseMetadataPrefix _INITIALIZE_AS(@"gm");

_EXTERN NSString* const kGDataCategoryGoogleBaseItemTypesScheme _INITIALIZE_AS(@"http://base.google.com/categories/itemtypes");

_EXTERN NSString* const kGDataGoogleBaseAttributeTypeText _INITIALIZE_AS(@"text");
_EXTERN NSString* const kGDataGoogleBaseAttributeTypeNumber _INITIALIZE_AS(@"number");
_EXTERN NSString* const kGDataGoogleBaseAttributeTypeInt _INITIALIZE_AS(@"int");
_EXTERN NSString* const kGDataGoogleBaseAttributeTypeFloat _INITIALIZE_AS(@"float");
_EXTERN NSString* const kGDataGoogleBaseAttributeTypeNumberUnit _INITIALIZE_AS(@"numberUnit");
_EXTERN NSString* const kGDataGoogleBaseAttributeTypeIntUnit _INITIALIZE_AS(@"intUnit");
_EXTERN NSString* const kGDataGoogleBaseAttributeTypeFloatUnit _INITIALIZE_AS(@"floatUnit");
_EXTERN NSString* const kGDataGoogleBaseAttributeTypeDateTimeRange _INITIALIZE_AS(@"dateTimeRange");
_EXTERN NSString* const kGDataGoogleBaseAttributeTypeDate _INITIALIZE_AS(@"date");
_EXTERN NSString* const kGDataGoogleBaseAttributeTypeDateTime _INITIALIZE_AS(@"dateTime");
_EXTERN NSString* const kGDataGoogleBaseAttributeTypeURL _INITIALIZE_AS(@"url");
_EXTERN NSString* const kGDataGoogleBaseAttributeTypeBoolean _INITIALIZE_AS(@"boolean");
_EXTERN NSString* const kGDataGoogleBaseAttributeTypeShipping _INITIALIZE_AS(@"shipping");
_EXTERN NSString* const kGDataGoogleBaseAttributeTypeLocation _INITIALIZE_AS(@"location");


@interface GDataEntryGoogleBase : GDataEntryBase {
}

+ (NSDictionary *)googleBaseNamespaces;

+ (GDataEntryGoogleBase *)googleBaseEntryForCategoryTerm:(NSString *)term;

// all four kinds of children are stored as extensions to the entry object
// so these setters and getters just call into the GDataObject extension 
// methods

// Attributes are regular Google Base snippet attributes:
// arbitrary Google Base attribute, like in a snippets feed
// http://code.google.com/apis/base/snippets-feed.html
//
//  <entry>
//   <g:expiration_date type="dateTime">2006-07-01T23:22:59.000Z</g:expiration_date>
//   <g:label type="text">Products</g:label>
//   <g:customer_id type="int">1182756</g:customer_id>
//   <g:currency type="text">USD</g:currency>
//   <g:location type="location">ONE GARDEN STATE PLAZA, PARAMUS, NJ 07652, US</g:location> 
//   <g:id type="text">3916610899---2501539</g:id>
//   <g:price type="floatUnit">19.950000762939453 usd</g:price>
//   <g:item_type type="text">Products</g:item_type>
//   <g:image_link type="url">http://catalogs.shoplocal.com/lib/DiscoveryStore/Library/b_730408_xl.jpg</g:image_link>
//  </entry>

- (NSArray *)entryAttributes;
- (void)setEntryAttributes:(NSArray *)attrs;
- (void)addEntryAttribute:(GDataGoogleBaseAttribute *)attr;

// Metadata Attributes are from attribute feeds, and contain values
// http://code.google.com/apis/base/attributes-feed.html
//
//  <entry>
//    <gm:attribute name='job industry' type='text' count='4416629'>
//      <gm:value count='380772'>it internet</gm:value>
//      <gm:value count='261565'>healthcare</gm:value>
//      <gm:value count='142018'>information technology</gm:value>
//      <gm:value count='124622'>accounting</gm:value>
//      <gm:value count='111311'>clerical&administrative</gm:value>
//      <gm:value count='82928'>other</gm:value>
//      <gm:value count='77620'>sales&sales management</gm:value>
//      <gm:value count='68764'>information systems</gm:value>
//      <gm:value count='65859'>engineering&architecture</gm:value>
//      <gm:value count='64757'>sales</gm:value>
//    </gm:attribute>
//  </entry>

- (NSArray *)metadataAttributes;
- (void)setMetadataAttributes:(NSArray *)attrs;
- (void)addMetadataAttribute:(GDataGoogleBaseMetadataAttribute *)attr;

// The Metadata Attributes List is provided by item type feeds
// (along with a metadata item type)
// http://code.google.com/apis/base/itemtypes-feed.html  
//
//  <entry>
//      <gm:item_type>jobs</gm:item_type>
//      <gm:attributes>
//        <gm:attribute name="job type" type="text"/>
//        <gm:attribute name="job industry" type="text"/>
//        <gm:attribute name="job function" type="text"/>
//        <gm:attribute name="employer" type="text"/>
//        <gm:attribute name="expiration date" type="dateTime"/>
//        <gm:attribute name="pickup" type="boolean"/>
//        <gm:attribute name="location" type="location"/>
//      </gm:attributes>
//  </entry> 

- (GDataGoogleBaseMetadataAttributeList *)metadataAttributeList;
- (void)setMetadataAttributeList:(GDataGoogleBaseMetadataAttributeList *)attrs;

- (NSString *)metadataItemType;
- (void)setMetadataItemType:(NSString *)itemType;

// convenience utilities for attributes

// Name and/or type may be nil to match any attributes.
// Type can be equal to or a subtype of the found attribute.
- (NSArray *)attributesWithName:(NSString *)name
                           type:(NSString *)type;

- (GDataGoogleBaseAttribute *)attributeWithName:(NSString *)name
                                           type:(NSString *)type;

- (void)removeAttributesWithName:(NSString *)name
                            type:(NSString *)type;

- (void)setAttributeWithName:(NSString *)name
                        type:(NSString *)type
                   textValue:(NSString *)value;

- (NSArray *)stringValuesForAttributes:(NSArray *)attributes;

// attributeDictionary returns a dictionary of attributes, with
// xml element names as keys, and each value an NSArray of
// GDataGoogleBaseAttribute objects.  This is to facilitate
// key-value coding access to the attributes
- (NSDictionary *)attributeDictionary;

// convenience setters/getters for known kinds of attributes

- (NSArray *)labels;
- (void)addLabel:(NSString *)label;

- (NSString *)itemType;
- (void)setItemType:(NSString *)str;

- (GDataDateTime *)expirationDate;
- (void)setExpirationDate:(GDataDateTime *)dateTime;

- (NSString *)imageLink;
- (NSArray *)imageLinks;
- (void)addImageLink:(NSString *)str;

- (NSArray *)paymentMethods;
- (void)addPaymentMethod:(NSString *)str;

- (NSString *)price;
- (void)setPrice:(NSString *)numberUnit;

- (NSString *)location;
- (void)setLocation:(NSString *)str;

- (NSString *)priceType;
- (void)setPriceType:(NSString *)str;

- (NSNumber *)quantity;
- (void)setQuantity:(NSNumber *)num;

- (NSString *)priceUnits;
- (void)setPriceUnits:(NSString *)str;

- (NSArray *)shippings;
- (void)addShipping:(NSString *)shipping;

- (NSNumber *)taxPercent;
- (void)setTaxPercent:(NSNumber *)num;

- (NSString *)taxRegion;
- (void)setTaxRegion:(NSString *)str;

- (NSString *)deliveryRadius;
- (void)setDeliveryRadius:(NSString *)str;

- (NSNumber *)shouldPickUp;
- (void)setShouldPickUp:(NSNumber *)flag;

- (NSString *)deliveryNotes;
- (void)setDeliveryNotes:(NSString *)str;

- (NSString *)paymentNotes;
- (void)setPaymentNotes:(NSString *)str;

- (NSNumber *)customerID;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_GOOGLEBASE_SERVICE
