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
//  GDataDeleted.m
//

#import "GDataDeleted.h"

@implementation GDataDeleted
// marker for a deleted entry, as in
// <gd:deleted/>

+ (NSString *)extensionElementURI       { return kGDataNamespaceGData; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementLocalName { return @"deleted"; }

+ (GDataDeleted *)deleted {
  GDataDeleted *obj = [[[self alloc] init] autorelease];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
  }
  return self;
}

- (id)copyWithZone:(NSZone *)zone {
  GDataDeleted* newDeleted = [super copyWithZone:zone];
  return newDeleted;
}

- (BOOL)isEqual:(GDataDeleted *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataDeleted class]]) return NO;
  
  return [super isEqual:other];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@ 0x%lX", [self class], self];
}

- (NSXMLElement *)XMLElement {
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"gd:deleted"];
  return element;
}

@end
