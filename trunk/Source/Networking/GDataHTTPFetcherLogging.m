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


#import "GDataHTTPFetcherLogging.h"

#if !STRIP_GDATA_FETCH_LOGGING

#import "GDataProgressMonitorInputStream.h"

// If logging isn't being stripped, make sure we have all the defines from
// GDataDefines.h
#import "GDataDefines.h"

@interface GDataInputStreamLogger : GDataProgressMonitorInputStream
// GDataInputStreamLogger is wraps any NSInputStream used for
// uploading so we can capture a copy of the data for the log
@end

// We don't invoke Leopard methods on 10.4, because we check if the methods are
// implemented before invoking it, but we need to be able to compile without
// warnings.
// These declarations mean if you target <=10.4, the methods will compile
// without complaint in this source, so you must test with
// -respondsToSelector:, too.
#if MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4
@interface NSFileManager (LeopardMethodsOnTigerBuilds)
- (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error;
- (BOOL)createSymbolicLinkAtPath:(NSString *)path
             withDestinationPath:(NSString *)destPath error:(NSError **)error;
- (BOOL)createDirectoryAtPath:(NSString *)path
  withIntermediateDirectories:(BOOL)createIntermediates
                   attributes:(NSDictionary *)attributes
                        error:(NSError **)error;
@end
#endif  // MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4

#endif  // !STRIP_GDATA_FETCH_LOGGING

@implementation GDataHTTPFetcher (GDataHTTPFetcherLogging)

// if STRIP_GDATA_FETCH_LOGGING is defined by the user's project then
// logging code will not be compiled into the framework

#if STRIP_GDATA_FETCH_LOGGING
- (void)logFetchWithError:(NSError *)error {}

+ (void)setLoggingDirectory:(NSString *)path {}
+ (NSString *)loggingDirectory {return nil;}

+ (void)setIsLoggingEnabled:(BOOL)flag {}
+ (BOOL)isLoggingEnabled {return NO;}

+ (void)setLoggingProcessName:(NSString *)str {}
+ (NSString *)loggingProcessName {return nil;}

+ (void)setLoggingDateStamp:(NSString *)str {}
+ (NSString *)loggingDateStamp {return nil;}

- (void)appendLoggedStreamData:(NSData *)newData {}
- (void)logCapturePostStream {}
#else

// fetchers come and fetchers go, but statics are forever
static BOOL gIsLoggingEnabled = NO;
static NSString *gLoggingDirectoryPath = nil;
static NSString *gLoggingDateStamp = nil;
static NSString* gLoggingProcessName = nil;

+ (void)setLoggingDirectory:(NSString *)path {
  [gLoggingDirectoryPath autorelease];
  gLoggingDirectoryPath = [path copy];
}

+ (NSString *)loggingDirectory {

  if (!gLoggingDirectoryPath) {
    NSArray *arr = nil;
#if GDATA_IPHONE && TARGET_IPHONE_SIMULATOR
    // default to a directory called GDataHTTPDebugLogs into a sandbox-safe
    // directory that a developer can find easily, the application home
    arr = [NSArray arrayWithObject:NSHomeDirectory()];
#elif GDATA_IPHONE
    // Neither ~/Desktop nor ~/Home is writable on an actual iPhone device.
    // Put it in ~/Documents.
    arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                              NSUserDomainMask, YES);
#else
    // default to a directory called GDataHTTPDebugLogs in the desktop folder
    arr = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory,
                                              NSUserDomainMask, YES);
#endif

    if ([arr count] > 0) {
      NSString *const kGDataLogFolderName = @"GDataHTTPDebugLogs";

      NSString *desktopPath = [arr objectAtIndex:0];
      NSString *logsFolderPath = [desktopPath stringByAppendingPathComponent:kGDataLogFolderName];

      BOOL doesFolderExist;
      BOOL isDir = NO;
      NSFileManager *fileManager = [NSFileManager defaultManager];
      doesFolderExist = [fileManager fileExistsAtPath:logsFolderPath
                                          isDirectory:&isDir];

      if (!doesFolderExist) {
        // make the directory
#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_5
        // Compiling for 10.5 or later, just use the new api
        doesFolderExist = [fileManager createDirectoryAtPath:logsFolderPath
                                 withIntermediateDirectories:YES
                                                  attributes:nil
                                                       error:NULL];
#else
        // Check at runtime if we have the newer api and use that, otherwise, just
        // use the older api (we avoid it to avoid console messages).
        if ([fileManager respondsToSelector:@selector(createDirectoryAtPath:withIntermediateDirectories:attributes:error:)]) {
          doesFolderExist = [fileManager createDirectoryAtPath:logsFolderPath
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:NULL];
        } else {
          doesFolderExist = [fileManager createDirectoryAtPath:logsFolderPath
                                                    attributes:nil];
        }
#endif
      }

      if (doesFolderExist) {
        // it's there; store it in the global
        gLoggingDirectoryPath = [logsFolderPath copy];
      }
    }
  }
  return gLoggingDirectoryPath;
}

+ (void)setIsLoggingEnabled:(BOOL)flag {
  gIsLoggingEnabled = flag;
}

+ (BOOL)isLoggingEnabled {
  return gIsLoggingEnabled;
}

+ (void)setLoggingProcessName:(NSString *)str {
  [gLoggingProcessName release];
  gLoggingProcessName = [str copy];
}

+ (NSString *)loggingProcessName {

  // get the process name (once per run) replacing spaces with underscores
  if (!gLoggingProcessName) {

    NSString *procName = [[NSProcessInfo processInfo] processName];
    NSMutableString *loggingProcessName;
    loggingProcessName = [[NSMutableString alloc] initWithString:procName];

    [loggingProcessName replaceOccurrencesOfString:@" "
                                        withString:@"_"
                                           options:0
                                             range:NSMakeRange(0, [gLoggingProcessName length])];
    gLoggingProcessName = loggingProcessName;
  }
  return gLoggingProcessName;
}

+ (void)setLoggingDateStamp:(NSString *)str {
  [gLoggingDateStamp release];
  gLoggingDateStamp = [str copy];
}

+ (NSString *)loggingDateStamp {
  // we'll pick one date stamp per run, so a run that starts at a later second
  // will get a unique results html file
  if (!gLoggingDateStamp) {
    // produce a string like 08-21_01-41-23PM

    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [formatter setDateFormat:@"M-dd_hh-mm-ssa"];

    gLoggingDateStamp = [[formatter stringFromDate:[NSDate date]] retain] ;
  }
  return gLoggingDateStamp;
}


// formattedStringFromData returns a prettyprinted string for XML input,
// and a plain string for other input data
- (NSString *)formattedStringFromData:(NSData *)inputData {

#if !GDATA_FOUNDATION_ONLY && !GDATA_SKIP_LOG_XMLFORMAT
  // verify that this data starts with the bytes indicating XML

  NSString *const kXMLLintPath = @"/usr/bin/xmllint";
  static BOOL hasCheckedAvailability = NO;
  static BOOL isXMLLintAvailable;

  if (!hasCheckedAvailability) {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    isXMLLintAvailable = [fileManager fileExistsAtPath:kXMLLintPath];
    hasCheckedAvailability = YES;
  }

  if (isXMLLintAvailable
      && [inputData length] > 5
      && strncmp([inputData bytes], "<?xml", 5) == 0) {

    // call xmllint to format the data
    NSTask *task = [[[NSTask alloc] init] autorelease];
    [task setLaunchPath:kXMLLintPath];

    // use the dash argument to specify stdin as the source file
    [task setArguments:[NSArray arrayWithObjects:@"--format", @"-", nil]];
    [task setEnvironment:[NSDictionary dictionary]];

    NSPipe *inputPipe = [NSPipe pipe];
    NSPipe *outputPipe = [NSPipe pipe];
    [task setStandardInput:inputPipe];
    [task setStandardOutput:outputPipe];

    [task launch];

    [[inputPipe fileHandleForWriting] writeData:inputData];
    [[inputPipe fileHandleForWriting] closeFile];

    // drain the stdout before waiting for the task to exit
    NSData *formattedData =
    [[outputPipe fileHandleForReading] readDataToEndOfFile];

    [task waitUntilExit];

    int status = [task terminationStatus];
    if (status == 0 && [formattedData length] > 0) {
      // success
      inputData = formattedData;
    }
  }
#else
  // we can't call external tasks on the iPhone; leave the XML unformatted
#endif

  NSString *dataStr = [[[NSString alloc] initWithData:inputData
                                             encoding:NSUTF8StringEncoding] autorelease];
  return dataStr;
}


- (NSString *)cleanParameterFollowing:(NSString *)paramName
                           fromString:(NSString *)originalStr {
  // We don't want the password written to disk
  //
  // find "&Passwd=" in the string, and replace it and the stuff that
  // follows it with "Passwd=_snip_"

  NSRange passwdRange = [originalStr rangeOfString:@"&Passwd="];
  if (passwdRange.location != NSNotFound) {

    // we found Passwd=; find the & that follows the parameter
    NSUInteger origLength = [originalStr length];
    NSRange restOfString = NSMakeRange(passwdRange.location+1,
                                       origLength - passwdRange.location - 1);
    NSRange rangeOfFollowingAmp = [originalStr rangeOfString:@"&"
                                                     options:0
                                                       range:restOfString];
    NSRange replaceRange;
    if (rangeOfFollowingAmp.location == NSNotFound) {
      // found no other & so replace to end of string
      replaceRange = NSMakeRange(passwdRange.location,
                           rangeOfFollowingAmp.location - passwdRange.location);
    } else {
      // another parameter after &Passwd=foo
      replaceRange = NSMakeRange(passwdRange.location,
                           rangeOfFollowingAmp.location - passwdRange.location);
    }

    NSMutableString *result = [NSMutableString stringWithString:originalStr];
    NSString *replacement = [NSString stringWithFormat:@"%@_snip_", paramName];

    [result replaceCharactersInRange:replaceRange withString:replacement];
    return result;
  }
  return originalStr;
}

// stringFromStreamData creates a string given the supplied data
//
// If NSString can create a UTF-8 string from the data, then that is returned.
//
// Otherwise, this routine tries to find a MIME boundary at the beginning of
// the data block, and uses that to break up the data into parts. Each part
// will be used to try to make a UTF-8 string.  For parts that fail, a
// replacement string showing the part header and <<n bytes>> is supplied
// in place of the binary data.

- (NSString *)stringFromStreamData:(NSData *)data {

  if (data == nil) return nil;

  // optimistically, see if the whole data block is UTF-8
  NSString *streamDataStr = [self formattedStringFromData:data];
  if (streamDataStr) return streamDataStr;

  // Munge a buffer by replacing non-ASCII bytes with underscores,
  // and turn that munged buffer an NSString.  That gives us a string
  // we can use with NSScanner.
  NSMutableData *mutableData = [NSMutableData dataWithData:data];
  unsigned char *bytes = [mutableData mutableBytes];

  for (unsigned int idx = 0; idx < [mutableData length]; idx++) {
    if (bytes[idx] > 0x7F || bytes[idx] == 0) {
      bytes[idx] = '_';
    }
  }

  NSString *mungedStr = [[[NSString alloc] initWithData:mutableData
                                   encoding:NSUTF8StringEncoding] autorelease];
  if (mungedStr != nil) {

    // scan for the boundary string
    NSString *boundary = nil;
    NSScanner *scanner = [NSScanner scannerWithString:mungedStr];

    if ([scanner scanUpToString:@"\r\n" intoString:&boundary]
        && [boundary hasPrefix:@"--"]) {

      // we found a boundary string; use it to divide the string into parts
      NSArray *mungedParts = [mungedStr componentsSeparatedByString:boundary];

      // look at each of the munged parts in the original string, and try to
      // convert those into UTF-8
      NSMutableArray *origParts = [NSMutableArray array];
      NSUInteger offset = 0;
      NSEnumerator *mungedPartsEnum = [mungedParts objectEnumerator];
      NSString *mungedPart;
      while ((mungedPart = [mungedPartsEnum nextObject]) != nil) {
        NSUInteger partSize = [mungedPart length];

        NSRange range = NSMakeRange(offset, partSize);
        NSData *origPartData = [data subdataWithRange:range];

        NSString *origPartStr = [[[NSString alloc] initWithData:origPartData
                                   encoding:NSUTF8StringEncoding] autorelease];
        if (origPartStr) {
          // we could make this original part into UTF-8; use the string
          [origParts addObject:origPartStr];
        } else {
          // this part can't be made into UTF-8; scan the header, if we can
          NSString *header = nil;
          NSScanner *headerScanner = [NSScanner scannerWithString:mungedPart];
          if (![headerScanner scanUpToString:@"\r\n\r\n" intoString:&header]) {
            // we couldn't find a header
            header = @"";;
          }

          // make a part string with the header and <<n bytes>>
          NSString *binStr = [NSString stringWithFormat:@"\r%@\r<<%lu bytes>>\r",
            header, (long)(partSize - [header length])];
          [origParts addObject:binStr];
        }
        offset += partSize + [boundary length];
      }

      // rejoin the original parts
      streamDataStr = [origParts componentsJoinedByString:boundary];
    }
  }

  if (!streamDataStr) {
    // give up; just make a string showing the uploaded bytes
    streamDataStr = [NSString stringWithFormat:@"<<%u bytes>>", [data length]];
  }
  return streamDataStr;
}

// logFetchWithError is called following a successful or failed fetch attempt
//
// This method does all the work for appending to and creating log files

- (void)logFetchWithError:(NSError *)error {

  if (![[self class] isLoggingEnabled]) return;

  NSFileManager *fileManager = [NSFileManager defaultManager];

  // TODO: (grobbins)  add Javascript to display response data formatted in hex

  NSString *logDirectory = [[self class] loggingDirectory];
  NSString *processName = [[self class] loggingProcessName];
  NSString *dateStamp = [[self class] loggingDateStamp];

  // each response's NSData goes into its own xml or txt file, though all
  // responses for this run of the app share a main html file.  This
  // counter tracks all fetch responses for this run of the app.
  static int zResponseCounter = 0;
  zResponseCounter++;

  // file name for the html file containing plain text in a <textarea>
  NSString *responseDataUnformattedFileName = nil;

  // file name for the "formatted" (raw) data file
  NSString *responseDataFormattedFileName = nil;
  NSUInteger responseDataLength = [downloadedData_ length];

  NSURLResponse *response = [self response];
  NSString *responseBaseName = nil;

  // if there's response data, decide what kind of file to put it in based
  // on the first bytes of the file or on the mime type supplied by the server
  if (responseDataLength) {
    NSString *responseDataExtn = nil;

    {
      // generate a response file base name like
      //   SyncProto_http_response_10-16_01-56-58PM_3
      NSString *format = @"%@_http_response_%@_%d";
#if GDATA_IPHONE && !TARGET_IPHONE_SIMULATOR
      // iPhone needs a shorter string for Fetch Application Data in Organizer
      // to work.
      // TODO: a long process name can still cause this to exceed the maximum.
      // We should check and truncate.
      // TODO: We should file a bug with Apple about this.
      format = @"%@_hr_%@_%d";
#endif
      responseBaseName = [NSString stringWithFormat:format,
        processName, dateStamp, zResponseCounter];
    }

    NSString *dataStr = [self formattedStringFromData:downloadedData_];
    if (dataStr) {
      // we were able to make a UTF-8 string from the response data

      NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceCharacterSet];
      dataStr = [dataStr stringByTrimmingCharactersInSet:whitespaceSet];

      // save a plain-text version of the response data in an html file
      // containing a wrapped, scrollable <textarea>
      //
      // we'll use <textarea rows="29" cols="108" readonly=true wrap=soft>
      //   </textarea>  to fit inside our iframe
      responseDataUnformattedFileName = [responseBaseName stringByAppendingPathExtension:@"html"];
      NSString *textFilePath = [logDirectory stringByAppendingPathComponent:responseDataUnformattedFileName];

      NSString* wrapFmt = @"<textarea rows=\"29\" cols=\"108\" readonly=true"
        " wrap=soft>\n%@\n</textarea>";
      NSString* wrappedStr = [NSString stringWithFormat:wrapFmt, dataStr];
      {
        NSError *wrappedStrError = nil;
        [wrappedStr writeToFile:textFilePath
                     atomically:NO
                       encoding:NSUTF8StringEncoding
                          error:&wrappedStrError];
        if (wrappedStrError) {
          NSLog(@"%@ logging write error:%@", [self class], wrappedStrError);
        }
      }

      // now determine the extension for the "formatted" file, which is really
      // the raw data written with an appropriate extension

      // for known file types, we'll write the data to a file with the
      // appropriate extension
      if ([dataStr hasPrefix:@"<?xml"]) {
        responseDataExtn = @"xml";
      } else if ([dataStr hasPrefix:@"<html"]) {
        responseDataExtn = @"html";
      } else {
        // add more types of identifiable text here
      }

    } else if ([[response MIMEType] isEqual:@"image/jpeg"]) {
      responseDataExtn = @"jpg";
    } else if ([[response MIMEType] isEqual:@"image/gif"]) {
      responseDataExtn = @"gif";
    } else if ([[response MIMEType] isEqual:@"image/png"]) {
      responseDataExtn = @"png";
    } else {
     // add more non-text types here
    }

    // if we have an extension, save the raw data in a file with that
    // extension to be our "formatted" display file
    if (responseDataExtn) {
      responseDataFormattedFileName = [responseBaseName stringByAppendingPathExtension:responseDataExtn];
      NSString *formattedFilePath = [logDirectory stringByAppendingPathComponent:responseDataFormattedFileName];

      NSError *downloadedError = nil;
      [downloadedData_ writeToFile:formattedFilePath options:0 error:&downloadedError];
      if (downloadedError) {
        NSLog(@"%@ logging write error:%@", [self class], downloadedError);
      }
    }
  }

  // we'll have one main html file per run of the app
  NSString *htmlName = [NSString stringWithFormat:@"%@_http_log_%@.html",
    processName, dateStamp];
  NSString *htmlPath =[logDirectory stringByAppendingPathComponent:htmlName];

  // if the html file exists (from logging previous fetches) we don't need
  // to re-write the header or the scripts
  BOOL didFileExist = [fileManager fileExistsAtPath:htmlPath];

  NSMutableString* outputHTML = [NSMutableString string];
  NSURLRequest *request = [self request];

  // we need file names for the various div's that we're going to show and hide,
  // names unique to this response's bundle of data, so we format our div
  // names with the counter that we incremented earlier
  NSString *requestHeadersName = [NSString stringWithFormat:@"RequestHeaders%d", zResponseCounter];
  NSString *postDataName = [NSString stringWithFormat:@"PostData%d", zResponseCounter];

  NSString *responseHeadersName = [NSString stringWithFormat:@"ResponseHeaders%d", zResponseCounter];
  NSString *responseDataDivName = [NSString stringWithFormat:@"ResponseData%d", zResponseCounter];
  NSString *dataIFrameID = [NSString stringWithFormat:@"DataIFrame%d", zResponseCounter];

  // we need a header to say we'll have UTF-8 text
  if (!didFileExist) {
    [outputHTML appendFormat:@"<html><head><meta http-equiv=\"content-type\" "
      "content=\"text/html; charset=UTF-8\"><title>%@ HTTP fetch log %@</title>",
      processName, dateStamp];
  }

  // write style sheets for each hideable element; each style sheet is
  // customized with our current response number, since they'll share
  // the html page with other responses
  NSString *styleFormat = @"<style type=\"text/css\">div#%@ "
    "{ margin: 0px 20px 0px 20px; display: none; }</style>\n";

  [outputHTML appendFormat:styleFormat, requestHeadersName];
  [outputHTML appendFormat:styleFormat, postDataName];
  [outputHTML appendFormat:styleFormat, responseHeadersName];
  [outputHTML appendFormat:styleFormat, responseDataDivName];

  if (!didFileExist) {
    // write javascript functions.  The first one shows/hides the layer
    // containing the iframe.
    NSString *scriptFormat = @"<script type=\"text/javascript\"> "
      "function toggleLayer(whichLayer){ var style2 = document.getElementById(whichLayer).style; "
      "style2.display = style2.display ? \"\":\"block\";}</script>\n";
    [outputHTML appendString:scriptFormat];

    // the second function is passed the src file; if it's what's shown, it
    // toggles the iframe's visibility. If some other src is shown, it shows
    // the iframe and loads the new source.  Note we want to load the source
    // whenever we show the iframe too since Firefox seems to format it wrong
    // when showing it if we don't reload it.
    NSString *toggleIFScriptFormat = @"<script type=\"text/javascript\"> "
      "function toggleIFrame(whichLayer,iFrameID,newsrc)"
      "{ \n var iFrameElem=document.getElementById(iFrameID); "
      "if (iFrameElem.src.indexOf(newsrc) != -1) { toggleLayer(whichLayer); } "
      "else { document.getElementById(whichLayer).style.display=\"block\"; } "
      "iFrameElem.src=newsrc; }</script>\n</head>\n<body>\n";
    [outputHTML appendString:toggleIFScriptFormat];
  }

  // now write the visible html elements

  // write the date & time
  [outputHTML appendFormat:@"<b>%@</b><br>", [[NSDate date] description]];

  // write the request URL
  [outputHTML appendFormat:@"<b>request:</b> %@ <i>URL:</i> <code>%@</code><br>\n",
    [request HTTPMethod], [request URL]];

  // write the request headers, toggleable
  NSDictionary *requestHeaders = [request allHTTPHeaderFields];
  if ([requestHeaders count]) {
    NSString *requestHeadersFormat = @"<a href=\"javascript:toggleLayer('%@');\">"
      "request headers (%d)</a><div id=\"%@\"><pre>%@</pre></div><br>\n";
    [outputHTML appendFormat:requestHeadersFormat,
      requestHeadersName, // layer name
      [requestHeaders count],
      requestHeadersName,
      [requestHeaders description]]; // description gives a human-readable dump
  } else {
    [outputHTML appendString:@"<i>Request headers: none</i><br>"];
  }

  // write the request post data, toggleable
  NSData *postData = postData_;
  if (loggedStreamData_) {
    postData = loggedStreamData_;
  }

  if ([postData length]) {
    NSString *postDataFormat = @"<a href=\"javascript:toggleLayer('%@');\">"
      "posted data (%d bytes)</a><div id=\"%@\">%@</div><br>\n";
    NSString *postDataStr = [self stringFromStreamData:postData];
    if (postDataStr) {
      NSString *postDataTextAreaFmt = @"<pre>%@</pre>";
      if ([postDataStr rangeOfString:@"<"].location != NSNotFound) {
        postDataTextAreaFmt =  @"<textarea rows=\"15\" cols=\"100\""
         " readonly=true wrap=soft>\n%@\n</textarea>";
      }
      NSString *cleanedPostData = [self cleanParameterFollowing:@"&Passwd="
                                                     fromString:postDataStr];
      NSString *postDataTextArea = [NSString stringWithFormat:
        postDataTextAreaFmt,  cleanedPostData];

      [outputHTML appendFormat:postDataFormat,
        postDataName, // layer name
        [postData length],
        postDataName,
        postDataTextArea];
    }
  } else {
    // no post data
  }

  // write the response status, MIME type, URL
  if (response) {
    NSString *statusString = @"";
    if ([response respondsToSelector:@selector(statusCode)]) {
      NSInteger status = [(NSHTTPURLResponse *)response statusCode];
      statusString = @"200";
      if (status != 200) {
        // purple for errors
        statusString = [NSString stringWithFormat:@"<FONT COLOR=\"#FF00FF\">%ld</FONT>",
          (long)status];
      }
    }

    // show the response URL only if it's different from the request URL
    NSString *responseURLStr =  @"";
    NSURL *responseURL = [response URL];

    if (responseURL && ![responseURL isEqual:[request URL]]) {
      NSString *responseURLFormat = @"<br><FONT COLOR=\"#FF00FF\">response URL:"
        "</FONT> <code>%@</code>";
      responseURLStr = [NSString stringWithFormat:responseURLFormat,
        [responseURL absoluteString]];
    }

    NSDictionary *responseHeaders = nil;
    if ([response respondsToSelector:@selector(allHeaderFields)]) {
      responseHeaders = [(NSHTTPURLResponse *)response allHeaderFields];
    }
    [outputHTML appendFormat:@"<b>response:</b> <i>status:</i> %@ <i>  "
        "&nbsp;&nbsp;&nbsp;MIMEType:</i><code> %@</code>%@<br>\n",
      statusString,
      [response MIMEType],
      responseURLStr,
      responseHeaders ? [responseHeaders description] : @""];

    // write the response headers, toggleable
    if ([responseHeaders count]) {

      NSString *cookiesSet = [responseHeaders objectForKey:@"Set-Cookie"];

      NSString *responseHeadersFormat = @"<a href=\"javascript:toggleLayer("
        "'%@');\">response headers (%d)  %@</a><div id=\"%@\"><pre>%@</pre>"
        "</div><br>\n";
      [outputHTML appendFormat:responseHeadersFormat,
        responseHeadersName,
        [responseHeaders count],
        (cookiesSet ? @"<i>sets cookies</i>" : @""),
        responseHeadersName,
        [responseHeaders description]];

    } else {
      [outputHTML appendString:@"<i>Response headers: none</i><br>\n"];
    }
  }

  // error
  if (error) {
    [outputHTML appendFormat:@"<b>error:</b> %@ <br>\n", [error description]];
  }

  // write the response data.  We have links to show formatted and text
  //   versions, but they both show it in the same iframe, and both
  //   links also toggle visible/hidden
  if (responseDataFormattedFileName || responseDataUnformattedFileName) {

    // response data, toggleable links -- formatted and text versions
    if (responseDataFormattedFileName) {
      [outputHTML appendFormat:@"response data (%d bytes) formatted <b>%@</b> ",
        responseDataLength,
        [responseDataFormattedFileName pathExtension]];

      // inline (iframe) link
      NSString *responseInlineFormattedDataNameFormat = @"&nbsp;&nbsp;<a "
        "href=\"javascript:toggleIFrame('%@','%@','%@');\">inline</a>\n";
      [outputHTML appendFormat:responseInlineFormattedDataNameFormat,
        responseDataDivName, // div ID
        dataIFrameID, // iframe ID (for reloading)
        responseDataFormattedFileName]; // src to reload

      // plain link (so the user can command-click it into another tab)
      [outputHTML appendFormat:@"&nbsp;&nbsp;<a href=\"%@\">stand-alone</a><br>\n",
        [responseDataFormattedFileName
          stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    if (responseDataUnformattedFileName) {
      [outputHTML appendFormat:@"response data (%d bytes) plain text ",
        responseDataLength];

      // inline (iframe) link
      NSString *responseInlineDataNameFormat = @"&nbsp;&nbsp;<a href=\""
        "javascript:toggleIFrame('%@','%@','%@');\">inline</a> \n";
      [outputHTML appendFormat:responseInlineDataNameFormat,
        responseDataDivName, // div ID
        dataIFrameID, // iframe ID (for reloading)
        responseDataUnformattedFileName]; // src to reload

      // plain link (so the user can command-click it into another tab)
      [outputHTML appendFormat:@"&nbsp;&nbsp;<a href=\"%@\">stand-alone</a><br>\n",
        [responseDataUnformattedFileName
          stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }

    // make the iframe
    NSString *divHTMLFormat = @"<div id=\"%@\">%@</div><br>\n";
    NSString *src = responseDataFormattedFileName ?
      responseDataFormattedFileName : responseDataUnformattedFileName;
    NSString *escapedSrc = [src stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *iframeFmt = @" <iframe src=\"%@\" id=\"%@\" width=800 height=400>"
      "\n<a href=\"%@\">%@</a>\n </iframe>\n";
    NSString *dataIFrameHTML = [NSString stringWithFormat:iframeFmt,
      escapedSrc, dataIFrameID, escapedSrc, src];
    [outputHTML appendFormat:divHTMLFormat,
      responseDataDivName, dataIFrameHTML];
  } else {
    // could not parse response data; just show the length of it
    [outputHTML appendFormat:@"<i>Response data: %d bytes </i>\n",
      responseDataLength];
  }

  [outputHTML appendString:@"<br><hr><p>"];

  // append the HTML to the main output file
  const char* htmlBytes = [outputHTML UTF8String];
  NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:htmlPath
                                                             append:YES];
  [stream open];
  [stream write:(const uint8_t *) htmlBytes maxLength:strlen(htmlBytes)];
  [stream close];

  // make a symlink to the latest html
  NSString *symlinkName = [NSString stringWithFormat:@"%@_http_log_newest.html",
    processName];
  NSString *symlinkPath = [logDirectory stringByAppendingPathComponent:symlinkName];

#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_5
  // Compiling for 10.5 or later, just use the new apis
  [fileManager removeItemAtPath:symlinkPath error:NULL];
  [fileManager createSymbolicLinkAtPath:symlinkPath
                    withDestinationPath:htmlPath
                                  error:NULL];
#else
  // Check at runtime if we have the newer api and use that, otherwise, just
  // use the older api (we avoid it to avoid console messages).
  if ([fileManager respondsToSelector:@selector(removeItemAtPath:error:)]) {
    [fileManager removeItemAtPath:symlinkPath error:NULL];
  } else {
    [fileManager removeFileAtPath:symlinkPath handler:nil];
  }
  if ([fileManager respondsToSelector:@selector(createSymbolicLinkAtPath:withDestinationPath:error:)]) {
    [fileManager createSymbolicLinkAtPath:symlinkPath
                      withDestinationPath:htmlPath
                                    error:NULL];
  } else {
    [fileManager createSymbolicLinkAtPath:symlinkPath pathContent:htmlPath];
  }
#endif
}

- (void)logCapturePostStream {

  // This is called when beginning a fetch.  The caller should have already
  // verified that logging is enabled, and should have allocated
  // loggedStreamData_ as a mutable object.

  // If we're logging, we need to wrap the upload stream with our monitor
  // stream subclass that will call us back with the bytes being read from the
  // stream

  // our wrapper will retain the old post stream
  [postStream_ autorelease];

  // length can be
  postStream_ = [GDataInputStreamLogger inputStreamWithStream:postStream_
                                                       length:0];
  [postStream_ retain];
  [(GDataInputStreamLogger *)postStream_ setMonitorDelegate:self];

  // we don't really want monitoring callbacks; our subclass will be
  // calling our appendLoggedStreamData: method at every read instead
  [(GDataInputStreamLogger *)postStream_ setMonitorSelector:nil];
}

- (void)appendLoggedStreamData:(NSData *)newData {
  [loggedStreamData_ appendData:newData];
}

#endif // !STRIP_GDATA_FETCH_LOGGING
@end

#if !STRIP_GDATA_FETCH_LOGGING
@implementation GDataInputStreamLogger
- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len {

  // capture the read stream data, and pass it to the delegate to append to
  NSInteger result = [super read:buffer maxLength:len];
  if (result >= 0) {
    NSData *data = [NSData dataWithBytes:buffer length:result];
    [monitorDelegate_ appendLoggedStreamData:data];
  }
  return result;
}
@end
#endif // !STRIP_GDATA_FETCH_LOGGING
