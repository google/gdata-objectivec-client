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
//  EditEventWindowController.m
//

#import "EditEventWindowController.h"


@implementation EditEventWindowController

- (id)init {
  
  return [self initWithWindowNibName:@"EditEventWindow"];
}

- (void)awakeFromNib {
  if (mEvent) {
    
    // copy data from the event to our dialog's controls
    NSString *title = [[mEvent title] stringValue];
    NSString *desc = [[mEvent content] stringValue];
    
    GDataDateTime *startTime = nil;
    GDataDateTime *endTime = nil;
    
    NSArray *times = [mEvent times];
    GDataWhen *when = nil;
    if ([times count] > 0) {
      when = [times objectAtIndex:0];
      startTime = [when startTime];
      endTime = [when endTime];
    }
    
    NSString *reminderMinutesStr = nil;
    NSArray *reminders = [when reminders];

    if ([reminders count] > 0) {
      GDataReminder *reminder = [reminders objectAtIndex:0];
      reminderMinutesStr = [reminder minutes]; // note: reminders may be stored other ways too
    }
    
    if (title) [mTitleField setStringValue:title];
    if (desc) [mDescriptionField setStringValue:desc];
    
    if (startTime) {
      [mStartDatePicker setDateValue:[startTime date]];
      [mStartDatePicker setTimeZone:[startTime timeZone]];
    }
    if (endTime) {
      [mEndDatePicker setDateValue:[endTime date]];
      [mEndDatePicker setTimeZone:[endTime timeZone]];
    }
    if (reminderMinutesStr) [mReminderMinutesField setStringValue:reminderMinutesStr];
  }
}

- (void)dealloc {
  [mEvent release];
  [super dealloc]; 
}

#pragma mark -

- (void)runModalForTarget:(id)target
                 selector:(SEL)doneSelector
                    event:(GDataEntryCalendarEvent *)event
{
  
  mTarget = target;
  mDoneSEL = doneSelector;
  mEvent = [event retain];
  
  [NSApp beginSheet:[self window]
     modalForWindow:[mTarget window]
      modalDelegate:self
     didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
        contextInfo:nil];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode  contextInfo:(void  *)contextInfo {
  
}

- (void)closeDialog {
  // call the target to say we're done
  [mTarget performSelector:mDoneSEL 
                withObject:[[self retain] autorelease]];
  
  [[self window] orderOut:self];
  [NSApp endSheet:[self window]];
}

- (IBAction)saveButtonClicked:(id)sender {
  mWasSaveClicked = YES;
  [self closeDialog];
}

- (IBAction)cancelButtonClicked:(id)sender {
  [self closeDialog];
}

- (GDataEntryCalendarEvent *)event {
  
  // copy from our dialog's controls into a copy of the original event
  NSString *title = [mTitleField stringValue];
  NSString *desc = [mDescriptionField stringValue];
  NSString *reminderMin = [mReminderMinutesField stringValue];
  
  GDataEntryCalendarEvent *newEvent;
  if (mEvent) {
    newEvent = [[mEvent copy] autorelease];
  } else {
    newEvent = [GDataEntryCalendarEvent calendarEvent];
  }
  
  [newEvent setTitleWithString:title];
  [newEvent setContentWithString:desc];
  
  // times
  GDataDateTime *startDateTime = [GDataDateTime dateTimeWithDate:[mStartDatePicker dateValue]
                                                        timeZone:[mStartDatePicker timeZone]];
  GDataDateTime *endDateTime = [GDataDateTime dateTimeWithDate:[mEndDatePicker dateValue]
                                                      timeZone:[mEndDatePicker timeZone]];
  GDataWhen *when = [GDataWhen whenWithStartTime:startDateTime
                                         endTime:endDateTime];

  // reminders.  Reminders are inside the GDWhen (except for recurring events,
  // where they're inside the event itself)
  NSMutableArray *reminders = [NSMutableArray array];
  if ([reminderMin length]) {
    GDataReminder *reminder = [GDataReminder reminder];
    [reminder setMinutes:reminderMin];
    [reminders addObject:reminder];
  }
  [when setReminders:reminders];

  [newEvent setTimes:[NSArray arrayWithObject:when]];
  
  
  return newEvent; 
}

- (BOOL)wasSaveClicked {
  return mWasSaveClicked; 
}

@end
