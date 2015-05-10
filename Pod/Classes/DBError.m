//
//  DBNetworkingError.m
//  DBNetworkingKit
//
//  Created by Devon Boyer on 2015-04-26.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBError.h"

@implementation DBError

+ (BOOL)errorOrUnderlyingErrorHasCodeInDomain:(NSError *)error code:(NSInteger)code domain:(NSString *)domain
{
    if ([error.domain isEqualToString:domain] && error.code == code) {
        return YES;
    } else if (error.userInfo[NSUnderlyingErrorKey]) {
        return [self errorOrUnderlyingErrorHasCodeInDomain:error.userInfo[NSUnderlyingErrorKey] code:code domain:domain];
    }
    
    return NO;
}

+ (NSError *)errorWithUnderlyingError:(NSError *)error underlyingError:(NSError *)underlyingError
{
    if (!error) {
        return underlyingError;
    }
    
    if (!underlyingError || error.userInfo[NSUnderlyingErrorKey]) {
        return error;
    }
    
    NSMutableDictionary *mutableUserInfo = [error.userInfo mutableCopy];
    mutableUserInfo[NSUnderlyingErrorKey] = underlyingError;
    
    return [[NSError alloc] initWithDomain:error.domain code:error.code userInfo:mutableUserInfo];
}

+ (NSError *)errorWithCode:(NSInteger)code domain:(NSString *)domain message:(NSString *)message
{
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : message};
    return [NSError errorWithDomain:domain code:code userInfo:userInfo];
}

+ (NSError *)errorWithCode:(NSInteger)code domain:(NSString *)domain message:(NSString *)message underlyingError:(NSError *)underlyingError
{
    NSError *error = [self errorWithCode:code domain:domain message:message];
    
    if (!underlyingError || error.userInfo[NSUnderlyingErrorKey]) {
        return error;
    }
    
    NSMutableDictionary *mutableUserInfo = [error.userInfo mutableCopy];
    mutableUserInfo[NSUnderlyingErrorKey] = underlyingError;
    
    return [[NSError alloc] initWithDomain:error.domain code:error.code userInfo:mutableUserInfo];
}

@end
