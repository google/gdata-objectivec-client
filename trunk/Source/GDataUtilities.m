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

#import "GDataUtilities.h"


@implementation GDataUtilities

+ (NSString *)stringWithControlsFilteredForString:(NSString *)str {
  // Ensure that control characters are not present in the string, since they 
  // would lead to XML that likely will make servers unhappy.  (Are control
  // characters ever legal in XML?)
  //
  // Why not assert on debug builds for the caller when the string has a control
  // character?  The characters may never be present in the data until the
  // program is deployed to users.  This filtering will make it less likely 
  // that bad XML might be generated for users and sent to servers.
  //
  // Since we generate our XML directly from the elements with
  // XMLData, we won't later have a good chance to look for and clean out
  // the control characters.
  
  static NSCharacterSet *filterChars = nil;
  if (filterChars == nil) {
    // make a character set of control characters (but not whitespace/newline
    // characters), and keep a static immutable copy to use for filtering
    // strings
    NSCharacterSet *ctrlChars = [NSCharacterSet controlCharacterSet];
    NSCharacterSet *newlineWsChars = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSCharacterSet *nonNewlineWsChars = [newlineWsChars invertedSet];
    
    NSMutableCharacterSet *mutableChars = [[ctrlChars mutableCopy] autorelease];
    [mutableChars formIntersectionWithCharacterSet:nonNewlineWsChars];
    
    [mutableChars addCharactersInRange:NSMakeRange(0x0B, 2)]; // filter vt, ff
    
    filterChars = [mutableChars copy];
  }
  
  // look for any invalid characters
  NSRange range = [str rangeOfCharacterFromSet:filterChars]; 
  if (range.location != NSNotFound) {
    
    // copy the string to a mutable, and remove null and non-whitespace 
    // control characters
    NSMutableString *mutableStr = [NSMutableString stringWithString:str];  
    while (range.location != NSNotFound) {
      
#if DEBUG
      NSLog(@"GDataObject: Removing char 0x%lx from XML element string \"%@\"", 
            [mutableStr characterAtIndex:range.location], str);
#endif
      [mutableStr deleteCharactersInRange:range];
      
      range = [mutableStr rangeOfCharacterFromSet:filterChars]; 
    }
    
    return mutableStr;
  }
  
  return str;
}

#pragma mark Copy method helpers

+ (NSArray *)arrayWithCopiesOfObjectsInArray:(NSArray *)source {
  if (source == nil) return nil;
  
  NSArray *result = [[[NSArray alloc] initWithArray:source
                                          copyItems:YES] autorelease];
  return result;
}

+ (NSDictionary *)dictionaryWithCopiesOfObjectsInDictionary:(NSDictionary *)source {
  if (source == nil) return nil;
  
  NSDictionary *result = [[[NSDictionary alloc] initWithDictionary:source
                                                         copyItems:YES] autorelease];
  return result;
}

+ (NSDictionary *)dictionaryWithCopiesOfArraysInDictionary:(NSDictionary *)source {
  
  // The extensions dictionary maps classes to arrays of extension objects.
  //
  // We want to copy each extension object in each array.
  
  if (source == nil) return nil;
  
  // Using CFPropertyListCreateDeepCopy would be nice, but it fails on non-plist
  // classes of objects
  
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  NSEnumerator *keyEnum = [source keyEnumerator];
  NSArray *key;
  while ((key = [keyEnum nextObject]) != nil) {
    NSArray *origArray = [source objectForKey:key];
    NSArray *copyArray = [self arrayWithCopiesOfObjectsInArray:origArray];
    
    [dict setObject:copyArray forKey:key];
  }
  
  return dict;
}

#pragma mark URL encoding 

+ (NSString *)stringByURLEncodingString:(NSString *)str {
  NSString *result = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  return result;
}

+ (NSString *)stringByURLEncodingStringParameter:(NSString *)str {
  
  // NSURL's stringByAddingPercentEscapesUsingEncoding: does not escape
  // some characters that should be escaped in URL parameters, like / and ?; 
  // we'll use CFURL to force the encoding of those
  //
  // We'll explicitly leave spaces unescaped now, and replace them with +'s
  //
  // Reference: http://www.ietf.org/rfc/rfc3986.txt
  
  NSString *resultStr = str;
  
  CFStringRef originalString = (CFStringRef) str;
  CFStringRef leaveUnescaped = CFSTR(" ");
  CFStringRef forceEscaped = CFSTR("!*'();:@&=+$,/?%#[]");
  
  CFStringRef escapedStr;
  escapedStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                       originalString,
                                                       leaveUnescaped, 
                                                       forceEscaped,
                                                       kCFStringEncodingUTF8);
  
  if (escapedStr) {
    NSMutableString *mutableStr = [NSMutableString stringWithString:(NSString *)escapedStr];
    CFRelease(escapedStr);
    
    // replace spaces with plusses
    [mutableStr replaceOccurrencesOfString:@" "
                                withString:@"+"
                                   options:0
                                     range:NSMakeRange(0, [mutableStr length])];
    resultStr = mutableStr;
  }
  return resultStr;
}


@end
