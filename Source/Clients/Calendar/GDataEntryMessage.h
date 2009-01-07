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
//  GDataEntryMessage.h
//

#import "GDataEntryBase.h"

#import "GDataRating.h"
#import "GDataWhen.h"
#import "GDataGeoPt.h"
#import "GDataWho.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAENTRYMESSAGE_DEFINE_GLOBALS
#define _EXTERN 
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString *kGDataMessage _INITIALIZE_AS(@"http://schemas.google.com/g/2005#message");

_EXTERN NSString *kGDataMessageStarred _INITIALIZE_AS(@"http://schemas.google.com/g/2005#message.starred");
_EXTERN NSString *kGDataMessageUnread _INITIALIZE_AS(@"http://schemas.google.com/g/2005#message.unread");
_EXTERN NSString *kGDataMessageChat _INITIALIZE_AS(@"http://schemas.google.com/g/2005#message.chat");
_EXTERN NSString *kGDataMessageSpam _INITIALIZE_AS(@"http://schemas.google.com/g/2005#message.spam");
_EXTERN NSString *kGDataMessageSent _INITIALIZE_AS(@"http://schemas.google.com/g/2005#message.sent");
_EXTERN NSString *kGDataMessageInbox _INITIALIZE_AS(@"http://schemas.google.com/g/2005#message.inbox");


@interface GDataEntryMessage : GDataEntryBase {
}

- (GDataRating *)rating;
- (void)setRating:(GDataRating *)obj;

- (GDataWhen *)time;
- (void)setTime:(GDataWhen *)obj;

- (GDataGeoPt *)geoPt;
- (void)setGeoPt:(GDataGeoPt *)obj;

- (NSArray *)participants;
- (void)setParticipants:(NSArray *)array;
- (void)addParticipant:(GDataWho *)obj;

@end
