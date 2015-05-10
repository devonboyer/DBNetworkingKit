//
//  DBURLRequestSerialization.h
//  DBNetworkingKit
//
//  Created by Devon Boyer on 2015-03-18.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @protocol DBURLRequestSerialization
 @abstract The `DBURLRequestSerialization` protocol is adopted by an object that encodes parameters for a specified HTTP requests.
 @discussion Request serializers may encode parameters as query strings, HTTP bodies, setting the appropriate HTTP header fields as necessary. For example, a JSON request serializer may set the HTTP body of the request to a JSON representation, and set the `Content-Type` HTTP header field value to `application/json`.
 */
@protocol DBURLRequestSerialization <NSObject>

- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                               withParameters:(id)parameters
                                        error:(NSError **)error;

@end

/*!
 @class DBHTTPRequestSerializer
 @abstract Conforms to the `DBURLRequestSerialization` protocols, offering a concrete base implementation of query string parameter serialization and default request headers.
 */
@interface DBHTTPRequestSerializer : NSObject <DBURLRequestSerialization>

/*!
 @abstract Creates and returns a serializer with default configuration.
 */
+ (instancetype)serializer;

/*!
 @abstract HTTP methods for which serialized requests will encode parameters as a query string. `GET`, `HEAD`, and `DELETE` by default.
 */
@property (nonatomic) NSSet *HTTPMethodsEncodingParametersInURI;

/*!
 @abstract The timeout interval, in seconds, for created requests. The default timeout interval is 60 seconds.
 */
@property (nonatomic) NSTimeInterval timeoutInterval;

/*!
 @name Configuring HTTP Request Headers
 */

/*!
 @abstract The default headers to be applied to serialized requests.
 @discussion The default headers include values based on device settings for `Accept-Encoding`, `Accept-Language`, `User-Agent`.
 */
@property (nonatomic, readonly) NSDictionary *HTTPRequestHeaders;

/*!
 @abstract Sets the value for the HTTP headers set in request objects made by the HTTP client. If `nil`, removes the existing value for that header.
 @param field The HTTP header to set a default value for
 @param value The value set as default for the specified header, or `nil`
 */
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

/*!
 @abstract Returns the value for the HTTP headers set in the request serializer.
 @param field The HTTP header to retrieve the default value for
 @return The value set as default for the specified header, or `nil`
 */
- (NSString *)valueForHTTPHeaderField:(NSString *)field;

/**
 * Sets the `Authorization` HTTP header set in request objects made by the HTTP client to a basic authentication value with Base64-encoded username and password. This overwrites any existing value for this header.
 * @param username The HTTP basic auth username
 * @param password The HTTP basic auth password
 */
- (void)setAuthorizationHeaderFieldWithUsername:(NSString *)username password:(NSString *)password;

/**
 * Sets the `Authorization` HTTP header set in request objects made by the HTTP client to present the sepcified authToken with the specified tokenType. This overwrites any existing value for this header.
 * @param authToken The opaque token string.
 * @param tokenType The type of token
 */
- (void)setAuthorizationHeaderFieldWithAuthToken:(NSString *)authToken tokenType:(NSString *)tokenType;

/*!
 @abstract Clears any existing value for the `Authorization` HTTP header.
 */
- (void)clearAuthorizationHeader;

/*!
 @name Creating Request Objects
 */

/*!
 @abstract Creates an `NSMutableURLRequest` object with the specified HTTP method and URL string.
 @discussion If the HTTP method is `GET`, `HEAD`, or `DELETE`, the parameters will be used to construct a url-encoded query string that is appended to the request's URL. Otherwise, the parameters will be encoded according to the value of the `parameterEncoding` property, and set as the request body.
 @param method The HTTP method for the request, such as `GET`, `POST`, `PUT`, or `DELETE`. This parameter must not be `nil`.
 @param URL The URL used to create the request URL.
 @param parameters The parameters to be either set as a query string for `GET` requests, or the request HTTP body.
 @param error The error that occured while constructing the request.
 @return An `NSMutableURLRequest` object.
 */
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                       URL:(NSURL *)URL
                                parameters:(id)parameters
                                     error:(NSError **)error;

@end

/*!
 @class DBJSONRequestSerializer
 @abstract `DBJSONRequestSerializer` is a subclass of `DBHTTPRequestSerializer` that encodes parameters as JSON using `NSJSONSerialization`, setting the `Content-Type` of the encoded request to `application/json`.
 */
@interface DBJSONRequestSerializer : DBHTTPRequestSerializer <DBURLRequestSerialization>

/*!
 @abstract The options for writing the request JSON data from Foundation objects.
 */
@property (nonatomic) NSJSONWritingOptions JSONWritingOptions;

@end
