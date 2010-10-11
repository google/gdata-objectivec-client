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

#if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_OAUTH

#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_5

// This class implements the OAuth 1.0a protocol for creating and signing
// requests. http://oauth.net/core/1.0a/
//
// Users can rely on +authForInstalledApp for creating a complete authentication
// object for use with Google's OAuth protocol.
//
// The user (typically the GDataOAuthSignIn object) can call the methods
//  - (void)setKeysForResponseData:(NSData *)data;
//  - (void)setKeysForResponseString:(NSString *)str;
//
// to set the parameters following each server interaction, and then can use
// - (BOOL)authorizeRequest:(NSMutableURLRequest *)request
//
// to add the "Authorization: OAuth ..." header to future resource requests.

#import <Foundation/Foundation.h>

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GDATAOAUTHAUTHENTICATION_DEFINE_GLOBALS
#define _EXTERN
#define _INITIALIZE_AS(x) =x
#else
#define _EXTERN extern
#define _INITIALIZE_AS(x)
#endif

_EXTERN NSString* const kGDataOAuthServiceProviderGoogle _INITIALIZE_AS(@"Google");

_EXTERN NSString* const kGDataOAuthSignatureMethodHMAC_SHA1 _INITIALIZE_AS(@"HMAC-SHA1");

//
// GDataOAuthSignIn constants, included here for use by clients
//
_EXTERN NSString* const kGDataOAuthErrorDomain  _INITIALIZE_AS(@"com.google.GDataOAuth");

// notifications for token fetches
_EXTERN NSString* const kGDataOAuthFetchStarted _INITIALIZE_AS(@"kGDataOAuthFetchStarted");
_EXTERN NSString* const kGDataOAuthFetchStopped _INITIALIZE_AS(@"kGDataOAuthFetchStopped");

_EXTERN NSString* const kGDataOAuthFetchTypeKey      _INITIALIZE_AS(@"FetchType");
_EXTERN NSString* const kGDataOAuthFetchTypeRequest  _INITIALIZE_AS(@"request");
_EXTERN NSString* const kGDataOAuthFetchTypeAccess   _INITIALIZE_AS(@"access");
_EXTERN NSString* const kGDataOAuthFetchTypeUserInfo _INITIALIZE_AS(@"userInfo");

// notification for network loss during html sign-in display
_EXTERN NSString* const kGDataOAuthNetworkLost       _INITIALIZE_AS(@"kGDataOAuthNetworkLost");
_EXTERN NSString* const kGDataOAuthNetworkFound      _INITIALIZE_AS(@"kGDataOAuthNetworkFound");

#if GDATA_OAUTH_SUPPORTS_RSASHA1_SIGNING
_EXTERN NSString* const kGDataOAuthSignatureMethodRSA_SHA1  _INITIALIZE_AS(@"RSA-SHA1");
#endif

@interface GDataOAuthAuthentication : NSObject {
 @private
  // paramValues_ contains the parameters used in requests and responses
  NSMutableDictionary *paramValues_;

  NSString *realm_;
  NSString *privateKey_;
  NSString *timestamp_; // set for testing only
  NSString *nonce_;     // set for testing only

  // flag indicating if the token in paramValues is a request token or an
  // access token
  BOOL hasAccessToken_;

  // flag indicating if authorizeRequest: adds a header or parameters
  BOOL shouldUseParamsToAuthorize_;

  id userData_;
}

// OAuth protocol parameters
//
// timestamp (seconds since 1970) and nonce (random number) are generated
// uniquely for each request, except during testing, when they may be set
// explicitly
@property (nonatomic, copy) NSString *scope;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *hostedDomain;
@property (nonatomic, copy) NSString *domain;
@property (nonatomic, copy) NSString *iconURLString;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *consumerKey;
@property (nonatomic, copy) NSString *signatureMethod;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *callback;
@property (nonatomic, copy) NSString *verifier;
@property (nonatomic, copy) NSString *tokenSecret;
@property (nonatomic, copy) NSString *callbackConfirmed;
@property (nonatomic, copy) NSString *timestamp;
@property (nonatomic, copy) NSString *nonce;

// other standard non-parameter OAuth protocol properties
@property (nonatomic, copy) NSString *realm;
@property (nonatomic, copy) NSString *privateKey;

// service identifier, like "Google"; not used for authentication or signing
@property (nonatomic, copy) NSString *serviceProvider;

// user email and verified status; not used for authentication or signing
//
// The verified string can be checked with -boolValue. If the result is false,
// then the email address is listed with the account on the server, but the
// address has not been confirmed as belonging to the owner of the account.
@property (nonatomic, copy) NSString *userEmail;
@property (nonatomic, copy) NSString *userEmailIsVerified;

// property for using a previously-authorized access token
@property (nonatomic, copy) NSString *accessToken;

// property indicating if authorization is done with parameters rather than a
// header
@property (nonatomic, assign) BOOL shouldUseParamsToAuthorize;

// userData is retained for the convenience of the caller
@property (nonatomic, retain) id userData;


// Create an authentication object, with hardcoded values for installed apps
// with HMAC-SHA1 as signature method, and "anonymous" as the consumer key and
// consumer secret (private key).
+ (GDataOAuthAuthentication *)authForInstalledApp;

// Create an authentication object, specifying the consumer key and
// private key (both anonymous for installed apps) and the signature method
// ("HMAC-SHA1" for installed apps).
//
// For signature method "RSA-SHA1", a proper consumer key and private key
// may be supplied (and the GDATA_OAUTH_SUPPORTS_RSASHA1_SIGNING compiler
// conditional must be set.)
- (id)initWithSignatureMethod:(NSString *)signatureMethod
                  consumerKey:(NSString *)consumerKey
                   privateKey:(NSString *)privateKey;

// clear out any authentication values, prepare for a new request fetch
- (void)reset;

// authorization entry point for GData library
- (BOOL)authorizeRequest:(NSMutableURLRequest *)request;
- (BOOL)canAuthorize;

// add OAuth headers
//
// any non-OAuth parameters (such as scope) will be included in the signature
// but added as a URL parameter, not in the Auth header
- (void)addRequestTokenHeaderToRequest:(NSMutableURLRequest *)request;
- (void)addAuthorizeTokenHeaderToRequest:(NSMutableURLRequest *)request;
- (void)addAccessTokenHeaderToRequest:(NSMutableURLRequest *)request;
- (void)addResourceTokenHeaderToRequest:(NSMutableURLRequest *)request;

// add OAuth URL params, as an alternative to adding headers
- (void)addRequestTokenParamsToRequest:(NSMutableURLRequest *)request;
- (void)addAuthorizeTokenParamsToRequest:(NSMutableURLRequest *)request;
- (void)addAccessTokenParamsToRequest:(NSMutableURLRequest *)request;
- (void)addResourceTokenParamsToRequest:(NSMutableURLRequest *)request;

// parse and set token and token secret from response data
- (void)setKeysForResponseData:(NSData *)data;
- (void)setKeysForResponseString:(NSString *)str;

// persistent token string for keychain storage
//
// we'll use the format "oauth_token=foo&oauth_token_secret=bar" so we can
// easily alter what portions of the auth data are stored
- (NSString *)persistenceResponseString;
- (void)setKeysForPersistenceResponseString:(NSString *)str;

// method for distinguishing between the OAuth token being a request token and
// an access token
- (BOOL)hasAccessToken;
- (void)setHasAccessToken:(BOOL)flag;

// methods for unit testing
+ (NSString *)normalizeQueryString:(NSString *)str;

//
// utilities
//

+ (NSString *)encodedOAuthParameterForString:(NSString *)str;
+ (NSString *)unencodedOAuthParameterForString:(NSString *)str;

+ (NSDictionary *)dictionaryWithResponseData:(NSData *)data;
+ (NSDictionary *)dictionaryWithResponseString:(NSString *)responseStr;

+ (NSString *)stringWithBase64ForData:(NSData *)data;

+ (NSString *)HMACSHA1HashForConsumerSecret:(NSString *)consumerSecret
                                tokenSecret:(NSString *)tokenSecret
                                       body:(NSString *)body;

#if GDATA_OAUTH_SUPPORTS_RSASHA1_SIGNING
+ (NSString *)RSASHA1HashForString:(NSString *)source
               privateKeyPEMString:(NSString *)key;
#endif

@end

#endif // #if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_5

#endif // #if !GDATA_REQUIRE_SERVICE_INCLUDES || GDATA_INCLUDE_OAUTH
