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
  IBOutlet NSButton *mDeletedCheckbox;
  IBOutlet NSComboBox *mGroupField; // group title, though user may enter group ID

  id mTarget; // WEAK 
  SEL mDoneSEL;
  GDataObject *mObject;
  GDataFeedContactGroup *mGroupFeed;
  BOOL mWasSaveClicked;
  
  NSDictionary *relsDict_;
}

// target must be a NSWindowController or at least respond to -window
//
// object should be of the class for the kind of data we're editing
// (phone, email, postal, IM, group, extProp)
- (void)runModalForTarget:(id)target
                 selector:(SEL)doneSelector
                groupFeed:(GDataFeedContactGroup *)groupFeed
                   object:(GDataObject *)object;

- (IBAction)saveButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;

- (BOOL)wasSaveClicked;

// this getter constructs an object based on the data in the edit dialog
- (GDataObject *)object;
@end

@interface GDataExtendedProperty (ContactsSampleAdditions)
// getter that returns the plain value or an XML string for the XML values;
// setter that looks for a leading "<" to decide if the value to set is XML
- (NSString *)unifiedStringValue;
- (void)setUnifiedStringValue:(NSString *)str;
@end
