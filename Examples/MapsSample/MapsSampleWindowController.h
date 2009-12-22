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
//  MapTableSampleWindowController.h
//

#import <Cocoa/Cocoa.h>

#import "GData/GDataMaps.h"

@interface MapsSampleWindowController : NSWindowController {
  IBOutlet NSTextField *mUsernameField;
  IBOutlet NSSecureTextField *mPasswordField;

  IBOutlet NSButton *mAddMapButton;
  IBOutlet NSButton *mRenameMapButton;
  IBOutlet NSButton *mDeleteMapButton;
  IBOutlet NSTextField *mMapNameField;

  IBOutlet NSButton *mAddFeatureButton;
  IBOutlet NSButton *mRenameFeatureButton;
  IBOutlet NSButton *mDeleteFeatureButton;
  IBOutlet NSTextField *mFeatureNameField;

  IBOutlet NSTableView *mMapTable;
  IBOutlet NSProgressIndicator *mMapProgressIndicator;
  IBOutlet NSTextView *mMapResultTextField;

  IBOutlet NSButton *mSpatialSearchCheckbox;
  IBOutlet NSTextField *mLatitudeField;
  IBOutlet NSTextField *mLongitudeField;
  IBOutlet NSTextField *mRadiusField;

  IBOutlet NSTableView *mFeatureTable;
  IBOutlet NSProgressIndicator *mFeatureProgressIndicator;
  IBOutlet NSTextView *mFeatureResultTextField;

  GDataFeedMap *mMapFeed;
  GDataServiceTicket *mMapFeedTicket;
  NSError *mMapFetchError;

  GDataServiceTicket *mMapEditTicket;

  GDataFeedMapFeature *mFeatureFeed;
  GDataServiceTicket *mFeatureFeedTicket;
  NSError *mFeatureFetchError;

  GDataServiceTicket *mFeatureEditTicket;
}

+ (MapsSampleWindowController *)sharedWindowController;

- (IBAction)getMapsClicked:(id)sender;

- (IBAction)addMapClicked:(id)sender;
- (IBAction)renameMapClicked:(id)sender;
- (IBAction)deleteMapClicked:(id)sender;

- (IBAction)spatialSearchClicked:(id)sender;

- (IBAction)addFeatureClicked:(id)sender;
- (IBAction)renameFeatureClicked:(id)sender;
- (IBAction)deleteFeatureClicked:(id)sender;

- (IBAction)loggingCheckboxClicked:(id)sender;
@end
