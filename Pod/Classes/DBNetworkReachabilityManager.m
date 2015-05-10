//
//  DBNetworkReachabilityManager.m
//  DBNetworkingKit
//
//  Created by Devon Boyer on 2015-03-18.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBNetworkReachabilityManager.h"

#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

static DBNetworkReachabilityStatus DBNetworkReachabilityStatusForFlags(SCNetworkReachabilityFlags flags) {
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
    {
        // The target host is not reachable.
        return DBNetworkReachabilityStatusNotReachable;
    }
    
    DBNetworkReachabilityStatus returnValue = DBNetworkReachabilityStatusNotReachable;
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        /*
         If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
         */
        returnValue = DBNetworkReachabilityStatusReachableViaWiFi;
    }
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
    {
        /*
         ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
         */
        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            /*
             ... and no [user] intervention is needed...
             */
            returnValue = DBNetworkReachabilityStatusReachableViaWiFi;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        /*
         ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
         */
        returnValue = DBNetworkReachabilityStatusReachableViaWWAN;
    }
    
    return returnValue;
}

static void DBNetworkReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info) {
    DBNetworkReachabilityStatus status = DBNetworkReachabilityStatusForFlags(flags);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        NSDictionary *userInfo = @{ DBNetworkReachabilityNotificationStatusKey: @(status)};
        [notificationCenter postNotificationName:DBNetworkReachabilityDidChangeNotification object:nil userInfo:userInfo];
    });
}

@interface DBNetworkReachabilityManager ()

@property (nonatomic, assign) SCNetworkReachabilityRef networkReachability;

@property (nonatomic, assign) DBNetworkReachabilityStatus networkReachabilityStatus;

@end

@implementation DBNetworkReachabilityManager

NSString * const DBNetworkReachabilityNotificationStatusKey = @"com.devonboyer.DBNetworkingKit.reachabilityNotificationStatusKey";

NSString * const DBNetworkReachabilityDidChangeNotification = @"com.devonboyer.DBNetworkingKit.networkReachabilityDidChangeNotification";

#pragma mark - Initialization

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    static DBNetworkReachabilityManager *instance = nil;
    dispatch_once(&onceToken, ^{
        struct sockaddr_in address;
        bzero(&address, sizeof(address));
        address.sin_len = sizeof(address);
        address.sin_family = AF_INET;
        
        instance = [self managerForAddress:&address];
    });
    return instance;
}

+ (instancetype)managerForDomain:(NSString *)domain
{
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [domain UTF8String]);
    DBNetworkReachabilityManager *manager = [[self alloc] initWithReachability:reachability];
    return manager;
}

+ (instancetype)managerForAddress:(const void *)address {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)address);
    DBNetworkReachabilityManager *manager = [[self alloc] initWithReachability:reachability];
    return manager;
}

- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability
{
    self = [super init];
    if (self) {
        self.networkReachability = reachability;
        self.networkReachabilityStatus = DBNetworkReachabilityStatusUnknown;
    }
    return self;
}

- (void)dealloc
{
    [self stopMonitoring];
    
    if (_networkReachability) {
        CFRelease(_networkReachability);
        _networkReachability = NULL;
    }
}

- (BOOL)isReachable
{
    return [self isReachableViaWWAN] || [self isReachableViaWiFi];
}

- (BOOL)isReachableViaWWAN
{
    return self.networkReachabilityStatus == DBNetworkReachabilityStatusReachableViaWWAN;
}

- (BOOL)isReachableViaWiFi
{
    return self.networkReachabilityStatus == DBNetworkReachabilityStatusReachableViaWiFi;
}

#pragma mark - Starting & Stopping Reachability Monitoring

- (void)startMonitoring
{
    [self stopMonitoring];
    
    if (!self.networkReachability) {
        return;
    }
    
    SCNetworkReachabilitySetCallback(self.networkReachability, DBNetworkReachabilityCallback, nil);
    SCNetworkReachabilityScheduleWithRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        SCNetworkReachabilityFlags flags;
        SCNetworkReachabilityGetFlags(self.networkReachability, &flags);
        DBNetworkReachabilityStatus status = DBNetworkReachabilityStatusForFlags(flags);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            NSDictionary *userInfo = @{ DBNetworkReachabilityNotificationStatusKey: @(status) };
            [notificationCenter postNotificationName:DBNetworkReachabilityDidChangeNotification object:nil userInfo:userInfo];
        });
    });
}

- (void)stopMonitoring
{
    if (!self.networkReachability) {
        return;
    }
    
    SCNetworkReachabilityUnscheduleFromRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
}

#pragma mark - Getting Localized Reachability Description

- (NSString *)localizedNetworkReachabilityStatusString
{
    switch (self.networkReachabilityStatus) {
        case DBNetworkReachabilityStatusNotReachable:
            return NSLocalizedStringFromTable(@"Not Reachable", @"DBNetworkReachability", nil);
        case DBNetworkReachabilityStatusReachableViaWWAN:
            return NSLocalizedStringFromTable(@"Reachable via WWAN", @"DBNetworkReachability", nil);
        case DBNetworkReachabilityStatusReachableViaWiFi:
            return NSLocalizedStringFromTable(@"Reachable via WiFi", @"DBNetworkReachability", nil);
        case DBNetworkReachabilityStatusUnknown:
        default:
            return NSLocalizedStringFromTable(@"Unknown", @"DBNetworkReachability", nil);
    }
}

@end
