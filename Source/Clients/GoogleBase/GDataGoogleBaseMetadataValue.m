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
//  GDataGoogleBaseMetadataValue.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_GOOGLEBASE_SERVICE

#import "GDataGoogleBaseMetadataValue.h"
#import "GDataEntryGoogleBase.h"

@implementation GDataGoogleBaseMetadataValue
// for values, like <gm:value count='87269'>products</gm:value>


+ (NSString *)extensionElementURI       { return kGDataNamespaceGoogleBaseMetadata; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGoogleBaseMetadataPrefix; }
+ (NSString *)extensionElementLocalName { return @"value"; }

+ (GDataGoogleBaseMetadataValue *)metadataValueWithContents:(NSString *)contents
                                                      count:(NSNumber *)count {
                      
  GDataGoogleBaseMetadataValue *obj = [[[GDataGoogleBaseMetadataValue alloc] init] autorelease];
  [obj setContents:contents];
  [obj setCount:count];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setContents:[self stringValueFromElement:element]];
    
    [self setCount:[self intNumberForAttributeName:@"count"
                                       fromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [contents_ release];
  [count_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataGoogleBaseMetadataValue* newObj = [super copyWithZone:zone];
  [newObj setContents:[self contents]];
  [newObj setCount:[self count]];
  return newObj;
}

- (BOOL)isEqual:(GDataGoogleBaseMetadataValue *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataGoogleBaseMetadataValue class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self contents], [other contents])
    && AreEqualOrBothNil([self count], [other count]);
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:contents_ withName:@"contents"];
  [self addToArray:items objectDescriptionIfNonNil:count_    withName:@"count"];
  
  return items;
}
#endif

- (NSXMLElement *)XMLElement {

  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"gm:value"];
  
  if ([self contents]) {
    [element addStringValue:[self contents]];
  }
  [self addToElement:element attributeValueIfNonNil:[[self count] stringValue] 
                                           withName:@"count"];

  return element;
}

- (NSString *)contents {
  return contents_;
}

- (void)setContents:(NSString *)str {
  [contents_ autorelease];
  contents_ = [str copy];
}

- (NSNumber *)count {
  return count_; 
}

- (void)setCount:(NSNumber *)num {
  [count_ autorelease];
  count_ = [num copy];
}


@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_GOOGLEBASE_SERVICE
