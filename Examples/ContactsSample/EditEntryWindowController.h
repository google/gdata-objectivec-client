/* Copyright (c) 2008 Google Inc.
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
//  EditEntryWindowController.h
//

#import <Cocoa/Cocoa.h>

#import "GData/GData.h"

@interface EditEntryWindowController : NSWindowController {
  IBOutlet NSTextField *mClassNameField;
  IBOutlet NSTextField *mValueField;
  IBOutlet NSTextField *mLabelField;
  IBOutlet NSComboBox *mRelField;
  IBOutlet NSTextField *mOrgTitleField;
  IBOutlet NSComboBox *mProtocolField;
  IBOutlet NSButton *mPrimaryCheckbox;

  id mTarget; // WEAK 
  SEL mDoneSEL;
  GDataObject *mObject;
  BOOL mWasSaveClicked;
  
  NSDictionary *relsDict_;
}

// target must be a NSWindowController or at least respond to -window
//
// object should be of the class for the kind of data we're editing
// (phone, email, postal, IM)
- (void)runModalForTarget:(id)target
                 selector:(SEL)doneSelector
                   object:(GDataObject *)object;

- (IBAction)saveButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;

- (BOOL)wasSaveClicked;

// this getter constructs an object based on the data in the edit dialog
- (GDataObject *)object;
@end
