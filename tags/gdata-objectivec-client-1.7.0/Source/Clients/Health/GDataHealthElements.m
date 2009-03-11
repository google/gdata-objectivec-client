/* Copyright (c) 2009 Google Inc.
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
//  GDataHealthElements.m
//

#import "GDataHealthElements.h"
#import "GDataEntryHealthProfile.h"


// a CCR element, like
//
// <ContinuityOfCareRecord xmlns="urn:astm-org:CCR"> 
//   ...
// </ContinuityOfCareRecord>

@implementation GDataContinuityOfCareRecord

+ (NSString *)extensionElementURI       { return kGDataNamespaceCCR; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceCCRPrefix; }
+ (NSString *)extensionElementLocalName { return @"ContinuityOfCareRecord"; }

- (void)addParseDeclarations {
  [self addChildXMLElementsDeclaration];
}

@end

// a ProfileMetaData element, like
//
// <h9m:ProfileMetaData> 
//   ...
// </h9m:ProfileMetaData>

@implementation GDataProfileMetaData

+ (NSString *)extensionElementURI       { return kGDataNamespaceH9M; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceH9MPrefix; }
+ (NSString *)extensionElementLocalName { return @"ProfileMetaData"; }

- (void)addParseDeclarations {
  [self addChildXMLElementsDeclaration];
}

@end
