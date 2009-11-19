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

/*
* A simple, short example of a command line tool to create a "Hello World"
* event on your Google Calendar. 
* 
* This runs under the XCode environment in the GData Examples folder. 
* To run this tool from the command line, you'll need to create a
* Frameworks folder one level up from this program and copy the GData framework
* into it as ../Frameworks/GData.framework
*/

#import "GData/GData.h"

int main(int argc, const char *argv[]) {
  
  if (3 != argc) {
    fprintf(stderr, "usage: %s accountname password\n", argv[0]);
    fprintf(stderr, "\tMakes a 'hello world' event on your Google Calendar\n");
    fprintf(stderr, "\tExample accountname: exampleName@gmail.com\n");
    return -1;
  } 
  
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  
  int returnValue = -1;
    
  NSString *account = [NSString stringWithUTF8String:argv[1]]; // @"my.account@gmail.com"
  NSString *password = [NSString stringWithUTF8String:argv[2]]; // @"myPassword"
  
  GDataServiceGoogleCalendar *service = 
    [[[GDataServiceGoogleCalendar alloc] init] autorelease];
  
  [service setUserCredentialsWithUsername:account 
                                 password:password];
  
  // Fetch the list of calendars
  GDataServiceTicket *ticket = [service fetchCalendarFeedForUsername:account
                                                            delegate:nil
                                                   didFinishSelector:nil];
  
  // Spin the event loop until the fetch finshes.
  //
  // waitForTicket: waits synchronously for fetch to complete. It is strongly
  // discouraged in a real program, because it may discard important events.
  // See the comment in GDataServiceBase.h for it.
  
  GDataFeedCalendar *calendarFeed = nil;
  NSError *error = nil;
  
  if ([service waitForTicket:ticket 
                     timeout:360. 
               fetchedObject:&calendarFeed 
                       error:&error]) {
    
    NSArray *calendars = [calendarFeed entries];
    GDataEntryCalendar *calendar = [calendars objectAtIndex:0];
    
    // Construct the event we'll post.
    GDataEntryCalendarEvent *event = [GDataEntryCalendarEvent calendarEvent];
    [event setTitleWithString:@"Hello World"];
    
    NSTimeZone *currentTimeZone = [NSTimeZone defaultTimeZone];
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    GDataDateTime *nowDateTime = [GDataDateTime dateTimeWithDate:now 
                                                        timeZone:currentTimeZone];
    
    NSDate *oneHourFromNow = [NSDate dateWithTimeIntervalSinceNow:60*60];
    GDataDateTime *endDateTime = [GDataDateTime dateTimeWithDate:oneHourFromNow
                                                        timeZone:currentTimeZone];
    GDataWhen *when = [GDataWhen whenWithStartTime:nowDateTime 
                                           endTime:endDateTime];
    [event addTime:when];
    
    // Post the event.
    NSURL *altLinkURL = [[calendar alternateLink] URL];
    
    ticket = [service fetchEntryByInsertingEntry:event
                                      forFeedURL:altLinkURL
                                        delegate:nil
                               didFinishSelector:nil];
    
    GDataEntryCalendarEvent *resultingEvent = nil;
    
    if ([service waitForTicket:ticket 
                       timeout:360. 
                 fetchedObject:&resultingEvent
                         error:&error]) {
      
      if (resultingEvent) {
        returnValue = 0;  // Good in Unix terms. SUCCESS_VAL
      }
    }
  }
  
  if (error) fprintf(stderr, "%s", [[error description] UTF8String]);
  
  [pool release];
  return returnValue;
}
