//
//  DBURLRequestSerialization.m
//  DBNetworkingKit
//
//  Created by Devon Boyer on 2015-03-18.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBURLRequestSerialization.h"
#import "DBURLParameterEncoding.h"

@interface DBHTTPRequestSerializer ()

@property (nonatomic) NSMutableDictionary *mutableHTTPRequestHeaders;

@end

@implementation DBHTTPRequestSerializer

+ (instancetype)serializer
{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _timeoutInterval = 60.0;
        _HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", @"DELETE", nil];
        
        self.mutableHTTPRequestHeaders = [NSMutableDictionary dictionary];
        [self.mutableHTTPRequestHeaders addEntriesFromDictionary:[[self class] defaultHTTPHeaders]];
    }
    return self;
}

+ (NSDictionary *)defaultHTTPHeaders
{
    // Accept-Encoding HTTP Header
    NSString *acceptEncoding = @"gzip;q=1.0,compress;q=0.5";
    
    NSMutableArray *components = [NSMutableArray new];
    [[NSLocale preferredLanguages] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        double q = 1.0 - idx * 0.1;
        [components addObject:[NSString stringWithFormat:@"(languageCode);q=(%f)", q]];
        if (q < 0.5f) {
            *stop = YES;
        }
    }];
    
    // Accept-Language HTTP Header
    NSString *acceptLanguage = [components componentsJoinedByString:@","];
    
    // User-Agent HTTP Header; see http://tools.ietf.org/html/rfc7231#section-5.5.3
    NSString *userAgent;
    if ([NSBundle mainBundle].infoDictionary) {
        NSDictionary *info = [NSBundle mainBundle].infoDictionary;
        id executable = info[(id)kCFBundleExecutableKey] ?: @"Unknown";
        id bundle = info[(id)kCFBundleIdentifierKey] ?: @"Unknown";
        id version = info[(id)kCFBundleVersionKey] ?: @"Unknown";
        id os = [NSProcessInfo processInfo].operatingSystemVersionString ?: @"Unknown";
        
        NSMutableString *mutableUserAgent =
        [NSMutableString stringWithFormat:@"(%@)(%@) ((%@); OS (%@))", executable, bundle, version, os];
        NSString *transform = @"Any-Latin; Latin-ASCII; [:^ASCII:] Remove";
        CFStringTransform((__bridge CFMutableStringRef)mutableUserAgent, nil, (__bridge CFStringRef)transform, 0);
        userAgent = mutableUserAgent;
    } else {
        userAgent = @"DBNetworkingKit";
    }
    
    return @{@"Accept-Encoding": acceptEncoding,
             @"Accept-Language": acceptLanguage,
             @"User-Agent": userAgent};
}

#pragma mark - Configuring HTTP Request Headers

- (NSDictionary *)HTTPRequestHeaders
{
    return [NSDictionary dictionaryWithDictionary:self.mutableHTTPRequestHeaders];
}

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field
{
    [self.mutableHTTPRequestHeaders setValue:value forKey:field];
}

- (NSString *)valueForHTTPHeaderField:(NSString *)field
{
    return [self.mutableHTTPRequestHeaders valueForKey:field];
}

- (void)setAuthorizationHeaderFieldWithUsername:(NSString *)username password:(NSString *)password
{
    NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@", username, password];

    NSData *data = [basicAuthCredentials dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [data base64EncodedStringWithOptions:0];
    
    [self setValue:[NSString stringWithFormat:@"Basic %@", base64String] forHTTPHeaderField:@"Authorization"];
}

- (void)setAuthorizationHeaderFieldWithAuthToken:(NSString *)authToken tokenType:(NSString *)tokenType
{
    [self setValue:[NSString stringWithFormat:@"%@ %@", tokenType, authToken] forHTTPHeaderField:@"Authorization"];
}

- (void)clearAuthorizationHeader
{
    [self.mutableHTTPRequestHeaders removeObjectForKey:@"Authorization"];
}

#pragma mark - Creating Request Objects

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                       URL:(NSURL *)URL
                                parameters:(id)parameters
                                     error:(NSError **)error
{
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:URL];
    mutableRequest.HTTPMethod = method;
    mutableRequest = [[self requestBySerializingRequest:mutableRequest withParameters:parameters error:error] mutableCopy];
    
    return mutableRequest;
}

- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                               withParameters:(id)parameters
                                        error:(NSError **)error
{
    NSParameterAssert(request);
    
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    
    [self.HTTPRequestHeaders enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL *stop) {
        if (![request valueForHTTPHeaderField:field]) {
            [mutableRequest setValue:value forHTTPHeaderField:field];
        }
    }];
    
    if (parameters) {
        
        NSString *queryString = [DBURLParameterEncoding queryStringWithParameters:parameters encoding:NSUTF8StringEncoding error:nil];
        
        if ([self.HTTPMethodsEncodingParametersInURI containsObject:[[request HTTPMethod] uppercaseString]]) {
            mutableRequest.URL = [NSURL URLWithString:[[mutableRequest.URL absoluteString] stringByAppendingFormat:mutableRequest.URL.query ? @"&%@" : @"?%@", queryString]];
        } else {
            if (![mutableRequest valueForHTTPHeaderField:@"Content-Type"]) {
                [mutableRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            }
            [mutableRequest setHTTPBody:[queryString dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    return mutableRequest;
}

@end

@implementation DBJSONRequestSerializer

+ (instancetype)serializer
{
    DBJSONRequestSerializer *serializer = [super serializer];
    serializer.JSONWritingOptions = NSJSONWritingPrettyPrinted;
    return serializer;
}

- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                               withParameters:(id)parameters
                                        error:(NSError **)error
{
    NSParameterAssert(request);
    
    if ([self.HTTPMethodsEncodingParametersInURI containsObject:[[request HTTPMethod] uppercaseString]]) {
        return [super requestBySerializingRequest:request withParameters:parameters error:error];
    }
    
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    
    [self.HTTPRequestHeaders enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL *stop) {
        if (![request valueForHTTPHeaderField:field]) {
            [mutableRequest setValue:value forHTTPHeaderField:field];
        }
    }];
    
    if (parameters) {
        if (![mutableRequest valueForHTTPHeaderField:@"Content-Type"]) {
            [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        }
        
        [mutableRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:self.JSONWritingOptions error:error]];
    }
    
    return mutableRequest;
}

@end
