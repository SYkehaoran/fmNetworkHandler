//
//  fmNetworkConfig.m
//  testUI
//
//  Created by 柯浩然 on 8/10/18.
//  Copyright © 2018 柯浩然. All rights reserved.
//

#import "fmNetworkConfig.h"
static fmNetworkConfig *_instance = nil;
@implementation fmNetworkConfig{
    NSMutableArray<id<fmUrlFilterProtocol>> *_urlFilterDic;
    
}

+(instancetype)sharedConfig {
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
        _urlFilterDic = [NSMutableArray array];
        
    }
    return self;
}

- (void)addFilter:(id<fmUrlFilterProtocol>)filter {
    
    [_urlFilterDic addObject:filter];
}

- (NSArray *)urlFilters {
    return [_urlFilterDic copy];
}


@end
