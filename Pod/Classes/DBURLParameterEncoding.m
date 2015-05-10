//
//  DBURLParameterEncoding.m
//  DBNetworkingKit
//
//  Created by Devon Boyer on 2015-05-01.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBURLParameterEncoding.h"

@interface DBQueryStringPair : NSObject

@property (nonatomic) id field;
@property (nonatomic) id value;

- (instancetype)initWithField:(id)field value:(id)value;

- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding;

@end

@implementation DBURLParameterEncoding

static NSString * const DBCharactersToBeEscapedInQueryString = @":/?&=;+!@#$()',*";

+ (NSString *)percentEscapedQueryStringKeyFromString:(NSString *)string withEncoding:(NSStringEncoding)encoding
{
    static NSString * const DBCharactersToLeaveUnescapedInQueryStringPairKey = @"[].";
    
    return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, (__bridge CFStringRef)DBCharactersToLeaveUnescapedInQueryStringPairKey, (__bridge CFStringRef)DBCharactersToBeEscapedInQueryString, CFStringConvertNSStringEncodingToEncoding(encoding));
}

+ (NSString *)percentEscapedQueryStringValueFromString:(NSString *)string withEncoding:(NSStringEncoding)encoding
{
    return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, NULL, (__bridge CFStringRef)DBCharactersToBeEscapedInQueryString, CFStringConvertNSStringEncodingToEncoding(encoding));
}

+ (NSString *)queryStringWithParameters:(id)parameters encoding:(NSStringEncoding)encoding error:(NSError **)error
{
    NSMutableArray *mutablePairs = [NSMutableArray array];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        DBQueryStringPair *pair = [[DBQueryStringPair alloc] initWithField:key value:value];
        [mutablePairs addObject:[pair URLEncodedStringValueWithEncoding:encoding]];
    }];
    
    NSString *queryString = [mutablePairs componentsJoinedByString:@"&"];
    return queryString;
}

@end

@implementation DBQueryStringPair

- (instancetype)initWithField:(id)field value:(id)value
{
    self = [super init];
    if (self) {
        self.field = field;
        self.value = value;
    }
    return self;
}

- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding
{
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return [DBURLParameterEncoding percentEscapedQueryStringKeyFromString:[self.field description] withEncoding:stringEncoding];
    } else {
        return [NSString stringWithFormat:@"%@=%@", [DBURLParameterEncoding percentEscapedQueryStringKeyFromString:[self.field description] withEncoding:stringEncoding], [DBURLParameterEncoding percentEscapedQueryStringValueFromString:[self.value description] withEncoding:stringEncoding]];
    }
}

@end
