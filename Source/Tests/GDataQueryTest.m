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

#import <SenTestingKit/SenTestingKit.h>

#import "GDataQuery.h"
#import "GData.h"

#define typeof __typeof__ // fixes http://www.brethorsting.com/blog/2006/02/stupid-issue-with-ocunit.html

@interface GDataQueryTest : SenTestCase
@end

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
  [query2 setAuthor:@"Fred Flintstone"];
  [query2 setFullTextQueryString:@"Darcy Dingo"];
  [query2 setIsAscendingOrder:YES];
  [query2 setIsStrict:YES];
  [query2 setLanguage:@"en"];
  [query2 setMaxResults:20];
  [query2 setOrderBy:@"random"];
  [query2 setProtocolVersion:@"2.0"];
  [query2 setShouldPrettyPrint:YES];
  [query2 setShouldShowDeleted:YES];
  [query2 setShouldRequireAllDeleted:YES];
  [query2 setShouldShowOnlyDeleted:YES];
  [query2 setStartIndex:10];
  [query2 setPublishedMinDateTime:dateTime1];
  [query2 setPublishedMaxDateTime:dateTime2];
  [query2 setUpdatedMinDateTime:dateTime3];
  [query2 setUpdatedMaxDateTime:dateTime4];
  [query2 addCustomParameterWithName:@"Fred" value:@"Barney"];
  [query2 addCustomParameterWithName:@"Wilma" value:@"Betty"];
  
  NSURL* resultURL2 = [query2 URL];
  
  NSString *expected2 = @"http://www.google.com/calendar/feeds/userID/private/basic?"
    "author=Fred+Flintstone&Fred=Barney&hl=en&max-results=20&onlydeleted=true"
    "&orderby=random&prettyprint=true&published-max=2006-03-30T07%3A35%3A59Z"
    "&published-min=2006-03-29T07%3A35%3A59Z&q=Darcy+Dingo"
    "&requirealldeleted=true&showdeleted=true"
    "&sortorder=ascending&start-index=10&strict=true"
    "&updated-max=2007-06-25T13%3A37%3A54%2B07%3A00"
    "&updated-min=2006-04-29T07%3A35%3A59Z&v=2.0&Wilma=Betty";
  
  STAssertEqualObjects([resultURL2 absoluteString], expected2, @"Parameter generation error");
  
  GDataCategoryFilter *categoryFilter = [GDataCategoryFilter categoryFilter];
  [categoryFilter addCategory:[GDataCategory categoryWithScheme:@"http://schemas.google.com/g/2005#kind" 
                                                           term:@"http://schemas.google.com/g/2005#event"]];
  [categoryFilter addCategoryWithScheme:@"MyScheme2" term:@"MyTerm2"];
  [categoryFilter addExcludeCategoryWithScheme:nil term:@"MyTerm3"];

  // test a query with categories but no params
  GDataQuery* query3 = [GDataQuery queryWithFeedURL:feedURL];
  [query3 addCategoryFilter:categoryFilter];
  NSURL* resultURL3 = [query3 URL];

  NSString* expected3 = @"http://www.google.com/calendar/feeds/userID/private/"
    "basic/-/%7Bhttp%3A%2F%2Fschemas.google.com%2Fg%2F2005%23kind%7Dhttp"
    "%3A%2F%2Fschemas.google.com%2Fg%2F2005%23event%7C%7BMyScheme2%7D"
    "MyTerm2%7C-MyTerm3";
  STAssertEqualObjects([resultURL3 absoluteString], expected3, @"Category filter generation error");


  // finally, add the previous category filter and another category filter
  // to the second query's parameters
  [query2 addCategoryFilter:categoryFilter];
  [query2 addCategoryFilterWithScheme:nil term:@"Zonk4"];
  
  NSURL* resultURL2a = [query2 URL];

  NSString *expected2a = @"http://www.google.com/calendar/feeds/userID/private/"
    "basic/-/%7Bhttp%3A%2F%2Fschemas.google.com%2Fg%2F2005%23kind%7Dhttp%3A%2F%2F"
    "schemas.google.com%2Fg%2F2005%23event%7C%7BMyScheme2%7DMyTerm2%7C-MyTerm3/"
    "Zonk4?author=Fred+Flintstone&Fred=Barney&hl=en&max-results=20&onlydeleted=true&"
    "orderby=random&prettyprint=true&published-max=2006-03-30T07%3A35%3A59Z&"
    "published-min=2006-03-29T07%3A35%3A59Z&q=Darcy+Dingo&"
    "requirealldeleted=true&showdeleted=true&"
    "sortorder=ascending&start-index=10&strict=true&"
    "updated-max=2007-06-25T13%3A37%3A54%2B07%3A00"
    "&updated-min=2006-04-29T07%3A35%3A59Z&v=2.0&Wilma=Betty";

  STAssertEqualObjects([resultURL2a absoluteString], expected2a, @"Category filter generation error");
  
  //
  // test a calendar query
  //
  GDataQueryCalendar* queryCal = [GDataQueryCalendar calendarQueryWithFeedURL:feedURL];
  [queryCal setStartIndex:10];
  [queryCal setMaxResults:20];
  [queryCal setMinimumStartTime:dateTime1];
  [queryCal setMaximumStartTime:dateTime2];
  [queryCal setShouldShowInlineComments:YES];
  [queryCal setShouldShowHiddenEvents:NO];
  
  NSURL* resultURLC1 = [queryCal URL];
  NSString *expectedC1 = @"http://www.google.com/calendar/feeds/userID/private/basic?"
    "max-results=20&start-index=10&start-max=2006-03-30T07%3A35%3A59Z&start-min=2006-03-29T07%3A35%3A59Z";

  STAssertEqualObjects([resultURLC1 absoluteString], expectedC1, @"Query error");
  
  GDataQueryCalendar* queryCal2 = [GDataQueryCalendar calendarQueryWithFeedURL:feedURL];
  [queryCal2 setRecurrenceExpansionStartTime:dateTime1];
  [queryCal2 setRecurrenceExpansionEndTime:dateTime1];
  [queryCal2 setShouldQueryAllFutureEvents:YES];
  [queryCal2 setShouldExpandRecurrentEvents:YES];
  [queryCal2 setCurrentTimeZoneName:@"America/Los Angeles"];
  [queryCal2 setShouldShowInlineComments:NO];
  [queryCal2 setShouldShowHiddenEvents:YES];
  [queryCal2 setShouldFormatErrorsAsXML:YES];
  [queryCal2 setMaximumAttendees:12];
  [queryCal2 setFieldSelection:@"entry(@gd:*,link,title)"];

  NSURL* resultURLC2 = [queryCal2 URL];
  NSString *expectedC2 = @"http://www.google.com/calendar/feeds/userID/private/basic?"
    "ctz=America%2FLos_Angeles&err=xml&"
    "fields=entry%28%40gd%3A%2A%2Clink%2Ctitle%29&futureevents=true&"
    "max-attendees=12&"
    "recurrence-expansion-end=2006-03-29T07%3A35%3A59Z&"
    "recurrence-expansion-start=2006-03-29T07%3A35%3A59Z&"
    "showhidden=true&showinlinecomments=false&singleevents=true";
  STAssertEqualObjects([resultURLC2 absoluteString], expectedC2, @"Query error");
  
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
  NSString *expected1 = @"https://spreadsheets.google.com/feeds/spreadsheets/private/full?"
    "max-col=12&max-row=7&min-col=2&min-row=3&range=A1%3AB2&return-empty=true";
  STAssertEqualObjects([resultURL1 absoluteString], expected1, 
                       @"Spreadsheet query 1 generation error");

  // list feed query tests
  GDataQuerySpreadsheet* query2 = [GDataQuerySpreadsheet spreadsheetQueryWithFeedURL:feedURL];
  [query2 setSpreadsheetQuery:@"ipm<4 and hours>40"];
  [query2 setOrderBy:@"column:foostuff"];
  [query2 setIsReverseSort:YES];
  
  NSURL* resultURL2 = [query2 URL];
  NSString *expected2 = @"https://spreadsheets.google.com/feeds/spreadsheets/private/full?"
    "orderby=column%3Afoostuff&reverse=true&sq=ipm%3C4+and+hours%3E40";
  STAssertEqualObjects([resultURL2 absoluteString], expected2, 
                       @"Spreadsheet query 2 generation error");
}

- (void)testGooglePhotosQuery {
  
  GDataQueryGooglePhotos *pwaQuery1;
  pwaQuery1 = [GDataQueryGooglePhotos photoQueryForUserID:@"fredflintstone"
                                                  albumID:@"12345"
                                                albumName:nil
                                                  photoID:@"987654321"];
  [pwaQuery1 setKind:kGDataGooglePhotosKindPhoto];
  [pwaQuery1 setAccess:kGDataGooglePhotosAccessPrivate];
  [pwaQuery1 setThumbsize:80];
  [pwaQuery1 setImageSize:32];
  [pwaQuery1 setTag:@"dog"];
  
  NSURL* resultURL1 = [pwaQuery1 URL];
  NSString *expected1 = @"https://photos.googleapis.com/data/feed/api/"
    "user/fredflintstone/albumid/12345/photoid/987654321?"
    "access=private&imgmax=32&kind=photo&tag=dog&thumbsize=80";
  STAssertEqualObjects([resultURL1 absoluteString], expected1, 
                       @"PWA query 1 generation error");
  STAssertEquals([pwaQuery1 imageSize], (NSInteger) 32, @"image size error");
  
  GDataQueryGooglePhotos *pwaQuery2; 
  pwaQuery2 = [GDataQueryGooglePhotos photoQueryForUserID:@"fredflintstone"
                                                  albumID:nil
                                                albumName:@"froggy photos"
                                                  photoID:nil];  
  [pwaQuery2 setImageSize:kGDataGooglePhotosImageSizeDownloadable];
  
  NSURL* resultURL2 = [pwaQuery2 URL];
  NSString *expected2 = @"https://photos.googleapis.com/data/feed/api/user/"
    "fredflintstone/album/froggy%20photos?imgmax=d";
  STAssertEqualObjects([resultURL2 absoluteString], expected2, 
                       @"PWA query 2 generation error");
  
  // image size special cases mapping -1 to "d" and back; test that we get back
  // -1
  STAssertEquals([pwaQuery2 imageSize], kGDataGooglePhotosImageSizeDownloadable,
                 @"image size error (2)");
  
  // test the generator for photo contact feed URLs
  NSURL *contactsURL = [GDataServiceGooglePhotos photoContactsFeedURLForUserID:@"fred@example.com"];
  NSString *contactsURLString = [contactsURL absoluteString];
  NSString *expectedContactsURLString = @"https://photos.googleapis.com/data/feed/api/user/fred%40example.com/contacts?kind=user";
  STAssertEqualObjects(contactsURLString, expectedContactsURLString, 
                       @"contacts URL error");

  // test service document request
  GDataQueryGooglePhotos *pwaQuery3;
  pwaQuery3 = [GDataQueryGooglePhotos photoQueryForUserID:@"fredflintstone"
                                                  albumID:nil
                                                albumName:nil
                                                  photoID:nil];
  [pwaQuery3 setResultFormat:kGDataQueryResultServiceDocument];
  NSURL *resultURL3 = [pwaQuery3 URL];
  NSString *expected3 = @"https://photos.googleapis.com/data/feed/api/user/fredflintstone?alt=atom-service";
  STAssertEqualObjects([resultURL3 absoluteString], expected3,
                       @"PWA query 3 generation error");
}

- (void)testMapsQuery {
  NSURL *feedURL = [GDataServiceGoogleMaps mapsFeedURLForUserID:kGDataServiceDefaultUser
                                                     projection:kGDataMapsProjectionFull];
  GDataQueryMaps *mapsQuery1, *mapsQuery2;

  mapsQuery1 = [GDataQueryMaps mapsQueryWithFeedURL:feedURL];
  [mapsQuery1 setPrevID:@"pid"];
  [mapsQuery1 setAttributeQueryString:@"[pool:true][price:budget]"];
  [mapsQuery1 setBoxString:@"1,2,3,4"];
  [mapsQuery1 setLatitude:12.3];
  [mapsQuery1 setLongitude:23.4];
  [mapsQuery1 setRadius:33.3];
  [mapsQuery1 setSortBy:@"distance"];
  NSURL *resultURL1 = [mapsQuery1 URL];
  NSString *expected1 = @"https://maps.google.com/maps/feeds/maps/default/full?"
    "box=1%2C2%2C3%2C4&lat=12.300000&lng=23.400000&"
    "mq=%5Bpool%3Atrue%5D%5Bprice%3Abudget%5D&previd=pid&"
    "radius=33.300000&sortby=distance";
  STAssertEqualObjects([resultURL1 absoluteString], expected1,
                       @"Maps Query 1 generation error");

  mapsQuery2 = [GDataQueryMaps mapsQueryWithFeedURL:feedURL];
  [mapsQuery2 setBoxWithWest:10 south:20 east:30 north:40];
  NSURL *resultURL2 = [mapsQuery2 URL];
  NSString *expected2 = @"https://maps.google.com/maps/feeds/maps/default/full?"
    "box=10.000000%2C20.000000%2C30.000000%2C40.000000";
  STAssertEqualObjects([resultURL2 absoluteString], expected2,
                       @"Maps Query 2 generation error");
}

- (void)testYouTubeQuery {
  
  NSURL *feedURL = [GDataServiceGoogleYouTube youTubeURLForUserID:@"fred"
                                                       userFeedID:kGDataYouTubeUserFeedIDFavorites];
  
  GDataQueryYouTube *ytQuery1;  
  ytQuery1 = [GDataQueryYouTube youTubeQueryWithFeedURL:feedURL];
  
  [ytQuery1 setVideoQuery:@"\"Fred Flintstone\""];
  [ytQuery1 setFormat:@"0,5,6"];
  [ytQuery1 setCaptionTrackFormat:kGDataYouTubeCaptionTrackFormatSubviewer];
  [ytQuery1 setTimePeriod:kGDataYouTubePeriodThisWeek];
  [ytQuery1 setOrderBy:kGDataYouTubeOrderByRelevance];
  [ytQuery1 setRestriction:@"127.0.0.1"];
  [ytQuery1 setLanguageRestriction:@"en"];
  [ytQuery1 setLocation:@"Canada"];
  [ytQuery1 setLocationRadius:@"2km"];
  [ytQuery1 setSafeSearch:kGDataYouTubeSafeSearchStrict];
  [ytQuery1 setHasCaptions:YES];
  [ytQuery1 setShouldInline:YES];
  [ytQuery1 setShouldRequire3D:YES];
  [ytQuery1 setUploader:@"foo"];
  
  NSURL* resultURL1 = [ytQuery1 URL];
  NSString *expected1 = @"https://gdata.youtube.com/feeds/api/users/fred/"
    "favorites?3d=true&caption=true&fmt=sbv&format=0%2C5%2C6&inline=true&location=Canada&"
    "location-radius=2km&lr=en&orderby=relevance&q=%22Fred+Flintstone%22&"
    "restriction=127.0.0.1&safeSearch=strict&time=this_week&uploader=foo";

  STAssertEqualObjects([resultURL1 absoluteString], expected1, 
                       @"YouTube query 1 generation error");
}

- (void)testContactQuery {
  
  GDataQueryContact *query1;
  query1 = [GDataQueryContact contactQueryForUserID:@"user@example.com"];
  
  [query1 setGroupIdentifier:@"http://www.google.com/m8/feeds/groups/user%40example.com/base/6"];
  
  NSURL *resultURL1 = [query1 URL];
  NSString *expected1 = @"https://www.google.com/m8/feeds/contacts/user%40example.com/full?group=http%3A%2F%2Fwww.google.com%2Fm8%2Ffeeds%2Fgroups%2Fuser%2540example.com%2Fbase%2F6";
  STAssertEqualObjects([resultURL1 absoluteString], expected1, 
                       @"Contacts query 1 generation error");
}

- (void)testFinanceQuery {
  
  NSURL *feedURL = [GDataServiceGoogleFinance portfolioFeedURLForUserID:@"user@example.com"];

  GDataQueryFinance *query1;
  query1 = [GDataQueryFinance financeQueryWithFeedURL:feedURL];
  
  [query1 setShouldIncludeReturns:NO];
  [query1 setShouldIncludePositions:NO];
  [query1 setShouldIncludeTransactions:NO];

  NSURL *resultURL1 = [query1 URL];
  NSString *expected1 = @"https://finance.google.com/finance/feeds/user%40example.com/portfolios";
  STAssertEqualObjects([resultURL1 absoluteString], expected1, 
                       @"Finance query 1 generation error");
  
  GDataQueryFinance *query2;
  query2 = [GDataQueryFinance financeQueryWithFeedURL:feedURL];
  
  [query2 setShouldIncludeReturns:YES];
  [query2 setShouldIncludePositions:YES];
  [query2 setShouldIncludeTransactions:YES];
  
  NSURL *resultURL2 = [query2 URL];
  NSString *expected2 = @"https://finance.google.com/finance/feeds/user%40example.com/portfolios?positions=true&returns=true&transactions=true";
  
  STAssertEqualObjects([resultURL2 absoluteString], expected2, 
                       @"Finance query 2 generation error");
}

- (void)testBooksQuery {

  NSURL *feedURL = [NSURL URLWithString:kGDataGoogleBooksVolumeFeed];
  GDataQueryBooks *query1 = [GDataQueryBooks booksQueryWithFeedURL:feedURL];

  [query1 setMinimumViewability:kGDataGoogleBooksMinViewabilityFull];
  [query1 setEBook:@"frogchild"];

  NSURL *resultURL1 = [query1 URL];
  NSString *expected1 = @"http://books.google.com/books/feeds/volumes?ebook=frogchild&min-viewability=full";
  STAssertEqualObjects([resultURL1 absoluteString], expected1,
                       @"Books query 1 generation error");
}

- (void)testDocsQuery {
  NSURL *feedURL = [GDataServiceGoogleDocs docsFeedURL];
  GDataQueryDocs *query1 = [GDataQueryDocs documentQueryWithFeedURL:feedURL];

  [query1 setTitleQuery:@"King Of Oceania"];
  [query1 setIsTitleQueryExact:YES];
  [query1 setParentFolderName:@"Major Folder"];
  [query1 setShouldShowFolders:YES];

  NSURL *resultURL1 = [query1 URL];
  NSString *expected1 = @"https://docs.google.com/feeds/default/private/full?"
    "folder=Major+Folder&showfolders=true&title=King+Of+Oceania&title-exact=true";
  STAssertEqualObjects([resultURL1 absoluteString], expected1,
                       @"Docs query 1 generation error");

  GDataQueryDocs *query2 = [GDataQueryDocs documentQueryWithFeedURL:feedURL];
  [query2 setOwner:@"fred@flintstone.com"];
  [query2 setReader:@"wilma@flintstone.com,pebbles@flintstone.com"];
  [query2 setWriter:@"barney@rubble.com,betty@rubble.com"];
  NSURL *resultURL2 = [query2 URL];
  NSString *expected2 = @"https://docs.google.com/feeds/default/private/full?"
    "owner=fred%40flintstone.com&reader=wilma%40flintstone.com%2C"
    "pebbles%40flintstone.com&writer=barney%40rubble.com%2Cbetty%40rubble.com";
  STAssertEqualObjects([resultURL2 absoluteString], expected2,
                       @"Docs query 2 generation error");

  GDataDateTime* minDate = [GDataDateTime dateTimeWithRFC3339String:@"2006-03-29T07:35:59.000Z"];
  GDataDateTime* maxDate = [GDataDateTime dateTimeWithRFC3339String:@"2006-03-30T07:35:59.000Z"];
  GDataDateTime* minDate2 = [GDataDateTime dateTimeWithRFC3339String:@"2006-04-29T07:35:59.000Z"];
  GDataDateTime* maxDate2 = [GDataDateTime dateTimeWithRFC3339String:@"2006-04-30T07:35:59.000Z"];

  GDataQueryDocs *query3 = [GDataQueryDocs documentQueryWithFeedURL:feedURL];
  [query3 setOpenedMinDateTime:minDate];
  [query3 setOpenedMaxDateTime:maxDate];
  [query3 setEditedMinDateTime:minDate2];
  [query3 setEditedMaxDateTime:maxDate2];
  NSURL *resultURL3 = [query3 URL];
  NSString *expected3 = @"https://docs.google.com/feeds/default/private/full?"
    "edited-max=2006-04-30T07%3A35%3A59Z&edited-min=2006-04-29T07%3A35%3A59Z&"
    "opened-max=2006-03-30T07%3A35%3A59Z&opened-min=2006-03-29T07%3A35%3A59Z";
  STAssertEqualObjects([resultURL3 absoluteString], expected3,
                       @"Docs query 3 generation error");

  GDataQueryDocs *query4 = [GDataQueryDocs documentQueryWithFeedURL:feedURL];
  [query4 setShouldActuallyDelete:YES];
  [query4 setShouldShowRootParentLink:YES];
  [query4 setShouldConvertUpload:NO];
  [query4 setSourceLanguage:@"en"];
  [query4 setTargetLanguage:@"de"];
  [query4 setShouldOCRUpload:YES];
  [query4 setShouldCreateNewRevision:YES];
  NSURL *resultURL4 = [query4 URL];
  NSString *expected4 = @"https://docs.google.com/feeds/default/private/full?"
    "convert=false&delete=true&new-revision=true&ocr=true&showroot=true&"
    "sourceLanguage=en&targetLanguage=de";
  STAssertEqualObjects([resultURL4 absoluteString], expected4,
                       @"Docs query 4 generation error");
}

- (void)testAnalyticsQuery {
  GDataQueryAnalytics *query1;

  query1 = [GDataQueryAnalytics analyticsDataQueryWithTableID:@"9876"
                                              startDateString:@"2001-01-01"
                                                endDateString:@"2001-12-01"];

  [query1 setDimensions:@"ga:browser,ga:country"];
  [query1 setMetrics:@"ga:pageviews"];
  [query1 setFilters:@"ga:country==United States,ga:country==Canada"];
  [query1 setSort:@"ga:browser,ga:pageviews"];
  [query1 setSegment:@"gaid::3"];

  NSURL *resultURL1 = [query1 URL];
  NSString *expected1 = @"https://www.google.com/analytics/feeds/data?"
    "dimensions=ga%3Abrowser%2Cga%3Acountry&end-date=2001-12-01&"
    "filters=ga%3Acountry%3D%3DUnited+States%2Cga%3Acountry%3D%3DCanada&"
    "ids=9876&metrics=ga%3Apageviews&segment=gaid%3A%3A3&"
    "sort=ga%3Abrowser%2Cga%3Apageviews&start-date=2001-01-01";
  STAssertEqualObjects([resultURL1 absoluteString], expected1,
                       @"Analytics query 1 generation error");
}

- (void)testMixedCategoryParamQueries {

  GDataCategory *cat = [GDataCategory categoryWithScheme:nil
                                                    term:@"ferret"];
  GDataCategory *excludeCat = [GDataCategory categoryWithScheme:nil
                                                           term:@"iguana"];

  GDataCategory *catB = [GDataCategory categoryWithScheme:nil
                                                     term:@"monkey"];

  GDataCategoryFilter *categoryFilterA = [GDataCategoryFilter categoryFilter];
  [categoryFilterA addCategory:cat];
  [categoryFilterA addExcludeCategory:excludeCat];

  // test a copy of the category filter
  categoryFilterA = [[categoryFilterA copy] autorelease];

  GDataCategoryFilter *categoryFilterB = [GDataCategoryFilter categoryFilter];
  [categoryFilterB addCategory:catB];

  // four flavors of URL: with and without trailing /, with and without params
  NSURL *url1 = [NSURL URLWithString:@"http://domain.net/?x=y"];
  NSURL *url2 = [NSURL URLWithString:@"http://domain.net?x=y"];
  NSURL *url3 = [NSURL URLWithString:@"http://domain.net/"];
  NSURL *url4 = [NSURL URLWithString:@"http://domain.net"];

  // URL 1
  //
  // changes to the URL made by the query
  //
  // category filters
  GDataQuery *query1 = [GDataQuery queryWithFeedURL:url1];
  [query1 addCategoryFilter:categoryFilterA];
  [query1 addCategoryFilter:categoryFilterB];

  // new parameter
  [query1 setStartIndex:10];
  
  // test a copy of the query
  query1 = [[query1 copy] autorelease];

  NSURL *resultURL1 = [query1 URL];
  NSString *expectedStr1 = @"http://domain.net/-/ferret%7C-iguana/monkey?x=y&start-index=10";
  STAssertEqualObjects([resultURL1 absoluteString], expectedStr1,
                       @"Mixed query generation error");

  // URL 2
  GDataQuery *query2 = [GDataQuery queryWithFeedURL:url2];
  [query2 addCategoryFilter:categoryFilterA];
  [query2 addCategoryFilterWithCategory:catB];
  [query2 setStartIndex:10];

  NSURL *resultURL2 = [query2 URL];
  NSString *expectedStr2 = @"http://domain.net/-/ferret%7C-iguana/monkey?x=y&start-index=10";
  STAssertEqualObjects([resultURL2 absoluteString], expectedStr2,
                       @"Mixed query generation error");

  // URL 3
  GDataQuery *query3 = [GDataQuery queryWithFeedURL:url3];
  [query3 addCategoryFilter:categoryFilterA];
  [query3 addCategoryFilter:categoryFilterB];
  [query3 setStartIndex:10];

  NSURL *resultURL3 = [query3 URL];
  NSString *expectedStr3 = @"http://domain.net/-/ferret%7C-iguana/monkey?start-index=10";
  STAssertEqualObjects([resultURL3 absoluteString], expectedStr3,
                       @"Mixed query generation error");

  // URL 4
  GDataQuery *query4 = [GDataQuery queryWithFeedURL:url4];
  [query4 addCategoryFilter:categoryFilterA];
  [query4 addCategoryFilter:categoryFilterB];
  [query4 setStartIndex:10];

  NSURL *resultURL4 = [query4 URL];
  NSString *expectedStr4 = @"http://domain.net/-/ferret%7C-iguana/monkey?start-index=10";
  STAssertEqualObjects([resultURL4 absoluteString], expectedStr4,
                       @"Mixed query generation error");

  // URL 1 again

  // repeat the first test, but with no category filters added to the query
  GDataQuery *query5 = [GDataQuery queryWithFeedURL:url1];
  [query5 setStartIndex:10];

  NSURL *resultURL5 = [query5 URL];
  NSString *expectedStr5 = @"http://domain.net/?x=y&start-index=10";
  STAssertEqualObjects([resultURL5 absoluteString], expectedStr5,
                       @"Mixed query generation error");

  // repeat the first test, but with no params added to the query
  GDataQuery *query6 = [GDataQuery queryWithFeedURL:url1];
  [query6 addCategoryFilter:categoryFilterA];
  [query6 addCategoryFilter:categoryFilterB];

  NSURL *resultURL6 = [query6 URL];
  NSString *expectedStr6 = @"http://domain.net/-/ferret%7C-iguana/monkey?x=y";
  STAssertEqualObjects([resultURL6 absoluteString], expectedStr6,
                       @"Mixed query generation error");
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
  
  // parameter encoding encodes these too: "!*'();:@&=+$,/?%#[]"
  // and encodes a space as a plus
  NSString *paramEncoded = @"+%21%22%23%24%25%26%27%28%29%2A%2B%2C-.%2F"
    "0123456789%3A%3B%3C%3D%3E%3F%40"
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ%5B%5C%5D%5E_%60"
    "abcdefghijklmnopqrstuvwxyz%7B%7C%7D~%7F";

  NSString *resultFull, *resultParam;
  
  resultFull = [GDataUtilities stringByURLEncodingString:fullAsciiParam];
  STAssertEqualObjects(resultFull, fullEncoded, @"URL full encoding error");
  
  resultParam = [GDataUtilities stringByURLEncodingStringParameter:fullAsciiParam];
  STAssertEqualObjects(resultParam, paramEncoded, @"URL param encoding error");
}

@end
