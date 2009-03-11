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
//  GDataEntryFolderDoc.h
//

#import "GDataEntryDocBase.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAENTRYFOLDERDOC_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataCategoryFolderDoc _INITIALIZE_AS(@"http://schemas.google.com/docs/2007#folder");

@interface GDataEntryFolderDoc : GDataEntryDocBase
@end

