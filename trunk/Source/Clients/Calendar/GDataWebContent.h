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
//  GDataWebContent.h
//

#import <Cocoa/Cocoa.h>
#import "GDataObject.h"

@interface GDataWebContent : GDataObject <NSCopying, GDataExtension> {
  NSNumber *height_;
  NSNumber *width_;
  NSString *url_;
}

+ (GDataWebContent *)webContentWithURL:(NSString *)urlString
                                 width:(int)width
                                height:(int)height;

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent;

- (NSXMLElement *)XMLElement;

- (NSNumber *)height;
- (void)setHeight:(NSNumber *)num;
- (NSNumber *)width;
- (void)setWidth:(NSNumber *)num;
- (NSString *)URLString;
- (void)setURLString:(NSString *)str;
@end
