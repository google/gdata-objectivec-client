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

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BLOGGER_SERVICE

//
//  GDataThreadingElements.h
//
// Implements extensions described in http://www.ietf.org/rfc/rfc4685.txt
//

#define GDATATHREADINGELEMENTS_DEFINE_GLOBALS 1
#import "GDataThreadingElements.h"


// thr:total extension element
@implementation GDataThreadingTotal
+ (NSString *)extensionElementURI       { return kGDataNamespaceAtomThreading; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAtomThreadingPrefix; }
+ (NSString *)extensionElementLocalName { return @"total"; }
@end

@implementation GDataInReplyTo
// for in-reply-to elements, like
//
// <thr:in-reply-to
//   href="http://blogName.blogspot.com/2007/04/first-post.html"
//   ref="tag:blogger.com,1999:blog-blogID.post-postID"
//   type="text/html"/>

static NSString* const kHrefAttr = @"href";
static NSString* const kRefAttr = @"ref";
static NSString* const kSourceAttr = @"source";
static NSString* const kTypeAttr = @"type";

+ (NSString *)extensionElementURI       { return kGDataNamespaceAtomThreading; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAtomThreadingPrefix; }
+ (NSString *)extensionElementLocalName { return @"in-reply-to"; }

+ (GDataInReplyTo *)inReplyToWithHref:(NSString *)href
                                  ref:(NSString *)ref
                               source:(NSString *)source
                                 type:(NSString *)type {
  GDataInReplyTo* obj = [self object];
  [obj setHref:href];
  [obj setRef:ref];
  [obj setSource:source];
  [obj setType:type];
  return obj;
}

- (void)addParseDeclarations {

  NSArray *attrs = [NSArray arrayWithObjects:
                    kHrefAttr, kRefAttr, kSourceAttr, kTypeAttr, nil];

  [self addLocalAttributeDeclarations:attrs];
}

#pragma mark -

- (NSString *)href {
  return [self stringValueForAttribute:kHrefAttr];
}

- (void)setHref:(NSString *)str {
  [self setStringValue:str forAttribute:kHrefAttr];
}

- (NSString *)ref {
  return [self stringValueForAttribute:kRefAttr];
}

- (void)setRef:(NSString *)str {
  [self setStringValue:str forAttribute:kRefAttr];
}

- (NSString *)source {
  return [self stringValueForAttribute:kSourceAttr];
}

- (void)setSource:(NSString *)str {
  [self setStringValue:str forAttribute:kSourceAttr];
}

- (NSString *)type {
  return [self stringValueForAttribute:kTypeAttr];
}

- (void)setType:(NSString *)str {
  [self setStringValue:str forAttribute:kTypeAttr];
}

@end


// threading attribute extensions for atom:link
//
// These are abstracted away inside the GDataThreadingLink class so they can
// be reused

// thr:count attribute for link elements
@interface GDataThreadingCount : GDataAttribute <GDataExtension>
@end

@implementation GDataThreadingCount
+ (NSString *)extensionElementURI { return kGDataNamespaceAtomThreading; }
+ (NSString *)extensionElementPrefix { return kGDataNamespaceAtomThreadingPrefix; }
+ (NSString *)extensionElementLocalName { return @"count"; }
@end

// thr:updated attribute for link elements
@interface GDataThreadingUpdated : GDataAttribute <GDataExtension>
@end

@implementation GDataThreadingUpdated
+ (NSString *)extensionElementURI { return kGDataNamespaceAtomThreading; }
+ (NSString *)extensionElementPrefix { return kGDataNamespaceAtomThreadingPrefix; }
+ (NSString *)extensionElementLocalName { return @"updated"; }
@end

@implementation GDataThreadingLink : NSObject

// utility routine to add the threading extension attributes
// for atom:link to a class
+ (void)addThreadingLinkExtensionDeclarationsToObject:(GDataObject *)object {

  // add thr:count and thr:updated attributes to atom:links
  [object addAttributeExtensionDeclarationForParentClass:[GDataLink class]
                                              childClass:[GDataThreadingCount class]];

  [object addAttributeExtensionDeclarationForParentClass:[GDataLink class]
                                              childClass:[GDataThreadingUpdated class]];
}

+ (NSNumber *)threadingCountForLink:(GDataLink *)threadedLink {
  NSString *str = [threadedLink attributeValueForExtensionClass:[GDataThreadingCount class]];
  if ([str length] > 0) {
    NSNumber *number = [NSNumber numberWithInt:[str intValue]];
    return number;
  }
  return nil;
}

+ (void)setThreadingCount:(NSNumber *)number
                  forLink:(GDataLink *)threadedLink {
  [threadedLink setAttributeValue:[number stringValue]
                forExtensionClass:[GDataThreadingCount class]];
}

+ (GDataDateTime *)threadingUpdatedDateForLink:(GDataLink *)threadedLink {
  NSString *str = [threadedLink attributeValueForExtensionClass:[GDataThreadingUpdated class]];
  if ([str length] > 0) {
    GDataDateTime *dateTime = [GDataDateTime dateTimeWithRFC3339String:str];
    return dateTime;
  }
  return nil;
}

+ (void)setThreadingUpdatedDate:(GDataDateTime *)dateTime
                        forLink:(GDataLink *)threadedLink {
  [threadedLink setAttributeValue:[dateTime RFC3339String]
                forExtensionClass:[GDataThreadingUpdated class]];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BLOGGER_SERVICE
