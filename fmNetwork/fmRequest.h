//
//  fmRequest.h
//  HXFundManager
//
//  Created by 柯浩然 on 8/9/18.
//  Copyright © 2018 柯浩然. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "fmBaseRequest.h"

@interface fmRequest : fmBaseRequest
@property(nonatomic, assign) BOOL ignoreCache;
@property(nonatomic, assign) BOOL cacheResponseData;
- (BOOL)loadCacheWithError:(NSError *)error;

- (void)startWithOutCache;
@end
