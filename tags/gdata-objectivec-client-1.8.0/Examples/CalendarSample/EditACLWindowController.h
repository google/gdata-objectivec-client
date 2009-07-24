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
//  EditACLWindowController.h
//

#import <Cocoa/Cocoa.h>

#import "GData/GData.h"

@interface EditACLWindowController : NSWindowController {
  IBOutlet NSComboBox *mScopeTypeField;
  IBOutlet NSTextField *mScopeValueField;
  IBOutlet NSComboBox *mRoleValueField;
  IBOutlet NSButton *mOKButton;
  IBOutlet NSButton *mCancelButton;
  
  id mTarget; // WEAK 
  SEL mDoneSEL;
  BOOL mWasSaveClicked;
  
  GDataEntryACL *mEntry;
}

// target must be a NSWindowController or at least respond to -window
- (void)runModalForTarget:(id)target
                 selector:(SEL)doneSelector
                 ACLEntry:(GDataEntryACL *)entry;

- (IBAction)saveButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;

- (BOOL)wasSaveClicked;

- (GDataEntryACL *)ACLEntry;
@end
