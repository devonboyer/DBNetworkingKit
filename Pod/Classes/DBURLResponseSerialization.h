//
//  DBURLResponseSerialization.h
//  DBNetworkingKit
//
//  Created by Devon Boyer on 2015-03-18.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const DBURLResponseSerializationErrorDomain;

/*!
 @protocol DBURLResponseSerialization
 @abstract The `DBURLResponseSerialization` protocol is adopted by an object that decodes data into a more useful object representation, according to details in the server response. Response serializers may additionally perform validation on the incoming response and data. For example, a JSON response serializer may check for an acceptable status code (`2XX` range) and content type (`application/json`), decoding a valid JSON response into an object.
 */
@protocol DBURLResponseSerialization <NSObject>

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError **)error;

@end

/*!
 @class DBHTTPResponseSerializer
 @abstract Conforms to the `DBHTTPResponseSerializer` protocols, offering a concrete base implementation of response serialization to an NSData object, as well as response status code and content type validation.
 */
@interface DBHTTPResponseSerializer : NSObject <DBURLResponseSerialization>

/*!
 @abstract Creates and returns a serializer with default configuration.
 */
+ (instancetype)serializer;

/*!
 @abstract The acceptable HTTP status codes for responses. Responses with status codes not contained by the set will result in an error during validation. The default is any status code between 200 - 299 inclusive.
 */
@property (nonatomic) NSIndexSet *acceptableStatusCodes;

/*!
 @abstract The acceptable MIME types for responses. Responses with a `Content-Type` with MIME types that do not intersect with the set will result in an error during validation.
 */
@property (nonatomic) NSSet *acceptableContentTypes;

/*!
 @name Validation
 */

/*!
 @abstract Validates the specified response and data by checking for an acceptable status code and content type.
 */
- (BOOL)validateResponse:(NSHTTPURLResponse *)response
                    data:(NSData *)data
                   error:(NSError **)error;

@end

/*!
 @class DBJSONResponseSerializer
 @abstract `DBJSONResponseSerializer` is a subclass of `DBHTTPResponseSerializer` that validates and decodes JSON responses.
 @discussion By default, `DBJSONResponseSerializer` accepts the following MIME types, which includes the official standard, `application/json`, as well as other commonly-used types:
 - `application/json`
 - `text/json`
 - `text/javascript`
 - `text/plain` (In most cases successful requests will return an empty string which should not cause validation to fail)
 */
@interface DBJSONResponseSerializer : DBHTTPResponseSerializer <DBURLResponseSerialization>

/*!
@abstract The options for reading the response JSON data and creating the Foundation objects.
 */
@property (nonatomic) NSJSONReadingOptions JSONReadingOptions;

/*!
 @abstract Whether to remove keys with `NSNull` values from response JSON. Defaults to `NO`.
 */
@property (nonatomic, assign) BOOL removesKeysWithNullValues;

@end
