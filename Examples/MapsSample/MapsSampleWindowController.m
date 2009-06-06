/* Copyright (c) 2009 Google Inc.
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
//  MapSampleWindowController.m
//

#import "MapsSampleWindowController.h"

@interface MapsSampleWindowController (PrivateMethods)
- (void)updateUI;

- (void)fetchFeedOfMaps;
- (void)fetchFeaturesOfSelectedMap;

- (void)addAMap;
- (void)renameSelectedMap;
- (void)deleteSelectedMap;

- (void)addFeatureToSelectedMap;
- (void)renameSelectedFeature;
- (void)deleteSelectedFeature;

- (GDataServiceGoogleMaps *)mapService;
- (GDataEntryMap *)selectedMap;
- (GDataEntryMapFeature *)selectedFeature;


- (GDataFeedMap *)mapFeed;
- (void)setMapFeed:(GDataFeedMap *)feed;
- (NSError *)mapFetchError;
- (void)setMapFetchError:(NSError *)error;
- (GDataServiceTicket *)mapFeedTicket;
- (void)setMapFeedTicket:(GDataServiceTicket *)obj;

- (GDataServiceTicket *)mapEditTicket;
- (void)setMapEditTicket:(GDataServiceTicket *)obj;

- (GDataFeedMapFeature *)featureFeed;
- (void)setFeatureFeed:(GDataFeedMapFeature *)feed;
- (NSError *)featureFetchError;
- (void)setFeatureFetchError:(NSError *)error;
- (GDataServiceTicket *)featureFeedTicket;
- (void)setFeatureFeedTicket:(GDataServiceTicket *)obj;

- (GDataServiceTicket *)featureEditTicket;
- (void)setFeatureEditTicket:(GDataServiceTicket *)obj;

@end

@implementation MapsSampleWindowController

+ (MapsSampleWindowController *)sharedWindowController {

  static MapsSampleWindowController* gWindowController = nil;

  if (!gWindowController) {
    gWindowController = [[MapsSampleWindowController alloc] init];
  }
  return gWindowController;
}


- (id)init {
  return [self initWithWindowNibName:@"MapsSampleWindow"];
}

- (void)windowDidLoad {
}

- (void)awakeFromNib {
  // Set the result text fields to have a distinctive color and mono-spaced font
  [mMapResultTextField setTextColor:[NSColor darkGrayColor]];
  [mFeatureResultTextField setTextColor:[NSColor darkGrayColor]];

  NSFont *resultTextFont = [NSFont fontWithName:@"Monaco" size:9];
  [mMapResultTextField setFont:resultTextFont];
  [mFeatureResultTextField setFont:resultTextFont];

  [self updateUI];
}

- (void)dealloc {

  [mMapFeed release];
  [mMapFeedTicket release];
  [mMapFetchError release];

  [mMapEditTicket release];

  [mFeatureFeed release];
  [mFeatureFeedTicket release];
  [mFeatureFetchError release];

  [mFeatureEditTicket release];

  [super dealloc];
}

#pragma mark -

- (void)updateUI {

  // map list display
  [mMapTable reloadData];

  if (mMapFeedTicket != nil || mMapEditTicket != nil) {
    [mMapProgressIndicator startAnimation:self];
  } else {
    [mMapProgressIndicator stopAnimation:self];
  }

  // map fetch result or selected item
  NSString *resultStr = @"";
  if (mMapFetchError) {
    resultStr = [mMapFetchError description];
  } else {
    GDataEntryMap *map = [self selectedMap];
    if (map) {
      resultStr = [map description];
    }
  }
  [mMapResultTextField setString:resultStr];

  // enable map edit buttons
  BOOL isMapSelected = ([self selectedMap] != nil);
  BOOL isMapNamePresent = ([[mMapNameField stringValue] length] > 0);

  [mAddMapButton setEnabled:isMapNamePresent];
  [mRenameMapButton setEnabled:(isMapSelected && isMapNamePresent)];
  [mDeleteMapButton setEnabled:isMapSelected];

  // features list display
  [mFeatureTable reloadData];

  if (mFeatureFeedTicket != nil || mFeatureEditTicket != nil) {
    [mFeatureProgressIndicator startAnimation:self];
  } else {
    [mFeatureProgressIndicator stopAnimation:self];
  }

  // feature fetch result or selected item
  resultStr = @"";
  if (mFeatureFetchError) {
    resultStr = [mFeatureFetchError description];
  } else {
    GDataEntryMapFeature *feature = [self selectedFeature];
    if (feature) {
      resultStr = [feature description];
    }
  }
  [mFeatureResultTextField setString:resultStr];

  // enable feature edit buttons
  BOOL isFeatureSelected = ([self selectedFeature] != nil);
  BOOL isFeatureNamePresent = ([[mFeatureNameField stringValue] length] > 0);

  [mAddFeatureButton setEnabled:isFeatureNamePresent];
  [mRenameFeatureButton setEnabled:(isFeatureSelected && isFeatureNamePresent)];
  [mDeleteFeatureButton setEnabled:isFeatureSelected];
}

#pragma mark IBActions

- (IBAction)getMapsClicked:(id)sender {

  NSCharacterSet *wsSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];

  NSString *username = [mUsernameField stringValue];
  username = [username stringByTrimmingCharactersInSet:wsSet];

  if ([username rangeOfString:@"@"].location == NSNotFound) {
    // if no domain was supplied, add @gmail.com
    username = [username stringByAppendingString:@"@gmail.com"];
  }

  [mUsernameField setStringValue:username];

  [self fetchFeedOfMaps];
}

- (IBAction)addMapClicked:(id)sender {
  [self addAMap];
}

- (IBAction)renameMapClicked:(id)sender {
  [self renameSelectedMap];
}

- (IBAction)deleteMapClicked:(id)sender {

  GDataEntryMap *map = [self selectedMap];

  NSBeginAlertSheet(@"Delete", nil, @"Cancel", nil,
                    [self window], self,
                    @selector(deleteMapSheetDidEnd:returnCode:contextInfo:),
                    nil, nil, @"Delete map \"%@\"?",
                    [[map title] stringValue]);
}

- (void)deleteMapSheetDidEnd:(NSWindow *)sheet
               returnCode:(int)returnCode
              contextInfo:(void  *)contextInfo {

  if (returnCode == NSOKButton) {
    [self deleteSelectedMap];
  }
}

- (IBAction)addFeatureClicked:(id)sender {
  [self addFeatureToSelectedMap];
}

- (IBAction)renameFeatureClicked:(id)sender {
  [self renameSelectedFeature];
}

- (IBAction)deleteFeatureClicked:(id)sender {
  GDataEntryMapFeature *feature = [self selectedFeature];

  NSBeginAlertSheet(@"Delete", nil, @"Cancel", nil,
                    [self window], self,
                    @selector(deleteFeatureSheetDidEnd:returnCode:contextInfo:),
                    nil, nil, @"Delete feature \"%@\"?",
                    [[feature title] stringValue]);
}

- (void)deleteFeatureSheetDidEnd:(NSWindow *)sheet
                  returnCode:(int)returnCode
                 contextInfo:(void  *)contextInfo {

  if (returnCode == NSOKButton) {
    [self deleteSelectedFeature];
  }
}

- (IBAction)loggingCheckboxClicked:(id)sender {
  [GDataHTTPFetcher setIsLoggingEnabled:[sender state]];
}

#pragma mark -

// get a map service object with the current username/password
//
// A "service" object handles networking tasks.  Service objects
// contain user authentication information as well as networking
// state information (such as cookies and the "last modified" date for
// fetched data.)

- (GDataServiceGoogleMaps *)mapService {

  static GDataServiceGoogleMaps* service = nil;

  if (!service) {
    service = [[GDataServiceGoogleMaps alloc] init];

    // iPhone apps typically would not turn on the caching here
    // to avoid the memory usage
    [service setShouldCacheDatedData:YES];
    [service setServiceShouldFollowNextLinks:YES];
  }

  // username/password may change
  NSString *username = [mUsernameField stringValue];
  NSString *password = [mPasswordField stringValue];

  [service setUserAgent:@"MyCompany-SampleMapsApp-1.0"]; // set this to yourName-appName-appVersion
  [service setUserCredentialsWithUsername:username
                                 password:password];

  return service;
}

// get the map selected in the top list, or nil if none
- (GDataEntryMap *)selectedMap {

  NSArray *maps = [mMapFeed entries];
  int rowIndex = [mMapTable selectedRow];
  if ([maps count] > 0 && rowIndex > -1) {

    GDataEntryMap *map = [maps objectAtIndex:rowIndex];
    return map;
  }
  return nil;
}

// get the feature selected in the second list, or nil if none
- (GDataEntryMapFeature *)selectedFeature {

  NSArray *features = [mFeatureFeed entries];
  int rowIndex = [mFeatureTable selectedRow];
  if ([features count] > 0 && rowIndex > -1) {

    GDataEntryMapFeature *feature = [features objectAtIndex:rowIndex];
    return feature;
  }
  return nil;
}


#pragma mark Fetch feed of all of the user's maps

// begin retrieving the list of the user's maps
- (void)fetchFeedOfMaps {

  [self setMapFeed:nil];
  [self setMapFetchError:nil];

  [self setFeatureFeed:nil];
  [self setFeatureFeedTicket:nil];
  [self setFeatureFetchError:nil];


  GDataServiceGoogleMaps *service = [self mapService];
  NSURL *feedURL = [GDataServiceGoogleMaps mapsFeedURLForUserID:kGDataServiceDefaultUser
                                                     projection:kGDataMapsProjectionFull];

  GDataServiceTicket *ticket;
  ticket = [service fetchMapsFeedWithURL:feedURL
                                delegate:self
                       didFinishSelector:@selector(mapsTicket:finishedWithFeed:)
                         didFailSelector:@selector(mapsTicket:failedWithError:)];
  [self setMapFeedTicket:ticket];

  [self updateUI];
}

//
// map feed fetch callbacks
//

// fetched map list successfully
- (void)mapsTicket:(GDataServiceTicket *)ticket
  finishedWithFeed:(GDataFeedMap *)feed {

  [self setMapFeed:feed];
  [self setMapFetchError:nil];
  [self setMapFeedTicket:nil];

  [self updateUI];
}

// failed
- (void)mapsTicket:(GDataServiceTicket *)ticket
   failedWithError:(NSError *)error {

  [self setMapFeed:nil];
  [self setMapFetchError:error];
  [self setMapFeedTicket:nil];

  [self updateUI];
}

#pragma mark Fetch a map's features

// for the map selected in the top list, begin retrieving the lists of
// features and tables
- (void)fetchFeaturesOfSelectedMap {

  GDataEntryMap *map = [self selectedMap];
  if (map) {

    GDataServiceGoogleMaps *service = [self mapService];

    // fetch the feed of features
    NSURL *featuresFeedURL = [map featuresFeedURL];
    if (featuresFeedURL) {

      [self setFeatureFeed:nil];
      [self setFeatureFetchError:nil];

      GDataServiceTicket *ticket;
      ticket = [service fetchMapsFeedWithURL:featuresFeedURL
                                    delegate:self
                           didFinishSelector:@selector(featuresTicket:finishedWithFeed:)
                             didFailSelector:@selector(featuresTicket:failedWithError:)];
      [self setFeatureFeedTicket:ticket];
    }
    [self updateUI];
  }
}

//
// features fetch callbacks
//

// fetched features list successfully
- (void)featuresTicket:(GDataServiceTicket *)ticket
      finishedWithFeed:(GDataFeedMapFeature *)feed {

  [self setFeatureFeed:feed];
  [self setFeatureFetchError:nil];
  [self setFeatureFeedTicket:nil];

  [self updateUI];
}

// failed
- (void)featuresTicket:(GDataServiceTicket *)ticket
       failedWithError:(NSError *)error {

  [self setFeatureFeed:nil];
  [self setFeatureFetchError:error];
  [self setFeatureFeedTicket:nil];

  [self updateUI];
}

#pragma mark Add a map

- (void)addAMap {

  NSURL *postURL = [[mMapFeed postLink] URL];

  NSString *title = [mMapNameField stringValue];

  if (postURL != nil && [title length] > 0) {
    GDataEntryMap *newEntry = [GDataEntryMap mapEntryWithTitle:title];

    GDataServiceGoogleMaps *service = [self mapService];

    GDataServiceTicket *ticket;
    ticket = [service fetchMapsEntryByInsertingEntry:newEntry
                                          forFeedURL:postURL
                                            delegate:self
                                   didFinishSelector:@selector(addMapTicket:finishedWithEntry:)
                                     didFailSelector:@selector(addMapTicket:failedWithError:)];
    [self setMapEditTicket:ticket];
    [self updateUI];
  }
}

- (void)addMapTicket:(GDataServiceTicket *)ticket
   finishedWithEntry:(GDataEntryMap *)entry {

  [self setMapEditTicket:nil];

  NSBeginAlertSheet(@"Map added", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Added map \"%@\"", [[entry title] stringValue]);

  [self fetchFeedOfMaps];
}

- (void)addMapTicket:(GDataServiceTicket *)ticket
     failedWithError:(NSError *)error {

  [self setMapEditTicket:nil];

  NSBeginAlertSheet(@"Add Map Error", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"%@", error);

  [self updateUI];
}

#pragma mark Rename a map

- (void)renameSelectedMap {

  GDataEntryMap *selectedMap = [self selectedMap];

  NSString *newName = [mMapNameField stringValue];

  NSURL *editURL = [[selectedMap editLink] URL];

  if (editURL != nil && [newName length] > 0) {

    GDataServiceGoogleMaps *service = [self mapService];

    GDataEntryMap *mapCopy = [selectedMap copy];
    [mapCopy setTitleWithString:newName];

    GDataServiceTicket *ticket;
    ticket = [service fetchMapsEntryByUpdatingEntry:mapCopy
                                        forEntryURL:editURL
                                           delegate:self
                                  didFinishSelector:@selector(renameMapTicket:finishedWithEntry:)
                                    didFailSelector:@selector(renameMapTicket:failedWithError:)];
    [self setMapEditTicket:ticket];
    [self updateUI];
  }
}

- (void)renameMapTicket:(GDataServiceTicket *)ticket
      finishedWithEntry:(GDataEntryMap *)entry {

  [self setMapEditTicket:nil];

  NSBeginAlertSheet(@"Map renamed", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Renamed map to \"%@\"",
                    [[entry title] stringValue]);

  [self fetchFeedOfMaps];
}

- (void)renameMapTicket:(GDataServiceTicket *)ticket
        failedWithError:(NSError *)error {

  [self setMapEditTicket:nil];

  NSBeginAlertSheet(@"Rename Map Error", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"%@", error);

  [self updateUI];
}

#pragma mark Delete the map

- (void)deleteSelectedMap {

  GDataEntryMap *selectedMap = [self selectedMap];
  if (selectedMap) {

    GDataServiceGoogleMaps *service = [self mapService];
    GDataServiceTicket *ticket;

    ticket = [service deleteMapsEntry:selectedMap
                             delegate:self
                    didFinishSelector:@selector(deleteMapTicket:finishedWithNil:)
                      didFailSelector:@selector(deleteMapTicket:failedWithError:)];
    [self setMapEditTicket:ticket];

    // save the name in the ticket
    [ticket setProperty:[[selectedMap title] stringValue]
                 forKey:@"mapName"];

    [self updateUI];
  }
}

- (void)deleteMapTicket:(GDataServiceTicket *)ticket
          finishedWithNil:(GDataObject *)nilObj {

  [self setMapEditTicket:nil];

  NSString *name = [ticket propertyForKey:@"mapName"];

  NSBeginAlertSheet(@"Map deleted", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Deleted map \"%@\"", name);

  [self fetchFeedOfMaps];
}

- (void)deleteMapTicket:(GDataServiceTicket *)ticket
       failedWithError:(NSError *)error {

  [self setMapEditTicket:nil];

  NSBeginAlertSheet(@"Delete Map Error", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"%@", error);

  [self updateUI];
}

#pragma mark Add a feature

- (void)addFeatureToSelectedMap {

  NSURL *postURL = [[mFeatureFeed postLink] URL];

  NSString *title = [mFeatureNameField stringValue];

  if (postURL != nil && [title length] > 0) {

    GDataEntryMapFeature *newEntry = [GDataEntryMapFeature featureEntryWithTitle:title];

    NSString *kmlStr = @"<Placemark xmlns='http://earth.google.com/kml/2.2'>"
    "<name>Faulkner's Birthplace</name><Point><coordinates>"
    "-89.520753,34.360902,0.0</coordinates></Point></Placemark>";

    NSError *error = nil;
    NSXMLElement *kmlElem;
    kmlElem = [[[NSXMLElement alloc] initWithXMLString:kmlStr
                                                 error:&error] autorelease];
    if (kmlElem) {
      [newEntry addKMLValue:kmlElem];
    } else {
      NSLog(@"cannot make kml element, %@", error);
    }

    GDataServiceGoogleMaps *service = [self mapService];

    GDataServiceTicket *ticket;
    ticket = [service fetchMapsEntryByInsertingEntry:newEntry
                                          forFeedURL:postURL
                                            delegate:self
                                   didFinishSelector:@selector(addFeatureTicket:finishedWithEntry:)
                                     didFailSelector:@selector(addFeatureTicket:failedWithError:)];
    [self setFeatureEditTicket:ticket];
    [self updateUI];
  }
}

- (void)addFeatureTicket:(GDataServiceTicket *)ticket
       finishedWithEntry:(GDataEntryMap *)entry {

  [self setFeatureEditTicket:nil];

  NSBeginAlertSheet(@"Feature added", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Added feature \"%@\"",
                    [[entry title] stringValue]);

  [self fetchFeaturesOfSelectedMap];
}

- (void)addFeatureTicket:(GDataServiceTicket *)ticket
         failedWithError:(NSError *)error {

  [self setFeatureEditTicket:nil];

  NSBeginAlertSheet(@"Add Feature Error", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"%@", error);

  [self updateUI];
}

#pragma mark Rename a feature

- (void)renameSelectedFeature {

  GDataEntryMapFeature *selectedFeature = [self selectedFeature];

  NSString *newName = [mFeatureNameField stringValue];

  NSURL *editURL = [[selectedFeature editLink] URL];

  if (editURL != nil && [newName length] > 0) {

    GDataServiceGoogleMaps *service = [self mapService];

    [selectedFeature setTitleWithString:newName];

    GDataServiceTicket *ticket;
    ticket = [service fetchMapsEntryByUpdatingEntry:selectedFeature
                                        forEntryURL:editURL
                                           delegate:self
                                  didFinishSelector:@selector(renameFeatureTicket:finishedWithEntry:)
                                    didFailSelector:@selector(renameFeatureTicket:failedWithError:)];
    [self setFeatureEditTicket:ticket];
    [self updateUI];
  }
}

- (void)renameFeatureTicket:(GDataServiceTicket *)ticket
          finishedWithEntry:(GDataEntryMapFeature *)entry {

  [self setFeatureEditTicket:nil];

  NSBeginAlertSheet(@"Feature renamed", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Renamed feature to \"%@\"",
                    [[entry title] stringValue]);

  [self fetchFeaturesOfSelectedMap];
}

- (void)renameFeatureTicket:(GDataServiceTicket *)ticket
            failedWithError:(NSError *)error {

  [self setFeatureEditTicket:nil];

  NSBeginAlertSheet(@"Rename Feature Error", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"%@", error);

  [self updateUI];
}

#pragma mark Delete the feature

- (void)deleteSelectedFeature {

  GDataEntryMapFeature *selectedFeature = [self selectedFeature];
  if (selectedFeature) {

    GDataServiceGoogleMaps *service = [self mapService];
    GDataServiceTicket *ticket;

    ticket = [service deleteMapsEntry:selectedFeature
                             delegate:self
                    didFinishSelector:@selector(deleteFeatureTicket:finishedWithNil:)
                      didFailSelector:@selector(deleteFeatureTicket:failedWithError:)];
    [self setFeatureEditTicket:ticket];

    // save the name in the ticket
    [ticket setProperty:[[selectedFeature title] stringValue]
                 forKey:@"featureName"];

    [self updateUI];
  }
}

- (void)deleteFeatureTicket:(GDataServiceTicket *)ticket
        finishedWithNil:(GDataObject *)nilObj {

  [self setFeatureEditTicket:nil];

  NSString *name = [ticket propertyForKey:@"featureName"];

  NSBeginAlertSheet(@"Feature deleted", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"Deleted feature \"%@\"", name);

  [self fetchFeaturesOfSelectedMap];
}

- (void)deleteFeatureTicket:(GDataServiceTicket *)ticket
        failedWithError:(NSError *)error {

  [self setFeatureEditTicket:nil];

  NSBeginAlertSheet(@"Delete Feature Error", nil, nil, nil,
                    [self window], nil, nil,
                    nil, nil, @"%@", error);

  [self updateUI];
}

#pragma mark Text field delegate methods

- (void)controlTextDidChange:(NSNotification *)note {

  [self updateUI]; // enabled/disable buttons
}

#pragma mark TableView delegate and data source methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification {

  id obj = [notification object];
  if (obj == mMapTable) {
    // the user clicked on a map, so fetch its features and tables
    [self fetchFeaturesOfSelectedMap];
  } else {
    // just update the results view for the selected item
    [self updateUI];
  }
}

// table view data source methods
- (GDataFeedBase *)feedForTableView:(NSTableView *)tableView {

  if (tableView == mMapTable)     return mMapFeed;
  if (tableView == mFeatureTable) return mFeatureFeed;
  return nil;
}

- (int)numberOfRowsInTableView:(NSTableView *)tableView {

  GDataFeedBase *feed = [self feedForTableView:tableView];
  return [[feed entries] count];
}

- (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(int)row {

  GDataFeedBase *feed = [self feedForTableView:tableView];
  GDataEntryBase *entry = [feed entryAtIndex:row];
  return [[entry title] stringValue];
}

#pragma mark Setters and Getters

- (GDataFeedMap *)mapFeed {
  return mMapFeed;
}

- (void)setMapFeed:(GDataFeedMap *)feed {
  [mMapFeed autorelease];
  mMapFeed = [feed retain];
}

- (NSError *)mapFetchError {
  return mMapFetchError;
}

- (void)setMapFetchError:(NSError *)error {
  [mMapFetchError release];
  mMapFetchError = [error retain];
}

- (GDataServiceTicket *)mapFeedTicket {
  return mMapFeedTicket;
}

- (void)setMapFeedTicket:(GDataServiceTicket *)obj {
  [mMapFeedTicket autorelease];
  mMapFeedTicket = [obj retain];
}

- (GDataServiceTicket *)mapEditTicket {
  return mMapEditTicket;
}

- (void)setMapEditTicket:(GDataServiceTicket *)obj {
  [mMapEditTicket autorelease];
  mMapEditTicket = [obj retain];
}


- (GDataFeedMapFeature *)featureFeed {
  return mFeatureFeed;
}

- (void)setFeatureFeed:(GDataFeedMapFeature *)feed {
  [mFeatureFeed autorelease];
  mFeatureFeed = [feed retain];
}

- (NSError *)featureFetchError {
  return mFeatureFetchError;
}

- (void)setFeatureFetchError:(NSError *)error {
  [mFeatureFetchError release];
  mFeatureFetchError = [error retain];
}

- (GDataServiceTicket *)featureFeedTicket {
  return mFeatureFeedTicket;
}

- (void)setFeatureFeedTicket:(GDataServiceTicket *)obj {
  [mFeatureFeedTicket autorelease];
  mFeatureFeedTicket = [obj retain];
}

- (GDataServiceTicket *)featureEditTicket {
  return mFeatureEditTicket;
}

- (void)setFeatureEditTicket:(GDataServiceTicket *)obj {
  [mFeatureEditTicket autorelease];
  mFeatureEditTicket = [obj retain];
}

@end
