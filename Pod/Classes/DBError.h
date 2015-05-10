//
//  DBNetworkingError.h
//  DBNetworkingKit
//
//  Created by Devon Boyer on 2015-04-26.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @class DBError
 @abstract <#description#>
 @discussion <#description#>
 */
@interface DBError : NSObject

+ (BOOL)errorOrUnderlyingErrorHasCodeInDomain:(NSError *)error code:(NSInteger)code domain:(NSString *)domain;

+ (NSError *)errorWithUnderlyingError:(NSError *)error underlyingError:(NSError *)underlyingError;

+ (NSError *)errorWithCode:(NSInteger)code domain:(NSString *)domain message:(NSString *)message;

+ (NSError *)errorWithCode:(NSInteger)code domain:(NSString *)domain message:(NSString *)message underlyingError:(NSError *)underlyingError;

@end
