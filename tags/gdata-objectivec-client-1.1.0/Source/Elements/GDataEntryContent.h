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
//  GDataEntryContent.h
//

#import <Cocoa/Cocoa.h>

#import "GDataObject.h"
#import "GDataTextConstruct.h"

// For content which may be text, like
//  <content type="text">Event title</title>
//
// or media content with a source URI specified,
//  <content src="http://lh.google.com/image/Car.jpg" type="image/jpeg"/>

@interface GDataEntryContent : GDataTextConstruct <NSCopying> {
  NSString *src_;
}

+ (id)contentWithSourceURI:(NSString *)str type:(NSString *)type;

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent;

- (NSXMLElement *)XMLElement;

- (NSString *)sourceURI;
- (void)setSourceURI:(NSString *)str;

@end

