//
//  DBURLSessionManager.h
//  DBNetworkingKit
//
//  Created by Devon Boyer on 2015-05-01.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <DBNetworkingKit/DBURLRequestSerialization.h>
#import <DBNetworkingKit/DBURLResponseSerialization.h>
#import <DBNetworkingKit/DBNetworkReachabilityManager.h>

/*!
 @class DBURLSessionManager
 @abstract Creates and manages an NSURLSession in which requests can be made.
 */
@interface DBURLSessionManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) DBNetworkReachabilityManager *reachabilityManager;

@property (nonatomic, strong) DBHTTPRequestSerializer *requestSerializer;

@property (nonatomic, strong) id<DBURLResponseSerialization> responseSerializer;

/*!
 @name Getting Session Tasks
 */

/*!
 @abstract The data, upload, and download tasks currently run by the session.
 */
@property (nonatomic, strong, readonly) NSArray *tasks;

/*!
 @abstract The data tasks currently run by the session.
 */
@property (nonatomic, strong, readonly) NSArray *dataTasks;

/*!
 @abstract The upload tasks currently run by the session.
 */
@property (nonatomic, strong, readonly) NSArray *uploadTasks;

/*!
 @abstract The download tasks currently run by the session.
 */
@property (nonatomic, strong, readonly) NSArray *downloadTasks;

/*!
 @name Data Tasks
 */

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                                   completion:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completion;

/*!
 @name Download Tasks
 */

+ (NSURL * (^)(NSURL *location, NSURLResponse *response))suggestedDownloadDestination;

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                             progress:(NSProgress **)progress
                                          destination:(NSURL * (^)(NSURL *location, NSURLResponse *response))destination
                                           completion:(void (^)(NSURLResponse *response, NSData *data, NSError *error))completion;

/*!
 @name Upload Tasks
 */

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromData:(NSData *)fromData
                                         progress:(NSProgress **)progress
                                       completion:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completion;

@end
