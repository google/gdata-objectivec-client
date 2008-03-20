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
//  GDataMediaCredit.m
//


#import "GDataMediaCredit.h"
#import "GDataMediaGroup.h"

@implementation GDataMediaCredit
// like <media:credit role="producer" scheme="urn:ebu">entity name</media:credit>
// http://search.yahoo.com/mrss

+ (NSString *)extensionElementURI       { return kGDataNamespaceMedia; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceMediaPrefix; }
+ (NSString *)extensionElementLocalName { return @"credit"; }

+ (GDataMediaCredit *)mediaCreditWithString:(NSString *)str {
  GDataMediaCredit* obj = [[[GDataMediaCredit alloc] init] autorelease];
  [obj setStringValue:str];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setRole:[self stringForAttributeName:@"role"
                                     fromElement:element]];
    [self setScheme:[self stringForAttributeName:@"scheme"
                                          fromElement:element]];
    [self setStringValue:[self stringValueFromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [role_ release];
  [scheme_ release];
  [content_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataMediaCredit* newObj = [super copyWithZone:zone];
  [newObj setRole:[self role]];
  [newObj setScheme:[self scheme]];
  [newObj setStringValue:[self stringValue]];
  return newObj;
}

- (BOOL)isEqual:(GDataMediaCredit *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataMediaCredit class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self role], [other role])
    && AreEqualOrBothNil([self scheme], [other scheme])
    && AreEqualOrBothNil([self stringValue], [other stringValue]);
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:role_ withName:@"role"];
  [self addToArray:items objectDescriptionIfNonNil:scheme_ withName:@"scheme"];
  
  if ([content_ length]) {
    [self addToArray:items objectDescriptionIfNonNil:content_ withName:@"content"];
  }

  return items;
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"media:credit"];
  
  [self addToElement:element attributeValueIfNonNil:role_ withName:@"role"];
  [self addToElement:element attributeValueIfNonNil:scheme_ withName:@"scheme"];
  if ([content_ length]) {
    [element addStringValue:content_]; 
  }

  return element;
}

- (NSString *)role {
  return role_; 
}

- (void)setRole:(NSString *)str {
  [role_ autorelease];
  role_ = [str copy];
}

- (NSString *)scheme {
  return scheme_; 
}

- (void)setScheme:(NSString *)str {
  [scheme_ autorelease];
  scheme_ = [str copy];
}

- (NSString *)stringValue {
  return content_;
}

- (void)setStringValue:(NSString *)str {
  [content_ autorelease];
  content_ = [str copy]; 
}

@end


