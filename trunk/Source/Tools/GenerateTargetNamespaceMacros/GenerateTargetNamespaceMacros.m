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

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

// This tool takes the path to the GData framework, and searches it
// for classes with the "GData" or "GTM" prefix.
//
// If any GData classes are found, it writes to the output path the contents
// of the file GDataTargetNamespace.h, like
//
// #define GDataServiceBase _GDATA_NS_SYMBOL(GDataServiceBase)
// #define GDataHTTPFetcher _GDATA_NS_SYMBOL(GDataHTTPFetcher)

static int DoGDataClassSearch(NSBundle *targetBundle, NSString *outputPath);
static NSArray *AllClassNamesNow(void);

int main (int argc, const char * argv[]) {

  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

  // get the --path argument
  NSString *const kPathKey = @"-path";
  NSString *const kOutputPathKey = @"-output";

  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *pathToBundle = [defaults stringForKey:kPathKey];
  NSString *pathToOutput = [defaults stringForKey:kOutputPathKey];

  int result = 1; // failure

  NSFileManager *fileMgr = [NSFileManager defaultManager];

  // the tool is in
  //   GData/Source/Tools/GenerateTargetNamespaceMacros/build/Debug/GenerateTargetNamespaceMacros
  // the framework is in
  //    GData/Source/build/Debug/GData.framework
  // or GData/Source/build/Release/GData.framework

  NSArray *args = [[NSProcessInfo processInfo] arguments];
  NSString *toolPath = [args objectAtIndex:0];
  NSString *toolDir = [toolPath stringByDeletingLastPathComponent];

  NSString *sourceDir = [toolDir stringByAppendingPathComponent:@"../../../.."];
  sourceDir = [sourceDir stringByStandardizingPath];

  if (pathToBundle == nil) {

    // no input path was specified; look for the framework in a usual build
    // location
    NSString *frameworkDir = [sourceDir stringByAppendingPathComponent:@"build/Debug/GData.framework"];
    if ([fileMgr fileExistsAtPath:frameworkDir]) {

      // found a built debug GData framework
      pathToBundle = frameworkDir;

    } else {

      frameworkDir = [sourceDir stringByAppendingPathComponent:@"build/Release/GData.framework"];

      if ([fileMgr fileExistsAtPath:frameworkDir]) {
        // found a built release GData framework
        pathToBundle = frameworkDir;
      }
    }
  }

  if (pathToBundle == nil) {
    // an input bundle is needed
    fprintf(stderr, "Usage: %s [--path /path/to/framework] [--output /path/to/output/file]\n", argv[0]);
    goto Done;
  }

  if (pathToOutput == nil) {
    // no output path was specified; default to the usual header path,
    // GData/Source/GDataTargetNamespace.h
    pathToOutput = [sourceDir stringByAppendingPathComponent:@"GDataTargetNamespace.h"];
  }

  NSBundle *targetBundle = [NSBundle bundleWithPath:pathToBundle];
  if (targetBundle == nil) {

    // could not make an NSBundle
    fprintf(stderr, "%s: No framework at path %s", argv[0],
            [pathToBundle UTF8String]);
    goto Done;
  }

  // generate the macros
  printf("Generating macros for bundle: %s\nOutput path: %s\n\n",
         [pathToBundle UTF8String], [pathToOutput UTF8String]);
  result = DoGDataClassSearch(targetBundle, pathToOutput);
  if (result == 0) {
    printf("Finished.\n");
  } else {
    printf("Failed.\n"); // DoGDataClassSearch writes error details to stderr
  }

Done:
  [pool release];
  return result;
}



// DoGDataClassSearch finds all classes in the target bundle that begin with
// GData.  If it finds any, it writes to the output path the contents of
// GDataTargetNamespace.h
static int DoGDataClassSearch(NSBundle *targetBundle, NSString *outputPath) {

  // get all predefined classes so we can omit them after loading the
  // bundle's classes
  //
  // Note:
  //   Remember that not all classes derive from NSObject, so we can't
  //   call *any* methods on any of them.

  NSArray *initialClasses = AllClassNamesNow();

  // now load the bundle, get all the class names again, and omit the
  // class names that were pre-existing
  [targetBundle load];

  NSMutableArray *bundleClasses;

  bundleClasses = [NSMutableArray arrayWithArray:AllClassNamesNow()];
  [bundleClasses removeObjectsInArray:initialClasses];

  // search for class names that are in our bundle (excluding those
  // that loaded with our bundle but are located in other bundles), and that
  // begin with GData
  NSMutableArray *sharedNamesArray = [NSMutableArray array];

  NSEnumerator *nameEnum = [bundleClasses objectEnumerator];
  NSString *className;

  while ((className = [nameEnum nextObject]) != nil) {

    if ([className hasPrefix:@"GData"] || [className hasPrefix:@"GTM"]) {
      Class classObj = NSClassFromString(className);

      NSBundle *classBundle = [NSBundle bundleForClass:classObj];
      if (classBundle == targetBundle) {

        [sharedNamesArray addObject:className];
      }
    }
  }

  // if there are no class names remaining, we're done
  if ([sharedNamesArray count] == 0) {
    return 0; // successful exit
  }

  // sort the remaining class names, and build a list of macros
  SEL compareSel = @selector(caseInsensitiveCompare:);
  NSArray *sortedNames;

  sortedNames = [sharedNamesArray sortedArrayUsingSelector:compareSel];

  // the output will pad the macro definitions for easier skimming, like
  //
  //    #define GDataAtomIcon  _GDATA_NS_SYMBOL(GDataAtomIcon)
  //    #define GDataAtomID    _GDATA_NS_SYMBOL(GDataAtomID)

  // use KVC magic to find the longest class name
  int maxNameLen = [[sortedNames valueForKeyPath:@"@max.length"] intValue];

  NSString *const kSpaces = @"                                             ";

  NSMutableString *nameListStr = [NSMutableString string];

  NSEnumerator *sortedEnum = [sortedNames objectEnumerator];
  NSString *name;
  while ((name = [sortedEnum nextObject]) != nil) {

    NSString *padding = [kSpaces substringToIndex:(maxNameLen - [name length])];

    [nameListStr appendFormat:@"  #define %@%@ _GDATA_NS_SYMBOL(%@)\n",
                              name, padding, name];
  }

  // write out the complete header file contents
  //
  // because of C-preprocessor argument evaluation rules, we need to create
  // "inner" macros to turn the arguments into their actual values
  //
  // we also generate GDATA_TARGET_NAMESPACE_STRING so code (particularly
  // unit tests) can explicitly refer to the prefix as a string at runtime

  NSString *const kTemplate =
    @"//\n// Makes the value of GDATA_TARGET_NAMESPACE a prefix for all GData class names\n//\n\n"
     "//\n// To avoid global namespace issues, define GDATA_TARGET_NAMESPACE to a short\n"
     "// string in your target if you are using the GData library in a shared-code\n"
     "// environment like a plug-in.\n"
     "//\n// For example:   -DGDATA_TARGET_NAMESPACE=MyPlugin\n//\n\n"
     "//\n// %@\n//\n\n"
     "#if defined(__OBJC__) && defined(GDATA_TARGET_NAMESPACE)\n\n"
     "  #define _GDATA_NS_SYMBOL_INNER(namespace, symbol) namespace ## _ ## symbol\n"
     "  #define _GDATA_NS_SYMBOL_MIDDLE(namespace, symbol) _GDATA_NS_SYMBOL_INNER(namespace, symbol)\n"
     "  #define _GDATA_NS_SYMBOL(symbol) _GDATA_NS_SYMBOL_MIDDLE(GDATA_TARGET_NAMESPACE, symbol)\n\n"
     "  #define _GDATA_NS_STRING_INNER(namespace) #namespace\n"
     "  #define _GDATA_NS_STRING_MIDDLE(namespace) _GDATA_NS_STRING_INNER(namespace)\n"
     "  #define GDATA_TARGET_NAMESPACE_STRING _GDATA_NS_STRING_MIDDLE(GDATA_TARGET_NAMESPACE)\n\n"

     "%@\n"
     "#endif\n";

  NSString *versionInfo = [NSString stringWithFormat:@"%@ v. %@ (%d classes) %@",
             [targetBundle bundleIdentifier],
             [[targetBundle infoDictionary] objectForKey:@"CFBundleVersion"],
             (int) [sortedNames count],
             [NSDate date]];

  NSString *fileStr = [NSString stringWithFormat:kTemplate,
                       versionInfo, nameListStr];

  NSError *error = nil;
  BOOL didWrite = [fileStr writeToFile:outputPath
                            atomically:YES
                              encoding:NSUTF8StringEncoding
                                 error:&error];
  if (!didWrite) {
    fprintf(stderr, "%s", [[error description] UTF8String]);
    return 1;
  }

  return 0;
}

// AllClassNamesNow returns all class names currently known to the Obj-C runtime
static NSArray *AllClassNamesNow(void)
{
  NSMutableArray *resultArray = [NSMutableArray array];

  int numClasses = 0;
  int newNumClasses = objc_getClassList(NULL, 0);
  Class *classes = NULL;

  // do the weird memory allocation dance suggested in objc-runtime.h
  while (numClasses < newNumClasses) {
    numClasses = newNumClasses;
    classes = realloc(classes, sizeof(Class) * numClasses);
    newNumClasses = objc_getClassList(classes, numClasses);
  }

  if (classes) {
    for (int index = 0; index < newNumClasses; ++index) {
      Class currClass = classes[index];
      NSString *className = NSStringFromClass(currClass);
      [resultArray addObject:className];
    }
    free(classes);
  }

  return resultArray;
}
