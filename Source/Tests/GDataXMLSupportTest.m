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
//  GDataXMLSupportTest.m
//

#import <SenTestingKit/SenTestingKit.h>

#import "GData/GData.h"

#import "GDataXMLNode.h"

@interface GDataXMLSupportTest : SenTestCase
@end

@implementation GDataXMLSupportTest

- (void)runNodesAndNamespacesTestUsingShim:(BOOL)shouldUseShim {

  NSLog(@"Nodes and ns test %@ shim", shouldUseShim ? @"with" : @"without");

  // since we don't want the GDataDefines macros to replace NSXMLNode
  // with GDataXMLNode, we'll use strings to make the classes
  Class cXMLNode = NSClassFromString(shouldUseShim ?
                                     @"GDataXMLNode" : @"NSXMLNode");
  Class cXMLElement = NSClassFromString(shouldUseShim ?
                                        @"GDataXMLElement" : @"NSXMLElement");

  // create elements and attributes

  // create with URI and local name
  NSXMLElement *attr1 = [cXMLElement attributeWithName:@"foo"
                                                   URI:kGDataNamespaceGData
                                           stringValue:@"baz"];
  NSXMLElement *child1 = [cXMLElement elementWithName:@"chyld"
                                                  URI:kGDataNamespaceGData];
  [child1 setStringValue:@"fuzz"];

  // create with URI and prefix
  NSXMLElement *attr2 = [cXMLElement attributeWithName:@"openSearch:foo"
                                           stringValue:@"baz2"];
  NSXMLElement *child2 = [cXMLElement elementWithName:@"openSearch:chyld"];
  [child2 setStringValue:@"fuzz2"];

  // create with unqualified local name
  NSXMLElement *child3 = [cXMLElement elementWithName:@"chyld"];
  [child3 setStringValue:@"fuzz3"];

  NSXMLElement *child3temp = nil;
  if (shouldUseShim) {
    // create a child we'll later remove (GDataXMLElement API only)
    child3temp = [cXMLElement elementWithName:@"childTemp"];
    [child3temp setStringValue:@"scorch"];
  }

  // create with a missing namespace URI that we'll never actually add,
  // so we can test searches based on our faked use of {uri}: as
  // a prefix for the local name
  NSXMLElement *attr4 = [cXMLElement attributeWithName:@"zorgbot"
                                                   URI:kGDataNamespaceBatch
                                           stringValue:@"gollyfum"];
  NSXMLElement *child4 = [cXMLElement elementWithName:@"zorgtree"
                                                  URI:kGDataNamespaceBatch];
  [child4 setStringValue:@"gollyfoo"];

  // create an element with a local namespace not defined in the parent level
  NSString *lonerURI = @"http://loner.ns";
  NSXMLElement *child5 = [cXMLElement elementWithName:@"ln:loner"
                                                  URI:lonerURI];
  NSXMLNode *ns5 = [cXMLNode namespaceWithName:@"ln"
                                   stringValue:lonerURI];
  [child5 addNamespace:ns5];

  // add these to a parent element, along with namespaces
  NSXMLElement *parent = [cXMLElement elementWithName:@"dad"];
  [parent setStringValue:@"buzz"];

  // atom is the default namespace
  NSXMLNode *nsAtom = [cXMLNode namespaceWithName:@""
                                      stringValue:kGDataNamespaceAtom];
  [parent addNamespace:nsAtom];

  NSXMLNode *nsGD = [cXMLNode namespaceWithName:@"gd"
                                    stringValue:kGDataNamespaceGData];
  [parent addNamespace:nsGD];

  NSXMLNode *nsOpenSearch = [cXMLNode namespaceWithName:@"openSearch"
                                            stringValue:kGDataNamespaceOpenSearch];
  [parent addNamespace:nsOpenSearch];

  [parent addChild:child1];
  [parent addAttribute:attr1];
  [parent addChild:child2];
  [parent addAttribute:attr2];
  [parent addChild:child3];
  if (shouldUseShim) {
    [parent addChild:child3temp];
  }

  [parent addChild:child4];
  [parent addAttribute:attr4];
  [parent addChild:child5];

  if (shouldUseShim) {
    // remove the temp child; we must obtain it from the tree, not use
    // the copy we added above
    NSArray *childrenToRemove = [parent elementsForName:@"childTemp"];
    STAssertEquals((int)[childrenToRemove count], 1, @"childTemp not found");

    GDataXMLNode *childToRemove = [childrenToRemove objectAtIndex:0];
    [(GDataXMLElement *)parent removeChild:childToRemove];

    childrenToRemove = [parent elementsForName:@"childTemp"];
    STAssertEquals((int)[childrenToRemove count], 0, @"childTemp still found");
  }

  // search for attr1 and child1 by qualified name, since they were
  // created by URI
  NSXMLNode *attr1Found = [parent attributeForName:@"gd:foo"];
  STAssertEqualObjects([attr1Found stringValue], @"baz", @"attribute gd:foo");

  NSArray *elements = [parent elementsForName:@"gd:chyld"];
  STAssertEquals((int)[elements count], 1, @"getting gd:chyld");
  NSXMLNode *child1Found = [elements objectAtIndex:0];
  STAssertEqualObjects([child1Found stringValue], @"fuzz", @"child gd:chyld");

  // search for attr2 and child2 by local name and URI, since they were
  // created by qualified names
  NSXMLNode *attr2Found = [parent attributeForLocalName:@"foo"
                                                    URI:kGDataNamespaceOpenSearch];
  STAssertEqualObjects([attr2Found stringValue], @"baz2", @"attribute openSearch:foo");

  NSArray *elements2 = [parent elementsForLocalName:@"chyld"
                                                URI:kGDataNamespaceOpenSearch];

  STAssertEquals((int)[elements2 count], 1, @"getting openSearch:chyld");
  NSXMLNode *child2Found = [elements2 objectAtIndex:0];
  STAssertEqualObjects([child2Found stringValue], @"fuzz2", @"child openSearch:chyld");

  // search for child3 by local name
  NSArray *elements3 = [parent elementsForName:@"chyld"];
  STAssertEquals((int)[elements3 count], 1, @"getting chyld");
  NSXMLNode *child3Found = [elements3 objectAtIndex:0];
  STAssertEqualObjects([child3Found stringValue], @"fuzz3", @"child chyld");

  // search for child3 by URI
  NSArray *elements3a = [parent elementsForLocalName:@"chyld"
                                                 URI:kGDataNamespaceAtom];
  STAssertEquals((int)[elements3a count], 1, @"getting chyld (URI");
  NSXMLNode *child3aFound = [elements3 objectAtIndex:0];
  STAssertEqualObjects([child3aFound stringValue], @"fuzz3", @"child chyld");

  // search for attr4 and child4 by local name and URI, since they were
  // created by URI and never bound to a prefix by a namespace declaration
  NSXMLNode *attr4Found = [parent attributeForLocalName:@"zorgbot"
                                                    URI:kGDataNamespaceBatch];
  STAssertEqualObjects([attr4Found stringValue], @"gollyfum", @"in test batch zorgbot");

  NSArray *elements4 = [parent elementsForLocalName:@"zorgtree"
                                                URI:kGDataNamespaceBatch];
  STAssertEquals((int)[elements4 count], 1, @"getting batch zorgtree");
  NSXMLNode *child4Found = [elements4 objectAtIndex:0];
  STAssertEqualObjects([child4Found stringValue], @"gollyfoo", @"in test batch zorgtree");

  // search for child 5 by local name and URI, since it has a locally-defined
  // namespace
  NSArray *elements5 = [parent elementsForLocalName:@"loner"
                                                URI:lonerURI];
  STAssertEquals((int)[elements5 count], 1, @"getting loner");

  // test output
  NSString *expectedXML;
  if (shouldUseShim) {
    expectedXML = @"<dad xmlns=\"http://www.w3.org/2005/Atom\" "
    "xmlns:gd=\"http://schemas.google.com/g/2005\" "
    "xmlns:openSearch=\"http://a9.com/-/spec/opensearch/1.1/\" "
    "gd:foo=\"baz\" openSearch:foo=\"baz2\" "
    "{http://schemas.google.com/gdata/batch}:zorgbot=\"gollyfum\">"
    "buzz<gd:chyld>fuzz</gd:chyld><openSearch:chyld>fuzz2</openSearch:chyld>"
    "<chyld>fuzz3</chyld><{http://schemas.google.com/gdata/batch}:zorgtree>"
    "gollyfoo</{http://schemas.google.com/gdata/batch}:zorgtree>"
    "<ln:loner xmlns:ln=\"http://loner.ns\"/></dad>";
  } else {
    expectedXML = @"<dad xmlns=\"http://www.w3.org/2005/Atom\" "
    "xmlns:gd=\"http://schemas.google.com/g/2005\" "
    "xmlns:openSearch=\"http://a9.com/-/spec/opensearch/1.1/\" "
    "foo=\"baz\" openSearch:foo=\"baz2\" zorgbot=\"gollyfum\">"
    "buzz<chyld>fuzz</chyld><openSearch:chyld>fuzz2</openSearch:chyld>"
    "<chyld>fuzz3</chyld><zorgtree>gollyfoo</zorgtree>"
    "<ln:loner xmlns:ln=\"http://loner.ns\"></ln:loner></dad>";
  }

  NSString *actualXML = [parent XMLString];
  STAssertEqualObjects(actualXML, expectedXML, @"unexpected xml output");
}


- (void)testNodesAndNamespaces {
  [self runNodesAndNamespacesTestUsingShim:NO];
  [self runNodesAndNamespacesTestUsingShim:YES];
}

- (void)runXPathTestUsingShim:(BOOL)shouldUseShim {

  NSLog(@"XPath test %@ shim", shouldUseShim ? @"with" : @"without");

  // since we don't want the GDataDefines macros to replace NSXMLDocument
  // with GDataXMLDocument, we'll use strings to make the classes
  Class cXMLDocument = NSClassFromString(shouldUseShim ?
                                       @"GDataXMLDocument" : @"NSXMLDocument");

  // read in a big feed
  NSError *error = nil;
  NSStringEncoding encoding = 0;

  NSString *contactFeedXML = [NSString stringWithContentsOfFile:@"Tests/FeedContactTest1.xml"
                                                   usedEncoding:&encoding
                                                          error:&error];
  NSData *data = [contactFeedXML dataUsingEncoding:NSUTF8StringEncoding];

  NSXMLDocument *xmlDocument;

  xmlDocument = [[(NSXMLDocument *)[cXMLDocument alloc] initWithData:data
                                                              options:0
                                                                error:&error] autorelease];
  STAssertNotNil(xmlDocument, @"could not allocate feed from xml");
  STAssertNil(error, @"error allocating feed from xml");

  // I'd like to test namespace-uri here, too, but that fails in NSXML's XPath
  NSXMLElement *root = [xmlDocument rootElement];
  NSString *path = @"*[local-name()='category']";

  NSArray *nodes = [root nodesForXPath:path error:&error];
  STAssertEquals((int)[nodes count], 1, @"XPath count");
  STAssertNil(error, @"XPath error");

  if (shouldUseShim) {
    // NSXML's XPath doesn't seem to deal with URI's properly

    // find elements with the default namespace URI
    path = @"*[namespace-uri()='http://www.w3.org/2005/Atom']";

    nodes = [root nodesForXPath:path error:&error];

    STAssertEquals((int)[nodes count], 10, @"XPath count for default ns");
    STAssertNil(error, @"XPath error");

    // find elements with a non-default namespace URI
    path = @"*[namespace-uri()='http://a9.com/-/spec/opensearch/1.1/']";

    // find the opensearch nodes
    nodes = [root nodesForXPath:path error:&error];

    STAssertEquals((int)[nodes count], 3, @"XPath count for opensearch ns");
    STAssertNil(error, @"XPath error");

    // find nodes with the default atom namespace
    path = @"_def_ns:entry/_def_ns:link"; // four entry link nodes
    nodes = [root nodesForXPath:path error:&error];

    STAssertEquals((int)[nodes count], 4, @"XPath count for default ns nodes");
    STAssertNil(error, @"XPath error");

    // find nodes with an explicit atom namespace
    path = @"atom:entry/atom:link"; // four entry link nodes
    NSDictionary *nsDict = [NSDictionary dictionaryWithObject:kGDataNamespaceAtom
                                                       forKey:kGDataNamespaceAtomPrefix];
    nodes = [(GDataXMLNode *)root nodesForXPath:path
                                     namespaces:nsDict
                                          error:&error];

    STAssertEquals((int)[nodes count], 4, @"XPath count for atom ns nodes");
    STAssertNil(error, @"XPath error");

    // test an illegal path string
    GDataXMLNode *emptyNode = [GDataXMLElement elementWithName:@"Abcde"];
    nodes = [emptyNode nodesForXPath:@""
                          namespaces:nsDict
                               error:&error];
    // libxml provides error code 1207 for this
    STAssertEquals([error code], 1207, @"error on invalid XPath: %@", error);
  }
}

- (void)testXPath {
  [self runXPathTestUsingShim:NO];
  [self runXPathTestUsingShim:YES];
}

@end

