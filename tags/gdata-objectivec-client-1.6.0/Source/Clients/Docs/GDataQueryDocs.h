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
//  GDataQueryDocument.h
//

// Document-specific query params, per 
//   http://code.google.com/apis/document/reference.html#Parameters

#import "GDataQuery.h"

@interface GDataQueryDocs : GDataQuery 

+ (GDataQueryDocs *)documentQueryWithFeedURL:(NSURL *)feedURL;

- (NSString *)titleQuery;
- (void)setTitleQuery:(NSString *)str;

// non-exact title searches are keyword-based; exact title searches are literal
- (BOOL)isTitleQueryExact;
- (void)setIsTitleQueryExact:(BOOL)flag;

- (NSString *)parentFolderName;
- (void)setParentFolderName:(NSString *)str;

- (BOOL)shouldShowFolders;
- (void)setShouldShowFolders:(BOOL)flag;
@end

