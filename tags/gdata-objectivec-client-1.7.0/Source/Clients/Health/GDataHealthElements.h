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

#import "GDataObject.h"

// use -childXMLElements to access child element, or
// -XMLElement to generate an XML tree with
// the ContinuityOfCare or ProfileMetaData as the root element

@interface GDataContinuityOfCareRecord : GDataObject <GDataExtension>
@end

@interface GDataProfileMetaData : GDataObject <GDataExtension>
@end
