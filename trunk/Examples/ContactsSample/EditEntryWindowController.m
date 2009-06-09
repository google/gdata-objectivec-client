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
//  EditEntryWindowController.m
//

#import "EditEntryWindowController.h"
#import "GData/GDataEntryContact.h"
#import "GData/GDataEntryContactGroup.h"


// map from class of item to display name for item and the item's object
// selectors to use for various editable fields in the nib
//
// for example, the value displayed will be obtained with stringValue
// for postal address objects but with address for IM objects
//
// nil means "disable this edit field"
typedef struct ItemSelectors {
  NSString *className;
  NSString *classDisplayName;
  NSString *valueKey;
  NSString *labelKey;
  NSString *relKey;
  NSString *titleKey;
  NSString *protocolKey;
} ItemSelectors;

static ItemSelectors sAllItemSelectors[] = {
  { @"GDataOrganization",            @"Organization",      @"orgName",            @"label", @"rel", @"orgTitle", nil         },
  { @"GDataEmail",                   @"E-mail",            @"address",            @"label", @"rel", nil,         nil         },
  { @"GDataIM",                      @"Instant Messaging", @"address",            @"label", @"rel", nil,         @"protocol" },
  { @"GDataPhoneNumber",             @"Phone",             @"stringValue",        @"label", @"rel", nil,         nil         },
  { @"GDataStructuredPostalAddress", @"Postal",            @"formattedAddress",   @"label", @"rel", nil,         nil         },
  { @"GDataGroupMembershipInfo",     @"Group",             nil,                   nil,      nil,    nil,         nil         },
  { @"GDataExtendedProperty",        @"Extended Property", @"unifiedStringValue", @"name",  nil,    nil,         nil         },
  { 0, 0, 0, 0, 0, 0 }
};


// given the object we're editing, get the list with the selectors
// and the display name for that class of object
static ItemSelectors *ItemSelectorsForObject(GDataObject *obj) {
  
  NSString *className = NSStringFromClass([obj class]);
  
  for (int idx = 0; sAllItemSelectors[idx].className; idx++) {

    if ([className isEqual:sAllItemSelectors[idx].className]) {
      return &sAllItemSelectors[idx]; 
    }
  }
  return NULL;
}

@interface EditEntryWindowController (PrivateMethods)
- (void)setUIFromObject:(GDataObject *)obj;
@end

@implementation EditEntryWindowController

- (id)init {
  return [self initWithWindowNibName:@"EditEntryWindow"];
}

- (void)awakeFromNib {
  
  if (mObject) {
    // copy data from the object to our dialog's controls
    [self setUIFromObject:mObject];
  }
  
  // make the lists of rel values for the rel combo box, and put in a dictionary
  // according to item class.  This dictionary is used for the combo box
  // data source delegate methods
  //
  // When the combo box menu's data source asks for the menu items,
  // we'll just look up the rel strings from the class of the item
  // being edited.
  
  NSArray *standardRels = [NSArray arrayWithObjects:kGDataContactHome,
    kGDataContactWork, kGDataContactOther, nil];
  
  NSArray *orgRels = [NSArray arrayWithObjects:kGDataContactWork, 
    kGDataContactOther, nil];
  
  NSArray *phoneRels = [NSArray arrayWithObjects:kGDataPhoneNumberHome, 
    kGDataPhoneNumberMobile, kGDataPhoneNumberPager, kGDataPhoneNumberWork,
    kGDataPhoneNumberHomeFax, kGDataPhoneNumberWorkFax, kGDataPhoneNumberOther,
    nil];

  NSArray *noRels = [NSArray array];
  
  relsDict_ = [[NSDictionary alloc] initWithObjectsAndKeys:
    orgRels, @"GDataOrganization",
    standardRels, @"GDataEmail",
    standardRels, @"GDataIM",
    phoneRels, @"GDataPhoneNumber",
    standardRels, @"GDataStructuredPostalAddress", 
    noRels, @"GDataGroupMembershipInfo", 
    noRels, @"GDataExtendedProperty", nil];
}

- (void)dealloc {
  [relsDict_ release];
  [mObject release];
  [mGroupFeed release];
  [super dealloc]; 
}



#pragma mark -

// given a key, get the value from the object for that key, or an empty string
- (NSString *)stringValueForKey:(NSString *)key object:(GDataObject *)obj {
  if (key) {
    NSString *value = [obj valueForKey:key];
    if (value) {
      return value;
    }
  }
  return @"";
}

- (void)setUIFromObject:(GDataObject *)obj {
  
  ItemSelectors *sels = ItemSelectorsForObject(obj);
  
  NSString *value = [self stringValueForKey:(sels->valueKey) object:obj];
  NSString *label = [self stringValueForKey:(sels->labelKey) object:obj];
  NSString *rel = [self stringValueForKey:(sels->relKey) object:obj];
  NSString *title = [self stringValueForKey:(sels->titleKey) object:obj];
  NSString *protocol = [self stringValueForKey:(sels->protocolKey) object:obj];

  [mClassNameField setStringValue:(sels->classDisplayName)];
  
  [mValueField setStringValue:value];
  [mLabelField setStringValue:label];
  [mRelField setStringValue:rel];
  [mOrgTitleField setStringValue:title];
  [mProtocolField setStringValue:protocol];

  [mValueField setEnabled:(sels->valueKey != nil)];
  [mLabelField setEnabled:(sels->labelKey != nil)];
  [mRelField setEnabled:(sels->relKey != nil)];
  [mOrgTitleField setEnabled:(sels->titleKey != nil)];
  [mProtocolField setEnabled:(sels->protocolKey != nil)];
  
  // group combo box
  if ([obj isKindOfClass:[GDataGroupMembershipInfo class]]) {
    [mGroupField setEnabled:YES];
    
    // set the field text to the group namefor this object's href
    NSString *objectID = [(GDataGroupMembershipInfo *)obj href];
    if (objectID) {
      GDataEntryContactGroup *groupEntry = [mGroupFeed entryForIdentifier:objectID];
      NSString *name = [[groupEntry title] stringValue];
      [mGroupField setStringValue:name];
    }
  } else {
    [mGroupField setEnabled:NO];
  }
  
  // "primary" checkbox
  if ([obj respondsToSelector:@selector(isPrimary)]) {
    BOOL isPrimary = [(id)obj isPrimary];
    [mPrimaryCheckbox setState:(isPrimary ? NSOnState : NSOffState)];
    [mPrimaryCheckbox setEnabled:YES];
  } else {
    [mPrimaryCheckbox setEnabled:NO];
  }

  // "deleted" checkbox
  if ([obj respondsToSelector:@selector(isDeleted)]) {
    BOOL isDeleted = [(id)obj isDeleted];
    [mDeletedCheckbox setState:(isDeleted ? NSOnState : NSOffState)];
    [mDeletedCheckbox setEnabled:YES];
  } else {
    [mDeletedCheckbox setEnabled:NO];
  }
  
}

- (NSString *)stringValueOrNilForField:(NSTextField *)field {
  NSString *str = [field stringValue];
  return ([str length] > 0) ? str : nil;
}

- (GDataObject *)objectFromUI {
  
  ItemSelectors *sels = ItemSelectorsForObject(mObject);
  
  NSString *value = [self stringValueOrNilForField:mValueField];
  NSString *label = [self stringValueOrNilForField:mLabelField];
  NSString *rel = [self stringValueOrNilForField:mRelField];
  NSString *title = [self stringValueOrNilForField:mOrgTitleField];
  NSString *protocol = [self stringValueOrNilForField:mProtocolField];
  
  GDataObject *newObj = [mObject copy];
  
  if (sels->valueKey)    [newObj setValue:value forKey:sels->valueKey];
  if (sels->labelKey)    [newObj setValue:label forKey:sels->labelKey];
  if (sels->relKey)      [newObj setValue:rel forKey:sels->relKey];
  if (sels->titleKey)    [newObj setValue:title forKey:sels->titleKey];
  if (sels->protocolKey) [newObj setValue:protocol forKey:sels->protocolKey];
  
  if ([mPrimaryCheckbox isEnabled]) {
    BOOL isPrimary = ([mPrimaryCheckbox state] == NSOnState);
    [(id)newObj setIsPrimary:isPrimary];
  }

  if ([mDeletedCheckbox isEnabled]) {
    BOOL isDeleted = ([mDeletedCheckbox state] == NSOnState);
    [(id)newObj setIsDeleted:isDeleted];
  }
  
  if ([mGroupField isEnabled]) {
    // find the index of the group entry that has the title in the combo box
    NSString *str = [mGroupField stringValue];
    NSArray *titles = [mGroupFeed valueForKeyPath:@"entries.title.stringValue"];
    int index = [titles indexOfObject:str];

    NSString *href;
    if (index != NSNotFound) {
      // we found the title; get the corresponding entry's ID
      href = [[[mGroupFeed entries] objectAtIndex:index] identifier];
    } else {
      // it wasn't a title, so assume the user entered a group's ID
      href = str; 
    }
    [(id)newObj setHref:href];
  }
  
  return newObj;
}



#pragma mark -

- (void)runModalForTarget:(id)target
                 selector:(SEL)doneSelector
                groupFeed:(GDataFeedContactGroup *)groupFeed
                   object:(GDataObject *)object
{
  
  mTarget = target;
  mDoneSEL = doneSelector;
  mObject = [object retain];
  mGroupFeed = [groupFeed retain];
  
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

- (GDataObject *)object {
  // copy from our dialog's controls into the object
  return [self objectFromUI]; 
}

- (BOOL)wasSaveClicked {
  return mWasSaveClicked; 
}

#pragma mark Rel and Protocol combo box data source

- (NSArray *)relsForCurrentObject {
  NSString *className = NSStringFromClass([mObject class]);
  return [relsDict_ objectForKey:className];
}

- (NSArray *)protocolsForCurrentObject {
  
  if ([mObject class] == [GDataIM class]) {
    
    return [NSArray arrayWithObjects:
      kGDataIMProtocolAIM, kGDataIMProtocolGoogleTalk, kGDataIMProtocolICQ,
      kGDataIMProtocolJabber, kGDataIMProtocolMSN, kGDataIMProtocolYahoo, nil];
  }
  return nil;
}

- (int)numberOfItemsInComboBox:(NSComboBox *)aComboBox {
  if (aComboBox == mRelField) {
    return [[self relsForCurrentObject] count];
  } else if (aComboBox == mGroupField) {
    return [[mGroupFeed entries] count];
  } else {
    return [[self protocolsForCurrentObject] count];
  }
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(int)index {
  if (aComboBox == mRelField) {
    return [[self relsForCurrentObject] objectAtIndex:index];
  } else if (aComboBox == mGroupField) {
    NSArray *titles = [mGroupFeed valueForKeyPath:@"entries.title.stringValue"];
    return [titles objectAtIndex:index];
  } else {
    return [[self protocolsForCurrentObject] objectAtIndex:index];
  }
}

@end


@implementation GDataExtendedProperty (ContactsSampleAdditions)
// getter that looks for a plain value or for an XML array;
// setter that looks for a leading "<" to decide if it's an XML element

- (NSString *)unifiedStringValue {
  
  NSString *result = [self value];
  if (result == nil) {
    NSArray *xmlStrings  = [[self XMLValues] valueForKey:@"XMLString"];
    result = [xmlStrings componentsJoinedByString:@""];
  }
  return result; 
}

- (void)setUnifiedStringValue:(NSString *)str {
  NSCharacterSet *wsSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  NSString *trimmed = [str stringByTrimmingCharactersInSet:wsSet];
  
  if ([trimmed hasPrefix:@"<"]) {
    
    // set as an XML element
    NSError *error = nil;
    NSXMLElement *element;
    element = [[[NSXMLElement alloc] initWithXMLString:str
                                                 error:&error] autorelease];
    if (element) {
      [self setXMLValues:[NSArray arrayWithObject:element]];
    } else {
      NSLog(@"XML parse error: %@", error);
      [self setXMLValues:nil];
    }
    [self setValue:nil];

  } else {
    
    // set as an attribute string
    [self setValue:str];
    [self setXMLValues:nil];
  }
}
@end
