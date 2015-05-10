//
//  DBURLSessionManager.m
//  DBNetworkingKit
//
//  Created by Devon Boyer on 2015-05-01.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBURLSessionManager.h"
#import "DBURLSessionManagerTaskDelegate.h"

@interface DBURLSessionManager () <NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *URLSession;
@property (nonatomic, strong) NSMutableDictionary *mutableTaskDelegatesKeyedByTaskIdentifier;

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
    return [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
}

#pragma mark - Getting Session Tasks

- (NSArray *)tasksForKeyPath:(NSString *)keyPath
{
    __block NSArray *tasks = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self.URLSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(dataTasks))]) {
            tasks = dataTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(uploadTasks))]) {
            tasks = uploadTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(downloadTasks))]) {
            tasks = downloadTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(tasks))]) {
            tasks = [@[dataTasks, uploadTasks, downloadTasks] valueForKeyPath:@"@unionOfArrays.self"];
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return tasks;
}

- (NSArray *)tasks
{
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

- (NSArray *)dataTasks
{
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

- (NSArray *)uploadTasks
{
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

- (NSArray *)downloadTasks
{
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

#pragma mark - Data Tasks

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

#pragma mark - Download Tasks

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

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                             progress:(NSProgress **)progress
                                          destination:(NSURL * (^)(NSURL *location, NSURLResponse *response))destination
                                           completion:(void (^)(NSURLResponse *response, NSData *data, NSError *error))completion
{
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
    
    [self setTaskDelegateForDownloadTask:downloadTask progress:progress];
    
    return downloadTask;
}

#pragma mark - Upload Tasks

- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromData:(NSData *)fromData
                                         progress:(NSProgress **)progress
                                       completion:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completion
{
    NSURLSessionUploadTask *uploadTask =
    [self.URLSession uploadTaskWithRequest:request fromData:fromData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *responseObject = [self.responseSerializer responseObjectForResponse:response data:data error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(response, responseObject, error);
        });
    }];
    
    [uploadTask resume];
    
    [self setTaskDelegateForUploadTask:uploadTask progress:progress];
    
    return uploadTask;
}

#pragma mark - Accessing Task Delegates

- (DBURLSessionManagerTaskDelegate *)taskDelegateForTask:(NSURLSessionTask *)task
{
    NSParameterAssert(task);
    return self.mutableTaskDelegatesKeyedByTaskIdentifier[@(task.taskIdentifier)];
}

- (void)setTaskDelegateForDownloadTask:(NSURLSessionDownloadTask *)downloadTask
                              progress:(NSProgress **)progress
{
    DBURLSessionManagerDownloadTaskDelegate *taskDelegate = [[DBURLSessionManagerDownloadTaskDelegate alloc] init];
    if (progress) {
        *progress = taskDelegate.progress;
    }
    [self setTaskDelegate:taskDelegate forTask:downloadTask];
}

- (void)setTaskDelegateForUploadTask:(NSURLSessionUploadTask *)uploadTask
                            progress:(NSProgress **)progress
{
    DBURLSessionManagerUploadTaskDelegate *taskDelegate = [[DBURLSessionManagerUploadTaskDelegate alloc] init];
    if (progress) {
        *progress = taskDelegate.progress;
    }
    [self setTaskDelegate:taskDelegate forTask:uploadTask];
}

- (void)setTaskDelegate:(DBURLSessionManagerTaskDelegate *)taskDelegate forTask:(NSURLSessionTask *)task
{
    NSParameterAssert(task);
    NSParameterAssert(taskDelegate);
    self.mutableTaskDelegatesKeyedByTaskIdentifier[@(task.taskIdentifier)] = taskDelegate;
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    DBURLSessionManagerUploadTaskDelegate *taskDelegate = (DBURLSessionManagerUploadTaskDelegate *)[self taskDelegateForTask:task];
    [taskDelegate URLSession:session task:task didSendBodyData:totalBytesSent totalBytesSent:bytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    DBURLSessionManagerDownloadTaskDelegate *taskDelegate = (DBURLSessionManagerDownloadTaskDelegate *)[self taskDelegateForTask:downloadTask];
    [taskDelegate URLSession:session downloadTask:downloadTask didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    DBURLSessionManagerDownloadTaskDelegate *taskDelegate = (DBURLSessionManagerDownloadTaskDelegate *)[self taskDelegateForTask:downloadTask];
    [taskDelegate URLSession:session downloadTask:downloadTask didFinishDownloadingToURL:location];
}

@end
