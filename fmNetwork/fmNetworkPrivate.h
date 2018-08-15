//
//  fmNetworkPrivate.h
//  HXFundManager
//
//  Created by 柯浩然 on 8/9/18.
//  Copyright © 2018 柯浩然. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "fmBaseRequest.h"

@interface fmNetworkUtils : NSObject

+ (NSString *)md5StringFromString:(NSString *)string;

@end

@interface fmBaseRequest (setter)
@property(nonatomic, strong, readwrite) NSURLSessionTask *task;
@property(nonatomic, strong, readwrite) id<fmRequestProtocol> child;
@property(nonatomic, strong, readwrite) id responseJSONObject;
@property(nonatomic, strong, readwrite) id responseObject;
@property(nonatomic, strong, readwrite) NSData *responseData;
@property(nonatomic, strong, readwrite) NSError *error;
@end
