/* Copyright (c) 2010 Google Inc.
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
//  GDataHTTPUploadFetcher.m
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE \
  || GDATA_INCLUDE_YOUTUBE_SERVICE

#import "GDataHTTPUploadFetcher.h"

static NSString* const kUploadFetcherRetainedDelegateKey =  @"_uploadDelegate";

static NSUInteger const kQueryServerForOffset = NSUIntegerMax;

@interface GDataHTTPUploadFetcher (InternalMethods)
- (void)uploadNextChunkWithOffset:(NSUInteger)offset
                         delegate:(id)delegate;
- (void)uploadNextChunkWithOffset:(NSUInteger)offset
                fetcherProperties:(NSDictionary *)props;
- (void)destroyChunkFetcher;

- (void)uploadFetcher:(GDataHTTPFetcher *)fetcher
         didSendBytes:(NSInteger)bytesSent
       totalBytesSent:(NSInteger)totalBytesSent
totalBytesExpectedToSend:(NSInteger)totalBytesExpected;

- (void)reportProgressManually;

- (NSUInteger)fullUploadLength;

// private methods of the superclass
- (void)invokeSentDataCallback:(SEL)sel
                        target:(id)target
               didSendBodyData:(NSInteger)bytesWritten
             totalBytesWritten:(NSInteger)totalBytesWritten
     totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;

- (void)invokeStatusCallback:(SEL)sel
                      target:(id)target
                      status:(NSInteger)status
                        data:(NSData *)data;

- (BOOL)invokeRetryCallback:(SEL)sel
                     target:(id)target
                  willRetry:(BOOL)willRetry
                      error:(NSError *)error;

- (void)chunkFetcher:(GDataHTTPFetcher *)chunkFetcher
    finishedWithData:(NSData *)data;
- (void)chunkFetcher:(GDataHTTPFetcher *)chunkFetcher
    failedWithStatus:(NSInteger)status
                data:(NSData *)data;
- (void)chunkFetcher:(GDataHTTPFetcher *)chunkFetcher
failedWithNetworkError:(NSError *)error;
-(BOOL)chunkFetcher:(GDataHTTPFetcher *)chunkFetcher
          willRetry:(BOOL)willRetry
           forError:(NSError *)error;
@end

@implementation GDataHTTPUploadFetcher

+ (GDataHTTPUploadFetcher *)uploadFetcherWithRequest:(NSURLRequest *)request
                                          uploadData:(NSData *)data
                                      uploadMIMEType:(NSString *)uploadMIMEType
                                           chunkSize:(NSUInteger)chunkSize {
  return [[[self alloc] initWithRequest:request
                             uploadData:data
                       uploadFileHandle:nil
                         uploadMIMEType:uploadMIMEType
                              chunkSize:chunkSize] autorelease];
}

+ (GDataHTTPUploadFetcher *)uploadFetcherWithRequest:(NSURLRequest *)request
                                    uploadFileHandle:(NSFileHandle *)fileHandle
                                      uploadMIMEType:(NSString *)uploadMIMEType
                                           chunkSize:(NSUInteger)chunkSize {
  return [[[self alloc] initWithRequest:request
                             uploadData:nil
                       uploadFileHandle:fileHandle
                         uploadMIMEType:uploadMIMEType
                              chunkSize:chunkSize] autorelease];
}

- (id)initWithRequest:(NSURLRequest *)request
           uploadData:(NSData *)data
     uploadFileHandle:(NSFileHandle *)fileHandle
       uploadMIMEType:(NSString *)uploadMIMEType
            chunkSize:(NSUInteger)chunkSize {

  self = [super initWithRequest:request];
  if (self) {
#if DEBUG
    NSAssert((data == nil) != (fileHandle == nil),
             @"upload data and fileHandle are mutually exclusive");
#endif

    [self setUploadData:data];
    [self setUploadFileHandle:fileHandle];
    [self setUploadMIMEType:uploadMIMEType];
    [self setChunkSize:chunkSize];

    // add our custom headers to the initial request indicating the data
    // type and total size to be delivered later in the chunk requests
    NSMutableURLRequest *mutableReq = [self request];

    NSString *lengthStr = [NSString stringWithFormat:@"%lu",
                           (unsigned long) [data length]];
    [mutableReq setValue:lengthStr
      forHTTPHeaderField:@"X-Upload-Content-Length"];

    [mutableReq setValue:uploadMIMEType
      forHTTPHeaderField:@"X-Upload-Content-Type"];

    // indicate that we've not yet determined the upload fetcher status
    statusCode_ = -1;

    // indicate that we've not yet determined the file handle's length
    uploadFileHandleLength_ = -1;
  }
  return self;
}

- (void)dealloc {
  [chunkFetcher_ release];
  [locationURL_ release];
  [uploadData_ release];
  [uploadFileHandle_ release];
  [uploadMIMEType_ release];
  [responseHeaders_ release];
  [super dealloc];
}

#pragma mark -

- (NSUInteger)fullUploadLength {
  if (uploadData_) {
    return [uploadData_ length];
  } else {
    if (uploadFileHandleLength_ == -1) {
      // first time through, seek to end to determine file length
      uploadFileHandleLength_ = (NSInteger) [uploadFileHandle_ seekToEndOfFile];
    }
    return uploadFileHandleLength_;
  }
}

- (NSData *)uploadSubdataWithOffset:(NSUInteger)offset
                             length:(NSUInteger)length {
  NSData *resultData = nil;

  if (uploadData_) {
    NSRange range = NSMakeRange(offset, length);
    resultData = [uploadData_ subdataWithRange:range];
  } else {
    @try {
      [uploadFileHandle_ seekToFileOffset:offset];
      resultData = [uploadFileHandle_ readDataOfLength:length];
    }
    @catch (NSException *exception) {
      NSLog(@"uploadFileHandle exception: %@", exception);
    }
  }

  return resultData;
}

#pragma mark Method overrides affecting the initial fetch only

- (BOOL)beginFetchWithDelegate:(id)delegate
             didFinishSelector:(SEL)finishedSEL
     didFailWithStatusSelector:(SEL)statusFailedSEL
      didFailWithErrorSelector:(SEL)networkFailedSEL {

  AssertSelectorNilOrImplementedWithArguments(delegate, finishedSEL, @encode(GDataHTTPFetcher *), @encode(NSData *), 0);

  // we don't support block callbacks since retaining them across pauses
  // would be messy
#if DEBUG && NS_BLOCKS_AVAILABLE
  NSAssert(completionBlock_ == NULL && sentDataBlock_ == NULL
           && retryBlock_ == NULL && receivedDataBlock_ == NULL,
           @"block callbacks not supported by upload fetcher");
#endif

  // replace the finishedSEL with our own, since the initial finish callback
  // is just the beginning of the upload experience
  delegateFinishedSEL_ = finishedSEL;

  // if the client is running on 10.4 or iPhone 2, we may need to manually
  // send progress indication since NSURLConnection won't be calling back
  // to us during uploads
  needsManualProgress_ = ![GDataHTTPFetcher doesSupportSentDataCallback];

  initialBodyLength_ = [[self postData] length];

  // we don't need a finish selector since we're overriding
  // -connectionDidFinishLoading
  return [super beginFetchWithDelegate:delegate
                     didFinishSelector:NULL
             didFailWithStatusSelector:statusFailedSEL
              didFailWithErrorSelector:networkFailedSEL];
}

- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {

  // ignore this callback if we're doing manual progress, mainly so that
  // we won't see duplicate progress callbacks when testing with
  // doesSupportSentDataCallback turned off
  if (needsManualProgress_) return;

  [self uploadFetcher:self
         didSendBytes:bytesWritten
       totalBytesSent:totalBytesWritten
totalBytesExpectedToSend:totalBytesExpectedToWrite];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

  // we land here once the initial fetch sending the initial POST body
  // has completed

  // we keep the delegate retained for as long as we have chunk fetchers
  // pending (but holding it in their properties); otherwise, it would
  // be released by our superclass when the connectionDidFinishLoading is called
  id uploadDelegate = [[[self delegate] retain] autorelease];

  [super connectionDidFinishLoading:connection];

  NSInteger statusCode = [super statusCode];
  [self setStatusCode:statusCode];

  if (statusCode >= 300) return;

#if DEBUG
  NSAssert([[self downloadedData] length] == 0,
                    @"unexpected response data");
#endif

  // we need to get the upload URL from the location header to continue
  NSDictionary *responseHeaders = [self responseHeaders];
  NSString *locationURLStr = [responseHeaders objectForKey:@"Location"];
#if DEBUG
  NSAssert([locationURLStr length] > 0, @"need upload location hdr");
#endif

  if ([locationURLStr length] == 0) {
    // we cannot continue since we do not know the location to use
    // as our upload destination
    //
    // we'll consider this status 501 Not Implemented
    if (statusFailedSEL_) {
      [self invokeStatusCallback:statusFailedSEL_
                          target:uploadDelegate
                          status:501
                            data:[self downloadedData]];
    }
    return;
  }

  [self setLocationURL:[NSURL URLWithString:locationURLStr]];

  // we've now sent all of the initial post body data, so we need to include
  // its size in future progress indicator callbacks
  initialBodySent_ = initialBodyLength_;

  if (needsManualProgress_) {
    [self reportProgressManually];
  }

  // just in case the user paused us during the initial fetch...
  if (![self isPaused]) {
    [self uploadNextChunkWithOffset:0
                           delegate:uploadDelegate];
  }
}

#pragma mark Chunk fetching methods

- (void)uploadNextChunkWithOffset:(NSUInteger)offset
                         delegate:(id)delegate {
  NSMutableDictionary *props;

  // we'll retain the delegate as part of the chunk fetcher properties;
  // once there is no longer an active chunk fetcher, we do not need
  // to be retaining the delegate since we won't be calling back into it
  props = [NSMutableDictionary dictionaryWithDictionary:[self properties]];

  [props setValue:delegate
           forKey:kUploadFetcherRetainedDelegateKey];

  [self uploadNextChunkWithOffset:offset
                fetcherProperties:props];
}

- (void)uploadNextChunkWithOffset:(NSUInteger)offset
                fetcherProperties:(NSDictionary *)props {
  // upload another chunk
  NSUInteger chunkSize = [self chunkSize];

  NSString *rangeStr, *lengthStr;
  NSData *chunkData;

  NSUInteger dataLen = [self fullUploadLength];

  if (offset == kQueryServerForOffset) {
    // resuming, so we'll initially send an empty data block and wait for the
    // server to tell us where the current offset really is
    chunkData = [NSData data];
    rangeStr = [NSString stringWithFormat:@"bytes */%lu", dataLen];
    lengthStr = @"0";
    offset = 0;
  } else {
    // uploading the next data chunk
#if DEBUG
    NSAssert2(offset < dataLen, @"offset %lu exceeds data length %lu",
              offset, dataLen);
#endif

    NSUInteger thisChunkSize = chunkSize;

    // if the chunk size is bigger than the remaining data, or else
    // it's close enough in size to the remaining data that we'd rather
    // avoid having a whole extra http fetch for the leftover bit, then make
    // this chunk size exactly match the remaining data size
    BOOL isChunkTooBig = (thisChunkSize + offset > dataLen);
    BOOL isChunkAlmostBigEnough = (dataLen - offset < thisChunkSize + 2500);

    if (isChunkTooBig || isChunkAlmostBigEnough) {
      thisChunkSize = dataLen - offset;
    }

    chunkData = [self uploadSubdataWithOffset:offset
                                       length:thisChunkSize];

    rangeStr = [NSString stringWithFormat:@"bytes %lu-%lu/%lu",
                          offset, offset + thisChunkSize - 1, dataLen];
    lengthStr = [NSString stringWithFormat:@"%lu", thisChunkSize];
  }

  // track the current offset for progress reporting
  [self setCurrentOffset:offset];

  //
  // make the request for fetching
  //

  // the chunk upload URL requires no authentication header
  NSURL *locURL = [self locationURL];
  NSMutableURLRequest *chunkRequest = [NSMutableURLRequest requestWithURL:locURL];

  [chunkRequest setHTTPMethod:@"PUT"];

  // copy the user-agent from the original connection
  NSURLRequest *origRequest = [self request];
  NSString *userAgent = [origRequest valueForHTTPHeaderField:@"User-Agent"];
  if ([userAgent length] > 0) {
    [chunkRequest setValue:userAgent forHTTPHeaderField:@"User-Agent"];
  }

  [chunkRequest setValue:rangeStr forHTTPHeaderField:@"Content-Range"];
  [chunkRequest setValue:lengthStr forHTTPHeaderField:@"Content-Length"];

  NSString *uploadMIMEType = [self uploadMIMEType];
  [chunkRequest setValue:uploadMIMEType forHTTPHeaderField:@"Content-Type"];

  //
  // make a new fetcher
  //
  GDataHTTPFetcher *chunkFetcher;

  chunkFetcher = [GDataHTTPFetcher httpFetcherWithRequest:chunkRequest];
  [chunkFetcher setRunLoopModes:[self runLoopModes]];

  // give the chunk fetcher the same properties as the previous chunk fetcher
  [chunkFetcher setProperties:props];

  // post the appropriate subset of the full data
  [chunkFetcher setPostData:chunkData];

  // copy other fetcher settings to the new fetcher
  [chunkFetcher setIsRetryEnabled:[self isRetryEnabled]];
  [chunkFetcher setMaxRetryInterval:[self maxRetryInterval]];
  [chunkFetcher setSentDataSelector:[self sentDataSelector]];
  [chunkFetcher setCookieStorageMethod:[self cookieStorageMethod]];

  if ([self isRetryEnabled]) {
    // we interpose our own retry method both so the sender is the upload
    // fetcher, and so we can change the request to ask the server to
    // tell us where to resume the chunk
    [chunkFetcher setRetrySelector:@selector(chunkFetcher:willRetry:forError:)];
  }

  [self setRequest:chunkRequest];

  // when fetching chunks, a 308 status means "upload more chunks", but
  // success (200 or 201 status) and other failures are no different than
  // for the regular object fetchers
  BOOL didFetch = [chunkFetcher beginFetchWithDelegate:self
                                     didFinishSelector:@selector(chunkFetcher:finishedWithData:)
                             didFailWithStatusSelector:@selector(chunkFetcher:failedWithStatus:data:)
                              didFailWithErrorSelector:@selector(chunkFetcher:failedWithNetworkError:)];
  if (!didFetch) {
    // something went horribly wrong, like the chunk upload URL is invalid
    NSError *error = [NSError errorWithDomain:kGDataHTTPFetcherErrorDomain
                                         code:kGDataHTTPFetcherErrorChunkUploadFailed
                                     userInfo:nil];

    id delegate = [props valueForKey:kUploadFetcherRetainedDelegateKey];
    [delegate performSelector:networkFailedSEL_
                   withObject:self
                   withObject:error];

    [self destroyChunkFetcher];
  } else {
    // hang on to the fetcher in case we need to cancel it
    [self setChunkFetcher:chunkFetcher];
  }
}

- (void)reportProgressManually {
  // reportProgressManually should be called only when there's no
  // NSURLConnection support for sent data callbacks

  // the user wants upload progress, and there's no support in NSURLConnection
  // for it, so we'll provide it here after each chunk
  //
  // the progress will be based on the uploadData and currentOffset,
  // so we can pass zeros
  [self uploadFetcher:self
         didSendBytes:0
       totalBytesSent:0
totalBytesExpectedToSend:0];
}

- (void)chunkFetcher:(GDataHTTPFetcher *)chunkFetcher finishedWithData:(NSData *)data {
  // the final chunk has uploaded successfully
#if DEBUG
  NSInteger status = [chunkFetcher statusCode];
  NSAssert1(status == 200 || status == 201,
            @"unexpected chunks status %d", status);
#endif

  // take the chunk fetcher's data as our own
  [downloadedData_ setData:data];

  [self setStatusCode:[chunkFetcher statusCode]];
  [self setResponseHeaders:[chunkFetcher responseHeaders]];

  if (needsManualProgress_) {
    // do a final upload progress report, indicating all of the chunk data
    // has been sent
    NSUInteger fullDataLength = [self fullUploadLength] + initialBodyLength_;
    [self setCurrentOffset:fullDataLength];

    [self reportProgressManually];
  }

  // we're done
  if (delegateFinishedSEL_) {
    id delegate = [chunkFetcher propertyForKey:kUploadFetcherRetainedDelegateKey];
    [delegate performSelector:delegateFinishedSEL_
                   withObject:self
                   withObject:data];
  }

  [self destroyChunkFetcher];
}

- (void)chunkFetcher:(GDataHTTPFetcher *)chunkFetcher failedWithStatus:(NSInteger)status data:(NSData *)data {
  // status 308 is "resume incomplete", meaning we should get the offset
  // from the Range header and upload the next chunk
  //
  // any other status really is an error

  [self setStatusCode:[chunkFetcher statusCode]];
  [self setResponseHeaders:[chunkFetcher responseHeaders]];

  if (status != 308) {
    // some unexpected status has occurred; handle it as we would a regular
    // object fetcher failure
    if (statusFailedSEL_) {
      // not retrying, call status failure callback
      id delegate = [chunkFetcher propertyForKey:kUploadFetcherRetainedDelegateKey];

      [self invokeStatusCallback:statusFailedSEL_
                          target:delegate
                          status:status
                            data:data];

      [self destroyChunkFetcher];
    }

    return;
  }

  NSDictionary *responseHeaders = [chunkFetcher responseHeaders];

  // parse the Range header from the server, since that tells us where we really
  // want the next chunk to begin.
  //
  // lack of a range header means the server has no bytes stored for this upload
  NSString *rangeStr = [responseHeaders objectForKey:@"Range"];
  NSUInteger newOffset = 0;
  if (rangeStr != nil) {
    // parse a content-range, like "bytes=0-999", to find where our new
    // offset for uploading from the data really is (at the end of the
    // range)
    NSScanner *scanner = [NSScanner scannerWithString:rangeStr];
    long long rangeStart = 0, rangeEnd = 0;
    if ([scanner scanString:@"bytes=" intoString:nil]
        && [scanner scanLongLong:&rangeStart]
        && [scanner scanString:@"-" intoString:nil]
        && [scanner scanLongLong:&rangeEnd]) {
      newOffset = (NSUInteger)rangeEnd + 1;
    }
  }

  [self setCurrentOffset:newOffset];

  if (needsManualProgress_) {
    [self reportProgressManually];
  }

  // if the response specifies a location, use that for future chunks
  NSString *locationURLStr = [responseHeaders objectForKey:@"Location"];
  if ([locationURLStr length] > 0) {
    [self setLocationURL:[NSURL URLWithString:locationURLStr]];
  }

  // we want to destroy this chunk fetcher before creating the next one, but
  // we want to pass on its properties
  NSDictionary *props = [[[chunkFetcher properties] retain] autorelease];

  // we no longer need to be able to cancel this chunkFetcher
  [self destroyChunkFetcher];

  // We may in the future handle Retry-After and ETag headers per
  // http://code.google.com/p/gears/wiki/ResumableHttpRequestsProposal
  // but they are not currently sent by the upload server

  [self uploadNextChunkWithOffset:newOffset
                fetcherProperties:props];
}

- (void)chunkFetcher:(GDataHTTPFetcher *)chunkFetcher failedWithNetworkError:(NSError *)error {

  [self setStatusCode:0];
  [self setResponseHeaders:[chunkFetcher responseHeaders]];

  // this is fatal; handle the same as we would a failure of the original
  // object fetcher
  if (networkFailedSEL_) {
    id delegate = [chunkFetcher propertyForKey:kUploadFetcherRetainedDelegateKey];
    [delegate performSelector:networkFailedSEL_
                   withObject:self
                   withObject:error];
  }

  [self destroyChunkFetcher];
  return;
}

-(BOOL)chunkFetcher:(GDataHTTPFetcher *)chunkFetcher willRetry:(BOOL)willRetry forError:(NSError *)error {
  if ([error code] == 308
      && [[error domain] isEqual:kGDataHTTPFetcherStatusDomain]) {
    // 308 is a normal chunk fethcher response, not an error
    // that needs to be retried
    return NO;
  }

  if (retrySEL_) {
    // call the client with the upload fetcher as the sender (not the chunk
    // fetcher) to find out if it wants to retry
    id delegate = [chunkFetcher propertyForKey:kUploadFetcherRetainedDelegateKey];

    willRetry = [self invokeRetryCallback:retrySEL_
                                   target:delegate
                                willRetry:willRetry
                                    error:error];
  }

  if (willRetry) {
    // change the request being retried into a query to the server to
    // tell us where to resume
    NSMutableURLRequest *chunkRequest = [chunkFetcher request];

    NSUInteger dataLen = [self fullUploadLength];
    NSString *rangeStr = [NSString stringWithFormat:@"bytes */%lu", dataLen];

    [chunkRequest setValue:rangeStr forHTTPHeaderField:@"Content-Range"];
    [chunkRequest setValue:@"0" forHTTPHeaderField:@"Content-Length"];
    [chunkFetcher setPostData:[NSData data]];

    // we don't know what our actual offset is anymore, but the server
    // will tell us
    [self setCurrentOffset:0];
  }

  return willRetry;
}

- (void)destroyChunkFetcher {
  [chunkFetcher_ stopFetching];
  [chunkFetcher_ setProperties:nil];
  [self setChunkFetcher:nil];
}

// the chunk fetchers use this as their sentData method
- (void)uploadFetcher:(GDataHTTPFetcher *)fetcher
         didSendBytes:(NSInteger)bytesSent
       totalBytesSent:(NSInteger)totalBytesSent
totalBytesExpectedToSend:(NSInteger)totalBytesExpected {

  id delegate = [fetcher propertyForKey:kUploadFetcherRetainedDelegateKey];
  if (delegate && delegateSentDataSEL_) {
    // the actual total bytes sent include the initial XML sent, plus the
    // offset into the batched data prior to this fetcher
    totalBytesSent += initialBodySent_ + currentOffset_;

    // the total bytes expected include the initial XML and the full chunked
    // data, independent of how big this fetcher's chunk is
    totalBytesExpected = initialBodyLength_ + [self fullUploadLength];

    [self invokeSentDataCallback:delegateSentDataSEL_
                          target:delegate
                 didSendBodyData:bytesSent
               totalBytesWritten:totalBytesSent
       totalBytesExpectedToWrite:totalBytesExpected];
  }
}

#pragma mark -

- (BOOL)isPaused {
  return isPaused_;
}

- (void)pauseFetching {
  isPaused_ = YES;

  // pausing just means stopping the current chunk from uploading;
  // when we resume, the magic offset value will force us to send
  // a request to the server to figure out what bytes to start sending
  //
  // we won't try to cancel the initial data upload, but rather will look for
  // the magic offset value in -connectionDidFinishLoading before
  // creating first initial chunk fetcher, just in case the user
  // paused during the initial data upload
  [self destroyChunkFetcher];
}

- (void)resumeFetchingWithDelegate:(id)delegate {
  if (isPaused_) {
    isPaused_ = NO;

    [self uploadNextChunkWithOffset:kQueryServerForOffset
                           delegate:delegate];
  }
}

- (void)stopFetching {
  // overrides the superclass
  [self destroyChunkFetcher];

  [super stopFetching];
}

#pragma mark -

- (NSURL *)locationURL {
  return locationURL_;
}

- (void)setLocationURL:(NSURL *)url {
  [locationURL_ autorelease];
  locationURL_ = [url retain];
}

- (NSData *)uploadData {
  return uploadData_;
}

- (void)setUploadData:(NSData *)data {
  [uploadData_ autorelease];
  uploadData_ = [data retain];
}

- (NSFileHandle *)uploadFileHandle {
  return uploadFileHandle_;
}

- (void)setUploadFileHandle:(NSFileHandle *)fileHandle {
  [uploadFileHandle_ autorelease];
  uploadFileHandle_ = [fileHandle retain];
}

- (NSString *)uploadMIMEType {
  return uploadMIMEType_;
}

- (void)setUploadMIMEType:(NSString *)str {
  [uploadMIMEType_ autorelease];
  uploadMIMEType_ = [str copy];
}

- (NSUInteger)chunkSize {
  return chunkSize_;
}

- (void)setChunkSize:(NSUInteger)val {
  chunkSize_ = val;
}

- (NSUInteger)currentOffset {
  return currentOffset_;
}

- (void)setCurrentOffset:(NSUInteger)val {
  currentOffset_ = val;
}

- (GDataHTTPFetcher *)chunkFetcher {
  return chunkFetcher_;
}

- (void)setChunkFetcher:(GDataHTTPFetcher *)fetcher {
  [chunkFetcher_ autorelease];
  chunkFetcher_ = [fetcher retain];
}

- (NSDictionary *)responseHeaders {
  // overrides the superclass

  // if asked for the fetcher's response, use the most recent fetcher
  if (responseHeaders_) {
    return responseHeaders_;
  } else {
    // no chunk fetcher yet completed, so return whatever we have from the
    // initial fetch
    return [super responseHeaders];
  }
}

- (void)setResponseHeaders:(NSDictionary *)dict {
  [responseHeaders_ autorelease];
  responseHeaders_ = [dict retain];
}

- (NSInteger)statusCode {
  if (statusCode_ != -1) {
    // overrides the superclass to indicate status appropriate to the initial
    // or latest chunk fetch
    return statusCode_;
  } else {
    return [super statusCode];
  }
}

- (void)setStatusCode:(NSInteger)val {
  statusCode_ = val;
}

- (SEL)sentDataSelector {
  // overrides the superclass
  if (delegateSentDataSEL_ && !needsManualProgress_) {
    return @selector(uploadFetcher:didSendBytes:totalBytesSent:totalBytesExpectedToSend:);
  } else {
    return NULL;
  }
}

- (void)setSentDataSelector:(SEL)theSelector {
  // overrides the superclass
  delegateSentDataSEL_ = theSelector;
}

- (GDataHTTPFetcher *)activeFetcher {
  if (chunkFetcher_) {
    return chunkFetcher_;
  } else {
    return self;
  }
}

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE || GDATA_INCLUDE_YOUTUBE_SERVICE
