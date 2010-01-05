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
//  GDataTranslationElements.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_TRANSLATION_SERVICE

#import "GDataValueConstruct.h"
#import "GDataLink.h"

@interface GDataTranslationSourceLanguage : GDataValueElementConstruct <GDataExtension>
@end

@interface GDataTranslationTargetLanguage : GDataValueElementConstruct <GDataExtension>
@end

@interface GDataTranslationPercentComplete : GDataValueElementConstruct <GDataExtension>
@end

@interface GDataTranslationNumberOfSourceWords : GDataValueElementConstruct <GDataExtension>
@end

@interface GDataTranslationScope : GDataValueElementConstruct <GDataExtension>
@end

@interface GDataTranslationLinks : GDataObject
- (NSArray *)links;
- (void)setLinks:(NSArray *)array;
- (void)addLink:(GDataLink *)obj;
- (void)removeLink:(GDataLink *)obj;

// convenience accessors
- (NSArray *)hrefs;
@end

@interface GDataTranslationGlossary : GDataTranslationLinks <GDataExtension>
+ (GDataTranslationGlossary *)glossaryWithLink:(GDataLink *)link;
@end

@interface GDataTranslationMemory : GDataTranslationLinks <GDataExtension>
+ (GDataTranslationMemory *)memoryWithLink:(GDataLink *)link;
@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_TRANSLATION_SERVICE
