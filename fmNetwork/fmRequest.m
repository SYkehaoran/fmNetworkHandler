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
#import "fmNetworkPrivate.h"
@interface fmRequest ()


@property(nonatomic, strong) NSData *cacheData;
@property(nonatomic, strong) id cacheJson;
@property(nonatomic, strong) id cacheXML;
@end

@implementation fmRequest

- (NSData *)responseData {
    if (_cacheData) {
        return _cacheData;
    }
    return [super responseData];
}

- (id)responseJSONObject {
    if (_cacheJson) {
        return _cacheJson;
    }
    return [super responseJSONObject];
}

- (id)responseObject {
     if (_cacheXML) {
        return _cacheXML;
     }else if (_cacheData) {
         return _cacheData;
     }
    return  [super responseObject];
}

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

- (BOOL)statusCodeValidator:(NSError * __autoreleasing *)error {
    
    return YES;
}

- (void)requestDidSuccessComplition {
    
    if (self.cacheResponseData) {
        [self saveResponseToFile:self.responseData];
    }
}

- (id)encryptParameters:(id)params error:(NSError * _Nullable __autoreleasing *)error {
    return [fmReqeustSerializer encryptParameters:params error:error];
}
- (BOOL)loadCacheData {
    NSString *filePath = [self getCachePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        
        NSData *cacheData = [NSData dataWithContentsOfFile:filePath];
        _cacheData = cacheData;
        switch (self.responseSerializerType) {
            case fmResponseSerializerTypeHTTP:
                //do noting
                return YES;
                break;
            case fmResponseSerializerTypeJSON:{
                NSError *error;
                _cacheJson = [NSJSONSerialization JSONObjectWithData:_cacheData options:NSJSONReadingAllowFragments error:&error];
                return  error == nil;
                
            }
                break;
            case fmResponseSerializerTypeXML:
                
                break;
            default:
                break;
        }
    }
    return NO;
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
    NSString *argument = [self cacheFileNameFilterWithArgument:[self.child requestArgument]];
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
@end
