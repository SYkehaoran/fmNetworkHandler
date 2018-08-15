//
//  fmNetworkConfig.h
//  testUI
//
//  Created by 柯浩然 on 8/10/18.
//  Copyright © 2018 柯浩然. All rights reserved.
//

#import <Foundation/Foundation.h>

@class fmBaseRequest;
@protocol fmUrlFilterProtocol
- (NSString *)filterWithUrl:(NSString *)originUrl request:(fmBaseRequest *)request;
@end

@interface fmNetworkConfig : NSObject

@property(nonatomic, copy) NSString *baseUrl;

@property(nonatomic, strong, readonly) NSArray *urlFilters;

@property(nonatomic, strong) NSURLSessionConfiguration *sessionConfig;

///这些方法每个请求都会进行，把这个类做为单例，不用每次都创建
+(instancetype)sharedConfig;

- (void)addFilter:(id<fmUrlFilterProtocol>)filter;

@end
