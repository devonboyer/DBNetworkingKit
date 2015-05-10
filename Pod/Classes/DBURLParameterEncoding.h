//
//  DBURLParameterEncoding.h
//  DBNetworkingKit
//
//  Created by Devon Boyer on 2015-05-01.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @class DBURLParameterEncoding
 @abstract <#description#>
 @discussion <#description#>
 */
@interface DBURLParameterEncoding : NSObject

/*!
 @abstract Constructs a query string representation of the parameters.
 @param parameters The parameters to use to create the query string.
 @param error If an error occurs, upon return contains an NSError object that describes the problem.
 @result Query string representation of the parameters.
 */
+ (NSString *)queryStringWithParameters:(id)parameters encoding:(NSStringEncoding)encoding error:(NSError **)error;

@end
