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
//  GDataEntrySitemap.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE

#import "GDataEntrySiteMessage.h"
#import "GDataWebmasterToolsConstants.h"

// private extensions

@interface GDataSiteMessageBody : GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataSiteMessageBody
+ (NSString *)extensionElementURI       { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementLocalName { return @"body"; }
@end

@interface GDataSiteMessageDate: GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataSiteMessageDate
+ (NSString *)extensionElementURI       { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementLocalName { return @"date"; }
@end

@interface GDataSiteMessageLanguage: GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataSiteMessageLanguage
+ (NSString *)extensionElementURI       { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementLocalName { return @"language"; }
@end

@interface GDataSiteMessageRead: GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataSiteMessageRead
+ (NSString *)extensionElementURI       { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementLocalName { return @"read"; }
@end

@interface GDataSiteMessageSubject: GDataValueElementConstruct <GDataExtension>
@end

@implementation GDataSiteMessageSubject
+ (NSString *)extensionElementURI       { return kGDataNamespaceWebmasterTools; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceWebmasterToolsPrefix; }
+ (NSString *)extensionElementLocalName { return @"subject"; }
@end


@implementation GDataEntrySiteMessage

+ (id)messageEntry {
  GDataEntrySiteMessage *obj = [[[self alloc] init] autorelease];

  [obj setNamespaces:[GDataWebmasterToolsConstants webmasterToolsNamespaces]];

  return obj;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategorySiteMessage;
}

+ (void)load {
  [self registerEntryClass];
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  Class entryClass = [self class];

  [self addExtensionDeclarationForParentClass:entryClass
                                 childClasses:
   [GDataSiteMessageBody class],
   [GDataSiteMessageDate class],
   [GDataSiteMessageLanguage class],
   [GDataSiteMessageRead class],
   [GDataSiteMessageSubject class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {

  static struct GDataDescriptionRecord descRecs[] = {
    { @"body",     @"body",                    kGDataDescValueLabeled   },
    { @"date",     @"messageDate.stringValue", kGDataDescValueLabeled   },
    { @"language", @"language",                kGDataDescValueLabeled   },
    { @"read",     @"read",                    kGDataDescBooleanLabeled },
    { @"subject",  @"subject",                 kGDataDescValueLabeled   },
    { nil, nil, 0 }
  };

  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

+ (NSString *)defaultServiceVersion {
  return kGDataWebmasterToolsDefaultServiceVersion;
}

#pragma mark -

- (NSString *)body {
  GDataSiteMessageBody *obj;

  obj = [self objectForExtensionClass:[GDataSiteMessageBody class]];
  return [obj stringValue];
}

- (void)setBody:(NSString *)str {
  GDataSiteMessageBody *obj = [GDataSiteMessageBody valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataSiteMessageBody class]];
}

- (GDataDateTime *)messageDate {
  GDataSiteMessageDate *obj;

  obj = [self objectForExtensionClass:[GDataSiteMessageDate class]];
  return [obj dateTimeValue];
}

- (void)setMessageDate:(GDataDateTime *)dateTime {
  GDataSiteMessageDate *obj = [GDataSiteMessageDate valueWithDateTime:dateTime];
  [self setObject:obj forExtensionClass:[GDataSiteMessageDate class]];
}

- (NSString *)language {
  GDataSiteMessageLanguage *obj;

  obj = [self objectForExtensionClass:[GDataSiteMessageLanguage class]];
  return [obj stringValue];
}

- (void)setLanguage:(NSString *)str {
  GDataSiteMessageLanguage *obj = [GDataSiteMessageLanguage valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataSiteMessageLanguage class]];
}

- (NSNumber *)read { // boolean
  GDataSiteMessageRead *obj;

  obj = [self objectForExtensionClass:[GDataSiteMessageRead class]];
  return [obj boolNumberValue];
}

- (void)setRead:(NSNumber *)num {
  GDataSiteMessageRead *obj = [GDataSiteMessageRead valueWithNumber:num];
  [self setObject:obj forExtensionClass:[GDataSiteMessageRead class]];
}

- (NSString *)subject {
  GDataSiteMessageSubject *obj;

  obj = [self objectForExtensionClass:[GDataSiteMessageSubject class]];
  return [obj stringValue];
}

- (void)setSubject:(NSString *)str {
  GDataSiteMessageSubject *obj = [GDataSiteMessageSubject valueWithString:str];
  [self setObject:obj forExtensionClass:[GDataSiteMessageSubject class]];
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_WEBMASTERTOOLS_SERVICE
