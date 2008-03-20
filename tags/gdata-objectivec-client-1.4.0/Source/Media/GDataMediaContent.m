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
//  GDataMediaContent.m
//

#import "GDataMediaContent.h"
#import "GDataMediaGroup.h"

@implementation GDataMediaContent
// media:content element
//
//  <media:content 
//    url="http://www.foo.com/movie.mov" 
//    fileSize="12216320" 
//    type="video/quicktime"
//    medium="video"
//    isDefault="true" 
//    expression="full" 
//    bitrate="128" 
//    framerate="25"
//    samplingrate="44.1"
//    channels="2"
//    duration="185" 
//    height="200"
//    width="300" 
//    lang="en" />
//
// http://search.yahoo.com/mrss


+ (NSString *)extensionElementURI       { return kGDataNamespaceMedia; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceMediaPrefix; }
+ (NSString *)extensionElementLocalName { return @"content"; }

+ (GDataMediaContent *)mediaContentWithURLString:(NSString *)urlString {
  
  GDataMediaContent *obj = [[[GDataMediaContent alloc] init] autorelease];
  [obj setURLString:urlString];
  return obj;
}

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setURLString:[self stringForAttributeName:@"url"
                                        fromElement:element]];
    [self setFileSize:[self longLongNumberForAttributeName:@"fileSize"
                                               fromElement:element]];
    [self setType:[self stringForAttributeName:@"type"
                                   fromElement:element]];
    [self setMedium:[self stringForAttributeName:@"medium"
                                     fromElement:element]];
    [self setIsDefault:[self boolNumberForAttributeName:@"isDefault"
                                            fromElement:element]];
    [self setExpression:[self stringForAttributeName:@"expression"
                                         fromElement:element]];
    [self setBitrate:[self decimalNumberForAttributeName:@"bitrate"
                                             fromElement:element]];
    [self setFramerate:[self decimalNumberForAttributeName:@"framerate"
                                               fromElement:element]];
    [self setSamplingrate:[self decimalNumberForAttributeName:@"samplingrate"
                                                  fromElement:element]];
    [self setChannels:[self intNumberForAttributeName:@"channels"
                                          fromElement:element]];
    [self setDuration:[self intNumberForAttributeName:@"duration"
                                          fromElement:element]];
    [self setHeight:[self intNumberForAttributeName:@"height"
                                        fromElement:element]];
    [self setWidth:[self intNumberForAttributeName:@"width"
                                       fromElement:element]];
    [self setLang:[self stringForAttributeName:@"lang"
                                   fromElement:element]];
  }
  return self;
}

- (void)dealloc {
  [urlString_ release];
  [fileSize_ release];
  [type_ release];
  [medium_ release];
  [isDefault_ release];
  [expression_ release];
  [bitrate_ release];
  [framerate_ release];
  [samplingrate_ release];
  [channels_ release];
  [duration_ release];
  [height_ release];
  [width_ release];
  [lang_ release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataMediaContent* newObj = [super copyWithZone:zone];
  [newObj setURLString:[self URLString]];
  [newObj setFileSize:[self fileSize]];
  [newObj setType:[self type]];
  [newObj setMedium:[self medium]];
  [newObj setIsDefault:[self isDefault]];
  [newObj setExpression:[self expression]];
  [newObj setBitrate:[self bitrate]];
  [newObj setFramerate:[self framerate]];
  [newObj setSamplingrate:[self samplingrate]];
  [newObj setChannels:[self channels]];
  [newObj setDuration:[self duration]];
  [newObj setHeight:[self height]];
  [newObj setWidth:[self width]];
  [newObj setLang:[self lang]];
  return newObj; 
}

- (BOOL)isEqual:(GDataMediaContent *)other {
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataMediaContent class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self URLString], [other URLString])
    && AreEqualOrBothNil([self fileSize], [other fileSize])
    && AreEqualOrBothNil([self type], [other type])
    && AreEqualOrBothNil([self medium], [other medium])
    && AreEqualOrBothNil([self isDefault], [other isDefault])
    && AreEqualOrBothNil([self expression], [other expression])
    && AreEqualOrBothNil([self bitrate], [other bitrate])
    && AreEqualOrBothNil([self framerate], [other framerate])
    && AreEqualOrBothNil([self samplingrate], [other samplingrate])
    && AreEqualOrBothNil([self channels], [other channels])
    && AreEqualOrBothNil([self duration], [other duration])
    && AreEqualOrBothNil([self height], [other height])
    && AreEqualOrBothNil([self width], [other width])
    && AreEqualOrBothNil([self lang], [other lang]);
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:urlString_ withName:@"URL"];
  [self addToArray:items objectDescriptionIfNonNil:fileSize_ withName:@"fileSize"];
  [self addToArray:items objectDescriptionIfNonNil:type_ withName:@"type"];
  [self addToArray:items objectDescriptionIfNonNil:medium_ withName:@"medium"];
  [self addToArray:items objectDescriptionIfNonNil:isDefault_ withName:@"isDefault"];
  [self addToArray:items objectDescriptionIfNonNil:expression_ withName:@"expression"];
  [self addToArray:items objectDescriptionIfNonNil:bitrate_ withName:@"bitrate"];
  [self addToArray:items objectDescriptionIfNonNil:framerate_ withName:@"framerate"];
  [self addToArray:items objectDescriptionIfNonNil:samplingrate_ withName:@"samplingrate"];
  [self addToArray:items objectDescriptionIfNonNil:channels_ withName:@"channels"];
  [self addToArray:items objectDescriptionIfNonNil:duration_ withName:@"duration"];
  [self addToArray:items objectDescriptionIfNonNil:height_ withName:@"height"];
  [self addToArray:items objectDescriptionIfNonNil:width_ withName:@"width"];
  [self addToArray:items objectDescriptionIfNonNil:lang_ withName:@"lang"];
  
  return items;
}


- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:@"media:content"];
  
  // decimal numbers should have period separators

  // Leopard deprecated the constant NSDecimalSeparator but it's still
  // needed by NSDecimalNumber (radar 5674482)
  NSString *const kNSDecimalSeparator = @"NSDecimalSeparator";
  NSDictionary *locale = [NSDictionary dictionaryWithObject:@"."
                                                     forKey:kNSDecimalSeparator];

  [self addToElement:element attributeValueIfNonNil:[self URLString] withName:@"url"];
  [self addToElement:element attributeValueIfNonNil:[[self fileSize] stringValue] withName:@"fileSize"];
  [self addToElement:element attributeValueIfNonNil:[self type]  withName:@"type"];
  [self addToElement:element attributeValueIfNonNil:[self medium] withName:@"medium"];
  if ([self isDefault]) {
    [self addToElement:element attributeValueIfNonNil:([self isDefault] ? @"true" : @"false") withName:@"isDefault"];
  }
  [self addToElement:element attributeValueIfNonNil:[self expression] withName:@"expression"];
  [self addToElement:element attributeValueIfNonNil:[[self bitrate] descriptionWithLocale:locale] withName:@"bitrate"];
  [self addToElement:element attributeValueIfNonNil:[[self framerate] descriptionWithLocale:locale] withName:@"framerate"];
  [self addToElement:element attributeValueIfNonNil:[[self samplingrate] descriptionWithLocale:locale] withName:@"samplingrate"];
  [self addToElement:element attributeValueIfNonNil:[[self channels] stringValue] withName:@"channels"];
  [self addToElement:element attributeValueIfNonNil:[[self duration] stringValue] withName:@"duration"];
  [self addToElement:element attributeValueIfNonNil:[[self height] stringValue] withName:@"height"];
  [self addToElement:element attributeValueIfNonNil:[[self width] stringValue] withName:@"width"];
  [self addToElement:element attributeValueIfNonNil:[self lang] withName:@"lang"];
  
  return element;
}

#pragma mark -

- (NSString *)URLString {
  return urlString_; 
}
- (void)setURLString:(NSString *)str {
  [urlString_ autorelease];
  urlString_ = [str copy];
}

- (NSNumber *)fileSize {
  return fileSize_; 
}
- (void)setFileSize:(NSNumber *)num {
  [fileSize_ autorelease];
  fileSize_ = [num copy];
}

- (NSString *)type {
  return type_; 
}
- (void)setType:(NSString *)str {
  [type_ autorelease];
  type_ = [str copy];
}

- (NSString *)medium {
  return medium_;
}
- (void)setMedium:(NSString *)str {
  [medium_ autorelease];
  medium_ = [str copy];
}

- (NSNumber *)isDefault {
  return isDefault_; 
}
- (void)setIsDefault:(NSNumber *)num {
  [isDefault_ autorelease];
  isDefault_ = [num copy];
}

- (NSString *)expression {
  return expression_;
}
- (void)setExpression:(NSString *)str {
  [expression_ autorelease];
  expression_ = [str copy]; 
}

- (NSDecimalNumber *)bitrate {
  return bitrate_; 
}
- (void)setBitrate:(NSDecimalNumber *)num {
  [bitrate_ autorelease];
  bitrate_ = [num copy];
}

- (NSDecimalNumber *)framerate {
  return framerate_; 
}
- (void)setFramerate:(NSDecimalNumber *)num {
  [framerate_ autorelease];
  framerate_ = [num copy];
}

- (NSDecimalNumber *)samplingrate {
  return samplingrate_; 
}
- (void)setSamplingrate:(NSDecimalNumber *)num {
  [samplingrate_ autorelease];
  samplingrate_ = [num copy];
}

- (NSNumber *)channels {
  return channels_; 
}
- (void)setChannels:(NSNumber *)num {
  [channels_ autorelease];
  channels_ = [num copy];
}

- (NSNumber *)duration {
  return duration_; 
}
- (void)setDuration:(NSNumber *)num {
  [duration_ autorelease];
  duration_ = [num copy];
}

- (NSNumber *)height {
  return height_; 
}
- (void)setHeight:(NSNumber *)num {
  [height_ autorelease];
  height_ = [num copy];
}

- (NSNumber *)width {
  return width_; 
}
- (void)setWidth:(NSNumber *)num {
  [width_ autorelease];
  width_ = [num copy];
}

- (NSString *)lang {
  return lang_;
}
- (void)setLang:(NSString *)str {
  [lang_ autorelease];
  lang_ = [str copy];
}

@end


