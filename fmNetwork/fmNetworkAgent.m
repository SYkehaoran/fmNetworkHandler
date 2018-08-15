//
//  fmNetworkAgent.m
//  HXFundManager
//
//  Created by 柯浩然 on 8/10/18.
//  Copyright © 2018 柯浩然. All rights reserved.
//

#import "fmNetworkAgent.h"
#import "fmBaseRequest.h"
#import "fmNetworkPrivate.h"
#import "AFNetworking.h"
#import "fmNetworkConfig.h"

static fmNetworkAgent *_instance = nil;
@implementation fmNetworkAgent{
    
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

- (void)addRequestToRecord:(fmBaseRequest *)request {
    _requestsRecord[@(request.task.taskIdentifier)] = request;
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
    
    if (error) {
        
        [self requestDidFailureRequest:request error:error];
        return;
    }
    
    NSError *serializerError = nil;
    if ([responseObject isKindOfClass:[NSData class]]) {
        request.responseData = responseObject;
        switch ([request responseSerializerType]) {
            case fmResponseSerializerTypeHTTP:
                //do noting
                break;
            case fmResponseSerializerTypeJSON:
                request.responseJSONObject = [[self jsonResponseSerializer] responseObjectForResponse:task.response data:responseObject error:&serializerError];
                
            case fmResponseSerializerTypeXML:
                request.responseObject = [[self xmlParserResponseSeralizer] responseObjectForResponse:task.response data:responseObject error:&serializerError];
            default:
                break;
        }
        
    }
    
    NSError *validationError = nil;
    BOOL success = [self validateResult:request error:&validationError];
    if (validationError) {
        [self requestDidFailureRequest:request error:validationError];
        return;
    }
    
    if (success) {
        
        [self requestDidSuccessRequest:request];
    }
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
