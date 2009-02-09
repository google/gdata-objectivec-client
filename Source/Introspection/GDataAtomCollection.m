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
//  GDataAtomCollection.m
//

#import "GDataAtomCollection.h"
#import "GDataAtomCategoryGroup.h"
#import "GDataBaseElements.h"

static NSString* const kHrefAttr = @"href";
static NSString *const kTitleAttr = @"title";


@implementation GDataAtomAccept
+ (NSString *)extensionElementURI       { return kGDataNamespaceAtomPub1_0; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAtomPubPrefix; }
+ (NSString *)extensionElementLocalName { return @"accept"; }
@end

@implementation GDataAtomAccept1_0
+ (NSString *)extensionElementURI       { return kGDataNamespaceAtomPubStd; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAtomPubPrefix; }
+ (NSString *)extensionElementLocalName { return @"accept"; }
@end


@implementation GDataAtomCollection1_0
// original atom collection: older namespace, and titles stored
// as attributes

+ (NSString *)extensionElementURI       { return kGDataNamespaceAtomPub1_0; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAtomPubPrefix; }
+ (NSString *)extensionElementLocalName { return @"collection"; }

+ (Class)categoryGroupClass {
  return [GDataAtomCategoryGroup1_0 class];
}

+ (Class)acceptClass {
  return [GDataAtomAccept1_0 class];
}

- (void)addParseDeclarations {

  NSArray *attrs = [NSArray arrayWithObjects:kHrefAttr, kTitleAttr, nil];

  [self addLocalAttributeDeclarations:attrs];
}


- (GDataTextConstruct *)title {
  NSString *str = [self stringValueForAttribute:kTitleAttr];
  GDataTextConstruct *obj = [GDataTextConstruct textConstructWithString:str];
  return obj;
}

- (void)setTitle:(GDataTextConstruct *)obj {
  [self setStringValue:[obj stringValue] forAttribute:kTitleAttr];
}

@end

@implementation GDataAtomCollection
// a collection in a service document for introspection,
// per http://tools.ietf.org/html/rfc5023#section-8.3.3
//
// For example,
//  <app:collection href="http://photos.googleapis.com/data/feed/api/user/user%40gmail.com?v=2">
//    <atom:title>gregrobbins</atom:title>
//    <app:accept>image/jpeg</app:accept>
//    <app:accept>video/*</app:accept>
//    <app:categories fixed="yes">
//      <atom:category scheme="http://example.org/extra-cats/" term="joke" />
//    </app:categories>
//  </app:collection>

+ (NSString *)extensionElementURI       { return kGDataNamespaceAtomPubStd; }
+ (NSString *)extensionElementPrefix    { return kGDataNamespaceAtomPubPrefix; }
+ (NSString *)extensionElementLocalName { return @"collection"; }

+ (Class)categoryGroupClass {
  return [GDataAtomCategoryGroup class];
}

+ (Class)acceptClass {
  return [GDataAtomAccept class];
}

- (void)addParseDeclarations {

  NSArray *attrs = [NSArray arrayWithObject:kHrefAttr];

  [self addLocalAttributeDeclarations:attrs];
}

- (void)addExtensionDeclarations {

  [super addExtensionDeclarations];

  [self addExtensionDeclarationForParentClass:[self class]
                                 childClasses:
   [[self class] categoryGroupClass],
   [[self class] acceptClass],
   [GDataAtomTitle class],
   nil];
}

#if !GDATA_SIMPLE_DESCRIPTIONS
- (NSMutableArray *)itemsForDescription {
  static struct GDataDescriptionRecord descRecs[] = {
    { @"title",         @"title.stringValue",    kGDataDescValueLabeled },
    { @"href",          @"href",                 kGDataDescValueLabeled },
    { @"categoryGroup", @"categoryGroup",        kGDataDescValueLabeled },
    { @"accepts",       @"serviceAcceptStrings", kGDataDescArrayDescs },
    { nil, nil, 0 }
  };
  
  NSMutableArray *items = [super itemsForDescription];
  [self addDescriptionRecords:descRecs toItems:items];
  return items;
}
#endif

#pragma mark -

- (NSString *)href {
  return [self stringValueForAttribute:kHrefAttr];
}

- (void)setHref:(NSString *)str {
  [self setStringValue:str forAttribute:kHrefAttr];
}

- (GDataTextConstruct *)title {
  return [self objectForExtensionClass:[GDataAtomTitle class]];
}

- (void)setTitle:(GDataTextConstruct *)obj {
  [self setObject:obj forExtensionClass:[GDataAtomTitle class]];
}

- (GDataAtomCategoryGroup *)categoryGroup {
  Class categoryGroupClass = [[self class] categoryGroupClass];

  return [self objectForExtensionClass:categoryGroupClass];
}

- (void)setCategoryGroup:(GDataAtomCategoryGroup *)obj {
  Class categoryGroupClass = [[self class] categoryGroupClass];

  [self setObject:obj forExtensionClass:categoryGroupClass];
}

- (NSArray *)serviceAcceptStrings {
  NSArray *acceptObjs;

  Class acceptClass = [[self class] acceptClass];

  acceptObjs = [self objectsForExtensionClass:acceptClass];

  if ([acceptObjs count] > 0) {
    // using KVC, make an array of the strings in each accept element
    return [acceptObjs valueForKey:@"stringValue"];
  }
  return nil;
}

- (void)setServiceAcceptStrings:(NSArray *)array {
  NSMutableArray *objArray = nil;

  Class acceptClass = [[self class] acceptClass];

  // make an accept object for each string in the array
  NSUInteger numberOfStrings = [array count];
  if (numberOfStrings > 0) {

    objArray = [NSMutableArray arrayWithCapacity:numberOfStrings];

    NSString *str;
    GDATA_FOREACH(str, array) {
      [objArray addObject:[acceptClass valueWithString:str]];
    }
  }

  // if objArray is still nil, the extensions will be removed
  [self setObjects:objArray forExtensionClass:acceptClass];
}

@end
