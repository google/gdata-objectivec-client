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
//  EditEventWindowController.h
//

#import <Cocoa/Cocoa.h>

#import "GData/GData.h"

@interface EditEventWindowController : NSWindowController {
  IBOutlet NSTextField *mTitleField;
  IBOutlet NSTextField *mDescriptionField;
  IBOutlet NSTextField *mReminderMinutesField;
  IBOutlet NSDatePicker *mStartDatePicker;
  IBOutlet NSDatePicker *mEndDatePicker;
  
  id mTarget; // WEAK 
  SEL mDoneSEL;
  GDataEntryCalendarEvent *mEvent;
  BOOL mWasSaveClicked;
}

// target must be a NSWindowController or at least respond to -window
- (void)runModalForTarget:(id)target
                 selector:(SEL)doneSelector
                    event:(GDataEntryCalendarEvent *)event;

- (IBAction)saveButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;

- (BOOL)wasSaveClicked;
- (GDataEntryCalendarEvent *)event;
@end
