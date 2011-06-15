/* Copyright (c) 2008 Google Inc.
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
//  GDataSiteVerificationMethod.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE

#define GDATASITEVERIFICATIONMETHOD_DEFINE_GLOBALS 1
#import "GDataSiteVerificationMethod.h"

#import "GDataWebmasterToolsConstants.h"

static NSString* const kTypeAttr = @"type";
static NSString* const kInUseAttr = @"in-use";

// Verification method elements, like
//
//  <wt:verification-method type="metatag" in-use="false">
//    <meta name="verify-v1" content="a2Ai" />
//  </wt:verification-method>
//
// and
//
//  <wt:verification-method type="htmlpage" in-use="true">456456-google.html
//                 </wt:verification-method>
//
//
// http://code.google.com/apis/webmastertools/docs/reference.html

@implementation GDataSiteVerificationMethod

+ (NSString *)extensionElementPrefix { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementURI { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementLocalName { return @"verification-method"; }

+ (id)verificationMethodWithType:(NSString *)type
                           value:(NSString *)value
                         isInUse:(BOOL)isInUse {
  
  GDataSiteVerificationMethod *obj;
  obj = [self object];
  
  [obj setType:type];
  [obj setValue:value];
  [obj setIsInUse:isInUse];
  
  return obj;
}

- (void)addParseDeclarations {
  
  NSArray *attrs = [NSArray arrayWithObjects:
                    kTypeAttr, kInUseAttr, nil];
  
  [self addLocalAttributeDeclarations:attrs];    
  
  [self addContentValueDeclaration];

  [self addChildXMLElementsDeclaration];
}

#pragma mark -

- (NSString *)type {
  return [self stringValueForAttribute:kTypeAttr];
}

- (void)setType:(NSString *)str {
  [self setStringValue:str forAttribute:kTypeAttr];
}

- (BOOL)isInUse {
  return [self boolValueForAttribute:kInUseAttr defaultValue:NO];
}

- (void)setIsInUse:(BOOL)flag {
  [self setBoolValue:flag defaultValue:NO forAttribute:kInUseAttr];
}

- (NSString *)value {
  // do we need to look differently for a meta tag?
  return [self contentStringValue]; 
}

- (void)setValue:(NSString *)value {
  [self setContentStringValue:value]; 
}

- (NSArray *)XMLValues {
  return [super childXMLElements];
}

- (void)setXMLValues:(NSArray *)arr {
  [self setChildXMLElements:arr]; 
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE
