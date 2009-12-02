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
//  GDataYouTubeElements.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataObject.h"
#import "GDataValueConstruct.h"


// http://code.google.com/apis/youtube/reference.html#Elements

// user info, like <yt:aboutMe>I am hot</yt:about me>
@interface GDataYouTubeAboutMe : GDataValueElementConstruct <GDataExtension>
@end

// user's age, an integer, like <yt:age>32</yt:age>
@interface GDataYouTubeAge : GDataValueElementConstruct <GDataExtension>
@end

// aspect ratio, like <yt:aspectRatio>widescreen</yt:aspectRatio>
@interface GDataYouTubeAspectRatio : GDataValueElementConstruct <GDataExtension>
@end

// user's books, like <yt:books>Pride and Prejudice</yt:books>
@interface GDataYouTubeBooks : GDataValueElementConstruct <GDataExtension>
@end

// rating of comment, like <yt:commentRating>1</yt:commentRating>
@interface GDataYouTubeCommentRating : GDataValueElementConstruct <GDataExtension>
@end

// user's company, like <yt:company>Self employed</yt:company>
@interface GDataYouTubeCompany : GDataValueElementConstruct <GDataExtension>
@end

// count hint for entry content, like <yt:countHint>10</yt:countHint>
@interface GDataYouTubeCountHint : GDataValueElementConstruct <GDataExtension>
@end

// user's hobbies, like <yt:hobbies>Reading, skiing</yt:hobbies>
@interface GDataYouTubeHobbies : GDataValueElementConstruct <GDataExtension>
@end

// user's hometown, like <yt:hometown>Seattle</yt:hometown>
@interface GDataYouTubeHometown : GDataValueElementConstruct <GDataExtension>
@end

// user's location, like <yt:location>Longbourn in Hertfordshire, Pemberley in Derbyshire</yt:location>
@interface GDataYouTubeLocation : GDataValueElementConstruct <GDataExtension>
@end

// recorded date, like <yt:recorded>1998-12-01</yt:recorded>
@interface GDataYouTubeRecordedDate : GDataValueElementConstruct <GDataExtension>
@end

// user's movies, like <yt:movies>Pride and Prejudice, 2005</yt:movies>
@interface GDataYouTubeMovies : GDataValueElementConstruct <GDataExtension>
@end

// user's music, like <yt:music>Pink Floyd</yt:music>
@interface GDataYouTubeMusic : GDataValueElementConstruct <GDataExtension>
@end

// user's occupation, like <yt:occupation>Doctor of quackery</yt:occupation>
@interface GDataYouTubeOccupation : GDataValueElementConstruct <GDataExtension>
@end

// user's school, like <yt:school>Rocky Mountain High</yt:school>
@interface GDataYouTubeSchool : GDataValueElementConstruct <GDataExtension>
@end

// user's gender, like <yt:gender>f</yt:gender>
@interface GDataYouTubeGender : GDataValueElementConstruct <GDataExtension>
@end

// user's relationship, like <yt:relationship>available</yt:relationship>
@interface GDataYouTubeRelationship : GDataValueElementConstruct <GDataExtension>
@end

// video duration in seconds, like <yt:duration seconds="2462" />
@interface GDataYouTubeDuration : GDataValueConstruct <GDataExtension>
- (NSString *)attributeName; // returns "seconds"
@end

// element indicating non-embeddable video, <yt:noembed/>
@interface GDataYouTubeNonEmbeddable : GDataImplicitValueConstruct <GDataExtension>
@end

// position in a playlist, an integer, like <yt:position>1</yt:position>
@interface GDataYouTubePosition : GDataValueElementConstruct <GDataExtension>
@end

// <yt:private/>
@interface GDataYouTubePrivate : GDataImplicitValueConstruct <GDataExtension>
@end

// <yt:firstName>Fred</yt:firstName>
@interface GDataYouTubeFirstName : GDataValueElementConstruct <GDataExtension>
@end

// <yt:lastName>Smith</yt:lastName>
@interface GDataYouTubeLastName : GDataValueElementConstruct <GDataExtension>
@end

// <yt:queryString>Smith</yt:queryString>
@interface GDataYouTubeQueryString : GDataValueElementConstruct <GDataExtension>
@end

// <yt:playlistId>1x4aa23</yt:playlistId>
@interface GDataYouTubePlaylistID : GDataValueElementConstruct <GDataExtension>
@end

// <yt:playlistTitle>Fred's Playlist</yt:playlistTitle>
@interface GDataYouTubePlaylistTitle : GDataValueElementConstruct <GDataExtension>
@end

// hint that the containing entry is spam, like <yt:spam/>
@interface GDataYouTubeSpam : GDataImplicitValueConstruct <GDataExtension>
@end

// status, like <yt:status>accepted</yt:status>
@interface GDataYouTubeStatus : GDataValueElementConstruct <GDataExtension>
@end

// user's name, like <yt:username>liz</yt:username>
@interface GDataYouTubeUsername : GDataValueElementConstruct <GDataExtension>
@end

// token extension to edit-media links, like <yt:token>LongForm</yt:token>
@interface GDataYouTubeToken : GDataValueElementConstruct <GDataExtension>
@end

// video ID for v2 feeds, like <yt:videoid>I-t-7lTw6mA</yt:videoid>
@interface GDataYouTubeVideoID : GDataValueElementConstruct <GDataExtension>
@end

// uploaded date for v2 feeds, like <yt:uploaded>2008-03-06T23:49:12.000Z</yt:uploaded>
@interface GDataYouTubeUploadedDate : GDataValueElementConstruct <GDataExtension>
@end

// element inside an app:control indicating an incompletely-defined video,
// like <yt:incomplete/>
@interface GDataYouTubeIncomplete : GDataImplicitValueConstruct <GDataExtension>
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_YOUTUBE_SERVICE
