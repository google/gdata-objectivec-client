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
//  GDataElementsTest.m
//

// Unit tests for the Objective-C GData framework element classes

#import "GData.h"
#import "GDataElementsTest.h"

#define typeof __typeof__ // fixes http://www.brethorsting.com/blog/2006/02/stupid-issue-with-ocunit.html

@implementation GDataElementsTest

- (NSString *)entryNamespaceString {
  NSString * const kNamespaceString = @"xmlns='http://www.w3.org/2005/Atom'"
                        " xmlns:gd='http://schemas.google.com/g/2005' "
                        " xmlns:gm='http://base.google.com/ns-metada/1.0' "
                        " xmlns:g='http://base.google.com/ns/1.0' "
                        " xmlns:gCal='http://schemas.google.com/gCal/2005' "
                        " xmlns:gs='http://schemas.google.com/spreadsheets/2006' "
                        " xmlns:gsx='http://schemas.google.com/spreadsheets/2006/extended' "
                        " xmlns:batch='http://schemas.google.com/gdata/batch' "
                        " xmlns:app='http://www.w3.org/2007/app'"
                        " xmlns:gcs='http://schemas.google.com/codesearch/2006'"
                        " xmlns:gf='http://schemas.google.com/finance/2007'"
                        " xmlns:wt='http://schemas.google.com/webmasters/tools/2007'"
                        " xmlns:media='http://search.yahoo.com/mrss/'" 
                        " xmlns:gphoto='http://schemas.google.com/photos/2007'"
                        " xmlns:exif='http://schemas.google.com/photos/exif/2007'"
                        " xmlns:geo='http://www.w3.org/2003/01/geo/wgs84_pos#'"
                        " xmlns:georss='http://www.georss.org/georss'"
                        " xmlns:gml='http://www.opengis.net/gml' ";
  
  return kNamespaceString;
}

- (NSArray *)entryNamespaceNodes {

  // convert the above string into an array of NSXML namespace nodes
  NSMutableArray *namespaces = [NSMutableArray array];
  NSScanner *scanner = [NSScanner scannerWithString:[self entryNamespaceString]];

  while ([scanner scanString:@"xmlns" intoString:nil]) {

    NSString *prefix = @""; // default namespace won't scan, but is an empty string
    NSString *uri = nil;

    [scanner scanString:@":" intoString:nil];
    [scanner scanUpToString:@"=" intoString:&prefix];
    [scanner scanString:@"='" intoString:nil];
    [scanner scanUpToString:@"'" intoString:&uri];
    [scanner scanString:@"'" intoString:nil];

    if (uri && prefix) {
      [namespaces addObject:[NSXMLElement namespaceWithName:prefix
                                                stringValue:uri]];
    }
  }
  return namespaces;
}

// Allocate a GDataObject of a known class, initialized from the 
// given XML.
//
// For XML needing but lacking namespace information, it will
// be allocated by being temporarily wrapped in a parent which
// has the full set of GData namespaces.
- (id)GDataObjectForClassName:(Class)gdataClass
                    XMLString:(NSString *)xmlString
shouldWrapWithNamespaceAndEntry:(BOOL)shouldWrap {
  
  
  NSString *wrappedXMLString = xmlString;
  
  if (shouldWrap) {
    // make an outer element with the namespace
    NSString * const kNamespaceWrapperString = @"<entry %@ >%@</entry>";
    
    wrappedXMLString = [NSString stringWithFormat:
      kNamespaceWrapperString,
      [self entryNamespaceString], xmlString];
  }
  
  // make an XML element for the wrapped XML, then extract the inner element
  NSError *error = nil;
  NSXMLElement *entryXML = [[[NSXMLElement alloc] initWithXMLString:wrappedXMLString
                                                              error:&error] autorelease];
  STAssertNil(error, @"%@ on wrapped XML:%@", error, wrappedXMLString);
  
  // skip over non-element children to find the first element
  NSXMLElement *element;
  int index = 0;
  do {
    element = (NSXMLElement *) [entryXML childAtIndex:index];
    ++index;
  } while (element != nil && ![element isKindOfClass:[NSXMLElement class]]);
  
  STAssertNotNil(element, @"Cannot get child element of %@", entryXML);

  // allocate our GData object from the inner element
  GDataObject *obj = [[[gdataClass alloc] initWithXMLElement:element
                                                      parent:nil] autorelease];
  return obj;
}

// This is the same as Obj-C's as valueForKeyPath: but allows array indices
// as path elements, like foo.0.bar
+ (id)valueInObject:(id)obj
  forKeyPathIncludingArrays:(NSString *)keyPath {
  
  NSArray *pathList = [keyPath componentsSeparatedByString:@"."];
  NSMutableArray *partialKeyPathList = [NSMutableArray array];

  // step through keys in the path
  id targetObj = obj;
  for (int idx = 0; idx < [pathList count]; idx++) {
    
    // if a key is an integer or "@count", then evaluate the array or set
    // preceding it and extract the object indexed by the integer or the count
    // of array objects
    id thisKey = [pathList objectAtIndex:idx];
    if ([thisKey isEqual:@"@count"]
        || [thisKey isEqual:@"0"] 
        || [thisKey intValue] > 0) {
      
      NSString *partialPathString = [partialKeyPathList componentsJoinedByString:@"."];
      
      NSArray *targetArray = [targetObj valueForKeyPath:partialPathString];
      
      [partialKeyPathList removeAllObjects];

      if ([thisKey isEqual:@"@count"]) {
#if MAC_OS_X_VERSION_MIN_REQUIRED <= MAC_OS_X_VERSION_10_4
        targetObj = [NSNumber numberWithInt:[targetArray count]];
#else
        targetObj = [NSNumber numberWithUnsignedInteger:[targetArray count]];
#endif
      } else {
        int arrayIndex = [thisKey intValue];
        targetObj = [targetArray objectAtIndex:arrayIndex];
      }
    } else {
      // for non-integer keys, just keep accumulating keys in the path
      [partialKeyPathList addObject:thisKey];
    }
  }
  if ([partialKeyPathList count]) {
    // find the final target object given the accumulated keys in the path
    NSString *finalKeyPathString = [partialKeyPathList componentsJoinedByString:@"."];
    
    @try {
      targetObj = [targetObj valueForKeyPath:finalKeyPathString];
    } 
    @catch(NSException *exc) {
      NSLog(@"testing class:%@ keyPath:\"%@\"", [obj class], keyPath);
      @throw;
    }
  }
  return targetObj;
}

// runElementTests: takes an array of ElementTestKeyPathValues, where the
// first is (class, xml) and later ones are (test path, expected value)
// 
// Empty strings mark end-of-element, nils mark end-of-test-array
//
// We'll test each element this way:
//
// 1. Generate the NSXMLElement from an XML string (wrapped by an outer <entry> 
//    element with the namespace)
// 2. Extract the inner element we care about
// 3. Create a GData object for the element (obj1)
// 4. Copy the GData object (obj1copy)
// 5. Generate an XML element from the copy (outputXML)
// 6. Create a new GData object from the output XML (obj2)
// 7. Test that [obj2 isEqual:obj1copy]
// 8. Run a series of key-value coding tests on obj2 to be sure it contains
//    everything we expect.
// 9. If the tests did not include checks for unknown elements or
//    attributes, then those are tested to be sure they are 0.

- (void)runElementTests:(ElementTestKeyPathValues *)tests {

  for (int testIndex = 0;
       tests[testIndex].str1 != nil;
       testIndex++) {
    
    // get the GData class and the XML string from the table
    NSString *className = tests[testIndex].str1;
    NSString *testXMLString = tests[testIndex].str2;
    
#ifdef GDATA_TARGET_NAMESPACE
    className = [NSString stringWithFormat:@"%s_%@", 
                GDATA_TARGET_NAMESPACE_STRING, className];
#endif

    Class gdataClass = NSClassFromString(className);
    STAssertNotNil(gdataClass, @"Cannot make class for class name: %@", className);
    
    // make a GDataObject instance with the XML
    GDataObject *obj1 = [self GDataObjectForClassName:gdataClass
                                            XMLString:testXMLString
                      shouldWrapWithNamespaceAndEntry:YES];
    
    // make a copy of the object, and verify that it equals the original
    GDataObject *obj1copy = [[obj1 copy] autorelease];
    STAssertTrue([obj1 isEqual:obj1copy],
                 @"Failed copy from %@ to %@\nfor class %@ and original XML string:\n  %@",
                 obj1, obj1copy, className, testXMLString);

    // get XML from the copy, make a new instance from the XML, and verify
    // the the new instance equals the previous copy

    NSXMLElement *outputXML = [obj1copy XMLElement];

    // before using the XML element from the copy, we need to give it
    // a parent containing the same implicit namespaces that the original
    // element had; otherwise, unbound URIs and prefixes won't resolve
    // identically
    NSXMLElement *tempParent = [NSXMLElement elementWithName:@"temp"];
    [tempParent setNamespaces:[self entryNamespaceNodes]];
    [tempParent addChild:outputXML];

#if GDATA_USES_LIBXML
    // GDataXMLElement's addChild: will fix up the namespaces in its new
    // copy of the child element, so we'll want to use the new copy of the
    // child for generating the new object
    outputXML = (NSXMLElement *)[tempParent childAtIndex:0];
#endif

    GDataObject *obj2 = [[[gdataClass alloc] initWithXMLElement:outputXML
                                                         parent:nil] autorelease];

    STAssertTrue([obj2 isEqual:obj1copy],
                 @"Failed using XML to convert\n  %@\nas XML:\n  %@\nto\n  %@\nfor class %@ and original XML string:\n  %@",
                 obj1copy, outputXML, obj2, className, testXMLString);

    // generate a description; this can fire an exception for an invalid keyPath
    // in the description record list
    STAssertNotNil([obj2 description], @"Could not generate description for %@",
                   className);

    // step through each test for this element, evaluate the key-value path,
    // and compare the result to the expected value string
    //
    // also, track if tests of unknownChildren or unknownAttributes are 
    // performed
    BOOL testedForUnknownChildren = NO;
    BOOL testedForUnknownAttributes = NO;
    
    while (1) {
      
      ++testIndex;
      
      NSString *keyPath = tests[testIndex].str1;
      NSString *expectedValue = tests[testIndex].str2;
      
      if (keyPath == nil || [keyPath length] == 0) break;
      
#if GDATA_USES_LIBXML
      // skip the XMLStrings until we can normalize whitespace and closing
      // brackets and other minor differences
      if ([keyPath hasSuffix:@".XMLString"]) continue;
#endif
      
      NSString *result = [GDataElementsTest valueInObject:obj2 forKeyPathIncludingArrays:keyPath];
      
      // if the result wasn't a string but responds to stringValue, then
      // invoke that to get a string
      if ([expectedValue isKindOfClass:[NSString class]]
          && ![result isKindOfClass:[NSString class]]
          && [result respondsToSelector:@selector(stringValue)]) {
        
        result = [(id)result stringValue];     
      }
      
#ifdef GDATA_TARGET_NAMESPACE
      // tests for class name need the prefix added
      if ([keyPath hasSuffix:@"className"]
          && [expectedValue hasPrefix:@"GData"]) {

        expectedValue = [NSString stringWithFormat:@"%s_%@",
                         GDATA_TARGET_NAMESPACE_STRING, expectedValue];
      }
#endif
      
      STAssertTrue(AreEqualOrBothNil(result, expectedValue), 
                   @"failed %@ testing key path %@:\n %@ \n!= \n %@", 
                   obj2, keyPath, result, expectedValue);
      
      if ([keyPath hasPrefix:@"unknownChildren"]) testedForUnknownChildren = YES;
      if ([keyPath hasPrefix:@"unknownAttributes"]) testedForUnknownAttributes = YES;
    }
    
    // if there were no explicit tests on this test object for unknown children
    // or attributes, then verify now that there are in fact no unknown children
    // or attributes present in the object
    
    if (!testedForUnknownChildren) {
      NSString *keyPath = @"unknownChildren.@count.stringValue";
      NSString *expectedValue = @"0";
      NSString *result = [GDataElementsTest valueInObject:obj2 
                                forKeyPathIncludingArrays:keyPath];
      
      // this object should have no unparsed children
      STAssertTrue(AreEqualOrBothNil(result, expectedValue),
                   @"failed %@ testing:\n %@ \n!= \n %@\n unknown children: %@", 
                   obj2, result, expectedValue, 
                   [GDataElementsTest valueInObject:obj2 
                          forKeyPathIncludingArrays:@"unknownChildren"]);      
    }
    
    if (!testedForUnknownAttributes) {
      NSString *keyPath = @"unknownAttributes.@count.stringValue";
      NSString *expectedValue = @"0";
      NSString *result = [GDataElementsTest valueInObject:obj2 
                                forKeyPathIncludingArrays:keyPath];
      
      // this object should have no unparsed attributes
      STAssertTrue(AreEqualOrBothNil(result, expectedValue),
                   @"failed %@ testing:\n %@ \n!= \n %@", 
                   obj2, result, expectedValue,
                   [GDataElementsTest valueInObject:obj2 
                          forKeyPathIncludingArrays:@"unknownAttributes"]);      
    }
  }
}



- (void)testElements {
  
  // this method tests base elements, using runElementTests: above
  
  // The tests mostly include static strings, but we'll generate a few 
  // strings dynamically first.
  
  // Test a non-ASCII character and some html characters in a TextConstruct.  
  // We'll allocate it dynamically since source code cannot contain non-ASCII.
  NSString *template = @"Test ellipsis (%C) and others \"<&>";
  NSString *textConstructTestResult = [NSString stringWithFormat:template, 8230];
  
  // To test an inline feed, we'll read in the cells feed test file,
  // strip the <?xml...> prefix, and wrap it in a gd:feedLink
  NSError *error = nil;
  NSStringEncoding encoding = 0;
  NSString *inlineFeed = [NSString stringWithContentsOfFile:@"Tests/FeedSpreadsheetCellsTest1.xml"
                                               usedEncoding:&encoding
                                                      error:&error];
  STAssertNotNil(inlineFeed, @"cannot load xml for inline feed, %@", error);

  inlineFeed = [inlineFeed substringFromIndex:[@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>" length]];
  NSString *inlinedFeedLinkStr = [NSString stringWithFormat:@"<gd:feedLink>%@</gd:feedLink>", inlineFeed];

  NSString *inlinedFeedContentStr = [NSString stringWithFormat:@"<content"
    " type='application/atom+xml;feed'>%@</content>", inlineFeed];

  NSString *inlinedLinkStr = [NSString stringWithFormat:@"<link"
                        " rel='fuzzrel'>%@</link>", inlinedFeedContentStr];
  
  ElementTestKeyPathValues tests[] =
  { 
    { @"GDataCategory", @"<category scheme=\"http://schemas.google.com/g/2005#kind\" "
      "term=\"http://schemas.google.com/g/2005#event\" label=\"My Category\" "
      "xml:lang=\"myLanguage\" unkAttr=\"ABCDE\" unkAttr2=\"EFGHI\" />" },
    { @"scheme", kGDataCategoryScheme },
    { @"term", kGDataCategoryEvent },
    { @"label", @"My Category" },
    { @"labelLang", @"myLanguage" },
    { @"unknownAttributes.0.XMLString", @"unkAttr=\"ABCDE\"" },
    { @"unknownAttributes.1.XMLString", @"unkAttr2=\"EFGHI\"" },
    { @"unknownAttributes.@count", @"2" },
    { @"", @"" },
      
    { @"GDataComment", @"<gd:comments rel=\"http://schemas.google.com/g/2005#reviews\"> "
      "<gd:feedLink href=\"http://example.com/restaurants/SanFrancisco/432432/reviews\" > "
      "</gd:feedLink> <unkElement foo=\"bar\" /> <unkElement2 /> </gd:comments>" },
    { @"rel", @"http://schemas.google.com/g/2005#reviews" },
    { @"feedLink.href", @"http://example.com/restaurants/SanFrancisco/432432/reviews" },
    { @"unknownChildren.0.XMLString", @"<unkElement foo=\"bar\"></unkElement>" },
    { @"unknownChildren.1.XMLString", @"<unkElement2></unkElement2>" },
    { @"unknownChildren.@count", @"2" },
    { @"", @"" },

    { @"GDataCustomProperty", @"<gd:customProperty name='milk' type='integer' "
      "unit='gallons' >5</gd:customProperty>" },
    { @"name", @"milk" },
    { @"type", @"integer" },
    { @"unit", @"gallons" },
    { @"value", @"5" },
    { @"", @"" },

    { @"GDataDeleted", @"<gd:deleted/>" },
    { @"unknownAttributes.@count", @"0" },
    { @"unknownChildren.@count", @"0" },
    { @"", @"" },
        
    { @"GDataEmail", @"<gd:email label=\"Personal\" address=\"fubar@gmail.com\" primary='true' />" },
    { @"label", @"Personal" },
    { @"address", @"fubar@gmail.com" },
    { @"primary", @"1" },
    { @"", @"" },
    
    // testing an inline contact entry
    { @"GDataEntryLink", @"<gd:entryLink href='http://gmail.com/jo/contacts/Jo'"
      " readOnly='true' rel='fizzbo'>"
      "<entry><category scheme='http://schemas.google.com/g/2005#kind' "
      " term='http://schemas.google.com/contact/2008#contact'/> "
      "<id>http://gmail.com/jo/contacts/Jo</id>"
      "<category term='user-tag' label='Google'/> "
      "<title>Jo March</title><gd:email address='jo@example.com'/> "
      "<gd:phoneNumber label='work' primary='true'>(650) 555-1212"
      "</gd:phoneNumber> </entry></gd:entryLink> " },
    { @"href", @"http://gmail.com/jo/contacts/Jo" },
    { @"isReadOnly", @"1" },
    { @"rel", @"fizzbo" },
    { @"entry.title.stringValue", @"Jo March" },
    { @"entry.emailAddresses.0.address", @"jo@example.com" },
    { @"entry.primaryPhoneNumber", @"(650) 555-1212" },
    { @"", @"" },
  
    { @"GDataExtendedProperty", @"<gd:extendedProperty name='X-MOZ-ALARM-LAST-ACK'"
      " value='2006-10-03T19:01:14Z'"
      " realm='http://schemas.google.com/g/2005#shared' />" },
    { @"name", @"X-MOZ-ALARM-LAST-ACK" },
    { @"value", @"2006-10-03T19:01:14Z" },
    { @"realm", kGDataExtendedPropertyRealmShared },
    { @"", @"" },

    { @"GDataExtendedProperty", @"<gd:extendedProperty name='fred'><mozq>"
            "<lepper x='1'/></mozq><frizq/></gd:extendedProperty>" },
    { @"name", @"fred" },
    { @"XMLValues.0.XMLString", @"<mozq><lepper x=\"1\"></lepper></mozq>" },
    { @"XMLValues.1.XMLString", @"<frizq></frizq>" },
#if MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_4
    // GDataExtendedProperty explicitly overrides the default namespace for its
    // children so that there's no default namespace (prefix "" = URI "")
    //
    // Skip this test under the 10.4 SDK because 10.4's KVC can't interpret
    // an empty string as the last part of the KVC path
    { @"namespaces.", @"" },
#endif
    { @"unknownChildren.@count.stringValue", @"0" },
    { @"", @"" },
        
    { @"GDataExtendedProperty", @"<gd:extendedProperty name='fred'><flub>"
    "cuckoo</flub><nackro>whoodle buzz</nackro></gd:extendedProperty>" },
    { @"name", @"fred" },
    { @"XMLValues.0.XMLString", @"<flub>cuckoo</flub>" },
    { @"XMLValues.1.XMLString", @"<nackro>whoodle buzz</nackro>" },
    { @"XMLValuesDictionary.flub", @"cuckoo" },
    { @"XMLValuesDictionary.nackro", @"whoodle buzz" },
    { @"unknownChildren.@count.stringValue", @"0" },
    { @"", @"" },
    
    { @"GDataFeedLink", @"<gd:feedLink href='http://example.com/Jo/posts/MyFirstPost/comments' "
      "countHint=\"10\" readOnly=\"true\" />" },
    { @"href", @"http://example.com/Jo/posts/MyFirstPost/comments" },
    { @"countHint", @"10" },
    { @"isReadOnly", @"1" },
    { @"", @"" },
      
    // testing an inline feedLink
    { @"GDataFeedLink", inlinedFeedLinkStr },
    { @"href", nil },
    { @"isReadOnly", @"0" },
    { @"feed.categories.0.term", kGDataCategorySpreadsheetCell },
    { @"feed.columnCount", @"20" },
    { @"feed.entries.0.cell.column", @"1" },
    { @"", @"" },
    
    { @"GDataGenerator", @" <generator version='1.0' uri='http://www.google.com/calendar/'>CL2</generator>" },
    { @"name", @"CL2" },
    { @"version", @"1.0" },
    { @"URI", @"http://www.google.com/calendar/" },
    { @"", @"" },
    
    { @"GDataGeoPt", @"<gd:geoPt lat=\"27.98778\" lon=\"86.94444\" elev=\"8850.0\" label=\"My GeoPt\" time=\"1996-12-19T16:39:57-08:00\"/>" },
    { @"label", @"My GeoPt" },
    { @"lat", @"27.98778" },
    { @"lon", @"86.94444" },
    { @"elev", @"8850" },
    { @"time.RFC3339String", @"1996-12-19T16:39:57-08:00" },
    { @"", @"" },
      
    { @"GDataIM", @"<gd:im protocol='http://schemas.google.com/g/2005#MSN' "
       "address='foo@bar.example.com' label='Alternate' primary='true' rel='http://schemas.google.com/g/2005#other' />" },
    { @"protocol", kGDataIMProtocolMSN },
    { @"address", @"foo@bar.example.com" },
    { @"label", @"Alternate" },
    { @"primary", @"1" },
    { @"rel", @"http://schemas.google.com/g/2005#other" },
    { @"", @"" },
    
    { @"GDataLink", @"<link rel='alternate' type='text/html' "
      "href='http://www.google.com/calendar/event?stff' title='alternate' "
      " gd:etag='abcdefg' />" },
    { @"rel", @"alternate" },
    { @"type", @"text/html" },
    { @"href", @"http://www.google.com/calendar/event?stff" },
    { @"title", @"alternate" },
    { @"content", nil },
    { @"ETag", @"abcdefg" },
    { @"", @"" },
    
    { @"GDataLink", inlinedLinkStr },
    { @"rel", @"fuzzrel" },
    { @"ETag", nil },
    { @"content.type", @"application/atom+xml;feed" },
    { @"content.childObject.className", @"GDataFeedSpreadsheetCell" },
    { @"content.childObject.categories.0.term", kGDataCategorySpreadsheetCell },
    { @"content.childObject.columnCount", @"20" },
    { @"content.childObject.entries.0.cell.column", @"1" },    
    { @"", @"" },
        
    { @"GDataMoney", @"<gd:money amount='10.52' currencyCode='USD' />" },
    { @"amount", @"10.52" },
    { @"currencyCode", @"USD" },
    { @"", @"" },
    
    { @"GDataName", @"<gd:name><gd:givenName>Fred</gd:givenName>"
      "<gd:additionalName>Old</gd:additionalName>"
      "<gd:familyName>Flintstone</gd:familyName>"
      "<gd:namePrefix>Mr</gd:namePrefix>"
      "<gd:nameSuffix>Jr</gd:nameSuffix>"
      "<gd:fullName>Mr Fred Old Flintstone Jr</gd:fullName></gd:name>" },
    { @"fullName", @"Mr Fred Old Flintstone Jr" },
    { @"namePrefix", @"Mr" },
    { @"nameSuffix", @"Jr" },
    { @"familyName", @"Flintstone" },
    { @"additionalName", @"Old" },
    { @"givenName", @"Fred" },
    { @"", @"" },

    { @"GDataOriginalEvent", @"<gd:originalEvent id=\"i8fl1nrv2bl57c1qgr3f0onmgg\" "
      "href=\"http://www.google.com/calendar/feeds/userID/private-magicCookie/full/eventID\" >"
      "<gd:when startTime=\"2006-03-17T22:00:00.000Z\"/>  </gd:originalEvent>" },
    { @"href", @"http://www.google.com/calendar/feeds/userID/private-magicCookie/full/eventID" },
    { @"originalID", @"i8fl1nrv2bl57c1qgr3f0onmgg" },
    { @"originalStartTime.startTime.RFC3339String", @"2006-03-17T22:00:00Z" }, // we generate +00:00 instead of Z
    { @"originalStartTime.endTime", nil },
    { @"originalStartTime.value", nil },
    { @"", @"" },
    
    { @"GDataOrganization", @"<gd:organization rel='http://schemas.google.com/g/2005#work' "
      "label='greensleeves' primary='true' >"
      "<gd:orgName yomi='ak me'>Acme Corp</gd:orgName>"
      "<gd:orgTitle>Prezident</gd:orgTitle>"
      "<gd:orgDepartment>Cheese Factory</gd:orgDepartment>"
      "<gd:orgJobDescription>Sniffer</gd:orgJobDescription>"
      "<gd:orgSymbol>GSLV</gd:orgSymbol>"
      "<gd:where valueString='Downtown' /></gd:organization>" },
    { @"rel", @"http://schemas.google.com/g/2005#work" },
    { @"label", @"greensleeves" },
    { @"isPrimary", @"1" },
    { @"orgName", @"Acme Corp", },
    { @"orgNameYomi", @"ak me", },
    { @"orgTitle", @"Prezident" },
    { @"orgDepartment", @"Cheese Factory" },
    { @"orgJobDescription", @"Sniffer" },
    { @"orgSymbol", @"GSLV" },
    { @"where.stringValue", @"Downtown" },
    { @"", @"" },

    { @"GDataPerson", @"<GDataPerson xml:lang='en'> <name>Fred Flintstone</name> <email>test@froo.net</email> "
      "<uri>http://foo.com/</uri></GDataPerson>" },
    { @"name", @"Fred Flintstone" },
    { @"nameLang", @"en" },
    { @"URI", @"http://foo.com/" },
    { @"email", @"test@froo.net" },
    { @"", @"" },
    
    { @"GDataPhoneNumber", @"<gd:phoneNumber rel='http://schemas.google.com/g/2005#work' "
      "label='work' primary='true'>(425) 555-8080 ext. 52585</gd:phoneNumber>" },
    { @"rel", kGDataPhoneNumberWork },
    { @"label", @"work" },
    { @"primary", @"1" },
    { @"stringValue", @"(425) 555-8080 ext. 52585" },
    { @"", @"" },
    
    { @"GDataPostalAddress", @"<gd:postalAddress label='work' primary='true'>500 West 45th Street\nNew York, NY 10036</gd:postalAddress>" },
    { @"label", @"work" },
    { @"primary", @"1" },
    { @"stringValue", @"500 West 45th Street\nNew York, NY 10036" },
    { @"", @"" },

    { @"GDataStructuredPostalAddress", @"<gd:structuredPostalAddress "
      "mailClass='http://schemas.google.com/g/2005#both' label='Madame Duval' "
      "rel='http://schemas.google.com/g/2005#other' "
      "usage='http://schemas.google.com/g/2005#general' primary='true' >"
      "<gd:agent>c/o Milkville</gd:agent>"
      "<gd:housename>Big Ville</gd:housename>"
      "<gd:street>27, rue Pasteur</gd:street>"
      "<gd:pobox>P.O. Box 7-a</gd:pobox>"
      "<gd:neighborhood>Uptown</gd:neighborhood>"
      "<gd:city>CABOURG</gd:city>"
      "<gd:region>Caen</gd:region>"
      "<gd:subregion>County Fin</gd:subregion>"
      "<gd:postcode>14390</gd:postcode>"
      "<gd:country code='fr'>FRANCE</gd:country>"
      "<gd:formattedAddress>Madame Duval\n27, rue Pasteur\n14390 CABOURG\n"
      "FRANCE</gd:formattedAddress></gd:structuredPostalAddress>" },
    { @"label", @"Madame Duval" },
    { @"mailClass", kGDataPostalAddressBoth },
    { @"isPrimary", @"1" },
    { @"rel", kGDataPostalAddressOther },
    { @"usage", kGDataPostalAddressGeneral },
    { @"agent", @"c/o Milkville" },
    { @"city", @"CABOURG" },
    { @"countryName", @"FRANCE" },
    { @"countryCode", @"fr" },
    { @"formattedAddress", @"Madame Duval\n27, rue Pasteur\n14390 CABOURG\nFRANCE" },
    { @"houseName", @"Big Ville" },
    { @"neighborhood", @"Uptown" },
    { @"POBox", @"P.O. Box 7-a" },
    { @"postCode", @"14390" },
    { @"region", @"Caen" },
    { @"street", @"27, rue Pasteur" },
    { @"subregion", @"County Fin" },
    { @"", @"" },
    
    { @"GDataRating", @"<gd:rating rel='http://schemas.google.com/g/2005#price' value='5' min='1' max='5' average='2.3' numRaters='132' />" },
    { @"rel", kGDataRatingPrice },
    { @"value", @"5" },
    { @"min", @"1" }, 
    { @"max", @"5" },
    { @"average", @"2.3" },
    { @"numberOfRaters", @"132" },
    { @"", @"" },

    { @"GDataRecurrence", @"<gd:recurrence>DTSTART;TZID=America/Los_Angeles:200"
      "60314T060000\nDURATION:PT3600S</gd:recurrence>" },
    { @"stringValue", @"DTSTART;TZID=America/Los_Angeles:20060314T060000\nDURATION:PT3600S" },
    { @"", @"" },
    
    { @"GDataRecurrenceException", @"<gd:recurrenceException specialized='true'> <gd:entryLink "
      "href='http://gmail.com/jo/contacts/Jo' readOnly='true' /> "
      "<gd:originalEvent id='i8fl1nrv2bl57c1qgr3f0onmgg' href='http://www.google.com/href' >"
      "<gd:when startTime=\"2007-05-01T00:00:00.000Z\"/>  </gd:originalEvent></gd:recurrenceException>" },
    { @"isSpecialized", @"1" },
    { @"entryLink.href", @"http://gmail.com/jo/contacts/Jo" },
    { @"entryLink.isReadOnly", @"1" },
    { @"originalEvent.originalID", @"i8fl1nrv2bl57c1qgr3f0onmgg" },
    { @"originalEvent.originalStartTime.startTime.RFC3339String", @"2007-05-01T00:00:00Z" },
    { @"", @"" },
    
    { @"GDataReminder", @"<gd:reminder minutes='15' method='email' />" },
    { @"minutes", @"15" },
    { @"method", @"email" },
    { @"", @"" },

    { @"GDataTextConstruct", @"<title type='text' xml:lang='en'>Event title</title>" },
    { @"stringValue", @"Event title" },
    { @"lang", @"en" },
    { @"type", @"text" },
    { @"", @"" },
    
    { @"GDataTextConstruct", @"<title type='text'>Test ellipsis (&#8230;) and others &quot;&lt;&amp;&gt;</title>" },
    { @"stringValue", textConstructTestResult }, // defined above
    { @"", @"" },    
    
    { @"GDataValueConstruct", @"<gCal:timezone value='America/Los_Angeles'/>" },
    { @"stringValue", @"America/Los_Angeles" },
    { @"", @"" },

    { @"GDataValueConstruct", @"<myValue value='1.51'/>" },
    { @"doubleValue", @"1.51" },
    { @"", @"" },
      
    { @"GDataValueConstruct", @"<myValue value=''/>" },
    { @"doubleValue", @"0" },
    { @"", @"" },
    
    { @"GDataValueConstruct", @"<myValue value='INF'/>" },
    { @"doubleValue", (id)kCFNumberPositiveInfinity },
    { @"", @"" },
    
    { @"GDataValueConstruct", @"<myValue value='-INF'/>" },
    { @"doubleValue", (id)kCFNumberNegativeInfinity },
    { @"", @"" },
    
    { @"GDataValueConstruct", @"<myValue value='987654321987'/>" },
    { @"longLongValue", @"987654321987" },
    { @"", @"" },
    
    { @"GDataValueElementConstruct", @"<gCal:timezone>America/Los_Angeles</gCal:timezone>" },
    { @"stringValue", @"America/Los_Angeles" },
    { @"", @"" },
          
    { @"GDataBoolValueConstruct", @"<construct value='true'/>" },
    { @"boolValue", @"1" },
    { @"", @"" },
    
    { @"GDataNameValueConstruct", @"<namevalue name='fred' value='flintstone' />" },
    { @"stringValue", @"flintstone" },
    { @"name", @"fred" },
    { @"", @"" },

    { @"GDataEntryContent", @"<content src='http://lh.google.com/image/Car.jpg' type='image/jpeg'/>" },
    { @"sourceURI", @"http://lh.google.com/image/Car.jpg" },
    { @"type", @"image/jpeg" },
    { @"", @"" },
      
    { @"GDataEntryContent", @"<content type='text' xml:lang='en'>Event title</content>" },
    { @"stringValue", @"Event title" },
    { @"lang", @"en" },
    { @"type", @"text" },
    { @"", @"" },

    { @"GDataEntryContent", @"<content type='application/vnd.google-earth.kml+xml'>"
      "<Placemark xmlns=\"http://earth.google.com/kml/2.2\">" // inline KML
      "<name>Grandma's House</name></Placemark></content>" },
    { @"type", @"application/vnd.google-earth.kml+xml" },
    { @"stringValue", nil },
    { @"XMLValues.@count", @"1" },
    { @"XMLValues.0.localName", @"Placemark" },
    { @"XMLValues.0.namespaces.0", @"http://earth.google.com/kml/2.2" },
    { @"", @"" },

    { @"GDataEntryContent", inlinedFeedContentStr },
    { @"type", @"application/atom+xml;feed" },
    { @"childObject.className", @"GDataFeedSpreadsheetCell" },
    { @"childObject.categories.0.term", kGDataCategorySpreadsheetCell },
    { @"childObject.columnCount", @"20" },
    { @"childObject.entries.0.cell.column", @"1" },
    { @"", @"" },
      
    { @"GDataWebContent", @"<gCal:webContent width='300' height='136' "
      "url='http://google.com/ig/modules/datetime.xml'>"
      "<gCal:webContentGadgetPref name='color' value='green' />"
      "<gCal:webContentGadgetPref name='sin' value='greed' /></gCal:webContent>" },
      
    { @"height", @"136" },
    { @"width", @"300" },
    { @"URLString", @"http://google.com/ig/modules/datetime.xml" },

    { @"gadgetPreferences.0.name", @"color" },
    { @"gadgetPreferences.0.value", @"green" },
    { @"gadgetPreferenceDictionary.color", @"green" },
    { @"gadgetPreferenceDictionary.sin", @"greed" },
    { @"", @"" },
    
    { @"GDataWhen", @"<gd:when startTime='2005-06-06' endTime='2005-06-07' "
          "valueString='This weekend'/>" },
    { @"startTime.RFC3339String", @"2005-06-06" },
    { @"endTime.RFC3339String", @"2005-06-07" },
    { @"value", @"This weekend" },
    { @"", @"" },
    
    { @"GDataWhere", @"<gd:where rel='http://schemas.google.com/g/2005#event' "
      "label='main' valueString='The Pub'> "
      "<gd:entryLink href='http://local.example.com/10018/JoesPub' /></gd:where>" },
    { @"rel", kGDataCategoryEvent },
    { @"label", @"main" },
    { @"stringValue", @"The Pub" },
    { @"entryLink.href", @"http://local.example.com/10018/JoesPub" },
    { @"", @"" },
    
      
    // TODO(grobbins): test embedded entries
     { @"GDataWho", @"<gd:who rel=\"http://schemas.google.com/g/2005#event.attendee\" "
          "valueString=\"Jo\" email=\"jo@gmail.com\" >  "
          "<gd:attendeeType value=\"http://schemas.google.com/g/2005#event.required\"/> "
          "<gd:attendeeStatus value=\"http://schemas.google.com/g/2005#event.tentative\" /> "
          "<gd:entryLink href=\"http://gmail.com/jo/contacts/Jo\" readOnly=\"true\" />  </gd:who>" },
    { @"rel", kGDataWhoEventAttendee },
    { @"stringValue", @"Jo" },
    { @"email", @"jo@gmail.com" },
    { @"attendeeType", kGDataWhoAttendeeTypeRequired },
    { @"attendeeStatus", kGDataEventStatusTentative },
    { @"entryLink.href", @"http://gmail.com/jo/contacts/Jo" },
    { @"entryLink.isReadOnly", @"1" },
    { @"", @"" },
    
    // Atom publishing control
    { @"GDataAtomPubControl", @"<app:control><app:draft>Yes</app:draft></app:control>" },
    { @"isDraft", @"1" },
    { @"", @"" },

    { @"GDataAtomPubControl", @"<app:control></app:control>" },
    { @"isDraft", @"0" },
    { @"", @"" },

    { @"GDataAtomPubControl", @"<app:control><app:draft>Yes</app:draft></app:control>" },
    { @"isDraft", @"1" },
    { @"", @"" },
    
    // Batch elements
    { @"GDataBatchOperation", @"<batch:operation type='insert'/>" },
    { @"type", @"insert" },
    { @"", @"" },
    
    { @"GDataBatchID", @"<batch:id>item2</batch:id>" },
    { @"stringValue", @"item2" },
    { @"", @"" },
    
    { @"GDataBatchStatus", @"<batch:status  code='404' reason='Bad request' "
                          "content-type='application-text'>error</batch:status>" },
    { @"code", @"404" },
    { @"reason", @"Bad request" },
    { @"contentType", @"application-text" },
    { @"stringValue", @"error" },
    { @"", @"" },
    
    { @"GDataBatchStatus", @"<batch:status  code='200' />" },
    { @"code", @"200" },
    { @"reason", nil },
    { @"contentType", nil },
    { @"stringValue", @"" },
    { @"", @"" },

    { @"GDataBatchInterrupted", @"<batch:interrupted reason='no good reason' success='3' failures='4' parsed='7' />" },
    { @"reason", @"no good reason" },
    { @"successCount", @"3" },
    { @"errorCount", @"4" },
    { @"totalCount", @"7" },
    { @"contentType", nil },
    { @"stringValue", @"" },
    { @"", @"" },
    
    { nil, nil }
  };
  
  [self runElementTests:tests];
}

- (void)testGoogleBaseElements {
  
  ElementTestKeyPathValues tests[] =
  {     
    { @"GDataGoogleBaseMetadataValue", @"<gm:value "
        "count='87269'>product fluggy</gm:value>>" },
    { @"count", @"87269" },
    { @"contents", @"product fluggy" },
    { @"", @"" },
      
    { @"GDataGoogleBaseMetadataAttribute", @"<gm:attribute "
      "name='item type' type='text' count='116353'>"
      "<gm:value count='87269'>products</gm:value> <gm:value count='2401'>produkte</gm:value> "
      " </gm:attribute>" },
    { @"type", @"text" },
    { @"name", @"item type" },
    { @"count", @"116353" },
    { @"values.@count", @"2" },
    { @"values.1.count", @"2401" },
    { @"values.1.contents", @"produkte" },
    { @"", @"" },
      
    { @"GDataGoogleBaseMetadataAttributeList", @"<gm:attributes "
      "xmlns:gm='http://base.google.com/ns-metada/1.0'>"
      "<gm:attribute name='location' type='location' />"
      "<gm:attribute name='delivery radius' type='floatUnit' />"
      "<gm:attribute name='payment' type='text' />       </gm:attributes>" },
    { @"metadataAttributes.@count", @"3" },
    { @"metadataAttributes.0.name", @"location" },
    { @"metadataAttributes.2.type", @"text" },
    { @"", @"" },
      
    { @"GDataGoogleBaseMetadataItemType", @"<gm:item_type "
      "xmlns:gm='http://base.google.com/ns-metada/1.0'>"
      "business locations</gm:item_type>" },
    { @"value", @"business locations" },
    { @"", @"" },
      
    { @"GDataGoogleBaseAttribute", @"<g:product_type type='text' "
      "xmlns:g='http://base.google.com/ns/1.0'>Camera "
      "Connecting Cable<g:product_model> 65-798M </g:product_model>"
      "<g:product_revision> July06 </g:product_revision></g:product_type>" },
    { @"name", @"product type" },
    { @"textValue", @"Camera Connecting Cable" },
    { @"", @"" },
    
    { nil, nil }
  };
  
  [self runElementTests:tests];
  
}

- (void)testSpreadsheetElements {
  
  ElementTestKeyPathValues tests[] =
  {     
    { @"GDataSpreadsheetCell", @"<gs:cell row='2' col='4' "
      " inputValue='=FLOOR(R[0]C[-1]/(R[0]C[-2]*60),.0001)'"
      " numericValue='0.0066'>0.0033</gs:cell>" },
    { @"row", @"2" },
    { @"column", @"4" },
    { @"inputString", @"=FLOOR(R[0]C[-1]/(R[0]C[-2]*60),.0001)" },
    { @"numericValue", @"0.0066" },
    { @"resultString", @"0.0033" },
    { @"", @"" },
      
    { @"GDataRowCount", @"<gs:rowCount>100</gs:rowCount>" },
    { @"count", @"100" },
    { @"", @"" },
      
    { @"GDataColumnCount", @"<gs:colCount>99</gs:colCount>" },
    { @"count", @"99" },
    { @"", @"" },
      
    { @"GDataSpreadsheetCustomElement", @"<gsx:e-mail "
      "xmlns:gsx='http://schemas.google.com/spreadsheets/2006/extended'>"
      "fitzy@gmail.com</gsx:e-mail>" }, 
    { @"name", @"e-mail" },
    { @"stringValue", @"fitzy@gmail.com" },
    { @"", @"" },
      
    { nil, nil }
  };
  
  [self runElementTests:tests];
  
}

- (void)testWebmasterToolsElements {
  
  ElementTestKeyPathValues tests[] =
  {     
    { @"GDataSitemapMobile", @"<wt:sitemap-mobile>"
      "<wt:markup-language>HTML</wt:markup-language>"
      "<wt:markup-language>WAP</wt:markup-language></wt:sitemap-mobile>" },
    { @"markupLanguages.@count", @"2" },
    { @"markupLanguages.0.stringValue", @"HTML" },
    { @"markupLanguages.1.stringValue", @"WAP" },
    { @"", @"" },
    
    { @"GDataSitemapNews", @"<wt:sitemap-news>"
      "<wt:publication-label>Value1</wt:publication-label>"
      "<wt:publication-label>Value2</wt:publication-label>"
      "<wt:publication-label>Value3</wt:publication-label></wt:sitemap-news>" },
    { @"publicationLabels.@count", @"3" },
    { @"publicationLabels.0.stringValue", @"Value1" },
    { @"", @"" },
        
    { @"GDataSiteVerificationMethod", @"<wt:verification-method type='htmlpage'"
      " in-use='true'>456456-google.html</wt:verification-method>" },
    { @"type", @"htmlpage" },
    { @"isInUse", @"1" },
    { @"value", @"456456-google.html" },
    { @"", @"" },

    { @"GDataSiteVerificationMethod", @"<wt:verification-method type='metatag'"
      " in-use='false'> <meta name=\"verify-v1\" content=\"a2Ai\" />"
      "</wt:verification-method>" },
    { @"type", @"metatag" },
    { @"isInUse", @"0" },
    { @"XMLValues.0.localName", @"meta" },
    { @"", @"" },
    
    { nil, nil }
  };
  
  [self runElementTests:tests];
}

- (void)testCodeSearchElements {
  
  ElementTestKeyPathValues tests[] =
  {     
    { @"GDataCodeSearchFile", @"<gcs:file "
      "name='3c-libwww-5.4.0/Library/src/wwwsys.h'/>" },
    { @"name", @"3c-libwww-5.4.0/Library/src/wwwsys.h" },
    { @"", @"" },
      
    { @"GDataCodeSearchPackage", @"<gcs:package "
      "name='w3c-libwww-5.4.0.zip' "
      "uri='http://www.w3.org/Library/Distribution/w3c-libwww-5.4.0.zip'/>" },
    { @"name", @"w3c-libwww-5.4.0.zip" },
    { @"URI", @"http://www.w3.org/Library/Distribution/w3c-libwww-5.4.0.zip" },
    { @"", @"" },
      
    { @"GDataCodeSearchMatch", @"<gcs:match "
      "lineNumber='23' type='text/html'>"
      "found &lt;b&gt; query &lt;/b&gt;</gcs:match>" },
    { @"lineNumberString", @"23" },
    { @"type", @"text/html" },
    { @"stringValue", @"found <b> query </b>" }, 
    // note: this is properly unescaped for us by the XMLNode
    { @"", @"" },
      
    { nil, nil }
  };
  
  [self runElementTests:tests];
}

- (void)testFinanceElements {
  
  ElementTestKeyPathValues tests[] =
  {     
    { @"GDataFinanceTransactionData", @" <gf:transactionData date='2007-11-07T00:00:00.000'"
      " shares='1000.0' type='Buy' notes='Forgle Blipnot'> "
      " <gf:commission> <gd:money amount='0.0' currencyCode='USD'/>"
      " </gf:commission><gf:price><gd:money amount='730.0' currencyCode='USD'/>"
      " </gf:price></gf:transactionData>" },
    { @"type", @"Buy" },
    { @"date", @"2007-11-07T00:00:00Z" },
    { @"shares", @"1000" }, 
    { @"notes", @"Forgle Blipnot" },
    { @"commission.moneyWithPrimaryCurrency.amount", @"0" },
    { @"price.moneyWithPrimaryCurrency.amount", @"730" },
    { @"", @"" },
    
    { @"GDataFinanceSymbol", @"<gf:symbol exchange='NASDAQ' "
      " fullName='Google Inc.' symbol='GOOG' />" }, 
    { @"exchange", @"NASDAQ" },
    { @"fullName", @"Google Inc." },
    { @"symbol", @"GOOG" },
    { @"", @"" },
        
    { @"GDataPortfolioData", @"<gf:portfolioData currencyCode='USD'"
      " gainPercentage='1.894857932' return1w='-0.07711772724' return1y='0.3969560994'"
      " return3m='0.197468495' return3y='1.228892613' return4w='-0.003721445821'"
      " return5y='1.894857933' returnOverall='1.894857932' returnYTD='0.4172674026'>"
      " <gf:costBasis><gd:money amount='52158.0' currencyCode='Euro'/></gf:costBasis>"
      " <gf:daysGain><gd:money amount='7321.0' currencyCode='USD'/></gf:daysGain>"
      " <gf:gain><gd:money amount='98832.0' currencyCode='USD'/> </gf:gain>"
      " <gf:marketValue><gd:money amount='150990.0' currencyCode='USD'/>"
      " <gd:money amount='200100.9' currencyCode='Euro'/> "
      " </gf:marketValue> </gf:portfolioData>" },
    { @"currencyCode", @"USD" },
    { @"gainPercentage", @"1.894857932" },
    { @"return1w", @"-0.07711772724" },
    { @"return1y", @"0.3969560994" },
    { @"return3m", @"0.197468495" },
    { @"return3y", @"1.228892613" },
    { @"return4w", @"-0.003721445821" },
    { @"return5y", @"1.894857933" },
    { @"returnOverall", @"1.894857932" },
    { @"returnYTD", @"0.4172674026" },
    { @"costBasis.moneyWithPrimaryCurrency.amount", @"52158" },
    { @"costBasis.moneyWithPrimaryCurrency.currencyCode", @"Euro" },
    { @"gain.moneyWithPrimaryCurrency.amount", @"98832" },
    { @"gain.moneyWithPrimaryCurrency.currencyCode", @"USD" },
    { @"daysGain.moneyWithPrimaryCurrency.amount", @"7321" },
    { @"daysGain.moneyWithPrimaryCurrency.currencyCode", @"USD" },
    { @"marketValue.moneyWithPrimaryCurrency.amount", @"150990" },
    { @"marketValue.moneyWithPrimaryCurrency.currencyCode", @"USD" },
    { @"marketValue.moneyWithSecondaryCurrency.amount", @"200100.9" },
    { @"marketValue.moneyWithSecondaryCurrency.currencyCode", @"Euro" },
    { @"", @"" },
    
    // position data shares implementation with portfolio data, except
    // portfolio has "currencyCode" and position has "shares"
    { @"GDataPositionData", @"<gf:positionData gainPercentage='4.31125' "
      " shares='1000.2'><gf:costBasis><gd:money amount='32000.0' currencyCode='USD'/>"
      " </gf:costBasis><gf:marketValue><gd:money amount='169960.0' currencyCode='USD'/>"
      " </gf:marketValue></gf:positionData>" },
    { @"shares", @"1000.2" },
    { @"gainPercentage", @"4.31125" },
    { @"marketValue.moneyWithPrimaryCurrency.amount", @"169960" },
    { @"", @"" },
    
    { nil, nil }
  };
  
  [self runElementTests:tests];
}


- (void)testMediaElements {
  
  ElementTestKeyPathValues tests[] =
  {     
    { @"GDataMediaContent", @"<media:content url='http://www.foo.com/movie.mov' "
        " fileSize='12216320' type='video/quicktime' medium='video' isDefault='true' "
        " expression='full' bitrate='128' framerate='25.1' samplingrate='44.1'"
        " channels='2' duration='185' height='200' width='300' "
        " lang='en' />" },
    { @"URLString", @"http://www.foo.com/movie.mov" },
    { @"fileSize", @"12216320" },
    { @"type", @"video/quicktime" },
    { @"medium", @"video" },
    { @"isDefault", @"1" },
    { @"expression", @"full" },
    { @"bitrate", @"128" },
    { @"framerate", @"25.1" },
    { @"samplingrate", @"44.1" },
    { @"channels", @"2" },
    { @"duration", @"185" },
    { @"height", @"200" },
    { @"width", @"300" },
    { @"lang", @"en" },
    { @"", @"" },
    
    { @"GDataMediaThumbnail", @"<media:thumbnail url='http://www.foo.com/keyframe.jpg' "
          " width='75' height='50' time='12:05:01.123' />" },
    { @"URLString", @"http://www.foo.com/keyframe.jpg" },
    { @"width", @"75" },
    { @"height", @"50" },
    { @"time.timeOffsetInMilliseconds", @"43501123" },
    { @"", @"" },
    
    { @"GDataMediaKeywords", @"<media:keywords>kitty, cat, big dog, yarn, fluffy</media:keywords>" },
    { @"keywords.0", @"kitty" },
    { @"keywords.2", @"big dog" },
    { @"keywords.@count", @"5" },
    { @"", @"" },
    
    { @"GDataMediaCredit", @"<media:credit role='producer' scheme='urn:ebu'>entity name</media:credit>" },
    { @"role", @"producer" },
    { @"scheme", @"urn:ebu" },
    { @"stringValue", @"entity name" },
    { @"", @"" },
      
    { @"GDataMediaCategory", @"<media:category label='fred' scheme='urn:ebu'>entity name</media:category>" },
    { @"label", @"fred" },
    { @"scheme", @"urn:ebu" },
    { @"stringValue", @"entity name" },
    { @"", @"" },
      
    { @"GDataMediaRating", @"<media:rating scheme='simple'>adult</media:rating>" },
    { @"scheme", @"simple" },
    { @"stringValue", @"adult" },
    { @"", @"" },
      
    { @"GDataMediaPlayer", @"<media:player url='http://www.foo.com/player?id=1111' height='200' width='400' />" },
    { @"height", @"200" },
    { @"width", @"400" },
    { @"URLString", @"http://www.foo.com/player?id=1111" },
    { @"", @"" },
      
    { @"GDataMediaRestriction", @"<media:restriction relationship='allow' type='country'>au us</media:restriction>" },
    { @"relationship", @"allow" },
    { @"type", @"country" },
    { @"stringValue", @"au us" },
    { @"", @"" },
      
    { nil, nil }
  };
  
  [self runElementTests:tests];

}

- (void)testPhotoElements {
  
  ElementTestKeyPathValues tests[] =
  {     
    { @"GDataPhotoAlbumID", @"<gphoto:albumid>5024425138</gphoto:albumid>" },
    { @"stringValue", @"5024425138" },
    { @"", @"" },
      
    { @"GDataPhotoCommentCount", @"<gphoto:commentCount>11</gphoto:commentCount>" },
    { @"intValue", @"11" }, // test the int accessor
    { @"", @"" },
      
    { @"GDataPhotoCommentingEnabled", @"<gphoto:commentingEnabled>true</gphoto:commentingEnabled>" },
    { @"stringValue", @"true" },
    { @"boolValue", @"1" }, // test the bool accessor, too
    { @"", @"" },
      
    { @"GDataPhotoGPhotoID", @"<gphoto:id>512131187</gphoto:id>" },
    { @"stringValue", @"512131187" },
    { @"", @"" },
      
    { @"GDataPhotoMaxPhotosPerAlbum", @"<gphoto:maxPhotosPerAlbum>1000</gphoto:maxPhotosPerAlbum>" },
    { @"intValue", @"1000" },
    { @"", @"" },
      
    { @"GDataPhotoNickname", @"<gphoto:nickname>Jane Smith</gphoto:nickname>" },
    { @"stringValue", @"Jane Smith" },
    { @"", @"" },
      
    { @"GDataPhotoQuotaUsed", @"<gphoto:quotacurrent>312459331</gphoto:quotacurrent>" },
    { @"longLongValue", @"312459331" },
    { @"", @"" },
      
    { @"GDataPhotoQuotaLimit", @"<gphoto:quotalimit>1385222385</gphoto:quotalimit>" },
    { @"longLongValue", @"1385222385" },
    { @"", @"" },
      
    { @"GDataPhotoThumbnail", @"<gphoto:thumbnail>http://picasaweb.google.com/image/.../Hello.jpg</gphoto:thumbnail>" },
    { @"stringValue", @"http://picasaweb.google.com/image/.../Hello.jpg" },
    { @"", @"" },
      
    { @"GDataPhotoUser", @"<gphoto:user>Jane</gphoto:user>" },
    { @"stringValue", @"Jane" },
    { @"", @"" },
      
    { @"GDataPhotoAccess", @"<gphoto:access>private</gphoto:access>" },
    { @"stringValue", @"private" },
    { @"", @"" },

    { @"GDataPhotoBytesUsed", @"<gphoto:bytesUsed>11876307</gphoto:bytesUsed>" },
    { @"longLongValue", @"11876307" },
    { @"", @"" },
      
    { @"GDataPhotoLocation", @"<gphoto:location>Tokyo, Japan</gphoto:location>" },
    { @"stringValue", @"Tokyo, Japan" },
    { @"", @"" },
      
    { @"GDataPhotoNumberUsed", @"<gphoto:numphotos>237</gphoto:numphotos>" },
    { @"intValue", @"237" },
    { @"", @"" },
      
    { @"GDataPhotoNumberLeft", @"<gphoto:numphotosremaining>763</gphoto:numphotosremaining>" },
    { @"intValue", @"763" },
    { @"", @"" },
      
    { @"GDataPhotoChecksum", @"<gphoto:checksum>987123</gphoto:checksum>" },
    { @"stringValue", @"987123" },
    { @"", @"" },
      
    { @"GDataPhotoHeight", @"<gphoto:height>1200</gphoto:height>" },
    { @"longLongValue", @"1200" },
    { @"", @"" },
      
    { @"GDataPhotoRotation", @"<gphoto:rotation>90</gphoto:rotation>" },
    { @"intValue", @"90" },
    { @"", @"" },
      
    { @"GDataPhotoSize", @"<gphoto:size>149351</gphoto:size>" },
    { @"longLongValue", @"149351" },
    { @"", @"" },
      
    { @"GDataPhotoTimestamp", @"<gphoto:timestamp>1168640584000</gphoto:timestamp>" },
    { @"longLongValue", @"1168640584000" },
    { @"", @"" },
      
    { @"GDataPhotoWidth", @"<gphoto:width>1600</gphoto:width>" },
    { @"longLongValue", @"1600" },
    { @"", @"" },
      
    { @"GDataPhotoPhotoID", @"<gphoto:photoid>301521187</gphoto:photoid>" },
    { @"stringValue", @"301521187" },
    { @"", @"" },
      
    { @"GDataPhotoWeight", @"<gphoto:weight>3</gphoto:weight>" },
    { @"intValue", @"3" },
    { @"", @"" },
    
    { @"GDataEXIFTags", @"<exif:tags xmlns:exif='http://schemas.google.com/photos/exif/2007'>"
      "<exif:fstop>0.0</exif:fstop>"
      "<exif:make>Nokia</exif:make><exif:model>6133</exif:model>"
      "<exif:distance>0.0</exif:distance><exif:exposure>0.0</exif:exposure>"
      "<exif:model>Second Model</exif:model><exif:flash>true</exif:flash>"
      "</exif:tags>" }, // intentional second copy of "model" tag
    { @"tags.@count", @"7" },
    { @"tagDictionary.make", @"Nokia" },
    { @"tagDictionary.model", @"6133" }, // first instance of "model" tag
    { @"", @"" },
      
    { nil, nil }
  };
  
  [self runElementTests:tests];
  
}

- (void)testGeo {
  ElementTestKeyPathValues tests[] =
  {     
    // test explicit types - here we specify which subclass of GDataGeo
    // to instantiate
    { @"GDataGeoW3CPoint", @"<geo:Point><geo:lat>55.701</geo:lat>"
        "<geo:long>12.552</geo:long></geo:Point>" },
    { @"latitude", @"55.701" },
    { @"longitude", @"12.552" },
    { @"coordinateString", @"55.701 12.552" },
    { @"isPoint", @"1" },
    { @"", @"" },
      
    { @"GDataGeoRSSPoint", @"<georss:point>45.256 -71.92</georss:point>" },
    { @"latitude", @"45.256" },
    { @"longitude", @"-71.92" },
    { @"", @"" },
      
    { @"GDataGeoRSSWhere", @"<georss:where><gml:Point><gml:pos>45.256 -71.92"
        "</gml:pos></gml:Point></georss:where>" },
    { @"latitude", @"45.256" },
    { @"longitude", @"-71.92" },
    { @"", @"" },
    
    // test GDataGeo for implicit types - here we use
    // a test class which incorporates uses GDataGeo's utilities for 
    // determining the subclass of GDataGeo to instantiate
    //
    // GDataGeoTestClass is defined below in this file
    { @"GDataGeoTestClass", @"<GDataGeoTestClass><geo:Point><geo:lat>55.701</geo:lat>" // W3CPoint
        "<geo:long>12.552</geo:long></geo:Point></GDataGeoTestClass>" },
    { @"geoLocation.latitude", @"55.701" },
    { @"geoLocation.longitude", @"12.552" },
    { @"", @"" },
      
    { @"GDataGeoTestClass", @"<GDataGeoTestClass><georss:point>0.256 -71.92"
        "</georss:point></GDataGeoTestClass>" }, // RSSPoint
    { @"geoLocation.latitude", @"0.256" },
    { @"geoLocation.longitude", @"-71.92" },
    { @"", @"" },
      
    { @"GDataGeoTestClass", @"<GDataGeoTestClass><georss:where><gml:Point><gml:pos>-1.256 -71.92" // RSSWhere
      "</gml:pos></gml:Point></georss:where></GDataGeoTestClass>" },
    { @"geoLocation.latitude", @"-1.256" },
    { @"geoLocation.longitude", @"-71.92" },
    { @"", @"" },
    
    { nil, nil }
  };
  
  [self runElementTests:tests];
  
}


- (void)testHealthElements {
  NSString *str = @"<ContinuityOfCareRecord xmlns='urn:astm-org:CCR'>"
    "<CCRDocumentObjectID>AgJ5uTnC3A</CCRDocumentObjectID>"
    "<etc>Frogfoot</etc></ContinuityOfCareRecord>";

  NSError *error = nil;
  NSXMLElement *element;
  element = [[[NSXMLElement alloc] initWithXMLString:str
                                               error:&error] autorelease];
  GDataContinuityOfCareRecord *ccr;
  ccr = [GDataContinuityOfCareRecord objectWithXMLElement:element];

  NSDictionary *expectedNS;
  expectedNS = [NSDictionary dictionaryWithObject:kGDataNamespaceCCR
                                           forKey:@""];
  STAssertEqualObjects([ccr namespaces], expectedNS, @"namespaces error");

  NSArray *children = [ccr childXMLElements];
  NSXMLNode *objid = [children objectAtIndex:0];
  STAssertEqualObjects([objid stringValue], @"AgJ5uTnC3A",
                       @"child value error");
}


- (void)testGDataExtendedProperty {
  
  // test the XMLValue key/value APIs
  NSString *key1 = @"noxweed";
  NSString *value1 = @"horgood\nbatman";

  NSString *key2 = @"frubble map";
  NSString *template = @"Ellipsis (%C) and other chars \"<&>";
  NSString *value2 = [NSString stringWithFormat:template, 8230];

  GDataExtendedProperty *extProp;
  extProp = [GDataExtendedProperty propertyWithName:@"zum" value:nil];
  
  [extProp setXMLValue:value1 forKey:key1];
  [extProp setXMLValue:value2 forKey:key2];
  
  NSString *testValue1 = [extProp XMLValueForKey:key1];
  STAssertEqualObjects(testValue1, value1, @"bad XML value storage 1");
  
  NSString *testValue2 = [extProp XMLValueForKey:key2];
  STAssertEqualObjects(testValue2, value2, @"bad XML value storage 2");

  // convert to XML, then reinstantiate as a GDataObject, and test 
  // that everything was preserved
  NSXMLElement *element = [extProp XMLElement];
  
  GDataExtendedProperty *extProp2;
  extProp2 = [[[GDataExtendedProperty alloc] initWithXMLElement:element
                                                         parent:nil] autorelease];
  testValue1 = [extProp2 XMLValueForKey:key1];
  STAssertEqualObjects(testValue1, value1, @"bad XML value storage 1");

  testValue2 = [extProp2 XMLValueForKey:key2];
  STAssertEqualObjects(testValue2, value2, @"bad XML value storage 2");
  
  // verify that the default namespace is empty so that extended
  // properties stored as XML children won't be considered part of the
  // atom namespace

  NSDictionary *namespaces = [extProp2 namespaces];
  STAssertEqualObjects([namespaces objectForKey:@""], @"", 
                       @"Missing default namespace from GDataObject");
  
#if !GDATA_USES_LIBXML
  // verify that the NSXMLElement really has the default namespace we expect
  //
  // this is conditional to avoid a dependency on NSXMLElement's 
  // namespaceForPrefix method in libxml builds
  //
  NSString *nsStr = [[element namespaceForPrefix:@""] XMLString];
  STAssertEqualObjects(nsStr, @"xmlns=\"\"",
                       @"Missing default namespace from XML element");
#endif
}

- (void)testEntryInputStreams {

  GDataEntryPhoto *entry = [GDataEntryPhoto photoEntry];

  //
  // test multi-part MIME stream with entry data and XML, and headers
  //

  const char *dataChars = "abcdefg";

  NSData *data = [NSData dataWithBytes:dataChars length:strlen(dataChars)];
  [entry setPhotoData:data];
  [entry setPhotoMIMEType:@"image/jpeg"];
  [entry setPhotoDescriptionWithString:@"cloud burst"];
  [entry setUploadSlug:@"testfile.jpg"];

  NSInputStream *inputStream = nil;
  unsigned long long streamLength = 0;
  NSDictionary *streamHeaders = nil;
  BOOL gotStream = [entry generateContentInputStream:&inputStream
                                              length:&streamLength
                                             headers:&streamHeaders];
  STAssertTrue(gotStream, @"generating multipart stream");

  NSMutableData *streamData = [NSMutableData dataWithLength:streamLength];
  [inputStream open];
  [inputStream read:[streamData mutableBytes] maxLength:streamLength];
  [inputStream close];

  NSString *streamDataStr = [[[NSString alloc] initWithData:streamData
                                                   encoding:NSUTF8StringEncoding] autorelease];

  NSString *expectedXmlStr = [[entry XMLElement] XMLString];
  NSString *expectedStr = [NSString stringWithFormat:
       @"\r\n--END_OF_PART\r\nContent-Type: application/atom+xml; charset=UTF-8"
       "\r\n\r\n%@\r\n"
       "--END_OF_PART\r\nContent-Transfer-Encoding: binary\r\n"
       "Content-Type: image/jpeg\r\n\r\n%s\r\n--END_OF_PART--\r\n",
       expectedXmlStr, dataChars];

  STAssertEqualObjects(streamDataStr, expectedStr, @"unexpected stream data");

  NSDictionary *expectedHeaders = [NSDictionary dictionaryWithObjectsAndKeys:
               @"multipart/related; boundary=\"END_OF_PART\"", @"Content-Type",
               @"1.0", @"MIME-Version",
               @"testfile.jpg", @"Slug", nil];
  STAssertEqualObjects(streamHeaders, expectedHeaders, @"unexpected headers");

  //
  // try again emitting only the data and headers, not the XML
  //
  [entry setShouldUploadDataOnly:YES];

  inputStream = nil;
  streamLength = 0;
  streamHeaders = nil;
  gotStream = [entry generateContentInputStream:&inputStream
                                         length:&streamLength
                                        headers:&streamHeaders];
  STAssertTrue(gotStream, @"generating multipart stream");

  streamData = [NSMutableData dataWithLength:streamLength];
  [inputStream open];
  [inputStream read:[streamData mutableBytes] maxLength:streamLength];
  [inputStream close];

  streamDataStr = [[[NSString alloc] initWithData:streamData
                                         encoding:NSUTF8StringEncoding] autorelease];

  expectedStr = [NSString stringWithUTF8String:dataChars];

  STAssertEqualObjects(streamDataStr, expectedStr, @"unexpected stream data 2");

  expectedHeaders = [NSDictionary dictionaryWithObjectsAndKeys:
                     @"image/jpeg", @"Content-Type",
                     @"1.0", @"MIME-Version",
                     @"testfile.jpg", @"Slug", nil];

  STAssertEqualObjects(streamHeaders, expectedHeaders, @"unexpected headers 2");
}

- (void)testChangedNamespace {
  
  // We'll allocate three objects which are equivalent except for 
  // differing namespace prefix declarations.
  
  // create with normal namespaces, including default of atom
  NSString * const xml0 = @"<entry xmlns=\"http://www.w3.org/2005/Atom\""
  " xmlns:gd=\"http://schemas.google.com/g/2005\"  >"
  " <gd:comments rel=\"http://schemas.google.com/g/2005#reviews\"> "
  "<gd:feedLink href=\"http://example.com/restaurants/SanFrancisco/432432/reviews\" > "
  "</gd:feedLink> <unkElement foo=\"bar\" /> <unkElement2 /> </gd:comments> </entry>";
  
  // use gx instead of gd for namespace prefix
  NSString * const xml1 = @"<entry xmlns=\"http://www.w3.org/2005/Atom\""
    " xmlns:gx=\"http://schemas.google.com/g/2005\"  >"
    " <gx:comments rel=\"http://schemas.google.com/g/2005#reviews\"> "
    "<gx:feedLink href=\"http://example.com/restaurants/SanFrancisco/432432/reviews\" > "
    "</gx:feedLink> <unkElement foo=\"bar\" /> <unkElement2 /> </gx:comments> </entry>";
  
  // make gd the default prefix, declare atom explicitly
  NSString * const xml2 = @"<entry xmlns:atom=\"http://www.w3.org/2005/Atom\""
  " xmlns=\"http://schemas.google.com/g/2005\"  >"
  " <comments rel=\"http://schemas.google.com/g/2005#reviews\"> "
  "<feedLink href=\"http://example.com/restaurants/SanFrancisco/432432/reviews\" > "
  "</feedLink> <unkElement foo=\"bar\" /> <unkElement2 /> </comments> </entry>";
  
  GDataObject *obj0 = [self GDataObjectForClassName:[GDataComment class]
                                          XMLString:xml0
                    shouldWrapWithNamespaceAndEntry:NO];
  STAssertNotNil(obj0, @"%@", obj0);

  GDataObject *obj1 = [self GDataObjectForClassName:[GDataComment class]
                                          XMLString:xml1
                    shouldWrapWithNamespaceAndEntry:NO];
  STAssertNotNil(obj1, @"%@", obj1);
  
  GDataObject *obj2 = [self GDataObjectForClassName:[GDataComment class]
                                          XMLString:xml2
                    shouldWrapWithNamespaceAndEntry:NO];
  STAssertNotNil(obj2, @"%@", obj2);
  
  STAssertEqualObjects(obj0, obj1, @"namespace interpretations should have made matching objects\n  %@\n!=\n  %@",
                       [obj0 XMLElement], [obj1 XMLElement]);
  STAssertEqualObjects(obj1, obj2, @"namespace interpretations should have made matching objects\n  %@\n!=\n  %@",
                       [obj1 XMLElement], [obj2 XMLElement]);
}

- (void)testNamespacePruning {
  NSString * const xml1 = @"<entry xmlns='http://schemas.google.com/g/2005'>"
  " <comments xmlns:atom='http://www.w3.org/2005/Atom'"
  "           rel='http://schemas.google.com/g/2005#reviews'> "
  "<feedLink xmlns:atom='http://www.w3.org/2005/Atom' xmlns:foo='bar'"
  "href=\"http://example.com/restaurants/SanFrancisco/432432/reviews\" > "
  "</feedLink> <unkElement foo=\"bar\" /> <unkElement2 /> </comments> </entry>";

  // the entry element's namespaces are stripped off when the object is
  // generated by the unit test's routine, so they won't show up in the
  // dictionary of complete namespaces
  //
  // atom is defined in the comments and in the feedlink
  GDataComment *obj1 = [self GDataObjectForClassName:[GDataComment class]
                                          XMLString:xml1
                    shouldWrapWithNamespaceAndEntry:NO];

  GDataFeedLink *feedLink = [obj1 feedLink];

  NSDictionary *namespaces = [feedLink namespaces];
  NSDictionary *completeNamespaces = [feedLink completeNamespaces];
  STAssertEquals((int) [namespaces count], 2, @"%@", namespaces);
  STAssertEquals((int) [completeNamespaces count], 2, @"%@", completeNamespaces);

  // prune the duplicate atom namespace
  [feedLink pruneInheritedNamespaces];

  namespaces = [feedLink namespaces];
  completeNamespaces = [feedLink completeNamespaces];
  STAssertEquals((int) [namespaces count], 1, @"%@", namespaces);
  STAssertEquals((int) [completeNamespaces count], 2, @"%@", completeNamespaces);
}

- (void)testDescriptionGeneration {

  // testing various GDataDescRecTypes:
  //
  //   title          is type kGDataDescValueLabeled
  //   categories     is type kGDataDescArrayCount
  //   links          is type kGDataDescValueIsKeyPath
  //   uploadDataOnly is type kGDataDescBooleanPresent
  //   uploadData     is type kGDataDescNonZeroLength

  GDataEntryContact *entry = [[[GDataEntryContact alloc] initWithServiceVersion:@"2.0"] autorelease];
  [entry setTitleWithString:@"Fred Flintstone"];
  [entry addLink:[GDataLink linkWithRel:@"rel" type:nil href:@"href"]];
  [entry setShouldUploadDataOnly:YES];
  [entry setUploadData:[NSData dataWithBytes:"  " length:2]];

  NSString *desc = [entry description];

#if GDATA_SIMPLE_DESCRIPTIONS
  NSString *expectedBody = @": {extensions:(category,link,title)}";
#else
  NSString *expectedBody = @": {v:2.0 title:Fred Flintstone categories:1"
  " links:rel uploadDataOnly:YES UploadData:#2}";
#endif

  NSScanner *scanner = [NSScanner scannerWithString:desc];
  NSString *className = nil;
  NSString *body = nil;

  [scanner scanUpToString:@" " intoString:&className];
  [scanner scanHexInt:nil];
  [scanner scanUpToString:@"\n" intoString:&body];

  STAssertEqualObjects(className, @"GDataEntryContact", @"classname description");
  STAssertEqualObjects(body, expectedBody, @"body description");
}

- (void)testControlCharacterRemoval {
  NSString *str = [NSString stringWithFormat:@"bunnyrabbit%C%C%C", 0, 1, 2];
  
  GDataTextConstruct *tc = [GDataTextConstruct textConstructWithString:str];
  NSXMLElement *elem = [tc XMLElement];
  NSString *elemStr = [elem XMLString];
  
  NSString *className = [GDataTextConstruct className];
  NSString *expectedStr = [NSString stringWithFormat:@"<%@>bunnyrabbit</%@>",
                           className, className];

  STAssertEqualObjects(elemStr, expectedStr, @"failed to remove control chars");
}

- (void)testProperties {
    
  NSString * const xml = @"<entry xmlns=\"http://www.w3.org/2005/Atom\""
  " xmlns:gd=\"http://schemas.google.com/g/2005\"  >"
  " <gd:comments rel=\"http://schemas.google.com/g/2005#reviews\"> "
  "<gd:feedLink href=\"http://example.com/restaurants/SanFrancisco/432432/reviews\" > "
  "</gd:feedLink>  </gd:comments> </entry>";
  
  GDataObject *obj = [self GDataObjectForClassName:[GDataComment class]
                                          XMLString:xml
                    shouldWrapWithNamespaceAndEntry:NO];
  STAssertNotNil(obj, @"%@", obj);
  
  NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
    @"0", @"zero", @"1", @"one", nil];
  
  // set all properties
  [obj setProperties:dict];
  
  // change one property
  [obj setProperty:@"2" forKey:@"two"];
  
  // delete one property
  [obj setProperty:nil forKey:@"zero"];
  
  STAssertNil([obj propertyForKey:@"zero"], @"prop 0 problem");
  STAssertEqualObjects([obj propertyForKey:@"one"], @"1", @"prop 1 problem");
  STAssertEqualObjects([obj propertyForKey:@"two"], @"2", @"prop 2 problem");
}


@end

// class for testing GDataGeo (used above)

// this internal test class doesn't have a macro defined in GDataTargetNamespace
#ifdef GDATA_TARGET_NAMESPACE
  #define GDataGeoTestClass _GDATA_NS_SYMBOL(GDataGeoTestClass)
#endif

@interface GDataGeoTestClass : GDataObject
@end

@implementation GDataGeoTestClass

- (void)addExtensionDeclarations {
  [super addExtensionDeclarations];
  
  [GDataGeo addGeoExtensionDeclarationsToObject:self
                                 forParentClass:[self class]];
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"GDataGeoTestClass"];
  return element;
}

#pragma mark -

- (GDataGeo *)geoLocation {
  return [GDataGeo geoLocationForObject:self];
}

- (void)setGeoLocation:(GDataGeo *)geo {
  [GDataGeo setGeoLocation:geo forObject:self];
}

@end
