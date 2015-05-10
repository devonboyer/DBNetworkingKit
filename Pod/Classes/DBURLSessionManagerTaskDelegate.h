//
//  DBURLSessionManagerTaskDelegate.h
//  DBNetworkingKit
//
//  Created by Devon Boyer on 2015-05-09.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBURLSessionManagerTaskDelegate : NSObject <NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSProgress *progress;

@end

@interface DBURLSessionManagerDataTaskDelegate : DBURLSessionManagerTaskDelegate <NSURLSessionDataDelegate>

@end

@interface DBURLSessionManagerDownloadTaskDelegate : DBURLSessionManagerTaskDelegate <NSURLSessionDownloadDelegate>

@end

@interface DBURLSessionManagerUploadTaskDelegate : DBURLSessionManagerDataTaskDelegate

@end


