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
//  GDataValueConstruct.m
//

#import "GDataValueConstruct.h"

@implementation GDataValueConstruct
// an element with a value="" attribute, as in
// <gCal:timezone value="America/Los_Angeles"/>
// (subclasses may override the attribute name,
// or return nil for it to indicate the value is
// in the child node text)


// convenience functions
//
// subclasses may re-use call into these convenience functions
// and coerce the return type appropriately

+ (id)valueWithString:(NSString *)str {
  GDataValueConstruct* obj = [[[[self class] alloc] init] autorelease];
  [obj setStringValue:str];
  return obj;
}

+ (id)valueWithNumber:(NSNumber *)num {
  GDataValueConstruct* obj = [[[[self class] alloc] init] autorelease];
  [obj setStringValue:[num stringValue]];
  return obj;
}

+ (id)valueWithInt:(int)val {
  GDataValueConstruct* obj = [[[[self class] alloc] init] autorelease];
  [obj setIntValue:val];
  return obj;
}

+ (id)valueWithLongLong:(long long)val {
  GDataValueConstruct* obj = [[[[self class] alloc] init] autorelease];
  [obj setLongLongValue:val];
  return obj;
}

+ (id)valueWithDouble:(double)val {
  GDataValueConstruct* obj = [[[[self class] alloc] init] autorelease];
  [obj setDoubleValue:val];
  return obj;
}

+ (id)valueWithBool:(BOOL)flag {
  GDataValueConstruct* obj = [[[[self class] alloc] init] autorelease];
  [obj setBoolValue:flag];
  return obj;
}

#pragma mark -

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    NSString *attrName = [self attributeName];
    if (attrName) {
      // use the named attribute
      [self setStringValue:[self stringForAttributeName:attrName
                                            fromElement:element]];
    } else {
      // no named attribute; use the child node text
      [self setStringValue:[self stringValueFromElement:element]];
    }
  }
  return self;
}

- (void)dealloc {
  [value_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataValueConstruct* newValue = [super copyWithZone:zone];
  [newValue setStringValue:value_];
  return newValue;
}

- (BOOL)isEqual:(GDataValueConstruct *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataValueConstruct class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self stringValue], [other stringValue]);
}

- (NSString *)description {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:value_ withName:@"value"];
  
  return [NSString stringWithFormat:@"%@ 0x%lX: {%@}",
    [self class], self, [items componentsJoinedByString:@" "]];
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:nil];

  NSString *attrName = [self attributeName];
  
  if (attrName) {
    // add as attribute
    [self addToElement:element attributeValueIfNonNil:[self stringValue] withName:[self attributeName]];
  } else {
    // add as child node text
    if ([[self stringValue] length] > 0) {
      [element addStringValue:[self stringValue]];
    }
  }
  
  return element;
}

- (NSString *)stringValue {
  return value_; 
}

- (void)setStringValue:(NSString *)str {
  [value_ autorelease];
  value_ = [str copy];
}

- (NSString *)attributeName {
  // subclasses can override if they store their value under a different
  // attribute name, or can return nil to indicate the value is in the child
  // node text
  return @"value";
}

// subclass value utilities

- (int)intValue {
  NSString *str = [self stringValue];
  if (str) {
    int result;
    NSScanner *scanner = [NSScanner scannerWithString:str];
    if ([scanner scanInt:&result]) {
      return result; 
    }
  }
  return nil;
}

- (NSNumber *)intNumberValue {
  return [NSNumber numberWithInt:[self intValue]];
}

- (void)setIntValue:(int)val {
  NSString *str = [[NSNumber numberWithInt:val] stringValue];
  [self setStringValue:str];
}

- (long long)longLongValue {
  NSString *str = [self stringValue];
  if (str) {
    long long result;
    NSScanner *scanner = [NSScanner scannerWithString:str];
    if ([scanner scanLongLong:&result]) {
      return result; 
    }
  }
  return nil;
}

- (NSNumber *)longLongNumberValue {
  return [NSNumber numberWithLongLong:[self longLongValue]];
}

- (void)setLongLongValue:(long long)val {
  NSString *str = [[NSNumber numberWithLongLong:val] stringValue];
  [self setStringValue:str];
}

- (double)doubleValue {
  NSString *str = [self stringValue];
  if (str) {
    double result;
    NSScanner *scanner = [NSScanner scannerWithString:str];
    if ([scanner scanDouble:&result]) {
      return result; 
    }
  }
  return nil;
}

- (NSNumber *)doubleNumberValue {
  return [NSNumber numberWithDouble:[self doubleValue]];
}

- (void)setDoubleValue:(double)val {
  NSString *str = [[NSNumber numberWithDouble:val] stringValue];
  [self setStringValue:str];
}

- (BOOL)boolValue {
  NSString *value = [self stringValue];
  if (value) {
    return ([value caseInsensitiveCompare:@"true"] == NSOrderedSame);
  }
  return NO;
}

- (NSNumber *)boolNumberValue {
  return [NSNumber numberWithBool:[self boolValue]];
}

- (void)setBoolValue:(BOOL)flag {
  [self setStringValue:(flag ? @"true" : @"false")];
}

@end

@implementation GDataValueElementConstruct // derives from GDataValueConstruct
- (NSString *)attributeName {
  // return nil to indicate the value is contained in the child text nodes
  return nil;  
}
@end

@implementation GDataBoolValueConstruct // derives from GDataValueConstruct

+ (id)boolValueWithBool:(BOOL)flag {
  return [super valueWithBool:flag];
}


@end
