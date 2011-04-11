/* Copyright (c) 2007-2008 Google Inc.
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
//  GDataACLRole.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_ACLS \
  || GDATA_INCLUDE_CALENDAR_SERVICE || GDATA_INCLUDE_DOCS_SERVICE

#define GDATAACLROLE_DEFINE_GLOBALS 1

#import "GDataACLRole.h"

#import "GDataEntryACL.h" // for namespace

static NSString* const kValueAttr = @"value";

@implementation GDataACLRole
// an element with a value attribute, as in
//  <gAcl:role value='owner'></gAcl:role>
//
//  http://code.google.com/apis/calendar/reference.html#gacl_reference

+ (NSString *)extensionElementURI       { return kGDataNamespaceACL; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceACLPrefix; }
+ (NSString *)extensionElementLocalName { return @"role"; }

+ (GDataACLRole *)roleWithValue:(NSString *)value {
  GDataACLRole *obj = [[[self alloc] init] autorelease];
  [obj setValue:value];
  return obj;
}

- (void)addParseDeclarations {
  
  NSArray *attrs = [NSArray arrayWithObject:kValueAttr];
  [self addLocalAttributeDeclarations:attrs];
}

- (NSString *)value {
  return [self stringValueForAttribute:kValueAttr];
}

- (void)setValue:(NSString *)str {
  [self setStringValue:str forAttribute:kValueAttr];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDE || GDATA_INCLUDE_*
