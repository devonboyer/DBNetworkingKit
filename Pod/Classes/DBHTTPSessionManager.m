//
//  DBHTTPSessionManager.m
//  DBNetworkingKit
//
//  Created by Devon Boyer on 2015-05-01.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBHTTPSessionManager.h"

@interface DBHTTPSessionManager ()

@end

@implementation DBHTTPSessionManager

@dynamic requestSerializer;
@dynamic responseSerializer;

- (void)setBaseURL:(NSURL *)baseURL
{
    _baseURL = baseURL;
    
    // Ensure terminal slash for baseURL path, so that NSURL +URLWithString:relativeToURL: works as expected
    if ([[baseURL path] length] > 0 && ![[baseURL absoluteString] hasSuffix:@"/"]) {
        _baseURL = [baseURL URLByAppendingPathComponent:@""];
    }
}

#pragma mark - Making Data Requests

- (NSURLSessionDataTask *)GET:(NSString *)path
                   parameters:(id)parameters
                    authToken:(NSString *)authToken
                    tokenType:(NSString *)tokenType
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    return [self dataTaskWithHTTPMethod:@"GET" path:path parameters:parameters authToken:authToken tokenType:tokenType success:success failure:failure];
}

- (NSURLSessionDataTask *)PUT:(NSString *)path
                   parameters:(id)parameters
                    authToken:(NSString *)authToken
                    tokenType:(NSString *)tokenType
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    return [self dataTaskWithHTTPMethod:@"PUT" path:path parameters:parameters authToken:authToken tokenType:tokenType success:success failure:failure];
}

- (NSURLSessionDataTask *)POST:(NSString *)path
                    parameters:(id)parameters
                     authToken:(NSString *)authToken
                     tokenType:(NSString *)tokenType
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    return [self dataTaskWithHTTPMethod:@"POST" path:path parameters:parameters authToken:authToken tokenType:tokenType success:success failure:failure];
}

- (NSURLSessionDataTask *)DELETE:(NSString *)path
                      parameters:(id)parameters
                       authToken:(NSString *)authToken
                       tokenType:(NSString *)tokenType
                         success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                         failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    return [self dataTaskWithHTTPMethod:@"DELETE" path:path parameters:parameters authToken:authToken tokenType:tokenType success:success failure:failure];
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                            path:(NSString *)path
                                      parameters:(id)parameters
                                       authToken:(NSString *)authToken
                                       tokenType:(NSString *)tokenType
                                         success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                         failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSParameterAssert(method);

    NSError *serializationError = nil;
    
    if (authToken && tokenType) {
        [self.requestSerializer setAuthorizationHeaderFieldWithAuthToken:authToken tokenType:tokenType];
    }
    
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URL:[NSURL URLWithString:path relativeToURL:self.baseURL] parameters:parameters error:&serializationError];
    if (serializationError) {
        if (failure) {
            failure(nil, serializationError);
        }
        return nil;
    }
    
    if (authToken && tokenType) {
        [self.requestSerializer clearAuthorizationHeader];
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self dataTaskWithRequest:request completion:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        if (error) {
            if (failure) {
                failure(dataTask, error);
            }
        } else {
            if (success) {
                success(dataTask, responseObject);
            }
        }
    }];
    
    return dataTask;
}

#pragma mark - Making Download Requests

- (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSURL *)URL
                                         progress:(NSProgress **)progress
                                      destination:(NSURL * (^)(NSURL *location, NSURLResponse *response))destination
                                          success:(void (^)(NSURLSessionDownloadTask *task, NSData *data))success
                                          failure:(void (^)(NSURLSessionDownloadTask *task, NSError *error))failure
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET" URL:URL parameters:nil error:&serializationError];
    if (serializationError) {
        if (failure) {
            failure(nil, serializationError);
        }
        return nil;
    }
    
    __block NSURLSessionDownloadTask *downloadTask = nil;
    downloadTask = [super downloadTaskWithRequest:request progress:progress destination:destination completion:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            if (failure) {
                failure(downloadTask, error);
            }
        } else {
            if (success) {
                success(downloadTask, data);
            }
        }
    }];
    return downloadTask;
}

- (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSURL *)URL
                                         progress:(NSProgress **)progress
                                          success:(void (^)(NSURLSessionDownloadTask *task, NSData *data))success
                                          failure:(void (^)(NSURLSessionDownloadTask *task, NSError *error))failure
{
    return [self downloadTaskWithURL:URL progress:progress destination:[DBURLSessionManager suggestedDownloadDestination] success:success failure:failure];
}

- (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSURL *)URL
                                          success:(void (^)(NSURLSessionDownloadTask *task, NSData *data))success
                                          failure:(void (^)(NSURLSessionDownloadTask *task, NSError *error))failure
{
    return [self downloadTaskWithURL:URL progress:nil success:success failure:failure];
}

#pragma mark - Making Upload Requests

- (NSURLSessionUploadTask *)uploadTaskWithHTTPMethod:(NSString *)method
                                                path:(NSString *)path
                                            fromData:(NSData *)fromData
                                            progress:(NSProgress **)progress
                                             success:(void (^)(NSURLSessionUploadTask *task, id responseObject))success
                                             failure:(void (^)(NSURLSessionUploadTask *task, NSError *error))failure
{
    NSParameterAssert(method);
    NSParameterAssert(![method isEqualToString:@"GET"] || ![method isEqualToString:@"HEAD"]);
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URL:[NSURL URLWithString:path relativeToURL:self.baseURL] parameters:nil error:&serializationError];
    if (serializationError) {
        if (failure) {
            failure(nil, serializationError);
        }
        return nil;
    }
    
    __block NSURLSessionUploadTask *uploadTask = nil;
    uploadTask = [super uploadTaskWithRequest:request fromData:fromData progress:progress completion:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (failure) {
                failure(uploadTask, error);
            }
        } else {
            if (success) {
                success(uploadTask, responseObject);
            }
        }
    }];
    
    return uploadTask;
}

@end
