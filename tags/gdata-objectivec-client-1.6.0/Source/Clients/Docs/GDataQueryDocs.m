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
//  GDataQueryDocument.m
//

#import "GDataQueryDocs.h"

static NSString *const kTitleParamName  = @"title";
static NSString *const kExactTitleParamName  = @"title-exact";
static NSString *const kParentFolderParamName  = @"folder";
static NSString *const kShowFoldersParamName  = @"showfolders";

@implementation GDataQueryDocs

+ (GDataQueryDocs *)documentQueryWithFeedURL:(NSURL *)feedURL {
  return [[[self alloc] initWithFeedURL:feedURL] autorelease];   
}

- (NSString *)titleQuery {
  NSString *str = [self valueForParameterWithName:kTitleParamName];
  return str;  
}

- (void)setTitleQuery:(NSString *)str {
  [self addCustomParameterWithName:kTitleParamName value:str];
}

- (BOOL)isTitleQueryExact {
  return [self boolValueForParameterWithName:kExactTitleParamName
                                defaultValue:NO];
}

- (void)setIsTitleQueryExact:(BOOL)flag {
  [self addCustomParameterWithName:kExactTitleParamName
                         boolValue:flag
                      defaultValue:NO];
}

- (NSString *)parentFolderName {
  NSString *str = [self valueForParameterWithName:kParentFolderParamName];
  return str;
}

- (void)setParentFolderName:(NSString *)str {
  [self addCustomParameterWithName:kParentFolderParamName value:str];
}

- (BOOL)shouldShowFolders {
  return [self boolValueForParameterWithName:kShowFoldersParamName
                                defaultValue:NO];
}

- (void)setShouldShowFolders:(BOOL)flag {
  [self addCustomParameterWithName:kShowFoldersParamName
                         boolValue:flag
                      defaultValue:NO];
}

@end
