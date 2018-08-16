//
//  fmRequest.m
//  HXFundManager
//
//  Created by 柯浩然 on 8/9/18.
//  Copyright © 2018 柯浩然. All rights reserved.
//

#import "fmRequest.h"

#import "fmResponseSerializer.h"
#import "fmReqeustSerializer.h"

@interface fmRequest ()
///最终使用的数据
@property(nonatomic, strong, readwrite) id responseJSONDataValue;
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

- (void)start {
    
    if (!_ignoreCache) {
        [self startWithOutCache];
        return;
    }
    
    if (![self loadCacheWithError:nil]) {
        [self startWithOutCache];
        return;
    }
    
    if (self.successCompletionBlock) {
        self.successCompletionBlock(self);
    }
}

- (void)startWithOutCache {
    
    [super start];
}

- (void)stop {
    [self.task cancel];
}
- (BOOL)statusCodeValidator:(NSError * __autoreleasing *)error {
    

    return YES;
}
- (id)encryptParameters:(id)params error:(NSError * _Nullable __autoreleasing *)error {
    return [fmReqeustSerializer encryptParameters:params error:error];
}
@end
