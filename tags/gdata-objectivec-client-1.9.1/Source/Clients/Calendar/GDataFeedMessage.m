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
//  GDataFeedMessage.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE

#import "GDataFeedMessage.h"
#import "GDataEntryMessage.h"

@implementation GDataFeedMessage

+ (GDataFeedMessage *)messageFeedWithXMLData:(NSData *)data {
  return [[[self alloc] initWithData:data] autorelease];
}

+ (GDataFeedMessage *)messageFeed {
  GDataFeedMessage *feed = [[[self alloc] init] autorelease];
  [feed setNamespaces:[GDataEntryBase baseGDataNamespaces]];
  return feed;
}

+ (NSString *)standardFeedKind {
  return kGDataMessage;
}

+ (void)load {
  [self registerFeedClass];
}

- (Class)classForEntries {
  return [GDataEntryMessage class];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CALENDAR_SERVICE
