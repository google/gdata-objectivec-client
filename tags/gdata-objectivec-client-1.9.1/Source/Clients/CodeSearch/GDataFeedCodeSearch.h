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
//  GDataFeedCodeSearch.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CODESEARCH_SERVICE

// Since Code Search requires no authentication and has no custom query
// parameters, it can be used with the base class service and query
// objects, like this:
//
//  NSURL *feedURL = [NSURL URLWithString:kGDataCodeSearchFeed];
//  GDataQuery *query = [GDataQuery queryWithFeedURL:feedURL];
//
//  [query setFullTextQueryString:@"package:perl Frodo"];
//
//  GDataServiceBase *service = [[GDataServiceGoogle alloc] init];
//  GDataServiceTicketBase *ticket;
//  ticket = [service fetchQuery:query
//                     feedClass:[GDataFeedCodeSearch class]
//                      delegate:self
//             didFinishSelector:@selector(ticket:finishedWithFeed:)
//               didFailSelector:@selector(ticket:failedWithError:)];


#import "GDataFeedBase.h"
#import "GDataEntryCodeSearch.h"

@interface GDataFeedCodeSearch : GDataFeedBase {
}

+ (GDataFeedCodeSearch *)codeSearchFeed;

+ (GDataFeedCodeSearch *)codeSearchFeedWithXMLData:(NSData *)data;

- (Class)classForEntries;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_CODESEARCH_SERVICE
