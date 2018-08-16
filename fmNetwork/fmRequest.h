//
//  fmRequest.h
//  HXFundManager
//
//  Created by 柯浩然 on 8/9/18.
//  Copyright © 2018 柯浩然. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "fmBaseRequest.h"

@interface fmRequest : fmBaseRequest<fmRequestProtocol>

@property(nonatomic, assign) BOOL ignoreCache;

- (BOOL)loadCacheWithError:(NSError *)error;

- (void)stop;

- (void)startWithOutCache;
@end
