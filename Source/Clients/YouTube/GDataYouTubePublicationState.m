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
//  GDataYouTubePublicationState.m
//

// yt:state is an extension to GDataAtomPubControl for YouTube video entries, 
// as in 
//
//  <app:control>
//    <yt:state name="rejected" reasonCode="32" helpUrl="http://www.youtube.com/">
//          incorrect format</yt:state>
//  </app:control>


#import "GDataYouTubePublicationState.h"
#import "GDataEntryYouTubeVideo.h"

@implementation GDataYouTubePublicationState 

+ (NSString *)extensionElementURI       { return kGDataNamespaceYouTube; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceYouTubePrefix; }
+ (NSString *)extensionElementLocalName { return @"state"; }


- (id)initWithXMLElement:(NSXMLElement *)element
                  parent:(GDataObject *)parent {
  self = [super initWithXMLElement:element
                            parent:parent];
  if (self) {
    [self setState:[self stringForAttributeName:@"name"
                                    fromElement:element]];
    [self setReasonCode:[self stringForAttributeName:@"reasonCode"
                                         fromElement:element]];
    [self setHelpURLString:[self stringForAttributeName:@"helpUrl"
                                            fromElement:element]];
    
    NSString *str = [self stringValueFromElement:element];
    if ([str length] > 0) {
      [self setErrorDescription:[self stringValueFromElement:element]];
    }
  }
  return self;
}

- (void)dealloc {
  
  [state_ release];
  [reasonCode_ release];
  [helpURLString_ release];
  [errorDescription_ release];

  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  GDataYouTubePublicationState* newObj = [super copyWithZone:zone];
  [newObj setState:[self state]];
  [newObj setReasonCode:[self reasonCode]];
  [newObj setHelpURLString:[self helpURLString]];
  [newObj setErrorDescription:[self errorDescription]];
    
  return newObj;
}

- (BOOL)isEqual:(GDataYouTubePublicationState *)other {
  
  if (self == other) return YES;
  if (![other isKindOfClass:[GDataYouTubePublicationState class]]) return NO;
  
  return [super isEqual:other]
    && AreEqualOrBothNil([self state], [other state])
    && AreEqualOrBothNil([self reasonCode], [other reasonCode])
    && AreEqualOrBothNil([self helpURLString], [other helpURLString])
    && AreEqualOrBothNil([self errorDescription], [other errorDescription]);
}

- (NSMutableArray *)itemsForDescription {
  NSMutableArray *items = [NSMutableArray array];
  
  [self addToArray:items objectDescriptionIfNonNil:[self state] withName:@"name"];
  [self addToArray:items objectDescriptionIfNonNil:[self reasonCode] withName:@"reasonCode"];
  [self addToArray:items objectDescriptionIfNonNil:[self helpURLString] withName:@"helpURL"];
  [self addToArray:items objectDescriptionIfNonNil:[self errorDescription] withName:@"description"];
  
  return items;
}

- (NSXMLElement *)XMLElement {
  
  NSXMLElement *element = [self XMLElementWithExtensionsAndDefaultName:nil];
  
  [self addToElement:element attributeValueIfNonNil:[self state] withName:@"name"];
  [self addToElement:element attributeValueIfNonNil:[self reasonCode] withName:@"reasonCode"];
  [self addToElement:element attributeValueIfNonNil:[self helpURLString] withName:@"helpUrl"];
  
  if ([self errorDescription]) {
    [element addStringValue:[self errorDescription]];
  }
  return element;
}

#pragma mark -

- (NSString *)state {
  return state_; 
}

- (void)setState:(NSString *)str {
  [state_ autorelease];
  state_ = [str copy];
}

- (NSString *)reasonCode {
  return reasonCode_; 
}

- (void)setReasonCode:(NSString *)str {
  [reasonCode_ autorelease];
  reasonCode_ = [str copy];
}

- (NSString *)helpURLString {
  return helpURLString_; 
}

- (void)setHelpURLString:(NSString *)str {
  [helpURLString_ autorelease];
  helpURLString_ = [str copy];
}

- (NSString *)errorDescription {
  return errorDescription_; 
}

- (void)setErrorDescription:(NSString *)str {
  [errorDescription_ autorelease];
  errorDescription_ = [str copy];
}

@end

