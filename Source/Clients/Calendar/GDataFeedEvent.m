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
//  GDataFeedEvent.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE

#import "GDataEntryEvent.h"
#import "GDataFeedEvent.h"
#import "GDataWhere.h"

@class GDataEntryEvent;

@implementation GDataFeedEvent

+ (GDataFeedEvent *)eventFeedWithXMLData:(NSData *)data {
  return [self feedWithXMLData:data];
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  Class feedClass = [self class];
  [self addExtensionDeclarationForParentClass:feedClass
                                   childClass:[GDataWhere class]];  
}

- (Class)classForEntries {
  return [GDataEntryEvent class];
}

#pragma mark -

- (NSArray *)wheres {
  return [self objectsForExtensionClass:[GDataWhere class]];
}

- (void)setWheres:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataWhere class]];
}

- (void)addWhere:(GDataWhere *)obj {
  [self addObject:obj forExtensionClass:[obj class]];
}
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE
