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
// There are several "thr" threading element extensions:
//   1. The simple <thr:total> value element
//   2. The custom <thr:in-reply-to> element
//   3. The thr:count and thr:updated attribute extensions added to atom:link
//

#import "GDataObject.h"
#import "GDataValueConstruct.h"
#import "GDataLink.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATATHREADINGELEMENTS_DEFINE_GLOBALS
#define _EXTERN
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN GDATA_EXTERN
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataNamespaceAtomThreading _INITIALIZE_AS(@"http://purl.org/syndication/thread/1.0");
_EXTERN NSString* const kGDataNamespaceAtomThreadingPrefix _INITIALIZE_AS(@"thr");


@interface GDataThreadingTotal : GDataValueElementConstruct <GDataExtension>
// thr:total extension element
//
// allocate with [GDataThreadingTotal valueWithInt:x]
@end


// for in-reply-to elements, like
//
// <thr:in-reply-to
//   href="http://blogName.blogspot.com/2007/04/first-post.html"
//   ref="tag:blogger.com,1999:blog-blogID.post-postID"
//   type="text/html"/>

@interface GDataInReplyTo : GDataObject <GDataExtension>

+ (GDataInReplyTo *)inReplyToWithHref:(NSString *)href
                                  ref:(NSString *)ref
                               source:(NSString *)source
                                 type:(NSString *)type;

- (NSString *)href;
- (void)setHref:(NSString *)str;

- (NSString *)ref;
- (void)setRef:(NSString *)str;

- (NSString *)source;
- (void)setSource:(NSString *)str;

- (NSString *)type;
- (void)setType:(NSString *)str;

@end


@interface GDataThreadingLink : NSObject
// This utility class has class methods for adding and accessing threading
// attribute extensions on atom:link elements
+ (void)addThreadingLinkExtensionDeclarationsToObject:(GDataObject *)object;

+ (NSNumber *)threadingCountForLink:(GDataLink *)link;
+ (void)setThreadingCount:(NSNumber *)number
                  forLink:(GDataLink *)link;

+ (GDataDateTime *)threadingUpdatedDateForLink:(GDataLink *)link;
+ (void)setThreadingUpdatedDate:(GDataDateTime *)dateTime
                        forLink:(GDataLink *)link;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BLOGGER_SERVICE
