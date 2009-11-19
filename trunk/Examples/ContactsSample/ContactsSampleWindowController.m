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

static const int kBallotX = 0x2717; // fancy X mark to indicate deleted items

// use a category on the Contact entry so we can refer to the display
// name string in a sort descriptor
@interface GDataEntryContact (ContactsSampleAdditions)
- (NSString *)entryDisplayName;
@end

@interface GDataEntryContactGroup (ContactsSampleAdditions)
- (NSString *)entryDisplayName;
@end

@interface ContactsSampleWindowController (PrivateMethods)
- (void)updateUI;
- (void)updateImageForContact:(GDataEntryContact *)contact;

- (void)fetchAllGroupsAndContacts;
- (void)fetchAllContacts;

- (void)addAnItem;
- (void)editSelectedItem;
- (void)deleteSelectedItem;
- (void)makeSelectedItemPrimary;

- (void)setContactImage;
- (void)deleteContactImage;
- (void)setSelectedContactPhotoAtPath:(NSString *)photoPath;

- (void)addAContact;
- (void)addAGroup;
- (void)deleteSelectedContactOrGroup;
- (void)deleteAllContactsOrGroups;

- (GDataServiceGoogleContact *)contactService;
- (GDataEntryContact *)selectedContact;
- (GDataEntryContactGroup *)selectedGroup;
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
- (NSString *)contactImageETag;
- (void)setContactImageETag:(NSString *)str;

- (GDataFeedContactGroup *)groupFeed;
- (void)setGroupFeed:(GDataFeedContactGroup *)feed;
- (NSError *)groupFetchError;
- (void)setGroupFetchError:(NSError *)error;  
- (GDataServiceTicket *)groupFetchTicket;
- (void)setGroupFetchTicket:(GDataServiceTicket *)ticket;
@end

enum {
  kContactsSegment = 0,
  kGroupsSegment = 1
};

enum {
  kOrganizationSegment = 0,
  kEmailSegment = 1,
  kPhoneSegment = 2,
  kPostalSegment = 3,
  kIMSegment = 4,
  kGroupSegment = 5,
  kExtendedPropsSegment = 6
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
  [mFeedResultTextField setTextColor:[NSColor darkGrayColor]];
  [mEntryResultTextField setTextColor:[NSColor darkGrayColor]];
  
  NSFont *resultTextFont = [NSFont fontWithName:@"Monaco" size:9];
  [mFeedResultTextField setFont:resultTextFont];
  [mEntryResultTextField setFont:resultTextFont];
  
  [self updateUI];
}

- (void)dealloc {
  [mContactFeed release];
  [mContactFetchError release];
  [mContactFetchTicket release];
  [mContactImageETag release];
  
  [mGroupFeed release];
  [mGroupFetchError release];
  [mGroupFetchTicket release];
  
  [super dealloc];
}

#pragma mark -

- (BOOL)isDisplayingContacts {
  BOOL flag = ([mFeedSegmentedControl selectedSegment] == kContactsSegment); 
  return flag;
}

- (void)updateSegmentedControlLabels {
  BOOL isDisplayingContacts = [self isDisplayingContacts];
  
  // put the number of each type of segment in the label for the item
  
  // feed segments
  
  int numContacts = [[mContactFeed entries] count];
  NSString *contactsLabel = [NSString stringWithFormat:@"Contacts - %d", numContacts];
  [mFeedSegmentedControl setLabel:contactsLabel forSegment:kContactsSegment];
  
  int numGroups = [[mGroupFeed entries] count];
  NSString *groupsLabel = [NSString stringWithFormat:@"Groups - %d", numGroups];
  [mFeedSegmentedControl setLabel:groupsLabel forSegment:kGroupsSegment];
  
  // entry segments
  //
  // when contacts are displayed, all segments are enabled; when groups
  // are displayed, only extended properties is enabled
  
  int numOrg = [[[self selectedContact] organizations] count];
  NSString *orgLabel = [NSString stringWithFormat:@"Org - %d", numOrg];
  [mEntrySegmentedControl setLabel:orgLabel forSegment:kOrganizationSegment];
  [mEntrySegmentedControl setEnabled:isDisplayingContacts forSegment:kOrganizationSegment];
  
  int numEmail = [[[self selectedContact] emailAddresses] count];
  NSString *mailLabel = [NSString stringWithFormat:@"E-mail - %d", numEmail];
  [mEntrySegmentedControl setLabel:mailLabel forSegment:kEmailSegment];
  [mEntrySegmentedControl setEnabled:isDisplayingContacts forSegment:kEmailSegment];
  
  int numIM = [[[self selectedContact] IMAddresses] count];
  NSString *IMlabel = [NSString stringWithFormat:@"IM - %d", numIM];
  [mEntrySegmentedControl setLabel:IMlabel forSegment:kIMSegment];
  [mEntrySegmentedControl setEnabled:isDisplayingContacts forSegment:kIMSegment];
  
  int numPhone = [[[self selectedContact] phoneNumbers] count];
  NSString *phoneLabel = [NSString stringWithFormat:@"Phone - %d", numPhone];
  [mEntrySegmentedControl setLabel:phoneLabel forSegment:kPhoneSegment];
  [mEntrySegmentedControl setEnabled:isDisplayingContacts forSegment:kPhoneSegment];
  
  int numPostal = [[[self selectedContact] structuredPostalAddresses] count];
  NSString *postalLabel = [NSString stringWithFormat:@"Postal - %d", numPostal];
  [mEntrySegmentedControl setLabel:postalLabel forSegment:kPostalSegment];
  [mEntrySegmentedControl setEnabled:isDisplayingContacts forSegment:kPostalSegment];
  
  int numGroupInfos = [[[self selectedContact] groupMembershipInfos] count];
  NSString *groupLabel = [NSString stringWithFormat:@"Group - %d", numGroupInfos];
  [mEntrySegmentedControl setLabel:groupLabel forSegment:kGroupSegment];
  [mEntrySegmentedControl setEnabled:isDisplayingContacts forSegment:kGroupSegment];
  
  int numExtProps;
  if ([self isDisplayingContacts]) {
    numExtProps = [[[self selectedContact] extendedProperties] count];
  } else {
    numExtProps = [[[self selectedGroup] extendedProperties] count];
  }
  NSString *extPropsLabel = [NSString stringWithFormat:@"ExtProp - %d", numExtProps];
  [mEntrySegmentedControl setLabel:extPropsLabel forSegment:kExtendedPropsSegment];
}

- (void)updateUI {
  BOOL isDisplayingContacts = [self isDisplayingContacts];
  
  // contact list display
  [mFeedTable reloadData]; 
  
  if ((isDisplayingContacts && mContactFetchTicket != nil)
      || (!isDisplayingContacts && mGroupFetchTicket != nil)) {
    [mFeedProgressIndicator startAnimation:self];  
  } else {
    [mFeedProgressIndicator stopAnimation:self];  
  }
  
  GDataEntryContact *selectedContact = [self selectedContact];
  GDataEntryContactGroup *selectedGroup = [self selectedGroup];
  
  if (isDisplayingContacts) {
    
    // show contact fetch or group fetch result error or the selected contact 
    NSString *resultStr = @"";
    if (mContactFetchError) {
      resultStr = [mContactFetchError description];
    } else if (mGroupFetchError) {
      resultStr = [mGroupFetchError description];
    } else {
      if (selectedContact) {
        resultStr = [selectedContact description];
      }
    }
    [mFeedResultTextField setString:resultStr];
    
  } else {
    
    // show group fetch result error or the selected group 
    NSString *resultStr = @"";
    if (mGroupFetchError) {
      resultStr = [mGroupFetchError description];
    } else {
      if (selectedGroup) {
        resultStr = [selectedGroup description];
      }
    }
    [mFeedResultTextField setString:resultStr];
  }
  
  [self updateImageForContact:selectedContact];
  
  // the bottom table displays items (orgs, e-mail, postal, IM, or phone
  // numbers, groups, extended props) for the selected contact, according to the 
  // selected segment for the type of the item
  
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
  BOOL isTicketPending = (mContactFetchTicket != nil || mGroupFetchTicket != nil);
  [mFeedCancelButton setEnabled:isTicketPending];
  
  // enable/disable other buttons
  BOOL isContactOrGroupSelected = (selectedContact != nil || selectedGroup != nil);
  BOOL isItemSelected = ([self selectedItem] != nil);
  BOOL canItemBePrimary = [[self selectedItem] respondsToSelector:@selector(isPrimary)];
  BOOL isEntrySegmentEnabled = [mEntrySegmentedControl isEnabledForSegment:
                                      [mEntrySegmentedControl selectedSegment]];
  
  [mAddEntryButton setEnabled:(isEntrySegmentEnabled && isContactOrGroupSelected)];
  [mDeleteEntryButton setEnabled:isItemSelected];
  [mEditEntryButton setEnabled:isItemSelected];
  
  [mMakePrimaryEntryButton setEnabled:(isItemSelected && canItemBePrimary)];
  
  [mEntrySegmentedControl setEnabled:isContactOrGroupSelected];
  [mDeleteContactButton setEnabled:isContactOrGroupSelected];
  
  BOOL isFeedAvailable = (mContactFeed != nil || mGroupFeed != nil);
  BOOL isAddInfoEntered = ([[mAddTitleField stringValue] length] > 0);
  
  [mAddContactButton setEnabled:(isAddInfoEntered && isFeedAvailable)];
  
  BOOL canEditSelectedContactImage = ([selectedContact photoLink] != nil);
  [mSetContactImageButton setEnabled:canEditSelectedContactImage];
  
  BOOL doesContactHaveImage = ([[selectedContact photoLink] ETag] != nil);
  [mDeleteContactImageButton setEnabled:(doesContactHaveImage && 
                                         canEditSelectedContactImage)];
  
  [mAddTitleField setEnabled:isFeedAvailable];
  [mAddEmailField setEnabled:(isFeedAvailable && isDisplayingContacts)];
  [mAddContactButton setEnabled:isFeedAvailable];
  
  BOOL canDeleteAllEntries = 
    (isDisplayingContacts 
      && [[mContactFeed entries] count] > 0 
      && [mContactFeed batchLink] != nil)
    || (!isDisplayingContacts 
      && [[mGroupFeed entries] count] > 0
      && [mGroupFeed batchLink] != nil);
  
  [mDeleteAllButton setEnabled:canDeleteAllEntries];
  
  if (isDisplayingContacts) {
    [[mAddTitleField cell] setPlaceholderString:@"Add Name"]; 
    [[mAddEmailField cell] setPlaceholderString:@"Add E-mail"]; 
  } else {
    [[mAddTitleField cell] setPlaceholderString:@"Add Group"]; 
    [[mAddEmailField cell] setPlaceholderString:@""]; 
  }
}

// get or clear the image for this specified contact
- (void)updateImageForContact:(GDataEntryContact *)contact {

  if (!contact) {
    // clear the image
    [mContactImageView setImage:nil];
    [self setContactImageETag:nil];

  } else {
    // Google Contacts guarantees that the photo link ETag changes whenever
    // the photo for the contact changes
    //
    // if the new photo link ETag is different from the previous one,
    // clear the image and fetch the new image
    
    GDataLink *photoLink = [contact photoLink];

    NSString *imageETag = [photoLink ETag];
    if (imageETag == nil || ![mContactImageETag isEqual:imageETag]) {

      // save the image ETag for the contact we're fetching so later we can
      // use it to determine if the image on the server has changed
      [self setContactImageETag:imageETag];

      [mContactImageView setImage:nil];

      if (imageETag != nil) {

        // get an NSURLRequest object with an auth token
        NSURL *imageURL = [photoLink URL];
        GDataServiceGoogleContact *service = [self contactService];
        NSMutableURLRequest *request = [service requestForURL:imageURL
                                                         ETag:nil
                                                   httpMethod:nil];

        [request setValue:@"image/*" forHTTPHeaderField:@"Accept"];

        GDataHTTPFetcher *fetcher = [GDataHTTPFetcher httpFetcherWithRequest:request];

        [fetcher beginFetchWithDelegate:self
                      didFinishSelector:@selector(imageFetcher:finishedWithData:)
                        didFailSelector:@selector(imageFetcher:failedWithError:)];
      }
    }
  }
}

- (void)imageFetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data {
  // got the data; display it in the image view.  Because this is sample
  // code, we won't be rigorous about verifying that the selected contact hasn't
  // changed between when the fetch began and now.
  NSImage *image = [[[NSImage alloc] initWithData:data] autorelease];

  [mContactImageView setImage:image];
}

- (void)imageFetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error {
  NSLog(@"imageFetcher:%@ failedWithError:%@", fetcher,  error);       
}


#pragma mark IBActions

- (IBAction)getFeedClicked:(id)sender {
  
  NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  
  NSString *username = [mUsernameField stringValue];
  username = [username stringByTrimmingCharactersInSet:whitespace];
  
  if ([username rangeOfString:@"@"].location == NSNotFound) {
    // if no domain was supplied, add @gmail.com
    username = [username stringByAppendingString:@"@gmail.com"];
  }
  
  [mUsernameField setStringValue:username];
  
  [self fetchAllGroupsAndContacts];
}

- (IBAction)feedSegmentClicked:(id)sender {
  [self updateUI];  
}

- (IBAction)cancelFeedFetchClicked:(id)sender {
  [mContactFetchTicket cancelTicket];
  [self setContactFetchTicket:nil];
  
  [mGroupFetchTicket cancelTicket];
  [self setGroupFetchTicket:nil];
  
  [self updateUI];
}

- (IBAction)setContactImageClicked:(id)sender {
  [self setContactImage]; 
}

- (IBAction)deleteContactImageClicked:(id)sender {
  [self deleteContactImage]; 
}

- (IBAction)addContactClicked:(id)sender {
  if ([self isDisplayingContacts]) {
    [self addAContact];
  } else {
    [self addAGroup]; 
  }
}

- (IBAction)deleteContactClicked:(id)sender {
  [self deleteSelectedContactOrGroup];
}

- (IBAction)deleteAllClicked:(id)sender {
  [self deleteAllContactsOrGroups];
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

- (NSArray *)sortedEntries:(NSArray *)entries {
  
  if ([mSortFeedCheckbox state] == NSOnState) {
    
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

// returns all contacts from the feed, sorted if the checkbox is checked
- (NSArray *)sortedContactEntries {
  NSArray *entries = [mContactFeed entries];
  return [self sortedEntries:entries];
}

// returns all groups from the feed, sorted if the checkbox is checked
- (NSArray *)sortedGroupEntries {
  NSArray *entries = [mGroupFeed entries];
  return [self sortedEntries:entries];
}


// get the contact selected in the top list, or nil if none or if groups
// are being viewed
- (GDataEntryContact *)selectedContact {
  
  if ([self isDisplayingContacts]) {
    
    NSArray *contacts = [self sortedContactEntries];
    int rowIndex = [mFeedTable selectedRow];
    if ([contacts count] > rowIndex) {
      
      GDataEntryContact *contact = [contacts objectAtIndex:rowIndex];
      return contact;
    }
  }
  return nil;
}

// get the contact or group selected in the top list, or nil if none 
- (GDataEntryContactGroup *)selectedGroup {
  
  if (![self isDisplayingContacts]) {
    
    NSArray *groups = [self sortedGroupEntries];
    int rowIndex = [mFeedTable selectedRow];
    if ([groups count] > rowIndex) {
      
      GDataEntryContactGroup *group = [groups objectAtIndex:rowIndex];
      return group;
    }
  }
  return nil;
}

- (id)selectedContactOrGroup {
  GDataEntryContact *selectedContact = [self selectedContact];
  if (selectedContact) return selectedContact;
  
  GDataEntryContactGroup *selectedGroup = [self selectedGroup];
  return selectedGroup;
}

// get the item selected in the bottom list, or nil if none
//
// the item could be org, phone, e-mail, IM, postal, group, or extended props
- (GDataObject *)selectedItem {
  
  NSArray *entries = [self itemsForSelectedSegment];
  
  int rowIndex = [mEntryTable selectedRow];
  if ([entries count] > rowIndex) {
    
    GDataObject *entry = [entries objectAtIndex:rowIndex];
    return entry;
  }
  return nil;  
}

// get the key needed to retrieve the list of items from a contact
- (NSString *)keyForSelectedSegment {
  
  switch ([mEntrySegmentedControl selectedSegment]) {
    case kOrganizationSegment:  return @"organizations";
    case kEmailSegment:         return @"emailAddresses";
    case kPhoneSegment:         return @"phoneNumbers";
    case kPostalSegment:        return @"structuredPostalAddresses";
    case kIMSegment:            return @"IMAddresses";
    case kGroupSegment:         return @"groupMembershipInfos";
    case kExtendedPropsSegment: return @"extendedProperties";
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
    case kPostalSegment:       return @selector(setPrimaryStructuredPostalAddress:);
  }  
  return nil;
}

// get the list of items from the selected contact, according to the segmented
// control's selection
- (NSArray *)itemsForSelectedSegment {
  
  NSString *path = [self keyForSelectedSegment];
  SEL sel = NSSelectorFromString(path);
  
  id selectedEntry = [self selectedContactOrGroup];
  
  // some segment selectors don't apply to group entries
  NSArray *array = nil;
  
  if ([selectedEntry respondsToSelector:sel]) {
    array = [selectedEntry performSelector:sel];
  }
  
  return array;
}

- (Class)itemClassForSelectedSegment {
  
  switch ([mEntrySegmentedControl selectedSegment]) {
    case kOrganizationSegment:  return [GDataOrganization class];
    case kEmailSegment:         return [GDataEmail class];
    case kPhoneSegment:         return [GDataPhoneNumber class];
    case kPostalSegment:        return [GDataStructuredPostalAddress class];
    case kIMSegment:            return [GDataIM class];
    case kGroupSegment:         return [GDataGroupMembershipInfo class];
    case kExtendedPropsSegment: return [GDataExtendedProperty class];
  }
  return nil;
}

#pragma mark Fetch all groups

- (NSURL *)groupFeedURL {
  
  NSString *propName = [mPropertyNameField stringValue];
  
  NSURL *feedURL;
  if ([propName caseInsensitiveCompare:@"full"] == NSOrderedSame
      || [propName length] == 0) {
    
    // full feed includes all clients' extended properties
    feedURL = [GDataServiceGoogleContact groupFeedURLForUserID:kGDataServiceDefaultUser];
    
  } else if ([propName caseInsensitiveCompare:@"thin"] == NSOrderedSame) {
    
    // thin feed excludes extended properties
    feedURL = [GDataServiceGoogleContact contactURLForFeedName:kGDataGoogleContactGroupsFeedName
                                                        userID:kGDataServiceDefaultUser
                                                    projection:kGDataGoogleContactThinProjection];
    
  } else {
    
    feedURL = [GDataServiceGoogleContact contactGroupFeedURLForPropertyName:propName];
  }
  return feedURL;
}

// begin retrieving the list of the user's contacts
- (void)fetchAllGroupsAndContacts {
  
  [self setGroupFeed:nil];
  [self setGroupFetchError:nil];
  [self setGroupFetchTicket:nil];
  
  // we will fetch contacts next
  [self setContactFeed:nil];

  GDataServiceGoogleContact *service = [self contactService];
  GDataServiceTicket *ticket;
  
  BOOL showDeleted = ([mShowDeletedCheckbox state] == NSOnState);
  
  // request a whole buncha groups; our service object is set to
  // follow next links as well in case there are more than 2000
  const int kBuncha = 2000;
  
  NSURL *feedURL = [self groupFeedURL];
  
  GDataQueryContact *query = [GDataQueryContact contactQueryWithFeedURL:feedURL];
  [query setShouldShowDeleted:showDeleted];
  [query setMaxResults:kBuncha];
  
  ticket = [service fetchFeedWithQuery:query
                              delegate:self
                     didFinishSelector:@selector(groupsFetchTicket:finishedWithFeed:error:)];
  
  [self setGroupFetchTicket:ticket];
  
  [self updateUI];
}

// groups fetched callback
- (void)groupsFetchTicket:(GDataServiceTicket *)ticket
         finishedWithFeed:(GDataFeedContactGroup *)feed
                    error:(NSError *)error {

  [self setGroupFeed:feed];
  [self setGroupFetchError:error];
  [self setGroupFetchTicket:nil];

  if (error == nil) {
    // we have the groups; now get the contacts
    [self fetchAllContacts];
  } else {
    // error fetching groups
    [self updateUI];
  }
}

#pragma mark Fetch all contacts

- (NSURL *)contactFeedURL {
  
  NSString *propName = [mPropertyNameField stringValue];
  
  NSURL *feedURL;
  if ([propName caseInsensitiveCompare:@"full"] == NSOrderedSame
      || [propName length] == 0) {
    
    // full feed includes all clients' extended properties
    feedURL = [GDataServiceGoogleContact contactFeedURLForUserID:kGDataServiceDefaultUser];
    
  } else if ([propName caseInsensitiveCompare:@"thin"] == NSOrderedSame) {
    
    // thin feed excludes all extended properties
    feedURL = [GDataServiceGoogleContact contactFeedURLForUserID:kGDataServiceDefaultUser
                                                      projection:kGDataGoogleContactThinProjection];
  } else {
    
    feedURL = [GDataServiceGoogleContact contactFeedURLForPropertyName:propName];
  }
  return feedURL;
}

// begin retrieving the list of the user's contacts
- (void)fetchAllContacts {

  [self setContactFeed:nil];
  [self setContactFetchError:nil];
  [self setContactFetchTicket:nil];

  GDataServiceGoogleContact *service = [self contactService];
  GDataServiceTicket *ticket;

  BOOL shouldShowDeleted = ([mShowDeletedCheckbox state] == NSOnState);
  BOOL shouldQueryMyContacts = ([mMyContactsCheckbox state] == NSOnState);

  // request a whole buncha contacts; our service object is set to
  // follow next links as well in case there are more than 2000
  const int kBuncha = 2000;

  NSURL *feedURL = [self contactFeedURL];

  GDataQueryContact *query = [GDataQueryContact contactQueryWithFeedURL:feedURL];
  [query setShouldShowDeleted:shouldShowDeleted];
  [query setMaxResults:kBuncha];

  if (shouldQueryMyContacts) {

    GDataFeedContactGroup *groupFeed = [self groupFeed];
    GDataEntryContactGroup *myContactsGroup
      = [groupFeed entryForSystemGroupID:kGDataSystemGroupIDMyContacts];

    NSString *myContactsGroupID = [myContactsGroup identifier];

    [query setGroupIdentifier:myContactsGroupID];
  }

  ticket = [service fetchFeedWithQuery:query
                              delegate:self
                     didFinishSelector:@selector(contactsFetchTicket:finishedWithFeed:error:)];

  [self setContactFetchTicket:ticket];

  [self updateUI];
}

// contacts fetched callback
- (void)contactsFetchTicket:(GDataServiceTicket *)ticket
           finishedWithFeed:(GDataFeedContact *)feed
                      error:(NSError *)error {

  [self setContactFeed:feed];
  [self setContactFetchError:error];
  [self setContactFetchTicket:nil];

  [self updateUI];
}

#pragma mark Set contact image

- (void)setContactImage {
  
  // ask the user to choose an image file
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setPrompt:@"Set"];
  [openPanel beginSheetForDirectory:nil
                               file:nil
                              types:[NSImage imageFileTypes]
                     modalForWindow:[self window]
                      modalDelegate:self
                     didEndSelector:@selector(openSheetDidEnd:returnCode:contextInfo:)
                        contextInfo:nil];
}

- (void)openSheetDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo {
  
  if (returnCode == NSOKButton) {
    // user chose a photo and clicked OK
    //
    // start uploading (deferred to the main thread since we currently have
    // a sheet displayed)
    [self performSelectorOnMainThread:@selector(setSelectedContactPhotoAtPath:)
                           withObject:[panel filename]
                        waitUntilDone:NO];
  }
}

- (void)setSelectedContactPhotoAtPath:(NSString *)path {
  
  NSString *errorMsg = nil;
  
  // make a new entry for the file
  NSString *mimeType = [GDataUtilities MIMETypeForFileAtPath:path
                                             defaultMIMEType:@"image/jpeg"];
  if (!mimeType) {
    errorMsg = [NSString stringWithFormat:@"need MIME type for file %@", path];
  } else {
    
    NSString *fullName = [[NSFileManager defaultManager] displayNameAtPath:path];

    GDataEntryContact *newEntry = [GDataEntryContact contactEntryWithFullNameString:fullName];

    NSData *uploadData = [NSData dataWithContentsOfFile:path];
    if (!uploadData) {
      errorMsg = [NSString stringWithFormat:@"cannot read file %@", path];
    } else {
      GDataLink *photoLink = [[self selectedContact] photoLink];

      [newEntry setShouldUploadDataOnly:YES];
      [newEntry setUploadData:uploadData];
      [newEntry setUploadMIMEType:mimeType];
      [newEntry setUploadSlug:[path lastPathComponent]];

      // provide the ETag of the photo we are replacing, if any
      [newEntry setETag:[photoLink ETag]];

      NSURL *putURL = [photoLink URL];
      
      // make service tickets call back into our upload progress selector
      GDataServiceGoogleContact *service = [self contactService];
      
      SEL progressSel = @selector(ticket:hasDeliveredByteCount:ofTotalByteCount:);
      [service setServiceUploadProgressSelector:progressSel];
      
      // insert the entry into the contacts feed
      GDataServiceTicket *ticket;
      ticket = [service fetchEntryByUpdatingEntry:newEntry
                                      forEntryURL:putURL
                                         delegate:self
                                didFinishSelector:@selector(uploadPhotoTicket:finishedWithEntry:error:)];
      
      // we don't want future tickets to always use the upload progress selector
      [service setServiceUploadProgressSelector:nil];
    }
  }
  
  if (errorMsg) {
    NSBeginAlertSheet(@"Upload Error", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"%@", errorMsg);
  }
  
  [self updateUI];
}

// progress callback
- (void)ticket:(GDataServiceTicket *)ticket
hasDeliveredByteCount:(unsigned long long)numberOfBytesRead 
   ofTotalByteCount:(unsigned long long)dataLength {
  
  [mSetContactImageProgressIndicator setMinValue:0.0];
  [mSetContactImageProgressIndicator setMaxValue:(double)dataLength];
  [mSetContactImageProgressIndicator setDoubleValue:(double)numberOfBytesRead];
}

// finished callback
- (void)uploadPhotoTicket:(GDataServiceTicket *)ticket
        finishedWithEntry:(GDataEntryBase *)entry
                    error:(NSError *)error {

  [mSetContactImageProgressIndicator setDoubleValue:0.0];
  [self updateUI];

  if (error == nil) {
    // refetch the current contact list
    [self fetchAllGroupsAndContacts];

    // tell the user that the add worked
    NSBeginAlertSheet(@"Uploaded photo", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Photo uploaded");
  } else {
    // error uploading photo
    NSBeginAlertSheet(@"Upload failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Photo upload failed: %@", error);
  }
}

#pragma mark Delete contact image

- (void)deleteContactImage {
  
  // display the confirmation dialog
  GDataEntryContact *contact = [self selectedContact];
  if (contact) {
    
    // make the user confirm that the selected contact should be deleted
    NSBeginAlertSheet(@"Delete Image", @"Delete", @"Cancel", nil,
                      [self window], self, 
                      @selector(contactPhotoDeleteSheetDidEnd:returnCode:contextInfo:),
                      nil, nil, @"Delete photo for contact \"%@\"?",
                      [contact entryDisplayName]);
  }
}


- (void)contactPhotoDeleteSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
  
  if (returnCode == NSAlertDefaultReturn) {
    
    // delete the contact's photo
    
    GDataServiceGoogleContact *service = [self contactService];
    
    GDataLink *photoLink = [[self selectedContact] photoLink];

    NSURL *editURL = [photoLink URL];
    NSString *etag = [photoLink ETag];
    
    [service deleteResourceURL:editURL
                          ETag:etag
                      delegate:self
             didFinishSelector:@selector(deletePhotoTicket:finishedWithNil:error:)];
  }
}

// delete photo callback
- (void)deletePhotoTicket:(GDataServiceTicket *)ticket
          finishedWithNil:(GDataObject *)obj
                    error:(NSError *)error {
  if (error == nil) {
    // photo deleted
    NSBeginAlertSheet(@"Deleted photo", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Photo deleted");

    // refetch the current contact list
    [self fetchAllGroupsAndContacts];
    [self updateUI];
  } else {
    // failed
    NSBeginAlertSheet(@"Delete photo failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Photo delete failed: %@", error);
  }
}

#pragma mark Add a Contact

- (void)addAContact {
  
  NSString *title = [mAddTitleField stringValue];
  NSString *email = [mAddEmailField stringValue];
  
  if ([title length] > 0) {
    
    GDataEntryContact *newContact;
    newContact = [GDataEntryContact contactEntryWithFullNameString:title];
    
    if ([email length] > 0) {
      // all items must have a rel or a label, but not both
      GDataEmail *emailObj = [GDataEmail emailWithLabel:nil
                                                address:email];
      [emailObj setRel:kGDataContactOther];
      [emailObj setIsPrimary:YES];

      [newContact addEmailAddress:emailObj];
    }

    if ([mMyContactsCheckbox state] == NSOnState) {
      // add this to the MyContacts group too
      GDataFeedContactGroup *groupFeed = [self groupFeed];
      GDataEntryContactGroup *myContactsGroup
        = [groupFeed entryForSystemGroupID:kGDataSystemGroupIDMyContacts];

      NSString *myContactsGroupID = [myContactsGroup identifier];

      GDataGroupMembershipInfo *groupInfo
        = [GDataGroupMembershipInfo groupMembershipInfoWithHref:myContactsGroupID];

      [newContact addGroupMembershipInfo:groupInfo];
    }

    GDataServiceGoogleContact *service = [self contactService];
   
    NSURL *postURL = [[mContactFeed postLink] URL];
    
    [service fetchEntryByInsertingEntry:newContact
                             forFeedURL:postURL
                               delegate:self
                      didFinishSelector:@selector(addContactTicket:addedEntry:error:)];
  }
}

// add contact callback
- (void)addContactTicket:(GDataServiceTicket *)ticket
              addedEntry:(GDataEntryContact *)object
                   error:(NSError *)error {
  if (error == nil) {
    // tell the user that the add worked
    NSBeginAlertSheet(@"Added contact", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Contact added");

    [mAddTitleField setStringValue:@""];
    [mAddEmailField setStringValue:@""];

    // refetch the current contacts
    [self fetchAllGroupsAndContacts];
    [self updateUI];
  } else {
    // failure to add contact
    NSBeginAlertSheet(@"Add failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Contact add failed: %@", error);
  }
}

#pragma mark Add a Group

- (void)addAGroup {
  
  NSString *title = [mAddTitleField stringValue];
  
  if ([title length] > 0) {
    
    GDataEntryContactGroup *newGroup;
    newGroup = [GDataEntryContactGroup contactGroupEntryWithTitle:title];
    
    GDataServiceGoogleContact *service = [self contactService];
    
    NSURL *postURL = [[mGroupFeed postLink] URL];
    
    [service fetchEntryByInsertingEntry:newGroup
                             forFeedURL:postURL
                               delegate:self
                      didFinishSelector:@selector(addGroupTicket:addedEntry:error:)];
  }
}

// add group callback
- (void)addGroupTicket:(GDataServiceTicket *)ticket
            addedEntry:(GDataEntryContactGroup *)object
                 error:(NSError *)error {
  if (error == nil) {
    // tell the user that the add worked
    NSBeginAlertSheet(@"Added group", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Group added");

    [mAddTitleField setStringValue:@""];
    [mAddEmailField setStringValue:@""];

    // refetch the current groups
    [self fetchAllGroupsAndContacts];
    [self updateUI];
  } else {
    // failure to add group
    NSBeginAlertSheet(@"Add failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Group add failed: %@", error);
  }
}

#pragma mark Delete a Contact or Group

- (void)deleteSelectedContactOrGroup {
  
  // display the confirmation dialog
  id entry = [self selectedContactOrGroup];
  if (entry) {
    
    // make the user confirm that the selected entry should be deleted
    NSBeginAlertSheet(@"Delete", @"Delete", @"Cancel", nil,
                      [self window], self, 
                      @selector(entryDeleteSheetDidEnd:returnCode:contextInfo:),
                      nil, nil, @"Delete \"%@\"?",
                      [entry entryDisplayName]);
  }
}

// delete dialog callback
- (void)entryDeleteSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
  
  if (returnCode == NSAlertDefaultReturn) {
    
    // delete the entry
    
    GDataServiceGoogleContact *service = [self contactService];
    
    id entry = [self selectedContactOrGroup];
    
    [service deleteEntry:entry
                delegate:self
       didFinishSelector:@selector(deleteEntryTicket:finishedWithNil:error:)];
  }
}

// delete entry callback
- (void)deleteEntryTicket:(GDataServiceTicket *)ticket
          finishedWithNil:(id)object
                    error:(NSError *)error {

  if (error == nil) {
    NSBeginAlertSheet(@"Deleted", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Entry deleted");
    [self fetchAllGroupsAndContacts];
    [self updateUI];
  } else {
    NSBeginAlertSheet(@"Delete failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Entry delete failed: %@", error);
  }
}

#pragma mark Batch Delete All Contacts or Groups

- (void)deleteAllContactsOrGroups {
  
  // make the user confirm that all entries should be deleted
  GDataFeedBase *feed;
  
  if ([self isDisplayingContacts]) {
    feed = mContactFeed;
  } else {
    feed = mGroupFeed;
  }
  
  NSBeginAlertSheet(@"Delete All", @"Delete", @"Cancel", nil,
                    [self window], self, 
                    @selector(deleteAllSheetDidEnd:returnCode:contextInfo:),
                    nil, nil, @"Delete %u %@?",
                    [[feed entries] count],
                    [self isDisplayingContacts] ? @"contacts" : @"groups");
}

NSString* const kBatchTicketsProperty = @"BatchTickets";
NSString* const kBatchResultsProperty = @"BatchResults";

// delete dialog callback
- (void)deleteAllSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
  
  if (returnCode == NSAlertDefaultReturn) {
    
    // delete the feed entries
    GDataFeedBase *feed;
    if ([self isDisplayingContacts]) {
      feed = mContactFeed;
    } else {
      feed = mGroupFeed;
    }
    
    NSArray *entries = [feed entries];
    
    NSURL *batchURL = [[feed batchLink] URL];
    if (batchURL == nil) {
      // the button shouldn't be enabled when we can't batch delete, so we
      // shouldn't get here
      NSBeep();
      
    } else {
      
      // the contacts feed supports batch size up to 100 entries
      const int kMaxBatchSize = 100;
      
      // allocate arrays that will be used by the callback when each
      // ticket finishes
      NSMutableArray *batchTickets = [NSMutableArray array];
      NSMutableArray *batchResults = [NSMutableArray array];
      
      unsigned int totalEntries = [entries count];
      
      for (unsigned int idx = 0; idx < totalEntries; idx++) {
        
        GDataEntryBase *entry = [entries objectAtIndex:idx];
        
        // add a batch ID to this entry
        static int staticID = 0;
        NSString *batchID = [NSString stringWithFormat:@"batchID_%u", ++staticID];
        [entry setBatchIDWithString:batchID];

        // we don't need to add the batch operation to the entries since
        // we're putting it in the feed to apply to all entries
        
        // we could force an error on an item by nuking the entry's identifier, 
        // like
        //   if (idx == 1) { [entry setIdentifier:nil]; }
        
        // send a batch when we've seen every entry, or when the batch size
        // has reached 100
        if (((idx + 1) % kMaxBatchSize) == 0
            || (idx + 1) == totalEntries) {
          
          // make a batch feed object: add entries to the feed, and since
          // we are doing the same operation for all entries in the feed, 
          // add the operation to the feed
          
          GDataFeedContact *batchFeed = [GDataFeedContact contactFeed];

          unsigned int rangeStart = idx - (idx % kMaxBatchSize);
          NSRange batchEntryRange = NSMakeRange(rangeStart, 
                                                idx - rangeStart + 1);
          NSArray *entrySubset = [entries subarrayWithRange:batchEntryRange];
          [batchFeed setEntriesWithEntries:entrySubset];
          
          GDataBatchOperation *op;
          op = [GDataBatchOperation batchOperationWithType:kGDataBatchOperationDelete];
          [batchFeed setBatchOperation:op];    
          
          // now do the usual steps for authenticating for this service, and issue
          // the fetch
          
          GDataServiceGoogleContact *service = [self contactService];
          GDataServiceTicket *ticket;
          
          ticket = [service fetchFeedWithBatchFeed:batchFeed
                                   forBatchFeedURL:batchURL
                                          delegate:self
                                 didFinishSelector:@selector(batchDeleteTicket:finishedWithFeed:error:)];
          
          [batchTickets addObject:ticket];
          
          // set the arrays used by the callback into the ticket properties
          [ticket setProperty:batchTickets forKey:kBatchTicketsProperty];
          [ticket setProperty:batchResults forKey:kBatchResultsProperty];
        }
      }
    }
  }
}

// batch delete callback
- (void)batchDeleteTicket:(GDataServiceTicket *)ticket
         finishedWithFeed:(GDataFeedBase *)feed
                    error:(NSError *)error {

  NSMutableArray *batchTickets = [ticket propertyForKey:kBatchTicketsProperty];

  if (error == nil) {
    NSMutableArray *batchResults = [ticket propertyForKey:kBatchResultsProperty];

    [batchResults addObjectsFromArray:[feed entries]];
    [batchTickets removeObject:ticket];

    if ([batchTickets count] > 0) {
      // more tickets are outstanding; let them complete
      return;
    }

    // step through all the entries in the response feed,
    // and build a string reporting each result

    // show the http status to start (should be 200)
    NSString *template = @"http status:%d\n\n";
    NSMutableString *reportStr = [NSMutableString stringWithFormat:template,
                                  [ticket statusCode]];

    for (int idx = 0; idx < [batchResults count]; idx++) {

      GDataEntryGoogleBase *entry = [batchResults objectAtIndex:idx];
      GDataBatchID *batchID = [entry batchID];

      // report the batch ID and status for each item
      [reportStr appendFormat:@"%@\n", [batchID stringValue]];

      GDataBatchInterrupted *interrupted = [entry batchInterrupted];
      if (interrupted) {
        [reportStr appendFormat:@"%@\n", [interrupted description]];
      }

      GDataBatchStatus *status = [entry batchStatus];
      if (status) {
        [reportStr appendFormat:@"%d %@\n",
         [[status code] intValue], [status reason]];
      }
      [reportStr appendString:@"\n"];
    }

    NSBeginAlertSheet(@"Delete completed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Delete All completed.\n%@", reportStr);

    [self fetchAllGroupsAndContacts];
    [self updateUI];
  } else {
    // batch delete failed
    [batchTickets removeObject:ticket];

    NSBeginAlertSheet(@"Delete failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Batch delete failed: %@", error);
  }
}

#pragma mark Add an Item

- (void)addAnItem {
  
  // make a new object for the selected segment type
  // (org, phone, postal, IM, group, e-mail, extended props)
  Class objClass = [self itemClassForSelectedSegment];
  id obj = [[[objClass alloc] init] autorelease];
  
  if ([obj respondsToSelector:@selector(setRel:)]) {
    // each item needs a rel or a label; we'll use other as a default rel
    [obj setRel:kGDataContactOther];
  }
  
  // display the item edit dialog
  EditEntryWindowController *controller = [[EditEntryWindowController alloc] init];
  [controller runModalForTarget:self
                       selector:@selector(addEditControllerFinished:)
                      groupFeed:mGroupFeed
                         object:obj];
}

// callback from the edit item dialog
- (void)addEditControllerFinished:(EditEntryWindowController *)addEntryController {
  
  if ([addEntryController wasSaveClicked]) {
    
    // add the object into a copy of the selected entry, 
    // and update the contact
    GDataObject *obj = [addEntryController object];
    if (obj) {
      
      // make a new array of items with the addition added to it
      NSArray *oldItems = [self itemsForSelectedSegment];
      NSMutableArray *newItems = [NSMutableArray arrayWithArray:oldItems];
      [newItems addObject:obj];
      
      // replace the entry's item array with our new one
      NSString *keyForSelectedSegment = [self keyForSelectedSegment];
      
      id selectedEntryCopy = [[[self selectedContactOrGroup] copy] autorelease];
      [selectedEntryCopy setValue:newItems forKey:keyForSelectedSegment];
      
      // now update the entry on the server
      GDataServiceGoogleContact *service = [self contactService];
      
      [service fetchEntryByUpdatingEntry:selectedEntryCopy
                                       delegate:self
                              didFinishSelector:@selector(addItemTicket:addedEntry:error:)];
    }
  }
  [addEntryController autorelease];
}

// add item callback
- (void)addItemTicket:(GDataServiceTicket *)ticket
           addedEntry:(GDataEntryContact *)object
                error:(NSError *)error {
  if (error == nil) {
    // tell the user that the add worked
    NSBeginAlertSheet(@"Added item", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Item added");

    // refetch the current contact's items
    [self fetchAllGroupsAndContacts];
    [self updateUI];
  } else {
    NSBeginAlertSheet(@"Add failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Item add failed: %@\nUser info: %@",
                      error, [error userInfo]);
  }
}

#pragma mark Edit an item

- (void)editSelectedItem {
  
  // display the item edit dialog
  GDataObject *item = [self selectedItem];
  if (item) {
    EditEntryWindowController *controller = [[EditEntryWindowController alloc] init];
    [controller runModalForTarget:self
                         selector:@selector(editControllerFinished:)
                        groupFeed:mGroupFeed
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
      
      // replace the entry's item array with our new one
      NSString *keyForSelectedSegment = [self keyForSelectedSegment];
      
      id selectedEntryCopy = [[[self selectedContactOrGroup] copy] autorelease];
      [selectedEntryCopy setValue:newItems forKey:keyForSelectedSegment];
      
      // now update the entry on the server
      GDataServiceGoogleContact *service = [self contactService];
      
      [service fetchEntryByUpdatingEntry:selectedEntryCopy
                                delegate:self
                       didFinishSelector:@selector(editItemTicket:editedEntry:error:)];
    }
  }
  [editContactController autorelease];
}

// edit item callback
- (void)editItemTicket:(GDataServiceTicket *)ticket
           editedEntry:(GDataEntryContact *)object
                 error:(NSError *)error {
  if (error == nil) {
    // tell the user that the update worked
    NSBeginAlertSheet(@"Updated Entry", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Entry updated");

    // re-fetch the selected contact's items
    [self fetchAllGroupsAndContacts];
    [self updateUI];
  } else {
    NSBeginAlertSheet(@"Update failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Entry update failed: %@", error);
  }
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
                      [self displayNameForItem:item]);
  }
}

// delete dialog callback
- (void)itemDeleteSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
  
  if (returnCode == NSAlertDefaultReturn) {
    
    // delete the item from the contact's item array
    
    NSArray *oldItems = [self itemsForSelectedSegment];
    NSMutableArray *newItems = [NSMutableArray arrayWithArray:oldItems];
    
    // using removeObject would remove all matching items; we just want to
    // remove the selected one
    [newItems removeObjectAtIndex:[mEntryTable selectedRow]];
    
    // replace the contact's item array with our new one
    NSString *keyForSelectedSegment = [self keyForSelectedSegment];
    
    GDataEntryContact *selectedContact = [self selectedContactOrGroup];
    [selectedContact setValue:newItems forKey:keyForSelectedSegment];
    
    // now update the contact on the server
    GDataServiceGoogleContact *service = [self contactService];
    
    [service fetchEntryByUpdatingEntry:selectedContact
                              delegate:self
                     didFinishSelector:@selector(deleteItemTicket:updatedEntry:error:)];
  }
}

// delete item callback
- (void)deleteItemTicket:(GDataServiceTicket *)ticket
            updatedEntry:(GDataEntryContact *)object
                   error:(NSError *)error {
  if (error == nil) {
    NSBeginAlertSheet(@"Deleted item", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Item deleted");

    // re-fetch the selected contact's items
    [self fetchAllGroupsAndContacts];
    [self updateUI];
  } else {
    NSBeginAlertSheet(@"Delete failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Item delete failed: %@", error);
  }
}

#pragma mark Make selected item primary

- (void)makeSelectedItemPrimary {
  
  GDataObject *item = [self selectedItem];
  GDataEntryContact *selectedContactCopy = [[[self selectedContact] copy] autorelease];
  
  SEL sel = [self makePrimarySelectorForSelectedSegment];
  [selectedContactCopy performSelector:sel withObject:item];
  
  // now update the contact on the server
  GDataServiceGoogleContact *service = [self contactService];  

  GDataServiceTicket *ticket =
    [service fetchEntryByUpdatingEntry:selectedContactCopy
                              delegate:self
                     didFinishSelector:@selector(makePrimaryTicket:finishedWithEntry:error:)];
  [ticket setUserData:item];
}

// make primary item callback
- (void)makePrimaryTicket:(GDataServiceTicket *)ticket
        finishedWithEntry:(GDataEntryContact *)entry
                    error:(NSError *)error {
  if (error == nil) {
    NSBeginAlertSheet(@"Made primary", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Item made primary: %@",
                      [self displayNameForItem:[ticket userData]]);

    // re-fetch the selected contact's items
    [self fetchAllGroupsAndContacts];
    [self updateUI];
  } else {
    NSBeginAlertSheet(@"Make primary failed", nil, nil, nil,
                      [self window], nil, nil,
                      nil, nil, @"Could not make item primary: %@", error);
  }
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
  if (tableView == mFeedTable) {
    
    // contact and group table
    if ([self isDisplayingContacts]) {
      return [[mContactFeed entries] count];
    } else {
      return [[mGroupFeed entries] count];
    }
    
  } else {
    // entry table
    unsigned int count = [[self itemsForSelectedSegment] count];
    return count;
  }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
  if (tableView == mFeedTable) {
    
    // contact and group table
    if ([self isDisplayingContacts]) {
      GDataEntryContact *contact = [[self sortedContactEntries] objectAtIndex:row];
      if (contact) {
        return [contact entryDisplayName];
      }
    } else {
      GDataEntryContactGroup *group = [[self sortedGroupEntries] objectAtIndex:row];
      if (group) {
        return [group entryDisplayName];
      }
    }
    
  } else {
    // item table, displaying according to the segment selected
    
    NSString *output = nil;
    
    NSArray *items = [self itemsForSelectedSegment];
    if ([items count] > row) {
      id obj = [items objectAtIndex:row];
      
      output = [self displayNameForItem:obj];
      
      if (output != nil
          && [obj respondsToSelector:@selector(isPrimary)] && [obj isPrimary]) {
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
    result = (NSString *) [item address];
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
  
  // extended property has value or XMLValue, which we unified via a category
  else if ([item respondsToSelector:@selector(unifiedStringValue)]) {    
    result = [item unifiedStringValue];
  }
  
  // groupMembershipInfo responds to href
  else if ([item respondsToSelector:@selector(href)]) {
    NSString *groupID = [item href];
    GDataEntryContactGroup *groupEntry = [mGroupFeed entryForIdentifier:groupID];
    if (groupEntry) {
      result = [groupEntry entryDisplayName];
    } else {
      // the group listed isn't in the group feed, so we can't display its
      // name
      if ([groupEntry isDeleted]) {
        // show an X by the group ID when it's deleted
        result = [NSString stringWithFormat:@"%C %@", kBallotX, groupID];
      } else {
        result = groupID;
      }
    }
  }
  
  // structuredPostAddress responds to formattedAddress
  else if ([item respondsToSelector:@selector(formattedAddress)]) {
    NSMutableString *mutable = [NSMutableString stringWithString:[item formattedAddress]];
    
    // make the return character visible 
    NSString *returnChar = [NSString stringWithUTF8String:"\n"];
    NSString *returnSymbol = [NSString stringWithFormat:@"%C", 0x23CE];
    [mutable replaceOccurrencesOfString:returnChar 
                             withString:returnSymbol
                                options:0
                                  range:NSMakeRange(0, [mutable length])];
    result = mutable;
  }
  
  // phone has a stringValue method
  else {
    result = [item stringValue];
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

- (NSString *)contactImageETag {
  return mContactImageETag;
}

- (void)setContactImageETag:(NSString *)str {
  [mContactImageETag autorelease];
  mContactImageETag = [str copy];
}


- (GDataFeedContactGroup *)groupFeed {
  return mGroupFeed; 
}

- (void)setGroupFeed:(GDataFeedContactGroup *)feed {
  [mGroupFeed autorelease];
  mGroupFeed = [feed retain];
}

- (NSError *)groupFetchError {
  return mGroupFetchError; 
}

- (void)setGroupFetchError:(NSError *)error {
  [mGroupFetchError release];
  mGroupFetchError = [error retain];
}

- (GDataServiceTicket *)groupFetchTicket {
  return mGroupFetchTicket; 
}

- (void)setGroupFetchTicket:(GDataServiceTicket *)ticket {
  [mGroupFetchTicket release];
  mGroupFetchTicket = [ticket retain];
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
    title = [NSString stringWithFormat:@"%C %@", kBallotX, [self identifier]];
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

@implementation GDataEntryContactGroup (ContactsSampleAdditions)

- (NSString *)entryDisplayName {
  
  NSString *title;
  
  if ([self isDeleted]) {
    title = [NSString stringWithFormat:@"%C %@", kBallotX, [self identifier]];
  } else {  
    
    title = [[self title] stringValue];
  }
  
  return title;
}

@end
