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
//  GDataAuthenticationFetcher.h
//

#import "GDataHTTPFetcher.h"

@interface GDataAuthenticationFetcher : NSObject

// authTokenFetcherWithUsername: returns a GDataHTTPFetcher
//
// serviceID is the code for the service to be used, like "cl"
// source is the app's identifier, in the form companyName-applicationName-versionID
// domain should be nil to authenticate against www.google.com; it may be
//   localhost:n for unit testing to port n
// params is a dictionary with additional parameters for the post body,
//   such as the captcha token and response
// headers are custom headers to be added to the request
//
// The user should invoke the fetcher's beginFetchWithDelegate: method
// and provide the callbacks, consistent with the GDataHTTPFetcher
// conventions.
//
+ (GDataHTTPFetcher *)authTokenFetcherWithUsername:(NSString *)username
                                          password:(NSString *)password
                                           service:(NSString *)serviceID
                                            source:(NSString *)source
                                      signInDomain:(NSString *)domain
                                       accountType:(NSString *)accountType
                              additionalParameters:(NSDictionary *)params
                                     customHeaders:(NSDictionary *)headers;
@end
