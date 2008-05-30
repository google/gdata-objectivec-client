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
//  GDataEntryContent.m
//
//  This is a subclass of GDataTextConstruct
//

#import "GDataEntryContent.h"

static NSString* const kSourceAttr = @"src";

@implementation GDataEntryContent
// For content which may be text, like
//  <content type="text">Event title</title>
//
// or media content with a source URI specified,
//  <content src="http://lh.google.com/image/Car.jpg" type="image/jpeg"/>

+ (id)contentWithSourceURI:(NSString *)str type:(NSString *)type {
  
  GDataEntryContent *obj = [[[GDataEntryContent alloc] init] autorelease];
  [obj setSourceURI:str];
  [obj setType:type]; // type is part of the superclass
  return obj;
}

- (void)addParseDeclarations {
  
  // we're a subclass of GDataTextConstruct, so add its attributes also
  [super addParseDeclarations];
  
  NSArray *attrs = [NSArray arrayWithObject:kSourceAttr];
  [self addLocalAttributeDeclarations:attrs];  
}

- (NSString *)sourceURI {
  return [self stringValueForAttribute:kSourceAttr];
}

- (void)setSourceURI:(NSString *)str {
  [self setStringValue:str forAttribute:kSourceAttr];
}

@end

