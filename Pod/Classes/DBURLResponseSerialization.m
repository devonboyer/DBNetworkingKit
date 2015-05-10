//
//  DBURLResponseSerialization.m
//  DBNetworkingKit
//
//  Created by Devon Boyer on 2015-03-18.
//  Copyright (c) 2015 Devon Boyer. All rights reserved.
//

#import "DBURLResponseSerialization.h"
#import "DBError.h"
#import "DBJSONParser.h"

@implementation DBHTTPResponseSerializer

NSString * const DBURLResponseSerializationErrorDomain = @"com.devonboyer.DBNetworkingKit.error.serialization.response";

 + (instancetype)serializer
{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _acceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
        _acceptableContentTypes = nil;
    }
    return self;
}

#pragma mark - Validation

- (BOOL)validateResponse:(NSHTTPURLResponse *)response
                    data:(NSData *)data
                   error:(NSError **)error
{
    BOOL isValid = YES;
    NSError *validationError = nil;
    
    if (response) {
        
        // Acceptable Status Codes
        if (self.acceptableStatusCodes && ![self.acceptableStatusCodes containsIndex:(NSUInteger)response.statusCode] && [response URL]) {
        
            NSString *description = [NSString stringWithFormat:@"Request failed: status-code (%d): %@", (int)response.statusCode,[NSHTTPURLResponse localizedStringForStatusCode:response.statusCode]];
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : description,
                                       NSURLErrorFailingURLErrorKey: [response URL]};
            
            validationError = [NSError errorWithDomain:DBURLResponseSerializationErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:userInfo];
            
            isValid = NO;
        }
        
        // Acceptable Content Types
        if (self.acceptableContentTypes && ![self.acceptableContentTypes containsObject:[response MIMEType]]) {
            
            NSString *description = [NSString stringWithFormat:@"Request failed: unacceptable content-type: %@", [response MIMEType]];
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : description,
                                       NSURLErrorFailingURLErrorKey: [response URL]};
            
            validationError = [NSError errorWithDomain:DBURLResponseSerializationErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:userInfo];
            
            isValid = NO;
        }
    }
    
    if (error && !isValid) {
        *error = validationError;
    }
    
    return isValid;
}

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError **)error
{
    [self validateResponse:(NSHTTPURLResponse *)response data:data error:error];
    return data;
}

@end

@implementation DBJSONResponseSerializer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.JSONReadingOptions = 0;
        self.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"application/json", @"text/json", @"text/javascript", nil];
    }
    return self;
}

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError **)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if (!error || [DBError errorOrUnderlyingErrorHasCodeInDomain:*error code:NSURLErrorCannotDecodeContentData domain:DBURLResponseSerializationErrorDomain]) {
            return nil;
        }
    }
    
    id responseObject = nil;
    NSError *serializationError = nil;
    
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (responseString && ![responseString isEqualToString:@""]) {
        // Workaround for a bug in NSJSONSerialization when Unicode character escape codes are used instead of the actual character
        // See http://stackoverflow.com/a/12843465/157142
        data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        
        if (data) {
            if ([data length] > 0) {
                responseObject = [NSJSONSerialization JSONObjectWithData:data options:self.JSONReadingOptions error:&serializationError];
            } else {
                return nil;
            }
        } else {
            NSString *description = @"Data failed decoding as a UTF-8 string";
            NSString *reason = [NSString stringWithFormat:@"Could not decode string: %@", responseString];
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: description,
                                       NSLocalizedFailureReasonErrorKey: reason};
            
            serializationError = [NSError errorWithDomain:DBURLResponseSerializationErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:userInfo];
        }
    }
    
    if (self.removesKeysWithNullValues && responseObject) {
        responseObject = [DBJSONParser JSONObjectByRemovingKeysWithNullValues:responseObject readingOptions:self.JSONReadingOptions];
    }
    
    if (error) {
        *error = [DBError errorWithUnderlyingError:serializationError underlyingError:*error];
    }

    return responseObject;
}

@end
