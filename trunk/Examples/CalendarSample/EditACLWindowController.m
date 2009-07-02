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
//  EditACLWindowController.m
//

#import "EditACLWindowController.h"


@implementation EditACLWindowController

- (id)init {
  
  return [self initWithWindowNibName:@"EditACLWindow"];
}

- (void)awakeFromNib {
  if (mEntry) {
    
    // copy data from the ACL entry to our dialog's controls
    NSString *scopeType = [[mEntry scope] type];
    NSString *scopeValue = [[mEntry scope] value];
    NSString *roleValue = [[mEntry role] value];
    
    if (scopeType) [mScopeTypeField setStringValue:scopeType];
    if (scopeValue) [mScopeValueField setStringValue:scopeValue];
    if (roleValue) [mRoleValueField setStringValue:roleValue];
    
    // add standard calendar roles to the combo box's menu
    NSArray *items = [NSArray arrayWithObjects:
      kGDataRoleCalendarNone, kGDataRoleCalendarRead, 
      kGDataRoleCalendarFreeBusy, kGDataRoleCalendarRespond, 
      kGDataRoleCalendarOverride, kGDataRoleCalendarContributor, 
      kGDataRoleCalendarEditor, kGDataRoleCalendarOwner, 
      kGDataRoleCalendarRoot, nil];
      
    [mRoleValueField addItemsWithObjectValues:items];
  }
}

- (void)dealloc {
  [mEntry release];
  [super dealloc]; 
}

#pragma mark -

- (void)runModalForTarget:(id)target
                 selector:(SEL)doneSelector
                 ACLEntry:(GDataEntryACL *)entry {
  mTarget = target;
  mDoneSEL = doneSelector;
  mEntry = [entry retain];

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

- (GDataEntryACL *)ACLEntry {
  
  // copy from our dialog's controls into a copy of the original event
  
  NSString *scopeType = [mScopeTypeField stringValue];
  NSString *scopeValue = [mScopeValueField stringValue];
  NSString *roleValue = [mRoleValueField stringValue];
  
  GDataACLScope *scope = [GDataACLScope scopeWithType:scopeType
                                                value:scopeValue];
  GDataACLRole *role = [GDataACLRole roleWithValue:roleValue];
  
  GDataEntryACL *newEntry;
  if (mEntry) {
    // copy the original entry
    newEntry = [[mEntry copy] autorelease];  
    [newEntry setScope:scope];
    [newEntry setRole:role];
  } else {
    // make a new entry
    newEntry = [GDataEntryACL ACLEntryWithScope:scope
                                           role:role];
  }
  
  return newEntry; 
}

- (BOOL)wasSaveClicked {
  return mWasSaveClicked; 
}

@end
