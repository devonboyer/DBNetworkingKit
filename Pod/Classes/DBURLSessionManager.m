//
//  DBURLSessionManager.m
//  DBNetworkingKit
//
//  Created by Devon Boyer on 2015-05-01.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBURLSessionManager.h"

@interface DBURLSessionManager ()

@property (nonatomic, strong) NSURLSession *URLSession;

@end

@implementation DBURLSessionManager

+ (instancetype)sharedInstance
{
    static DBURLSessionManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _reachabilityManager = [DBNetworkReachabilityManager sharedManager];
        _requestSerializer = [DBJSONRequestSerializer serializer];
        _responseSerializer = [DBJSONResponseSerializer serializer];
        _URLSession = [self defaultURLSession];
    }
    return self;
}

- (NSURLSession *)defaultURLSession
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.HTTPAdditionalHeaders = @{@"Accept": @"application/json"};
    return [NSURLSession sessionWithConfiguration:configuration];
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                                   completion:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completion
{
    NSURLSessionDataTask *dataTask =
    [self.URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *responseObject = [self.responseSerializer responseObjectForResponse:response data:data error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(response, responseObject, error);
        });
    }];
    
    [dataTask resume];
    
    return dataTask;
}

+ (NSURL * (^)(NSURL *location, NSURLResponse *response))suggestedDownloadDestination
{
    return ^NSURL * (NSURL *targetPath, NSURLResponse *response) {
        NSURL *directoryURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
        if (directoryURL) {
            return [directoryURL URLByAppendingPathComponent:response.suggestedFilename];
        }
        return targetPath;
    };
}

- (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSURL *)URL
                                      destination:(NSURL * (^)(NSURL *location, NSURLResponse *response))destination
                                       completion:(void (^)(NSURLResponse *response, NSData *data, NSError *error))completion
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask =
    [self.URLSession downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(response, nil, error);
            });
        } else {
            NSURL *destinationURL = destination(location, response);
            if (destinationURL) {
                if ([[NSFileManager defaultManager] fileExistsAtPath:destinationURL.path]) {
                    [[NSFileManager defaultManager] removeItemAtURL:destinationURL error:nil];
                }
                [[NSFileManager defaultManager] moveItemAtURL:location toURL:destinationURL error:nil];
                NSData *data = [NSData dataWithContentsOfURL:destinationURL];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(response, data, error);
                });
            } else {
                NSData *data = [NSData dataWithContentsOfURL:location];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(response, data, error);
                });
            }
        }
    }];
    
    [downloadTask resume];
    
    return downloadTask;
}

- (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSURL *)URL
                                       completion:(void (^)(NSURLResponse *response, NSData *data, NSError *error))completion
{
    return [self downloadTaskWithURL:URL destination:[DBURLSessionManager suggestedDownloadDestination] completion:completion];
}

@end
