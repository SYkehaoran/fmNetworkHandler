//
//  fmBaseRequest.m
//  HXFundManager
//
//  Created by 柯浩然 on 8/1/18.
//  Copyright © 2018 China Asset Management Co., Ltd. All rights reserved.
//

#import "fmBaseRequest.h"
#import "fmNetworkPrivate.h"
#import "fmNetworkAgent.h"
@interface fmBaseRequest()

@property(nonatomic, strong, readwrite) NSError *error;
@property(nonatomic, strong, readwrite) NSURLSessionTask *task;
@property(nonatomic, strong, readwrite) id responseJSONObject;//JSON转译之后的数据
@property(nonatomic, strong, readwrite) id responseObject;//其他方式转译之后的数据
@property(nonatomic, strong, readwrite) NSData *responseData;//原始数据

@end

@implementation fmBaseRequest

-(NSString *)baseUrl{
    return @"";
}

- (fmResponseSerializerType)responseSerializerType {
    return fmResponseSerializerTypeJSON;
}
- (NSString *)downloadPath {
    return nil;
}
- (AFURLSessionTaskProgressBlock)downloadProgressBlock {
    return nil;
}

- (NSInteger)timeoutInterval {
    return 60;
}

- (AFConstructingBlock)constructingBlock {

    return nil;
}

- (BOOL)statusCodeValidator:(NSError * __autoreleasing *)error {
    
    return YES;
}

- (NSString *)requestArgument {
    return nil;
}
- (NSString *)requestUrl {
    return nil;
}
- (fmRequestMethod)requestMethod {
    return fmRequestMethodGET;
}

- (void)setCompletionBlockWithSuccess:(fmRequestCompletionBlock)success failure:(fmRequestCompletionBlock)failure {
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
}

- (void)startWithCompletionBlockWithSuccess:(fmRequestCompletionBlock)success failure:(fmRequestCompletionBlock)failure {
    
    [self setCompletionBlockWithSuccess:success failure:failure];
    [self start];
}

- (void)start {
    [[fmNetworkAgent sharedAgent] addRequest:self];
}
- (void)stop {
     [[fmNetworkAgent sharedAgent] cancelRequest:self];
}
- (void)clearCompletionBlock {
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}


- (id)encryptParameters:(id)params error:(NSError * _Nullable __autoreleasing *)error {
   return params;
}
- (void)requestDidSuccessComplition {
 
}

- (NSString *)cacheFileNameFilterWithArgument:(id)argument {
    return argument;
}

- (nullable NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary {
    return nil;
}
@end
