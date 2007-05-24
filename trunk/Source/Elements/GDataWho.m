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
//  GDataWho.m
//

#define GDATAWHO_DEFINE_GLOBALS 1
#import "GDataWho.h"

#import "GDataEntryLink.h"

@implementation GDataAttendeeStatus
+ (NSString *)extensionElementURI       { return kGDataNamespaceGData; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementLocalName { return @"attendeeStatus"; }
@end

@implementation GDataAttendeeType
+ (NSString *)extensionElementURI       { return kGDataNamespaceGData; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementLocalName { return @"attendeeType"; }
@end


@implementation GDataWho
// a who entry, as in
// <gd:who rel="http://schemas.google.com/g/2005#event.organizer" valueString="Greg Robbins" email="test@coldnose.net">
//   <gd:attendeeStatus value="http://schemas.google.com/g/2005#event.accepted"/>
// </gd:who>
//
// http://code.google.com/apis/gdata/common-elements.html#gdWho

+ (NSString *)extensionElementURI       { return kGDataNamespaceGData; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementLocalName { return @"who"; }

+ (GDataWho *)whoWithRel:(NSString *)rel
                    name:(NSString *)valueString
                   email:(NSString *)email {
  GDataWho *obj = [[[GDataWho alloc] init] autorelease];
  [obj setRel:rel];
  [obj setStringValue:valueString];
  [obj setEmail:email];
  return obj;
}
- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setRel:[self stringForAttributeName:@"rel"
                                  fromElement:element]];
    [self setStringValue:[self stringForAttributeName:@"valueString"
                                          fromElement:element]];
    [self setEmail:[self stringForAttributeName:@"email"
                                    fromElement:element]];
    
    [self setAttendeeType:[self objectForChildOfElement:element
                                          qualifiedName:@"gd:attendeeType"
                                           namespaceURI:kGDataNamespaceGData
                                            objectClass:[GDataAttendeeType class]]];
    [self setAttendeeStatus:[self objectForChildOfElement:element
                                            qualifiedName:@"gd:attendeeStatus"
                                             namespaceURI:kGDataNamespaceGData
                                              objectClass:[GDataAttendeeStatus class]]];
    [self setEntryLink:[self objectForChildOfElement:element
                                       qualifiedName:@"gd:entryLink"
                                        namespaceURI:kGDataNamespaceGData
                                         objectClass:[GDataEntryLink class]]];
  }
  return self;
}

- (void)dealloc {
  [rel_ release];
  [email_ release];
  [valueString_ release];
  [attendeeType_ release];
  [attendeeStatus_ release];
  [entryLink_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataWho* newWho = [super copyWithZone:zone];
  [newWho setRel:rel_];
  [newWho setEmail:email_];
  [newWho setStringValue:valueString_];
  [newWho setAttendeeType:attendeeType_];
  [newWho setAttendeeStatus:attendeeStatus_];
  [newWho setEntryLink:entryLink_];
  return newWho;
}

- (BOOL)isEqual:(GDataWho *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataWho class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self rel], [other rel])
    && AreEqualOrBothNil([self email], [other email])
    && AreEqualOrBothNil([self stringValue], [other stringValue])
    && AreEqualOrBothNil([self attendeeType], [other attendeeType])
    && AreEqualOrBothNil([self attendeeStatus], [other attendeeStatus])
    && AreEqualOrBothNil([self entryLink], [other entryLink]);
}

- (NSString *)description {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:rel_ withName:@"rel"];
  [self addToArray:items objectDescriptionIfNonNil:valueString_ withName:@"valueString"];
  [self addToArray:items objectDescriptionIfNonNil:email_ withName:@"email"];
  [self addToArray:items objectDescriptionIfNonNil:attendeeType_ withName:@"attendeeType"];
  [self addToArray:items objectDescriptionIfNonNil:attendeeStatus_ withName:@"attendeeStatus"];
  [self addToArray:items objectDescriptionIfNonNil:entryLink_ withName:@"entryLink"];

  return [NSString stringWithFormat:@"%@ 0x%lX: {%@}",
    [self class], self, [items componentsJoinedByString:@" "]];
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"gd:who"];
  
  [self addToElement:element attributeValueIfNonNil:[self rel]        withName:@"rel"];
  [self addToElement:element attributeValueIfNonNil:[self stringValue] withName:@"valueString"];
  [self addToElement:element attributeValueIfNonNil:[self email]       withName:@"email"];

  if ([self attendeeStatus]) {
    [element addChild:[[self attendeeStatus] XMLElement]];
  }
  if ([self attendeeType]) {
    [element addChild:[[self attendeeType] XMLElement]]; 
  }
  if ([self entryLink]) {
    [element addChild:[[self entryLink] XMLElement]]; 
  }
  
  return element;
}

- (NSString *)rel {
  return rel_;
}

- (void)setRel:(NSString *)str {
  [rel_ autorelease];
  rel_ = [str copy];
}

- (NSString *)email {
  return email_;
}

- (void)setEmail:(NSString *)str {
  [email_ autorelease];
  email_ = [str copy];
}

- (NSString *)stringValue {
  return valueString_;
}

- (void)setStringValue:(NSString *)str {
  [valueString_ autorelease];
  valueString_ = [str copy];
}

- (GDataAttendeeType *)attendeeType {
  return attendeeType_;
}

- (void)setAttendeeType:(GDataAttendeeType *)val {
  [attendeeType_ autorelease];
  attendeeType_ = [val copy];
}

- (GDataAttendeeStatus *)attendeeStatus {
  return attendeeStatus_;
}

- (void)setAttendeeStatus:(GDataAttendeeStatus *)val {
  [attendeeStatus_ autorelease];
  attendeeStatus_ = [val copy];
}

- (GDataEntryLink *)entryLink {
  return entryLink_;
}

- (void)setEntryLink:(GDataEntryLink *)entryLink {
  [entryLink_ autorelease];
  entryLink_ = [entryLink retain];
}

@end

