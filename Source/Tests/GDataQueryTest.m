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
//  GDataQueryTest.m
//

#import "GData.h"
#import "GDataQueryTest.h"

#define typeof __typeof__ // fixes http://www.brethorsting.com/blog/2006/02/stupid_issue_with_ocunit.html

@implementation GDataQueryTest

- (void)testGDataCalendarQuery {
  
  NSURL* feedURL = [NSURL URLWithString:@"http://www.google.com/calendar/feeds/userID/private/basic"];
  
  GDataDateTime* dateTime1 = [GDataDateTime dateTimeWithRFC3339String:@"2006-03-29T07:35:59.000Z"];
  GDataDateTime* dateTime2 = [GDataDateTime dateTimeWithRFC3339String:@"2006-03-30T07:35:59.000Z"];
  GDataDateTime* dateTime3 = [GDataDateTime dateTimeWithRFC3339String:@"2006-04-29T07:35:59.000Z"];
  GDataDateTime* dateTime4 = [GDataDateTime dateTimeWithRFC3339String:@"2007-06-25T13:37:54.146+07:00"];
  
  // test query with feed URL but no params
  GDataQuery* query1 = [GDataQuery queryWithFeedURL:feedURL];
  NSURL* resultURL1 = [query1 URL];
  STAssertEqualObjects(resultURL1, feedURL, @"Unadorned feed URL is not preserved by GDataQuery");

  // test query with params but no categories
  GDataQuery* query2 = [GDataQuery queryWithFeedURL:feedURL];
  [query2 setStartIndex:10];
  [query2 setMaxResults:20];
  [query2 setFullTextQueryString:@"Darcy"];
  [query2 setAuthor:@"Fred Flintstone"];
  [query2 setOrderBy:@"random"];
  [query2 setPublishedMinDateTime:dateTime1];
  [query2 setPublishedMaxDateTime:dateTime2];
  [query2 setUpdatedMinDateTime:dateTime3];
  [query2 setUpdatedMaxDateTime:dateTime4];
  [query2 addCustomParameterWithName:@"Fred" value:@"Barney"];
  [query2 addCustomParameterWithName:@"Wilma" value:@"Betty"];
  
  NSURL* resultURL2 = [query2 URL];
  NSString *expected2 = @"http://www.google.com/calendar/feeds/userID/private/basic"
    "?q=Darcy&author=Fred+Flintstone&orderby=random&updated-min=2006-04-29T07:35:59Z&updated-max=2007-06-25T13:37:54%2B07:00"
    "&published-min=2006-03-29T07:35:59Z&published-max=2006-03-30T07:35:59Z"
    "&start-index=10&max-results=20&Fred=Barney&Wilma=Betty";
  STAssertEqualObjects([resultURL2 absoluteString], expected2, @"Parameter generation error");
  
  GDataCategoryFilter *categoryFilter = [GDataCategoryFilter categoryFilter];
  [categoryFilter addCategory:[GDataCategory categoryWithScheme:@"http://schemas.google.com/g/2005#kind" 
                                                           term:@"http://schemas.google.com/g/2005#event"]];
  [categoryFilter addCategory:[GDataCategory categoryWithScheme:@"MyScheme2" 
                                                           term:@"MyTerm2"]];
  [categoryFilter addExcludeCategory:[GDataCategory categoryWithScheme:nil
                                                                  term:@"MyTerm3"]];

  // test a query with categories but no params
  GDataQuery* query3 = [GDataQuery queryWithFeedURL:feedURL];
  [query3 addCategoryFilter:categoryFilter];
  NSURL* resultURL3 = [query3 URL];
 
  NSString* expected3 = @"http://www.google.com/calendar/feeds/userID/private/basic/"
    "-/%7Bhttp://schemas.google.com/g/2005%23kind%7Dhttp://schemas.google.com/g/2005%23event%7C%7BMyScheme2%7DMyTerm2%7C-MyTerm3";
  STAssertEqualObjects([resultURL3 absoluteString], expected3, @"Category filter generation error");
  
  
  // finally, add the previous category filter and another category filter
  // to the second query's parameters
  GDataCategoryFilter *categoryFilter2 = [GDataCategoryFilter categoryFilter];
  [categoryFilter2 addCategory:[GDataCategory categoryWithScheme:nil term:@"Zonk4"]];

  [query2 addCategoryFilter:categoryFilter];
  [query2 addCategoryFilter:categoryFilter2];
  
  NSURL* resultURL2a = [query2 URL];
  NSString *expected2a = @"http://www.google.com/calendar/feeds/userID/private/basic/"
    "-/%7Bhttp://schemas.google.com/g/2005%23kind%7Dhttp://schemas.google.com/g/2005%23event%7C%7BMyScheme2%7DMyTerm2%7C-MyTerm3/Zonk4"
    "?q=Darcy&author=Fred+Flintstone&orderby=random&updated-min=2006-04-29T07:35:59Z&updated-max=2007-06-25T13:37:54%2B07:00&published-min=2006-03-29T07:35:59Z"
    "&published-max=2006-03-30T07:35:59Z&start-index=10&max-results=20&Fred=Barney&Wilma=Betty";
  
  STAssertEqualObjects([resultURL2a absoluteString], expected2a, @"Category filter generation error");
  //NSLog(@"======+++++> %@", [[resultURL2a absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
  
  //
  // test a calendar query
  //
  GDataQueryCalendar* queryCal = [GDataQueryCalendar calendarQueryWithFeedURL:feedURL];
  [queryCal setStartIndex:10];
  [queryCal setMaxResults:20];
  [queryCal setMinimumStartTime:dateTime1];
  [queryCal setMaximumStartTime:dateTime2];
  
  NSURL* resultURLC1 = [queryCal URL];
  NSString *expectedC1 = @"http://www.google.com/calendar/feeds/userID/private/basic?"
    "start-index=10&max-results=20&start-min=2006-03-29T07:35:59Z&start-max=2006-03-30T07:35:59Z";
  STAssertEqualObjects([resultURLC1 absoluteString], expectedC1, @"Category filter generation error");

}

- (void)testGDataGoogleBaseQuery {
  
  NSURL* feedURL = [NSURL URLWithString:@"http://www.google.com/base/feeds/snippets/"];
  
  GDataQueryGoogleBase* queryGB1 = [GDataQueryGoogleBase googleBaseQueryWithFeedURL:feedURL];
  [queryGB1 setIsAscendingOrder:YES];
  [queryGB1 setOrderBy:@"modification_time"];
  [queryGB1 setMaxValues:7];
  
  NSURL* resultURLGB1 = [queryGB1 URL];
  NSString *expectedGB1 = @"http://www.google.com/base/feeds/snippets/?"
    "orderby=modification_time&max-values=7&sortorder=ascending";
  STAssertEqualObjects([resultURLGB1 absoluteString], expectedGB1, @"Google Base query 1 generation error");
  
  // Try a "bq" base query
  
 GDataQueryGoogleBase* queryGB2 = [GDataQueryGoogleBase googleBaseQueryWithFeedURL:feedURL];
  [queryGB2 setGoogleBaseQuery:@"digital camera"];
  [queryGB2 setMaxResults:1];
  
  NSURL* resultURLGB2 = [queryGB2 URL];
  NSString *expectedGB2 = @"http://www.google.com/base/feeds/snippets/"
    "?max-results=1&bq=digital+camera";
  STAssertEqualObjects([resultURLGB2 absoluteString], expectedGB2, @"Google Base query 2 generation error");
}

- (void)testGDataSpreadsheetsQuery {
  
  NSURL* feedURL = [NSURL URLWithString:kGDataGoogleSpreadsheetsPrivateFullFeed];
  
  // cell feed query tests
  GDataQuerySpreadsheet* query1 = [GDataQuerySpreadsheet spreadsheetQueryWithFeedURL:feedURL];
  [query1 setMinimumRow:3];
  [query1 setMaximumRow:7];
  [query1 setMinimumColumn:2];
  [query1 setMaximumColumn:12];
  [query1 setRange:@"A1:B2"];
  [query1 setShouldReturnEmpty:YES];
  
  NSURL* resultURL1 = [query1 URL];
  NSString *expected1 = @"http://spreadsheets.google.com/feeds/spreadsheets/private/full?"
    "max-row=7&min-col=2&max-col=12&min-row=3&range=A1:B2&return-empty=true";
  STAssertEqualObjects([resultURL1 absoluteString], expected1, 
                       @"Spreadsheet query 1 generation error");

  // list feed query tests
  GDataQuerySpreadsheet* query2 = [GDataQuerySpreadsheet spreadsheetQueryWithFeedURL:feedURL];
  [query2 setSpreadsheetQuery:@"ipm<4 and hours>40"];
  [query2 setOrderBy:@"column:foostuff"];
  [query2 setIsReverseSort:YES];
  
  NSURL* resultURL2 = [query2 URL];
  NSString *expected2 = @"http://spreadsheets.google.com/feeds/spreadsheets/private/full?"
    "orderby=column:foostuff&sq=ipm%3C4+and+hours%3E40&reverse=true";
  STAssertEqualObjects([resultURL2 absoluteString], expected2, 
                       @"Spreadsheet query 2 generation error");
}

- (void)testURLParameterEncoding {
  
  // test all characters between 0x20 and 0x7f
  NSString *fullAsciiParam = @" !\"#$%&'()*+,-./"
    "0123456789:;<=>?@"
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`"
    "abcdefghijklmnopqrstuvwxyz{|}~";
  
  // full URL encoding leaves +, =, and other URL-legal symbols intact
  NSString *fullEncoded = @"%20!%22%23$%25&'()*+,-./"
    "0123456789:;%3C=%3E?@"
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ%5B%5C%5D%5E_%60"
    "abcdefghijklmnopqrstuvwxyz%7B%7C%7D~%7F";
  
  // parameter encoding encodes these too: "/+?&='"
  // and encodes a space as a plus
  NSString *paramEncoded = @"+!%22%23$%25%26%27()*%2B,-.%2F"
    "0123456789:;%3C%3D%3E%3F@"
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ%5B%5C%5D%5E_%60"
    "abcdefghijklmnopqrstuvwxyz%7B%7C%7D~%7F";

  NSString *resultFull, *resultParam;
  
  resultFull = [GDataQuery stringByURLEncodingString:fullAsciiParam];
  STAssertEqualObjects(resultFull, fullEncoded, @"URL full encoding error");
  
  resultParam = [GDataQuery stringByURLEncodingStringParameter:fullAsciiParam];
  STAssertEqualObjects(resultParam, paramEncoded, @"URL param encoding error");
}

@end
