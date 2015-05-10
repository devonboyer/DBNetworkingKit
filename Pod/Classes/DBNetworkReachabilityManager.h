//
//  DBNetworkReachabilityManager.h
//  DBNetworkingKit
//
//  Created by Devon Boyer on 2015-03-18.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

extern NSString * const DBNetworkReachabilityNotificationStatusKey;
extern NSString * const DBNetworkReachabilityDidChangeNotification;

/*!
 @typedef DBNetworkReachabilityStatus
 @abstract <#description#>
 */
typedef NS_ENUM(NSInteger, DBNetworkReachabilityStatus) {
    DBNetworkReachabilityStatusUnknown          = 0,
    DBNetworkReachabilityStatusNotReachable     = 1,
    DBNetworkReachabilityStatusReachableViaWWAN = 2,
    DBNetworkReachabilityStatusReachableViaWiFi = 3,
};

/*!
 @class DBNetworkReachabilityManager
 @abstract `DBNetworkReachabilityManager` monitors the reachability of domains, and addresses for both WWAN and WiFi network interfaces.
 @discussion Reachability can be used to determine background information about why a network operation failed, or to trigger a network operation retrying when a connection is established. It should not be used to prevent a user from initiating a network request, as it's possible that an initial request may be required to establish reachability.
 See Apple's Reachability Sample Code (https://developer.apple.com/library/ios/samplecode/reachability/)
 @warning Instances of `DBNetworkReachabilityManager` must be started with `-startMonitoring` before reachability status can be determined.
 */
@interface DBNetworkReachabilityManager : NSObject

/*!
 @abstract The current network reachability status.
 */
@property (nonatomic, readonly, assign) DBNetworkReachabilityStatus networkReachabilityStatus;

/*!
 @abstract Whether or not the network is currently reachable.
 */
@property (nonatomic, readonly, assign, getter = isReachable) BOOL reachable;

/*!
 @abstract Whether or not the network is currently reachable via WWAN.
 */
@property (nonatomic, readonly, assign, getter = isReachableViaWWAN) BOOL reachableViaWWAN;

/*!
 @abstract Whether or not the network is currently reachable via WiFi.
 */
@property (nonatomic, readonly, assign, getter = isReachableViaWiFi) BOOL reachableViaWiFi;

/*!
 @name Initialization
 */

/*!
 @abstract Returns the shared network reachability manager.
 */
+ (instancetype)sharedManager;

/*!
 @abstract Creates and returns a network reachability manager for the specified domain.
 @param domain The domain used to evaluate network reachability.
 @return An initialized network reachability manager, actively monitoring the specified domain.
 */
+ (instancetype)managerForDomain:(NSString *)domain;

/*!
 @abstract Initializes an instance of a network reachability manager from the specified reachability object.
 @param reachability The reachability object to monitor.
 @return An initialized network reachability manager, actively monitoring the specified reachability.
 */
- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability;

/*!
 @name Starting & Stopping Reachability Monitoring
 */

/*!
 @abstract Starts monitoring for changes in network reachability status.
 */
- (void)startMonitoring;

/**
 @abstract Stops monitoring for changes in network reachability status.
 */
- (void)stopMonitoring;

/*!
 @name Getting Localized Reachability Description
 */

/*!
 @abstract Returns a localized string representation of the current network reachability status.
 */
- (NSString *)localizedNetworkReachabilityStatusString;

@end
