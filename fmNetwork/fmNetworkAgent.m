//
//  fmNetworkAgent.m
//  HXFundManager
//
//  Created by 柯浩然 on 8/10/18.
//  Copyright © 2018 柯浩然. All rights reserved.
//

#import "fmNetworkAgent.h"
#import "fmNetworkPrivate.h"
#import "AFNetworking.h"
#import "fmNetworkConfig.h"
#import <pthread/pthread.h>
#define Lock() pthread_mutex_lock(&_lock)
#define Unlock() pthread_mutex_unlock(&_lock)
static fmNetworkAgent *_instance = nil;
@implementation fmNetworkAgent{
    
    pthread_mutex_t _lock;
    
    AFHTTPSessionManager *_manager;
    NSMutableDictionary <NSNumber *, fmBaseRequest *>* _requestsRecord;
    fmNetworkConfig *_config;
    AFJSONResponseSerializer *_jsonResponseSerializer;
    AFXMLParserResponseSerializer *_xmlParserResponseSeralizer;
}

- (AFJSONResponseSerializer *)jsonResponseSerializer {
    if (!_jsonResponseSerializer) {
        
        _jsonResponseSerializer = [AFJSONResponseSerializer serializer];
    }
    return _jsonResponseSerializer;
}

- (AFXMLParserResponseSerializer *)xmlParserResponseSeralizer {
    if (!_xmlParserResponseSeralizer) {
        
        _xmlParserResponseSeralizer = [AFXMLParserResponseSerializer serializer];
    }
    return _xmlParserResponseSeralizer;
}

+ (instancetype)sharedAgent {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _config = [fmNetworkConfig sharedConfig];
        _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:_config.sessionConfig];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        pthread_mutex_init(&_lock, NULL);
        _requestsRecord = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addRequest:(fmBaseRequest *)request {
    
    NSError *encryptError = nil;
    [self handleParameterWithRequest:request error:&encryptError];
    if (encryptError) {
        [self requestDidFailureRequest:request error:encryptError];
        return;
    }
    
    NSError *reqeustSerializerError = nil;
    request.task = [self sessionTaskForRequest:request error:&reqeustSerializerError];
    if (reqeustSerializerError) {
        [self requestDidFailureRequest:request error:reqeustSerializerError];
        return;
    }
    
    [self addRequestToRecord:request];
    [request.task resume];
}

- (void)cancelRequest:(fmBaseRequest *)request {

    [request.task cancel];
    [request clearCompletionBlock];
    [self removeRecordWithRequest:request];
}

- (void)addRequestToRecord:(fmBaseRequest *)request {
    Lock();
    _requestsRecord[@(request.task.taskIdentifier)] = request;
    Unlock();
}
- (void)removeRecordWithRequest:(fmBaseRequest *)request {
    Lock();
    [_requestsRecord removeObjectForKey:@(request.task.taskIdentifier)];
    Unlock();
}
- (NSURLSessionTask *)sessionTaskForRequest:(fmBaseRequest *)request error:(NSError * _Nullable __autoreleasing *)error {
    
    NSString *url = [self bulidUrlWithRequest:request];
    id parm = [self handleParameterWithRequest:request error:nil];
    fmRequestMethod method = [request.child requestMethod];
    AFHTTPRequestSerializer *requestSerializer = [[AFJSONRequestSerializer alloc] init];
    
    switch (method) {
        case fmRequestMethodGET:
            return [self dataTaskWithHttpMethod:@"GET" requestSerializer:requestSerializer URLString:url parameters:parm error:error];
            break;
        default:
            break;
    }
}

- (NSURLSessionTask *)dataTaskWithHttpMethod:(NSString *)method requestSerializer:(AFHTTPRequestSerializer *)requestSerializer URLString:(NSString *)url parameters:(id)parm error:(NSError * _Nullable __autoreleasing *)error {
    
    NSURLRequest *request = [requestSerializer requestWithMethod:method URLString:url parameters:parm error:error];
    
    __block NSURLSessionTask *task = nil;
    task = [_manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        [self handlerRequestResult:task responseObject:responseObject error:error];
    }];
    return task;
}

- (void)handlerRequestResult:(NSURLSessionTask *)task responseObject:(id)responseObject error:(NSError *)error {
    
    fmBaseRequest *request = _requestsRecord[@(task.taskIdentifier)];
    
    NSError *serializerError = nil;
    NSError *validationError = nil;
    NSError *requestError = nil;
    BOOL success = NO;
    
    if ([responseObject isKindOfClass:[NSData class]]) {
        request.responseData = responseObject;
        switch ([request responseSerializerType]) {
            case fmResponseSerializerTypeHTTP:
                //do noting
                break;
            case fmResponseSerializerTypeJSON:
                request.responseJSONObject = [[self jsonResponseSerializer] responseObjectForResponse:task.response data:responseObject error:&serializerError];
                break;
            case fmResponseSerializerTypeXML:
                request.responseObject = [[self xmlParserResponseSeralizer] responseObjectForResponse:task.response data:responseObject error:&serializerError];
                break;
            default:
                break;
        }
    }
    
    if (error) {
        success = NO;
        requestError = error;
    }else if(serializerError) {
        success = NO;
        requestError = serializerError;
    }else {
        success = [self validateResult:request error:&validationError];
        requestError = validationError;
    }
    
    if (success) {
        
        [self requestDidSuccessRequest:request];
    }else {
        [self requestDidFailureRequest:request error:requestError];
    }
    [self removeRecordWithRequest:request];
    [request clearCompletionBlock];
}

- (BOOL)validateResult:(fmBaseRequest *)request error:(NSError * _Nullable __autoreleasing *)error {
    BOOL validate = [request statusCodeValidator:error];

    return validate;
}

- (void)requestDidSuccessRequest:(fmBaseRequest *)request {
    
    // saveResponse
    [request requestDidSuccessComplition];
    //callBack
    if (request.successCompletionBlock) {
        request.successCompletionBlock(request);
    }
}
- (void)requestDidFailureRequest:(fmBaseRequest *)request error:(NSError *)error{
    request.error = error;
    if (request.failureCompletionBlock) {
        request.failureCompletionBlock(request);
    }
}
- (NSString *)bulidUrlWithRequest:(fmBaseRequest *)request {
    
    NSString *detailUrl = [request.child requestUrl];
    
    for (id<fmUrlFilterProtocol> filter in _config.urlFilters) {
        detailUrl = [filter filterWithUrl:detailUrl request:request];
    }
    NSURL *baseUrl = nil;

    if ([request baseUrl]) {
        baseUrl = [NSURL URLWithString:[request baseUrl]];
    }else {
        baseUrl = [NSURL URLWithString:_config.baseUrl];
    }
    
    if (baseUrl != nil) {
        return [NSURL URLWithString:detailUrl relativeToURL:baseUrl].absoluteString;
    }else {
        return detailUrl;
    }
}

- (id)handleParameterWithRequest:(fmBaseRequest *)request error:(NSError * _Nullable __autoreleasing *)error{

    id parm = [request.child requestArgument];
     
    return [request encryptParameters:parm error:error];
}

@end
