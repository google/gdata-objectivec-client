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
//  GDataWebContent.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE

#define GDATAWEBCONTENT_DEFINE_GLOBALS 1
#import "GDataWebContent.h"
#import "GDataEntryCalendarEvent.h"

static NSString* const kDisplayAttr = @"display";
static NSString* const kHeightAttr = @"height";
static NSString* const kWidthAttr = @"width";
static NSString* const kURLAttr = @"url";

@implementation GDataWebContentGadgetPref
+ (NSString *)extensionElementURI       { return kGDataNamespaceGCal; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGCalPrefix; }
+ (NSString *)extensionElementLocalName { return @"webContentGadgetPref"; }
@end

@implementation GDataWebContent 
// Calendar Web Content element, inside a <link>, as in
//
// <gCal:webContent url="http://www.google.com/logos/july4th06.gif" 
//                  width="276" height="120" >
//      <gCal:webContentGadgetPref name="color" value="green" />
//      <gCal:webContentGadgetPref name="military_time" value="false" />
// </gCal:webContent>
//
// http://code.google.com/apis/gdata/calendar.html#gCalwebContent

+ (NSString *)extensionElementURI       { return kGDataNamespaceGCal; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceGCalPrefix; }
+ (NSString *)extensionElementLocalName { return @"webContent"; }

+ (GDataWebContent *)webContentWithURL:(NSString *)urlString
                                 width:(int)width
                                height:(int)height {
  GDataWebContent *obj = [self object];
  [obj setURLString:urlString];
  [obj setWidth:[NSNumber numberWithInt:width]];
  [obj setHeight:[NSNumber numberWithInt:height]];
  return obj;
}

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  // gadget preference support
  [self addExtensionDeclarationForParentClass:[self class]
                                   childClass:[GDataWebContentGadgetPref class]];
}

- (void)addParseDeclarations {
  NSArray *attrs = [NSArray arrayWithObjects: 
                    kHeightAttr, kWidthAttr, kURLAttr, nil];
  
  [self addLocalAttributeDeclarations:attrs];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [super itemsForDescription];
  
  // make an array of name=value items for gadget prefs
  NSArray *prefs = [self gadgetPreferences];
  NSMutableArray *prefsItems = [NSMutableArray array];
  NSUInteger numPrefs = [prefs count];
  
  if (numPrefs) {
    for (NSUInteger idx = 0; idx < numPrefs; idx++) {
      GDataWebContentGadgetPref *pref = [prefs objectAtIndex:idx];
      
      NSString *str = [NSString stringWithFormat:@"%@=%@", 
        [pref name], [pref value]];
      
      [prefsItems addObject:str];
    }
    NSString *allPrefs = [prefsItems componentsJoinedByString:@","];
    [self addToArray:items objectDescriptionIfNonNil:allPrefs withName:@"gadgetPrefs"];
  }
  
  return items;
}
#endif

- (NSNumber *)height {
  return [self intNumberForAttribute:kHeightAttr]; 
}

- (void)setHeight:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kHeightAttr];
}

- (NSNumber *)width {
  return [self intNumberForAttribute:kWidthAttr]; 
}

- (void)setWidth:(NSNumber *)num {
  [self setStringValue:[num stringValue] forAttribute:kWidthAttr];
}

- (NSString *)URLString {
  return [self stringValueForAttribute:kURLAttr]; 
}

- (void)setURLString:(NSString *)str {
  [self setStringValue:str forAttribute:kURLAttr];
}

- (NSString *)display {
  return [self stringValueForAttribute:kDisplayAttr];
}

- (void)setDisplay:(NSString *)str {
  [self setStringValue:str forAttribute:kDisplayAttr];
}

// extensions

- (NSArray *)gadgetPreferences {
  return [self objectsForExtensionClass:[GDataWebContentGadgetPref class]]; 
}

- (void)setGadgetPreferences:(NSArray *)array {
  [self setObjects:array forExtensionClass:[GDataWebContentGadgetPref class]];
}

- (void)addGadgetPreference:(GDataWebContentGadgetPref *)obj {
  [self addObject:obj forExtensionClass:[GDataWebContentGadgetPref class]];  
}

// returning a dictionary simplifies key-value coding access
- (NSDictionary *)gadgetPreferenceDictionary {
  
  // step through all preferences and add their name/values to a dictionary
  NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
  
  for (GDataWebContentGadgetPref *pref in [self gadgetPreferences]) {
    [dictionary setObject:[pref value] forKey:[pref name]];
  }

  return dictionary;
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE
