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
//  ContactsSampleWindowController.m
//

#import "ContactsSampleWindowController.h"

#import "EditEntryWindowController.h"

#import "GData/GDataContacts.h"

// use a category on the Contact entry so we can refer to the display
// name string in a sort descriptor
@interface GDataEntryContact (ContactsSampleAdditions)
- (NSString *)entryDisplayName;
@end

@interface ContactsSampleWindowController (PrivateMethods)
- (void)updateUI;

- (void)fetchAllContacts;

- (void)fetchSelectedContactEntrys;
- (void)addAnItem;
- (void)editSelectedItem;
- (void)deleteSelectedItem;
- (void)makeSelectedItemPrimary;

- (void)addAContact;
- (void)deleteSelectedContact;

- (GDataServiceGoogleContact *)contactService;
- (GDataEntryContact *)selectedContact;
- (GDataObject *)selectedItem;

- (int)selectedSegment;
- (NSArray *)itemsForSelectedSegment;
  
- (NSString *)displayNameForItem:(id)item;

- (GDataFeedContact *)contactFeed;
- (void)setContactFeed:(GDataFeedContact *)feed;
- (NSError *)contactFetchError;
- (void)setContactFetchError:(NSError *)error;  
- (GDataServiceTicket *)contactFetchTicket;
- (void)setContactFetchTicket:(GDataServiceTicket *)ticket;

@end

enum {
  kOrganizationSegment = 0,
  kEmailSegment = 1,
  kPhoneSegment = 2,
  kPostalSegment = 3,
  kIMSegment = 4
};

@implementation ContactsSampleWindowController

static ContactsSampleWindowController* gContactsSampleWindowController = nil;


+ (ContactsSampleWindowController *)sharedContactsSampleWindowController {
  
  if (!gContactsSampleWindowController) {
    gContactsSampleWindowController = [[[self class] alloc] init];
  }  
  return gContactsSampleWindowController;
}


- (id)init {
  return [self initWithWindowNibName:@"ContactsSampleWindow"];
}

- (void)windowDidLoad {
}

- (void)awakeFromNib {
  // Set the result text fields to have a distinctive color and mono-spaced font
  // to aid in understanding of each contact query operation.
  [mContactResultTextField setTextColor:[NSColor darkGrayColor]];
  [mEntryResultTextField setTextColor:[NSColor darkGrayColor]];

  NSFont *resultTextFont = [NSFont fontWithName:@"Monaco" size:9];
  [mContactResultTextField setFont:resultTextFont];
  [mEntryResultTextField setFont:resultTextFont];

  [self updateUI];
}

- (void)dealloc {
  [mContactFeed release];
  [mContactFetchError release];
  [mContactFetchTicket release];
  
  [super dealloc];
}

#pragma mark -

- (void)updateSegmentedControlLabels {
  // put the number of each type of item in the label for the item
  int numOrg = [[[self selectedContact] organizations] count];
  NSString *orgLabel = [NSString stringWithFormat:@"Org - %d", numOrg];
  [mEntrySegmentedControl setLabel:orgLabel forSegment:kOrganizationSegment];

  int numEmail = [[[self selectedContact] emailAddresses] count];
  NSString *mailLabel = [NSString stringWithFormat:@"E-mail - %d", numEmail];
  [mEntrySegmentedControl setLabel:mailLabel forSegment:kEmailSegment];
   
  int numIM = [[[self selectedContact] IMAddresses] count];
  NSString *IMlabel = [NSString stringWithFormat:@"IM - %d", numIM];
  [mEntrySegmentedControl setLabel:IMlabel forSegment:kIMSegment];
  
  int numPhone = [[[self selectedContact] phoneNumbers] count];
  NSString *phoneLabel = [NSString stringWithFormat:@"Phone - %d", numPhone];
  [mEntrySegmentedControl setLabel:phoneLabel forSegment:kPhoneSegment];
  
  int numPostal = [[[self selectedContact] postalAddresses] count];
  NSString *postalLabel = [NSString stringWithFormat:@"Postal - %d", numPostal];
  [mEntrySegmentedControl setLabel:postalLabel forSegment:kPostalSegment];
}

- (void)updateUI {
  
  // contact list display
  [mContactTable reloadData]; 
  
  if (mContactFetchTicket != nil) {
    [mContactProgressIndicator startAnimation:self];  
  } else {
    [mContactProgressIndicator stopAnimation:self];  
  }
  
  GDataEntryContact *selectedContact = [self selectedContact];

  // show contact fetch result error or the selected contact 
  NSString *contactResultStr = @"";
  if (mContactFetchError) {
    contactResultStr = [mContactFetchError description];
  } else {
    if (selectedContact) {
      contactResultStr = [selectedContact description];
    }
  }
  [mContactResultTextField setString:contactResultStr];
  

  // the bottom table displays items (orgs, e-mail, postal, IM, or phone
  // numbers) for the selected contact, according to the selected segment 
  // for the type of the item
  
  [mEntryTable reloadData]; 
  
  // display selected item's description
  NSString *entryDesc = @"";
  GDataObject *selectedItem = [self selectedItem];
  if (selectedItem) {
    entryDesc = [selectedItem description];
  }
  [mEntryResultTextField setString:entryDesc];
  
  // show the number of items for each segment
  [self updateSegmentedControlLabels];
  
  // enable/disable cancel button depending on if a ticket is outstanding
  [mContactCancelButton setEnabled:(mContactFetchTicket != nil)];
  
  // enable/disable other buttons
  BOOL isContactSelected = (selectedContact != nil);
  
  BOOL isItemSelected = ([self selectedItem] != nil);
  
  [mAddEntryButton setEnabled:isContactSelected];
  [mDeleteEntryButton setEnabled:isItemSelected];
  [mEditEntryButton setEnabled:isItemSelected];
  [mMakePrimaryEntryButton setEnabled:isItemSelected];
  
  [mEntrySegmentedControl setEnabled:isContactSelected];
  [mDeleteContactButton setEnabled:isContactSelected];
  
  BOOL isFeedAvailable = (mContactFeed != nil);
  BOOL isAddInfoEntered = ([[mAddTitleField stringValue] length] > 0);
  
  [mAddContactButton setEnabled:(isAddInfoEntered && isFeedAvailable)];
}

#pragma mark IBActions

- (IBAction)getContactClicked:(id)sender {
  
  NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];

  NSString *username = [mUsernameField stringValue];
  username = [username stringByTrimmingCharactersInSet:whitespace];

  if ([username rangeOfString:@"@"].location == NSNotFound) {
    // if no domain was supplied, add @gmail.com
    username = [username stringByAppendingString:@"@gmail.com"];
  }
  
  [mUsernameField setStringValue:username];

  [self fetchAllContacts];
}

- (IBAction)cancelContactFetchClicked:(id)sender {
  [mContactFetchTicket cancelTicket];
  [self setContactFetchTicket:nil];
  [self updateUI];
}

- (IBAction)addContactClicked:(id)sender {
  [self addAContact];
}

- (IBAction)deleteContactClicked:(id)sender {
  [self deleteSelectedContact];
}

- (IBAction)addEntryClicked:(id)sender {
  [self addAnItem];
}

- (IBAction)editEntryClicked:(id)sender {
  [self editSelectedItem];
}

- (IBAction)deleteEntryClicked:(id)sender {
  [self deleteSelectedItem];
}

- (IBAction)makeEntryPrimaryClicked:(id)sender {
  [self makeSelectedItemPrimary];
}

- (IBAction)entrySegmentClicked:(id)sender {
  [self updateUI];  
}

- (IBAction)sortContactsClicked:(id)sender {
  [self updateUI]; 
}

- (IBAction)loggingCheckboxClicked:(id)sender {
  [GDataHTTPFetcher setIsLoggingEnabled:[sender state]]; 
}

#pragma mark -

// get a contact service object with the current username/password
//
// A "service" object handles networking tasks.  Service objects
// contain user authentication information as well as networking
// state information (such as cookies and the "last modified" date for
// fetched data.)

- (GDataServiceGoogleContact *)contactService {
  
  static GDataServiceGoogleContact* service = nil;
  
  if (!service) {
    service = [[GDataServiceGoogleContact alloc] init];
    
    [service setUserAgent:@"SampleContactApp"];
    [service setShouldCacheDatedData:YES]; 
    [service setServiceShouldFollowNextLinks:YES];
  }

  // update the username/password each time the service is requested
  NSString *username = [mUsernameField stringValue];
  NSString *password = [mPasswordField stringValue];
  
  [service setUserCredentialsWithUsername:username
                                 password:password];
  
  return service;
}

// returns all contacts from the feed, sorted if the checkbox is checked
- (NSArray *)sortedContactEntries {
  NSArray *entries = [mContactFeed entries];
  
  if ([mSortContactsCheckbox state] == NSOnState) {
    
    NSSortDescriptor *sortDesc;
    SEL sel = @selector(caseInsensitiveCompare:);
    
    sortDesc = [[[NSSortDescriptor alloc] initWithKey:@"entryDisplayName" 
                                            ascending:YES
                                             selector:sel] autorelease];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDesc];
    entries = [entries sortedArrayUsingDescriptors:sortDescriptors];
  }
  return entries;
}

// get the contact selected in the top list, or nil if none
- (GDataEntryContact *)selectedContact {
  
  NSArray *contacts = [self sortedContactEntries];
  int rowIndex = [mContactTable selectedRow];
  if ([contacts count] > 0 && rowIndex > -1) {
    
    GDataEntryContact *contact = [contacts objectAtIndex:rowIndex];
    return contact;
  }
  return nil;
}

// get the item selected in the bottom list, or nil if none
//
// the item could be org, phone, e-mail, IM, or postal
- (GDataObject *)selectedItem {
  
  NSArray *entries = [self itemsForSelectedSegment];
  
  int rowIndex = [mEntryTable selectedRow];
  if ([entries count] > 0 && rowIndex > -1) {
    
    GDataObject *entry = [entries objectAtIndex:rowIndex];
    return entry;
  }
  return nil;  
}

- (int)selectedSegment {
  return [mEntrySegmentedControl selectedSegment];
}

// get the key needed to retrieve the list of items from a contact
- (NSString *)keyForSelectedSegment {
  
  switch ([mEntrySegmentedControl selectedSegment]) {
    case kOrganizationSegment:  return @"organizations";
    case kEmailSegment:  return @"emailAddresses";
    case kPhoneSegment:  return @"phoneNumbers";
    case kPostalSegment: return @"postalAddresses";
    case kIMSegment:     return @"IMAddresses";
  }  
  return nil;
}

// get the selector needed to make an item primary
- (SEL)makePrimarySelectorForSelectedSegment {
  
  switch ([mEntrySegmentedControl selectedSegment]) {
    case kOrganizationSegment: return @selector(setPrimaryOrganization:);
    case kEmailSegment:        return @selector(setPrimaryEmailAddress:);
    case kIMSegment:           return @selector(setPrimaryIMAddress:);
    case kPhoneSegment:        return @selector(setPrimaryPhoneNumber:);
    case kPostalSegment:       return @selector(setPrimaryPostalAddress:);
  }  
  return nil;
}

// get the list of items from the selected contact, according to the segmented
// control's selection
- (NSArray *)itemsForSelectedSegment {
  
  NSString *path = [self keyForSelectedSegment];
  SEL sel = NSSelectorFromString(path);
  
  GDataEntryContact *selectedContact = [self selectedContact];
  NSArray *array = [selectedContact performSelector:sel];
  return array;
}

- (Class)itemClassForSelectedSegment {
  
  switch ([mEntrySegmentedControl selectedSegment]) {
    case kOrganizationSegment:  return [GDataOrganization class];
    case kEmailSegment:         return [GDataEmail class];
    case kPhoneSegment:         return [GDataPhoneNumber class];
    case kPostalSegment:        return [GDataPostalAddress class];
    case kIMSegment:            return [GDataIM class];
  }
  return nil;
}

#pragma mark Fetch all contacts

// begin retrieving the list of the user's contacts
- (void)fetchAllContacts {
  
  [self setContactFeed:nil];
  [self setContactFetchError:nil];
  [self setContactFetchTicket:nil];
    
  GDataServiceGoogleContact *service = [self contactService];
  GDataServiceTicket *ticket;
  
  BOOL showDeleted = ([mShowDeletedCheckbox state] == NSOnState);

  // request a whole buncha contacts; our service object is set to
  // follow next links as well in case there are more than 2000
  const int kBuncha = 2000;
  
  GDataQueryContact *query = [GDataQueryContact contactQueryForUserID:username];
  [query setShouldShowDeleted:showDeleted];
  [query setMaxResults:kBuncha];
  
  ticket = [service fetchContactQuery:query
                             delegate:self
                    didFinishSelector:@selector(contactsFetchTicket:finishedWithFeed:)
                      didFailSelector:@selector(contactsFetchTicket:failedWithError:)];

  [self setContactFetchTicket:ticket];
  
  [self updateUI];
}

//
// contact list fetch callbacks
//

// finished contact list successfully
- (void)contactsFetchTicket:(GDataServiceTicket *)ticket
           finishedWithFeed:(GDataFeedContact *)object {
  
  [self setContactFeed:object];
  [self setContactFetchError:nil];    
  [self setContactFetchTicket:nil];
  
  [self updateUI];
} 

// failed
- (void)contactsFetchTicket:(GDataServiceTicket *)ticket
                failedWithError:(NSError *)error {

  [self setContactFeed:nil];
  [self setContactFetchError:error];    
  [self setContactFetchTicket:nil];

  [self updateUI];
}

#pragma mark Add a Contact

- (void)addAContact {
  
  NSString *title = [mAddTitleField stringValue];
  NSString *email = [mAddEmailField stringValue];

  if ([title length] > 0) {
    
    GDataEntryContact *newContact;
    newContact = [GDataEntryContact contactEntryWithTitle:title];
        
    if ([email length] > 0) {
      // all items must have a rel or a label, but not both
      GDataEmail *emailObj = [GDataEmail emailWithLabel:nil
                                                address:email];
      [emailObj setRel:kGDataContactOther];
      [emailObj setIsPrimary:YES];
      
      [newContact addEmailAddress:emailObj];
    }
    
    GDataServiceGoogleContact *service = [self contactService];
    
    NSURL *postURL = [[[mContactFeed links] postLink] URL];
    
    [service fetchContactEntryByInsertingEntry:newContact
                                    forFeedURL:postURL
                                      delegate:self
                             didFinishSelector:@selector(addContactTicket:addedEntry:)
                               didFailSelector:@selector(addContactTicket:failedWithError:)];
  }
}


// contact added successfully
- (void)addContactTicket:(GDataServiceTicket *)ticket
              addedEntry:(GDataEntryContact *)object {
  
  // tell the user that the add worked
  NSBeginAlertSheet(@"Added contact", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Contact added");
  
  [mAddTitleField setStringValue:@""];
  [mAddEmailField setStringValue:@""];
  
  // refetch the current contacts
  [self fetchAllContacts];
  [self updateUI];
} 

// failure to add contact
- (void)addContactTicket:(GDataServiceTicket *)ticket
         failedWithError:(NSError *)error {
  
  NSBeginAlertSheet(@"Add failed", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Item add failed: %@", error);
  
}

#pragma mark Delete a Contact

- (void)deleteSelectedContact {
  
  // display the confirmation dialog
  GDataEntryContact *contact = [self selectedContact];
  if (contact) {
    
    // make the user confirm that the selected contact should be deleted
    NSBeginAlertSheet(@"Delete Contact", @"Delete", @"Cancel", nil,
                      [self window], self, 
                      @selector(contactDeleteSheetDidEnd:returnCode:contextInfo:),
                      nil, nil, @"Delete the contact \"%@\"?",
                      [contact entryDisplayName]);
  }
}

// delete dialog callback
- (void)contactDeleteSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
  
  if (returnCode == NSAlertDefaultReturn) {
    
    // delete the contact
    
    // now update the contact on the server
    GDataServiceGoogleContact *service = [self contactService];
    
    GDataEntryContact *contact = [self selectedContact];
    
    NSURL *entryURL = [[[contact links] editLink] URL];
    
    [service deleteContactResourceURL:entryURL
                             delegate:self
                    didFinishSelector:@selector(deleteContactTicket:finishedWithObject:)
                      didFailSelector:@selector(deleteContactTicket:failedWithError:)];
  }
}

// contact deleted successfully
- (void)deleteContactTicket:(GDataServiceTicket *)ticket
         finishedWithObject:(GDataEntryContact *)object {
  
  NSBeginAlertSheet(@"Deleted contact", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Contact deleted");
  
  // re-fetch all contacts
  [self fetchAllContacts];
  [self updateUI];
} 

// failure to delete contact
- (void)deleteContactTicket:(GDataServiceTicket *)ticket
            failedWithError:(NSError *)error {
  
  NSBeginAlertSheet(@"Delete failed", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Contact delete failed: %@", error);
  
}


#pragma mark Add an Item

- (void)addAnItem {
  
  // make a new object for the selected segment type
  // (org, phone, postal, IM, e-mail)
  Class objClass = [self itemClassForSelectedSegment];
  id obj = [[[objClass alloc] init] autorelease];
  
  // each item needs a rel or a label; we'll use other as a default rel
  [obj setRel:kGDataContactOther];
  
  // display the item edit dialog
  EditEntryWindowController *controller = [[EditEntryWindowController alloc] init];
  [controller runModalForTarget:self
                       selector:@selector(addEditControllerFinished:)
                         object:obj];
}

// callback from the edit item dialog
- (void)addEditControllerFinished:(EditEntryWindowController *)addEntryController {
  
  if ([addEntryController wasSaveClicked]) {
    
    // add the object into a copy of the selected contact, 
    // and update the contact
    GDataObject *obj = [addEntryController object];
    if (obj) {
      
      // make a new array of items with the addition added to it
      NSArray *oldItems = [self itemsForSelectedSegment];
      NSMutableArray *newItems = [NSMutableArray arrayWithArray:oldItems];
      [newItems addObject:obj];
      
      // replace the contact's item array with our new one
      NSString *keyForSelectedSegment = [self keyForSelectedSegment];
      
      GDataEntryContact *selectedContactCopy = [[[self selectedContact] copy] autorelease];
      [selectedContactCopy setValue:newItems forKey:keyForSelectedSegment];
      
      // now update the contact on the server
      GDataServiceGoogleContact *service = [self contactService];
      
      NSURL *entryURL = [[[selectedContactCopy links] editLink] URL];
      
      [service fetchContactEntryByUpdatingEntry:selectedContactCopy
                                    forEntryURL:entryURL
                                       delegate:self
                              didFinishSelector:@selector(addItemTicket:addedEntry:)
                                didFailSelector:@selector(addItemTicket:failedWithError:)];
    }
  }
  [addEntryController autorelease];
}

// item added successfully
- (void)addItemTicket:(GDataServiceTicket *)ticket
           addedEntry:(GDataEntryContact *)object {
  
  // tell the user that the add worked
  NSBeginAlertSheet(@"Added item", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Item added");
  
  // refetch the current contact's items
  [self fetchAllContacts];
  [self updateUI];
} 

// failure to add item
- (void)addItemTicket:(GDataServiceTicket *)ticket
      failedWithError:(NSError *)error {
  
  NSBeginAlertSheet(@"Add failed", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Item add failed: %@", error);
}


#pragma mark Edit an item

- (void)editSelectedItem {
  
  // display the item edit dialog
  GDataObject *item = [self selectedItem];
  if (item) {
    EditEntryWindowController *controller = [[EditEntryWindowController alloc] init];
    [controller runModalForTarget:self
                         selector:@selector(editControllerFinished:)
                           object:item];
  }
}

// callback from the edit item dialog
- (void)editControllerFinished:(EditEntryWindowController *)editContactController {
  
  if ([editContactController wasSaveClicked]) {
    
    // add the object into the selected contact, and update the contact
    GDataObject *obj = [editContactController object];
    if (obj) {
      
      // make a new array of items with the edited item replacing its predecessor
      NSArray *oldItems = [self itemsForSelectedSegment];
      NSMutableArray *newItems = [NSMutableArray arrayWithArray:oldItems];
      [newItems replaceObjectAtIndex:[newItems indexOfObject:[self selectedItem]]
                                                  withObject:obj];
      
      // replace the contact's item array with our new one
      NSString *keyForSelectedSegment = [self keyForSelectedSegment];
      
      GDataEntryContact *selectedContactCopy = [[[self selectedContact] copy] autorelease];
      [selectedContactCopy setValue:newItems forKey:keyForSelectedSegment];
      
      // now update the contact on the server
      GDataServiceGoogleContact *service = [self contactService];
      
      NSURL *entryURL = [[[selectedContactCopy links] editLink] URL];
      
      [service fetchContactEntryByUpdatingEntry:selectedContactCopy
                                    forEntryURL:entryURL
                                       delegate:self
                              didFinishSelector:@selector(editItemTicket:editedEntry:)
                                didFailSelector:@selector(editItemTicket:failedWithError:)];
    }
  }
  [editContactController autorelease];
}

// item edited successfully
- (void)editItemTicket:(GDataServiceTicket *)ticket
           editedEntry:(GDataEntryContact *)object {
  
  // tell the user that the update worked
  NSBeginAlertSheet(@"Updated Entry", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Entry updated");
  
  // re-fetch the selected contact's items
  [self fetchAllContacts];
  [self updateUI];
} 

// failure to submit edited item
- (void)editItemTicket:(GDataServiceTicket *)ticket
       failedWithError:(NSError *)error {
  
  NSBeginAlertSheet(@"Update failed", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Entry update failed: %@", error);
  
}

#pragma mark Delete an item

- (void)deleteSelectedItem {
  
  // display the item edit dialog
  GDataObject *item = [self selectedItem];
  if (item) {
    
    // make the user confirm that the selected item should be deleted
    NSBeginAlertSheet(@"Delete Item", @"Delete", @"Cancel", nil,
                      [self window], self, 
                      @selector(itemDeleteSheetDidEnd:returnCode:contextInfo:),
                      nil, nil, @"Delete the item \"%@\"?",
                      [item description]);
  }
}

// delete dialog callback
- (void)itemDeleteSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
  
  if (returnCode == NSAlertDefaultReturn) {
    
    // delete the item from the contact's item array
    
    NSArray *oldItems = [self itemsForSelectedSegment];
    NSMutableArray *newItems = [NSMutableArray arrayWithArray:oldItems];
    [newItems removeObject:[self selectedItem]];
    
    // replace the contact's item array with our new one
    NSString *keyForSelectedSegment = [self keyForSelectedSegment];
    
    GDataEntryContact *selectedContact = [self selectedContact];
    [selectedContact setValue:newItems forKey:keyForSelectedSegment];
    
    // now update the contact on the server
    GDataServiceGoogleContact *service = [self contactService];
    
    NSURL *entryURL = [[[selectedContact links] editLink] URL];
    
    [service fetchContactEntryByUpdatingEntry:selectedContact
                                  forEntryURL:entryURL
                                     delegate:self
                            didFinishSelector:@selector(deleteItemTicket:updatedEntry:)
                              didFailSelector:@selector(deleteItemTicket:failedWithError:)];
  }
}

// item deleted successfully
- (void)deleteItemTicket:(GDataServiceTicket *)ticket
            updatedEntry:(GDataEntryContact *)object {
  
  NSBeginAlertSheet(@"Deleted item", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Item deleted");
  
  // re-fetch the selected contact's items
  [self fetchAllContacts];
  [self updateUI];
} 

// failure to delete item
- (void)deleteItemTicket:(GDataServiceTicket *)ticket
         failedWithError:(NSError *)error {
  
  NSBeginAlertSheet(@"Delete failed", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Item delete failed: %@", error);
}

#pragma mark Make selected item primary

- (void)makeSelectedItemPrimary {
  
  GDataObject *item = [self selectedItem];
  GDataEntryContact *selectedContactCopy = [[[self selectedContact] copy] autorelease];
  
  SEL sel = [self makePrimarySelectorForSelectedSegment];
  [selectedContactCopy performSelector:sel withObject:item];
  
  // now update the contact on the server
  GDataServiceGoogleContact *service = [self contactService];
  
  NSURL *entryURL = [[[selectedContactCopy links] editLink] URL];
  
  GDataServiceTicket *ticket =
    [service fetchContactEntryByUpdatingEntry:selectedContactCopy
                                  forEntryURL:entryURL
                                     delegate:self
                            didFinishSelector:@selector(makePrimaryTicket:finishedWithEntry:)
                              didFailSelector:@selector(makePrimaryTicket:failedWithError:)];
  [ticket setUserData:item];
}

// item edited successfully
- (void)makePrimaryTicket:(GDataServiceTicket *)ticket
        finishedWithEntry:(GDataEntryContact *)object {
  
  NSBeginAlertSheet(@"Made primary", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Item made primary: %@",
                    [self displayNameForItem:[ticket userData]]);  
  
  // re-fetch the selected contact's items
  [self fetchAllContacts];
  [self updateUI];
} 

// item edited successfully
- (void)makePrimaryTicket:(GDataServiceTicket *)ticket
          failedWithError:(NSError *)error {
  
  NSBeginAlertSheet(@"Make primary failed", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Could not make item primary: %@", error);
} 



#pragma mark TableView delegate methods
//
// table view delegate methods
//

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  
  [self updateUI];
}

// table view data source methods
- (int)numberOfRowsInTableView:(NSTableView *)tableView {
  if (tableView == mContactTable) {
    return [[mContactFeed entries] count];
  } else {
    // entry table
    return [[self itemsForSelectedSegment] count];
  }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
  if (tableView == mContactTable) {
    
    // get the contact's title
    GDataEntryContact *contact = [[self sortedContactEntries] objectAtIndex:row];
    if (contact) {
      return [contact entryDisplayName];
    }
  } else {
    // item table, displaying according to the segment selected
    
    NSString *output = nil;
    
    NSArray *items = [self itemsForSelectedSegment];
    if ([items count] > row) {
      id obj = [items objectAtIndex:row];
      
      output = [self displayNameForItem:obj];
      
      if (output != nil && [obj isPrimary]) {
        output = [output stringByAppendingString:@" (primary)"];
      }
    }
    return output;
  }
  return nil;
}

- (NSString *)displayNameForItem:(id)item {
  
  NSString *result = nil;
  
  // e-mail and IM have address methods
  if ([item respondsToSelector:@selector(address)]) {
    result = [item address]; 
  }
  
  // org has title and name
  else if ([item respondsToSelector:@selector(orgTitle)]) {
    
    NSString *title = [item orgTitle];
    NSString *name = [item orgName];
    
    if (title && name) {
      result = [NSString stringWithFormat:@"%@, %@", title, name];
    } else if (title) {
      result = title;
    } else {
      result = name;
    }
  }
  
  // postal and phone have stringValue methods
  else {
    NSMutableString *mutable = [NSMutableString stringWithString:[item stringValue]];
    
    // make the return character visible 
    NSString *returnChar = [NSString stringWithUTF8String:"\n"];
    NSString *returnSymbol = [NSString stringWithFormat:@"%C", 0x23CE];
    [mutable replaceOccurrencesOfString:returnChar 
                             withString:returnSymbol
                                options:0
                                  range:NSMakeRange(0, [mutable length])];
    result = mutable;
  }
  return result;
}

//
// control delegate methods
//

- (void)controlTextDidChange:(NSNotification *)aNotification {
  // enable or disable Add Contact button
  [self updateUI]; 
}

#pragma mark Setters and Getters

- (GDataFeedContact *)contactFeed {
  return mContactFeed; 
}

- (void)setContactFeed:(GDataFeedContact *)feed {
  [mContactFeed autorelease];
  mContactFeed = [feed retain];
}

- (NSError *)contactFetchError {
  return mContactFetchError; 
}

- (void)setContactFetchError:(NSError *)error {
  [mContactFetchError release];
  mContactFetchError = [error retain];
}

- (GDataServiceTicket *)contactFetchTicket {
  return mContactFetchTicket; 
}

- (void)setContactFetchTicket:(GDataServiceTicket *)ticket {
  [mContactFetchTicket release];
  mContactFetchTicket = [ticket retain];
}

@end

// get a string to use to represent a contact. This may be the contact's
// name (from the title field), the e-mail address, or for deleted contacts,
// an x-mark and the ID
//
// use a category on the Contact entry so we can refer to the display
// name string in a sort descriptor

@implementation GDataEntryContact (ContactsSampleAdditions)

- (NSString *)entryDisplayName {
  
  NSString *title;
  
  if ([self isDeleted]) {
    // show deleted contacts by ID, preceded by a fancy X mark
    const int kBallotX = 0x2717;
    title = [NSString stringWithFormat:@"%C %@", 
      kBallotX, [self identifier]];
  } else {  
    
    title = [[self title] stringValue];
    
    // if no title, fall back on e-mail address or use the string "Contact N"
    if ([title length] == 0 && [[self emailAddresses] count] > 0) {
      
      GDataEmail *email = [self primaryEmailAddress];
      if (email == nil) {
        email = [[self emailAddresses] objectAtIndex:0];
      }
      title = [email address]; 
    }
    
    if ([title length] == 0) {
      // fallback case
      title = [self description]; 
    }
  }
  
  return title;
}

@end
