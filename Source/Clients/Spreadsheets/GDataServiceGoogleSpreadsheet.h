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
//  GDataServiceGoogleSpreadsheet.h
//

#import <Cocoa/Cocoa.h>

#import "GDataServiceGoogle.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATASERVICEGOOGLESPREADSHEET_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* kGDataGoogleSpreadsheetsPrivateFullFeed _INITIALIZE_AS(@"http://spreadsheets.google.com/feeds/spreadsheets/private/full");

@class GDataEntrySpreadsheet;
@class GDataQuerySpreadsheet;

// These routines are all simple wrappers around GDataServiceGoogle methods.

// finishedSelector has signature like:
//   serviceTicket:(GDataServiceTicket *)ticket finishedWithObject:(GDataObject *)object;
// failedSelector has signature like:
//   serviceTicket:(GDataServiceTicket *)ticket failedWithError:(NSError *)error

@interface GDataServiceGoogleSpreadsheet : GDataServiceGoogle 

// finished callback (see above) is passed an appropriate spreadsheet feed
- (GDataServiceTicket *)fetchSpreadsheetFeedWithURL:(NSURL *)feedURL
                                           delegate:(id)delegate
                                  didFinishSelector:(SEL)finishedSelector
                                    didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the inserted entry
- (GDataServiceTicket *)fetchSpreadsheetEntryByInsertingEntry:(GDataEntryBase *)entryToInsert
                                                   forFeedURL:(NSURL *)spreadsheetFeedURL
                                                     delegate:(id)delegate
                                            didFinishSelector:(SEL)finishedSelector
                                              didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the updated entry
- (GDataServiceTicket *)fetchSpreadsheetEntryByUpdatingEntry:(GDataEntryBase *)entryToUpdate
                                                 forEntryURL:(NSURL *)spreadsheetEntryEditURL
                                                    delegate:(id)delegate
                                           didFinishSelector:(SEL)finishedSelector
                                             didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed the appropriate spreadsheet feed
- (GDataServiceTicket *)fetchSpreadsheetQuery:(GDataQuerySpreadsheet *)query
                                     delegate:(id)delegate
                            didFinishSelector:(SEL)finishedSelector
                              didFailSelector:(SEL)failedSelector;

// finished callback (see above) is passed a nil object
- (GDataServiceTicket *)deleteSpreadsheetResourceURL:(NSURL *)resourceEditURL
                                            delegate:(id)delegate
                                   didFinishSelector:(SEL)finishedSelector
                                     didFailSelector:(SEL)failedSelector;
@end
