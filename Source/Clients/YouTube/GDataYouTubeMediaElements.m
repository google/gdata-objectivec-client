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
//  GDataYouTubeMediaElements.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#define GDATAYOUTUBEMEDIAELEMENTS_DEFINE_GLOBALS 1
#import "GDataYouTubeMediaElements.h"
#import "GDataYouTubeConstants.h"

// yt:format attribute
@interface GDataYouTubeFormatAttribute : GDataAttribute <GDataExtension>
@end

@implementation GDataYouTubeFormatAttribute
+ (NSString *)extensionElementURI { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"format"; }
@end

@implementation GDataMediaContent (YouTubeExtensions)

// media content with YouTube's addition of an integer format attribute, 
// like yt:format="1"
- (NSNumber *)youTubeFormatNumber {
  NSString *str = [self attributeValueForExtensionClass:[GDataYouTubeFormatAttribute class]];
  NSNumber *number = [NSNumber numberWithInt:[str intValue]]; 
  return number;
}

- (void)setYouTubeFormatNumber:(NSNumber *)num {
  [self setAttributeValue:[num stringValue] forExtensionClass:[GDataYouTubeFormatAttribute class]];
}

@end

// yt:name attribute
@interface GDataYouTubeNameAttribute : GDataAttribute <GDataExtension>
@end

@implementation GDataYouTubeNameAttribute
+ (NSString *)extensionElementURI { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"name"; }
@end

@implementation GDataMediaThumbnail (YouTubeExtensions)

// media thumbnail with YouTube's addition of a name attribute,
// like yt:name="default"
- (NSString *)youTubeName {
  NSString *str = [self attributeValueForExtensionClass:[GDataYouTubeNameAttribute class]];
  return str;
}

- (void)setYouTubeName:(NSString *)str {
  [self setAttributeValue:str forExtensionClass:[GDataYouTubeNameAttribute class]];
}

@end

// yt:country attribute
@interface GDataYouTubeCountryAttribute : GDataAttribute <GDataExtension>
@end

@implementation GDataYouTubeCountryAttribute
+ (NSString *)extensionElementURI { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"country"; }
@end

@implementation GDataMediaRating (YouTubeExtensions)

// media rating with YouTube's addition of a country attribute, 
// like yt:country="USA"
- (NSString *)youTubeCountry {
  NSString *str = [self attributeValueForExtensionClass:[GDataYouTubeCountryAttribute class]];
  return str;
}

- (void)setYouTubeCountry:(NSString *)str {
  [self setAttributeValue:str
        forExtensionClass:[GDataYouTubeCountryAttribute class]];
}

@end

// type attribute extension to media credit (v2.0)
@interface GDataYouTubeTypeAttribute : GDataAttribute <GDataExtension>
@end

@implementation GDataYouTubeTypeAttribute
+ (NSString *)extensionElementURI { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"type"; }
@end

@implementation GDataMediaCredit (YouTubeExtensions)
// media credit with YouTube's addition of a type attribute, 
// like yt:type="partner"
- (NSString *)youTubeCreditType {
  NSString *str = [self attributeValueForExtensionClass:[GDataYouTubeTypeAttribute class]];
  return str;
}

- (void)setYouTubeCreditType:(NSString *)str {
  [self setAttributeValue:str
        forExtensionClass:[GDataYouTubeTypeAttribute class]];
}
@end

@implementation GDataYouTubeMediaGroup

// a media group with YouTube extensions

- (void)addExtensionDeclarations {
  
  [super addExtensionDeclarations];
  
  [self addExtensionDeclarationForParentClass:[self class]
                                 childClasses:
   [GDataYouTubeAspectRatio class],
   [GDataYouTubeDuration class],
   [GDataYouTubePrivate class],
   [GDataYouTubeVideoID class],
   [GDataYouTubeUploadedDate class],
   nil];
  
  // add the yt:format attribute to GDataMediaContent
  [self addAttributeExtensionDeclarationForParentClass:[GDataMediaContent class]
                                            childClass:[GDataYouTubeFormatAttribute class]];

  // add the yt:country attribute to GDataMediaRating
  [self addAttributeExtensionDeclarationForParentClass:[GDataMediaRating class]
                                            childClass:[GDataYouTubeCountryAttribute class]];

  // add the yt:type attribute to GDataMediaCredit
  [self addAttributeExtensionDeclarationForParentClass:[GDataMediaCredit class]
                                            childClass:[GDataYouTubeTypeAttribute class]];

  // add the yt:name attribute to GDataMediaThumbnail
  [self addAttributeExtensionDeclarationForParentClass:[GDataMediaThumbnail class]
                                            childClass:[GDataYouTubeNameAttribute class]];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"duration",    @"duration",     kGDataDescValueLabeled   },
    { @"videoID",     @"videoID",      kGDataDescValueLabeled   },
    { @"aspectRatio", @"aspectRatio",  kGDataDescValueLabeled   },
    { @"uploaded",    @"uploadedDate", kGDataDescValueLabeled   },
    { @"private",     @"isPrivate",    kGDataDescBooleanPresent },
    { nil, nil, (GDataDescRecTypes)0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

#pragma mark -

- (NSNumber *)duration {
  GDataYouTubeDuration *obj = [self objectForExtensionClass:[GDataYouTubeDuration class]];
  return [obj intNumberValue];
}

- (void)setDuration:(NSNumber *)num {
  GDataYouTubeDuration *obj = [GDataYouTubeDuration valueWithNumber:num];
  [self setObject:obj forExtensionClass:[GDataYouTubeDuration class]];
}

- (BOOL)isPrivate {
  GDataYouTubePrivate *obj = [self objectForExtensionClass:[GDataYouTubePrivate class]];
  return (obj != nil);
}

- (void)setIsPrivate:(BOOL)flag {
  if (flag) {
    GDataYouTubePrivate *private = [GDataYouTubePrivate implicitValue];
    [self setObject:private forExtensionClass:[GDataYouTubePrivate class]];
  } else {
    [self setObject:nil forExtensionClass:[GDataYouTubePrivate class]];
  }
}

// videoID available in v2.0
- (NSString *)videoID {
  GDataYouTubeVideoID *obj;
  
  obj = [self objectForExtensionClass:[GDataYouTubeVideoID class]];
  return [obj stringValue];
}

- (void)setVideoID:(NSString *)str {
  GDataYouTubeVideoID *obj = [GDataYouTubeVideoID valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeVideoID class]];
}

// uploadedDate available in v2.0
- (GDataDateTime *)uploadedDate {
  GDataYouTubeUploadedDate *obj;
  
  obj = [self objectForExtensionClass:[GDataYouTubeUploadedDate class]];
  return [obj dateTimeValue];
}

- (void)setUploadedDate:(GDataDateTime *)dateTime {
  GDataYouTubeUploadedDate *obj;

  obj = [GDataYouTubeUploadedDate valueWithDateTime:dateTime];
  [self setObject:obj forExtensionClass:[GDataYouTubeUploadedDate class]];
}

// aspectRatio available in v2.0
- (NSString *)aspectRatio {
  GDataYouTubeAspectRatio *obj;

  obj = [self objectForExtensionClass:[GDataYouTubeAspectRatio class]];
  return [obj stringValue];
}

- (void)setAspectRatio:(NSString *)str {
  GDataYouTubeAspectRatio *obj = [GDataYouTubeAspectRatio valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataYouTubeAspectRatio class]];
}

// convenience accessors
- (GDataMediaThumbnail *)highQualityThumbnail {
  // the HQ thumbnail is the one lacking a time attribute
  NSArray *array = [self mediaThumbnails];
  GDataMediaThumbnail *obj = [GDataUtilities firstObjectFromArray:array
                                                        withValue:nil
                                                       forKeyPath:@"time"];
  return obj;
}

- (GDataMediaContent *)mediaContentWithFormatNumber:(NSInteger)formatNumber {
  NSArray *mediaContents = [self mediaContents];

  NSNumber *formatNum = [NSNumber numberWithInteger:formatNumber];

  GDataMediaContent *content;
  content = [GDataUtilities firstObjectFromArray:mediaContents
                                       withValue:formatNum
                                      forKeyPath:@"youTubeFormatNumber"];
  return content;
}
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
