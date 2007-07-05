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
// GData.h
//

#import "GDataFramework.h"

// utility classes
#import "GDataDateTime.h"
#import "GDataHTTPFetcher.h"
#import "GDataHTTPFetcherLogging.h"
#import "GDataProgressMonitorInputStream.h"
#import "GDataGatherInputStream.h"
#import "GDataMIMEDocument.h"

// base classes
#import "GDataObject.h"
#import "GDataEntryBase.h"
#import "GDataFeedBase.h"
#import "GDataEntryEvent.h"
#import "GDataFeedEvent.h"
#import "GDataEntryMessage.h"
#import "GDataFeedMessage.h"
#import "GDataServiceBase.h"
#import "GDataServiceGoogle.h"
#import "GDataQuery.h"

// standard elements
#import "GDataCategory.h"
#import "GDataComment.h"
#import "GDataContactSection.h"
#import "GDataEmail.h"
#import "GDataEntryLink.h"
#import "GDataExtendedProperty.h"
#import "GDataFeedLink.h"
#import "GDataGenerator.h"
#import "GDataGeoPt.h"
#import "GDataIM.h"
#import "GDataLink.h"
#import "GDataOriginalEvent.h"
#import "GDataPerson.h"
#import "GDataPhoneNumber.h"
#import "GDataPostalAddress.h"
#import "GDataRating.h"
#import "GDataRecurrence.h"
#import "GDataRecurrenceException.h"
#import "GDataReminder.h"
#import "GDataTextConstruct.h"
#import "GDataValueConstruct.h"
#import "GDataEntryContent.h"
#import "GDataWhen.h"
#import "GDataWhere.h"
#import "GDataWho.h"
#import "GDataAtomPubControl.h"
#import "GDataBatchID.h"
#import "GDataBatchInterrupted.h"
#import "GDataBatchOperation.h"
#import "GDataBatchStatus.h"

// ACL
#import "GDataACLScope.h"
#import "GDataACLRole.h"
#import "GDataEntryACL.h"
#import "GDataFeedACL.h"

// Media
#import "GDataNormalPlayTime.h"
#import "GDataMediaContent.h"
#import "GDataMediaCredit.h"
#import "GDataMediaGroup.h"
#import "GDataMediaKeywords.h"
#import "GDataMediaThumbnail.h"

// Geo
#import "GDataGeo.h"

// Google Calendar
#import "GDataWebContent.h"
#import "GDataEntryCalendar.h"
#import "GDataFeedCalendar.h"
#import "GDataEntryCalendarEvent.h"
#import "GDataFeedCalendarEvent.h"
#import "GDataServiceGoogleCalendar.h"
#import "GDataQueryCalendar.h"

// Google Base
#import "GDataEntryGoogleBase.h"
#import "GDataFeedGoogleBase.h"
#import "GDataServiceGoogleBase.h"
#import "GDataQueryGoogleBase.h"

// Google Spreadsheet
#import "GDataSpreadsheetCustomElement.h"
#import "GDataSpreadsheetCell.h"
#import "GDataRowColumnCount.h"
#import "GDataEntryWorksheet.h"
#import "GDataEntrySpreadsheetList.h"
#import "GDataEntrySpreadsheetCell.h"
#import "GDataEntrySpreadsheet.h"
#import "GDataFeedWorksheet.h"
#import "GDataFeedSpreadsheetList.h"
#import "GDataFeedSpreadsheetCell.h"
#import "GDataFeedSpreadsheet.h"
#import "GDataServiceGoogleSpreadsheet.h"
#import "GDataQuerySpreadsheet.h"

// Code Search
#import "GDataCodeSearchFile.h"
#import "GDataCodeSearchPackage.h"
#import "GDataCodeSearchMatch.h"
#import "GDataEntryCodeSearch.h"
#import "GDataFeedCodeSearch.h"

// Google Photos/Picasa Web
#import "GDataPhotoElements.h"
#import "GDataEXIFTags.h"
#import "GDataEntryPhotoBase.h"
#import "GDataEntryPhoto.h"
#import "GDataEntryPhotoAlbum.h"
#import "GDataEntryPhotoComment.h"
#import "GDataEntryPhotoTag.h"
#import "GDataEntryPhotoUser.h"
#import "GDataFeedPhotoBase.h"
#import "GDataFeedPhoto.h"
#import "GDataFeedPhotoAlbum.h"
#import "GDataFeedPhotoUser.h"
#import "GDataServiceGooglePicasaWeb.h"
#import "GDataQueryPicasaWeb.h"
