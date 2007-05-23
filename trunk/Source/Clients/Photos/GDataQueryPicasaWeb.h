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
//  GDataQueryPicasaWeb.h
//

#import <Cocoa/Cocoa.h>
#import "GDataQuery.h"

@interface GDataQueryPicasaWeb : GDataQuery 

+ (GDataQueryPicasaWeb *)picasaWebQueryWithFeedURL:(NSURL *)feedURL;

+ (GDataQueryPicasaWeb *)picasaWebQueryForUserID:(NSString *)userID
                                         albumID:(NSString *)albumIDorNil
                                       albumName:(NSString *)albumNameOrNil
                                         photoID:(NSString *)photoIDorNil;

- (void)setKind:(NSString *)str;
- (NSString *)kind;

- (void)setAccess:(NSString *)str;
- (NSString *)access;

- (void)setThumbsize:(int)val;
- (int)thumbsize;
@end

