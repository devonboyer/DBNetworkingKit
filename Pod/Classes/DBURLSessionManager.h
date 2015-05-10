//
//  DBURLSessionManager.h
//  DBNetworkingKit
//
//  Created by Devon Boyer on 2015-05-01.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DBURLRequestSerialization.h"
#import "DBURLResponseSerialization.h"
#import "DBNetworkReachabilityManager.h"

/*!
 @class DBURLSessionManager
 @abstract Creates and manages an NSURLSession in which requests can be made.
 */
@interface DBURLSessionManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) DBNetworkReachabilityManager *reachabilityManager;

@property (nonatomic, strong) DBHTTPRequestSerializer *requestSerializer;

@property (nonatomic, strong) id<DBURLResponseSerialization> responseSerializer;

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                                   completion:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completion;

- (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSURL *)URL
                                      destination:(NSURL * (^)(NSURL *location, NSURLResponse *response))destination
                                       completion:(void (^)(NSURLResponse *response, NSData *data, NSError *error))completion;

- (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSURL *)URL
                                       completion:(void (^)(NSURLResponse *response, NSData *data, NSError *error))completion;

+ (NSURL * (^)(NSURL *location, NSURLResponse *response))suggestedDownloadDestination;

@end
