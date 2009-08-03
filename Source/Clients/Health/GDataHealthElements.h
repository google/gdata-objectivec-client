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
//  GDataHealthElements.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_HEALTH_SERVICE

#import "GDataObject.h"

@interface GDataHealthContainerObject : GDataObject
// objectWithXMLElement does not parse the element, but rather constructs the
// new object incorporating the element's XML directly.
//
// The element's local name must match the extensionElementLocalName of the
// class being constructed.
+ (id)objectWithXMLElement:(NSXMLElement *)element;
@end


// use -childXMLElements to access child element, or
// -XMLElement to generate an XML tree with
// the ContinuityOfCare or ProfileMetaData as the root element

@interface GDataContinuityOfCareRecord : GDataHealthContainerObject <GDataExtension>
// this can be constructed from a CCR NSXMLElement with
//
// + (GDataObject *)objectWithXMLElement:(NSXMLElement *)element;
@end

@interface GDataProfileMetaData : GDataHealthContainerObject <GDataExtension>
// this can be constructed from a ProfileMetaData NSXMLElement with
//
// + (GDataObject *)objectWithXMLElement:(NSXMLElement *)element;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_HEALTH_SERVICE
