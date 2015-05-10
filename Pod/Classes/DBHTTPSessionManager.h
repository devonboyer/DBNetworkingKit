//
//  DBHTTPSessionManager.h
//  DBNetworkingKit
//
//  Created by Devon Boyer on 2015-05-01.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <DBNetworkingKit/DBURLSessionManager.h>

/*!
 @class DBHTTPSessionManager
 @abstract A subclass of DBURLSessionManager specialized for making requests to a REST API using a baseURL and relative paths to make requests.
 */
@interface DBHTTPSessionManager : DBURLSessionManager

@property (nonatomic, strong) NSURL *baseURL;

@property (nonatomic, strong) DBJSONRequestSerializer *requestSerializer;

@property (nonatomic, strong) DBJSONResponseSerializer *responseSerializer;

/*!
 @name Making HTTP Requests
 */

- (NSURLSessionDataTask *)GET:(NSString *)path
                   parameters:(id)parameters
                    authToken:(NSString *)authToken
                    tokenType:(NSString *)tokenType
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (NSURLSessionDataTask *)PUT:(NSString *)path
                   parameters:(id)parameters
                    authToken:(NSString *)authToken
                    tokenType:(NSString *)tokenType
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (NSURLSessionDataTask *)POST:(NSString *)path
                    parameters:(id)parameters
                     authToken:(NSString *)authToken
                     tokenType:(NSString *)tokenType
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (NSURLSessionDataTask *)DELETE:(NSString *)path
                      parameters:(id)parameters
                       authToken:(NSString *)authToken
                       tokenType:(NSString *)tokenType
                         success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                         failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                            path:(NSString *)path
                                      parameters:(id)parameters
                                       authToken:(NSString *)authToken
                                       tokenType:(NSString *)tokenType
                                         success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                         failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/*!
 @name Making Download Requests
 */

- (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSURL *)URL
                                         progress:(NSProgress **)progress
                                      destination:(NSURL * (^)(NSURL *location, NSURLResponse *response))destination
                                          success:(void (^)(NSURLSessionDownloadTask *task, NSData *data))success
                                          failure:(void (^)(NSURLSessionDownloadTask *task, NSError *error))failure;

- (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSURL *)URL
                                         progress:(NSProgress **)progress
                                          success:(void (^)(NSURLSessionDownloadTask *task, NSData *data))success
                                          failure:(void (^)(NSURLSessionDownloadTask *task, NSError *error))failure;

- (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSURL *)URL
                                          success:(void (^)(NSURLSessionDownloadTask *task, NSData *data))success
                                          failure:(void (^)(NSURLSessionDownloadTask *task, NSError *error))failure;

/*!
 @name Making Upload Requests
 */

- (NSURLSessionUploadTask *)uploadTaskWithHTTPMethod:(NSString *)method
                                                path:(NSString *)path
                                            fromData:(NSData *)fromData
                                            progress:(NSProgress **)progress
                                             success:(void (^)(NSURLSessionUploadTask *task, id responseObject))success
                                             failure:(void (^)(NSURLSessionUploadTask *task, NSError *error))failure;
@end
