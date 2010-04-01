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
//  GDataHTTPUploadFetcher.h
//

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE \
  || GDATA_INCLUDE_YOUTUBE_SERVICE

//
// This subclass of GDataHTTPFetcher simulates the series of fetches
// needed for chunked upload as a single fetch operation.
//
// Protocol document:
//   http://code.google.com/p/gears/wiki/ResumableHttpRequestsProposal
//
// To the client, the only fetcher that exists is this class; the subsidiary
// fetchers needed for uploading chunks are not visible (though the most recent
// chunk fetcher may be accessed via the -activeFetcher method, and
// -responseHeaders and -statusCode reflect results from the most recent chunk
// fetcher.)
//
// Chunk fetchers are discarded as soon as they have completed.
//

#pragma once

#import "GDataHTTPFetcher.h"

// async retrieval of an http get or post
@interface GDataHTTPUploadFetcher : GDataHTTPFetcher {
  GDataHTTPFetcher *chunkFetcher_;

  // we'll call through to the delegate's sentData and finished selectors
  SEL delegateSentDataSEL_;
  SEL delegateFinishedSEL_;

  BOOL needsManualProgress_;

  // the initial fetch's body length and bytes actually sent are
  // needed for calculating progress during subsequent chunk uploads
  NSUInteger initialBodyLength_;
  NSUInteger initialBodySent_;

  NSURL *locationURL_;

  // uploadData_ or uploadFileHandle_ may be set, but not both
  NSData *uploadData_;
  NSFileHandle *uploadFileHandle_;
  NSInteger uploadFileHandleLength_;
  NSString *uploadMIMEType_;
  NSUInteger chunkSize_;
  BOOL isPaused_;

  // we keep the latest offset into the upload data just for
  // progress reporting
  NSUInteger currentOffset_;

  // we store the response headers and status code for the most recent
  // chunk fetcher
  NSDictionary *responseHeaders_;
  NSInteger statusCode_;
}

+ (GDataHTTPUploadFetcher *)uploadFetcherWithRequest:(NSURLRequest *)request
                                          uploadData:(NSData *)data
                                      uploadMIMEType:(NSString *)uploadMIMEType
                                           chunkSize:(NSUInteger)chunkSize;

+ (GDataHTTPUploadFetcher *)uploadFetcherWithRequest:(NSURLRequest *)request
                                    uploadFileHandle:(NSFileHandle *)fileHandle
                                      uploadMIMEType:(NSString *)uploadMIMEType
                                           chunkSize:(NSUInteger)chunkSize;

- (id)initWithRequest:(NSURLRequest *)request
           uploadData:(NSData *)data
     uploadFileHandle:(NSFileHandle *)fileHandle
       uploadMIMEType:(NSString *)uploadMIMEType
            chunkSize:(NSUInteger)chunkSize;

- (void)pauseFetching;
- (void)resumeFetchingWithDelegate:(id)delegate;
- (BOOL)isPaused;

- (NSURL *)locationURL;
- (void)setLocationURL:(NSURL *)url;

- (NSData *)uploadData;
- (void)setUploadData:(NSData *)data;

- (NSFileHandle *)uploadFileHandle;
- (void)setUploadFileHandle:(NSFileHandle *)fileHandle;

- (NSString *)uploadMIMEType;
- (void)setUploadMIMEType:(NSString *)str;

- (NSUInteger)chunkSize;
- (void)setChunkSize:(NSUInteger)val;

- (NSUInteger)currentOffset;
- (void)setCurrentOffset:(NSUInteger)val;

- (GDataHTTPFetcher *)chunkFetcher;
- (void)setChunkFetcher:(GDataHTTPFetcher *)fetcher;

// the active fetcher is the last chunk fetcher, or the upload fetcher itself
// if no chunk fetcher has yet been created
- (GDataHTTPFetcher *)activeFetcher;

// the response headers from the most recently-completed fetch
- (NSDictionary *)responseHeaders;
- (void)setResponseHeaders:(NSDictionary *)dict;

// the status code from the most recently-completed fetch
- (NSInteger)statusCode;
- (void)setStatusCode:(NSInteger)val;

@end

#endif // !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_DOCS_SERVICE || GDATA_INCLUDE_YOUTUBE_SERVICE
