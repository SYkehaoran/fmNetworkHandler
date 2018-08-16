//
//  fmNetworkAgent.h
//  HXFundManager
//
//  Created by 柯浩然 on 8/10/18.
//  Copyright © 2018 柯浩然. All rights reserved.
//

#import <Foundation/Foundation.h>
@class fmBaseRequest;
@interface fmNetworkAgent : NSObject
+ (instancetype)sharedAgent;
- (void)addRequest:(fmBaseRequest *)request;
- (void)cancelRequest:(fmBaseRequest *)request;
@end
