//
//  fmReqeustSerializer.h
//  testUI
//
//  Created by 柯浩然 on 8/13/18.
//  Copyright © 2018 柯浩然. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface fmReqeustSerializer : NSObject
+ (id)encryptParameters:(id)params error:(NSError * _Nullable __autoreleasing *)error;
@end
