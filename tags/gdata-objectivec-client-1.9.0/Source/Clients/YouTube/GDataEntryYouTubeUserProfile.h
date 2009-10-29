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
//  GDataEntryYouTubeUserProfile.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataEntryBase.h"
#import "GDataFeedLink.h"
#import "GDataYouTubeStatistics.h"
#import "GDataMediaThumbnail.h"

@interface GDataEntryYouTubeUserProfile : GDataEntryBase

+ (GDataEntryYouTubeUserProfile *)userProfileEntry;

// channelType is a convenience accessor to get the term value from
// the channel category element
- (NSString *)channelType;


- (GDataYouTubeStatistics *)statistics;
- (void)setStatistics:(GDataYouTubeStatistics *)obj;

- (NSString *)aboutMe;
- (void)setAboutMe:(NSString *)str;

- (NSString *)books;
- (void)setBooks:(NSString *)str;

- (NSNumber *)age; // int NSNumber
- (void)setAge:(NSNumber *)str;

- (GDataMediaThumbnail *)thumbnail;
- (void)setThumbnail:(GDataMediaThumbnail *)obj;

- (NSString *)company;
- (void)setCompany:(NSString *)str;

- (NSString *)gender;
- (void)setGender:(NSString *)str;

- (NSString *)hobbies;
- (void)setHobbies:(NSString *)str;

- (NSString *)hometown;
- (void)setHometown:(NSString *)str;

- (NSString *)location;
- (void)setLocation:(NSString *)str;

- (NSString *)movies;
- (void)setMovies:(NSString *)str;

- (NSString *)music;
- (void)setMusic:(NSString *)str;

- (NSString *)occupation;
- (void)setOccupation:(NSString *)str;

- (NSString *)relationship;
- (void)setRelationship:(NSString *)str;

- (NSString *)school;
- (void)setSchool:(NSString *)str;

- (NSString *)username;
- (void)setUsername:(NSString *)str;

- (NSString *)firstName;
- (void)setFirstName:(NSString *)str;

- (NSString *)lastName;
- (void)setLastName:(NSString *)str;

- (NSArray *)feedLinks;

// convenience accessors

- (GDataLink *)videoLogLink;
- (GDataLink *)featuredVideoLink;

- (GDataFeedLink *)favoritesFeedLink;
- (GDataFeedLink *)contactsFeedLink;
- (GDataFeedLink *)inboxFeedLink;
- (GDataFeedLink *)playlistsFeedLink;
- (GDataFeedLink *)subscriptionsFeedLink;
- (GDataFeedLink *)uploadsFeedLink;
- (GDataFeedLink *)recentSubscriptionVideosFeedLink; // previously newSubscriptionVideosFeedLink
- (GDataFeedLink *)friendsActivityFeedLink;
- (GDataFeedLink *)recentActivityFeedLink;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
