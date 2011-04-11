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
//  GDataVolumeReadingPosition.h
//

// reading position, like
//   <gbs:readingPosition action="NextPage"
//                        application="Sony Reader"
//                        value="GBS.25.w.2.9.15"
//                        time="2007-07-16T00:00:00" />

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BOOKS_SERVICE

#import "GDataObject.h"

@interface GDataVolumeReadingPosition : GDataObject <GDataExtension>

+ (GDataVolumeReadingPosition *)positionWithAction:(NSString *)action
                                   applicationName:(NSString *)name
                                              time:(GDataDateTime *)dateTime
                                             value:(NSString *)value;

- (NSString *)action;
- (void)setAction:(NSString *)str;

- (NSString *)applicationName;
- (void)setApplicationName:(NSString *)str;

- (NSString *)value;
- (void)setValue:(NSString *)str;

- (GDataDateTime *)positionTime;
- (void)setPositionTime:(GDataDateTime *)dateTime;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_BOOKS_SERVICE
