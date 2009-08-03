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
//  GDataOriginalEvent.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE

#import "GDataOriginalEvent.h"
#import "GDataWhen.h"

static NSString* const kIDAttr = @"id";
static NSString* const kHrefAttr = @"href";

@implementation GDataOriginalEvent
// original event element, as in
// <gd:originalEvent id="i8fl1nrv2bl57c1qgr3f0onmgg"
//         href="http://www.google.com/calendar/feeds/userID/private-magicCookie/full/eventID">
//         <gd:when startTime="2006-03-17T22:00:00.000Z"/>
// </gd:originalEvent>
//
// http://code.google.com/apis/gdata/common-elements.html#gdOriginalEvent

+ (NSString *)extensionElementURI       { return kGDataNamespaceGData; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGDataPrefix; }
+ (NSString *)extensionElementLocalName { return @"originalEvent"; }

+ (GDataOriginalEvent *)originalEventWithID:(NSString *)originalID
                                       href:(NSString *)feedHref
                          originalStartTime:(GDataWhen *)startTime {
  
  GDataOriginalEvent *obj = [[[GDataOriginalEvent alloc] init] autorelease];
  [obj setHref:feedHref];
  [obj setOriginalID:originalID];
  [obj setOriginalStartTime:startTime];
  return obj;
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataWhen class]];
}

- (void)addParseDeclarations {
  NSArray *attrs = [NSArray arrayWithObjects: 
                    kIDAttr, kHrefAttr, nil];
  
  [self addLocalAttributeDeclarations:attrs];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [super itemsForDescription];
  
  // add extensions  
  [self addToArray:items objectDescriptionIfNonNil:[self originalStartTime] withName:@"startTime"];
  
  return items;
}
#endif

#pragma mark -

- (NSString *)href {
  return [self stringValueForAttribute:kHrefAttr];
}
- (void)setHref:(NSString *)str {
  [self setStringValue:str forAttribute:kHrefAttr];
}

- (NSString *)originalID {
  return [self stringValueForAttribute:kIDAttr];
}

- (void)setOriginalID:(NSString *)str {
  [self setStringValue:str forAttribute:kIDAttr];
}

- (GDataWhen *)originalStartTime {
  return [self objectForExtensionClass:[GDataWhen class]];
}

- (void)setOriginalStartTime:(GDataWhen *)startTime {
  [self setObject:startTime forExtensionClass:[GDataWhen class]];
}
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE
