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

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_HEALTH_SERVICE

#import "GDataHealthElements.h"
#import "GDataHealthConstants.h"


// a CCR element, like
//
// <ContinuityOfCareRecord xmlns="urn:astm-org:CCR">
//   ...
// </ContinuityOfCareRecord>

@implementation GDataContinuityOfCareRecord
+ (NSString *)extensionElementURI       { return kGDataNamespaceCCR; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceCCRPrefix; }
+ (NSString *)extensionElementLocalName { return @"ContinuityOfCareRecord"; }
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
@end


@implementation GDataHealthContainerObject

- (GDataObject *)initWithXMLElement:(NSXMLElement *)element {
  self = [super init];
  if (self != nil) {
    GDATA_DEBUG_ASSERT([[element localName] isEqual:[[self class] extensionElementLocalName]],
                       @"element name %@ (expected %@)", [element localName],
                       [[self class] extensionElementLocalName]);

    // Add the children from the XML element to the GData object. Because
    // NSXMLNodes cannot have two parents, we need to add copies of the children
    NSArray *children = [element children];
    NSArray *childCopies = [GDataUtilities arrayWithCopiesOfObjectsInArray:children];
    [self setChildXMLElements:childCopies];

    // Make the new object also have the same namespaces defined in the
    // NSXMLElement so the children are valid
    NSDictionary *ns = [[self class] dictionaryForElementNamespaces:element];
    [self setNamespaces:ns];
  }
  return self;
}

+ (id)objectWithXMLElement:(NSXMLElement *)element {
  return [[[self alloc] initWithXMLElement:element] autorelease];
}

- (void)addParseDeclarations {
  [self addChildXMLElementsDeclaration];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_HEALTH_SERVICE
