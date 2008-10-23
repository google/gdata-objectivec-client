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
//  GDataAtomPubControl.h
//

#import "GDataObject.h"

// For app:control, like:
//   <app:control><app:draft>yes</app:draft></app:control>

@interface GDataAtomPubControl : GDataObject <NSCopying, GDataExtension> {
  BOOL isDraft_;
}

+ (GDataAtomPubControl *)atomPubControl;
+ (GDataAtomPubControl *)atomPubControlWithIsDraft:(BOOL)isDraft;

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent;

- (NSXMLElement *)XMLElement;

- (BOOL)isDraft;
- (void)setIsDraft:(BOOL)flag;

// implementation utilities
+ (Class)atomPubControlClassForObject:(GDataObject *)obj;

@end

// In version 1 of GData, a pre-standard URI was used
@interface GDataAtomPubControl1_0 : GDataAtomPubControl  <NSCopying, GDataExtension> 
@end
