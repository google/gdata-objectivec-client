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

#import "GDataProgressMonitorInputStream.h"

@interface GDataInputStreamLogger : GDataProgressMonitorInputStream
// GDataInputStreamLogger is wraps any NSInputStream used for
// uploading so we can capture a copy of the data for the log
@end

@implementation GDataHTTPFetcher (GDataHTTPFetcherLogging)

// if STRIP_GDATA_FETCH_LOGGING is defined by the user's project then 
// logging code will not be compiled into the framework

#ifdef STRIP_GDATA_FETCH_LOGGING
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
static NSMutableString* gLoggingProcessName = nil; 

+ (void)setLoggingDirectory:(NSString *)path {
  [gLoggingDirectoryPath autorelease];
  gLoggingDirectoryPath = [path copy];
}

+ (NSString *)loggingDirectory {
  
  if (!gLoggingDirectoryPath) {
    
    // default to a directory called GDataHTTPDebugLogs in the desktop folder
    NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, 
                                                       NSUserDomainMask, YES);
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
        doesFolderExist = [fileManager createDirectoryAtPath:logsFolderPath 
                                                  attributes:nil];
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
    
    CFStringRef procName;
    ProcessSerialNumber currentPSN = { 0, kCurrentProcess };
    if (CopyProcessName(&currentPSN, &procName) == noErr) {
      gLoggingProcessName = [[NSMutableString alloc] initWithString:(NSString *)procName];
      [gLoggingProcessName replaceOccurrencesOfString:@" " 
                                    withString:@"_" 
                                       options:0 
                                         range:NSMakeRange(0, [gLoggingProcessName length])];
      CFRelease(procName);
    } else {
      gLoggingProcessName = @"proc";
    }
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
    // TODO(grobbins) remove use of NSCalendarDate since Apple will eventually
    // deprecate it in favor of formatters
    
    // produce a string like 08-21_01-41-23PM
    gLoggingDateStamp = [[[NSCalendarDate calendarDate] descriptionWithCalendarFormat:@"%m-%d_%I-%M-%S%p"] retain];
  }
  return gLoggingDateStamp;
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
    unsigned int origLength = [originalStr length];
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
  NSString *streamDataStr = [[[NSString alloc] initWithData:data
                                   encoding:NSUTF8StringEncoding] autorelease];
  if (streamDataStr) return streamDataStr;
    
  // Munge a buffer by replacing non-ASCII bytes with underscores,
  // and turn that munged buffer an NSString.  That gives us a string
  // we can use with NSScanner.
  NSMutableData *mutableData = [NSMutableData dataWithData:data];
  unsigned char *bytes = [mutableData mutableBytes];
  
  for (int idx = 0; idx < [mutableData length]; idx++) {
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
      int offset = 0;
      for (int partIdx = 0; partIdx < [mungedParts count]; partIdx++) {
        
        NSString *mungedPart = [mungedParts objectAtIndex:partIdx];
        int partSize = [mungedPart length];
        
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
          NSString *binStr = [NSString stringWithFormat:@"\r%@\r<<%u bytes>>\r",
            header, partSize - [header length]];
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
  
  // TODO(grobbins)  add Javascript to display response data formatted in hex
  
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
  unsigned int responseDataLength = [downloadedData_ length];
  
  NSURLResponse *response = [self response];
  NSString *responseBaseName = nil;
  
  // if there's response data, decide what kind of file to put it in based  
  // on the first bytes of the file or on the mime type supplied by the server
  if (responseDataLength) {
    NSString *responseDataExtn = nil;

    // generate a response file base name like
    //   SyncProto_http_response_10-16_01-56-58PM_3
    responseBaseName = [NSString stringWithFormat:@"%@_http_response_%@_%d",
      processName, dateStamp, zResponseCounter];
    
    NSString *dataStr = [[[NSString alloc] initWithData:downloadedData_ 
                                   encoding:NSUTF8StringEncoding] autorelease];
    if (dataStr) {
      // we were able to make a UTF-8 string from the response data
      
      NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceCharacterSet];
      dataStr = [dataStr stringByTrimmingCharactersInSet:whitespaceSet];
      
      // save a plain-text version of the response data in an html cile  
      // containing a wrapped, scrollable <textarea>
      //
      // we'll use <textarea rows="33" cols="108" readonly=true wrap=soft>
      //   </textarea>  to fit inside our iframe
      responseDataUnformattedFileName = [responseBaseName stringByAppendingPathExtension:@"html"];
      NSString *textFilePath = [logDirectory stringByAppendingPathComponent:responseDataUnformattedFileName];
      
      NSString* wrapFmt = @"<textarea rows=\"33\" cols=\"108\" readonly=true"
        " wrap=soft>\n%@\n</textarea>";
      NSString* wrappedStr = [NSString stringWithFormat:wrapFmt, dataStr];
      [wrappedStr writeToFile:textFilePath 
                   atomically:NO 
                     encoding:NSUTF8StringEncoding 
                        error:nil];
      
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

      [downloadedData_ writeToFile:formattedFilePath atomically:NO];
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
      "content=\"text/html; charset=UTF-8\"><title>%@ HTTP fetch log %@</title></head>",
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
    [outputHTML appendFormat:scriptFormat];

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
      "iFrameElem.src=newsrc; }</script>\n";
    [outputHTML appendFormat:toggleIFScriptFormat];
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
      int status = [(NSHTTPURLResponse *)response statusCode];
      statusString = @"200";
      if (status != 200) {
        // purple for errors
        statusString = [NSString stringWithFormat:@"<FONT COLOR=\"#FF00FF\">%d</FONT>",
          status];
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
      [outputHTML appendFormat:@"&nbsp;&nbsp;<a href=%@>stand-alone</a><br>\n",
        responseDataFormattedFileName];
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
      [outputHTML appendFormat:@"&nbsp;&nbsp;<a href=%@>stand-alone</a><br>\n",
        responseDataUnformattedFileName];
    }
    
    // make the iframe
    NSString *divHTMLFormat = @"<div id=\"%@\">%@</div><br>\n";
    NSString *src = responseDataFormattedFileName ?  
      responseDataFormattedFileName : responseDataUnformattedFileName;
    NSString *iframeFmt = @" <iframe src=\"%@\" id=\"%@\" width=800 height=400>"
      "\n<a href=\"%@\">%@</a>\n </iframe>\n";
    NSString *dataIFrameHTML = [NSString stringWithFormat:iframeFmt,
      src, dataIFrameID, src, src];
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
  [stream write:(const u_int8_t *) htmlBytes maxLength:strlen(htmlBytes)];
  [stream close];
  
  // make a symlink to the latest html
  NSString *symlinkName = [NSString stringWithFormat:@"%@_http_log_newest.html", 
    processName];
  NSString *symlinkPath = [logDirectory stringByAppendingPathComponent:symlinkName];
  [fileManager removeFileAtPath:symlinkPath handler:nil];
  [fileManager createSymbolicLinkAtPath:symlinkPath pathContent:htmlPath];
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

@implementation GDataInputStreamLogger
- (int)read:(uint8_t *)buffer maxLength:(unsigned int)len {
  
  // capture the read stream data, and pass it to the delegate to append to
  int result = [super read:buffer maxLength:len];
  if (result >= 0) {
    NSData *data = [NSData dataWithBytes:buffer length:result];
    [monitorDelegate_ appendLoggedStreamData:data];
  }
  return result;
}
@end

