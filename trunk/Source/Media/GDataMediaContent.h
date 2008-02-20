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
//  GDataMediaContent.h
//

#import "GDataObject.h"


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

@interface GDataMediaContent : GDataObject <NSCopying, GDataExtension> {
  NSString* urlString_; 
  NSNumber* fileSize_;
  NSString* type_;
  NSString* medium_;
  NSNumber* isDefault_;
  NSString* expression_;
  NSDecimalNumber* bitrate_;
  NSDecimalNumber* framerate_;
  NSDecimalNumber* samplingrate_;
  NSNumber* channels_;
  NSNumber* duration_;
  NSNumber* height_;
  NSNumber* width_;
  NSString* lang_;
}
+ (GDataMediaContent *)mediaContentWithURLString:(NSString *)urlString;

- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent;
- (NSXMLElement *)XMLElement;

- (NSMutableArray *)itemsForDescription;

- (NSString *)URLString;
- (void)setURLString:(NSString *)str;

- (NSNumber *)fileSize;
- (void)setFileSize:(NSNumber *)num;

- (NSString *)type;
- (void)setType:(NSString *)str;

- (NSString *)medium;
- (void)setMedium:(NSString *)str;

- (NSNumber *)isDefault;
- (void)setIsDefault:(NSNumber *)num;

- (NSString *)expression;
- (void)setExpression:(NSString *)str;

- (NSDecimalNumber *)bitrate;
- (void)setBitrate:(NSDecimalNumber *)num;

- (NSDecimalNumber *)framerate;
- (void)setFramerate:(NSDecimalNumber *)num;

- (NSDecimalNumber *)samplingrate;
- (void)setSamplingrate:(NSDecimalNumber *)num;

- (NSNumber *)channels;
- (void)setChannels:(NSNumber *)num;

- (NSNumber *)duration;
- (void)setDuration:(NSNumber *)num;

- (NSNumber *)height;
- (void)setHeight:(NSNumber *)num;

- (NSNumber *)width;
- (void)setWidth:(NSNumber *)num;

- (NSString *)lang;
- (void)setLang:(NSString *)str;
@end
