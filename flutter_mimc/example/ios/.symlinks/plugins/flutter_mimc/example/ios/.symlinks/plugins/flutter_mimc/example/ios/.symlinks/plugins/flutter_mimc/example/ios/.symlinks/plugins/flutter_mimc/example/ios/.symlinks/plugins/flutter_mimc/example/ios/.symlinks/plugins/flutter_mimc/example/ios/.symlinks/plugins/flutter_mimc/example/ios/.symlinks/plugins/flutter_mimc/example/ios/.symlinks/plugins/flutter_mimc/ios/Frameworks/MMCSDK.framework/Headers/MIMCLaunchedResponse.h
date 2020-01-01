//
//  MIMCLaunchedResponse.h
//  MMCSDK
//
//  Created by zhangdan on 2018/7/19.
//  Copyright © 2018年 mimc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MIMCLaunchedResponse : NSObject

- (id)initWithAccepted:(Boolean)accepted desc:(NSString *)desc;
- (Boolean)isAccepted;
- (NSString *)getDesc;
@end
