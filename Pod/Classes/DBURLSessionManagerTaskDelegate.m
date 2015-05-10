//
//  DBURLSessionManagerTaskDelegate.m
//  DBNetworkingKit
//
//  Created by Devon Boyer on 2015-05-09.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBURLSessionManagerTaskDelegate.h"

@implementation DBURLSessionManagerTaskDelegate

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.progress = [NSProgress progressWithTotalUnitCount:0];
    }
    return self;
}

@end

@implementation DBURLSessionManagerDataTaskDelegate

#pragma mark - NSURLSessionDataDelegate

@end

@implementation DBURLSessionManagerDownloadTaskDelegate

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    self.progress.totalUnitCount = totalBytesExpectedToWrite;
    self.progress.completedUnitCount = totalBytesWritten;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    // TODO: Move code to handle download destination here
}

@end

@implementation DBURLSessionManagerUploadTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    self.progress.totalUnitCount = totalBytesExpectedToSend;
    self.progress.completedUnitCount = totalBytesSent;
}

@end
