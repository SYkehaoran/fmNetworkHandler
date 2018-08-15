//
//  fmRequest.m
//  HXFundManager
//
//  Created by 柯浩然 on 8/9/18.
//  Copyright © 2018 柯浩然. All rights reserved.
//

#import "fmRequest.h"
#import "fmNetworkAgent.h"
#import "fmResponseSerializer.h"
#import "fmReqeustSerializer.h"

@interface fmRequest ()
@end

@implementation fmRequest

- (NSString *)requestUrl {
    return [self.child requestUrl];
}

- (id)requestArgument {
    return [self.child requestArgument];
    
}

- (fmRequestMethod)requestMethod {
    return  [self.child requestMethod];
}

- (BOOL)loadCacheWithError:(NSError *)error {
    return NO;
}

- (void)startWithCompletionBlockWithSuccess:(fmRequestCompletionBlock)success failure:(fmRequestCompletionBlock)failure {
 
    [self setCompletionBlockWithSuccess:success failure:failure];
    [self start];
}

- (void)setCompletionBlockWithSuccess:(fmRequestCompletionBlock)success failure:(fmRequestCompletionBlock)failure {
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
}

- (void)start {
    
    if (!_ignoreCache) {
        [self startWithOutCache];
    }
    
    if (![self loadCacheWithError:nil]) {
        [self startWithOutCache];
    }
    
    if (self.successCompletionBlock) {
        self.successCompletionBlock(self);
    }
}

- (void)startWithOutCache {
    
    [[fmNetworkAgent sharedAgent] addRequest:self];
}

- (void)stop {
    [self.task cancel];
}
- (BOOL)statusCodeValidator:(NSError * __autoreleasing *)error {
    
    BOOL validate = [fmResponseSerializer validateResponseJSONObject:self.responseJSONObject error:error];
    
    return validate;
}
- (id)encryptParameters:(id)params error:(NSError * _Nullable __autoreleasing *)error {
    return [fmReqeustSerializer encryptParameters:params error:error];
}
@end
