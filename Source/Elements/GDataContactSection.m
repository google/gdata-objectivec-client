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
//  GDataContactSection.m
//

#import "GDataContactSection.h"

#import "GDataIM.h"
#import "GDataEmail.h"
#import "GDataPhoneNumber.h"
#import "GDataPostalAddress.h"
#import "GDataGeoPt.h"

@implementation GDataContactSection
// for contact info
//
//  <gd:contactSection label="Work">
//    <gd:email address="jo@example.com"/>
//    <gd:phoneNumber rel="http://schemas.google.com/g/2005#work">(650) 555-1212</gd:phoneNumber>
//    <gd:phoneNumber rel="http://schemas.google.com/g/2005#pager">(650) 555-1214</gd:phoneNumber>
//    <gd:postalAddress>
//      1600 Amphitheatre Pkwy
//      Mountain View, CA 94043
//    </gd:postalAddress>
//    <gd:geoPt lat="37.423269" lon="-122.082667"/>
//  </gd:contactSection>
//
// http://code.google.com/apis/gdata/common-elements.html#gdContactSection

+ (NSString *)extensionElementURI       { return kGDataNamespaceGData; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementLocalName { return @"contactSection"; }

+ (GDataContactSection *)contactSection {
  return [[[GDataContactSection alloc] init] autorelease]; 
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setLabel:[self stringForAttributeName:@"label" 
                                    fromElement:element]];
    
    [self setEmails:[self objectsForChildrenOfElement:element
                                        qualifiedName:@"gd:email"
                                         namespaceURI:kGDataNamespaceGData
                                          objectClass:[GDataEmail class]]];
    [self setGeoPts:[self objectsForChildrenOfElement:element
                                        qualifiedName:@"gd:geoPt"
                                         namespaceURI:kGDataNamespaceGData
                                          objectClass:[GDataGeoPt class]]];
    [self setIMs:[self objectsForChildrenOfElement:element
                                     qualifiedName:@"gd:im"
                                      namespaceURI:kGDataNamespaceGData
                                       objectClass:[GDataIM class]]];
    [self setPhoneNumbers:[self objectsForChildrenOfElement:element
                                              qualifiedName:@"gd:phoneNumber"
                                               namespaceURI:kGDataNamespaceGData
                                                objectClass:[GDataPhoneNumber class]]];
    [self setPostalAddresses:[self objectsForChildrenOfElement:element
                                                 qualifiedName:@"gd:postalAddress"
                                                  namespaceURI:kGDataNamespaceGData
                                                   objectClass:[GDataPostalAddress class]]];
  }
  return self;
}

- (void)dealloc {
  [label_ release];
  [emails_ release];
  [geoPts_ release];
  [ims_ release];
  [phoneNumbers_ release];
  [postalAddresses_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataContactSection* newObj = [super copyWithZone:zone];
  [newObj setLabel:label_];
  [newObj setEmails:emails_];
  [newObj setGeoPts:geoPts_];
  [newObj setIMs:ims_];
  [newObj setPhoneNumbers:phoneNumbers_];
  [newObj setPostalAddresses:postalAddresses_];
  return newObj;
}

- (BOOL)isEqual:(GDataContactSection *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataContactSection class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self label], [other label])
    && AreEqualOrBothNil([self emails], [other emails])
    && AreEqualOrBothNil([self geoPts], [other geoPts])
    && AreEqualOrBothNil([self IMs], [other IMs])
    && AreEqualOrBothNil([self phoneNumbers], [other phoneNumbers])
    && AreEqualOrBothNil([self postalAddresses], [other postalAddresses]);
}

- (NSString *)description {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:label_ withName:@"label"];
  
  if ([emails_ count]) {
    [self addToArray:items objectDescriptionIfNonNil:emails_ withName:@"emails"];
  }
  if ([geoPts_ count]) {
    [self addToArray:items objectDescriptionIfNonNil:geoPts_ withName:@"geoPts"];
  }
  if ([ims_ count]) {
    [self addToArray:items objectDescriptionIfNonNil:ims_ withName:@"IMs"];
  }
  if ([phoneNumbers_ count]) {
    [self addToArray:items objectDescriptionIfNonNil:phoneNumbers_ withName:@"phoneNumbers"];
  }
  if ([postalAddresses_ count]) {
    [self addToArray:items objectDescriptionIfNonNil:postalAddresses_ withName:@"postalAddresses"];
  }
  
  return [NSString stringWithFormat:@"%@ 0x%lX: {%@}",
    [self class], self, [items componentsJoinedByString:@" "]];
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"gd:contactSection"];
  
  [self addToElement:element attributeValueIfNonNil:[self label] withName:@"label"];
  
  if ([[self emails] count]) {
    [self addToElement:element XMLElementsForArray:[self emails]]; 
  }
  if ([[self geoPts] count]) {
    [self addToElement:element XMLElementsForArray:[self geoPts]]; 
  }
  if ([[self IMs] count]) {
    [self addToElement:element XMLElementsForArray:[self IMs]]; 
  }
  if ([[self phoneNumbers] count]) {
    [self addToElement:element XMLElementsForArray:[self phoneNumbers]]; 
  }
  if ([[self postalAddresses] count]) {
    [self addToElement:element XMLElementsForArray:[self postalAddresses]]; 
  }
  
  return element;
}

- (NSString *)label {
  return label_;
}

- (void)setLabel:(NSString *)str {
  [label_ release];
  label_ = [str copy]; 
}

- (NSArray *)emails {
  return emails_; 
}

- (void)setEmails:(NSArray *)array {
  [emails_ release];
  emails_ = [array mutableCopy];
}

- (void)addEmail:(GDataEmail *)obj {
  if (!emails_) {
    emails_ = [[NSMutableArray alloc] init]; 
  }
  [emails_ addObject:obj];
}

- (NSArray *)geoPts {
  return geoPts_; 
}

- (void)setGeoPts:(NSArray *)array {
  [geoPts_ release];
  geoPts_ = [array mutableCopy];
}

- (void)addGeoPts:(GDataGeoPt *)obj {
  if (!geoPts_) {
    geoPts_ = [[NSMutableArray alloc] init]; 
  }
  [geoPts_ addObject:obj];
}

- (NSArray *)IMs {
  return ims_; 
}

- (void)setIMs:(NSArray *)array {
  [ims_ release];
  ims_ = [array mutableCopy];
}

- (void)addIM:(GDataIM *)obj {
  if (!ims_) {
    ims_ = [[NSMutableArray alloc] init]; 
  }
  [ims_ addObject:obj];
}

- (NSArray *)phoneNumbers {
  return phoneNumbers_; 
}

- (void)setPhoneNumbers:(NSArray *)array {
  [phoneNumbers_ release];
  phoneNumbers_ = [array mutableCopy];
}

- (void)addPhoneNumber:(GDataPhoneNumber *)obj {
  if (!phoneNumbers_) {
    phoneNumbers_ = [[NSMutableArray alloc] init]; 
  }
  [phoneNumbers_ addObject:obj];
}

- (NSArray *)postalAddresses {
  return postalAddresses_; 
}

- (void)setPostalAddresses:(NSArray *)array {
  [postalAddresses_ release];
  postalAddresses_ = [array mutableCopy];
}

- (void)addPostalAddress:(GDataPostalAddress *)obj {
  if (!postalAddresses_) {
    postalAddresses_ = [[NSMutableArray alloc] init]; 
  }
  [postalAddresses_ addObject:obj];
}

@end


