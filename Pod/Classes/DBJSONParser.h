//
//  DBJSONParser.h
//  DBNetworkingKit
//
//  Created by Devon Boyer on 2015-05-01.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @class DBJSONParser
 @abstract <#description#>
 @discussion <#description#>
 */
@interface DBJSONParser : NSObject

+ (id)JSONObjectByRemovingKeysWithNullValues:(id)JSONObject readingOptions:(NSJSONReadingOptions)readingOptions;

@end
