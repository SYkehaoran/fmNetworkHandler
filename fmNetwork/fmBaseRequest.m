//
//  fmBaseRequest.m
//  HXFundManager
//
//  Created by 柯浩然 on 8/1/18.
//  Copyright © 2018 柯浩然. All rights reserved.
//

#import "fmBaseRequest.h"
#import "fmNetworkPrivate.h"
#import "fmNetworkAgent.h"
@interface fmBaseRequest()

@property(nonatomic, strong, readwrite) NSError *error;
@property(nonatomic, strong, readwrite) NSURLSessionTask *task;
@property(nonatomic, strong, readwrite) id<fmRequestProtocol> child;
@property(nonatomic, strong, readwrite) id responseJSONObject;//JSON转译之后的数据
@property(nonatomic, strong, readwrite) id responseObject;//其他方式转译之后的数据
@property(nonatomic, strong, readwrite) NSData *responseData;//原始数据

@end

@implementation fmBaseRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        if ([self conformsToProtocol:@protocol(fmRequestProtocol)]) {
            self.child = (id<fmRequestProtocol>) self;
        }else {
            NSAssert(NO, @"子类必须服从<fmRequestProtocol>");
        }
    }
    return self;
}

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

- (void)saveResponseToFile:(id)responseObject {
    
    NSString *cacheFile = [self getCacheFile];
    [responseObject writeToFile:cacheFile options:NSDataWritingAtomic error:nil];
}

- (NSString *)getCacheFile {
    NSString *cachePath = [self getCachePath];
    NSString *cacheName = [self getCacheName];
    return [cachePath stringByAppendingPathComponent:cacheName];
}

- (NSString *)getCachePath {
    NSString *basePath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject;
    NSString *path = [basePath stringByAppendingPathComponent:@"lazyRequestCache"];
    
    [self creatDirectoryIfNeeded:path];
    return path;
}

- (NSString *)getCacheName {
    
    fmRequestMethod method = [self.child requestMethod];
    NSString *urlStr = [self.child requestUrl];
    NSString *argument = [self.child requestArgument];
    NSString *cacheName = [NSString stringWithFormat:@"Method:%ld,URL:%@,Argument:%@",method,urlStr,argument];
    return [fmNetworkUtils md5StringFromString:cacheName];
}

- (void)creatDirectoryIfNeeded:(NSString *)path {
    NSFileManager *manager =[NSFileManager defaultManager];
    BOOL isDir;
    if (![manager fileExistsAtPath:path isDirectory:&isDir] ) {
        
        [self creatBaseDirectoryAtPath:path];
    }else {
        
        if (!isDir) {
            [manager removeItemAtPath:path error:nil];
            [self creatBaseDirectoryAtPath:path];
        }
    }
}

- (void)creatBaseDirectoryAtPath:(NSString *)path {
    
    NSFileManager *manager =[NSFileManager defaultManager];

    NSError *error =nil;
    [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        NSLog(@"creat Directory failure");
    }
}
- (id)encryptParameters:(id)params error:(NSError * _Nullable __autoreleasing *)error {
   return params;
}
- (void)requestDidSuccessComplition {
 
    [self saveResponseToFile:self.responseData];
}

- (nullable NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary {
    return nil;
}
@end
