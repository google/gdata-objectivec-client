/* Copyright (c) 2007-2008 Google Inc.
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
#import "GDataServerError.h"

// base classes
#import "GDataObject.h"
#import "GDataEntryBase.h"
#import "GDataFeedBase.h"
#import "GDataServiceBase.h"
#import "GDataServiceGoogle.h"
#import "GDataQuery.h"

// standard elements
#import "GDataCategory.h"
#import "GDataComment.h"
#import "GDataEmail.h"
#import "GDataEntryLink.h"
#import "GDataExtendedProperty.h"
#import "GDataFeedLink.h"
#import "GDataGenerator.h"
#import "GDataGeoPt.h"
#import "GDataIM.h"
#import "GDataLink.h"
#import "GDataMoney.h"
#import "GDataPerson.h"
#import "GDataPhoneNumber.h"
#import "GDataPostalAddress.h"
#import "GDataRating.h"
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
#import "GDataMediaCategory.h"
#import "GDataMediaCredit.h"
#import "GDataMediaGroup.h"
#import "GDataMediaKeywords.h"
#import "GDataMediaThumbnail.h"
#import "GDataMediaPlayer.h"
#import "GDataMediaRating.h"
#import "GDataMediaRestriction.h"

// Geo
#import "GDataGeo.h"

