//
//  fmResponseSerializer.h
//  testUI
//
//  Created by 柯浩然 on 8/14/18.
//  Copyright © 2018 柯浩然. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface fmResponseSerializer : NSObject

+ (BOOL)validateResponseJSONObject:(id)responseJSONObject error:(NSError * _Nullable __autoreleasing *)error;

@end
