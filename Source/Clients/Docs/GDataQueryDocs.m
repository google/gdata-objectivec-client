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

@implementation GDataQueryDocs

+ (GDataQueryDocs *)documentQueryWithFeedURL:(NSURL *)feedURL {
  return [[[self alloc] initWithFeedURL:feedURL] autorelease];   
}

- (NSString *)titleQuery {
  NSString *str = [[self customParameters] objectForKey:kTitleParamName];
  return str;  
}

- (void)setTitleQuery:(NSString *)str {
  [self addCustomParameterWithName:kTitleParamName value:str];
}

- (BOOL)isTitleQueryExact {
  NSString *val = [[self customParameters] objectForKey:kExactTitleParamName];
  return (val != nil) && 
    ([val caseInsensitiveCompare:@"true"] == NSOrderedSame);
}

- (void)setIsTitleQueryExact:(BOOL)flag {
  NSString *value = (flag ? @"true" : nil);
  [self addCustomParameterWithName:kExactTitleParamName
                             value:value]; // nil value removes the parameter  
}

@end
