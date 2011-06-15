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
//  GDataVolumeReadingPosition.m
//

// reading position, like
//   <gbs:readingPosition action="NextPage"
//                        application="Sony Reader"
//                        value="GBS.25.w.2.9.15"
//                        time="2007-07-16T00:00:00" />

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BOOKS_SERVICE

#import "GDataVolumeReadingPosition.h"
#import "GDataBookConstants.h"

static NSString* const kActionAttr      = @"action";
static NSString* const kApplicationAttr = @"application";
static NSString* const kTimeAttr        = @"time";
static NSString* const kValueAttr       = @"value";

@implementation GDataVolumeReadingPosition

+ (NSString *)extensionElementURI       { return kGDataNamespaceBooks; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceBooksPrefix; }
+ (NSString *)extensionElementLocalName { return @"readingPosition"; }

+ (GDataVolumeReadingPosition *)positionWithAction:(NSString *)action
                                   applicationName:(NSString *)name
                                              time:(GDataDateTime *)dateTime
                                             value:(NSString *)value {
  GDataVolumeReadingPosition *obj = [self object];
  [obj setAction:action];
  [obj setApplicationName:name];
  [obj setValue:value];
  [obj setPositionTime:dateTime];
  return obj;
}

- (void)addParseDeclarations {
  NSArray *attrs = [NSArray arrayWithObjects:
                    kActionAttr, kApplicationAttr, kTimeAttr, kValueAttr, nil];
  [self addLocalAttributeDeclarations:attrs];
}

#pragma mark -

- (NSString *)action {
  return [self stringValueForAttribute:kActionAttr];
}

- (void)setAction:(NSString *)str {
  [self setStringValue:str forAttribute:kActionAttr];
}

- (NSString *)applicationName {
  return [self stringValueForAttribute:kApplicationAttr];
}

- (void)setApplicationName:(NSString *)str {
  [self setStringValue:str forAttribute:kApplicationAttr];
}

- (NSString *)value {
  return [self stringValueForAttribute:kValueAttr];
}

- (void)setValue:(NSString *)str {
  [self setStringValue:str forAttribute:kValueAttr];
}

- (GDataDateTime *)positionTime {
  return [self dateTimeForAttribute:kTimeAttr];
}

- (void)setPositionTime:(GDataDateTime *)dateTime {
  [self setDateTimeValue:dateTime forAttribute:kTimeAttr];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BOOKS_SERVICE
