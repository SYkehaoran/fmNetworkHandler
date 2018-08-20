//
//  fmBaseRequest.h
//  HXFundManager
//
//  Created by 柯浩然 on 8/1/18.
//  Copyright © 2018 China Asset Management Co., Ltd. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, fmRequestMethod) {
    fmRequestMethodGET,
    fmRequestMethodPOST,
};

typedef NS_ENUM(NSUInteger, fmResponseSerializerType) {
    fmResponseSerializerTypeHTTP,
    fmResponseSerializerTypeJSON,
    fmResponseSerializerTypeXML,
};
@protocol AFMultipartFormData;
typedef void (^AFConstructingBlock)(id <AFMultipartFormData>formData);
@class fmBaseRequest;
typedef void(^fmRequestCompletionBlock)(__kindof fmBaseRequest *request);
typedef void (^AFURLSessionTaskProgressBlock)(NSProgress *progress);
@protocol fmRequestProtocol

- (NSString *)requestUrl;
- (fmRequestMethod)requestMethod;
- (id)requestArgument;

@end

@interface fmBaseRequest : NSObject

@property(nonatomic, strong, readonly) NSURLSessionTask *task;
@property(nonatomic, strong, readonly) id<fmRequestProtocol> child;
///JSON转译之后的数据
@property(nonatomic, strong, readonly) id responseJSONObject;
///原始数据或其他方式转译之后的数据
@property(nonatomic, strong, readonly) id responseObject;
///原始数据
@property(nonatomic, strong, readonly) NSData *responseData;

@property(nonatomic, strong, readonly) NSError *error;

@property(nonatomic, copy, nullable) fmRequestCompletionBlock successCompletionBlock;
@property(nonatomic, copy, nullable) fmRequestCompletionBlock failureCompletionBlock;


- (NSString *)baseUrl;
- (fmResponseSerializerType)responseSerializerType;
- (NSInteger)timeoutInterval;

- (AFConstructingBlock)constructingBlock;
- (NSString *)downloadPath;
- (AFURLSessionTaskProgressBlock)downloadProgressBlock;

- (BOOL)statusCodeValidator:(NSError * __autoreleasing *)error;
- (id)encryptParameters:(id)params error:(NSError * _Nullable __autoreleasing *)error;

- (void)requestDidSuccessComplition;

- (void)start;
- (void)stop;
- (void)startWithCompletionBlockWithSuccess:(fmRequestCompletionBlock)success failure:(fmRequestCompletionBlock)failure;

- (void)clearCompletionBlock;

- (NSString *)cacheFileNameFilterWithArgument:(id)argument;

///  Additional HTTP request header field.
- (nullable NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary;


@end
